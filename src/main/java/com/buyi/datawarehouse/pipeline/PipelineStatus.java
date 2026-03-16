package com.buyi.datawarehouse.pipeline;

/**
 * 管线执行状态枚举
 * Pipeline Execution Status
 */
public enum PipelineStatus {

    /** 执行中 */
    RUNNING,

    /** 执行成功（所有行均成功处理，SLA达标） */
    SUCCESS,

    /** 执行失败（管线中断，需要告警和人工干预） */
    FAILED,

    /** 部分成功（有失败行但管线未中断，需要人工评估） */
    PARTIAL,

    /** 等待执行（已排队，尚未开始） */
    PENDING,

    /** 已跳过（幂等重跑检测到数据已存在，无需处理） */
    SKIPPED
}
