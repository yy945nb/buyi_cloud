package com.buyi.channel.rule.executor;

import com.buyi.channel.rule.enums.ChannelRuleType;
import com.buyi.channel.rule.model.ChannelRule;
import com.buyi.channel.rule.model.ChannelRuleContext;
import org.apache.commons.jexl3.JexlBuilder;
import org.apache.commons.jexl3.JexlContext;
import org.apache.commons.jexl3.JexlEngine;
import org.apache.commons.jexl3.JexlExpression;
import org.apache.commons.jexl3.MapContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 条件执行器 - 专门用于条件判断
 * Condition Executor - Specialized for condition evaluation
 *
 * 从buyi_cloud的FlowEngine.evaluateCondition和DslRuleChainEngine.executeConditionNode
 * 的内联实现中抽取为独立的执行器，职责更清晰。
 */
public class ConditionExecutor implements ChannelRuleExecutor {

    private static final Logger logger = LoggerFactory.getLogger(ConditionExecutor.class);
    private final JexlEngine jexlEngine;
    private final Map<String, JexlExpression> expressionCache;

    public ConditionExecutor() {
        this.jexlEngine = new JexlBuilder()
                .cache(512)
                .strict(false)
                .silent(false)
                .create();
        this.expressionCache = new ConcurrentHashMap<>();
    }

    @Override
    public void execute(ChannelRule rule, ChannelRuleContext context) {
        long startTime = System.currentTimeMillis();

        try {
            String condition = rule.getRuleContent();
            if (condition == null || condition.trim().isEmpty()) {
                context.setResult(false);
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

            JexlExpression compiledExpr = expressionCache.computeIfAbsent(
                    condition, jexlEngine::createExpression);
            Object result = compiledExpr.evaluate(jexlContext);
            boolean conditionMet = ExpressionExecutor.toBoolean(result);

            context.setResult(conditionMet);
            context.setSuccess(true);

            if (rule.getOutputVariable() != null && !rule.getOutputVariable().isEmpty()) {
                context.setVariable(rule.getOutputVariable(), conditionMet);
            }

            context.setStepResult(rule.getRuleCode(), conditionMet);

            logger.debug("Condition '{}' evaluated to: {}", condition, conditionMet);

        } catch (Exception e) {
            logger.error("Failed to evaluate condition rule: {}", rule.getRuleCode(), e);
            context.setSuccess(false);
            context.setErrorMessage("Condition evaluation failed for rule '" +
                    rule.getRuleCode() + "': " + e.getMessage());
        } finally {
            long duration = System.currentTimeMillis() - startTime;
            context.addTrace(rule.getRuleCode(), "Condition evaluated", context.isSuccess(), duration);
        }
    }

    @Override
    public ChannelRuleType getSupportedType() {
        return ChannelRuleType.CONDITION;
    }
}
