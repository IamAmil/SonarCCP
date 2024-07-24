@IsTest
public class ccp2_UIpermissionListTest {
    @IsTest
    static void testUpdateRecords_Success() {
        // Create a test user and access control record
        User testUser = [SELECT Id FROM User LIMIT 1]; // Assuming a test user is already present
        CCP2_Access_Control__c accessControl = new CCP2_Access_Control__c(
            Name = testUser.Id,
            Basic_Service_EC_Flag__c = false,
            Cost_management_Flag__c = false,
            E_invoice_Flag__c = false,
            Financial_service_Flag__c = false,
            Online_maintenance_booking_Flag__c = false,
            Vehicle_management_Flag__c = false
        );
        insert accessControl;

        // Create a valid JSON string as a list containing a single map
        String uiSRJson = '[{"userId":"' + testUser.Id + '","外部電子請求書":true,"外部金融サービス":true,"基本サービス（ふそうショップ）":true,"コスト管理":true,"オンラインメンテナンス予約":true,"車両管理":true}]';

        Test.startTest();
        ccp2_UIpermissionList.updateRecords(uiSRJson);
        Test.stopTest();

        // Verify the record is updated
        accessControl = [SELECT Basic_Service_EC_Flag__c, Cost_management_Flag__c, E_invoice_Flag__c, Financial_service_Flag__c, Online_maintenance_booking_Flag__c, Vehicle_management_Flag__c FROM CCP2_Access_Control__c WHERE Id = :accessControl.Id];
        System.assertEquals(true, accessControl.Basic_Service_EC_Flag__c);
        System.assertEquals(true, accessControl.Cost_management_Flag__c);
        System.assertEquals(true, accessControl.E_invoice_Flag__c);
        System.assertEquals(true, accessControl.Financial_service_Flag__c);
        System.assertEquals(true, accessControl.Online_maintenance_booking_Flag__c);
        System.assertEquals(true, accessControl.Vehicle_management_Flag__c);
    }

    @IsTest
    static void testUpdateRecords_EmptyJson() {
        Test.startTest();
        try {
            ccp2_UIpermissionList.updateRecords('[]');
            System.assert(false, 'Expected AuraHandledException for empty JSON');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void testUpdateRecords_MissingUserId() {
        // Create a JSON string without userId
        String uiSRJson = '[{"外部電子請求書":true,"外部金融サービス":true,"基本サービス（ふそうショップ）":true,"コスト管理":true,"オンラインメンテナンス予約":true,"車両管理":true}]';

        Test.startTest();
        try {
            ccp2_UIpermissionList.updateRecords(uiSRJson);
            System.assert(false, 'Expected AuraHandledException for missing userId');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void testUpdateRecords_NoAccessControlRecord() {
        // Create a JSON string with a valid but non-existent userId
        String uiSRJson = '[{"userId":"005000000000000000","外部電子請求書":true,"外部金融サービス":true,"基本サービス（ふそうショップ）":true,"コスト管理":true,"オンラインメンテナンス予約":true,"車両管理":true}]';

        Test.startTest();
        try {
            ccp2_UIpermissionList.updateRecords(uiSRJson);
            System.assert(false, 'Expected AuraHandledException for non-existent userId');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void testUpdateRecords_DmlException() {
        // Create a test user and access control record
        User testUser = [SELECT Id FROM User LIMIT 1]; // Assuming a test user is already present
        CCP2_Access_Control__c accessControl = new CCP2_Access_Control__c(
            Name = testUser.Id,
            Basic_Service_EC_Flag__c = false,
            Cost_management_Flag__c = false,
            E_invoice_Flag__c = false,
            Financial_service_Flag__c = false,
            Online_maintenance_booking_Flag__c = false,
            Vehicle_management_Flag__c = false
        );
        insert accessControl;

        // Create a valid JSON string as a list containing a single map
        String uiSRJson = '[{"userId":"' + testUser.Id + '","外部電子請求書":true,"外部金融サービス":true,"基本サービス（ふそうショップ）":true,"コスト管理":true,"オンラインメンテナンス予約":true,"車両管理":true}]';

        // Simulate a DML exception by creating a new record with the same unique identifier
        CCP2_Access_Control__c duplicateAccessControl = new CCP2_Access_Control__c(
            Name = testUser.Id
        );
        insert duplicateAccessControl;

        Test.startTest();
        try {
            ccp2_UIpermissionList.updateRecords(uiSRJson);
            } catch (AuraHandledException e) {
            System.assert(e.getMessage().startsWith('Error updating access control record:'), 'Unexpected exception message: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void testUiPermissionList_WithPermissions() {
        // Create a test user and access control record
        User testUser = [SELECT Id FROM User LIMIT 1]; // Assuming a test user is already present
        CCP2_Access_Control__c accessControl = new CCP2_Access_Control__c(
            Name = testUser.Id,
            Basic_Service_EC_Flag__c = true,
            Cost_management_Flag__c = true,
            E_invoice_Flag__c = true,
            Financial_service_Flag__c = true,
            Online_maintenance_booking_Flag__c = true,
            Vehicle_management_Flag__c = true
        );
        insert accessControl;

        Test.startTest();
        List<String> permissions = ccp2_UIpermissionList.uiPermissionList(testUser.Id, 1);
        Test.stopTest();

        // Verify the returned permissions
        System.assertEquals(6, permissions.size());
        System.assert(permissions.contains('基本サービス（ふそうショップ）'));
        System.assert(permissions.contains('費用管理'));
        System.assert(permissions.contains('部整月次請求書（電子版）'));
        System.assert(permissions.contains('金融サービス'));
        System.assert(permissions.contains('車検入庫予約'));
        System.assert(permissions.contains('車両管理'));
    }

    @IsTest
    static void testUiPermissionList_WithoutPermissions() {
        // Create a test user and access control record
        User testUser = [SELECT Id FROM User LIMIT 1]; // Assuming a test user is already present
        CCP2_Access_Control__c accessControl = new CCP2_Access_Control__c(
            Name = testUser.Id,
            Basic_Service_EC_Flag__c = false,
            Cost_management_Flag__c = false,
            E_invoice_Flag__c = false,
            Financial_service_Flag__c = false,
            Online_maintenance_booking_Flag__c = false,
            Vehicle_management_Flag__c = false
        );
        insert accessControl;

        Test.startTest();
        List<String> permissions = ccp2_UIpermissionList.uiPermissionList(testUser.Id, 1);
        Test.stopTest();

        // Verify the returned permissions
        System.assertEquals(0, permissions.size());
    }

    @IsTest
    static void testUiPermissionList_NoAccessControlRecord() {
        // Create a test user with no access control record
        User testUser = [SELECT Id FROM User LIMIT 1]; // Assuming a test user is already present

        Test.startTest();
        List<String> permissions = ccp2_UIpermissionList.uiPermissionList(testUser.Id, 1);
        Test.stopTest();

        // Verify the returned permissions
        System.assertEquals(0, permissions.size());
    }
}