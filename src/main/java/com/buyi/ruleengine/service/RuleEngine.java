package com.buyi.ruleengine.service;

import com.buyi.ruleengine.executor.RuleExecutor;
import com.buyi.ruleengine.model.RuleConfig;
import com.buyi.ruleengine.model.RuleContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.ArrayList;
import java.util.List;

/**
 * 规则引擎服务
 * Rule Engine Service
 */
public class RuleEngine {
    
    private static final Logger logger = LoggerFactory.getLogger(RuleEngine.class);
    private final List<RuleExecutor> executors;
    
    public RuleEngine() {
        this.executors = new ArrayList<>();
    }
    
    /**
     * 注册规则执行器
     * @param executor 规则执行器
     */
    public void registerExecutor(RuleExecutor executor) {
        if (executor != null) {
            this.executors.add(executor);
            logger.info("Registered rule executor: {}", executor.getClass().getSimpleName());
        }
    }
    
    /**
     * 执行单个规则
     * @param ruleConfig 规则配置
     * @param context 执行上下文
     * @return 执行结果上下文
     */
    public RuleContext executeRule(RuleConfig ruleConfig, RuleContext context) {
        if (ruleConfig == null) {
            throw new IllegalArgumentException("Rule config cannot be null");
        }
        
        if (context == null) {
            throw new IllegalArgumentException("Rule context cannot be null");
        }
        
        logger.info("Executing rule: {} (type: {})", ruleConfig.getRuleCode(), ruleConfig.getRuleType());
        
        // 查找合适的执行器
        RuleExecutor executor = findExecutor(ruleConfig);
        if (executor == null) {
            String errorMsg = "No executor found for rule type: " + ruleConfig.getRuleType();
            logger.error(errorMsg);
            context.setSuccess(false);
            context.setErrorMessage(errorMsg);
            return context;
        }
        
        // 执行规则
        return executor.execute(ruleConfig, context);
    }
    
    /**
     * 查找支持指定规则的执行器
     */
    private RuleExecutor findExecutor(RuleConfig ruleConfig) {
        for (RuleExecutor executor : executors) {
            if (executor.supports(ruleConfig)) {
                return executor;
            }
        }
        return null;
    }
    
    /**
     * 获取已注册的执行器列表
     */
    public List<RuleExecutor> getExecutors() {
        return new ArrayList<>(executors);
    }
}
