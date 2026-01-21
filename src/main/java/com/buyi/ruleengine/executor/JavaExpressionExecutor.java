package com.buyi.ruleengine.executor;

import com.buyi.ruleengine.enums.RuleType;
import com.buyi.ruleengine.model.RuleConfig;
import com.buyi.ruleengine.model.RuleContext;
import org.apache.commons.jexl3.JexlBuilder;
import org.apache.commons.jexl3.JexlContext;
import org.apache.commons.jexl3.JexlEngine;
import org.apache.commons.jexl3.JexlExpression;
import org.apache.commons.jexl3.MapContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Java表达式执行器
 * Java Expression Executor using JEXL
 */
public class JavaExpressionExecutor implements RuleExecutor {
    
    private static final Logger logger = LoggerFactory.getLogger(JavaExpressionExecutor.class);
    private final JexlEngine jexlEngine;
    
    public JavaExpressionExecutor() {
        this.jexlEngine = new JexlBuilder()
                .cache(512)
                .strict(true)
                .silent(false)
                .create();
    }
    
    @Override
    public RuleContext execute(RuleConfig ruleConfig, RuleContext context) {
        long startTime = System.currentTimeMillis();
        
        try {
            logger.info("Executing Java expression rule: {}", ruleConfig.getRuleCode());
            
            // 创建JEXL上下文并加载输入参数
            JexlContext jexlContext = new MapContext();
            if (context.getInputParams() != null) {
                context.getInputParams().forEach(jexlContext::set);
            }
            
            // 编译并执行表达式
            JexlExpression expression = jexlEngine.createExpression(ruleConfig.getRuleContent());
            Object result = expression.evaluate(jexlContext);
            
            // 设置结果
            context.setResult(result);
            context.setSuccess(true);
            
            logger.info("Java expression rule executed successfully. Result: {}", result);
            
        } catch (Exception e) {
            logger.error("Failed to execute Java expression rule: {}", ruleConfig.getRuleCode(), e);
            context.setSuccess(false);
            context.setErrorMessage("Java expression execution failed: " + e.getMessage());
        } finally {
            context.setExecutionTime(System.currentTimeMillis() - startTime);
        }
        
        return context;
    }
    
    @Override
    public boolean supports(RuleConfig ruleConfig) {
        return ruleConfig != null && RuleType.JAVA_EXPR.equals(ruleConfig.getRuleType());
    }
}
