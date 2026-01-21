package com.buyi.sku.tag.scheduler;

import com.buyi.sku.tag.model.ScheduledTagJob;
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
 * 调度任务JSON配置加载器
 * Scheduled Job JSON Configuration Loader
 * 
 * 从JSON文件/字符串加载调度任务配置
 */
public class ScheduledJobConfigLoader {
    
    private static final Logger logger = LoggerFactory.getLogger(ScheduledJobConfigLoader.class);
    private final Gson gson;
    
    public ScheduledJobConfigLoader() {
        this.gson = new GsonBuilder()
                .setPrettyPrinting()
                .create();
    }
    
    /**
     * 从JSON文件加载调度任务配置
     * Load scheduled job configuration from JSON file
     * 
     * @param jsonFilePath JSON文件路径
     * @return 调度任务配置
     * @throws IOException 文件读取异常
     */
    public ScheduledTagJob loadJobConfig(String jsonFilePath) throws IOException {
        logger.info("Loading job config from JSON file: {}", jsonFilePath);
        
        try (Reader reader = Files.newBufferedReader(
                Paths.get(jsonFilePath), StandardCharsets.UTF_8)) {
            JsonObject jsonObject = gson.fromJson(reader, JsonObject.class);
            return parseJobConfig(jsonObject);
        }
    }
    
    /**
     * 从JSON字符串加载调度任务配置
     * Load scheduled job configuration from JSON string
     * 
     * @param jsonString JSON字符串
     * @return 调度任务配置
     */
    public ScheduledTagJob loadJobConfigFromString(String jsonString) {
        logger.info("Loading job config from JSON string");
        JsonObject jsonObject = gson.fromJson(jsonString, JsonObject.class);
        return parseJobConfig(jsonObject);
    }
    
    /**
     * 从JSON文件加载多个调度任务配置
     * Load multiple scheduled job configurations from JSON file
     * 
     * @param jsonFilePath JSON文件路径
     * @return 调度任务配置列表
     * @throws IOException 文件读取异常
     */
    public List<ScheduledTagJob> loadJobConfigs(String jsonFilePath) throws IOException {
        logger.info("Loading job configs from JSON file: {}", jsonFilePath);
        
        try (Reader reader = Files.newBufferedReader(
                Paths.get(jsonFilePath), StandardCharsets.UTF_8)) {
            JsonArray jsonArray = gson.fromJson(reader, JsonArray.class);
            List<ScheduledTagJob> configs = new ArrayList<>();
            
            for (JsonElement element : jsonArray) {
                configs.add(parseJobConfig(element.getAsJsonObject()));
            }
            
            return configs;
        }
    }
    
    /**
     * 从JSON字符串加载多个调度任务配置
     * Load multiple scheduled job configurations from JSON string
     * 
     * @param jsonString JSON字符串
     * @return 调度任务配置列表
     */
    public List<ScheduledTagJob> loadJobConfigsFromString(String jsonString) {
        logger.info("Loading job configs from JSON string");
        JsonArray jsonArray = gson.fromJson(jsonString, JsonArray.class);
        List<ScheduledTagJob> configs = new ArrayList<>();
        
        for (JsonElement element : jsonArray) {
            configs.add(parseJobConfig(element.getAsJsonObject()));
        }
        
        return configs;
    }
    
    /**
     * 将调度任务配置导出为JSON字符串
     * Export scheduled job configuration to JSON string
     * 
     * @param job 调度任务配置
     * @return JSON字符串
     */
    public String exportJobConfig(ScheduledTagJob job) {
        return gson.toJson(job);
    }
    
    /**
     * 将多个调度任务配置导出为JSON字符串
     * Export multiple scheduled job configurations to JSON string
     * 
     * @param jobs 调度任务配置列表
     * @return JSON字符串
     */
    public String exportJobConfigs(List<ScheduledTagJob> jobs) {
        return gson.toJson(jobs);
    }
    
    /**
     * 解析调度任务配置JSON对象
     * Parse scheduled job configuration JSON object
     */
    private ScheduledTagJob parseJobConfig(JsonObject jsonObject) {
        ScheduledTagJob job = new ScheduledTagJob();
        
        // 必填字段
        job.setJobCode(jsonObject.get("jobCode").getAsString());
        job.setJobName(jsonObject.get("jobName").getAsString());
        job.setTagGroupId(jsonObject.get("tagGroupId").getAsLong());
        
        // 可选字段
        if (jsonObject.has("cronExpression")) {
            job.setCronExpression(jsonObject.get("cronExpression").getAsString());
        }
        
        if (jsonObject.has("dataSourceType")) {
            job.setDataSourceType(jsonObject.get("dataSourceType").getAsString());
        }
        
        if (jsonObject.has("dataSourceConfig")) {
            JsonElement configElement = jsonObject.get("dataSourceConfig");
            if (configElement.isJsonPrimitive()) {
                job.setDataSourceConfig(configElement.getAsString());
            } else {
                job.setDataSourceConfig(gson.toJson(configElement));
            }
        }
        
        if (jsonObject.has("jobParams")) {
            Type mapType = new TypeToken<Map<String, Object>>(){}.getType();
            Map<String, Object> params = gson.fromJson(jsonObject.get("jobParams"), mapType);
            job.setJobParams(params);
        }
        
        if (jsonObject.has("batchSize")) {
            job.setBatchSize(jsonObject.get("batchSize").getAsInt());
        }
        
        if (jsonObject.has("maxRetries")) {
            job.setMaxRetries(jsonObject.get("maxRetries").getAsInt());
        }
        
        if (jsonObject.has("timeoutSeconds")) {
            job.setTimeoutSeconds(jsonObject.get("timeoutSeconds").getAsInt());
        }
        
        if (jsonObject.has("status")) {
            job.setStatus(jsonObject.get("status").getAsString());
        }
        
        if (jsonObject.has("description")) {
            job.setDescription(jsonObject.get("description").getAsString());
        }
        
        logger.debug("Parsed job config: {} (tagGroupId: {})", 
                job.getJobCode(), job.getTagGroupId());
        return job;
    }
}
