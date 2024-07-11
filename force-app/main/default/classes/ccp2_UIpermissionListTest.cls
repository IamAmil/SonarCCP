@isTest
public class ccp2_UIpermissionListTest {
    @testSetup
    static void setupTestData() {
        // Create a user for testing
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser892@example.com.test',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        // Create an access control record for testing
        CCP2_Access_Control__c accessControl = new CCP2_Access_Control__c(
            Name = testUser.Id,
            Basic_Service_EC_Flag__c = true,
            Cost_management_Flag__c = false,
            E_invoice_Flag__c = true,
            Financial_service_Flag__c = false,
            Online_maintenance_booking_Flag__c = true,
            Vehicle_management_Flag__c = false
        );
        insert accessControl;
    }

    @isTest
    static void testUpdateRecords() {
        // Fetch the test user
        User testUser = [SELECT Id FROM User WHERE Username = 'testuser892@example.com.test' LIMIT 1];
        
        // Create JSON input for updateRecords method
        String jsonInput = '[{"userId":"' + testUser.Id + '", "基本サービス（ふそうショップ）": false, "費用管理": true, "部整月次請求書（電子版）": false, "金融サービス": true, "車検入庫予約": false, "車両管理": true}]';

        // Call the updateRecords method
        Test.startTest();
        CCP2_userController.updateAccessRecords(jsonInput);
        Test.stopTest();

        // Verify the access control record has been updated
        CCP2_Access_Control__c updatedAccessControl = [SELECT Basic_Service_EC_Flag__c, Cost_management_Flag__c, E_invoice_Flag__c, Financial_service_Flag__c, Online_maintenance_booking_Flag__c, Vehicle_management_Flag__c FROM CCP2_Access_Control__c WHERE Name = :testUser.Id LIMIT 1];
        System.assertEquals(false, updatedAccessControl.Basic_Service_EC_Flag__c);
        System.assertEquals(false, updatedAccessControl.Cost_management_Flag__c);
        System.assertEquals(true, updatedAccessControl.E_invoice_Flag__c);
        System.assertEquals(false, updatedAccessControl.Financial_service_Flag__c);
        System.assertEquals(true, updatedAccessControl.Online_maintenance_booking_Flag__c);
        System.assertEquals(true, updatedAccessControl.Vehicle_management_Flag__c);
    }

    @isTest
    static void testUpdateRecords_NoUserId() {
        // Create JSON input without userId
        String jsonInput = '[{"基本サービス（ふそうショップ）": false, "費用管理": true, "部整月次請求書（電子版）": false, "金融サービス": true, "車検入庫予約": false, "車両管理": true}]';

        // Call the updateRecords method and expect an exception
        Test.startTest();
        try {
            CCP2_userController.updateAccessRecords(jsonInput);
            System.assert(false, 'Expected AuraHandledException due to missing userId');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testUpdateRecords_EmptyJson() {
        // Create an empty JSON input
        String jsonInput = '[]';

        // Call the updateRecords method and expect an exception
        Test.startTest();
        try {
            CCP2_userController.updateAccessRecords(jsonInput);
            System.assert(false, 'Expected AuraHandledException due to empty JSON');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testUiPermissionList() {
        // Fetch the test user
        User testUser = [SELECT Id FROM User WHERE Username = 'testuser892@example.com.test' LIMIT 1];

        // Update access control record to set all permissions to true
        CCP2_Access_Control__c accessControl = [SELECT Id FROM CCP2_Access_Control__c WHERE Name = :testUser.Id LIMIT 1];
        accessControl.Basic_Service_EC_Flag__c = true;
        accessControl.Cost_management_Flag__c = true;
        accessControl.E_invoice_Flag__c = true;
        accessControl.Financial_service_Flag__c = true;
        accessControl.Online_maintenance_booking_Flag__c = true;
        accessControl.Vehicle_management_Flag__c = true;
        update accessControl;

        // Call the uiPermissionList method
        Test.startTest();
        List<String> permissions = CCP2_userController.uiPermissionList(testUser.Id, 1);
        Test.stopTest();

        // Verify the returned permissions
        System.assert(permissions.contains('基本サービス（ふそうショップ）'));
        System.assert(permissions.contains('費用管理'));
        System.assert(permissions.contains('部整月次請求書（電子版）'));
        System.assert(permissions.contains('金融サービス'));
        System.assert(permissions.contains('車検入庫予約'));
        System.assert(permissions.contains('車両管理'));
    }

    @isTest
    static void testUiPermissionList_NoRecord() {
        // Call the uiPermissionList method with a non-existent userId
        Test.startTest();
        List<String> permissions = CCP2_userController.uiPermissionList('005000000000000000', 1);
        Test.stopTest();

        // Verify the returned permissions list is empty
        System.assertEquals(0, permissions.size());
    }

    @isTest
    static void testUpdateRecords_NoAccessControlRecord() {
        // Fetch the test user
        User testUser = [SELECT Id FROM User WHERE Username = 'testuser892@example.com.test' LIMIT 1];

        // Create a JSON input with a non-existent userId
        String jsonInput = '[{"userId":"005000000000000000", "基本サービス（ふそうショップ）": false, "費用管理": true, "部整月次請求書（電子版）": false, "金融サービス": true, "車検入庫予約": false, "車両管理": true}]';

        // Call the updateRecords method and expect an exception
        Test.startTest();
        try {
            CCP2_userController.updateAccessRecords(jsonInput);
            System.assert(false, 'Expected AuraHandledException due to no access control record found');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
    }
}