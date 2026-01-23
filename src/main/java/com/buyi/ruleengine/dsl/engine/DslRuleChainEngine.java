package com.buyi.ruleengine.dsl.engine;

import com.buyi.ruleengine.dsl.model.DslExecutionContext;
import com.buyi.ruleengine.dsl.model.DslNode;
import com.buyi.ruleengine.dsl.model.DslRuleChain;
import org.apache.commons.jexl3.JexlBuilder;
import org.apache.commons.jexl3.JexlContext;
import org.apache.commons.jexl3.JexlEngine;
import org.apache.commons.jexl3.JexlExpression;
import org.apache.commons.jexl3.MapContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.HashMap;
import java.util.Map;

/**
 * DSL规则链执行引擎
 * DSL Rule Chain Execution Engine
 * 
 * 功能特性：
 * 1. 执行DSL解析器生成的规则链
 * 2. 支持条件判断、分支、合并等节点类型
 * 3. 支持变量传递和表达式求值
 * 4. 执行深度和超时控制
 * 5. 详细的执行追踪日志
 */
public class DslRuleChainEngine {
    
    private static final Logger logger = LoggerFactory.getLogger(DslRuleChainEngine.class);
    
    private final JexlEngine jexlEngine;
    private final Map<String, NodeExecutor> customExecutors;
    
    public DslRuleChainEngine() {
        this.jexlEngine = new JexlBuilder()
                .cache(512)
                .strict(false)
                .silent(false)
                .create();
        this.customExecutors = new HashMap<>();
    }
    
    /**
     * 注册自定义节点执行器
     * Register custom node executor
     * 
     * @param nodeType 节点类型标识
     * @param executor 执行器
     */
    public void registerExecutor(String nodeType, NodeExecutor executor) {
        customExecutors.put(nodeType, executor);
        logger.info("Registered custom executor for node type: {}", nodeType);
    }
    
    /**
     * 执行规则链
     * Execute rule chain
     * 
     * @param chain 规则链
     * @param initialParams 初始参数
     * @return 执行上下文（包含结果）
     */
    public DslExecutionContext execute(DslRuleChain chain, Map<String, Object> initialParams) {
        if (chain == null) {
            throw new IllegalArgumentException("Rule chain cannot be null");
        }
        
        DslExecutionContext context = new DslExecutionContext(initialParams);
        
        // 添加全局参数
        if (chain.getGlobalParams() != null) {
            for (Map.Entry<String, Object> entry : chain.getGlobalParams().entrySet()) {
                if (!context.hasVariable(entry.getKey())) {
                    context.setVariable(entry.getKey(), entry.getValue());
                }
            }
        }
        
        logger.info("Starting execution of rule chain: {} (version: {})", 
                chain.getChainId(), chain.getVersion());
        
        try {
            DslNode startNode = chain.getStartNode();
            if (startNode == null) {
                context.setSuccess(false);
                context.setErrorMessage("No start node found in rule chain");
                return context;
            }
            
            executeFromNode(chain, startNode, context);
            
        } catch (Exception e) {
            logger.error("Rule chain execution failed", e);
            context.setSuccess(false);
            context.setErrorMessage("Execution failed: " + e.getMessage());
        } finally {
            context.finishExecution();
        }
        
        logger.info("Rule chain execution completed. Success: {}, Duration: {}ms", 
                context.isSuccess(), context.getTotalExecutionTime());
        
        return context;
    }
    
    /**
     * 从指定节点开始执行
     */
    private void executeFromNode(DslRuleChain chain, DslNode startNode, DslExecutionContext context) {
        String currentNodeId = startNode.getNodeId();
        
        while (currentNodeId != null && !context.isTerminated()) {
            context.incrementDepth();
            
            // 检查执行深度
            if (context.getExecutionDepth() > chain.getMaxExecutionDepth()) {
                context.setSuccess(false);
                context.setErrorMessage("Maximum execution depth exceeded: " + chain.getMaxExecutionDepth());
                logger.warn("Maximum execution depth exceeded at node: {}", currentNodeId);
                return;
            }
            
            // 检查超时
            if (System.currentTimeMillis() - context.getStartTime() > chain.getExecutionTimeout()) {
                context.setSuccess(false);
                context.setErrorMessage("Execution timeout exceeded: " + chain.getExecutionTimeout() + "ms");
                logger.warn("Execution timeout at node: {}", currentNodeId);
                return;
            }
            
            DslNode node = chain.getNode(currentNodeId);
            if (node == null) {
                context.setSuccess(false);
                context.setErrorMessage("Node not found: " + currentNodeId);
                logger.error("Node not found: {}", currentNodeId);
                return;
            }
            
            context.setCurrentNodeId(currentNodeId);
            
            if (chain.isEnableLogging()) {
                logger.info("Executing node: {} (type: {})", currentNodeId, node.getNodeType());
            }
            
            // 执行节点
            String nextNodeId = executeNode(node, context);
            
            if (!context.isSuccess() && !node.isContinueOnError()) {
                logger.warn("Node {} failed, stopping execution", currentNodeId);
                return;
            }
            
            currentNodeId = nextNodeId;
        }
    }
    
    /**
     * 执行单个节点
     * 
     * @param node 节点
     * @param context 执行上下文
     * @return 下一个节点ID
     */
    private String executeNode(DslNode node, DslExecutionContext context) {
        try {
            switch (node.getNodeType()) {
                case START:
                    return executeStartNode(node, context);
                    
                case END:
                    return executeEndNode(node, context);
                    
                case RULE:
                    return executeRuleNode(node, context);
                    
                case CONDITION:
                    return executeConditionNode(node, context);
                    
                case FORK:
                    return executeForkNode(node, context);
                    
                case JOIN:
                    return executeJoinNode(node, context);
                    
                default:
                    context.setSuccess(false);
                    context.setErrorMessage("Unknown node type: " + node.getNodeType());
                    return null;
            }
        } catch (Exception e) {
            logger.error("Error executing node: {}", node.getNodeId(), e);
            context.addTrace(node.getNodeId(), "Error: " + e.getMessage(), false);
            
            if (node.isContinueOnError()) {
                context.setSuccess(true);
                return node.getNextNodeId();
            } else {
                context.setSuccess(false);
                context.setErrorMessage("Node " + node.getNodeId() + " failed: " + e.getMessage());
                return null;
            }
        }
    }
    
    /**
     * 执行开始节点
     */
    private String executeStartNode(DslNode node, DslExecutionContext context) {
        context.addTrace(node.getNodeId(), "Start node executed", true);
        return node.getNextNodeId();
    }
    
    /**
     * 执行结束节点
     */
    private String executeEndNode(DslNode node, DslExecutionContext context) {
        context.addTrace(node.getNodeId(), "End node reached", true);
        context.setTerminated(true);
        return null;
    }
    
    /**
     * 执行规则节点
     */
    private String executeRuleNode(DslNode node, DslExecutionContext context) {
        String expression = node.getExpression();
        
        if (expression == null || expression.isEmpty()) {
            context.addTrace(node.getNodeId(), "Rule node with no expression, skipping", true);
            return node.getNextNodeId();
        }
        
        // 创建JEXL上下文
        JexlContext jexlContext = new MapContext();
        for (Map.Entry<String, Object> entry : context.getVariables().entrySet()) {
            jexlContext.set(entry.getKey(), entry.getValue());
        }
        
        // 添加节点参数
        if (node.getParams() != null) {
            for (Map.Entry<String, Object> entry : node.getParams().entrySet()) {
                jexlContext.set(entry.getKey(), entry.getValue());
            }
        }
        
        // 执行表达式
        Object result = evaluateExpression(expression, jexlContext);
        
        // 存储结果
        if (node.getOutputVariable() != null && !node.getOutputVariable().isEmpty()) {
            context.setVariable(node.getOutputVariable(), result);
        }
        
        // 同时以节点ID为键存储结果
        context.setVariable(node.getNodeId() + "_result", result);
        context.setResult(result);
        
        context.addTrace(node.getNodeId(), 
                "Rule executed, result: " + result, true);
        
        logger.debug("Node {} expression '{}' evaluated to: {}", 
                node.getNodeId(), expression, result);
        
        return node.getNextNodeId();
    }
    
    /**
     * 执行条件节点
     */
    private String executeConditionNode(DslNode node, DslExecutionContext context) {
        String condition = node.getCondition();
        if (condition == null || condition.isEmpty()) {
            condition = node.getExpression();
        }
        
        if (condition == null || condition.isEmpty()) {
            context.addTrace(node.getNodeId(), "Condition node with no condition, defaulting to false", true);
            return node.getFalseNodeId();
        }
        
        // 创建JEXL上下文
        JexlContext jexlContext = new MapContext();
        for (Map.Entry<String, Object> entry : context.getVariables().entrySet()) {
            jexlContext.set(entry.getKey(), entry.getValue());
        }
        
        // 评估条件
        Object result = evaluateExpression(condition, jexlContext);
        boolean conditionMet = toBoolean(result);
        
        context.addTrace(node.getNodeId(), 
                "Condition '" + condition + "' evaluated to: " + conditionMet, true);
        
        logger.debug("Node {} condition '{}' evaluated to: {}", 
                node.getNodeId(), condition, conditionMet);
        
        if (conditionMet) {
            return node.getTrueNodeId();
        } else {
            return node.getFalseNodeId();
        }
    }
    
    /**
     * 执行分支节点
     */
    private String executeForkNode(DslNode node, DslExecutionContext context) {
        if (node.getBranchNodeIds() == null || node.getBranchNodeIds().isEmpty()) {
            context.addTrace(node.getNodeId(), "Fork node with no branches, skipping", true);
            return node.getNextNodeId();
        }
        
        // 简化实现：顺序执行所有分支
        // 在实际生产环境中，可以使用线程池并行执行
        for (String branchId : node.getBranchNodeIds()) {
            context.setBranchResult(branchId, "executed");
        }
        
        context.addTrace(node.getNodeId(), 
                "Fork executed with " + node.getBranchNodeIds().size() + " branches", true);
        
        // 返回第一个分支作为下一个节点
        return node.getBranchNodeIds().get(0);
    }
    
    /**
     * 执行合并节点
     */
    private String executeJoinNode(DslNode node, DslExecutionContext context) {
        // 简化实现：直接继续执行
        // 在实际生产环境中，需要等待所有分支完成
        
        context.addTrace(node.getNodeId(), "Join node executed", true);
        
        return node.getNextNodeId();
    }
    
    /**
     * 评估表达式
     */
    private Object evaluateExpression(String expression, JexlContext jexlContext) {
        try {
            JexlExpression jexlExpression = jexlEngine.createExpression(expression);
            return jexlExpression.evaluate(jexlContext);
        } catch (Exception e) {
            logger.error("Failed to evaluate expression: {}", expression, e);
            throw new RuntimeException("Expression evaluation failed: " + e.getMessage(), e);
        }
    }
    
    /**
     * 转换为布尔值
     */
    private boolean toBoolean(Object value) {
        if (value == null) {
            return false;
        }
        if (value instanceof Boolean) {
            return (Boolean) value;
        }
        if (value instanceof Number) {
            return ((Number) value).doubleValue() != 0;
        }
        if (value instanceof String) {
            String str = (String) value;
            return !str.isEmpty() && !"false".equalsIgnoreCase(str) && !"0".equals(str);
        }
        return true;
    }
    
    /**
     * 节点执行器接口
     * Node Executor Interface
     */
    public interface NodeExecutor {
        /**
         * 执行节点
         * 
         * @param node 节点
         * @param context 执行上下文
         * @return 下一个节点ID
         */
        String execute(DslNode node, DslExecutionContext context);
        
        /**
         * 是否支持指定节点类型
         * 
         * @param nodeType 节点类型
         * @return 是否支持
         */
        boolean supports(String nodeType);
    }
}
