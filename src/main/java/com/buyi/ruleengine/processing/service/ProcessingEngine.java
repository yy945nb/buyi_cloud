package com.buyi.ruleengine.processing.service;

import com.buyi.ruleengine.processing.executor.ActionExecutor;
import com.buyi.ruleengine.processing.executor.ApiActionExecutor;
import com.buyi.ruleengine.processing.executor.ScriptActionExecutor;
import com.buyi.ruleengine.processing.model.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.*;
import java.util.stream.Collectors;

/**
 * 流程处理引擎 - 解析和执行processing.json定义的规则流程
 * Processing Engine - Parses and executes rule flows defined in processing.json
 * 
 * 核心功能：
 * 1. 加载和解析processing.json配置
 * 2. 按照entryPoint开始执行规则
 * 3. 执行规则中的每个动作
 * 4. 根据转换条件和优先级进行规则跳转
 * 5. 支持terminal规则作为终止节点
 * 6. 支持变量在规则间传递
 * 7. 支持执行深度和超时控制
 */
public class ProcessingEngine {
    
    private static final Logger logger = LoggerFactory.getLogger(ProcessingEngine.class);
    
    private final Map<ProcessingAction.ActionType, ActionExecutor> executors;
    private final ScriptActionExecutor scriptExecutor;
    private ProcessingConfig config;
    private Map<String, ProcessingRule> ruleMap;
    
    public ProcessingEngine() {
        this.executors = new HashMap<>();
        this.scriptExecutor = new ScriptActionExecutor();
        this.ruleMap = new HashMap<>();
        
        // 注册默认执行器
        registerExecutor(scriptExecutor);
        registerExecutor(new ApiActionExecutor());
    }
    
    /**
     * 注册动作执行器
     * Register action executor
     * 
     * @param executor 执行器
     */
    public void registerExecutor(ActionExecutor executor) {
        for (ProcessingAction.ActionType type : ProcessingAction.ActionType.values()) {
            if (executor.supports(type)) {
                executors.put(type, executor);
                logger.info("Registered executor for action type: {}", type);
            }
        }
    }
    
    /**
     * 加载配置
     * Load configuration
     * 
     * @param config 流程配置
     */
    public void loadConfig(ProcessingConfig config) {
        this.config = config;
        this.ruleMap = new HashMap<>();
        
        if (config.getRules() != null) {
            for (ProcessingRule rule : config.getRules()) {
                ruleMap.put(rule.getRuleId(), rule);
                logger.info("Loaded rule: {}", rule.getRuleId());
            }
        }
        
        logger.info("Configuration loaded with {} rules, entry point: {}", 
                ruleMap.size(), config.getEntryPoint());
    }
    
    /**
     * 执行流程
     * Execute the processing flow
     * 
     * @param initialVariables 初始变量
     * @return 执行上下文（包含结果和跟踪信息）
     */
    public ProcessingContext execute(Map<String, Object> initialVariables) {
        if (config == null) {
            throw new IllegalStateException("Configuration not loaded. Call loadConfig() first.");
        }
        
        ProcessingContext context = new ProcessingContext(initialVariables);
        
        String entryPoint = config.getEntryPoint();
        if (entryPoint == null || !ruleMap.containsKey(entryPoint)) {
            context.setSuccess(false);
            context.setErrorMessage("Entry point rule not found: " + entryPoint);
            return context;
        }
        
        ProcessingConfig.GlobalSettings settings = config.getGlobalSettings();
        int maxDepth = settings != null ? settings.getMaxExecutionDepth() : 50;
        long timeout = settings != null ? settings.getTimeout() : 30000;
        
        logger.info("Starting execution from entry point: {}, maxDepth: {}, timeout: {}ms", 
                entryPoint, maxDepth, timeout);
        
        try {
            executeRule(entryPoint, context, maxDepth, timeout);
        } catch (Exception e) {
            logger.error("Execution failed with exception", e);
            context.setSuccess(false);
            context.setErrorMessage("Execution failed: " + e.getMessage());
        } finally {
            context.finishExecution();
        }
        
        logger.info("Execution completed. Success: {}, Duration: {}ms, Trace count: {}", 
                context.isSuccess(), context.getTotalExecutionTime(), 
                context.getExecutionTraces().size());
        
        return context;
    }
    
    /**
     * 执行单个规则（使用迭代方式避免栈溢出）
     * Execute a single rule (using iteration to avoid stack overflow)
     */
    private void executeRule(String startRuleId, ProcessingContext context, int maxDepth, long timeout) {
        String currentRuleId = startRuleId;
        int ruleExecutionCount = 0;
        
        while (currentRuleId != null) {
            ruleExecutionCount++;
            
            // 检查执行深度（使用迭代计数器）
            if (ruleExecutionCount > maxDepth) {
                context.setSuccess(false);
                context.setErrorMessage("Maximum execution depth exceeded: " + maxDepth);
                logger.warn("Maximum execution depth exceeded at rule: {}", currentRuleId);
                return;
            }
            
            // 检查超时
            if (System.currentTimeMillis() - context.getStartTime() > timeout) {
                context.setSuccess(false);
                context.setErrorMessage("Execution timeout exceeded: " + timeout + "ms");
                logger.warn("Execution timeout exceeded for rule: {}", currentRuleId);
                return;
            }
            
            ProcessingRule rule = ruleMap.get(currentRuleId);
            if (rule == null) {
                context.setSuccess(false);
                context.setErrorMessage("Rule not found: " + currentRuleId);
                logger.error("Rule not found: {}", currentRuleId);
                return;
            }
            
            context.setCurrentRuleId(currentRuleId);
            context.setExecutionDepth(ruleExecutionCount);
            logger.info("Executing rule: {} - {}", currentRuleId, rule.getDescription());
            
            // 执行规则中的所有动作
            boolean shouldContinue = true;
            if (rule.getActions() != null) {
                for (ProcessingAction action : rule.getActions()) {
                    boolean actionSuccess = executeAction(action, context);
                    
                    if (!actionSuccess && !action.isContinueOnError()) {
                        logger.warn("Action {} failed and continueOnError is false, stopping execution", 
                                action.getActionId());
                        shouldContinue = false;
                        break;
                    }
                }
            }
            
            if (!shouldContinue) {
                return;
            }
            
            // 如果是终止节点，结束执行
            if (rule.isTerminal()) {
                logger.info("Reached terminal rule: {}", currentRuleId);
                return;
            }
            
            // 查找下一个规则
            String nextRule = findNextRule(rule, context);
            
            if (nextRule != null) {
                logger.info("Transitioning from {} to {}", currentRuleId, nextRule);
                currentRuleId = nextRule;
            } else {
                logger.info("No matching transition found for rule: {}", currentRuleId);
                currentRuleId = null;
            }
        }
    }
    
    /**
     * 执行单个动作
     * Execute a single action
     */
    private boolean executeAction(ProcessingAction action, ProcessingContext context) {
        logger.debug("Executing action: {} (type: {})", action.getActionId(), action.getType());
        
        ActionExecutor executor = executors.get(action.getType());
        if (executor == null) {
            logger.error("No executor found for action type: {}", action.getType());
            context.addTrace(context.getCurrentRuleId(), action.getActionId(), 
                    "No executor found for type: " + action.getType(), false);
            return false;
        }
        
        ActionExecutor.ActionResult result = executor.execute(action, context);
        
        if (result.isSuccess()) {
            Object outputValue = result.getResult();
            
            // 如果有输出表达式，应用它
            if (action.getOutputExpression() != null && !action.getOutputExpression().isEmpty()) {
                outputValue = scriptExecutor.evaluateOutputExpression(
                        action.getOutputExpression(), outputValue, context);
            }
            
            // 存储输出变量
            if (action.getOutputVariable() != null && !action.getOutputVariable().isEmpty()) {
                context.setVariable(action.getOutputVariable(), outputValue);
                logger.debug("Set variable '{}' = {}", action.getOutputVariable(), outputValue);
            }
            
            context.addTrace(context.getCurrentRuleId(), action.getActionId(), 
                    "Action executed successfully", true);
            return true;
        } else {
            logger.warn("Action {} failed: {}", action.getActionId(), result.getErrorMessage());
            context.addTrace(context.getCurrentRuleId(), action.getActionId(), 
                    result.getErrorMessage(), false);
            
            if (!action.isContinueOnError()) {
                context.setSuccess(false);
                context.setErrorMessage("Action " + action.getActionId() + " failed: " + result.getErrorMessage());
            }
            return false;
        }
    }
    
    /**
     * 查找下一个规则
     * Find the next rule based on transition conditions
     */
    private String findNextRule(ProcessingRule currentRule, ProcessingContext context) {
        List<ProcessingTransition> transitions = currentRule.getTransitions();
        
        if (transitions == null || transitions.isEmpty()) {
            return null;
        }
        
        // 按优先级排序（数字越小优先级越高）
        List<ProcessingTransition> sortedTransitions = transitions.stream()
                .sorted(Comparator.comparingInt(ProcessingTransition::getPriority))
                .collect(Collectors.toList());
        
        for (ProcessingTransition transition : sortedTransitions) {
            String condition = transition.getCondition();
            
            // 如果没有条件，默认通过
            if (condition == null || condition.isEmpty()) {
                return transition.getTargetRule();
            }
            
            // 评估条件
            boolean conditionMet = scriptExecutor.evaluateCondition(condition, context);
            
            if (conditionMet) {
                logger.debug("Transition condition '{}' evaluated to true, target: {}", 
                        condition, transition.getTargetRule());
                return transition.getTargetRule();
            }
        }
        
        return null;
    }
    
    /**
     * 获取当前加载的配置
     * Get currently loaded configuration
     * 
     * @return 流程配置
     */
    public ProcessingConfig getConfig() {
        return config;
    }
    
    /**
     * 获取规则映射
     * Get rule map
     * 
     * @return 规则映射
     */
    public Map<String, ProcessingRule> getRuleMap() {
        return new HashMap<>(ruleMap);
    }
    
    /**
     * 检查是否已加载配置
     * Check if configuration is loaded
     * 
     * @return 是否已加载
     */
    public boolean isConfigLoaded() {
        return config != null;
    }
    
    /**
     * 验证配置
     * Validate configuration
     * 
     * @return 验证结果消息列表（空表示验证通过）
     */
    public List<String> validateConfig() {
        List<String> errors = new ArrayList<>();
        
        if (config == null) {
            errors.add("Configuration is not loaded");
            return errors;
        }
        
        if (config.getEntryPoint() == null || config.getEntryPoint().isEmpty()) {
            errors.add("Entry point is not defined");
        } else if (!ruleMap.containsKey(config.getEntryPoint())) {
            errors.add("Entry point rule not found: " + config.getEntryPoint());
        }
        
        // 验证每个规则
        for (ProcessingRule rule : config.getRules()) {
            if (rule.getRuleId() == null || rule.getRuleId().isEmpty()) {
                errors.add("Rule with empty ruleId found");
            }
            
            // 验证转换目标
            if (rule.getTransitions() != null) {
                for (ProcessingTransition transition : rule.getTransitions()) {
                    if (!ruleMap.containsKey(transition.getTargetRule())) {
                        errors.add("Transition target rule not found: " + transition.getTargetRule() 
                                + " (in rule: " + rule.getRuleId() + ")");
                    }
                }
            }
        }
        
        return errors;
    }
}
