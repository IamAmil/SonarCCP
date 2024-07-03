@isTest
public class ContactUpdateTest {
    @testSetup
    static void setup() {
        // Create a sample CCP2_Access_Control__c record
        CCP2_Access_Control__c sampleRecord = new CCP2_Access_Control__c(
            Name = 'TestRecord',
            E_invoice_flag__c = true,
            Financial_service_Flag__c = true,
            Basic_Service_EC_Flag__c = true,
            Cost_management_Flag__c = true,
            Online_maintenance_booking_Flag__c = true,
            Vehicle_management_Flag__c = true
        );
        insert sampleRecord;
    }
    
    @isTest
    static void testUpdateAccessControl() {
        // Query for the sample record created in the test setup
        CCP2_Access_Control__c sampleRecord = [SELECT Id, Name FROM CCP2_Access_Control__c WHERE Name = 'TestRecord' LIMIT 1];
        
        // Create a new CCP2_Access_Control__c record with updated values
        CCP2_Access_Control__c updatedRecord = new CCP2_Access_Control__c(
            Name = sampleRecord.Name,
            E_invoice_flag__c = false,
            Financial_service_Flag__c = false,
            Basic_Service_EC_Flag__c = false,
            Cost_management_Flag__c = false,
            Online_maintenance_booking_Flag__c = false,
            Vehicle_management_Flag__c = false
        );

        // Call the updateAccessControl method
        Test.startTest();
        ContactUpdate.updateAccessControl(updatedRecord);
        Test.stopTest();

        // Verify the update
        CCP2_Access_Control__c result = [SELECT E_invoice_flag__c, Financial_service_Flag__c, 
                                         Basic_Service_EC_Flag__c, Cost_management_Flag__c, 
                                         Online_maintenance_booking_Flag__c, Vehicle_management_Flag__c 
                                         FROM CCP2_Access_Control__c 
                                         WHERE Id = :sampleRecord.Id 
                                         LIMIT 1];
        System.assertEquals(false, result.E_invoice_flag__c);
        System.assertEquals(false, result.Financial_service_Flag__c);
        System.assertEquals(false, result.Basic_Service_EC_Flag__c);
        System.assertEquals(false, result.Cost_management_Flag__c);
        System.assertEquals(false, result.Online_maintenance_booking_Flag__c);
        System.assertEquals(false, result.Vehicle_management_Flag__c);
    }

    @isTest
    static void testUpdateAccessControl_NoRecordFound() {
        // Create a CCP2_Access_Control__c record with a non-existing Name
        CCP2_Access_Control__c nonExistingRecord = new CCP2_Access_Control__c(
            Name = 'NonExistingRecord',
            E_invoice_flag__c = true,
            Financial_service_Flag__c = true,
            Basic_Service_EC_Flag__c = true,
            Cost_management_Flag__c = true,
            Online_maintenance_booking_Flag__c = true,
            Vehicle_management_Flag__c = true
        );

        // Call the updateAccessControl method
        Test.startTest();
        ContactUpdate.updateAccessControl(nonExistingRecord);
        Test.stopTest();

        // Verify that no record was updated (using debug logs)
        // We can't assert the debug log, but we can ensure no DML exception was thrown
    }
}