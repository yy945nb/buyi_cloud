package com.buyi.channel.rule.exception;

/**
 * 渠道规则引擎基础异常
 * Channel Rule Engine Base Exception
 *
 * buyi_cloud中缺少统一的异常体系，各引擎直接抛出RuntimeException或设置errorMessage。
 * 这里建立了类型化的异常层次结构，便于调用方精确捕获和处理不同类型的错误。
 */
public class ChannelRuleException extends RuntimeException {

    private final String ruleCode;

    public ChannelRuleException(String message) {
        super(message);
        this.ruleCode = null;
    }

    public ChannelRuleException(String ruleCode, String message) {
        super(message);
        this.ruleCode = ruleCode;
    }

    public ChannelRuleException(String ruleCode, String message, Throwable cause) {
        super(message, cause);
        this.ruleCode = ruleCode;
    }

    public String getRuleCode() {
        return ruleCode;
    }
}
