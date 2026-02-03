package com.buyi.datawarehouse.monitoring;

import com.buyi.datawarehouse.enums.BusinessMode;
import com.buyi.datawarehouse.enums.RiskLevel;
import org.junit.Test;

import static org.junit.Assert.*;

/**
 * 业务模式和风险等级枚举测试
 * Business Mode and Risk Level Enum Test
 */
public class EnumTest {
    
    @Test
    public void testBusinessModeEnum() {
        // 测试枚举值
        assertEquals("JH", BusinessMode.JH.getCode());
        assertEquals("LX", BusinessMode.LX.getCode());
        assertEquals("FBA", BusinessMode.FBA.getCode());
        assertEquals("JH_LX", BusinessMode.JH_LX.getCode());
        
        // 测试枚举名称
        assertEquals("聚合模式", BusinessMode.JH.getName());
        assertEquals("零星模式", BusinessMode.LX.getName());
        assertEquals("FBA模式", BusinessMode.FBA.getName());
    }
    
    @Test
    public void testBusinessModeFromCode() {
        // 测试从代码获取枚举
        assertEquals(BusinessMode.JH, BusinessMode.fromCode("JH"));
        assertEquals(BusinessMode.LX, BusinessMode.fromCode("LX"));
        assertEquals(BusinessMode.FBA, BusinessMode.fromCode("FBA"));
        assertEquals(BusinessMode.JH_LX, BusinessMode.fromCode("JH_LX"));
        
        // 测试null
        assertNull(BusinessMode.fromCode(null));
        
        // 测试无效代码
        try {
            BusinessMode.fromCode("INVALID");
            fail("应该抛出IllegalArgumentException");
        } catch (IllegalArgumentException e) {
            assertTrue(e.getMessage().contains("Unknown business mode code"));
        }
    }
    
    @Test
    public void testBusinessModeIsFBA() {
        assertTrue(BusinessMode.FBA.isFBA());
        assertFalse(BusinessMode.JH.isFBA());
        assertFalse(BusinessMode.LX.isFBA());
        assertFalse(BusinessMode.JH_LX.isFBA());
    }
    
    @Test
    public void testBusinessModeIsJHOrLX() {
        assertTrue(BusinessMode.JH.isJHOrLX());
        assertTrue(BusinessMode.LX.isJHOrLX());
        assertFalse(BusinessMode.FBA.isJHOrLX());
        assertFalse(BusinessMode.JH_LX.isJHOrLX());
    }
    
    @Test
    public void testBusinessModeToMergedMode() {
        // JH和LX应该转换为JH_LX
        assertEquals(BusinessMode.JH_LX, BusinessMode.JH.toMergedMode());
        assertEquals(BusinessMode.JH_LX, BusinessMode.LX.toMergedMode());
        
        // FBA和JH_LX保持不变
        assertEquals(BusinessMode.FBA, BusinessMode.FBA.toMergedMode());
        assertEquals(BusinessMode.JH_LX, BusinessMode.JH_LX.toMergedMode());
    }
    
    @Test
    public void testRiskLevelEnum() {
        // 测试枚举值
        assertEquals("SAFE", RiskLevel.SAFE.getCode());
        assertEquals("WARNING", RiskLevel.WARNING.getCode());
        assertEquals("DANGER", RiskLevel.DANGER.getCode());
        assertEquals("STOCKOUT", RiskLevel.STOCKOUT.getCode());
        
        // 测试枚举名称
        assertEquals("安全", RiskLevel.SAFE.getName());
        assertEquals("预警", RiskLevel.WARNING.getName());
        assertEquals("危险", RiskLevel.DANGER.getName());
        assertEquals("已断货", RiskLevel.STOCKOUT.getName());
    }
    
    @Test
    public void testRiskLevelFromCode() {
        // 测试从代码获取枚举
        assertEquals(RiskLevel.SAFE, RiskLevel.fromCode("SAFE"));
        assertEquals(RiskLevel.WARNING, RiskLevel.fromCode("WARNING"));
        assertEquals(RiskLevel.DANGER, RiskLevel.fromCode("DANGER"));
        assertEquals(RiskLevel.STOCKOUT, RiskLevel.fromCode("STOCKOUT"));
        
        // 测试null
        assertNull(RiskLevel.fromCode(null));
    }
    
    @Test
    public void testRiskLevelCalculation() {
        int safetyStockDays = 30;
        
        // 测试库存为0，应该是STOCKOUT
        assertEquals(RiskLevel.STOCKOUT, RiskLevel.calculateRiskLevel(0, safetyStockDays));
        
        // 测试库存小于安全库存的一半，应该是DANGER
        assertEquals(RiskLevel.DANGER, RiskLevel.calculateRiskLevel(10, safetyStockDays));
        
        // 测试库存在安全库存一半到安全库存之间，应该是WARNING
        assertEquals(RiskLevel.WARNING, RiskLevel.calculateRiskLevel(20, safetyStockDays));
        
        // 测试库存大于等于安全库存，应该是SAFE
        assertEquals(RiskLevel.SAFE, RiskLevel.calculateRiskLevel(30, safetyStockDays));
        assertEquals(RiskLevel.SAFE, RiskLevel.calculateRiskLevel(50, safetyStockDays));
    }
    
    @Test
    public void testRiskLevelBoundaryConditions() {
        int safetyStockDays = 30;
        
        // 边界条件测试
        assertEquals(RiskLevel.STOCKOUT, RiskLevel.calculateRiskLevel(0.0, safetyStockDays));
        assertEquals(RiskLevel.DANGER, RiskLevel.calculateRiskLevel(14.9, safetyStockDays));
        assertEquals(RiskLevel.DANGER, RiskLevel.calculateRiskLevel(15.0, safetyStockDays));
        assertEquals(RiskLevel.WARNING, RiskLevel.calculateRiskLevel(15.1, safetyStockDays));
        assertEquals(RiskLevel.WARNING, RiskLevel.calculateRiskLevel(29.9, safetyStockDays));
        assertEquals(RiskLevel.SAFE, RiskLevel.calculateRiskLevel(30.0, safetyStockDays));
    }
}
