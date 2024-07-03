@isTest
public class ccp2_UIpermissionListTest {
    @testSetup
    static void setupTestData() {
        // Create a user for testing
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser@example.com.test',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
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
        User testUser = [SELECT Id FROM User WHERE Username = 'testuser@example.com.test' LIMIT 1];
        
        // Create JSON input for updateRecords method
        String jsonInput = '[{"userId":"' + testUser.Id + '", "基本サービスEC": false, "コスト管理": true, "外部電子請求書": false, "外部金融サービス": true, "オンラインメンテナンス予約": false, "車両管理": true}]';

        // Call the updateRecords method
        Test.startTest();
        ccp2_UIpermissionList.updateRecords(jsonInput);
        Test.stopTest();

        // Verify the access control record has been updated
        CCP2_Access_Control__c updatedAccessControl = [SELECT Basic_Service_EC_Flag__c, Cost_management_Flag__c, E_invoice_Flag__c, Financial_service_Flag__c, Online_maintenance_booking_Flag__c, Vehicle_management_Flag__c FROM CCP2_Access_Control__c WHERE Name = :testUser.Id LIMIT 1];
        System.assertEquals(false, updatedAccessControl.Basic_Service_EC_Flag__c);
        System.assertEquals(true, updatedAccessControl.Cost_management_Flag__c);
        System.assertEquals(false, updatedAccessControl.E_invoice_Flag__c);
        System.assertEquals(true, updatedAccessControl.Financial_service_Flag__c);
        System.assertEquals(false, updatedAccessControl.Online_maintenance_booking_Flag__c);
        System.assertEquals(true, updatedAccessControl.Vehicle_management_Flag__c);
    }

    @isTest
    static void testUpdateRecords_NoUserId() {
        // Create JSON input without userId
        String jsonInput = '[{"基本サービスEC": false, "コスト管理": true, "外部電子請求書": false, "外部金融サービス": true, "オンラインメンテナンス予約": false, "車両管理": true}]';

        // Call the updateRecords method and expect an exception
        Test.startTest();
        try {
            ccp2_UIpermissionList.updateRecords(jsonInput);
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
            ccp2_UIpermissionList.updateRecords(jsonInput);
            System.assert(false, 'Expected AuraHandledException due to empty JSON');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testUiPermissionList() {
        // Fetch the test user
        User testUser = [SELECT Id FROM User WHERE Username = 'testuser@example.com.test' LIMIT 1];

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
        List<String> permissions = ccp2_UIpermissionList.uiPermissionList(testUser.Id);
        Test.stopTest();

        // Verify the returned permissions
        System.assert(permissions.contains('基本サービスEC'));
        System.assert(permissions.contains('コスト管理'));
        System.assert(permissions.contains('外部電子請求書'));
        System.assert(permissions.contains('外部金融サービス'));
        System.assert(permissions.contains('オンラインメンテナンス予約'));
        System.assert(permissions.contains('車両管理'));
    }

    @isTest
    static void testUiPermissionList_NoRecord() {
        // Call the uiPermissionList method with a non-existent userId
        Test.startTest();
        List<String> permissions = ccp2_UIpermissionList.uiPermissionList('005000000000000000');
        Test.stopTest();

        // Verify the returned permissions list is empty
        System.assertEquals(0, permissions.size());
    }

    @isTest
    static void testUpdateRecords_NoAccessControlRecord() {
        // Fetch the test user
        User testUser = [SELECT Id FROM User WHERE Username = 'testuser@example.com.test' LIMIT 1];

        // Create a JSON input with a non-existent userId
        String jsonInput = '[{"userId":"005000000000000000", "基本サービスEC": false, "コスト管理": true, "外部電子請求書": false, "外部金融サービス": true, "オンラインメンテナンス予約": false, "車両管理": true}]';

        // Call the updateRecords method and expect an exception
        Test.startTest();
        try {
            ccp2_UIpermissionList.updateRecords(jsonInput);
            System.assert(false, 'Expected AuraHandledException due to no access control record found');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
    }

    /*@isTest
    static void testUpdateRecords_DmlException() {
        // Fetch the test user
        User testUser = [SELECT Id FROM User WHERE Username = 'testuser@example.com.test' LIMIT 1];
        
        // Create JSON input for updateRecords method that will cause a DML exception
        String jsonInput = '[{"userId":"' + testUser.Id + '", "基本サービスEC": false, "コスト管理": true, "外部電子請求書": false, "外部金融サービス": true, "オンラインメンテナンス予約": false, "車両管理": true}]';

        // Cause a DML exception by making the Name field blank (assuming it's a required field)
        CCP2_Access_Control__c accessControl = [SELECT Id FROM CCP2_Access_Control__c WHERE Name = :testUser.Id LIMIT 1];
        accessControl.Name = '';
        update accessControl;

        // Call the updateRecords method and expect an exception
        Test.startTest();
        try {
            ccp2_UIpermissionList.updateRecords(jsonInput);
            System.assert(false, 'Expected AuraHandledException due to DML exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Script-thrown exception'));
        }
        Test.stopTest();
    }*/
}