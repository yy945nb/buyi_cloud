package com.buyi.ruleengine.service;

import com.buyi.ruleengine.executor.JavaExpressionExecutor;
import com.buyi.ruleengine.model.RuleConfig;
import com.buyi.ruleengine.model.RuleContext;
import com.buyi.ruleengine.model.RuleFlow;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.HashMap;
import java.util.Map;

/**
 * 流程引擎服务
 * Flow Engine Service
 */
public class FlowEngine {
    
    private static final Logger logger = LoggerFactory.getLogger(FlowEngine.class);
    private final RuleEngine ruleEngine;
    private final Map<String, RuleConfig> ruleConfigCache;
    
    public FlowEngine(RuleEngine ruleEngine) {
        this.ruleEngine = ruleEngine;
        this.ruleConfigCache = new HashMap<>();
    }
    
    /**
     * 注册规则配置到缓存
     * @param ruleConfig 规则配置
     */
    public void registerRule(RuleConfig ruleConfig) {
        if (ruleConfig != null && ruleConfig.getRuleCode() != null) {
            ruleConfigCache.put(ruleConfig.getRuleCode(), ruleConfig);
            logger.info("Registered rule: {}", ruleConfig.getRuleCode());
        }
    }
    
    /**
     * 执行规则流程
     * @param flow 流程配置
     * @param initialContext 初始上下文
     * @return 最终执行结果上下文
     */
    public RuleContext executeFlow(RuleFlow flow, RuleContext initialContext) {
        if (flow == null || flow.getSteps() == null || flow.getSteps().isEmpty()) {
            throw new IllegalArgumentException("Flow or flow steps cannot be null or empty");
        }
        
        logger.info("Executing flow: {} with {} steps", flow.getFlowCode(), flow.getSteps().size());
        
        RuleContext currentContext = initialContext;
        
        for (RuleFlow.FlowStep step : flow.getSteps()) {
            logger.info("Executing step {}: {}", step.getStep(), step.getRuleCode());
            
            // 检查执行条件
            if (step.getCondition() != null && !step.getCondition().isEmpty()) {
                if (!evaluateCondition(step.getCondition(), currentContext)) {
                    logger.info("Condition not met for step {}, skipping", step.getStep());
                    continue;
                }
            }
            
            // 获取规则配置
            RuleConfig ruleConfig = ruleConfigCache.get(step.getRuleCode());
            if (ruleConfig == null) {
                logger.error("Rule config not found: {}", step.getRuleCode());
                currentContext.setSuccess(false);
                currentContext.setErrorMessage("Rule config not found: " + step.getRuleCode());
                
                if ("abort".equals(step.getOnFailure())) {
                    logger.info("Aborting flow due to missing rule config");
                    break;
                }
                continue;
            }
            
            // 执行规则
            currentContext = ruleEngine.executeRule(ruleConfig, currentContext);
            
            // 处理执行结果
            if (!currentContext.isSuccess()) {
                logger.warn("Step {} failed: {}", step.getStep(), currentContext.getErrorMessage());
                
                if ("abort".equals(step.getOnFailure())) {
                    logger.info("Aborting flow due to step failure");
                    break;
                }
            } else {
                logger.info("Step {} completed successfully", step.getStep());
                
                // 将当前步骤的结果添加到上下文中，供后续步骤使用
                if (currentContext.getResult() != null) {
                    String resultKey = step.getRuleCode() + "_result";
                    currentContext.setInput(resultKey, currentContext.getResult());
                }
                
                if ("complete".equals(step.getOnSuccess())) {
                    logger.info("Flow completed at step {}", step.getStep());
                    break;
                }
            }
        }
        
        logger.info("Flow execution completed: {}", flow.getFlowCode());
        return currentContext;
    }
    
    /**
     * 评估条件表达式
     */
    private boolean evaluateCondition(String condition, RuleContext context) {
        try {
            JavaExpressionExecutor expressionExecutor = new JavaExpressionExecutor();
            RuleConfig conditionRule = new RuleConfig();
            conditionRule.setRuleCode("_condition_");
            conditionRule.setRuleName("Condition Check");
            conditionRule.setRuleType(com.buyi.ruleengine.enums.RuleType.JAVA_EXPR);
            conditionRule.setRuleContent(condition);
            
            RuleContext conditionContext = new RuleContext(context.getInputParams());
            conditionContext = expressionExecutor.execute(conditionRule, conditionContext);
            
            if (conditionContext.isSuccess() && conditionContext.getResult() != null) {
                return Boolean.TRUE.equals(conditionContext.getResult());
            }
        } catch (Exception e) {
            logger.error("Failed to evaluate condition: {}", condition, e);
        }
        return false;
    }
    
    /**
     * 获取规则配置缓存
     */
    public Map<String, RuleConfig> getRuleConfigCache() {
        return new HashMap<>(ruleConfigCache);
    }
}
