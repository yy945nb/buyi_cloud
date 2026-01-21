package com.buyi.ruleengine.processing;

import com.buyi.ruleengine.processing.model.*;
import com.buyi.ruleengine.processing.service.ProcessingConfigLoader;
import com.buyi.ruleengine.processing.service.ProcessingEngine;
import org.junit.Before;
import org.junit.Test;

import java.util.*;

import static org.junit.Assert.*;

/**
 * 流程引擎单元测试
 * Processing Engine Unit Tests
 */
public class ProcessingEngineTest {
    
    private ProcessingEngine engine;
    private ProcessingConfigLoader loader;
    
    @Before
    public void setUp() {
        engine = new ProcessingEngine();
        loader = new ProcessingConfigLoader();
    }
    
    @Test
    public void testLoadConfigFromString() {
        // 测试加载简单配置
        String json = createSimpleConfig();
        
        ProcessingConfig config = loader.loadFromString(json);
        
        assertNotNull(config);
        assertEquals("1.0", config.getVersion());
        assertEquals("start-rule", config.getEntryPoint());
        assertEquals(2, config.getRules().size());
    }
    
    @Test
    public void testExecuteSimpleScript() {
        // 测试执行简单脚本
        String json = createSimpleScriptConfig();
        
        ProcessingConfig config = loader.loadFromString(json);
        engine.loadConfig(config);
        
        Map<String, Object> variables = new HashMap<>();
        variables.put("a", 10);
        variables.put("b", 20);
        
        ProcessingContext result = engine.execute(variables);
        
        assertTrue(result.isSuccess());
        assertEquals(30, result.getVariable("sum"));
    }
    
    @Test
    public void testConditionalTransition() {
        // 测试条件转换
        String json = createConditionalConfig();
        
        ProcessingConfig config = loader.loadFromString(json);
        engine.loadConfig(config);
        
        // 测试amount > 100时走high分支
        Map<String, Object> highVariables = new HashMap<>();
        highVariables.put("amount", 150);
        
        ProcessingContext highResult = engine.execute(highVariables);
        assertTrue(highResult.isSuccess());
        assertEquals("HIGH", highResult.getVariable("level"));
        
        // 测试amount <= 100时走low分支
        Map<String, Object> lowVariables = new HashMap<>();
        lowVariables.put("amount", 50);
        
        ProcessingContext lowResult = engine.execute(lowVariables);
        assertTrue(lowResult.isSuccess());
        assertEquals("LOW", lowResult.getVariable("level"));
    }
    
    @Test
    public void testTerminalRule() {
        // 测试终止规则
        String json = "{\n" +
                "  \"version\": \"1.0\",\n" +
                "  \"entryPoint\": \"terminal-rule\",\n" +
                "  \"rules\": [\n" +
                "    {\n" +
                "      \"ruleId\": \"terminal-rule\",\n" +
                "      \"description\": \"Terminal rule\",\n" +
                "      \"terminal\": true,\n" +
                "      \"actions\": [\n" +
                "        {\n" +
                "          \"actionId\": \"set-status\",\n" +
                "          \"type\": \"SCRIPT\",\n" +
                "          \"config\": {\"expression\": \"'COMPLETED'\"},\n" +
                "          \"outputVariable\": \"status\"\n" +
                "        }\n" +
                "      ]\n" +
                "    }\n" +
                "  ]\n" +
                "}";
        
        ProcessingConfig config = loader.loadFromString(json);
        engine.loadConfig(config);
        
        ProcessingContext result = engine.execute(new HashMap<>());
        
        assertTrue(result.isSuccess());
        assertEquals("COMPLETED", result.getVariable("status"));
    }
    
    @Test
    public void testPriorityTransitions() {
        // 测试优先级转换
        String json = "{\n" +
                "  \"version\": \"1.0\",\n" +
                "  \"entryPoint\": \"start\",\n" +
                "  \"rules\": [\n" +
                "    {\n" +
                "      \"ruleId\": \"start\",\n" +
                "      \"description\": \"Start rule\",\n" +
                "      \"actions\": [],\n" +
                "      \"transitions\": [\n" +
                "        {\"condition\": \"value > 0\", \"targetRule\": \"high-priority\", \"priority\": 1},\n" +
                "        {\"condition\": \"value > 0\", \"targetRule\": \"low-priority\", \"priority\": 2}\n" +
                "      ]\n" +
                "    },\n" +
                "    {\n" +
                "      \"ruleId\": \"high-priority\",\n" +
                "      \"terminal\": true,\n" +
                "      \"actions\": [{\"actionId\": \"a1\", \"type\": \"SCRIPT\", \"config\": {\"expression\": \"'HIGH'\"}, \"outputVariable\": \"result\"}]\n" +
                "    },\n" +
                "    {\n" +
                "      \"ruleId\": \"low-priority\",\n" +
                "      \"terminal\": true,\n" +
                "      \"actions\": [{\"actionId\": \"a1\", \"type\": \"SCRIPT\", \"config\": {\"expression\": \"'LOW'\"}, \"outputVariable\": \"result\"}]\n" +
                "    }\n" +
                "  ]\n" +
                "}";
        
        ProcessingConfig config = loader.loadFromString(json);
        engine.loadConfig(config);
        
        Map<String, Object> variables = new HashMap<>();
        variables.put("value", 10);
        
        ProcessingContext result = engine.execute(variables);
        
        assertTrue(result.isSuccess());
        // 应该匹配高优先级（priority=1）的转换
        assertEquals("HIGH", result.getVariable("result"));
    }
    
    @Test
    public void testMaxDepthProtection() {
        // 测试最大深度保护（防止无限循环）
        String json = "{\n" +
                "  \"version\": \"1.0\",\n" +
                "  \"entryPoint\": \"loop-rule\",\n" +
                "  \"globalSettings\": {\"maxExecutionDepth\": 5, \"timeout\": 30000},\n" +
                "  \"rules\": [\n" +
                "    {\n" +
                "      \"ruleId\": \"loop-rule\",\n" +
                "      \"description\": \"Looping rule\",\n" +
                "      \"actions\": [\n" +
                "        {\"actionId\": \"inc\", \"type\": \"SCRIPT\", \"config\": {\"expression\": \"(counter == null ? 0 : counter) + 1\"}, \"outputVariable\": \"counter\"}\n" +
                "      ],\n" +
                "      \"transitions\": [\n" +
                "        {\"condition\": \"true\", \"targetRule\": \"loop-rule\", \"priority\": 1}\n" +
                "      ]\n" +
                "    }\n" +
                "  ]\n" +
                "}";
        
        ProcessingConfig config = loader.loadFromString(json);
        engine.loadConfig(config);
        
        ProcessingContext result = engine.execute(new HashMap<>());
        
        // 应该因为达到最大深度而停止
        assertFalse(result.isSuccess());
        assertTrue(result.getErrorMessage().contains("Maximum execution depth exceeded"));
    }
    
    @Test
    public void testOutputExpression() {
        // 测试输出表达式
        String json = "{\n" +
                "  \"version\": \"1.0\",\n" +
                "  \"entryPoint\": \"test-rule\",\n" +
                "  \"rules\": [\n" +
                "    {\n" +
                "      \"ruleId\": \"test-rule\",\n" +
                "      \"terminal\": true,\n" +
                "      \"actions\": [\n" +
                "        {\n" +
                "          \"actionId\": \"create-object\",\n" +
                "          \"type\": \"SCRIPT\",\n" +
                "          \"config\": {\"expression\": \"{'name': 'John', 'age': 30}\"},\n" +
                "          \"outputVariable\": \"person\"\n" +
                "        },\n" +
                "        {\n" +
                "          \"actionId\": \"extract-name\",\n" +
                "          \"type\": \"SCRIPT\",\n" +
                "          \"config\": {\"expression\": \"person\"},\n" +
                "          \"outputVariable\": \"personName\",\n" +
                "          \"outputExpression\": \"result.name\"\n" +
                "        }\n" +
                "      ]\n" +
                "    }\n" +
                "  ]\n" +
                "}";
        
        ProcessingConfig config = loader.loadFromString(json);
        engine.loadConfig(config);
        
        ProcessingContext result = engine.execute(new HashMap<>());
        
        assertTrue(result.isSuccess());
        assertEquals("John", result.getVariable("personName"));
    }
    
    @Test
    public void testUtilFunctions() {
        // 测试工具函数 - 使用命名空间语法 util:methodName()
        // Test utility functions - using namespace syntax util:methodName()
        String json = "{\n" +
                "  \"version\": \"1.0\",\n" +
                "  \"entryPoint\": \"util-test\",\n" +
                "  \"rules\": [\n" +
                "    {\n" +
                "      \"ruleId\": \"util-test\",\n" +
                "      \"terminal\": true,\n" +
                "      \"actions\": [\n" +
                "        {\n" +
                "          \"actionId\": \"round\",\n" +
                "          \"type\": \"SCRIPT\",\n" +
                "          \"config\": {\"expression\": \"util:roundTo(3.14159, 2)\"},\n" +
                "          \"outputVariable\": \"rounded\"\n" +
                "        },\n" +
                "        {\n" +
                "          \"actionId\": \"uuid\",\n" +
                "          \"type\": \"SCRIPT\",\n" +
                "          \"config\": {\"expression\": \"util:uuid()\"},\n" +
                "          \"outputVariable\": \"uuid\"\n" +
                "        }\n" +
                "      ]\n" +
                "    }\n" +
                "  ]\n" +
                "}";
        
        ProcessingConfig config = loader.loadFromString(json);
        engine.loadConfig(config);
        
        ProcessingContext result = engine.execute(new HashMap<>());
        
        assertTrue(result.isSuccess());
        assertEquals(3.14, result.getVariable("rounded"));
        assertNotNull(result.getVariable("uuid"));
    }
    
    @Test
    public void testContinueOnError() {
        // 测试错误继续执行
        String json = "{\n" +
                "  \"version\": \"1.0\",\n" +
                "  \"entryPoint\": \"error-test\",\n" +
                "  \"rules\": [\n" +
                "    {\n" +
                "      \"ruleId\": \"error-test\",\n" +
                "      \"terminal\": true,\n" +
                "      \"actions\": [\n" +
                "        {\n" +
                "          \"actionId\": \"will-fail\",\n" +
                "          \"type\": \"SCRIPT\",\n" +
                "          \"config\": {\"expression\": \"undefined_variable.method()\"},\n" +
                "          \"outputVariable\": \"failed\",\n" +
                "          \"continueOnError\": true\n" +
                "        },\n" +
                "        {\n" +
                "          \"actionId\": \"will-succeed\",\n" +
                "          \"type\": \"SCRIPT\",\n" +
                "          \"config\": {\"expression\": \"'SUCCESS'\"},\n" +
                "          \"outputVariable\": \"status\"\n" +
                "        }\n" +
                "      ]\n" +
                "    }\n" +
                "  ]\n" +
                "}";
        
        ProcessingConfig config = loader.loadFromString(json);
        engine.loadConfig(config);
        
        ProcessingContext result = engine.execute(new HashMap<>());
        
        // 即使第一个动作失败，第二个动作也应该执行
        assertTrue(result.isSuccess());
        assertEquals("SUCCESS", result.getVariable("status"));
    }
    
    @Test
    public void testValidateConfig() {
        // 测试配置验证
        engine.loadConfig(loader.loadFromString(createSimpleConfig()));
        List<String> errors = engine.validateConfig();
        assertTrue(errors.isEmpty());
        
        // 测试无效配置
        String invalidJson = "{\n" +
                "  \"version\": \"1.0\",\n" +
                "  \"entryPoint\": \"non-existent\",\n" +
                "  \"rules\": []\n" +
                "}";
        
        engine.loadConfig(loader.loadFromString(invalidJson));
        errors = engine.validateConfig();
        assertFalse(errors.isEmpty());
        assertTrue(errors.get(0).contains("Entry point rule not found"));
    }
    
    @Test
    public void testExecutionTrace() {
        // 测试执行跟踪
        String json = createSimpleScriptConfig();
        ProcessingConfig config = loader.loadFromString(json);
        engine.loadConfig(config);
        
        Map<String, Object> variables = new HashMap<>();
        variables.put("a", 10);
        variables.put("b", 20);
        
        ProcessingContext result = engine.execute(variables);
        
        assertTrue(result.isSuccess());
        assertFalse(result.getExecutionTraces().isEmpty());
        assertTrue(result.getTotalExecutionTime() >= 0);
    }
    
    // Helper methods to create test configurations
    
    private String createSimpleConfig() {
        return "{\n" +
                "  \"version\": \"1.0\",\n" +
                "  \"entryPoint\": \"start-rule\",\n" +
                "  \"globalSettings\": {\n" +
                "    \"maxExecutionDepth\": 50,\n" +
                "    \"timeout\": 30000\n" +
                "  },\n" +
                "  \"rules\": [\n" +
                "    {\n" +
                "      \"ruleId\": \"start-rule\",\n" +
                "      \"description\": \"Start rule\",\n" +
                "      \"actions\": [],\n" +
                "      \"transitions\": [\n" +
                "        {\"condition\": \"true\", \"targetRule\": \"end-rule\", \"priority\": 1}\n" +
                "      ]\n" +
                "    },\n" +
                "    {\n" +
                "      \"ruleId\": \"end-rule\",\n" +
                "      \"description\": \"End rule\",\n" +
                "      \"terminal\": true,\n" +
                "      \"actions\": []\n" +
                "    }\n" +
                "  ]\n" +
                "}";
    }
    
    private String createSimpleScriptConfig() {
        return "{\n" +
                "  \"version\": \"1.0\",\n" +
                "  \"entryPoint\": \"calc-rule\",\n" +
                "  \"rules\": [\n" +
                "    {\n" +
                "      \"ruleId\": \"calc-rule\",\n" +
                "      \"description\": \"Calculate sum\",\n" +
                "      \"terminal\": true,\n" +
                "      \"actions\": [\n" +
                "        {\n" +
                "          \"actionId\": \"add\",\n" +
                "          \"type\": \"SCRIPT\",\n" +
                "          \"config\": {\"expression\": \"a + b\"},\n" +
                "          \"outputVariable\": \"sum\"\n" +
                "        }\n" +
                "      ]\n" +
                "    }\n" +
                "  ]\n" +
                "}";
    }
    
    private String createConditionalConfig() {
        return "{\n" +
                "  \"version\": \"1.0\",\n" +
                "  \"entryPoint\": \"check-amount\",\n" +
                "  \"rules\": [\n" +
                "    {\n" +
                "      \"ruleId\": \"check-amount\",\n" +
                "      \"description\": \"Check amount level\",\n" +
                "      \"actions\": [],\n" +
                "      \"transitions\": [\n" +
                "        {\"condition\": \"amount > 100\", \"targetRule\": \"high-amount\", \"priority\": 1},\n" +
                "        {\"condition\": \"amount <= 100\", \"targetRule\": \"low-amount\", \"priority\": 2}\n" +
                "      ]\n" +
                "    },\n" +
                "    {\n" +
                "      \"ruleId\": \"high-amount\",\n" +
                "      \"description\": \"High amount processing\",\n" +
                "      \"terminal\": true,\n" +
                "      \"actions\": [\n" +
                "        {\n" +
                "          \"actionId\": \"set-level\",\n" +
                "          \"type\": \"SCRIPT\",\n" +
                "          \"config\": {\"expression\": \"'HIGH'\"},\n" +
                "          \"outputVariable\": \"level\"\n" +
                "        }\n" +
                "      ]\n" +
                "    },\n" +
                "    {\n" +
                "      \"ruleId\": \"low-amount\",\n" +
                "      \"description\": \"Low amount processing\",\n" +
                "      \"terminal\": true,\n" +
                "      \"actions\": [\n" +
                "        {\n" +
                "          \"actionId\": \"set-level\",\n" +
                "          \"type\": \"SCRIPT\",\n" +
                "          \"config\": {\"expression\": \"'LOW'\"},\n" +
                "          \"outputVariable\": \"level\"\n" +
                "        }\n" +
                "      ]\n" +
                "    }\n" +
                "  ]\n" +
                "}";
    }
}
