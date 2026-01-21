package com.buyi.ruleengine;

import com.buyi.ruleengine.enums.RuleType;
import com.buyi.ruleengine.executor.SqlQueryExecutor;
import com.buyi.ruleengine.model.RuleConfig;
import com.buyi.ruleengine.model.RuleContext;
import com.buyi.ruleengine.service.RuleEngine;
import org.junit.Before;
import org.junit.Ignore;
import org.junit.Test;

import java.util.*;

import static org.junit.Assert.*;

/**
 * 动态SQL拼接单元测试
 * Dynamic SQL Concatenation Unit Tests
 * 
 * Note: These tests require a running database and are marked as @Ignore by default.
 * Remove @Ignore annotation and configure database connection to run these tests.
 */
public class DynamicSqlTest {
    
    private RuleEngine ruleEngine;
    private SqlQueryExecutor sqlExecutor;
    
    @Before
    public void setUp() {
        ruleEngine = new RuleEngine();
        // Note: Replace with actual database credentials
        String jdbcUrl = "jdbc:mysql://localhost:3306/test_db";
        String username = "test_user";
        String password = "test_pass";
        sqlExecutor = new SqlQueryExecutor(jdbcUrl, username, password);
        ruleEngine.registerExecutor(sqlExecutor);
    }
    
    @Test
    @Ignore("Requires database setup")
    public void testBasicSqlQuery() {
        // 测试基本SQL查询（不使用动态拼接）
        RuleConfig rule = new RuleConfig();
        rule.setRuleCode("QUERY_USER");
        rule.setRuleName("查询用户");
        rule.setRuleType(RuleType.SQL_QUERY);
        rule.setRuleContent("SELECT * FROM users WHERE id = ?");
        
        Map<String, Object> ruleParams = new HashMap<>();
        ruleParams.put("inputs", Arrays.asList("userId"));
        rule.setRuleParams(ruleParams);
        
        Map<String, Object> params = new HashMap<>();
        params.put("userId", 1);
        
        RuleContext context = new RuleContext(params);
        context = ruleEngine.executeRule(rule, context);
        
        assertTrue(context.isSuccess());
        assertNotNull(context.getResult());
    }
    
    @Test
    @Ignore("Requires database setup")
    public void testDynamicSqlWithWhereConditions() {
        // 测试动态WHERE条件拼接
        RuleConfig rule = new RuleConfig();
        rule.setRuleCode("DYNAMIC_QUERY_PRODUCTS");
        rule.setRuleName("动态查询商品");
        rule.setRuleType(RuleType.SQL_QUERY);
        rule.setRuleContent("SELECT * FROM products");
        
        Map<String, Object> ruleParams = new HashMap<>();
        
        // 配置动态SQL
        Map<String, Object> dynamicSql = new HashMap<>();
        List<Map<String, Object>> conditions = new ArrayList<>();
        
        // 添加category条件
        Map<String, Object> condition1 = new HashMap<>();
        condition1.put("field", "category");
        condition1.put("operator", "=");
        condition1.put("paramName", "category");
        conditions.add(condition1);
        
        // 添加price条件
        Map<String, Object> condition2 = new HashMap<>();
        condition2.put("field", "price");
        condition2.put("operator", ">=");
        condition2.put("paramName", "minPrice");
        conditions.add(condition2);
        
        dynamicSql.put("whereConditions", conditions);
        ruleParams.put("dynamicSql", dynamicSql);
        
        rule.setRuleParams(ruleParams);
        
        Map<String, Object> params = new HashMap<>();
        params.put("category", "electronics");
        params.put("minPrice", 100.0);
        
        RuleContext context = new RuleContext(params);
        context = ruleEngine.executeRule(rule, context);
        
        assertTrue(context.isSuccess());
        // 应该执行: SELECT * FROM products WHERE category = ? AND price >= ?
    }
    
    @Test
    @Ignore("Requires database setup")
    public void testDynamicSqlWithOptionalConditions() {
        // 测试可选的动态条件（某些参数为null时不添加该条件）
        RuleConfig rule = new RuleConfig();
        rule.setRuleCode("OPTIONAL_CONDITIONS");
        rule.setRuleName("可选条件查询");
        rule.setRuleType(RuleType.SQL_QUERY);
        rule.setRuleContent("SELECT * FROM orders");
        
        Map<String, Object> ruleParams = new HashMap<>();
        Map<String, Object> dynamicSql = new HashMap<>();
        List<Map<String, Object>> conditions = new ArrayList<>();
        
        Map<String, Object> condition1 = new HashMap<>();
        condition1.put("field", "status");
        condition1.put("operator", "=");
        condition1.put("paramName", "status");
        conditions.add(condition1);
        
        Map<String, Object> condition2 = new HashMap<>();
        condition2.put("field", "customer_id");
        condition2.put("operator", "=");
        condition2.put("paramName", "customerId");
        conditions.add(condition2);
        
        dynamicSql.put("whereConditions", conditions);
        ruleParams.put("dynamicSql", dynamicSql);
        rule.setRuleParams(ruleParams);
        
        Map<String, Object> params = new HashMap<>();
        params.put("status", "completed");
        // customerId为null，不应该添加这个条件
        params.put("customerId", null);
        
        RuleContext context = new RuleContext(params);
        context = ruleEngine.executeRule(rule, context);
        
        assertTrue(context.isSuccess());
        // 应该执行: SELECT * FROM orders WHERE status = ?
        // 不包含customer_id条件
    }
    
    @Test
    @Ignore("Requires database setup")
    public void testDynamicSqlWithOrderBy() {
        // 测试动态ORDER BY拼接
        RuleConfig rule = new RuleConfig();
        rule.setRuleCode("ORDERED_QUERY");
        rule.setRuleName("排序查询");
        rule.setRuleType(RuleType.SQL_QUERY);
        rule.setRuleContent("SELECT * FROM products WHERE category = ?");
        
        Map<String, Object> ruleParams = new HashMap<>();
        ruleParams.put("inputs", Arrays.asList("category"));
        
        Map<String, Object> dynamicSql = new HashMap<>();
        dynamicSql.put("orderBy", "price");
        dynamicSql.put("orderDirection", "DESC");
        ruleParams.put("dynamicSql", dynamicSql);
        
        rule.setRuleParams(ruleParams);
        
        Map<String, Object> params = new HashMap<>();
        params.put("category", "electronics");
        
        RuleContext context = new RuleContext(params);
        context = ruleEngine.executeRule(rule, context);
        
        assertTrue(context.isSuccess());
        // 应该执行: SELECT * FROM products WHERE category = ? ORDER BY price DESC
    }
    
    @Test
    @Ignore("Requires database setup")
    public void testDynamicSqlWithLimit() {
        // 测试动态LIMIT拼接
        RuleConfig rule = new RuleConfig();
        rule.setRuleCode("LIMITED_QUERY");
        rule.setRuleName("限制结果查询");
        rule.setRuleType(RuleType.SQL_QUERY);
        rule.setRuleContent("SELECT * FROM products");
        
        Map<String, Object> ruleParams = new HashMap<>();
        Map<String, Object> dynamicSql = new HashMap<>();
        dynamicSql.put("limit", 10);
        ruleParams.put("dynamicSql", dynamicSql);
        
        rule.setRuleParams(ruleParams);
        
        Map<String, Object> params = new HashMap<>();
        RuleContext context = new RuleContext(params);
        context = ruleEngine.executeRule(rule, context);
        
        assertTrue(context.isSuccess());
        // 应该执行: SELECT * FROM products LIMIT 10
    }
    
    @Test
    @Ignore("Requires database setup")
    public void testComplexDynamicSql() {
        // 测试复杂的动态SQL（WHERE + ORDER BY + LIMIT）
        RuleConfig rule = new RuleConfig();
        rule.setRuleCode("COMPLEX_QUERY");
        rule.setRuleName("复杂动态查询");
        rule.setRuleType(RuleType.SQL_QUERY);
        rule.setRuleContent("SELECT * FROM products");
        
        Map<String, Object> ruleParams = new HashMap<>();
        Map<String, Object> dynamicSql = new HashMap<>();
        
        // WHERE条件
        List<Map<String, Object>> conditions = new ArrayList<>();
        Map<String, Object> condition = new HashMap<>();
        condition.put("field", "category");
        condition.put("operator", "=");
        condition.put("paramName", "category");
        conditions.add(condition);
        dynamicSql.put("whereConditions", conditions);
        
        // ORDER BY
        dynamicSql.put("orderBy", "price");
        dynamicSql.put("orderDirection", "ASC");
        
        // LIMIT
        dynamicSql.put("limit", 5);
        
        ruleParams.put("dynamicSql", dynamicSql);
        rule.setRuleParams(ruleParams);
        
        Map<String, Object> params = new HashMap<>();
        params.put("category", "books");
        
        RuleContext context = new RuleContext(params);
        context = ruleEngine.executeRule(rule, context);
        
        assertTrue(context.isSuccess());
        // 应该执行: SELECT * FROM products WHERE category = ? ORDER BY price ASC LIMIT 5
    }
    
    @Test
    public void testDynamicSqlConfigParsing() {
        // 测试动态SQL配置解析（不需要数据库）
        RuleConfig rule = new RuleConfig();
        rule.setRuleCode("CONFIG_TEST");
        rule.setRuleName("配置测试");
        rule.setRuleType(RuleType.SQL_QUERY);
        rule.setRuleContent("SELECT * FROM test_table");
        
        Map<String, Object> ruleParams = new HashMap<>();
        Map<String, Object> dynamicSql = new HashMap<>();
        
        List<Map<String, Object>> conditions = new ArrayList<>();
        Map<String, Object> condition = new HashMap<>();
        condition.put("field", "name");
        condition.put("operator", "LIKE");
        condition.put("paramName", "searchName");
        conditions.add(condition);
        
        dynamicSql.put("whereConditions", conditions);
        dynamicSql.put("orderBy", "created_at");
        dynamicSql.put("orderDirection", "DESC");
        dynamicSql.put("limit", 20);
        
        ruleParams.put("dynamicSql", dynamicSql);
        rule.setRuleParams(ruleParams);
        
        // 验证配置正确设置
        assertNotNull(rule.getRuleParams());
        assertTrue(rule.getRuleParams().containsKey("dynamicSql"));
        
        @SuppressWarnings("unchecked")
        Map<String, Object> parsedDynamicSql = (Map<String, Object>) rule.getRuleParams().get("dynamicSql");
        assertNotNull(parsedDynamicSql);
        assertTrue(parsedDynamicSql.containsKey("whereConditions"));
        assertEquals("created_at", parsedDynamicSql.get("orderBy"));
        assertEquals("DESC", parsedDynamicSql.get("orderDirection"));
        assertEquals(20, parsedDynamicSql.get("limit"));
    }
}
