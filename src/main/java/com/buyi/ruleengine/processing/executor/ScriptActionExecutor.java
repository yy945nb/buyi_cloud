package com.buyi.ruleengine.processing.executor;

import com.buyi.ruleengine.processing.model.ProcessingAction;
import com.buyi.ruleengine.processing.model.ProcessingContext;
import com.buyi.ruleengine.processing.util.ProcessingUtils;
import org.apache.commons.jexl3.*;
import org.apache.commons.jexl3.introspection.JexlPermissions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.HashMap;
import java.util.Map;

/**
 * 脚本动作执行器 - 执行JEXL表达式
 * Script Action Executor - Executes JEXL expressions
 */
public class ScriptActionExecutor implements ActionExecutor {
    
    private static final Logger logger = LoggerFactory.getLogger(ScriptActionExecutor.class);
    private final JexlEngine jexlEngine;
    
    public ScriptActionExecutor() {
        // 创建命名空间映射，使用静态方法类
        // Create namespace map using class with static methods
        Map<String, Object> namespaces = new HashMap<>();
        namespaces.put("util", ProcessingUtils.class);  // 使用类以调用静态方法
        
        this.jexlEngine = new JexlBuilder()
                .cache(512)
                .strict(false)  // 允许未定义的变量
                .silent(false)
                .namespaces(namespaces)
                .permissions(JexlPermissions.UNRESTRICTED)  // 允许调用所有类的方法
                .create();
    }
    
    @Override
    public ActionResult execute(ProcessingAction action, ProcessingContext context) {
        long startTime = System.currentTimeMillis();
        
        try {
            logger.debug("Executing script action: {}", action.getActionId());
            
            // 获取表达式
            Map<String, Object> config = action.getConfig();
            String expression = (String) config.get("expression");
            
            if (expression == null || expression.isEmpty()) {
                return ActionResult.failure("Expression is null or empty");
            }
            
            // 创建JEXL上下文
            JexlContext jexlContext = new MapContext();
            
            // 添加所有上下文变量
            context.getAllVariables().forEach(jexlContext::set);
            
            // 编译并执行表达式
            Object result;
            
            // 检查是否是多行脚本
            if (expression.contains(";") && expression.contains("return")) {
                // 使用JexlScript执行多行脚本
                JexlScript script = jexlEngine.createScript(expression);
                result = script.execute(jexlContext);
            } else {
                // 使用JexlExpression执行简单表达式
                JexlExpression jexlExpression = jexlEngine.createExpression(expression);
                result = jexlExpression.evaluate(jexlContext);
            }
            
            logger.debug("Script action {} executed, result: {}", action.getActionId(), result);
            
            ActionResult actionResult = ActionResult.success(result);
            actionResult.setExecutionTime(System.currentTimeMillis() - startTime);
            return actionResult;
            
        } catch (Exception e) {
            logger.error("Failed to execute script action: {}", action.getActionId(), e);
            ActionResult actionResult = ActionResult.failure("Script execution failed: " + e.getMessage());
            actionResult.setExecutionTime(System.currentTimeMillis() - startTime);
            return actionResult;
        }
    }
    
    /**
     * 评估条件表达式
     * Evaluate condition expression
     * 
     * @param condition 条件表达式
     * @param context 执行上下文
     * @return 评估结果
     */
    public boolean evaluateCondition(String condition, ProcessingContext context) {
        try {
            JexlContext jexlContext = new MapContext();
            context.getAllVariables().forEach(jexlContext::set);
            
            JexlExpression expression = jexlEngine.createExpression(condition);
            Object result = expression.evaluate(jexlContext);
            
            if (result instanceof Boolean) {
                return (Boolean) result;
            }
            
            // 尝试将结果转换为布尔值
            if (result != null) {
                String strResult = result.toString().toLowerCase();
                return "true".equals(strResult) || "1".equals(strResult);
            }
            
            return false;
        } catch (Exception e) {
            logger.error("Failed to evaluate condition: {}", condition, e);
            return false;
        }
    }
    
    /**
     * 评估输出表达式
     * Evaluate output expression
     * 
     * @param outputExpression 输出表达式
     * @param result 执行结果
     * @param context 执行上下文
     * @return 提取的值
     */
    public Object evaluateOutputExpression(String outputExpression, Object result, ProcessingContext context) {
        try {
            JexlContext jexlContext = new MapContext();
            context.getAllVariables().forEach(jexlContext::set);
            jexlContext.set("result", result);
            
            JexlExpression expression = jexlEngine.createExpression(outputExpression);
            return expression.evaluate(jexlContext);
        } catch (Exception e) {
            logger.error("Failed to evaluate output expression: {}", outputExpression, e);
            return result;
        }
    }
    
    @Override
    public boolean supports(ProcessingAction.ActionType actionType) {
        return ProcessingAction.ActionType.SCRIPT == actionType;
    }
}
