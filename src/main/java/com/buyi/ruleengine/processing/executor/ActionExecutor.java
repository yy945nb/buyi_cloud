package com.buyi.ruleengine.processing.executor;

import com.buyi.ruleengine.processing.model.ProcessingAction;
import com.buyi.ruleengine.processing.model.ProcessingContext;

/**
 * 动作执行器接口
 * Action Executor Interface
 */
public interface ActionExecutor {
    
    /**
     * 执行动作
     * Execute action
     * 
     * @param action 动作配置
     * @param context 执行上下文
     * @return 执行结果
     */
    ActionResult execute(ProcessingAction action, ProcessingContext context);
    
    /**
     * 检查是否支持该动作类型
     * Check if this executor supports the given action type
     * 
     * @param actionType 动作类型
     * @return 是否支持
     */
    boolean supports(ProcessingAction.ActionType actionType);
    
    /**
     * 动作执行结果
     */
    class ActionResult {
        private boolean success;
        private Object result;
        private String errorMessage;
        private long executionTime;
        
        public ActionResult() {
        }
        
        public ActionResult(boolean success, Object result) {
            this.success = success;
            this.result = result;
        }
        
        public static ActionResult success(Object result) {
            ActionResult ar = new ActionResult();
            ar.setSuccess(true);
            ar.setResult(result);
            return ar;
        }
        
        public static ActionResult failure(String errorMessage) {
            ActionResult ar = new ActionResult();
            ar.setSuccess(false);
            ar.setErrorMessage(errorMessage);
            return ar;
        }
        
        public boolean isSuccess() {
            return success;
        }
        
        public void setSuccess(boolean success) {
            this.success = success;
        }
        
        public Object getResult() {
            return result;
        }
        
        public void setResult(Object result) {
            this.result = result;
        }
        
        public String getErrorMessage() {
            return errorMessage;
        }
        
        public void setErrorMessage(String errorMessage) {
            this.errorMessage = errorMessage;
        }
        
        public long getExecutionTime() {
            return executionTime;
        }
        
        public void setExecutionTime(long executionTime) {
            this.executionTime = executionTime;
        }
        
        @Override
        public String toString() {
            return "ActionResult{" +
                    "success=" + success +
                    ", result=" + result +
                    ", errorMessage='" + errorMessage + '\'' +
                    '}';
        }
    }
}
