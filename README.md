# Buyi Cloud - 跨境电商平台

## 项目简介 (Project Overview)

Buyi Cloud是一个跨境电商平台项目，包含以下核心功能：

1. **规则引擎 (Rule Engine)** - 灵活的业务规则执行框架，支持Java表达式、SQL查询、API调用
2. **SKU标签系统 (SKU Tagging System)** - 商品标签管理系统，支持规则自动打标和人工打标
3. **数据仓库 (Data Warehouse)** - 私有化部署的数据仓库解决方案，支持OLAP多维分析
4. **产品断货点监控模型 (Product Stockout Monitoring)** - 产品级别断货点监控，整合国内仓库存数据

## 主要功能模块 (Main Features)

### 1. 规则引擎 (Rule Engine)

详细文档请参考：[RULE_ENGINE_README.md](RULE_ENGINE_README.md)

- ✅ 支持Java表达式、SQL查询、API调用三种规则类型
- ✅ 流程编排与条件执行
- ✅ 优先级排序与动态SQL
- ✅ JSON配置加载

### 2. SKU标签系统 (SKU Tagging System)

详细文档请参考：[SKU_TAGGING_GUIDE.md](SKU_TAGGING_GUIDE.md)

- ✅ 标签元数据管理（标签组、标签值）
- ✅ 规则引擎自动打标（支持优先级、版本控制）
- ✅ 人工打标与覆盖（支持原因、有效期）
- ✅ 完整的历史审计追溯
- ✅ 批量处理与查询API
- ✅ 货盘S/A/B/C等级标签示例

### 3. 数据仓库 (Data Warehouse)

详细文档请参考：[DATA_WAREHOUSE_GUIDE.md](DATA_WAREHOUSE_GUIDE.md)

- ✅ 维度建模（时间、商品、店铺、仓库、地区）
- ✅ 事实表设计（销售事实、库存事实、采购事实）
- ✅ ETL数据处理（抽取、转换、加载）
- ✅ 聚合表支持（日/周/月汇总）
- ✅ OLAP多维分析（切片、切块、钻取、旋转）
- ✅ 定时同步调度
- ✅ SCD Type 2 缓慢变化维度支持

### 4. 产品断货点监控模型 (Product Stockout Monitoring)

详细文档请参考：[PRODUCT_STOCKOUT_MONITOR_GUIDE.md](PRODUCT_STOCKOUT_MONITOR_GUIDE.md)

- ✅ 产品级别（SPU）断货监控快照
- ✅ 整合国内仓余单/实物库存数据
- ✅ local_sku到产品SKU自动映射
- ✅ 聚合SKU级别监控数据到产品级别
- ✅ 风险等级评估（0-4级）
- ✅ 智能补货建议（直补量、生产量）
- ✅ 幂等存储过程，支持定时调度
- ✅ 覆盖天数和断货日期预测

## 快速开始 (Quick Start)

### 1. 环境要求

- Java 1.8+
- Maven 3.x
- MySQL 8.0+

### 2. 编译项目

```bash
mvn clean compile
```

### 3. 运行测试

```bash
mvn test
```

### 4. 初始化数据库

```bash
# 创建规则引擎表
mysql -u username -p database < rule_engine_schema.sql

# 创建SKU标签系统表（包含货盘等级示例数据）
mysql -u username -p database < sku_tag_schema.sql

# 创建数据仓库表
mysql -u username -p datawarehouse < datawarehouse_schema.sql

# 创建产品断货点监控模型表
mysql -u username -p database < product_stockout_monitor_schema.sql
```

### 5. 运行示例

```bash
# 运行规则引擎示例
mvn exec:java -Dexec.mainClass="com.buyi.ruleengine.RuleEngineExample"

# 运行SKU标签系统示例
mvn exec:java -Dexec.mainClass="com.buyi.sku.tag.SkuTaggingExample"

# 运行数据仓库示例
mvn exec:java -Dexec.mainClass="com.buyi.datawarehouse.DataWarehouseDemo"
```

## 项目结构 (Project Structure)

```
buyi_cloud/
├── src/main/java/com/buyi/
│   ├── ruleengine/          # 规则引擎模块
│   │   ├── model/           # 规则模型
│   │   ├── service/         # 规则服务
│   │   ├── executor/        # 规则执行器
│   │   └── enums/           # 枚举类型
│   ├── sku/tag/             # SKU标签系统模块
│   │   ├── model/           # 标签模型
│   │   ├── service/         # 标签服务
│   │   └── enums/           # 枚举类型
│   └── datawarehouse/       # 数据仓库模块
│       ├── model/           # 数仓模型（维度表、事实表、聚合表）
│       ├── service/         # ETL和OLAP服务
│       ├── config/          # 配置
│       └── scheduler/       # 调度器
├── src/test/java/           # 测试代码
├── rule_engine_schema.sql   # 规则引擎数据库表
├── sku_tag_schema.sql       # SKU标签系统数据库表
├── datawarehouse_schema.sql # 数据仓库数据库表
├── RULE_ENGINE_README.md    # 规则引擎文档
├── SKU_TAGGING_GUIDE.md     # SKU标签系统文档
└── DATA_WAREHOUSE_GUIDE.md  # 数据仓库文档
```

## 核心概念 (Core Concepts)

### 规则引擎 (Rule Engine)

规则引擎提供了一个灵活的框架来定义和执行业务规则：

- **规则类型**：Java表达式（JEXL）、SQL查询、API调用
- **流程编排**：支持多步骤规则流程，条件跳转
- **优先级排序**：支持规则优先级，自动排序执行

### SKU标签系统 (SKU Tagging System)

SKU标签系统为商品提供灵活的分类和标记能力：

- **标签组**：定义标签分类（如：货盘等级、促销类型等）
- **标签值**：每个标签组下的具体标签值（如：S/A/B/C级）
- **自动打标**：基于规则引擎自动为SKU打标签
- **人工打标**：支持人工覆盖自动标签，记录原因
- **优先级策略**：人工标签优先级高于规则标签

## 使用案例 (Use Cases)

### 1. 货盘等级自动分类

系统预置了货盘S/A/B/C等级标签，基于销量、利润率、周转天数自动分类：

```java
// S级货盘: 销量>=1000且利润率>=30%且周转天数<=15天
// A级货盘: 销量>=500且利润率>=20%且周转天数<=30天
// B级货盘: 销量>=100且利润率>=10%且周转天数<=60天
// C级货盘: 销量<100或利润率<10%或周转天数>60天
```

### 2. 备货系统集成

下游备货系统可通过标签查询API获取商品等级，制定不同的备货策略：

```java
// 查询S级和A级货盘用于优先备货
TagQueryService queryService = new TagQueryService(tagService);
List<SkuTagResult> highGradeSku = queryService.querySkusByGrade("S", "A");
```

### 3. 促销系统集成

促销系统可查询C级货盘商品，创建清库存促销活动：

```java
// 查询C级货盘用于促销清库存
List<SkuTagResult> lowGradeSku = queryService.querySkusByGrade("C");
```

## 测试覆盖 (Test Coverage)

- ✅ 规则引擎测试：24个测试用例
- ✅ SKU标签系统测试：16个测试用例
- ✅ 数据仓库测试：18个测试用例
- ✅ 总计：58个测试用例

```bash
[INFO] Results:
[INFO] 
[WARNING] Tests run: 40, Failures: 0, Errors: 0, Skipped: 6
[INFO] 
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
```

## 技术栈 (Tech Stack)

- **语言**: Java 1.8
- **构建工具**: Maven 3.x
- **数据库**: MySQL 8.0
- **规则引擎**: Apache Commons JEXL 3.3
- **HTTP客户端**: Apache HttpClient 4.5.14
- **JSON处理**: Gson 2.10.1
- **日志框架**: SLF4J + Logback
- **测试框架**: JUnit 4.13.2

## 文档资源 (Documentation)

- [规则引擎开发文档](RULE_ENGINE_README.md)
- [规则引擎JSON功能指南](JSON_FEATURES_GUIDE.md)
- [SKU标签系统开发文档](SKU_TAGGING_GUIDE.md)
- [数据仓库部署指南](DATA_WAREHOUSE_GUIDE.md)
- [产品断货点监控模型指南](PRODUCT_STOCKOUT_MONITOR_GUIDE.md)

## 贡献指南 (Contributing)

欢迎提交Issue和Pull Request来改进项目。

## 许可证 (License)

本项目为Buyi Cloud项目的一部分，遵循项目统一许可证。

## 联系方式 (Contact)

如有问题或建议，请通过GitHub Issue反馈。