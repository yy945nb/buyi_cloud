package com.buyi.channel.rule.engine;

import com.buyi.channel.rule.enums.ChannelExecutionStatus;
import com.buyi.channel.rule.enums.ChannelRuleType;
import com.buyi.channel.rule.exception.ChannelRuleException;
import com.buyi.channel.rule.exception.ChannelRuleExecutionException;
import com.buyi.channel.rule.exception.ChannelRuleTimeoutException;
import com.buyi.channel.rule.executor.ChannelRuleExecutor;
import com.buyi.channel.rule.executor.ConditionExecutor;
import com.buyi.channel.rule.executor.ExpressionExecutor;
import com.buyi.channel.rule.executor.ScriptExecutor;
import com.buyi.channel.rule.metrics.ChannelRuleMetrics;
import com.buyi.channel.rule.model.ChannelRule;
import com.buyi.channel.rule.model.ChannelRuleContext;
import com.buyi.channel.rule.model.ChannelRuleResult;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.HashMap;
import java.util.Map;

/**
 * 渠道规则引擎核心
 * Channel Rule Engine Core
 *
 * 合并优化说明：
 * 1. 执行器注册使用HashMap（O(1)查找），替代buyi_cloud RuleEngine的List线性遍历
 * 2. 内置重试机制（buyi_cloud DslNode有retryCount字段但从未真正实现重试逻辑）
 * 3. 超时控制（融合DslRuleChain和ProcessingConfig的timeout特性）
 * 4. 内置指标收集（buyi_cloud完全没有指标机制）
 * 5. 自动注册默认执行器（Expression、Condition、Script）
 */
public class ChannelRuleEngine {

    private static final Logger logger = LoggerFactory.getLogger(ChannelRuleEngine.class);

    private final Map<ChannelRuleType, ChannelRuleExecutor> executorRegistry;
    private final ChannelRuleMetrics metrics;
    private final ExpressionExecutor expressionExecutor;

    public ChannelRuleEngine() {
        this.executorRegistry = new HashMap<>();
        this.metrics = new ChannelRuleMetrics();
        this.expressionExecutor = new ExpressionExecutor();

        // 自动注册默认执行器
        registerExecutor(expressionExecutor);
        registerExecutor(new ConditionExecutor());
        registerExecutor(new ScriptExecutor());
    }

    /**
     * 注册规则执行器
     * HashMap注册实现O(1)查找，优于buyi_cloud的List线性遍历
     *
     * @param executor 规则执行器
     */
    public void registerExecutor(ChannelRuleExecutor executor) {
        if (executor != null) {
            executorRegistry.put(executor.getSupportedType(), executor);
            logger.info("Registered executor for type: {}", executor.getSupportedType());
        }
    }

    /**
     * 执行单条规则
     *
     * @param rule    规则配置
     * @param context 执行上下文
     * @return 执行结果
     */
    public ChannelRuleResult executeRule(ChannelRule rule, ChannelRuleContext context) {
        if (rule == null) {
            throw new ChannelRuleException("Rule cannot be null");
        }
        if (context == null) {
            throw new ChannelRuleException("Context cannot be null");
        }
        if (!rule.isEnabled()) {
            context.setStatus(ChannelExecutionStatus.SKIPPED);
            context.addTrace(rule.getRuleCode(), "Rule is disabled, skipped", true);
            context.finishExecution();
            return ChannelRuleResult.fromContext(context);
        }

        context.setCurrentRuleCode(rule.getRuleCode());

        // 使用HashMap O(1)查找执行器
        ChannelRuleExecutor executor = executorRegistry.get(rule.getRuleType());
        if (executor == null) {
            String errorMsg = "No executor registered for rule type: " + rule.getRuleType();
            logger.error(errorMsg);
            context.setSuccess(false);
            context.setErrorMessage(errorMsg);
            context.finishExecution();
            return ChannelRuleResult.fromContext(context);
        }

        // 带重试的执行
        executeWithRetry(rule, context, executor);

        context.finishExecution();

        // 收集指标
        metrics.recordExecution(rule.getRuleCode(), context.isSuccess(),
                context.getTotalExecutionTime(), context.getRetryCount());

        return ChannelRuleResult.fromContext(context);
    }

    /**
     * 带重试的执行逻辑
     * buyi_cloud DslNode定义了retryCount字段但从未在执行引擎中实现，这里真正实现了重试
     */
    void executeWithRetry(ChannelRule rule, ChannelRuleContext context, ChannelRuleExecutor executor) {
        int maxRetries = rule.getMaxRetries();
        long retryDelay = rule.getRetryDelayMs();

        for (int attempt = 0; attempt <= maxRetries; attempt++) {
            if (attempt > 0) {
                context.incrementRetryCount();
                context.setStatus(ChannelExecutionStatus.RETRYING);
                logger.info("Retrying rule '{}', attempt {}/{}", rule.getRuleCode(), attempt, maxRetries);

                try {
                    Thread.sleep(retryDelay);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                    context.setSuccess(false);
                    context.setErrorMessage("Retry interrupted for rule: " + rule.getRuleCode());
                    return;
                }
            }

            // 检查超时
            if (rule.getTimeoutMs() > 0 && context.getElapsedTime() > rule.getTimeoutMs()) {
                context.setStatus(ChannelExecutionStatus.TIMEOUT);
                context.setErrorMessage("Rule execution timed out after " + rule.getTimeoutMs() + "ms");
                return;
            }

            // 重置状态并执行
            context.setSuccess(true);
            context.setErrorMessage(null);
            executor.execute(rule, context);

            if (context.isSuccess()) {
                return;
            }

            if (attempt < maxRetries) {
                logger.warn("Rule '{}' failed on attempt {}, will retry. Error: {}",
                        rule.getRuleCode(), attempt + 1, context.getErrorMessage());
            }
        }
    }

    /**
     * 获取指标
     */
    public ChannelRuleMetrics getMetrics() {
        return metrics;
    }

    /**
     * 获取表达式执行器（供FlowEngine使用）
     */
    public ExpressionExecutor getExpressionExecutor() {
        return expressionExecutor;
    }

    /**
     * 获取注册的执行器
     */
    public Map<ChannelRuleType, ChannelRuleExecutor> getExecutorRegistry() {
        return new HashMap<>(executorRegistry);
    }
}
