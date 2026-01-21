package com.buyi.ruleengine.processing;

import com.buyi.ruleengine.processing.model.ProcessingConfig;
import com.buyi.ruleengine.processing.model.ProcessingContext;
import com.buyi.ruleengine.processing.service.ProcessingConfigLoader;
import com.buyi.ruleengine.processing.service.ProcessingEngine;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 流程引擎示例 - 演示如何使用ProcessingEngine执行processing.json配置
 * Processing Engine Demo - Demonstrates how to use ProcessingEngine to execute processing.json configuration
 */
public class ProcessingEngineDemo {
    
    public static void main(String[] args) {
        System.out.println("=== Buyi Processing Engine Demo ===\n");
        
        // 创建配置加载器和引擎
        ProcessingConfigLoader loader = new ProcessingConfigLoader();
        ProcessingEngine engine = new ProcessingEngine();
        
        try {
            // 从资源文件加载配置
            System.out.println("Loading configuration from rule/processing.json...");
            ProcessingConfig config = loader.loadFromResource("rule/processing.json");
            System.out.println("Configuration loaded: " + config);
            System.out.println("Entry point: " + config.getEntryPoint());
            System.out.println("Rules count: " + config.getRules().size());
            System.out.println();
            
            // 加载配置到引擎
            engine.loadConfig(config);
            
            // 验证配置
            List<String> validationErrors = engine.validateConfig();
            if (!validationErrors.isEmpty()) {
                System.out.println("Configuration validation errors:");
                validationErrors.forEach(e -> System.out.println("  - " + e));
                return;
            }
            System.out.println("Configuration validation passed.\n");
            
            // 示例1：已验证用户的订单
            System.out.println("=== Example 1: Verified User Order ===");
            runExample(engine, createVerifiedUserOrder());
            
            // 示例2：未验证用户
            System.out.println("\n=== Example 2: Unverified User ===");
            runExample(engine, createUnverifiedUserOrder());
            
            // 示例3：高价值订单
            System.out.println("\n=== Example 3: High Value Order ===");
            runExample(engine, createHighValueOrder());
            
        } catch (Exception e) {
            System.err.println("Demo failed: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    private static void runExample(ProcessingEngine engine, Map<String, Object> variables) {
        System.out.println("Input variables: " + variables);
        System.out.println();
        
        ProcessingContext result = engine.execute(variables);
        
        System.out.println("Execution Result:");
        System.out.println("  Success: " + result.isSuccess());
        System.out.println("  Duration: " + result.getTotalExecutionTime() + "ms");
        
        if (!result.isSuccess()) {
            System.out.println("  Error: " + result.getErrorMessage());
        }
        
        System.out.println("\nOutput Variables:");
        result.getAllVariables().forEach((key, value) -> {
            // 只显示非输入的变量
            if (!variables.containsKey(key)) {
                System.out.println("  " + key + " = " + value);
            }
        });
        
        System.out.println("\nExecution Trace:");
        result.getExecutionTraces().forEach(trace -> 
            System.out.println("  [" + (trace.isSuccess() ? "OK" : "FAIL") + "] " 
                    + trace.getRuleId() + "." + trace.getActionId()));
    }
    
    private static Map<String, Object> createVerifiedUserOrder() {
        Map<String, Object> vars = new HashMap<>();
        vars.put("userId", "1");
        vars.put("verified", true);
        vars.put("items", createItemsList(
                createItem("Item A", 50.0, 2),
                createItem("Item B", 30.0, 3)
        ));
        return vars;
    }
    
    private static Map<String, Object> createUnverifiedUserOrder() {
        Map<String, Object> vars = new HashMap<>();
        vars.put("userId", "2");
        vars.put("verified", false);
        vars.put("items", createItemsList(
                createItem("Item X", 100.0, 1)
        ));
        return vars;
    }
    
    private static Map<String, Object> createHighValueOrder() {
        Map<String, Object> vars = new HashMap<>();
        vars.put("userId", "3");
        vars.put("verified", true);
        vars.put("items", createItemsList(
                createItem("Premium Item", 500.0, 3),
                createItem("Luxury Item", 300.0, 2)
        ));
        return vars;
    }
    
    private static List<Map<String, Object>> createItemsList(Map<String, Object>... items) {
        List<Map<String, Object>> list = new java.util.ArrayList<>();
        for (Map<String, Object> item : items) {
            list.add(item);
        }
        return list;
    }
    
    private static Map<String, Object> createItem(String name, double price, int quantity) {
        Map<String, Object> item = new HashMap<>();
        item.put("name", name);
        item.put("price", price);
        item.put("quantity", quantity);
        return item;
    }
}
