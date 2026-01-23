package com.buyi.ruleengine.dsl.parser;

/**
 * DSL语法关键字和标记定义
 * DSL Syntax Keywords and Tokens
 */
public final class DslTokens {
    
    private DslTokens() {
        // Utility class, no instantiation
    }
    
    // 内部节点ID常量 (Internal Node ID Constants)
    public static final String INTERNAL_START_NODE_ID = "_start_";
    public static final String INTERNAL_END_NODE_ID = "_end_";
    
    // 块关键字 (Block Keywords)
    public static final String CHAIN = "chain";
    public static final String NODE = "node";
    public static final String START = "start";
    public static final String END = "end";
    public static final String RULE = "rule";
    public static final String CONDITION = "condition";
    public static final String FORK = "fork";
    public static final String JOIN = "join";
    
    // 属性关键字 (Property Keywords)
    public static final String ID = "id";
    public static final String NAME = "name";
    public static final String VERSION = "version";
    public static final String DESCRIPTION = "description";
    public static final String EXPRESSION = "expression";
    public static final String THEN = "then";
    public static final String ELSE = "else";
    public static final String NEXT = "next";
    public static final String BRANCHES = "branches";
    public static final String WAIT_FOR = "waitFor";
    public static final String OUTPUT = "output";
    public static final String PARAMS = "params";
    public static final String TIMEOUT = "timeout";
    public static final String RETRY = "retry";
    public static final String ON_ERROR = "onError";
    public static final String CONTINUE = "continue";
    public static final String ABORT = "abort";
    
    // 配置关键字 (Config Keywords)
    public static final String CONFIG = "config";
    public static final String MAX_DEPTH = "maxDepth";
    public static final String EXECUTION_TIMEOUT = "executionTimeout";
    public static final String ENABLE_LOGGING = "enableLogging";
    
    // 分隔符 (Delimiters)
    public static final String BLOCK_START = "{";
    public static final String BLOCK_END = "}";
    public static final String ARRAY_START = "[";
    public static final String ARRAY_END = "]";
    public static final String COLON = ":";
    public static final String COMMA = ",";
    public static final String SEMICOLON = ";";
    public static final String ARROW = "->";
    public static final String DOUBLE_ARROW = "=>";
    
    // 引号 (Quotes)
    public static final char DOUBLE_QUOTE = '"';
    public static final char SINGLE_QUOTE = '\'';
    public static final char BACKTICK = '`';
    
    // 注释 (Comments)
    public static final String LINE_COMMENT = "//";
    public static final String BLOCK_COMMENT_START = "/*";
    public static final String BLOCK_COMMENT_END = "*/";
    public static final char HASH_COMMENT = '#';
    
    // 特殊值 (Special Values)
    public static final String TRUE = "true";
    public static final String FALSE = "false";
    public static final String NULL = "null";
}
