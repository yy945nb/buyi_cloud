package com.buyi.ruleengine.service;

import com.buyi.ruleengine.enums.RuleType;
import com.buyi.ruleengine.model.RuleConfig;
import com.buyi.ruleengine.model.RuleFlow;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.reflect.TypeToken;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.FileReader;
import java.io.IOException;
import java.io.Reader;
import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * JSON配置加载器
 * JSON Configuration Loader for loading rules and flows from JSON files
 */
public class JsonConfigLoader {
    
    private static final Logger logger = LoggerFactory.getLogger(JsonConfigLoader.class);
    private final Gson gson;
    
    public JsonConfigLoader() {
        this.gson = new GsonBuilder()
                .setPrettyPrinting()
                .create();
    }
    
    /**
     * 从JSON文件加载规则配置
     * Load rule configuration from JSON file
     * 
     * @param jsonFilePath JSON文件路径
     * @return 规则配置对象
     * @throws IOException 文件读取异常
     */
    public RuleConfig loadRuleConfig(String jsonFilePath) throws IOException {
        logger.info("Loading rule config from JSON file: {}", jsonFilePath);
        
        try (Reader reader = new FileReader(jsonFilePath)) {
            JsonObject jsonObject = gson.fromJson(reader, JsonObject.class);
            return parseRuleConfig(jsonObject);
        }
    }
    
    /**
     * 从JSON字符串加载规则配置
     * Load rule configuration from JSON string
     * 
     * @param jsonString JSON字符串
     * @return 规则配置对象
     */
    public RuleConfig loadRuleConfigFromString(String jsonString) {
        logger.info("Loading rule config from JSON string");
        JsonObject jsonObject = gson.fromJson(jsonString, JsonObject.class);
        return parseRuleConfig(jsonObject);
    }
    
    /**
     * 从JSON文件加载多个规则配置
     * Load multiple rule configurations from JSON file
     * 
     * @param jsonFilePath JSON文件路径
     * @return 规则配置列表
     * @throws IOException 文件读取异常
     */
    public List<RuleConfig> loadRuleConfigs(String jsonFilePath) throws IOException {
        logger.info("Loading rule configs from JSON file: {}", jsonFilePath);
        
        try (Reader reader = new FileReader(jsonFilePath)) {
            JsonArray jsonArray = gson.fromJson(reader, JsonArray.class);
            List<RuleConfig> configs = new ArrayList<>();
            
            for (JsonElement element : jsonArray) {
                configs.add(parseRuleConfig(element.getAsJsonObject()));
            }
            
            return configs;
        }
    }
    
    /**
     * 从JSON文件加载流程配置
     * Load flow configuration from JSON file
     * 
     * @param jsonFilePath JSON文件路径
     * @return 流程配置对象
     * @throws IOException 文件读取异常
     */
    public RuleFlow loadFlowConfig(String jsonFilePath) throws IOException {
        logger.info("Loading flow config from JSON file: {}", jsonFilePath);
        
        try (Reader reader = new FileReader(jsonFilePath)) {
            JsonObject jsonObject = gson.fromJson(reader, JsonObject.class);
            return parseFlowConfig(jsonObject);
        }
    }
    
    /**
     * 从JSON字符串加载流程配置
     * Load flow configuration from JSON string
     * 
     * @param jsonString JSON字符串
     * @return 流程配置对象
     */
    public RuleFlow loadFlowConfigFromString(String jsonString) {
        logger.info("Loading flow config from JSON string");
        JsonObject jsonObject = gson.fromJson(jsonString, JsonObject.class);
        return parseFlowConfig(jsonObject);
    }
    
    /**
     * 解析规则配置JSON对象
     */
    private RuleConfig parseRuleConfig(JsonObject jsonObject) {
        RuleConfig config = new RuleConfig();
        
        // 必填字段
        config.setRuleCode(jsonObject.get("ruleCode").getAsString());
        config.setRuleName(jsonObject.get("ruleName").getAsString());
        config.setRuleType(RuleType.valueOf(jsonObject.get("ruleType").getAsString()));
        config.setRuleContent(jsonObject.get("ruleContent").getAsString());
        
        // 可选字段
        if (jsonObject.has("description")) {
            config.setDescription(jsonObject.get("description").getAsString());
        }
        
        if (jsonObject.has("status")) {
            config.setStatus(jsonObject.get("status").getAsInt());
        } else {
            config.setStatus(1); // 默认启用
        }
        
        if (jsonObject.has("priority")) {
            config.setPriority(jsonObject.get("priority").getAsInt());
        } else {
            config.setPriority(0); // 默认优先级
        }
        
        // 规则参数
        if (jsonObject.has("ruleParams")) {
            Type mapType = new TypeToken<Map<String, Object>>(){}.getType();
            Map<String, Object> params = gson.fromJson(jsonObject.get("ruleParams"), mapType);
            config.setRuleParams(params);
        }
        
        logger.debug("Parsed rule config: {} (priority: {})", config.getRuleCode(), config.getPriority());
        return config;
    }
    
    /**
     * 解析流程配置JSON对象
     */
    private RuleFlow parseFlowConfig(JsonObject jsonObject) {
        RuleFlow flow = new RuleFlow();
        
        // 必填字段
        flow.setFlowCode(jsonObject.get("flowCode").getAsString());
        flow.setFlowName(jsonObject.get("flowName").getAsString());
        
        // 可选字段
        if (jsonObject.has("description")) {
            flow.setDescription(jsonObject.get("description").getAsString());
        }
        
        if (jsonObject.has("status")) {
            flow.setStatus(jsonObject.get("status").getAsInt());
        } else {
            flow.setStatus(1); // 默认启用
        }
        
        // 解析流程步骤
        JsonArray stepsArray = jsonObject.getAsJsonArray("steps");
        List<RuleFlow.FlowStep> steps = new ArrayList<>();
        
        for (JsonElement element : stepsArray) {
            JsonObject stepObj = element.getAsJsonObject();
            RuleFlow.FlowStep step = new RuleFlow.FlowStep();
            
            step.setStep(stepObj.get("step").getAsInt());
            step.setRuleCode(stepObj.get("ruleCode").getAsString());
            
            if (stepObj.has("condition") && !stepObj.get("condition").isJsonNull()) {
                step.setCondition(stepObj.get("condition").getAsString());
            }
            
            if (stepObj.has("onSuccess")) {
                step.setOnSuccess(stepObj.get("onSuccess").getAsString());
            } else {
                step.setOnSuccess("next"); // 默认继续下一步
            }
            
            if (stepObj.has("onFailure")) {
                step.setOnFailure(stepObj.get("onFailure").getAsString());
            } else {
                step.setOnFailure("abort"); // 默认中止
            }
            
            if (stepObj.has("priority")) {
                // 如果步骤中包含priority，可以用于后续排序
                // Priority can be used for sorting steps
            }
            
            steps.add(step);
        }
        
        flow.setSteps(steps);
        
        logger.debug("Parsed flow config: {} with {} steps", flow.getFlowCode(), steps.size());
        return flow;
    }
}
