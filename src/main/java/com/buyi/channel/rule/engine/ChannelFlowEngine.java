package com.buyi.channel.rule.engine;

import com.buyi.channel.rule.enums.ChannelExecutionStatus;
import com.buyi.channel.rule.exception.ChannelRuleException;
import com.buyi.channel.rule.exception.ChannelRuleTimeoutException;
import com.buyi.channel.rule.executor.ExpressionExecutor;
import com.buyi.channel.rule.model.ChannelRule;
import com.buyi.channel.rule.model.ChannelRuleContext;
import com.buyi.channel.rule.model.ChannelRuleFlow;
import com.buyi.channel.rule.model.ChannelRuleResult;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 渠道流程引擎
 * Channel Flow Engine
 *
 * 合并优化说明：
 * 1. 融合buyi_cloud FlowEngine的优先级排序和条件执行能力
 * 2. 融合DslRuleChainEngine的执行深度和超时控制
 * 3. 融合ProcessingEngine的迭代执行（非递归）防止栈溢出
 * 4. 优化：将规则缓存和条件评估分离，职责更清晰
 * 5. 优化：流程执行结果包含详细的步骤追踪信息
 */
public class ChannelFlowEngine {

    private static final Logger logger = LoggerFactory.getLogger(ChannelFlowEngine.class);

    private final ChannelRuleEngine ruleEngine;
    private final Map<String, ChannelRule> ruleCache;
    private final ExpressionExecutor expressionExecutor;
    private boolean enablePrioritySorting = true;

    public ChannelFlowEngine(ChannelRuleEngine ruleEngine) {
        if (ruleEngine == null) {
            throw new ChannelRuleException("Rule engine cannot be null");
        }
        this.ruleEngine = ruleEngine;
        this.ruleCache = new HashMap<>();
        this.expressionExecutor = ruleEngine.getExpressionExecutor();
    }

    /**
     * 注册规则到缓存
     *
     * @param rule 规则配置
     */
    public void registerRule(ChannelRule rule) {
        if (rule != null && rule.getRuleCode() != null) {
            ruleCache.put(rule.getRuleCode(), rule);
            logger.info("Registered rule: {}", rule.getRuleCode());
        }
    }

    /**
     * 启用或禁用优先级排序
     */
    public void setEnablePrioritySorting(boolean enable) {
        this.enablePrioritySorting = enable;
    }

    public boolean isEnablePrioritySorting() {
        return enablePrioritySorting;
    }

    /**
     * 执行规则流程
     *
     * @param flow           流程配置
     * @param initialContext 初始上下文
     * @return 执行结果
     */
    public ChannelRuleResult executeFlow(ChannelRuleFlow flow, ChannelRuleContext initialContext) {
        if (flow == null || flow.getSteps() == null || flow.getSteps().isEmpty()) {
            throw new ChannelRuleException("Flow or flow steps cannot be null or empty");
        }
        if (initialContext == null) {
            throw new ChannelRuleException("Initial context cannot be null");
        }

        logger.info("Executing flow: {} with {} steps", flow.getFlowCode(), flow.getSteps().size());

        ChannelRuleContext context = initialContext;

        // 排序步骤
        List<ChannelRuleFlow.FlowStep> steps = flow.getSteps();
        if (enablePrioritySorting) {
            steps = sortStepsByPriority(steps);
        }

        int skippedCount = 0;

        for (ChannelRuleFlow.FlowStep step : steps) {
            context.incrementDepth();

            // 检查执行深度
            if (context.getExecutionDepth() > flow.getMaxExecutionDepth()) {
                context.setSuccess(false);
                context.setErrorMessage("Maximum execution depth exceeded: " + flow.getMaxExecutionDepth());
                break;
            }

            // 检查超时
            if (context.getElapsedTime() > flow.getExecutionTimeoutMs()) {
                context.setStatus(ChannelExecutionStatus.TIMEOUT);
                context.setErrorMessage("Flow execution timed out after " + flow.getExecutionTimeoutMs() + "ms");
                break;
            }

            // 评估条件
            if (step.getCondition() != null && !step.getCondition().isEmpty()) {
                boolean conditionMet = expressionExecutor.evaluateCondition(
                        step.getCondition(), context.getVariables());
                if (!conditionMet) {
                    logger.info("Condition not met for step {}, skipping", step.getStep());
                    context.addTrace(step.getRuleCode(), "Step skipped (condition not met)", true);
                    skippedCount++;
                    continue;
                }
            }

            // 获取规则
            ChannelRule rule = ruleCache.get(step.getRuleCode());
            if (rule == null) {
                String errorMsg = "Rule not found: " + step.getRuleCode();
                logger.error(errorMsg);
                context.setSuccess(false);
                context.setErrorMessage(errorMsg);

                if ("abort".equals(step.getOnFailure())) {
                    break;
                }
                continue;
            }

            // 创建子规则上下文执行（共享变量）
            context.setCurrentRuleCode(step.getRuleCode());
            ChannelRuleResult stepResult = ruleEngine.executeRule(rule, context);

            if (!stepResult.isSuccess()) {
                logger.warn("Step {} failed: {}", step.getStep(), stepResult.getErrorMessage());

                if ("abort".equals(step.getOnFailure())) {
                    break;
                }
                // continue模式下重置成功状态以便后续步骤执行
                if ("continue".equals(step.getOnFailure())) {
                    context.setSuccess(true);
                    context.setErrorMessage(null);
                }
            } else {
                // 将结果存入上下文供后续步骤使用
                if (context.getResult() != null) {
                    context.setVariable(step.getRuleCode() + "_result", context.getResult());
                }

                if ("complete".equals(step.getOnSuccess())) {
                    logger.info("Flow completed at step {}", step.getStep());
                    break;
                }
            }
        }

        context.finishExecution();

        logger.info("Flow '{}' completed. Status: {}, Duration: {}ms",
                flow.getFlowCode(), context.getStatus(), context.getTotalExecutionTime());

        return ChannelRuleResult.fromContext(context);
    }

    /**
     * 根据优先级排序步骤
     * 融合FlowEngine的优先级排序逻辑，同时支持步骤自身priority和规则priority
     */
    private List<ChannelRuleFlow.FlowStep> sortStepsByPriority(List<ChannelRuleFlow.FlowStep> steps) {
        List<ChannelRuleFlow.FlowStep> sorted = new ArrayList<>(steps);
        sorted.sort((s1, s2) -> {
            // 首先使用步骤自身的优先级
            int p1 = s1.getPriority();
            int p2 = s2.getPriority();

            // 如果步骤优先级相同，使用规则的优先级
            if (p1 == p2) {
                ChannelRule r1 = ruleCache.get(s1.getRuleCode());
                ChannelRule r2 = ruleCache.get(s2.getRuleCode());
                p1 = (r1 != null && r1.getPriority() != null) ? r1.getPriority() : 0;
                p2 = (r2 != null && r2.getPriority() != null) ? r2.getPriority() : 0;
            }

            // 高优先级排在前面
            int cmp = Integer.compare(p2, p1);
            if (cmp != 0) return cmp;

            // 优先级相同保持原始顺序
            return Integer.compare(s1.getStep(), s2.getStep());
        });
        return sorted;
    }

    /**
     * 获取规则缓存
     */
    public Map<String, ChannelRule> getRuleCache() {
        return new HashMap<>(ruleCache);
    }
}
