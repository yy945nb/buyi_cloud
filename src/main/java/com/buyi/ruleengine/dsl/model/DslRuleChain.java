package com.buyi.ruleengine.dsl.model;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * DSL规则链 - 表示完整的规则链定义
 * DSL Rule Chain - Represents a complete rule chain definition
 * 
 * 规则链包含：
 * - 基本信息（ID、名称、版本、描述）
 * - 节点列表
 * - 全局参数
 * - 执行配置
 */
public class DslRuleChain {
    
    /**
     * 规则链唯一标识
     */
    private String chainId;
    
    /**
     * 规则链名称
     */
    private String chainName;
    
    /**
     * 版本号
     */
    private String version;
    
    /**
     * 描述
     */
    private String description;
    
    /**
     * 节点映射（nodeId -> DslNode）
     */
    private Map<String, DslNode> nodes;
    
    /**
     * 节点列表（保持顺序）
     */
    private List<DslNode> nodeList;
    
    /**
     * 开始节点ID
     */
    private String startNodeId;
    
    /**
     * 全局参数
     */
    private Map<String, Object> globalParams;
    
    /**
     * 最大执行深度（防止无限循环）
     */
    private int maxExecutionDepth;
    
    /**
     * 执行超时时间（毫秒）
     */
    private long executionTimeout;
    
    /**
     * 是否启用日志
     */
    private boolean enableLogging;
    
    /**
     * 状态（0-禁用，1-启用）
     */
    private int status;
    
    // Constructors
    public DslRuleChain() {
        this.nodes = new HashMap<>();
        this.nodeList = new ArrayList<>();
        this.globalParams = new HashMap<>();
        this.maxExecutionDepth = 100;
        this.executionTimeout = 60000;
        this.enableLogging = true;
        this.status = 1;
        this.version = "1.0.0";
    }
    
    public DslRuleChain(String chainId, String chainName) {
        this();
        this.chainId = chainId;
        this.chainName = chainName;
    }
    
    /**
     * 添加节点
     * @param node 节点
     */
    public void addNode(DslNode node) {
        if (node != null && node.getNodeId() != null) {
            nodes.put(node.getNodeId(), node);
            nodeList.add(node);
            
            // 自动设置开始节点
            if (node.getNodeType() == DslNode.NodeType.START && startNodeId == null) {
                startNodeId = node.getNodeId();
            }
        }
    }
    
    /**
     * 获取节点
     * @param nodeId 节点ID
     * @return 节点
     */
    public DslNode getNode(String nodeId) {
        return nodes.get(nodeId);
    }
    
    /**
     * 检查节点是否存在
     * @param nodeId 节点ID
     * @return 是否存在
     */
    public boolean hasNode(String nodeId) {
        return nodes.containsKey(nodeId);
    }
    
    /**
     * 获取开始节点
     * @return 开始节点
     */
    public DslNode getStartNode() {
        if (startNodeId != null) {
            return nodes.get(startNodeId);
        }
        // 查找START类型的节点
        for (DslNode node : nodeList) {
            if (node.getNodeType() == DslNode.NodeType.START) {
                return node;
            }
        }
        // 返回第一个节点
        return nodeList.isEmpty() ? null : nodeList.get(0);
    }
    
    // Getters and Setters
    public String getChainId() {
        return chainId;
    }
    
    public void setChainId(String chainId) {
        this.chainId = chainId;
    }
    
    public String getChainName() {
        return chainName;
    }
    
    public void setChainName(String chainName) {
        this.chainName = chainName;
    }
    
    public String getVersion() {
        return version;
    }
    
    public void setVersion(String version) {
        this.version = version;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public Map<String, DslNode> getNodes() {
        return nodes;
    }
    
    public void setNodes(Map<String, DslNode> nodes) {
        this.nodes = nodes;
    }
    
    public List<DslNode> getNodeList() {
        return nodeList;
    }
    
    public void setNodeList(List<DslNode> nodeList) {
        this.nodeList = nodeList;
        // 重建映射
        this.nodes.clear();
        for (DslNode node : nodeList) {
            this.nodes.put(node.getNodeId(), node);
        }
    }
    
    public String getStartNodeId() {
        return startNodeId;
    }
    
    public void setStartNodeId(String startNodeId) {
        this.startNodeId = startNodeId;
    }
    
    public Map<String, Object> getGlobalParams() {
        return globalParams;
    }
    
    public void setGlobalParams(Map<String, Object> globalParams) {
        this.globalParams = globalParams;
    }
    
    public void setGlobalParam(String key, Object value) {
        if (this.globalParams == null) {
            this.globalParams = new HashMap<>();
        }
        this.globalParams.put(key, value);
    }
    
    public int getMaxExecutionDepth() {
        return maxExecutionDepth;
    }
    
    public void setMaxExecutionDepth(int maxExecutionDepth) {
        this.maxExecutionDepth = maxExecutionDepth;
    }
    
    public long getExecutionTimeout() {
        return executionTimeout;
    }
    
    public void setExecutionTimeout(long executionTimeout) {
        this.executionTimeout = executionTimeout;
    }
    
    public boolean isEnableLogging() {
        return enableLogging;
    }
    
    public void setEnableLogging(boolean enableLogging) {
        this.enableLogging = enableLogging;
    }
    
    public int getStatus() {
        return status;
    }
    
    public void setStatus(int status) {
        this.status = status;
    }
    
    @Override
    public String toString() {
        return "DslRuleChain{" +
                "chainId='" + chainId + '\'' +
                ", chainName='" + chainName + '\'' +
                ", version='" + version + '\'' +
                ", nodeCount=" + nodeList.size() +
                ", startNodeId='" + startNodeId + '\'' +
                ", maxExecutionDepth=" + maxExecutionDepth +
                ", executionTimeout=" + executionTimeout +
                '}';
    }
}
