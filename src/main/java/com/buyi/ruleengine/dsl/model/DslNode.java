package com.buyi.ruleengine.dsl.model;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * DSL规则节点 - 表示规则链中的一个节点
 * DSL Rule Node - Represents a single node in the rule chain
 * 
 * 节点可以是以下类型之一：
 * - RULE: 执行规则
 * - CONDITION: 条件判断
 * - FORK: 分支（并行执行多个分支）
 * - JOIN: 合并分支结果
 * - START: 开始节点
 * - END: 结束节点
 */
public class DslNode {
    
    /**
     * 节点类型枚举
     */
    public enum NodeType {
        START,      // 开始节点
        END,        // 结束节点
        RULE,       // 规则执行节点
        CONDITION,  // 条件判断节点
        FORK,       // 分支节点
        JOIN        // 合并节点
    }
    
    /**
     * 节点唯一标识
     */
    private String nodeId;
    
    /**
     * 节点名称
     */
    private String nodeName;
    
    /**
     * 节点类型
     */
    private NodeType nodeType;
    
    /**
     * 规则表达式（当nodeType为RULE时使用）
     */
    private String expression;
    
    /**
     * 条件表达式（当nodeType为CONDITION时使用）
     */
    private String condition;
    
    /**
     * 下一个节点ID（顺序执行）
     */
    private String nextNodeId;
    
    /**
     * 条件为真时的下一个节点ID
     */
    private String trueNodeId;
    
    /**
     * 条件为假时的下一个节点ID
     */
    private String falseNodeId;
    
    /**
     * 分支节点列表（当nodeType为FORK时使用）
     */
    private List<String> branchNodeIds;
    
    /**
     * 需要等待的分支节点（当nodeType为JOIN时使用）
     */
    private List<String> waitForNodeIds;
    
    /**
     * 节点参数
     */
    private Map<String, Object> params;
    
    /**
     * 输出变量名
     */
    private String outputVariable;
    
    /**
     * 描述
     */
    private String description;
    
    /**
     * 是否在失败时继续执行
     */
    private boolean continueOnError;
    
    /**
     * 超时时间（毫秒）
     */
    private long timeout;
    
    /**
     * 重试次数
     */
    private int retryCount;
    
    // Constructors
    public DslNode() {
        this.branchNodeIds = new ArrayList<>();
        this.waitForNodeIds = new ArrayList<>();
        this.params = new HashMap<>();
        this.timeout = 30000;
        this.retryCount = 0;
    }
    
    public DslNode(String nodeId, String nodeName, NodeType nodeType) {
        this();
        this.nodeId = nodeId;
        this.nodeName = nodeName;
        this.nodeType = nodeType;
    }
    
    // Getters and Setters
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
    
    public String getExpression() {
        return expression;
    }
    
    public void setExpression(String expression) {
        this.expression = expression;
    }
    
    public String getCondition() {
        return condition;
    }
    
    public void setCondition(String condition) {
        this.condition = condition;
    }
    
    public String getNextNodeId() {
        return nextNodeId;
    }
    
    public void setNextNodeId(String nextNodeId) {
        this.nextNodeId = nextNodeId;
    }
    
    public String getTrueNodeId() {
        return trueNodeId;
    }
    
    public void setTrueNodeId(String trueNodeId) {
        this.trueNodeId = trueNodeId;
    }
    
    public String getFalseNodeId() {
        return falseNodeId;
    }
    
    public void setFalseNodeId(String falseNodeId) {
        this.falseNodeId = falseNodeId;
    }
    
    public List<String> getBranchNodeIds() {
        return branchNodeIds;
    }
    
    public void setBranchNodeIds(List<String> branchNodeIds) {
        this.branchNodeIds = branchNodeIds;
    }
    
    public void addBranchNodeId(String nodeId) {
        if (this.branchNodeIds == null) {
            this.branchNodeIds = new ArrayList<>();
        }
        this.branchNodeIds.add(nodeId);
    }
    
    public List<String> getWaitForNodeIds() {
        return waitForNodeIds;
    }
    
    public void setWaitForNodeIds(List<String> waitForNodeIds) {
        this.waitForNodeIds = waitForNodeIds;
    }
    
    public void addWaitForNodeId(String nodeId) {
        if (this.waitForNodeIds == null) {
            this.waitForNodeIds = new ArrayList<>();
        }
        this.waitForNodeIds.add(nodeId);
    }
    
    public Map<String, Object> getParams() {
        return params;
    }
    
    public void setParams(Map<String, Object> params) {
        this.params = params;
    }
    
    public void setParam(String key, Object value) {
        if (this.params == null) {
            this.params = new HashMap<>();
        }
        this.params.put(key, value);
    }
    
    public String getOutputVariable() {
        return outputVariable;
    }
    
    public void setOutputVariable(String outputVariable) {
        this.outputVariable = outputVariable;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public boolean isContinueOnError() {
        return continueOnError;
    }
    
    public void setContinueOnError(boolean continueOnError) {
        this.continueOnError = continueOnError;
    }
    
    public long getTimeout() {
        return timeout;
    }
    
    public void setTimeout(long timeout) {
        this.timeout = timeout;
    }
    
    public int getRetryCount() {
        return retryCount;
    }
    
    public void setRetryCount(int retryCount) {
        this.retryCount = retryCount;
    }
    
    @Override
    public String toString() {
        return "DslNode{" +
                "nodeId='" + nodeId + '\'' +
                ", nodeName='" + nodeName + '\'' +
                ", nodeType=" + nodeType +
                ", expression='" + expression + '\'' +
                ", condition='" + condition + '\'' +
                ", nextNodeId='" + nextNodeId + '\'' +
                '}';
    }
}
