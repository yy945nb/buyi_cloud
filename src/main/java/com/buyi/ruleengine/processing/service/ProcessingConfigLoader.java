package com.buyi.ruleengine.processing.service;

import com.buyi.ruleengine.processing.model.*;
import com.google.gson.*;
import com.google.gson.reflect.TypeToken;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.lang.reflect.Type;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * 流程配置加载器 - 解析processing.json格式的配置文件
 * Processing Config Loader - Parses processing.json format configuration files
 */
public class ProcessingConfigLoader {
    
    private static final Logger logger = LoggerFactory.getLogger(ProcessingConfigLoader.class);
    private final Gson gson;
    
    public ProcessingConfigLoader() {
        this.gson = new GsonBuilder()
                .setPrettyPrinting()
                .create();
    }
    
    /**
     * 从文件路径加载配置
     * Load configuration from file path
     * 
     * @param filePath 文件路径
     * @return 流程配置
     * @throws IOException 读取异常
     */
    public ProcessingConfig loadFromFile(String filePath) throws IOException {
        logger.info("Loading processing config from file: {}", filePath);
        
        try (Reader reader = Files.newBufferedReader(Paths.get(filePath), StandardCharsets.UTF_8)) {
            return parseConfig(reader);
        }
    }
    
    /**
     * 从类路径资源加载配置
     * Load configuration from classpath resource
     * 
     * @param resourcePath 资源路径
     * @return 流程配置
     * @throws IOException 读取异常
     */
    public ProcessingConfig loadFromResource(String resourcePath) throws IOException {
        logger.info("Loading processing config from resource: {}", resourcePath);
        
        InputStream inputStream = getClass().getClassLoader().getResourceAsStream(resourcePath);
        if (inputStream == null) {
            throw new IOException("Resource not found: " + resourcePath);
        }
        
        try (Reader reader = new InputStreamReader(inputStream, StandardCharsets.UTF_8)) {
            return parseConfig(reader);
        }
    }
    
    /**
     * 从JSON字符串加载配置
     * Load configuration from JSON string
     * 
     * @param jsonString JSON字符串
     * @return 流程配置
     */
    public ProcessingConfig loadFromString(String jsonString) {
        logger.info("Loading processing config from string");
        JsonObject jsonObject = gson.fromJson(jsonString, JsonObject.class);
        return parseConfigObject(jsonObject);
    }
    
    /**
     * 解析配置
     */
    private ProcessingConfig parseConfig(Reader reader) {
        JsonObject jsonObject = gson.fromJson(reader, JsonObject.class);
        return parseConfigObject(jsonObject);
    }
    
    /**
     * 解析配置对象
     */
    private ProcessingConfig parseConfigObject(JsonObject json) {
        ProcessingConfig config = new ProcessingConfig();
        
        // 解析基本属性
        if (json.has("version")) {
            config.setVersion(json.get("version").getAsString());
        }
        
        if (json.has("entryPoint")) {
            config.setEntryPoint(json.get("entryPoint").getAsString());
        }
        
        // 解析全局设置
        if (json.has("globalSettings")) {
            config.setGlobalSettings(parseGlobalSettings(json.getAsJsonObject("globalSettings")));
        } else {
            // 使用默认设置
            config.setGlobalSettings(new ProcessingConfig.GlobalSettings());
        }
        
        // 解析规则列表
        if (json.has("rules")) {
            JsonArray rulesArray = json.getAsJsonArray("rules");
            List<ProcessingRule> rules = new ArrayList<>();
            for (JsonElement element : rulesArray) {
                rules.add(parseRule(element.getAsJsonObject()));
            }
            config.setRules(rules);
        }
        
        logger.info("Loaded processing config: {}", config);
        return config;
    }
    
    /**
     * 解析全局设置
     */
    private ProcessingConfig.GlobalSettings parseGlobalSettings(JsonObject json) {
        ProcessingConfig.GlobalSettings settings = new ProcessingConfig.GlobalSettings();
        
        if (json.has("maxExecutionDepth")) {
            settings.setMaxExecutionDepth(json.get("maxExecutionDepth").getAsInt());
        }
        
        if (json.has("timeout")) {
            settings.setTimeout(json.get("timeout").getAsLong());
        }
        
        return settings;
    }
    
    /**
     * 解析规则
     */
    private ProcessingRule parseRule(JsonObject json) {
        ProcessingRule rule = new ProcessingRule();
        
        // 基本属性
        if (json.has("ruleId")) {
            rule.setRuleId(json.get("ruleId").getAsString());
        }
        
        if (json.has("description")) {
            rule.setDescription(json.get("description").getAsString());
        }
        
        if (json.has("terminal")) {
            rule.setTerminal(json.get("terminal").getAsBoolean());
        }
        
        // 解析动作列表
        if (json.has("actions")) {
            JsonArray actionsArray = json.getAsJsonArray("actions");
            List<ProcessingAction> actions = new ArrayList<>();
            for (JsonElement element : actionsArray) {
                actions.add(parseAction(element.getAsJsonObject()));
            }
            rule.setActions(actions);
        }
        
        // 解析转换列表
        if (json.has("transitions")) {
            JsonArray transitionsArray = json.getAsJsonArray("transitions");
            List<ProcessingTransition> transitions = new ArrayList<>();
            for (JsonElement element : transitionsArray) {
                transitions.add(parseTransition(element.getAsJsonObject()));
            }
            rule.setTransitions(transitions);
        }
        
        logger.debug("Parsed rule: {}", rule.getRuleId());
        return rule;
    }
    
    /**
     * 解析动作
     */
    private ProcessingAction parseAction(JsonObject json) {
        ProcessingAction action = new ProcessingAction();
        
        if (json.has("actionId")) {
            action.setActionId(json.get("actionId").getAsString());
        }
        
        if (json.has("type")) {
            String typeStr = json.get("type").getAsString();
            action.setType(ProcessingAction.ActionType.valueOf(typeStr));
        }
        
        if (json.has("config")) {
            Type mapType = new TypeToken<Map<String, Object>>(){}.getType();
            Map<String, Object> config = gson.fromJson(json.get("config"), mapType);
            action.setConfig(config);
        }
        
        if (json.has("outputVariable")) {
            action.setOutputVariable(json.get("outputVariable").getAsString());
        }
        
        if (json.has("outputExpression")) {
            action.setOutputExpression(json.get("outputExpression").getAsString());
        }
        
        if (json.has("continueOnError")) {
            action.setContinueOnError(json.get("continueOnError").getAsBoolean());
        }
        
        return action;
    }
    
    /**
     * 解析转换
     */
    private ProcessingTransition parseTransition(JsonObject json) {
        ProcessingTransition transition = new ProcessingTransition();
        
        if (json.has("condition")) {
            transition.setCondition(json.get("condition").getAsString());
        }
        
        if (json.has("targetRule")) {
            transition.setTargetRule(json.get("targetRule").getAsString());
        }
        
        if (json.has("priority")) {
            transition.setPriority(json.get("priority").getAsInt());
        }
        
        return transition;
    }
    
    /**
     * 将配置转换为JSON字符串
     * Convert configuration to JSON string
     * 
     * @param config 配置对象
     * @return JSON字符串
     */
    public String toJson(ProcessingConfig config) {
        return gson.toJson(config);
    }
}
