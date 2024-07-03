@isTest
public class CCP2_ServicesListTest {
    
    @testSetup
    static void setupTestData() {
        // Create a test Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create a test Contact
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'testcontact@example.com', AccountId = testAccount.Id);
        insert testContact;

        // Create a test User in a different transaction using System.runAs
        Profile p = [SELECT Id FROM Profile WHERE Name='FUSO Customer Community Plus Login User' LIMIT 1];
        User testUser = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles',
                          UserName='Login_user123@testorg.com', ContactId = testContact.Id);

        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert testUser;

            // Query for existing permission sets
            List<PermissionSet> existingPermissionSets = [
                SELECT Id, Name FROM PermissionSet WHERE Name IN (
                    'FUSO_CCP_External_E_invoice_new',
                    'FUSO_CCP_External_Financial_service',
                    'FUSO_CCP_External_Basic_Service_EC',
                    'FUSO_CCP_External_Cost_management',
                    'FUSO_CCP_External_Online_maintenance_booking',
                    'FUSO_CCP_External_Vehicle_management'
                )
            ];

            Map<String, PermissionSet> permissionSetMap = new Map<String, PermissionSet>();
            for (PermissionSet ps : existingPermissionSets) {
                permissionSetMap.put(ps.Name, ps);
            }

            List<PermissionSet> permissionSetsToCreate = new List<PermissionSet>();
            if (!permissionSetMap.containsKey('FUSO_CCP_External_E_invoice_new')) {
                permissionSetsToCreate.add(new PermissionSet(Label = 'FUSO_CCP_External_E_invoice_new', Name = 'FUSO_CCP_External_E_invoice_new'));
            }
            if (!permissionSetMap.containsKey('FUSO_CCP_External_Financial_service')) {
                permissionSetsToCreate.add(new PermissionSet(Label = 'FUSO_CCP_External_Financial_service', Name = 'FUSO_CCP_External_Financial_service'));
            }
            if (!permissionSetMap.containsKey('FUSO_CCP_External_Basic_Service_EC')) {
                permissionSetsToCreate.add(new PermissionSet(Label = 'FUSO_CCP_External_Basic_Service_EC', Name = 'FUSO_CCP_External_Basic_Service_EC'));
            }
            if (!permissionSetMap.containsKey('FUSO_CCP_External_Cost_management')) {
                permissionSetsToCreate.add(new PermissionSet(Label = 'FUSO_CCP_External_Cost_management', Name = 'FUSO_CCP_External_Cost_management'));
            }
            if (!permissionSetMap.containsKey('FUSO_CCP_External_Online_maintenance_booking')) {
                permissionSetsToCreate.add(new PermissionSet(Label = 'FUSO_CCP_External_Online_maintenance_booking', Name = 'FUSO_CCP_External_Online_maintenance_booking'));
            }
            if (!permissionSetMap.containsKey('FUSO_CCP_External_Vehicle_management')) {
                permissionSetsToCreate.add(new PermissionSet(Label = 'FUSO_CCP_External_Vehicle_management', Name = 'FUSO_CCP_External_Vehicle_management'));
            }

            if (!permissionSetsToCreate.isEmpty()) {
                insert permissionSetsToCreate;
                for (PermissionSet ps : permissionSetsToCreate) {
                    permissionSetMap.put(ps.Name, ps);
                }
            }

            List<PermissionSetAssignment> permissionSetAssignments = new List<PermissionSetAssignment>();
            for (PermissionSet ps : permissionSetMap.values()) {
                permissionSetAssignments.add(new PermissionSetAssignment(AssigneeId = testUser.Id, PermissionSetId = ps.Id));
            }
            insert permissionSetAssignments;
        }
    }

    @isTest
    static void testPermissionValues() {
        // Retrieve the test user
        User testUser = [SELECT Id FROM User WHERE UserName = 'Login_user123@testorg.com' LIMIT 1];

        // Call the method to test
        Test.startTest();
        List<Map<String, Object>> result = CCP2_ServicesList.permissionValues(testUser.Id);
        Test.stopTest();

        // Expected output
        List<Map<String, Object>> expectedList = new List<Map<String, Object>>();
        expectedList.add(new Map<String, Object>{ 'name' => '外部電子請求書', 'isActive' => true });
        expectedList.add(new Map<String, Object>{ 'name' => '外部金融サービス', 'isActive' => true });
        expectedList.add(new Map<String, Object>{ 'name' => '基本サービスEC', 'isActive' => true });
        expectedList.add(new Map<String, Object>{ 'name' => 'コスト管理', 'isActive' => true });
        expectedList.add(new Map<String, Object>{ 'name' => 'オンラインメンテナンス予約', 'isActive' => true });
        expectedList.add(new Map<String, Object>{ 'name' => '車両管理', 'isActive' => true });

        // Verify the output
        System.assertEquals(expectedList, result, 'The returned permission list is not as expected.');
    }
}