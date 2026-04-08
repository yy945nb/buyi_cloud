package com.buyi.channel.rule.executor;

import com.buyi.channel.rule.enums.ChannelRuleType;
import com.buyi.channel.rule.model.ChannelRule;
import com.buyi.channel.rule.model.ChannelRuleContext;

/**
 * 渠道规则执行器接口
 * Channel Rule Executor Interface
 *
 * 合并优化说明：
 * - 基于buyi_cloud RuleExecutor接口的supports/execute模式
 * - 增加getSupportedType()方法返回明确的类型，用于HashMap注册（O(1)查找）
 *   而非buyi_cloud的线性遍历supports()匹配
 */
public interface ChannelRuleExecutor {

    /**
     * 执行规则
     *
     * @param rule    规则配置
     * @param context 执行上下文
     */
    void execute(ChannelRule rule, ChannelRuleContext context);

    /**
     * 获取支持的规则类型
     * 用于HashMap注册，实现O(1)查找
     *
     * @return 支持的规则类型
     */
    ChannelRuleType getSupportedType();

    /**
     * 判断是否支持该规则
     * 默认根据类型匹配，子类可以覆盖实现更细粒度的判断
     *
     * @param rule 规则配置
     * @return 是否支持
     */
    default boolean supports(ChannelRule rule) {
        return rule != null && getSupportedType().equals(rule.getRuleType());
    }
}
