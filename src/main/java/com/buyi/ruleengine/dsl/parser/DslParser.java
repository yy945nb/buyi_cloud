package com.buyi.ruleengine.dsl.parser;

import com.buyi.ruleengine.dsl.model.DslNode;
import com.buyi.ruleengine.dsl.model.DslRuleChain;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * DSL解析器 - 解析规则链DSL文本
 * DSL Parser - Parses rule chain DSL text into model objects
 * 
 * DSL语法示例:
 * <pre>
 * chain {
 *     id: "order_processing"
 *     name: "订单处理流程"
 *     version: "1.0.0"
 *     
 *     config {
 *         maxDepth: 100
 *         executionTimeout: 60000
 *     }
 *     
 *     start -> checkStock
 *     
 *     node checkStock {
 *         type: rule
 *         expression: `stock >= quantity`
 *         output: "hasStock"
 *         next: calculatePrice
 *     }
 *     
 *     node calculatePrice {
 *         type: rule
 *         expression: `price * quantity * (1 - discount/100)`
 *         output: "totalPrice"
 *     }
 *     
 *     condition checkVip {
 *         expression: `isVip == true`
 *         then: applyVipDiscount
 *         else: normalProcess
 *     }
 *     
 *     end
 * }
 * </pre>
 */
public class DslParser {
    
    private static final Logger logger = LoggerFactory.getLogger(DslParser.class);
    
    // 正则表达式模式
    private static final Pattern CHAIN_PATTERN = Pattern.compile(
            "chain\\s*\\{", Pattern.MULTILINE);
    private static final Pattern PROPERTY_PATTERN = Pattern.compile(
            "^\\s*(\\w+)\\s*:\\s*(.+)$", Pattern.MULTILINE);
    private static final Pattern NODE_PATTERN = Pattern.compile(
            "node\\s+(\\w+)\\s*\\{", Pattern.MULTILINE);
    private static final Pattern CONDITION_PATTERN = Pattern.compile(
            "condition\\s+(\\w+)\\s*\\{", Pattern.MULTILINE);
    private static final Pattern FORK_PATTERN = Pattern.compile(
            "fork\\s+(\\w+)\\s*\\{", Pattern.MULTILINE);
    private static final Pattern JOIN_PATTERN = Pattern.compile(
            "join\\s+(\\w+)\\s*\\{", Pattern.MULTILINE);
    private static final Pattern START_ARROW_PATTERN = Pattern.compile(
            "start\\s*->\\s*(\\w+)", Pattern.MULTILINE);
    private static final Pattern CONFIG_PATTERN = Pattern.compile(
            "config\\s*\\{", Pattern.MULTILINE);
    private static final Pattern STRING_VALUE_PATTERN = Pattern.compile(
            "^[\"'`](.+)[\"'`]$");
    private static final Pattern ARRAY_PATTERN = Pattern.compile(
            "\\[\\s*(.*)\\s*\\]");
    
    private String input;
    private int position;
    private int lineNumber;
    private int columnNumber;
    
    /**
     * 从文件解析DSL
     * Parse DSL from file
     * 
     * @param filePath 文件路径
     * @return 规则链对象
     * @throws IOException 文件读取异常
     * @throws DslParseException 解析异常
     */
    public DslRuleChain parseFile(String filePath) throws IOException {
        logger.info("Parsing DSL from file: {}", filePath);
        String content = new String(Files.readAllBytes(Paths.get(filePath)), StandardCharsets.UTF_8);
        return parse(content);
    }
    
    /**
     * 解析DSL字符串
     * Parse DSL string
     * 
     * @param dslText DSL文本
     * @return 规则链对象
     * @throws DslParseException 解析异常
     */
    public DslRuleChain parse(String dslText) {
        if (dslText == null || dslText.trim().isEmpty()) {
            throw new DslParseException("DSL text cannot be null or empty");
        }
        
        logger.debug("Parsing DSL text ({} characters)", dslText.length());
        
        // 预处理：移除注释
        this.input = removeComments(dslText);
        this.position = 0;
        this.lineNumber = 1;
        this.columnNumber = 1;
        
        DslRuleChain chain = new DslRuleChain();
        
        try {
            // 查找chain块
            skipWhitespace();
            if (!matchKeyword(DslTokens.CHAIN)) {
                throw new DslParseException("DSL must start with 'chain' keyword", lineNumber);
            }
            
            skipWhitespace();
            expect('{');
            
            // 解析chain内容
            parseChainContent(chain);
            
            expect('}');
            
            // 验证规则链
            validateChain(chain);
            
            logger.info("Successfully parsed rule chain: {} with {} nodes", 
                    chain.getChainId(), chain.getNodeList().size());
            
        } catch (DslParseException e) {
            throw e;
        } catch (Exception e) {
            throw new DslParseException("Unexpected error during parsing: " + e.getMessage(), 
                    lineNumber, e);
        }
        
        return chain;
    }
    
    /**
     * 移除注释
     */
    private String removeComments(String text) {
        StringBuilder result = new StringBuilder();
        boolean inString = false;
        boolean inBacktick = false;
        char stringChar = 0;
        int i = 0;
        
        while (i < text.length()) {
            char c = text.charAt(i);
            
            // 处理字符串
            if (!inString && !inBacktick && (c == '"' || c == '\'')) {
                inString = true;
                stringChar = c;
                result.append(c);
                i++;
            } else if (inString && c == stringChar) {
                inString = false;
                result.append(c);
                i++;
            } else if (!inString && !inBacktick && c == '`') {
                inBacktick = true;
                result.append(c);
                i++;
            } else if (inBacktick && c == '`') {
                inBacktick = false;
                result.append(c);
                i++;
            } else if (!inString && !inBacktick) {
                // 检查单行注释
                if (i + 1 < text.length() && c == '/' && text.charAt(i + 1) == '/') {
                    // 跳过到行末
                    while (i < text.length() && text.charAt(i) != '\n') {
                        i++;
                    }
                }
                // 检查块注释
                else if (i + 1 < text.length() && c == '/' && text.charAt(i + 1) == '*') {
                    i += 2;
                    while (i + 1 < text.length() && !(text.charAt(i) == '*' && text.charAt(i + 1) == '/')) {
                        if (text.charAt(i) == '\n') {
                            result.append('\n'); // 保持行号
                        }
                        i++;
                    }
                    i += 2; // 跳过 */
                }
                // 检查 # 注释
                else if (c == '#') {
                    while (i < text.length() && text.charAt(i) != '\n') {
                        i++;
                    }
                }
                else {
                    result.append(c);
                    i++;
                }
            } else {
                result.append(c);
                i++;
            }
        }
        
        return result.toString();
    }
    
    /**
     * 解析chain内容
     */
    private void parseChainContent(DslRuleChain chain) {
        while (position < input.length()) {
            skipWhitespace();
            
            if (peek() == '}') {
                break;
            }
            
            // 解析属性或节点
            String identifier = readIdentifier();
            if (identifier == null) {
                break;
            }
            
            skipWhitespace();
            
            switch (identifier.toLowerCase()) {
                case DslTokens.ID:
                    expect(':');
                    chain.setChainId(parseStringValue());
                    break;
                    
                case DslTokens.NAME:
                    expect(':');
                    chain.setChainName(parseStringValue());
                    break;
                    
                case DslTokens.VERSION:
                    expect(':');
                    chain.setVersion(parseStringValue());
                    break;
                    
                case DslTokens.DESCRIPTION:
                    expect(':');
                    chain.setDescription(parseStringValue());
                    break;
                    
                case DslTokens.CONFIG:
                    parseConfig(chain);
                    break;
                    
                case DslTokens.START:
                    parseStartDeclaration(chain);
                    break;
                    
                case DslTokens.NODE:
                    DslNode node = parseNode();
                    chain.addNode(node);
                    break;
                    
                case DslTokens.CONDITION:
                    DslNode condNode = parseConditionNode();
                    chain.addNode(condNode);
                    break;
                    
                case DslTokens.FORK:
                    DslNode forkNode = parseForkNode();
                    chain.addNode(forkNode);
                    break;
                    
                case DslTokens.JOIN:
                    DslNode joinNode = parseJoinNode();
                    chain.addNode(joinNode);
                    break;
                    
                case DslTokens.END:
                    DslNode endNode = parseEndNode(identifier);
                    if (endNode != null) {
                        chain.addNode(endNode);
                    }
                    break;
                    
                default:
                    // 可能是简写形式的节点定义
                    DslNode simpleNode = tryParseSimpleNode(identifier);
                    if (simpleNode != null) {
                        chain.addNode(simpleNode);
                    }
                    break;
            }
        }
    }
    
    /**
     * 解析配置块
     */
    private void parseConfig(DslRuleChain chain) {
        skipWhitespace();
        expect('{');
        
        while (position < input.length()) {
            skipWhitespace();
            
            if (peek() == '}') {
                break;
            }
            
            String key = readIdentifier();
            if (key == null) {
                break;
            }
            
            skipWhitespace();
            expect(':');
            skipWhitespace();
            
            switch (key.toLowerCase()) {
                case DslTokens.MAX_DEPTH:
                case "maxdepth":
                    chain.setMaxExecutionDepth(parseIntValue());
                    break;
                    
                case DslTokens.EXECUTION_TIMEOUT:
                case "executiontimeout":
                    chain.setExecutionTimeout(parseLongValue());
                    break;
                    
                case DslTokens.ENABLE_LOGGING:
                case "enablelogging":
                    chain.setEnableLogging(parseBooleanValue());
                    break;
                    
                default:
                    // 跳过未知配置
                    parseValue();
                    break;
            }
        }
        
        expect('}');
    }
    
    /**
     * 解析start声明
     */
    private void parseStartDeclaration(DslRuleChain chain) {
        skipWhitespace();
        
        // 检查是否是 start -> nodeId 形式
        if (peek() == '-') {
            advance(); // skip -
            if (peek() == '>') {
                advance(); // skip >
                skipWhitespace();
                String startNodeId = readIdentifier();
                if (startNodeId != null) {
                    chain.setStartNodeId(startNodeId);
                    
                    // 创建隐式开始节点
                    DslNode startNode = new DslNode();
                    startNode.setNodeId(DslTokens.INTERNAL_START_NODE_ID);
                    startNode.setNodeName("Start");
                    startNode.setNodeType(DslNode.NodeType.START);
                    startNode.setNextNodeId(startNodeId);
                    chain.addNode(startNode);
                }
            }
        } else if (peek() == '{') {
            // start { ... } 形式
            DslNode startNode = parseStartNode();
            chain.addNode(startNode);
            chain.setStartNodeId(startNode.getNodeId());
        }
    }
    
    /**
     * 解析start节点
     */
    private DslNode parseStartNode() {
        DslNode node = new DslNode();
        node.setNodeType(DslNode.NodeType.START);
        node.setNodeId(DslTokens.INTERNAL_START_NODE_ID);
        node.setNodeName("Start");
        
        skipWhitespace();
        if (peek() == '{') {
            expect('{');
            parseNodeProperties(node);
            expect('}');
        }
        
        return node;
    }
    
    /**
     * 解析end节点
     */
    private DslNode parseEndNode(String identifier) {
        DslNode node = new DslNode();
        node.setNodeType(DslNode.NodeType.END);
        node.setNodeId(DslTokens.INTERNAL_END_NODE_ID);
        node.setNodeName("End");
        
        skipWhitespace();
        if (peek() == '{') {
            expect('{');
            parseNodeProperties(node);
            expect('}');
        }
        
        return node;
    }
    
    /**
     * 解析普通节点
     */
    private DslNode parseNode() {
        skipWhitespace();
        String nodeId = readIdentifier();
        if (nodeId == null) {
            throw new DslParseException("Expected node identifier", lineNumber);
        }
        
        DslNode node = new DslNode();
        node.setNodeId(nodeId);
        node.setNodeName(nodeId);
        node.setNodeType(DslNode.NodeType.RULE);
        
        skipWhitespace();
        expect('{');
        parseNodeProperties(node);
        expect('}');
        
        return node;
    }
    
    /**
     * 解析条件节点
     */
    private DslNode parseConditionNode() {
        skipWhitespace();
        String nodeId = readIdentifier();
        if (nodeId == null) {
            throw new DslParseException("Expected condition node identifier", lineNumber);
        }
        
        DslNode node = new DslNode();
        node.setNodeId(nodeId);
        node.setNodeName(nodeId);
        node.setNodeType(DslNode.NodeType.CONDITION);
        
        skipWhitespace();
        expect('{');
        parseNodeProperties(node);
        expect('}');
        
        return node;
    }
    
    /**
     * 解析分支节点
     */
    private DslNode parseForkNode() {
        skipWhitespace();
        String nodeId = readIdentifier();
        if (nodeId == null) {
            throw new DslParseException("Expected fork node identifier", lineNumber);
        }
        
        DslNode node = new DslNode();
        node.setNodeId(nodeId);
        node.setNodeName(nodeId);
        node.setNodeType(DslNode.NodeType.FORK);
        
        skipWhitespace();
        expect('{');
        parseNodeProperties(node);
        expect('}');
        
        return node;
    }
    
    /**
     * 解析合并节点
     */
    private DslNode parseJoinNode() {
        skipWhitespace();
        String nodeId = readIdentifier();
        if (nodeId == null) {
            throw new DslParseException("Expected join node identifier", lineNumber);
        }
        
        DslNode node = new DslNode();
        node.setNodeId(nodeId);
        node.setNodeName(nodeId);
        node.setNodeType(DslNode.NodeType.JOIN);
        
        skipWhitespace();
        expect('{');
        parseNodeProperties(node);
        expect('}');
        
        return node;
    }
    
    /**
     * 尝试解析简写形式的节点
     */
    private DslNode tryParseSimpleNode(String identifier) {
        skipWhitespace();
        
        // identifier -> nextNode 形式
        if (peek() == '-') {
            advance();
            if (peek() == '>') {
                advance();
                skipWhitespace();
                String nextNodeId = readIdentifier();
                
                DslNode node = new DslNode();
                node.setNodeId(identifier);
                node.setNodeName(identifier);
                node.setNodeType(DslNode.NodeType.RULE);
                node.setNextNodeId(nextNodeId);
                
                return node;
            }
        }
        
        return null;
    }
    
    /**
     * 解析节点属性
     */
    private void parseNodeProperties(DslNode node) {
        while (position < input.length()) {
            skipWhitespace();
            
            if (peek() == '}') {
                break;
            }
            
            String key = readIdentifier();
            if (key == null) {
                break;
            }
            
            skipWhitespace();
            
            // 特殊处理 params 块（可以不带冒号）
            if (DslTokens.PARAMS.equalsIgnoreCase(key) && peek() == '{') {
                node.setParams(parseParamsBlock());
                continue;
            }
            
            expect(':');
            skipWhitespace();
            
            switch (key.toLowerCase()) {
                case DslTokens.ID:
                    node.setNodeId(parseStringValue());
                    break;
                    
                case DslTokens.NAME:
                    node.setNodeName(parseStringValue());
                    break;
                    
                case "type":
                    String typeStr = parseStringOrIdentifier();
                    node.setNodeType(parseNodeType(typeStr));
                    break;
                    
                case DslTokens.EXPRESSION:
                    node.setExpression(parseExpressionValue());
                    break;
                    
                case DslTokens.CONDITION:
                    node.setCondition(parseExpressionValue());
                    break;
                    
                case DslTokens.NEXT:
                    node.setNextNodeId(parseStringOrIdentifier());
                    break;
                    
                case DslTokens.THEN:
                    node.setTrueNodeId(parseStringOrIdentifier());
                    break;
                    
                case DslTokens.ELSE:
                    node.setFalseNodeId(parseStringOrIdentifier());
                    break;
                    
                case DslTokens.BRANCHES:
                    List<String> branches = parseStringArray();
                    node.setBranchNodeIds(branches);
                    break;
                    
                case DslTokens.WAIT_FOR:
                case "waitfor":
                    List<String> waitFor = parseStringArray();
                    node.setWaitForNodeIds(waitFor);
                    break;
                    
                case DslTokens.OUTPUT:
                    node.setOutputVariable(parseStringOrIdentifier());
                    break;
                    
                case DslTokens.DESCRIPTION:
                    node.setDescription(parseStringValue());
                    break;
                    
                case DslTokens.TIMEOUT:
                    node.setTimeout(parseLongValue());
                    break;
                    
                case DslTokens.RETRY:
                    node.setRetryCount(parseIntValue());
                    break;
                    
                case DslTokens.ON_ERROR:
                case "onerror":
                    String onError = parseStringOrIdentifier();
                    node.setContinueOnError(DslTokens.CONTINUE.equalsIgnoreCase(onError));
                    break;
                    
                case DslTokens.PARAMS:
                    node.setParams(parseParamsBlock());
                    break;
                    
                default:
                    // 存储为自定义参数
                    Object value = parseValue();
                    node.setParam(key, value);
                    break;
            }
        }
    }
    
    /**
     * 解析参数块
     */
    private Map<String, Object> parseParamsBlock() {
        Map<String, Object> params = new HashMap<>();
        
        skipWhitespace();
        if (peek() != '{') {
            return params;
        }
        
        expect('{');
        
        while (position < input.length()) {
            skipWhitespace();
            
            if (peek() == '}') {
                break;
            }
            
            String key = readIdentifier();
            if (key == null) {
                break;
            }
            
            skipWhitespace();
            expect(':');
            skipWhitespace();
            
            Object value = parseValue();
            params.put(key, value);
        }
        
        expect('}');
        
        return params;
    }
    
    /**
     * 解析节点类型
     */
    private DslNode.NodeType parseNodeType(String typeStr) {
        if (typeStr == null) {
            return DslNode.NodeType.RULE;
        }
        
        switch (typeStr.toLowerCase()) {
            case "start":
                return DslNode.NodeType.START;
            case "end":
                return DslNode.NodeType.END;
            case "rule":
                return DslNode.NodeType.RULE;
            case "condition":
                return DslNode.NodeType.CONDITION;
            case "fork":
                return DslNode.NodeType.FORK;
            case "join":
                return DslNode.NodeType.JOIN;
            default:
                return DslNode.NodeType.RULE;
        }
    }
    
    /**
     * 解析字符串值
     */
    private String parseStringValue() {
        skipWhitespace();
        char c = peek();
        
        if (c == '"' || c == '\'' || c == '`') {
            return parseQuotedString(c);
        }
        
        // 读取到换行或逗号/分号为止
        return readUntil('\n', ',', ';', '}').trim();
    }
    
    /**
     * 解析表达式值（支持反引号包裹）
     */
    private String parseExpressionValue() {
        skipWhitespace();
        char c = peek();
        
        if (c == '`') {
            return parseQuotedString('`');
        } else if (c == '"' || c == '\'') {
            return parseQuotedString(c);
        }
        
        // 读取到换行或逗号/分号为止
        return readUntil('\n', ',', ';', '}').trim();
    }
    
    /**
     * 解析字符串或标识符
     */
    private String parseStringOrIdentifier() {
        skipWhitespace();
        char c = peek();
        
        if (c == '"' || c == '\'' || c == '`') {
            return parseQuotedString(c);
        }
        
        return readIdentifier();
    }
    
    /**
     * 解析引号字符串
     */
    private String parseQuotedString(char quote) {
        expect(quote);
        StringBuilder sb = new StringBuilder();
        
        while (position < input.length()) {
            char c = advance();
            
            if (c == quote) {
                break;
            }
            
            if (c == '\\' && position < input.length()) {
                char next = advance();
                switch (next) {
                    case 'n':
                        sb.append('\n');
                        break;
                    case 't':
                        sb.append('\t');
                        break;
                    case 'r':
                        sb.append('\r');
                        break;
                    case '\\':
                        sb.append('\\');
                        break;
                    default:
                        sb.append(next);
                        break;
                }
            } else {
                sb.append(c);
            }
        }
        
        return sb.toString();
    }
    
    /**
     * 解析字符串数组
     */
    private List<String> parseStringArray() {
        List<String> result = new ArrayList<>();
        
        skipWhitespace();
        if (peek() != '[') {
            // 单个值
            String value = parseStringOrIdentifier();
            if (value != null && !value.isEmpty()) {
                result.add(value);
            }
            return result;
        }
        
        expect('[');
        
        while (position < input.length()) {
            skipWhitespace();
            
            if (peek() == ']') {
                break;
            }
            
            String value = parseStringOrIdentifier();
            if (value != null && !value.isEmpty()) {
                result.add(value);
            }
            
            skipWhitespace();
            if (peek() == ',') {
                advance();
            }
        }
        
        expect(']');
        
        return result;
    }
    
    /**
     * 解析整数值
     */
    private int parseIntValue() {
        String value = readNumber();
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            throw new DslParseException("Invalid integer value: " + value, lineNumber);
        }
    }
    
    /**
     * 解析长整数值
     */
    private long parseLongValue() {
        String value = readNumber();
        try {
            return Long.parseLong(value);
        } catch (NumberFormatException e) {
            throw new DslParseException("Invalid long value: " + value, lineNumber);
        }
    }
    
    /**
     * 解析布尔值
     */
    private boolean parseBooleanValue() {
        String value = readIdentifier();
        return "true".equalsIgnoreCase(value);
    }
    
    /**
     * 解析通用值
     */
    private Object parseValue() {
        skipWhitespace();
        char c = peek();
        
        if (c == '"' || c == '\'' || c == '`') {
            return parseQuotedString(c);
        }
        
        if (c == '[') {
            return parseStringArray();
        }
        
        if (c == '{') {
            return parseParamsBlock();
        }
        
        if (Character.isDigit(c) || c == '-' || c == '+') {
            String num = readNumber();
            if (num.contains(".")) {
                return Double.parseDouble(num);
            }
            return Long.parseLong(num);
        }
        
        String identifier = readIdentifier();
        if ("true".equalsIgnoreCase(identifier)) {
            return true;
        }
        if ("false".equalsIgnoreCase(identifier)) {
            return false;
        }
        if ("null".equalsIgnoreCase(identifier)) {
            return null;
        }
        
        return identifier;
    }
    
    /**
     * 读取标识符
     */
    private String readIdentifier() {
        skipWhitespace();
        
        if (position >= input.length()) {
            return null;
        }
        
        char c = peek();
        if (!Character.isLetter(c) && c != '_') {
            return null;
        }
        
        StringBuilder sb = new StringBuilder();
        while (position < input.length()) {
            c = peek();
            if (Character.isLetterOrDigit(c) || c == '_') {
                sb.append(advance());
            } else {
                break;
            }
        }
        
        return sb.length() > 0 ? sb.toString() : null;
    }
    
    /**
     * 读取数字
     */
    private String readNumber() {
        skipWhitespace();
        StringBuilder sb = new StringBuilder();
        
        while (position < input.length()) {
            char c = peek();
            if (Character.isDigit(c) || c == '.' || c == '-' || c == '+') {
                sb.append(advance());
            } else {
                break;
            }
        }
        
        return sb.toString();
    }
    
    /**
     * 读取直到指定字符
     */
    private String readUntil(char... terminators) {
        StringBuilder sb = new StringBuilder();
        Set<Character> termSet = new HashSet<>();
        for (char t : terminators) {
            termSet.add(t);
        }
        
        while (position < input.length()) {
            char c = peek();
            if (termSet.contains(c)) {
                break;
            }
            sb.append(advance());
        }
        
        return sb.toString();
    }
    
    /**
     * 跳过空白字符
     */
    private void skipWhitespace() {
        while (position < input.length()) {
            char c = peek();
            if (Character.isWhitespace(c)) {
                if (c == '\n') {
                    lineNumber++;
                    columnNumber = 1;
                } else {
                    columnNumber++;
                }
                position++;
            } else {
                break;
            }
        }
    }
    
    /**
     * 查看当前字符
     */
    private char peek() {
        if (position >= input.length()) {
            return '\0';
        }
        return input.charAt(position);
    }
    
    /**
     * 前进一个字符
     */
    private char advance() {
        char c = input.charAt(position++);
        if (c == '\n') {
            lineNumber++;
            columnNumber = 1;
        } else {
            columnNumber++;
        }
        return c;
    }
    
    /**
     * 期望并消费指定字符
     */
    private void expect(char expected) {
        skipWhitespace();
        if (position >= input.length()) {
            throw new DslParseException("Unexpected end of input, expected '" + expected + "'", 
                    lineNumber, columnNumber);
        }
        char actual = advance();
        if (actual != expected) {
            throw new DslParseException("Expected '" + expected + "' but found '" + actual + "'", 
                    lineNumber, columnNumber);
        }
    }
    
    /**
     * 匹配关键字
     */
    private boolean matchKeyword(String keyword) {
        int savedPos = position;
        int savedLine = lineNumber;
        int savedCol = columnNumber;
        
        String identifier = readIdentifier();
        if (keyword.equals(identifier)) {
            return true;
        }
        
        // 回退
        position = savedPos;
        lineNumber = savedLine;
        columnNumber = savedCol;
        return false;
    }
    
    /**
     * 验证规则链
     */
    private void validateChain(DslRuleChain chain) {
        List<String> errors = new ArrayList<>();
        
        if (chain.getChainId() == null || chain.getChainId().isEmpty()) {
            errors.add("Chain ID is required");
        }
        
        if (chain.getNodeList().isEmpty()) {
            errors.add("Chain must have at least one node");
        }
        
        // 验证节点引用
        for (DslNode node : chain.getNodeList()) {
            if (node.getNextNodeId() != null && !chain.hasNode(node.getNextNodeId()) 
                    && !DslTokens.INTERNAL_END_NODE_ID.equals(node.getNextNodeId())) {
                errors.add("Node '" + node.getNodeId() + "' references non-existent node: " + node.getNextNodeId());
            }
            
            if (node.getTrueNodeId() != null && !chain.hasNode(node.getTrueNodeId())) {
                errors.add("Node '" + node.getNodeId() + "' references non-existent then node: " + node.getTrueNodeId());
            }
            
            if (node.getFalseNodeId() != null && !chain.hasNode(node.getFalseNodeId())) {
                errors.add("Node '" + node.getNodeId() + "' references non-existent else node: " + node.getFalseNodeId());
            }
            
            if (node.getBranchNodeIds() != null) {
                for (String branchId : node.getBranchNodeIds()) {
                    if (!chain.hasNode(branchId)) {
                        errors.add("Node '" + node.getNodeId() + "' references non-existent branch node: " + branchId);
                    }
                }
            }
        }
        
        if (!errors.isEmpty()) {
            throw new DslParseException("Validation failed:\n - " + String.join("\n - ", errors));
        }
    }
}
