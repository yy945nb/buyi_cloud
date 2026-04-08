package com.buyi.channel.rule.exception;

import java.util.Collections;
import java.util.List;

/**
 * 渠道规则验证异常
 * Channel Rule Validation Exception
 */
public class ChannelRuleValidationException extends ChannelRuleException {

    private final List<String> validationErrors;

    public ChannelRuleValidationException(String message, List<String> errors) {
        super(message);
        this.validationErrors = errors != null ? Collections.unmodifiableList(errors) : Collections.emptyList();
    }

    public List<String> getValidationErrors() {
        return validationErrors;
    }
}
