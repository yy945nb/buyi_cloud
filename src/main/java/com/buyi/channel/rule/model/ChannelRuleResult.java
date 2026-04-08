package com.buyi.channel.rule.model;

import com.buyi.channel.rule.enums.ChannelExecutionStatus;

import java.util.Collections;
import java.util.List;

/**
 * 渠道规则执行结果
 * Channel Rule Execution Result
 *
 * buyi_cloud中执行结果分散在RuleContext中，没有独立的结果对象。
 * 这里将结果抽取为独立的不可变对象，包含更丰富的执行信息。
 */
public class ChannelRuleResult {

    private final Object result;
    private final ChannelExecutionStatus status;
    private final String errorMessage;
    private final long executionTimeMs;
    private final int totalSteps;
    private final int successSteps;
    private final int failedSteps;
    private final int skippedSteps;
    private final int totalRetries;
    private final List<ChannelRuleContext.ExecutionTrace> traces;

    private ChannelRuleResult(Builder builder) {
        this.result = builder.result;
        this.status = builder.status;
        this.errorMessage = builder.errorMessage;
        this.executionTimeMs = builder.executionTimeMs;
        this.totalSteps = builder.totalSteps;
        this.successSteps = builder.successSteps;
        this.failedSteps = builder.failedSteps;
        this.skippedSteps = builder.skippedSteps;
        this.totalRetries = builder.totalRetries;
        this.traces = builder.traces != null ?
                Collections.unmodifiableList(builder.traces) : Collections.emptyList();
    }

    public static ChannelRuleResult fromContext(ChannelRuleContext context) {
        int success = 0;
        int failed = 0;
        for (ChannelRuleContext.ExecutionTrace trace : context.getTraces()) {
            if (trace.isSuccess()) {
                success++;
            } else {
                failed++;
            }
        }

        return new Builder()
                .result(context.getResult())
                .status(context.getStatus())
                .errorMessage(context.getErrorMessage())
                .executionTimeMs(context.getTotalExecutionTime())
                .totalSteps(success + failed)
                .successSteps(success)
                .failedSteps(failed)
                .totalRetries(context.getRetryCount())
                .traces(context.getTraces())
                .build();
    }

    // Getters
    public Object getResult() {
        return result;
    }

    public ChannelExecutionStatus getStatus() {
        return status;
    }

    public boolean isSuccess() {
        return status == ChannelExecutionStatus.SUCCESS;
    }

    public String getErrorMessage() {
        return errorMessage;
    }

    public long getExecutionTimeMs() {
        return executionTimeMs;
    }

    public int getTotalSteps() {
        return totalSteps;
    }

    public int getSuccessSteps() {
        return successSteps;
    }

    public int getFailedSteps() {
        return failedSteps;
    }

    public int getSkippedSteps() {
        return skippedSteps;
    }

    public int getTotalRetries() {
        return totalRetries;
    }

    public List<ChannelRuleContext.ExecutionTrace> getTraces() {
        return traces;
    }

    @Override
    public String toString() {
        return "ChannelRuleResult{" +
                "status=" + status +
                ", result=" + result +
                ", executionTimeMs=" + executionTimeMs +
                ", totalSteps=" + totalSteps +
                ", successSteps=" + successSteps +
                ", failedSteps=" + failedSteps +
                '}';
    }

    /**
     * Builder pattern for ChannelRuleResult
     */
    public static class Builder {
        private Object result;
        private ChannelExecutionStatus status = ChannelExecutionStatus.SUCCESS;
        private String errorMessage;
        private long executionTimeMs;
        private int totalSteps;
        private int successSteps;
        private int failedSteps;
        private int skippedSteps;
        private int totalRetries;
        private List<ChannelRuleContext.ExecutionTrace> traces;

        public Builder result(Object result) {
            this.result = result;
            return this;
        }

        public Builder status(ChannelExecutionStatus status) {
            this.status = status;
            return this;
        }

        public Builder errorMessage(String errorMessage) {
            this.errorMessage = errorMessage;
            return this;
        }

        public Builder executionTimeMs(long executionTimeMs) {
            this.executionTimeMs = executionTimeMs;
            return this;
        }

        public Builder totalSteps(int totalSteps) {
            this.totalSteps = totalSteps;
            return this;
        }

        public Builder successSteps(int successSteps) {
            this.successSteps = successSteps;
            return this;
        }

        public Builder failedSteps(int failedSteps) {
            this.failedSteps = failedSteps;
            return this;
        }

        public Builder skippedSteps(int skippedSteps) {
            this.skippedSteps = skippedSteps;
            return this;
        }

        public Builder totalRetries(int totalRetries) {
            this.totalRetries = totalRetries;
            return this;
        }

        public Builder traces(List<ChannelRuleContext.ExecutionTrace> traces) {
            this.traces = traces;
            return this;
        }

        public ChannelRuleResult build() {
            return new ChannelRuleResult(this);
        }
    }
}
