package com.buyi.ruleengine.executor;

import com.buyi.ruleengine.model.RuleConfig;
import com.buyi.ruleengine.model.RuleContext;

/**
 * 规则执行器接口
 * Rule Executor Interface
 */
public interface RuleExecutor {
    
    /**
     * 执行规则
     * @param ruleConfig 规则配置
     * @param context 执行上下文
     * @return 执行结果上下文
     */
    RuleContext execute(RuleConfig ruleConfig, RuleContext context);
    
    /**
     * 判断是否支持该规则类型
     * @param ruleConfig 规则配置
     * @return 是否支持
     */
    boolean supports(RuleConfig ruleConfig);
}
