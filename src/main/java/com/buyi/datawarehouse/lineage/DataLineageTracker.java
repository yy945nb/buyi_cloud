package com.buyi.datawarehouse.lineage;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Queue;

/**
 * 数据血缘追踪器
 * Data Lineage Tracker
 *
 * 构建并维护数据血缘图，支持：
 * - 注册Bronze/Silver/Gold层节点
 * - 追踪每一行数据从源头到Gold层的完整链路
 * - 查询某张表的所有上游依赖（影响分析）
 * - 查询某张表的所有下游消费方（影响范围分析）
 */
public class DataLineageTracker {
    private static final Logger logger = LoggerFactory.getLogger(DataLineageTracker.class);

    /** 所有血缘节点的注册表（nodeId -> LineageNode） */
    private final Map<String, LineageNode> nodeRegistry;

    public DataLineageTracker() {
        this.nodeRegistry = new HashMap<>();
    }

    /**
     * 注册一个血缘节点
     *
     * @param node 血缘节点
     */
    public void registerNode(LineageNode node) {
        if (node == null || node.getNodeId() == null) {
            throw new IllegalArgumentException("血缘节点及其ID不能为空");
        }
        nodeRegistry.put(node.getNodeId(), node);
        logger.info("Registered lineage node: {} ({})", node.getNodeName(), node.getNodeType());
    }

    /**
     * 建立两个节点之间的血缘关系（上游 -> 下游）
     *
     * @param upstreamNodeId   上游节点ID
     * @param downstreamNodeId 下游节点ID
     */
    public void addLineage(String upstreamNodeId, String downstreamNodeId) {
        LineageNode upstream = nodeRegistry.get(upstreamNodeId);
        LineageNode downstream = nodeRegistry.get(downstreamNodeId);

        if (upstream == null) {
            throw new IllegalArgumentException("上游节点未注册：" + upstreamNodeId);
        }
        if (downstream == null) {
            throw new IllegalArgumentException("下游节点未注册：" + downstreamNodeId);
        }

        upstream.addDownstream(downstreamNodeId);
        downstream.addUpstream(upstreamNodeId);
        logger.info("Added lineage: {} -> {}", upstream.getNodeName(), downstream.getNodeName());
    }

    /**
     * 获取指定节点的所有上游节点（包含间接上游，BFS遍历）
     *
     * @param nodeId 目标节点ID
     * @return 所有上游节点列表（按BFS顺序）
     */
    public List<LineageNode> getAllUpstream(String nodeId) {
        LineageNode startNode = nodeRegistry.get(nodeId);
        if (startNode == null) {
            logger.warn("Node not found: {}", nodeId);
            return Collections.emptyList();
        }

        List<LineageNode> result = new ArrayList<>();
        Queue<String> queue = new LinkedList<>();
        Map<String, Boolean> visited = new HashMap<>();

        queue.addAll(startNode.getUpstreamNodeIds());
        for (String id : startNode.getUpstreamNodeIds()) {
            visited.put(id, true);
        }

        while (!queue.isEmpty()) {
            String currentId = queue.poll();
            LineageNode current = nodeRegistry.get(currentId);
            if (current != null) {
                result.add(current);
                for (String upId : current.getUpstreamNodeIds()) {
                    if (!visited.containsKey(upId)) {
                        visited.put(upId, true);
                        queue.add(upId);
                    }
                }
            }
        }
        return result;
    }

    /**
     * 获取指定节点的所有下游节点（包含间接下游，BFS遍历）
     * 用于影响范围分析：当某节点发生变更时，评估受影响的下游消费方
     *
     * @param nodeId 目标节点ID
     * @return 所有下游节点列表（按BFS顺序）
     */
    public List<LineageNode> getAllDownstream(String nodeId) {
        LineageNode startNode = nodeRegistry.get(nodeId);
        if (startNode == null) {
            logger.warn("Node not found: {}", nodeId);
            return Collections.emptyList();
        }

        List<LineageNode> result = new ArrayList<>();
        Queue<String> queue = new LinkedList<>();
        Map<String, Boolean> visited = new HashMap<>();

        queue.addAll(startNode.getDownstreamNodeIds());
        for (String id : startNode.getDownstreamNodeIds()) {
            visited.put(id, true);
        }

        while (!queue.isEmpty()) {
            String currentId = queue.poll();
            LineageNode current = nodeRegistry.get(currentId);
            if (current != null) {
                result.add(current);
                for (String downId : current.getDownstreamNodeIds()) {
                    if (!visited.containsKey(downId)) {
                        visited.put(downId, true);
                        queue.add(downId);
                    }
                }
            }
        }
        return result;
    }

    /**
     * 获取节点
     *
     * @param nodeId 节点ID
     * @return 节点，不存在则返回null
     */
    public LineageNode getNode(String nodeId) {
        return nodeRegistry.get(nodeId);
    }

    /**
     * 更新节点的最近刷新时间
     *
     * @param nodeId 节点ID
     */
    public void markRefreshed(String nodeId) {
        LineageNode node = nodeRegistry.get(nodeId);
        if (node != null) {
            node.setLastRefreshedAt(LocalDateTime.now());
            logger.debug("Marked node {} as refreshed at {}", nodeId, node.getLastRefreshedAt());
        }
    }

    /**
     * 获取所有已注册节点数量
     */
    public int getNodeCount() {
        return nodeRegistry.size();
    }

    /**
     * 打印血缘图摘要（调试用）
     */
    public void printLineageSummary() {
        logger.info("=== 数据血缘图摘要 ===");
        logger.info("已注册节点数：{}", nodeRegistry.size());
        for (LineageNode node : nodeRegistry.values()) {
            logger.info("  节点: {} [{}] 上游:{} 下游:{}",
                    node.getNodeName(),
                    node.getNodeType(),
                    node.getUpstreamNodeIds().size(),
                    node.getDownstreamNodeIds().size());
        }
    }
}
