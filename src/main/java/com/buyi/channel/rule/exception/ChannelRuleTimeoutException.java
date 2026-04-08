package com.buyi.channel.rule.exception;

/**
 * 渠道规则超时异常
 * Channel Rule Timeout Exception
 */
public class ChannelRuleTimeoutException extends ChannelRuleExecutionException {

    private final long timeoutMs;

    public ChannelRuleTimeoutException(String ruleCode, long timeoutMs) {
        super(ruleCode, "Rule execution timed out after " + timeoutMs + "ms");
        this.timeoutMs = timeoutMs;
    }

    public long getTimeoutMs() {
        return timeoutMs;
    }
}
