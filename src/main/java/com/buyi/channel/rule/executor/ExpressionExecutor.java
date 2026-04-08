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
 * 表达式执行器 - 支持JEXL表达式求值
 * Expression Executor - Supports JEXL expression evaluation
 *
 * 合并优化说明：
 * - 基于buyi_cloud JavaExpressionExecutor的JEXL引擎
 * - 优化1：增加编译表达式缓存（ConcurrentHashMap），避免重复编译
 *   buyi_cloud的JexlBuilder.cache(512)仅缓存引擎内部状态，
 *   这里额外缓存JexlExpression对象，减少解析开销
 * - 优化2：支持outputVariable自动存储结果到上下文变量
 * - 优化3：表达式求值失败时提供更精确的错误信息
 */
public class ExpressionExecutor implements ChannelRuleExecutor {

    private static final Logger logger = LoggerFactory.getLogger(ExpressionExecutor.class);
    private final JexlEngine jexlEngine;
    private final Map<String, JexlExpression> expressionCache;
    private final int maxCacheSize;

    public ExpressionExecutor() {
        this(1024);
    }

    public ExpressionExecutor(int maxCacheSize) {
        this.jexlEngine = new JexlBuilder()
                .cache(512)
                .strict(true)
                .silent(false)
                .create();
        this.expressionCache = new ConcurrentHashMap<>();
        this.maxCacheSize = maxCacheSize;
    }

    @Override
    public void execute(ChannelRule rule, ChannelRuleContext context) {
        long startTime = System.currentTimeMillis();

        try {
            String expression = rule.getRuleContent();
            if (expression == null || expression.trim().isEmpty()) {
                context.setSuccess(true);
                context.setResult(null);
                return;
            }

            // 创建JEXL上下文
            JexlContext jexlContext = new MapContext();
            for (Map.Entry<String, Object> entry : context.getVariables().entrySet()) {
                jexlContext.set(entry.getKey(), entry.getValue());
            }

            // 加载规则参数
            if (rule.getRuleParams() != null) {
                for (Map.Entry<String, Object> entry : rule.getRuleParams().entrySet()) {
                    jexlContext.set(entry.getKey(), entry.getValue());
                }
            }

            // 获取或编译表达式
            JexlExpression compiledExpr = getOrCompileExpression(expression);

            // 执行表达式
            Object result = compiledExpr.evaluate(jexlContext);

            // 设置结果
            context.setResult(result);
            context.setSuccess(true);

            // 如果指定了输出变量名，存储到上下文
            if (rule.getOutputVariable() != null && !rule.getOutputVariable().isEmpty()) {
                context.setVariable(rule.getOutputVariable(), result);
            }

            // 以规则代码为键存储步骤结果
            context.setStepResult(rule.getRuleCode(), result);

            logger.debug("Expression '{}' evaluated to: {}", expression, result);

        } catch (Exception e) {
            logger.error("Failed to execute expression rule: {}", rule.getRuleCode(), e);
            context.setSuccess(false);
            context.setErrorMessage("Expression execution failed for rule '" +
                    rule.getRuleCode() + "': " + e.getMessage());
        } finally {
            long duration = System.currentTimeMillis() - startTime;
            context.addTrace(rule.getRuleCode(), "Expression executed", context.isSuccess(), duration);
        }
    }

    @Override
    public ChannelRuleType getSupportedType() {
        return ChannelRuleType.EXPRESSION;
    }

    /**
     * 获取或编译表达式（带缓存）
     */
    private JexlExpression getOrCompileExpression(String expression) {
        return expressionCache.computeIfAbsent(expression, expr -> {
            // 简单的缓存大小控制
            if (expressionCache.size() >= maxCacheSize) {
                expressionCache.clear();
                logger.info("Expression cache cleared (exceeded max size: {})", maxCacheSize);
            }
            return jexlEngine.createExpression(expr);
        });
    }

    /**
     * 评估条件表达式，返回布尔值
     * 供FlowEngine等外部调用
     *
     * @param expression 条件表达式
     * @param variables  变量
     * @return 条件是否为真
     */
    public boolean evaluateCondition(String expression, Map<String, Object> variables) {
        try {
            JexlContext jexlContext = new MapContext();
            if (variables != null) {
                for (Map.Entry<String, Object> entry : variables.entrySet()) {
                    jexlContext.set(entry.getKey(), entry.getValue());
                }
            }

            JexlExpression compiledExpr = getOrCompileExpression(expression);
            Object result = compiledExpr.evaluate(jexlContext);
            return toBoolean(result);
        } catch (Exception e) {
            logger.error("Failed to evaluate condition: {}", expression, e);
            return false;
        }
    }

    /**
     * 清除表达式缓存
     */
    public void clearCache() {
        expressionCache.clear();
    }

    /**
     * 获取缓存大小
     */
    public int getCacheSize() {
        return expressionCache.size();
    }

    /**
     * 转换为布尔值
     */
    static boolean toBoolean(Object value) {
        if (value == null) {
            return false;
        }
        if (value instanceof Boolean) {
            return (Boolean) value;
        }
        if (value instanceof Number) {
            return ((Number) value).doubleValue() != 0;
        }
        if (value instanceof String) {
            String str = (String) value;
            return !str.isEmpty() && !"false".equalsIgnoreCase(str) && !"0".equals(str);
        }
        return true;
    }
}
