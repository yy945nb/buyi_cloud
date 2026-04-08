package com.buyi.channel.rule.executor;

import com.buyi.channel.rule.enums.ChannelRuleType;
import com.buyi.channel.rule.model.ChannelRule;
import com.buyi.channel.rule.model.ChannelRuleContext;
import org.apache.commons.jexl3.JexlBuilder;
import org.apache.commons.jexl3.JexlContext;
import org.apache.commons.jexl3.JexlEngine;
import org.apache.commons.jexl3.JexlScript;
import org.apache.commons.jexl3.MapContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 脚本执行器 - 支持多行JEXL脚本
 * Script Executor - Supports multi-line JEXL scripts
 *
 * 合并优化说明：
 * - 基于buyi_cloud ProcessingEngine中的ScriptActionExecutor
 * - 使用JexlScript替代JexlExpression，支持多行脚本和流程控制语句
 * - 增加脚本编译缓存
 */
public class ScriptExecutor implements ChannelRuleExecutor {

    private static final Logger logger = LoggerFactory.getLogger(ScriptExecutor.class);
    private final JexlEngine jexlEngine;
    private final Map<String, JexlScript> scriptCache;

    public ScriptExecutor() {
        this.jexlEngine = new JexlBuilder()
                .cache(512)
                .strict(false)
                .silent(false)
                .create();
        this.scriptCache = new ConcurrentHashMap<>();
    }

    @Override
    public void execute(ChannelRule rule, ChannelRuleContext context) {
        long startTime = System.currentTimeMillis();

        try {
            String script = rule.getRuleContent();
            if (script == null || script.trim().isEmpty()) {
                context.setResult(null);
                context.setSuccess(true);
                return;
            }

            JexlContext jexlContext = new MapContext();
            for (Map.Entry<String, Object> entry : context.getVariables().entrySet()) {
                jexlContext.set(entry.getKey(), entry.getValue());
            }

            if (rule.getRuleParams() != null) {
                for (Map.Entry<String, Object> entry : rule.getRuleParams().entrySet()) {
                    jexlContext.set(entry.getKey(), entry.getValue());
                }
            }

            JexlScript compiledScript = scriptCache.computeIfAbsent(
                    script, jexlEngine::createScript);
            Object result = compiledScript.execute(jexlContext);

            context.setResult(result);
            context.setSuccess(true);

            if (rule.getOutputVariable() != null && !rule.getOutputVariable().isEmpty()) {
                context.setVariable(rule.getOutputVariable(), result);
            }

            context.setStepResult(rule.getRuleCode(), result);

            logger.debug("Script executed for rule '{}', result: {}", rule.getRuleCode(), result);

        } catch (Exception e) {
            logger.error("Failed to execute script rule: {}", rule.getRuleCode(), e);
            context.setSuccess(false);
            context.setErrorMessage("Script execution failed for rule '" +
                    rule.getRuleCode() + "': " + e.getMessage());
        } finally {
            long duration = System.currentTimeMillis() - startTime;
            context.addTrace(rule.getRuleCode(), "Script executed", context.isSuccess(), duration);
        }
    }

    @Override
    public ChannelRuleType getSupportedType() {
        return ChannelRuleType.SCRIPT;
    }
}
