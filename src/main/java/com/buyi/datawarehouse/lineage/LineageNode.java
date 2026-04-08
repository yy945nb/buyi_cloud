package com.buyi.datawarehouse.lineage;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * 数据血缘节点
 * Data Lineage Node
 *
 * 代表数据血缘图中的一个节点（数据表/文件/流主题），
 * 支持追踪每一行数据从Bronze到Gold的完整血缘链路。
 */
public class LineageNode implements Serializable {
    private static final long serialVersionUID = 1L;

    /** 节点唯一标识 */
    private String nodeId;

    /** 节点名称（如：bronze.orders, silver.orders, gold.daily_revenue） */
    private String nodeName;

    /** 节点类型（SOURCE_TABLE / BRONZE / SILVER / GOLD / STREAM） */
    private NodeType nodeType;

    /** 数据层级（bronze / silver / gold / source） */
    private String layer;

    /** 所属系统/业务域 */
    private String sourceSystem;

    /** 节点创建时间 */
    private LocalDateTime createdAt;

    /** 最近刷新时间 */
    private LocalDateTime lastRefreshedAt;

    /** 上游节点列表（直接依赖的输入节点） */
    private List<String> upstreamNodeIds;

    /** 下游节点列表（直接依赖此节点的输出节点） */
    private List<String> downstreamNodeIds;

    /** 该节点关联的转换逻辑描述 */
    private String transformationDescription;

    /** 数据归属方 */
    private String dataOwner;

    /** SLA承诺（新鲜度）描述 */
    private String slaDescription;

    /**
     * 节点类型枚举
     */
    public enum NodeType {
        /** 原始数据源（如：API、文件、数据库） */
        SOURCE,
        /** Bronze层：原始摄取 */
        BRONZE,
        /** Silver层：清洗统一 */
        SILVER,
        /** Gold层：业务聚合 */
        GOLD,
        /** 实时流 */
        STREAM
    }

    public LineageNode() {
        this.upstreamNodeIds = new ArrayList<>();
        this.downstreamNodeIds = new ArrayList<>();
        this.createdAt = LocalDateTime.now();
    }

    public LineageNode(String nodeId, String nodeName, NodeType nodeType, String layer) {
        this();
        this.nodeId = nodeId;
        this.nodeName = nodeName;
        this.nodeType = nodeType;
        this.layer = layer;
    }

    /**
     * 添加上游节点
     */
    public void addUpstream(String upstreamNodeId) {
        if (!upstreamNodeIds.contains(upstreamNodeId)) {
            upstreamNodeIds.add(upstreamNodeId);
        }
    }

    /**
     * 添加下游节点
     */
    public void addDownstream(String downstreamNodeId) {
        if (!downstreamNodeIds.contains(downstreamNodeId)) {
            downstreamNodeIds.add(downstreamNodeId);
        }
    }

    public String getNodeId() {
        return nodeId;
    }

    public void setNodeId(String nodeId) {
        this.nodeId = nodeId;
    }

    public String getNodeName() {
        return nodeName;
    }

    public void setNodeName(String nodeName) {
        this.nodeName = nodeName;
    }

    public NodeType getNodeType() {
        return nodeType;
    }

    public void setNodeType(NodeType nodeType) {
        this.nodeType = nodeType;
    }

    public String getLayer() {
        return layer;
    }

    public void setLayer(String layer) {
        this.layer = layer;
    }

    public String getSourceSystem() {
        return sourceSystem;
    }

    public void setSourceSystem(String sourceSystem) {
        this.sourceSystem = sourceSystem;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getLastRefreshedAt() {
        return lastRefreshedAt;
    }

    public void setLastRefreshedAt(LocalDateTime lastRefreshedAt) {
        this.lastRefreshedAt = lastRefreshedAt;
    }

    public List<String> getUpstreamNodeIds() {
        return upstreamNodeIds;
    }

    public void setUpstreamNodeIds(List<String> upstreamNodeIds) {
        this.upstreamNodeIds = upstreamNodeIds;
    }

    public List<String> getDownstreamNodeIds() {
        return downstreamNodeIds;
    }

    public void setDownstreamNodeIds(List<String> downstreamNodeIds) {
        this.downstreamNodeIds = downstreamNodeIds;
    }

    public String getTransformationDescription() {
        return transformationDescription;
    }

    public void setTransformationDescription(String transformationDescription) {
        this.transformationDescription = transformationDescription;
    }

    public String getDataOwner() {
        return dataOwner;
    }

    public void setDataOwner(String dataOwner) {
        this.dataOwner = dataOwner;
    }

    public String getSlaDescription() {
        return slaDescription;
    }

    public void setSlaDescription(String slaDescription) {
        this.slaDescription = slaDescription;
    }

    @Override
    public String toString() {
        return "LineageNode{" +
                "nodeId='" + nodeId + '\'' +
                ", nodeName='" + nodeName + '\'' +
                ", nodeType=" + nodeType +
                ", layer='" + layer + '\'' +
                ", upstreamCount=" + (upstreamNodeIds != null ? upstreamNodeIds.size() : 0) +
                ", downstreamCount=" + (downstreamNodeIds != null ? downstreamNodeIds.size() : 0) +
                '}';
    }
}
