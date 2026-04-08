package com.buyi.channel.rule.model;

import com.buyi.channel.rule.enums.ChannelExecutionStatus;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;

/**
 * 渠道规则执行上下文
 * Channel Rule Execution Context
 *
 * 合并优化说明：
 * - 融合RuleContext的inputParams/result/success/executionTime
 * - 融合DslExecutionContext的线程安全设计（ConcurrentHashMap + CopyOnWriteArrayList）
 * - 融合ProcessingContext的executionTraces和variable存储
 * - 新增executionStatus枚举（比简单boolean更精细）
 * - 新增stepResults用于保存每一步的执行结果
 * - 新增retryCount追踪重试次数
 */
public class ChannelRuleContext {

    private final Map<String, Object> variables;
    private final List<ExecutionTrace> traces;
    private final Map<String, Object> stepResults;

    private volatile Object result;
    private volatile ChannelExecutionStatus status;
    private volatile String errorMessage;
    private volatile String currentRuleCode;
    private volatile int executionDepth;
    private volatile int retryCount;
    private final long startTime;
    private volatile long totalExecutionTime;

    public ChannelRuleContext() {
        this.variables = new ConcurrentHashMap<>();
        this.traces = new CopyOnWriteArrayList<>();
        this.stepResults = new ConcurrentHashMap<>();
        this.status = ChannelExecutionStatus.SUCCESS;
        this.executionDepth = 0;
        this.retryCount = 0;
        this.startTime = System.currentTimeMillis();
    }

    public ChannelRuleContext(Map<String, Object> inputParams) {
        this();
        if (inputParams != null) {
            this.variables.putAll(inputParams);
        }
    }

    // Variable operations
    public void setVariable(String key, Object value) {
        variables.put(key, value);
    }

    public Object getVariable(String key) {
        return variables.get(key);
    }

    public boolean hasVariable(String key) {
        return variables.containsKey(key);
    }

    public Map<String, Object> getVariables() {
        return variables;
    }

    // Step result operations
    public void setStepResult(String ruleCode, Object result) {
        stepResults.put(ruleCode, result);
    }

    public Object getStepResult(String ruleCode) {
        return stepResults.get(ruleCode);
    }

    public Map<String, Object> getStepResults() {
        return Collections.unmodifiableMap(stepResults);
    }

    // Trace operations
    public void addTrace(String ruleCode, String message, boolean success) {
        ExecutionTrace trace = new ExecutionTrace(ruleCode, message, success);
        traces.add(trace);
    }

    public void addTrace(String ruleCode, String message, boolean success, long durationMs) {
        ExecutionTrace trace = new ExecutionTrace(ruleCode, message, success, durationMs);
        traces.add(trace);
    }

    public List<ExecutionTrace> getTraces() {
        return Collections.unmodifiableList(traces);
    }

    // Status operations
    public boolean isSuccess() {
        return status == ChannelExecutionStatus.SUCCESS;
    }

    public void setSuccess(boolean success) {
        this.status = success ? ChannelExecutionStatus.SUCCESS : ChannelExecutionStatus.FAILURE;
    }

    public ChannelExecutionStatus getStatus() {
        return status;
    }

    public void setStatus(ChannelExecutionStatus status) {
        this.status = status;
    }

    // Depth
    public void incrementDepth() {
        this.executionDepth++;
    }

    public int getExecutionDepth() {
        return executionDepth;
    }

    // Retry
    public void incrementRetryCount() {
        this.retryCount++;
    }

    public int getRetryCount() {
        return retryCount;
    }

    public void resetRetryCount() {
        this.retryCount = 0;
    }

    // Timing
    public long getStartTime() {
        return startTime;
    }

    public long getElapsedTime() {
        return System.currentTimeMillis() - startTime;
    }

    public void finishExecution() {
        this.totalExecutionTime = System.currentTimeMillis() - startTime;
    }

    public long getTotalExecutionTime() {
        return totalExecutionTime;
    }

    // Result
    public Object getResult() {
        return result;
    }

    public void setResult(Object result) {
        this.result = result;
    }

    // Error
    public String getErrorMessage() {
        return errorMessage;
    }

    public void setErrorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
        if (errorMessage != null) {
            this.status = ChannelExecutionStatus.FAILURE;
        }
    }

    // Current rule
    public String getCurrentRuleCode() {
        return currentRuleCode;
    }

    public void setCurrentRuleCode(String currentRuleCode) {
        this.currentRuleCode = currentRuleCode;
    }

    /**
     * 执行追踪记录
     */
    public static class ExecutionTrace {
        private final String ruleCode;
        private final String message;
        private final boolean success;
        private final long timestamp;
        private final long durationMs;

        public ExecutionTrace(String ruleCode, String message, boolean success) {
            this(ruleCode, message, success, -1);
        }

        public ExecutionTrace(String ruleCode, String message, boolean success, long durationMs) {
            this.ruleCode = ruleCode;
            this.message = message;
            this.success = success;
            this.timestamp = System.currentTimeMillis();
            this.durationMs = durationMs;
        }

        public String getRuleCode() {
            return ruleCode;
        }

        public String getMessage() {
            return message;
        }

        public boolean isSuccess() {
            return success;
        }

        public long getTimestamp() {
            return timestamp;
        }

        public long getDurationMs() {
            return durationMs;
        }

        @Override
        public String toString() {
            return "ExecutionTrace{ruleCode='" + ruleCode + "', success=" + success +
                    ", durationMs=" + durationMs + ", message='" + message + "'}";
        }
    }

    @Override
    public String toString() {
        return "ChannelRuleContext{" +
                "status=" + status +
                ", currentRuleCode='" + currentRuleCode + '\'' +
                ", executionDepth=" + executionDepth +
                ", retryCount=" + retryCount +
                ", result=" + result +
                ", errorMessage='" + errorMessage + '\'' +
                '}';
    }
}
