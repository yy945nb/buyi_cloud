package com.buyi.channel.rule.metrics;

import java.util.Collections;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

/**
 * 渠道规则执行指标收集器
 * Channel Rule Execution Metrics Collector
 *
 * buyi_cloud完全缺少执行指标收集能力。
 * 这里提供规则级别的执行统计：执行次数、成功/失败次数、总耗时、平均耗时、重试次数。
 */
public class ChannelRuleMetrics {

    private final Map<String, RuleMetric> metricsMap;

    public ChannelRuleMetrics() {
        this.metricsMap = new ConcurrentHashMap<>();
    }

    /**
     * 记录规则执行
     *
     * @param ruleCode    规则代码
     * @param success     是否成功
     * @param durationMs  执行时间（毫秒）
     * @param retryCount  重试次数
     */
    public void recordExecution(String ruleCode, boolean success, long durationMs, int retryCount) {
        RuleMetric metric = metricsMap.computeIfAbsent(ruleCode, k -> new RuleMetric());
        metric.totalExecutions.incrementAndGet();
        metric.totalDurationMs.addAndGet(durationMs);
        metric.totalRetries.addAndGet(retryCount);

        if (success) {
            metric.successCount.incrementAndGet();
        } else {
            metric.failureCount.incrementAndGet();
        }
    }

    /**
     * 获取指定规则的指标快照
     *
     * @param ruleCode 规则代码
     * @return 指标快照
     */
    public MetricSnapshot getMetricSnapshot(String ruleCode) {
        RuleMetric metric = metricsMap.get(ruleCode);
        if (metric == null) {
            return new MetricSnapshot(0, 0, 0, 0, 0, 0);
        }
        long total = metric.totalExecutions.get();
        long duration = metric.totalDurationMs.get();
        return new MetricSnapshot(
                total,
                metric.successCount.get(),
                metric.failureCount.get(),
                duration,
                total > 0 ? duration / total : 0,
                metric.totalRetries.get()
        );
    }

    /**
     * 获取所有规则的指标
     */
    public Map<String, RuleMetric> getAllMetrics() {
        return Collections.unmodifiableMap(metricsMap);
    }

    /**
     * 重置所有指标
     */
    public void reset() {
        metricsMap.clear();
    }

    /**
     * 规则级别的指标（线程安全）
     */
    public static class RuleMetric {
        final AtomicLong totalExecutions = new AtomicLong(0);
        final AtomicLong successCount = new AtomicLong(0);
        final AtomicLong failureCount = new AtomicLong(0);
        final AtomicLong totalDurationMs = new AtomicLong(0);
        final AtomicLong totalRetries = new AtomicLong(0);

        public long getTotalExecutions() {
            return totalExecutions.get();
        }

        public long getSuccessCount() {
            return successCount.get();
        }

        public long getFailureCount() {
            return failureCount.get();
        }

        public long getTotalDurationMs() {
            return totalDurationMs.get();
        }

        public long getTotalRetries() {
            return totalRetries.get();
        }

        public double getAverageDurationMs() {
            long total = totalExecutions.get();
            return total > 0 ? (double) totalDurationMs.get() / total : 0;
        }

        public double getSuccessRate() {
            long total = totalExecutions.get();
            return total > 0 ? (double) successCount.get() / total * 100 : 0;
        }
    }

    /**
     * 指标快照（不可变）
     */
    public static class MetricSnapshot {
        private final long totalExecutions;
        private final long successCount;
        private final long failureCount;
        private final long totalDurationMs;
        private final long averageDurationMs;
        private final long totalRetries;

        public MetricSnapshot(long totalExecutions, long successCount, long failureCount,
                              long totalDurationMs, long averageDurationMs, long totalRetries) {
            this.totalExecutions = totalExecutions;
            this.successCount = successCount;
            this.failureCount = failureCount;
            this.totalDurationMs = totalDurationMs;
            this.averageDurationMs = averageDurationMs;
            this.totalRetries = totalRetries;
        }

        public long getTotalExecutions() {
            return totalExecutions;
        }

        public long getSuccessCount() {
            return successCount;
        }

        public long getFailureCount() {
            return failureCount;
        }

        public long getTotalDurationMs() {
            return totalDurationMs;
        }

        public long getAverageDurationMs() {
            return averageDurationMs;
        }

        public long getTotalRetries() {
            return totalRetries;
        }

        @Override
        public String toString() {
            return "MetricSnapshot{" +
                    "totalExecutions=" + totalExecutions +
                    ", successCount=" + successCount +
                    ", failureCount=" + failureCount +
                    ", avgDurationMs=" + averageDurationMs +
                    ", totalRetries=" + totalRetries +
                    '}';
        }
    }
}
