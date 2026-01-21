package com.buyi.ruleengine.processing.executor;

import com.buyi.ruleengine.processing.model.ProcessingAction;
import com.buyi.ruleengine.processing.model.ProcessingContext;
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
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * API动作执行器 - 执行HTTP API调用
 * API Action Executor - Executes HTTP API calls
 */
public class ApiActionExecutor implements ActionExecutor {
    
    private static final Logger logger = LoggerFactory.getLogger(ApiActionExecutor.class);
    private static final Pattern VARIABLE_PATTERN = Pattern.compile("\\$\\{([^}]+)}");
    private final Gson gson;
    
    public ApiActionExecutor() {
        this.gson = new Gson();
    }
    
    @Override
    public ActionResult execute(ProcessingAction action, ProcessingContext context) {
        long startTime = System.currentTimeMillis();
        CloseableHttpClient httpClient = null;
        CloseableHttpResponse response = null;
        
        try {
            logger.debug("Executing API action: {}", action.getActionId());
            
            Map<String, Object> config = action.getConfig();
            
            // 获取配置
            String url = (String) config.get("url");
            String method = (String) config.get("method");
            
            if (url == null || method == null) {
                return ActionResult.failure("URL or method is not specified");
            }
            
            // 替换URL中的变量
            url = replaceVariables(url, context);
            
            @SuppressWarnings("unchecked")
            Map<String, String> headers = (Map<String, String>) config.get("headers");
            
            // 创建HTTP客户端和请求
            httpClient = HttpClients.createDefault();
            HttpRequestBase request = createRequest(method, url);
            
            // 设置请求头
            if (headers != null) {
                for (Map.Entry<String, String> entry : headers.entrySet()) {
                    request.setHeader(entry.getKey(), entry.getValue());
                }
            }
            
            // 设置请求体
            if (config.containsKey("body") && request instanceof HttpEntityEnclosingRequestBase) {
                String body = gson.toJson(config.get("body"));
                body = replaceVariables(body, context);
                StringEntity entity = new StringEntity(body, "UTF-8");
                ((HttpEntityEnclosingRequestBase) request).setEntity(entity);
            }
            
            // 执行请求
            logger.debug("Executing HTTP {} request to: {}", method, url);
            response = httpClient.execute(request);
            
            // 处理响应
            int statusCode = response.getStatusLine().getStatusCode();
            HttpEntity entity = response.getEntity();
            String responseBody = entity != null ? EntityUtils.toString(entity, "UTF-8") : null;
            
            logger.debug("API response status: {}", statusCode);
            
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
                
                ActionResult actionResult = ActionResult.success(result);
                actionResult.setExecutionTime(System.currentTimeMillis() - startTime);
                return actionResult;
            } else {
                ActionResult actionResult = ActionResult.failure(
                        "API call failed with status: " + statusCode + ", body: " + responseBody);
                actionResult.setExecutionTime(System.currentTimeMillis() - startTime);
                return actionResult;
            }
            
        } catch (Exception e) {
            logger.error("Failed to execute API action: {}", action.getActionId(), e);
            ActionResult actionResult = ActionResult.failure("API execution failed: " + e.getMessage());
            actionResult.setExecutionTime(System.currentTimeMillis() - startTime);
            return actionResult;
        } finally {
            closeQuietly(response);
            closeQuietly(httpClient);
        }
    }
    
    /**
     * 替换字符串中的变量
     * Replace variables in string (${variable} format)
     */
    private String replaceVariables(String template, ProcessingContext context) {
        if (template == null) {
            return null;
        }
        
        Matcher matcher = VARIABLE_PATTERN.matcher(template);
        StringBuffer sb = new StringBuffer();
        
        while (matcher.find()) {
            String varName = matcher.group(1);
            Object value = context.getVariable(varName);
            String replacement = value != null ? value.toString() : "";
            matcher.appendReplacement(sb, Matcher.quoteReplacement(replacement));
        }
        matcher.appendTail(sb);
        
        return sb.toString();
    }
    
    /**
     * 创建HTTP请求对象
     */
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
    
    /**
     * 静默关闭资源
     */
    private void closeQuietly(AutoCloseable closeable) {
        if (closeable != null) {
            try {
                closeable.close();
            } catch (Exception e) {
                logger.warn("Failed to close resource", e);
            }
        }
    }
    
    @Override
    public boolean supports(ProcessingAction.ActionType actionType) {
        return ProcessingAction.ActionType.API == actionType;
    }
}
