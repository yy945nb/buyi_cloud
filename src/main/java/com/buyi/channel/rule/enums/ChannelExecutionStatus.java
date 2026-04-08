package com.buyi.channel.rule.enums;

/**
 * 渠道规则执行状态枚举
 * Channel Rule Execution Status
 *
 * 相比buyi_cloud的ExecutionStatus（仅SUCCESS/FAILURE），
 * 增加了SKIPPED、TIMEOUT、RETRYING等中间状态，
 * 更精细地反映规则执行生命周期。
 */
public enum ChannelExecutionStatus {

    /**
     * 执行成功
     */
    SUCCESS(1, "执行成功"),

    /**
     * 执行失败
     */
    FAILURE(0, "执行失败"),

    /**
     * 被跳过（条件不满足）
     */
    SKIPPED(2, "被跳过"),

    /**
     * 执行超时
     */
    TIMEOUT(3, "执行超时"),

    /**
     * 重试中
     */
    RETRYING(4, "重试中");

    private final int code;
    private final String description;

    ChannelExecutionStatus(int code, String description) {
        this.code = code;
        this.description = description;
    }

    public int getCode() {
        return code;
    }

    public String getDescription() {
        return description;
    }
}
