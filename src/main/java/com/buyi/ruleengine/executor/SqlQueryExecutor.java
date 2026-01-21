package com.buyi.ruleengine.executor;

import com.buyi.ruleengine.enums.RuleType;
import com.buyi.ruleengine.model.RuleConfig;
import com.buyi.ruleengine.model.RuleContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * SQL查询执行器
 * SQL Query Executor
 */
public class SqlQueryExecutor implements RuleExecutor {
    
    private static final Logger logger = LoggerFactory.getLogger(SqlQueryExecutor.class);
    private final String jdbcUrl;
    private final String username;
    private final String password;
    
    public SqlQueryExecutor(String jdbcUrl, String username, String password) {
        this.jdbcUrl = jdbcUrl;
        this.username = username;
        this.password = password;
    }
    
    @Override
    public RuleContext execute(RuleConfig ruleConfig, RuleContext context) {
        long startTime = System.currentTimeMillis();
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            logger.info("Executing SQL query rule: {}", ruleConfig.getRuleCode());
            
            // 获取数据库连接
            conn = DriverManager.getConnection(jdbcUrl, username, password);
            
            // 准备SQL语句
            String sql = ruleConfig.getRuleContent();
            stmt = conn.prepareStatement(sql);
            
            // 设置参数
            if (ruleConfig.getRuleParams() != null && ruleConfig.getRuleParams().containsKey("inputs")) {
                Object inputsObj = ruleConfig.getRuleParams().get("inputs");
                if (inputsObj instanceof List) {
                    @SuppressWarnings("unchecked")
                    List<String> inputs = (List<String>) inputsObj;
                    for (int i = 0; i < inputs.size(); i++) {
                        String paramName = inputs.get(i);
                        Object paramValue = context.getInput(paramName);
                        stmt.setObject(i + 1, paramValue);
                    }
                }
            }
            
            // 执行查询
            rs = stmt.executeQuery();
            
            // 处理结果集
            List<Map<String, Object>> resultList = new ArrayList<>();
            ResultSetMetaData metaData = rs.getMetaData();
            int columnCount = metaData.getColumnCount();
            
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                for (int i = 1; i <= columnCount; i++) {
                    String columnName = metaData.getColumnLabel(i);
                    Object columnValue = rs.getObject(i);
                    row.put(columnName, columnValue);
                }
                resultList.add(row);
            }
            
            // 设置结果
            Object result = resultList.isEmpty() ? null : 
                           (resultList.size() == 1 ? resultList.get(0) : resultList);
            context.setResult(result);
            context.setSuccess(true);
            
            logger.info("SQL query rule executed successfully. Result size: {}", resultList.size());
            
        } catch (Exception e) {
            logger.error("Failed to execute SQL query rule: {}", ruleConfig.getRuleCode(), e);
            context.setSuccess(false);
            context.setErrorMessage("SQL query execution failed: " + e.getMessage());
        } finally {
            // 关闭资源
            closeQuietly(rs);
            closeQuietly(stmt);
            closeQuietly(conn);
            context.setExecutionTime(System.currentTimeMillis() - startTime);
        }
        
        return context;
    }
    
    @Override
    public boolean supports(RuleConfig ruleConfig) {
        return ruleConfig != null && RuleType.SQL_QUERY.equals(ruleConfig.getRuleType());
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
