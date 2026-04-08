package com.buyi.channel.rule.exception;

/**
 * 渠道规则执行异常
 * Channel Rule Execution Exception
 */
public class ChannelRuleExecutionException extends ChannelRuleException {

    public ChannelRuleExecutionException(String ruleCode, String message) {
        super(ruleCode, message);
    }

    public ChannelRuleExecutionException(String ruleCode, String message, Throwable cause) {
        super(ruleCode, message, cause);
    }
}
