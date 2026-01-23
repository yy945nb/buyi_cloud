package com.buyi.ruleengine.dsl.parser;

/**
 * DSL解析异常
 * DSL Parsing Exception
 */
public class DslParseException extends RuntimeException {
    
    private static final long serialVersionUID = 1L;
    
    /**
     * 行号
     */
    private final int lineNumber;
    
    /**
     * 列号
     */
    private final int columnNumber;
    
    /**
     * 错误的文本片段
     */
    private final String snippet;
    
    public DslParseException(String message) {
        super(message);
        this.lineNumber = -1;
        this.columnNumber = -1;
        this.snippet = null;
    }
    
    public DslParseException(String message, int lineNumber) {
        super(formatMessage(message, lineNumber, -1, null));
        this.lineNumber = lineNumber;
        this.columnNumber = -1;
        this.snippet = null;
    }
    
    public DslParseException(String message, int lineNumber, int columnNumber) {
        super(formatMessage(message, lineNumber, columnNumber, null));
        this.lineNumber = lineNumber;
        this.columnNumber = columnNumber;
        this.snippet = null;
    }
    
    public DslParseException(String message, int lineNumber, int columnNumber, String snippet) {
        super(formatMessage(message, lineNumber, columnNumber, snippet));
        this.lineNumber = lineNumber;
        this.columnNumber = columnNumber;
        this.snippet = snippet;
    }
    
    public DslParseException(String message, Throwable cause) {
        super(message, cause);
        this.lineNumber = -1;
        this.columnNumber = -1;
        this.snippet = null;
    }
    
    public DslParseException(String message, int lineNumber, Throwable cause) {
        super(formatMessage(message, lineNumber, -1, null), cause);
        this.lineNumber = lineNumber;
        this.columnNumber = -1;
        this.snippet = null;
    }
    
    private static String formatMessage(String message, int lineNumber, int columnNumber, String snippet) {
        StringBuilder sb = new StringBuilder();
        sb.append("DSL Parse Error");
        
        if (lineNumber >= 0) {
            sb.append(" at line ").append(lineNumber);
            if (columnNumber >= 0) {
                sb.append(", column ").append(columnNumber);
            }
        }
        
        sb.append(": ").append(message);
        
        if (snippet != null && !snippet.isEmpty()) {
            sb.append("\n  Near: ").append(snippet);
        }
        
        return sb.toString();
    }
    
    public int getLineNumber() {
        return lineNumber;
    }
    
    public int getColumnNumber() {
        return columnNumber;
    }
    
    public String getSnippet() {
        return snippet;
    }
}
