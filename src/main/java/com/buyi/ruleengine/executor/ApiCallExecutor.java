package com.buyi.ruleengine.executor;

import com.buyi.ruleengine.enums.RuleType;
import com.buyi.ruleengine.model.RuleConfig;
import com.buyi.ruleengine.model.RuleContext;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import org.apache.http.HttpEntity;
import org.apache.http.client.methods.*;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Map;

/**
 * API接口调用执行器
 * API Call Executor
 */
public class ApiCallExecutor implements RuleExecutor {
    
    private static final Logger logger = LoggerFactory.getLogger(ApiCallExecutor.class);
    private final Gson gson;
    
    public ApiCallExecutor() {
        this.gson = new Gson();
    }
    
    @Override
    public RuleContext execute(RuleConfig ruleConfig, RuleContext context) {
        long startTime = System.currentTimeMillis();
        CloseableHttpClient httpClient = null;
        CloseableHttpResponse response = null;
        
        try {
            logger.info("Executing API call rule: {}", ruleConfig.getRuleCode());
            
            // 解析API配置
            Map<String, Object> apiConfig = gson.fromJson(
                    ruleConfig.getRuleContent(),
                    new TypeToken<Map<String, Object>>(){}.getType()
            );
            
            String url = (String) apiConfig.get("url");
            String method = (String) apiConfig.get("method");
            Map<String, String> headers = (Map<String, String>) apiConfig.get("headers");
            
            // 替换URL中的参数占位符
            if (context.getInputParams() != null) {
                for (Map.Entry<String, Object> entry : context.getInputParams().entrySet()) {
                    url = url.replace("{" + entry.getKey() + "}", String.valueOf(entry.getValue()));
                }
            }
            
            // 创建HTTP请求
            httpClient = HttpClients.createDefault();
            HttpRequestBase request = createRequest(method, url);
            
            // 设置请求头
            if (headers != null) {
                headers.forEach(request::setHeader);
            }
            
            // 设置请求体（POST/PUT）
            if (apiConfig.containsKey("body") && request instanceof HttpEntityEnclosingRequestBase) {
                String body = apiConfig.get("body").toString();
                // 替换body中的参数占位符
                if (context.getInputParams() != null) {
                    for (Map.Entry<String, Object> entry : context.getInputParams().entrySet()) {
                        body = body.replace("{" + entry.getKey() + "}", String.valueOf(entry.getValue()));
                    }
                }
                StringEntity entity = new StringEntity(body, "UTF-8");
                ((HttpEntityEnclosingRequestBase) request).setEntity(entity);
            }
            
            // 执行请求
            response = httpClient.execute(request);
            
            // 处理响应
            int statusCode = response.getStatusLine().getStatusCode();
            HttpEntity entity = response.getEntity();
            String responseBody = entity != null ? EntityUtils.toString(entity, "UTF-8") : null;
            
            if (statusCode >= 200 && statusCode < 300) {
                // 解析JSON响应
                Object result = null;
                if (responseBody != null && !responseBody.isEmpty()) {
                    try {
                        result = gson.fromJson(responseBody, Object.class);
                    } catch (Exception e) {
                        result = responseBody;
                    }
                }
                
                context.setResult(result);
                context.setSuccess(true);
                
                logger.info("API call rule executed successfully. Status: {}", statusCode);
            } else {
                context.setSuccess(false);
                context.setErrorMessage("API call failed with status: " + statusCode + ", body: " + responseBody);
                logger.error("API call failed. Status: {}, Body: {}", statusCode, responseBody);
            }
            
        } catch (Exception e) {
            logger.error("Failed to execute API call rule: {}", ruleConfig.getRuleCode(), e);
            context.setSuccess(false);
            context.setErrorMessage("API call execution failed: " + e.getMessage());
        } finally {
            closeQuietly(response);
            closeQuietly(httpClient);
            context.setExecutionTime(System.currentTimeMillis() - startTime);
        }
        
        return context;
    }
    
    @Override
    public boolean supports(RuleConfig ruleConfig) {
        return ruleConfig != null && RuleType.API_CALL.equals(ruleConfig.getRuleType());
    }
    
    private HttpRequestBase createRequest(String method, String url) {
        switch (method.toUpperCase()) {
            case "GET":
                return new HttpGet(url);
            case "POST":
                return new HttpPost(url);
            case "PUT":
                return new HttpPut(url);
            case "DELETE":
                return new HttpDelete(url);
            default:
                throw new IllegalArgumentException("Unsupported HTTP method: " + method);
        }
    }
    
    private void closeQuietly(AutoCloseable closeable) {
        if (closeable != null) {
            try {
                closeable.close();
            } catch (Exception e) {
                logger.warn("Failed to close resource", e);
            }
        }
    }
}
