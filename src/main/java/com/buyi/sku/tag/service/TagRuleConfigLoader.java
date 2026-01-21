package com.buyi.sku.tag.service;

import com.buyi.sku.tag.model.SkuTagRule;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.reflect.TypeToken;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.io.Reader;
import java.lang.reflect.Type;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * 标签规则JSON配置加载器
 * Tag Rule JSON Configuration Loader
 * 
 * 从JSON文件/字符串加载标签规则配置
 */
public class TagRuleConfigLoader {
    
    private static final Logger logger = LoggerFactory.getLogger(TagRuleConfigLoader.class);
    private final Gson gson;
    
    public TagRuleConfigLoader() {
        this.gson = new GsonBuilder()
                .setPrettyPrinting()
                .create();
    }
    
    /**
     * 从JSON文件加载标签规则配置
     * Load tag rule configuration from JSON file
     * 
     * @param jsonFilePath JSON文件路径
     * @return 标签规则配置
     * @throws IOException 文件读取异常
     */
    public SkuTagRule loadRuleConfig(String jsonFilePath) throws IOException {
        logger.info("Loading tag rule config from JSON file: {}", jsonFilePath);
        
        try (Reader reader = Files.newBufferedReader(
                Paths.get(jsonFilePath), StandardCharsets.UTF_8)) {
            JsonObject jsonObject = gson.fromJson(reader, JsonObject.class);
            return parseRuleConfig(jsonObject);
        }
    }
    
    /**
     * 从JSON字符串加载标签规则配置
     * Load tag rule configuration from JSON string
     * 
     * @param jsonString JSON字符串
     * @return 标签规则配置
     */
    public SkuTagRule loadRuleConfigFromString(String jsonString) {
        logger.info("Loading tag rule config from JSON string");
        JsonObject jsonObject = gson.fromJson(jsonString, JsonObject.class);
        return parseRuleConfig(jsonObject);
    }
    
    /**
     * 从JSON文件加载多个标签规则配置
     * Load multiple tag rule configurations from JSON file
     * 
     * @param jsonFilePath JSON文件路径
     * @return 标签规则配置列表
     * @throws IOException 文件读取异常
     */
    public List<SkuTagRule> loadRuleConfigs(String jsonFilePath) throws IOException {
        logger.info("Loading tag rule configs from JSON file: {}", jsonFilePath);
        
        try (Reader reader = Files.newBufferedReader(
                Paths.get(jsonFilePath), StandardCharsets.UTF_8)) {
            JsonArray jsonArray = gson.fromJson(reader, JsonArray.class);
            List<SkuTagRule> configs = new ArrayList<>();
            
            for (JsonElement element : jsonArray) {
                configs.add(parseRuleConfig(element.getAsJsonObject()));
            }
            
            return configs;
        }
    }
    
    /**
     * 从JSON字符串加载多个标签规则配置
     * Load multiple tag rule configurations from JSON string
     * 
     * @param jsonString JSON字符串
     * @return 标签规则配置列表
     */
    public List<SkuTagRule> loadRuleConfigsFromString(String jsonString) {
        logger.info("Loading tag rule configs from JSON string");
        JsonArray jsonArray = gson.fromJson(jsonString, JsonArray.class);
        List<SkuTagRule> configs = new ArrayList<>();
        
        for (JsonElement element : jsonArray) {
            configs.add(parseRuleConfig(element.getAsJsonObject()));
        }
        
        return configs;
    }
    
    /**
     * 将标签规则配置导出为JSON字符串
     * Export tag rule configuration to JSON string
     * 
     * @param rule 标签规则配置
     * @return JSON字符串
     */
    public String exportRuleConfig(SkuTagRule rule) {
        return gson.toJson(rule);
    }
    
    /**
     * 将多个标签规则配置导出为JSON字符串
     * Export multiple tag rule configurations to JSON string
     * 
     * @param rules 标签规则配置列表
     * @return JSON字符串
     */
    public String exportRuleConfigs(List<SkuTagRule> rules) {
        return gson.toJson(rules);
    }
    
    /**
     * 加载并注册规则到TagRuleService
     * Load and register rules to TagRuleService
     * 
     * @param jsonFilePath JSON文件路径
     * @param ruleService TagRuleService实例
     * @param autoPublish 是否自动发布
     * @param publishUser 发布人
     * @return 注册的规则数量
     * @throws IOException 文件读取异常
     */
    public int loadAndRegisterRules(String jsonFilePath, TagRuleService ruleService, 
                                    boolean autoPublish, String publishUser) throws IOException {
        List<SkuTagRule> rules = loadRuleConfigs(jsonFilePath);
        int count = 0;
        
        for (SkuTagRule rule : rules) {
            ruleService.registerRule(rule);
            
            if (autoPublish && "ENABLED".equals(rule.getStatus())) {
                int version = rule.getVersion() != null ? rule.getVersion() : 1;
                ruleService.publishRule(rule.getRuleCode(), version, publishUser);
            }
            
            count++;
        }
        
        logger.info("Loaded and registered {} rules from {}", count, jsonFilePath);
        return count;
    }
    
    /**
     * 解析标签规则配置JSON对象
     * Parse tag rule configuration JSON object
     */
    private SkuTagRule parseRuleConfig(JsonObject jsonObject) {
        SkuTagRule rule = new SkuTagRule();
        
        // 必填字段 - 添加null检查
        if (!jsonObject.has("ruleCode") || jsonObject.get("ruleCode").isJsonNull()) {
            throw new IllegalArgumentException("Missing required field: ruleCode");
        }
        if (!jsonObject.has("ruleName") || jsonObject.get("ruleName").isJsonNull()) {
            throw new IllegalArgumentException("Missing required field: ruleName");
        }
        if (!jsonObject.has("tagGroupId") || jsonObject.get("tagGroupId").isJsonNull()) {
            throw new IllegalArgumentException("Missing required field: tagGroupId");
        }
        if (!jsonObject.has("tagValueId") || jsonObject.get("tagValueId").isJsonNull()) {
            throw new IllegalArgumentException("Missing required field: tagValueId");
        }
        if (!jsonObject.has("ruleType") || jsonObject.get("ruleType").isJsonNull()) {
            throw new IllegalArgumentException("Missing required field: ruleType");
        }
        if (!jsonObject.has("ruleContent") || jsonObject.get("ruleContent").isJsonNull()) {
            throw new IllegalArgumentException("Missing required field: ruleContent");
        }
        
        rule.setRuleCode(jsonObject.get("ruleCode").getAsString());
        rule.setRuleName(jsonObject.get("ruleName").getAsString());
        rule.setTagGroupId(jsonObject.get("tagGroupId").getAsLong());
        rule.setTagValueId(jsonObject.get("tagValueId").getAsLong());
        rule.setRuleType(jsonObject.get("ruleType").getAsString());
        rule.setRuleContent(jsonObject.get("ruleContent").getAsString());
        
        // 可选字段
        if (jsonObject.has("ruleParams")) {
            Type mapType = new TypeToken<Map<String, Object>>(){}.getType();
            Map<String, Object> params = gson.fromJson(jsonObject.get("ruleParams"), mapType);
            rule.setRuleParams(params);
        }
        
        if (jsonObject.has("scopeConfig")) {
            Type mapType = new TypeToken<Map<String, Object>>(){}.getType();
            Map<String, Object> scope = gson.fromJson(jsonObject.get("scopeConfig"), mapType);
            rule.setScopeConfig(scope);
        }
        
        if (jsonObject.has("priority")) {
            rule.setPriority(jsonObject.get("priority").getAsInt());
        } else {
            rule.setPriority(0);
        }
        
        if (jsonObject.has("version")) {
            rule.setVersion(jsonObject.get("version").getAsInt());
        } else {
            rule.setVersion(1);
        }
        
        if (jsonObject.has("status")) {
            rule.setStatus(jsonObject.get("status").getAsString());
        } else {
            rule.setStatus("DRAFT");
        }
        
        if (jsonObject.has("description")) {
            rule.setDescription(jsonObject.get("description").getAsString());
        }
        
        logger.debug("Parsed tag rule config: {} (tagGroupId: {}, priority: {})", 
                rule.getRuleCode(), rule.getTagGroupId(), rule.getPriority());
        return rule;
    }
}
