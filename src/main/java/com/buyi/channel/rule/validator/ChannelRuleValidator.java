package com.buyi.channel.rule.validator;

import com.buyi.channel.rule.exception.ChannelRuleValidationException;
import com.buyi.channel.rule.model.ChannelRule;
import com.buyi.channel.rule.model.ChannelRuleFlow;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * 渠道规则验证器
 * Channel Rule Validator
 *
 * buyi_cloud中仅ProcessingEngine有简单的validateConfig方法，
 * 其他引擎（RuleEngine, FlowEngine, DslRuleChainEngine）缺少配置验证。
 * 这里提供统一的、可扩展的验证框架。
 */
public class ChannelRuleValidator {

    /**
     * 验证单条规则配置
     *
     * @param rule 规则配置
     * @return 验证错误列表（空表示验证通过）
     */
    public List<String> validateRule(ChannelRule rule) {
        List<String> errors = new ArrayList<>();

        if (rule == null) {
            errors.add("Rule cannot be null");
            return errors;
        }

        if (rule.getRuleCode() == null || rule.getRuleCode().trim().isEmpty()) {
            errors.add("Rule code cannot be empty");
        }

        if (rule.getRuleType() == null) {
            errors.add("Rule type cannot be null for rule: " + rule.getRuleCode());
        }

        if (rule.getRuleContent() == null || rule.getRuleContent().trim().isEmpty()) {
            errors.add("Rule content cannot be empty for rule: " + rule.getRuleCode());
        }

        if (rule.getMaxRetries() < 0) {
            errors.add("Max retries cannot be negative for rule: " + rule.getRuleCode());
        }

        if (rule.getTimeoutMs() < 0) {
            errors.add("Timeout cannot be negative for rule: " + rule.getRuleCode());
        }

        if (rule.getRetryDelayMs() < 0) {
            errors.add("Retry delay cannot be negative for rule: " + rule.getRuleCode());
        }

        return errors;
    }

    /**
     * 验证规则流程配置
     *
     * @param flow      流程配置
     * @param ruleCache 可用规则缓存
     * @return 验证错误列表
     */
    public List<String> validateFlow(ChannelRuleFlow flow, Map<String, ChannelRule> ruleCache) {
        List<String> errors = new ArrayList<>();

        if (flow == null) {
            errors.add("Flow cannot be null");
            return errors;
        }

        if (flow.getFlowCode() == null || flow.getFlowCode().trim().isEmpty()) {
            errors.add("Flow code cannot be empty");
        }

        if (flow.getSteps() == null || flow.getSteps().isEmpty()) {
            errors.add("Flow must have at least one step");
            return errors;
        }

        if (flow.getMaxExecutionDepth() <= 0) {
            errors.add("Max execution depth must be positive");
        }

        if (flow.getExecutionTimeoutMs() <= 0) {
            errors.add("Execution timeout must be positive");
        }

        // 检查步骤
        Set<Integer> stepNumbers = new HashSet<>();
        Set<String> stepRuleCodes = new HashSet<>();

        for (ChannelRuleFlow.FlowStep step : flow.getSteps()) {
            if (step.getRuleCode() == null || step.getRuleCode().trim().isEmpty()) {
                errors.add("Step " + step.getStep() + " has empty rule code");
                continue;
            }

            // 检查步骤编号唯一性
            if (!stepNumbers.add(step.getStep())) {
                errors.add("Duplicate step number: " + step.getStep());
            }

            // 检查引用的规则是否存在
            if (ruleCache != null && !ruleCache.containsKey(step.getRuleCode())) {
                errors.add("Rule not found for step " + step.getStep() + ": " + step.getRuleCode());
            }

            // 检查onSuccess值
            String onSuccess = step.getOnSuccess();
            if (onSuccess != null && !onSuccess.isEmpty()
                    && !"next".equals(onSuccess) && !"complete".equals(onSuccess)) {
                errors.add("Invalid onSuccess value '" + onSuccess + "' for step " + step.getStep()
                        + " (expected 'next' or 'complete')");
            }

            // 检查onFailure值
            String onFailure = step.getOnFailure();
            if (onFailure != null && !onFailure.isEmpty()
                    && !"abort".equals(onFailure) && !"continue".equals(onFailure)) {
                errors.add("Invalid onFailure value '" + onFailure + "' for step " + step.getStep()
                        + " (expected 'abort' or 'continue')");
            }
        }

        return errors;
    }

    /**
     * 验证并抛出异常
     *
     * @param rule 规则配置
     * @throws ChannelRuleValidationException 验证失败时抛出
     */
    public void validateAndThrow(ChannelRule rule) {
        List<String> errors = validateRule(rule);
        if (!errors.isEmpty()) {
            throw new ChannelRuleValidationException(
                    "Rule validation failed for: " + (rule != null ? rule.getRuleCode() : "null"),
                    errors);
        }
    }

    /**
     * 验证流程并抛出异常
     *
     * @param flow      流程配置
     * @param ruleCache 可用规则缓存
     * @throws ChannelRuleValidationException 验证失败时抛出
     */
    public void validateFlowAndThrow(ChannelRuleFlow flow, Map<String, ChannelRule> ruleCache) {
        List<String> errors = validateFlow(flow, ruleCache);
        if (!errors.isEmpty()) {
            throw new ChannelRuleValidationException(
                    "Flow validation failed for: " + (flow != null ? flow.getFlowCode() : "null"),
                    errors);
        }
    }
}
