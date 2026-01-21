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
            
            // 准备SQL语句 - 支持动态SQL拼接
            // Prepare SQL statement - support dynamic SQL concatenation
            String sql = buildDynamicSql(ruleConfig.getRuleContent(), context, ruleConfig.getRuleParams());
            logger.debug("Executing SQL: {}", sql);
            
            stmt = conn.prepareStatement(sql);
            
            // 设置参数
            List<Object> paramValues = extractParameterValues(ruleConfig, context);
            for (int i = 0; i < paramValues.size(); i++) {
                Object paramValue = paramValues.get(i);
                stmt.setObject(i + 1, paramValue);
                logger.debug("Setting parameter {}: {}", i + 1, paramValue);
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
    
    /**
     * 构建动态SQL - 支持SQL片段拼接
     * Build dynamic SQL - support SQL fragment concatenation
     * 
     * @param sqlTemplate SQL模板
     * @param context 执行上下文
     * @param ruleParams 规则参数
     * @return 拼接后的SQL语句
     */
    private String buildDynamicSql(String sqlTemplate, RuleContext context, Map<String, Object> ruleParams) {
        if (ruleParams == null || !ruleParams.containsKey("dynamicSql")) {
            return sqlTemplate;
        }
        
        Object dynamicSqlObj = ruleParams.get("dynamicSql");
        if (!(dynamicSqlObj instanceof Map)) {
            return sqlTemplate;
        }
        
        @SuppressWarnings("unchecked")
        Map<String, Object> dynamicSqlConfig = (Map<String, Object>) dynamicSqlObj;
        
        StringBuilder sql = new StringBuilder(sqlTemplate);
        boolean hasWhereClause = sqlTemplate.toUpperCase().contains("WHERE");
        
        // 处理WHERE条件拼接
        // Handle WHERE clause concatenation
        if (dynamicSqlConfig.containsKey("whereConditions")) {
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> conditions = (List<Map<String, Object>>) dynamicSqlConfig.get("whereConditions");
            
            for (Map<String, Object> condition : conditions) {
                String field = (String) condition.get("field");
                String operator = (String) condition.get("operator");
                String paramName = (String) condition.get("paramName");
                
                // 检查参数是否存在且不为null
                Object paramValue = context.getInput(paramName);
                if (paramValue != null) {
                    // 如果SQL中不包含WHERE，添加WHERE，否则添加AND
                    if (!hasWhereClause) {
                        sql.append(" WHERE ");
                        hasWhereClause = true;
                    } else {
                        sql.append(" AND ");
                    }
                    sql.append(field).append(" ").append(operator).append(" ?");
                }
            }
        }
        
        // 处理ORDER BY拼接
        // Handle ORDER BY concatenation
        if (dynamicSqlConfig.containsKey("orderBy")) {
            String orderByField = (String) dynamicSqlConfig.get("orderBy");
            if (orderByField != null && !orderByField.isEmpty()) {
                sql.append(" ORDER BY ").append(orderByField);
                
                // 检查是否有排序方向
                if (dynamicSqlConfig.containsKey("orderDirection")) {
                    String direction = (String) dynamicSqlConfig.get("orderDirection");
                    if ("ASC".equalsIgnoreCase(direction) || "DESC".equalsIgnoreCase(direction)) {
                        sql.append(" ").append(direction);
                    }
                }
            }
        }
        
        // 处理LIMIT拼接
        // Handle LIMIT concatenation
        if (dynamicSqlConfig.containsKey("limit")) {
            Object limitObj = dynamicSqlConfig.get("limit");
            if (limitObj instanceof Number) {
                sql.append(" LIMIT ").append(limitObj);
            }
        }
        
        logger.debug("Dynamic SQL built: {}", sql.toString());
        return sql.toString();
    }
    
    /**
     * 提取参数值列表
     * Extract parameter values list
     * 
     * @param ruleConfig 规则配置
     * @param context 执行上下文
     * @return 参数值列表
     */
    private List<Object> extractParameterValues(RuleConfig ruleConfig, RuleContext context) {
        List<Object> paramValues = new ArrayList<>();
        
        if (ruleConfig.getRuleParams() == null) {
            return paramValues;
        }
        
        // 提取inputs参数
        if (ruleConfig.getRuleParams().containsKey("inputs")) {
            Object inputsObj = ruleConfig.getRuleParams().get("inputs");
            if (inputsObj instanceof List) {
                @SuppressWarnings("unchecked")
                List<String> inputs = (List<String>) inputsObj;
                for (String paramName : inputs) {
                    paramValues.add(context.getInput(paramName));
                }
            }
        }
        
        // 提取动态WHERE条件的参数
        if (ruleConfig.getRuleParams().containsKey("dynamicSql")) {
            Object dynamicSqlObj = ruleConfig.getRuleParams().get("dynamicSql");
            if (dynamicSqlObj instanceof Map) {
                @SuppressWarnings("unchecked")
                Map<String, Object> dynamicSqlConfig = (Map<String, Object>) dynamicSqlObj;
                
                if (dynamicSqlConfig.containsKey("whereConditions")) {
                    @SuppressWarnings("unchecked")
                    List<Map<String, Object>> conditions = (List<Map<String, Object>>) dynamicSqlConfig.get("whereConditions");
                    
                    for (Map<String, Object> condition : conditions) {
                        String paramName = (String) condition.get("paramName");
                        Object paramValue = context.getInput(paramName);
                        // 只添加非null的参数值
                        if (paramValue != null) {
                            paramValues.add(paramValue);
                        }
                    }
                }
            }
        }
        
        return paramValues;
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
