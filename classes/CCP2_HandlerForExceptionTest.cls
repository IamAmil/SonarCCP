@isTest
public class CCP2_HandlerForExceptionTest {
    
    @isTest
    static void testLogException() {
        // Create a mock exception to pass to the LogException method
        Exception mockException;
        try {
            // Intentionally cause an exception to use as a test case
            Integer zero = 0;
            Integer result = 1 / zero;
        } catch (Exception e) {
            mockException = e;
        }

        // Ensure mockException is not null
        System.assertNotEquals(null, mockException);

        // Call the LogException method with the mock exception
        CCP2_HandlerForException.LogException(mockException);
        
        // Query the exception log to ensure it was logged correctly
        CCP2_Exception_Logging__c[] logs = [SELECT Govt_Limit_Msg__c, Exception_Message__c, Exception_Type__c, Line_Number__c, Stack_Trace__c, Method_Name__c, Class_Name__c FROM CCP2_Exception_Logging__c];

        // Assert that an exception log was created
        System.assert(logs.size() > 0);

        // Perform additional assertions to validate the logged data
        CCP2_Exception_Logging__c log = logs[0];
        System.assertNotEquals(null, log.Govt_Limit_Msg__c);
        System.assertEquals(mockException.getMessage(), log.Exception_Message__c);
        System.assertEquals(mockException.getTypeName(), log.Exception_Type__c);
        System.assertEquals(mockException.getLineNumber(), log.Line_Number__c);
        System.assertEquals(mockException.getStackTraceString(), log.Stack_Trace__c);
    }
}