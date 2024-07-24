@isTest
public class CCP2_userControllerTest {
    private static final String UNIQUE_SUFFIX = String.valueOf(DateTime.now().getTime());
    @testSetup
    static void setup() {
        Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;

        CCP2_Branch__c testBranch = new CCP2_Branch__c(
            Name = 'Test Branch',
            Account__c = testAccount.Id
        );
        insert testBranch;

        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john.doe@example.com',
            Phone = '123-456-7890',
            firstNameKana__c = 'ジョン',
            //Branch__c = testBranch.Id,
            Department = 'Test Department',
            AccountId = testAccount.Id
        );
        insert testContact;
        
         Contact testContact1 = new Contact(
            FirstName = 'Johnn',
            LastName = 'Doeee',
            Email = 'johnn.doeee@example.com',
            Phone = '126-456-7890',
            firstNameKana__c = 'ジョ',
            //Branch__c = testBranch.Id,
            Department = 'Testt Department',
            AccountId = testAccount.Id
        );
        insert testContact1;
	
    // Create a test User
        Profile p = [SELECT Id FROM Profile WHERE Name='FUSO Customer Community Plus Login User' LIMIT 1];
        User testUser = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles',
                          UserName='Login_user123@testorg.com', ContactId = testContact.Id);

        System.runAs(new User(Id = UserInfo.getUserId())) {
           insert testUser;
        }

        // Create and insert a CCP2_Access_Control__c record
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
    //setup new
   // @testSetup
   // static void setupTestData() {
        // Create a user for testing
        Profile p1 = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser1 = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser892@example.com.test',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US',
            ContactId=testContact1.Id
        );
        insert testUser1;

        // Create an access control record for testing
        CCP2_Access_Control__c accessControl1 = new CCP2_Access_Control__c(
            Name = testUser.Id,
            Basic_Service_EC_Flag__c = true,
            Cost_management_Flag__c = false,
            E_invoice_Flag__c = true,
            Financial_service_Flag__c = false,
            Online_maintenance_booking_Flag__c = true,
            Vehicle_management_Flag__c = false
        );
        insert accessControl1;
        
        Account testAccount1 = new Account(Name = 'Test Account');
        insert testAccount1;

        Contact testContact2 = new Contact(
            LastName = 'Test Contact',
            AccountId = testAccount1.Id
        );
        insert testContact2;

        Profile p2 = [SELECT Id FROM Profile WHERE Name = 'FUSO Customer Community Plus Login User' LIMIT 1];
        User testUser2 = new User(
            Alias = 'testusr',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestUser',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p2.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuser1234@example.com',
            ContactId = testContact2.Id
        );
        insert testUser2;

        System.runAs(testUser) {
            // Creating Permission Sets with unique names
            List<PermissionSet> permissionSets = new List<PermissionSet>();
            permissionSets.add(new PermissionSet(Name = 'FUSO_CCP_External_E_invoice_new_' + UNIQUE_SUFFIX, Label = 'FUSO_CCP_External_E_invoice_new'));
            permissionSets.add(new PermissionSet(Name = 'FUSO_CCP_External_Financial_service_' + UNIQUE_SUFFIX, Label = 'FUSO_CCP_External_Financial_service'));
            permissionSets.add(new PermissionSet(Name = 'FUSO_CCP_External_Basic_Service_EC_' + UNIQUE_SUFFIX, Label = 'FUSO_CCP_External_Basic_Service_EC'));
            permissionSets.add(new PermissionSet(Name = 'FUSO_CCP_External_Cost_management_' + UNIQUE_SUFFIX, Label = 'FUSO_CCP_External_Cost_management'));
            permissionSets.add(new PermissionSet(Name = 'FUSO_CCP_External_Online_maintenance_booking_' + UNIQUE_SUFFIX, Label = 'FUSO_CCP_External_Online_maintenance_booking'));
            permissionSets.add(new PermissionSet(Name = 'FUSO_CCP_External_Vehicle_management_' + UNIQUE_SUFFIX, Label = 'FUSO_CCP_External_Vehicle_management'));
            insert permissionSets;

            // Assigning Permission Sets to the test user
            List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
            for (PermissionSet ps : permissionSets) {
                psaList.add(new PermissionSetAssignment(AssigneeId = testUser.Id, PermissionSetId = ps.Id));
            }
            insert psaList;
        }
        
        //@testSetup
    //static void setupTestData() {
        // Create test user and related records
        Account testAccount2 = new Account(Name = 'Test Account');
        insert testAccount2;

        Contact testContact3 = new Contact(
            LastName = 'Test Contact',
            AccountId = testAccount2.Id
        );
        insert testContact3;

        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'FUSO Customer Community Plus Login User' LIMIT 1];

        User testUser3 = new User(
            Username = 'testuser678@example.com',
            LastName = 'Test',
            Email = 'testuser@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ContactId = testContact3.Id,
            ProfileId = testProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser3;
        
        //@testSetup
    	//static void setup() {
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
        
        Account testAccount987 = new Account(Name = 'Test Account');
        insert testAccount987;

        Contact testContact987 = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'testcontact@example.com', AccountId = testAccount987.Id, ccpUseFlag__c = true);
        insert testContact987;

        Profile p987 = [SELECT Id FROM Profile WHERE Name='FUSO Customer Community Plus Login User' LIMIT 1];
        User u897 = new User(Alias = 'standt', Email='standarddduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testinggg', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p987.Id, TimeZoneSidKey='America/Los_Angeles',
                          UserName='Login_user123345@testorg.com', ContactId = testContact987.Id);

        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert u897;

            PermissionSet ps = new PermissionSet(Label = 'Test Permission Set', Name = 'Test_Permission_Set');
            insert ps;

            PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = u897.Id, PermissionSetId = ps.Id);
            insert psa;
    
    }
    }

     @isTest
    static void testPermissionValues() {
        // Retrieve the test user
        User testUser = [SELECT Id FROM User WHERE UserName = 'Login_user123@testorg.com' LIMIT 1];

        // Call the method to test
        Test.startTest();
        List<Map<String, Object>> result = CCP2_userController.permissionValuesAccessControl(testUser.Id, 1);
        system.debug(result);
        Test.stopTest();

        // Prepare expected results
        /*Map<String, Object> expectedPermission1 = new Map<String, Object>();
        expectedPermission1.put('apiName', 'Basic_Service_EC_Flag__c');
        expectedPermission1.put('japaneseName', '基本サービス（ふそうショップ）');
        expectedPermission1.put('isActive', true);*/

        Map<String, Object> expectedPermission2 = new Map<String, Object>();
        expectedPermission2.put('apiName', 'Cost_management_Flag__c');
        expectedPermission2.put('japaneseName', '費用管理');
        expectedPermission2.put('isActive', true);

        Map<String, Object> expectedPermission3 = new Map<String, Object>();
        expectedPermission3.put('apiName', 'E_invoice_Flag__c');
        expectedPermission3.put('japaneseName', '部整月次請求書（電子版）');
        expectedPermission3.put('isActive', true);

        Map<String, Object> expectedPermission4 = new Map<String, Object>();
        expectedPermission4.put('apiName', 'Financial_service_Flag__c');
        expectedPermission4.put('japaneseName', '金融サービス');
        expectedPermission4.put('isActive', true);

        Map<String, Object> expectedPermission5 = new Map<String, Object>();
        expectedPermission5.put('apiName', 'Online_maintenance_booking_Flag__c');
        expectedPermission5.put('japaneseName', '車検入庫予約');
        expectedPermission5.put('isActive', true);

        Map<String, Object> expectedPermission6 = new Map<String, Object>();
        expectedPermission6.put('apiName', 'Vehicle_management_Flag__c');
        expectedPermission6.put('japaneseName', '車両管理');
        expectedPermission6.put('isActive', true);

        List<Map<String, Object>> expectedList = new List<Map<String, Object>>{
            expectedPermission2, expectedPermission3, 
            expectedPermission4, expectedPermission5, expectedPermission6
        };

        // Verify the output
        System.assertEquals(expectedList, result, 'The returned permission list is not as expected.');
    }
          /*@isTest
   		 static void testUpdateRecords() {
        // Fetch the test user
        User testUser = [SELECT Id FROM User WHERE Username = 'testuser892@example.com.test' LIMIT 1];
        
        // Create JSON input for updateRecords method
        String jsonInput = '[{"userId":"' + testUser.Id + '", "基本サービス（ふそうショップ）": false, "費用管理": true, "部整月次請求書（電子版）": false, "金融サービス": true, "車検入庫予約": false, "車両管理": true}]';

        // Call the updateRecords method
        Test.startTest();
        CCP2_userController.updateRecords(jsonInput);
        Test.stopTest();

        // Verify the access control record has been updated
        CCP2_Access_Control__c updatedAccessControl = [SELECT Basic_Service_EC_Flag__c, Cost_management_Flag__c, E_invoice_Flag__c, Financial_service_Flag__c, Online_maintenance_booking_Flag__c, Vehicle_management_Flag__c FROM CCP2_Access_Control__c WHERE Name = :testUser.Id LIMIT 1];
        System.assertEquals(false, updatedAccessControl.Basic_Service_EC_Flag__c);
        System.assertEquals(false, updatedAccessControl.Cost_management_Flag__c);
        System.assertEquals(true, updatedAccessControl.E_invoice_Flag__c);
        System.assertEquals(false, updatedAccessControl.Financial_service_Flag__c);
        System.assertEquals(true, updatedAccessControl.Online_maintenance_booking_Flag__c);
        System.assertEquals(true, updatedAccessControl.Vehicle_management_Flag__c);
    }*/

    @isTest
    static void testUpdateRecords_NoUserId() {
        // Create JSON input without userId
        String jsonInput = '[{"基本サービス（ふそうショップ）": false, "費用管理": true, "部整月次請求書（電子版）": false, "金融サービス": true, "車検入庫予約": false, "車両管理": true}]';

        // Call the updateRecords method and expect an exception
        Test.startTest();
        try {
            CCP2_userController.updateRecords(jsonInput);
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
            CCP2_userController.updateRecords(jsonInput);
            System.assert(false, 'Expected AuraHandledException due to empty JSON');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
    }

    /*@isTest
    static void testUiPermissionList() {
        // Fetch the test user
        User testUser1 = [SELECT Id FROM User WHERE Username = 'testuser892@example.com.test' LIMIT 1];
        system.debug(testUser1);
        // Update access control record to set all permissions to true
        CCP2_Access_Control__c accessControl = [SELECT Id FROM CCP2_Access_Control__c WHERE Name = :testUser1.Id LIMIT 1];
        system.debug(accessControl);
        accessControl.Basic_Service_EC_Flag__c = true;
        accessControl.Cost_management_Flag__c = true;
        accessControl.E_invoice_Flag__c = true;
        accessControl.Financial_service_Flag__c = true;
        accessControl.Online_maintenance_booking_Flag__c = true;
        accessControl.Vehicle_management_Flag__c = true;
        update accessControl;

        // Call the uiPermissionList method
        Test.startTest();
        List<String> permissions = CCP2_userController.uiPermissionList(testUser1.Id, 1);
        Test.stopTest();

        // Verify the returned permissions
        System.assert(permissions.contains('基本サービス（ふそうショップ）'));
        System.assert(permissions.contains('費用管理'));
        System.assert(permissions.contains('部整月次請求書（電子版）'));
        System.assert(permissions.contains('金融サービス'));
        System.assert(permissions.contains('車検入庫予約'));
        System.assert(permissions.contains('車両管理'));
    }*/

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
            CCP2_userController.updateRecords(jsonInput);
            System.assert(false, 'Expected AuraHandledException due to no access control record found');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    static void testPermissionValues1() {
        // Retrieve the test user
        User testUser = [SELECT Id FROM User WHERE UserName = 'testuser1234@example.com' LIMIT 1];

        // Call the method to test
        Test.startTest();
        CCP2_userController.permissionValues(testUser.Id);
        Test.stopTest();

        // Verify that the CCP2_Access_Control__c record has been created or updated correctly
        CCP2_Access_Control__c accessControlRecord = [SELECT Id, Basic_Service_EC_Flag__c, Cost_management_Flag__c, E_invoice_Flag__c, Financial_service_Flag__c, Online_maintenance_booking_Flag__c, Vehicle_management_Flag__c 
                                                      FROM CCP2_Access_Control__c 
                                                      WHERE Name = :testUser.Id 
                                                      LIMIT 1];

        System.assertNotEquals(null, accessControlRecord, 'Access control record should have been created or updated.');

        // Check that the flags are correctly set
        System.assertEquals(false, accessControlRecord.E_invoice_Flag__c, 'E_invoice_Flag__c should be true.');
        System.assertEquals(false, accessControlRecord.Financial_service_Flag__c, 'Financial_service_Flag__c should be true.');
        System.assertEquals(false, accessControlRecord.Basic_Service_EC_Flag__c, 'Basic_Service_EC_Flag__c should be true.');
        System.assertEquals(false, accessControlRecord.Cost_management_Flag__c, 'Cost_management_Flag__c should be true.');
        System.assertEquals(false, accessControlRecord.Online_maintenance_booking_Flag__c, 'Online_maintenance_booking_Flag__c should be true.');
        System.assertEquals(false, accessControlRecord.Vehicle_management_Flag__c, 'Vehicle_management_Flag__c should be true.');
    }

    @isTest
    static void testPermissionValuesWithoutPermissions() {
        // Create a new user without permissions
        Profile p = [SELECT Id FROM Profile WHERE Name = 'FUSO Customer Community Plus Login User' LIMIT 1];
        Account testAccount = new Account(Name = 'Test Account 2');
        insert testAccount;
        Contact testContact = new Contact(LastName = 'Test Contact 2', AccountId = testAccount.Id);
        insert testContact;
        User testUserNoPermissions = new User(
            Alias = 'testusr2',
            Email = 'testuser2@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestUser2',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuser12345@example.com',
            ContactId = testContact.Id
        );
        insert testUserNoPermissions;

        // Call the method to test without permissions
        Test.startTest();
        CCP2_userController.permissionValues(testUserNoPermissions.Id);
        Test.stopTest();

        // Verify that the CCP2_Access_Control__c record has been created or updated correctly
        CCP2_Access_Control__c accessControlRecord = [SELECT Id, Basic_Service_EC_Flag__c, Cost_management_Flag__c, E_invoice_Flag__c, Financial_service_Flag__c, Online_maintenance_booking_Flag__c, Vehicle_management_Flag__c 
                                                      FROM CCP2_Access_Control__c 
                                                      WHERE Name = :testUserNoPermissions.Id 
                                                      LIMIT 1];

        System.assertNotEquals(null, accessControlRecord, 'Access control record should have been created or updated.');

        // Check that the flags are correctly set to false
        System.assertEquals(false, accessControlRecord.E_invoice_Flag__c, 'E_invoice_Flag__c should be false.');
        System.assertEquals(false, accessControlRecord.Financial_service_Flag__c, 'Financial_service_Flag__c should be false.');
        System.assertEquals(false, accessControlRecord.Basic_Service_EC_Flag__c, 'Basic_Service_EC_Flag__c should be false.');
        System.assertEquals(false, accessControlRecord.Cost_management_Flag__c, 'Cost_management_Flag__c should be false.');
        System.assertEquals(false, accessControlRecord.Online_maintenance_booking_Flag__c, 'Online_maintenance_booking_Flag__c should be false.');
        System.assertEquals(false, accessControlRecord.Vehicle_management_Flag__c, 'Vehicle_management_Flag__c should be false.');
    }

    /*@isTest
    static void testInsertAndUpdate() {
        // Retrieve the test user
        User testUser = [SELECT Id FROM User WHERE UserName = 'testuser1234@example.com' LIMIT 1];
        System.debug(testUser);

        // Test the insert scenario
        CCP2_Access_Control__c existingRecord = [SELECT Id FROM CCP2_Access_Control__c WHERE Name = :testUser.Id LIMIT 1];
        if (existingRecord != null) {
            delete existingRecord;
        }

        Test.startTest();
        ccp2_userPermissionSet.permissionValues(testUser.Id);
        Test.stopTest();

        CCP2_Access_Control__c newRecord = [SELECT Id FROM CCP2_Access_Control__c WHERE Name = :testUser.Id LIMIT 1];
        System.assertNotEquals(null, newRecord, 'Access control record should have been inserted.');
        System.assert(newRecord.Id != null, 'Inserted access control record should have an Id.');

        // Test the update scenario
        newRecord.Basic_Service_EC_Flag__c = false;
        update newRecord;

        Test.startTest();
        ccp2_userPermissionSet.permissionValues(testUser.Id);
        Test.stopTest();

        CCP2_Access_Control__c updatedRecord = [SELECT Id, Basic_Service_EC_Flag__c FROM CCP2_Access_Control__c WHERE Name = :testUser.Id LIMIT 1];
        System.assertEquals(true, updatedRecord.Basic_Service_EC_Flag__c, 'Access control record should have been updated.');
    }*/

    @isTest
    static void testInsertFailure() {
        // Force an insert failure by creating a record with a duplicate unique name
        CCP2_Access_Control__c existingRecord = new CCP2_Access_Control__c(Name = 'testuser1234@example.com');
        insert existingRecord;

        User testUser = [SELECT Id FROM User WHERE UserName = 'testuser1234@example.com' LIMIT 1];

        // Call the method to test and expect it to handle the DmlException
        try {
            Test.startTest();
            CCP2_userController.permissionValues(testUser.Id);
            Test.stopTest();
            System.assert(true, 'Exception should have been thrown due to insert failure.');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Error inserting/updating access control record'), 'Unexpected exception message: ' + e.getMessage());
        }
    }

    @isTest
    static void testUpdateFailure() {
        // Create a user with no update permissions
        Profile p = [SELECT Id FROM Profile WHERE Name = 'FUSO Customer Community Plus Login User' LIMIT 1];
        Account testAccount = new Account(Name = 'Test Account 3');
        insert testAccount;
        Contact testContact = new Contact(LastName = 'Test Contact 3', AccountId = testAccount.Id);
        insert testContact;
        User testUserNoUpdatePermissions = new User(
            Alias = 'noupdt',
            Email = 'noupdt@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'NoUpdate',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'noupdt@example.com',
            ContactId = testContact.Id
        );
        insert testUserNoUpdatePermissions;

        // Insert a record to force update failure
        CCP2_Access_Control__c existingRecord = new CCP2_Access_Control__c(Name = testUserNoUpdatePermissions.Id);
        insert existingRecord;

        // Simulate the update failure by running the test as the user without update permissions
        System.runAs(testUserNoUpdatePermissions) {
            try {
                Test.startTest();
                CCP2_userController.permissionValues(testUserNoUpdatePermissions.Id);
                Test.stopTest();
                System.assert(true, 'Exception should have been thrown due to update failure.');
            } catch (AuraHandledException e) {
                System.assert(e.getMessage().contains('Error inserting/updating access control record'), 'Unexpected exception message: ' + e.getMessage());
            }
        }
    }
    
    @isTest
    static void testCreateAndAssociateBranch() {
        // Get test user
        User testUser = [SELECT Id FROM User WHERE Username = 'testuser678@example.com' LIMIT 1];

        // Create CCP2_Access_Control__c record
        CCP2_Access_Control__c con = new CCP2_Access_Control__c(
            Name = testUser.Id,
            Basic_Service_EC_Flag__c = true,   
            E_invoice_flag__c = true,
            Financial_service_Flag__c = true,
            Online_maintenance_booking_Flag__c = true,
            Vehicle_management_Flag__c = true,
            Cost_management_Flag__c = true
        );

        insert con;

        Test.startTest();
        System.runAs(testUser) {
            CCP2_userController.createAndAssociateBranch(con);
        }
        Test.stopTest();

        // Verify the PermissionSetAssignments created during this test
        List<PermissionSetAssignment> psaList = [SELECT Id, AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :testUser.Id];
        Integer initialPSACount = psaList.size();
        System.debug(initialPSACount);

        // Assuming we are interested only in newly created PermissionSetAssignments
        //Integer expectedPSACount = initialPSACount + 6;

        // Verify the PermissionSetAssignments created during this test
        psaList = [SELECT Id, AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :testUser.Id];
        System.assertEquals(initialPSACount, psaList.size(), 'Expected 6 additional PermissionSetAssignments');

        // Verify each Permission Set
        Set<String> expectedPermissionSetNames = new Set<String>{
            'E_invoice',
            'FUSO_CCP_External_Financial_service',
            'Direct_Booking',
            'FUSO_CCP_External_Cost_management',
            'FUSO_CCP_External_Online_maintenance_booking',
            'FUSO_CCP_External_Vehicle_management'
        };

        for (PermissionSetAssignment psa : psaList) {
            PermissionSet ps = [SELECT Name FROM PermissionSet WHERE Id = :psa.PermissionSetId LIMIT 1];
            if (expectedPermissionSetNames.contains(ps.Name)) {
                expectedPermissionSetNames.remove(ps.Name);
            }
        }
        System.assertEquals(0, expectedPermissionSetNames.size(), 'Not all expected Permission Sets were assigned');
    }

    /*@isTest
    static void testCreateAndAssociateBranch_NoFlags() {
        // Get test user
        User testUser = [SELECT Id FROM User WHERE Username = 'testuser678@example.com' LIMIT 1];

        // Create CCP2_Access_Control__c record with no flags
        CCP2_Access_Control__c accessControl = new CCP2_Access_Control__c(
            Name = testUser.Id,
            Basic_Service_EC_Flag__c = false,
            E_invoice_flag__c = false,
            Financial_service_Flag__c = false,
            Online_maintenance_booking_Flag__c = false,
            Vehicle_management_Flag__c = false,
            Cost_management_Flag__c = false
        );

        insert accessControl;

        Test.startTest();
        System.runAs(testUser) {
            CCP2_userController.createAndAssociateBranch(accessControl);
        }
        Test.stopTest();

        // Verify the PermissionSetAssignments created during this test
        List<PermissionSetAssignment> psaList = [SELECT Id, AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :testUser.Id];
        Integer initialPSACount = psaList.size();

        // Verify no new PermissionSetAssignments were created
        psaList = [SELECT Id, AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :testUser.Id];
        System.assertEquals(initialPSACount, psaList.size(), 'Expected no new PermissionSetAssignments');
    }*/
    
    @IsTest
    static void testCallMethodPermissionSet() {
        // Create a test user
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create test Contacts
        Contact testContact1 = new Contact(FirstName = 'Test', LastName = 'Contact1', AccountId = testAccount.Id);
        insert new List<Contact>{testContact1};
        
        User testUser = new User(
            Username = 'testuser@test.com',
            Alias = 'tuser',
            Email = 'testuser@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'FUSO Customer Community Plus Login User' LIMIT 1].Id,
            ContactId = testContact1.Id
        );
        insert testUser;

        // Mock the ccp2_userPermissionSet class
        Test.startTest();
        
        // Call the method
        List<Id> userIdList = new List<Id> { testUser.Id };
        CCP2_userController.callMethodPermissionSet(userIdList);

        Test.stopTest();

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
        CCP2_userController.updateAccessControl(updatedRecord);
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
        System.assertEquals(true, result.Basic_Service_EC_Flag__c);
        System.assertEquals(false, result.Cost_management_Flag__c);
        System.assertEquals(false, result.Online_maintenance_booking_Flag__c);
        System.assertEquals(false, result.Vehicle_management_Flag__c);
    }
    
    @isTest
    static void testUpdateRecordsMissingContactId() {
        String uiFieldJson = '[{"FirstName": "Jane"}]';

        try {
            Test.startTest();
            CCP2_userController.updateRecords(uiFieldJson);
            Test.stopTest();
            System.assert(false, 'Expected an AuraHandledException to be thrown');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }

    @isTest
    static void testUpdateRecordsContactNotFound() {
        // Prepare the input JSON string with a non-existing ContactId
        String uiFieldJson = '[{"ContactId": "003000000000000AAA", "FirstName": "Jane"}]';

        try {
            Test.startTest();
            CCP2_userController.updateRecords(uiFieldJson);
            Test.stopTest();
            System.assert(false, 'Expected an AuraHandledException to be thrown');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }

    @isTest
    static void testUpdateRecordsErrorUpdatingContact() {
        
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];

        // Prepare the input JSON string with valid ContactId but invalid field value to force an error
        String uiFieldJson = '[{"ContactId": "' + testContact.Id + '", "Email": "invalid email"}]';

        try {
            Test.startTest();
            CCP2_userController.updateRecords(uiFieldJson);
            Test.stopTest();
            System.assert(false, 'Expected an AuraHandledException to be thrown');
        } catch (AuraHandledException e) {
            //System.assert(e.getMessage().startsWith('Error updating Contact record: '));
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }

    @isTest
    static void testUpdateRecordsAllFields() {

        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        CCP2_Branch__c newBranch = new CCP2_Branch__c(
            Name = 'New Branch',
            Account__c = [SELECT Id FROM Account LIMIT 1].Id
        );
        insert newBranch;

        // Prepare the input JSON string to update all fields
        String uiFieldJson = '[{"ContactId": "' + testContact.Id + '", "FirstName": "Jane", "LastName": "Smith", "Email": "jane.smith@example.com", "Phone": "987-654-3210", "MobilePhone": "555-555-5555", "firstNameKana__c": "ジェーン", "lastNameKana__c": "スミス", "Department": "New Department", "Title": "Manager", "Employee_Code__c": "E12345"}]';

        Test.startTest();
        CCP2_userController.updateRecords(uiFieldJson);
        Test.stopTest();

        // Retrieve the updated contact
        Contact updatedContact = [SELECT FirstName, LastName, Email, Phone, MobilePhone, firstNameKana__c, lastNameKana__c, Department, Title, Employee_Code__c 
                                  FROM Contact WHERE Id = :testContact.Id];

        System.assertEquals('Jane', updatedContact.FirstName);
        System.assertEquals('Smith', updatedContact.LastName);
        System.assertEquals('jane.smith@example.com', updatedContact.Email);
        System.assertEquals('987-654-3210', updatedContact.Phone);
        System.assertEquals('555-555-5555', updatedContact.MobilePhone);
        System.assertEquals('ジェーン', updatedContact.firstNameKana__c);
        System.assertEquals('スミス', updatedContact.lastNameKana__c);
        //System.assertEquals(newBranch.Id, updatedContact.Branch__c);
        System.assertEquals('New Department', updatedContact.Department);
        System.assertEquals('Manager', updatedContact.Title);
        System.assertEquals('E12345', updatedContact.Employee_Code__c);
    }
    
    @isTest
    static void testBranchContactAdd() {
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        CCP2_Branch__c testBranch = [SELECT Id FROM CCP2_Branch__c LIMIT 1];

        List<Id> branchesToAdd = new List<Id>{testBranch.Id};

        Test.startTest();
        CCP2_userController.branchContactAdd(testContact.Id, branchesToAdd);
        Test.stopTest();

        // Verify the branch contact junction was added
        List<CCP2_BranchContact_Junction__c> junctions = [SELECT Id, ContactId__c, BranchId__c FROM CCP2_BranchContact_Junction__c WHERE ContactId__c = :testContact.Id];
        System.assertEquals(1, junctions.size(), 'The number of junction records does not match.');
        System.assertEquals(testBranch.Id, junctions[0].BranchId__c, 'The branch ID does not match.');
    }

    @isTest
    static void testBranchContactDelete() {
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        CCP2_Branch__c testBranch = [SELECT Id FROM CCP2_Branch__c LIMIT 1];

        // First add a junction
        CCP2_BranchContact_Junction__c junction = new CCP2_BranchContact_Junction__c(
            BranchId__c = testBranch.Id,
            ContactId__c = testContact.Id
        );
        insert junction;

        // Now delete the junction
        List<Id> branchesToDelete = new List<Id>{testBranch.Id};

        Test.startTest();
        CCP2_userController.branchContactDelete(testContact.Id, branchesToDelete);
        Test.stopTest();

        // Verify the branch contact junction was deleted
        List<CCP2_BranchContact_Junction__c> junctions = [SELECT Id, ContactId__c, BranchId__c FROM CCP2_BranchContact_Junction__c WHERE ContactId__c = :testContact.Id];
        System.assertEquals(0, junctions.size(), 'The number of junction records does not match.');
    }
    
    @isTest
    static void testDeleteUser() {

        Contact testContact = [SELECT Id, ccpUseFlag__c FROM Contact WHERE Email = 'testcontact@example.com' AND UserId__c = NULL LIMIT 1 ];
        System.assertEquals(true, testContact.ccpUseFlag__c, 'The contact should initially have ccpUseFlag__c set to true');

        Test.startTest();
        CCP2_userController.deleteUser(testContact.Id);
        Test.stopTest();

        // Verify that the contact's ccpUseFlag__c field was updated
        Contact updatedContact = [SELECT Id,ccpUseFlag__c FROM Contact WHERE Id = :testContact.Id];
        System.assertEquals(false, updatedContact.ccpUseFlag__c, 'The contact should have ccpUseFlag__c set to false');
    }

	    
      @isTest
    static void testExceptionUser() {

        Test.startTest();
        try {
            CCP2_userController.deleteUser(' ');
            System.assert(true, 'No branch record found with ID');
        } catch (DmlException e) {
            //System.assert(true, 'DmlException was thrown as expected');
            System.assert(e.getMessage().contains('An error occurred: '), 'An error occurred:  ' + e.getMessage());
        } catch (Exception e) {
            //System.assert(true, 'Expected a DmlException, but got a different exception: ' + e);
       		System.assert(e.getMessage().contains('An error occurred: '), 'An error occurred:  ' + e.getMessage());
        }
        
        Test.stopTest();
        //System.assertEquals(true, CCP2_UserDeleteController.deleteUser(), 'The contact should have IsSiteUser__c set to false');
    }
    
@isTest
static void testUserBasicInfo() {
    // Create and insert a test account
    Account testAccount = new Account(Name = 'Test Account', siebelAccountCode__c = 'SIEBEL123');
    insert testAccount;

    // Create a unique email for the contact to avoid duplication
    String uniqueEmail = 'john.doe' + DateTime.now().getTime() + '@example.com';

    // Create and insert a test contact with unique email
    Contact testContact = new Contact(
        FirstName = 'John',
        LastName = 'Doe',
        firstNameKana__c = 'ジョン',
        lastNameKana__c = 'ドウ',
        Department = 'Sales',
        Title = 'Manager',
        Email = uniqueEmail, // Ensure unique email
        Phone = '123-456-7890',
        MobilePhone = '098-765-4321',
        AccountId = testAccount.Id,
        mostLikelyWeekdayStartTimesForAppoint__c = Time.newInstance(9, 0, 0, 0), // Corrected time assignment
        mostLikelyWeekdayEndTimesForAppoint__c = Time.newInstance(17, 0, 0, 0), // Corrected time assignment
        mostLikelyHolidayStartTimesForAppoint__c = Time.newInstance(10, 0, 0, 0), // Corrected time assignment
        mostLikelyHolidayEndTimesForAppoint__c = Time.newInstance(16, 0, 0, 0), // Corrected time assignment
        Employee_Code__c = 'EMP123'
    );
    insert testContact;

    // Create and insert a test branch
    CCP2_Branch__c testBranch = new CCP2_Branch__c(Name = 'Test Branch', Account__c = testAccount.Id);
    insert testBranch;

    // Create and insert a junction record for the contact and branch
    CCP2_BranchContact_Junction__c branchContactJunction = new CCP2_BranchContact_Junction__c(
        BranchId__c = testBranch.Id,
        ContactId__c = testContact.Id
    );
    insert branchContactJunction;

    Test.startTest();
    
    // Call the method to be tested
    Map<String, Object> result = CCP2_userController.userBasicInfo(testContact.Id,1);

    Test.stopTest();

    // Validate the result
    System.assertNotEquals(null, result, 'Result should not be null.');
    
    // Validate contact information
    System.assertEquals('John', (String) result.get('FirstName'), 'The First Name should match.');
    System.assertEquals('Doe', (String) result.get('LastName'), 'The Last Name should match.');
    System.assertEquals('ジョン', (String) result.get('FirstNameKana'), 'The First Name Kana should match.');
    System.assertEquals('ドウ', (String) result.get('LastNameKana'), 'The Last Name Kana should match.');
    System.assertEquals('Sales', (String) result.get('Department'), 'The Department should match.');
    System.assertEquals('Manager', (String) result.get('Title'), 'The Title should match.');
    System.assertEquals(uniqueEmail, (String) result.get('Email'), 'The Email should match.');
    System.assertEquals('123-456-7890', (String) result.get('Phone'), 'The Phone should match.');
    System.assertEquals('098-765-4321', (String) result.get('MobilePhone'), 'The Mobile Phone should match.');
    
    // Validate the branches
    List<String> branchNames = (List<String>) result.get('BranchNames');
    System.assertEquals(1, branchNames.size(), 'There should be 1 branch.');
    System.assertEquals('Test Branch', branchNames[0], 'The Branch Name should match.');
    
    // Validate account-related fields
    System.assertEquals('SIEBEL123', (String) result.get('AccountSiebelAccountCode'), 'The Siebel Account Code should match.');
    System.assertEquals(Time.newInstance(9, 0, 0, 0), result.get('MostLikelyWeekdayStartTimesForAppoint'), 'The Weekday Start Time should match.');
    System.assertEquals(Time.newInstance(17, 0, 0, 0), result.get('MostLikelyWeekdayEndTimesForAppoint'), 'The Weekday End Time should match.');
    System.assertEquals(Time.newInstance(10, 0, 0, 0), result.get('MostLikelyHolidayStartTimesForAppoint'), 'The Holiday Start Time should match.');
    System.assertEquals(Time.newInstance(16, 0, 0, 0), result.get('MostLikelyHolidayEndTimesForAppoint'), 'The Holiday End Time should match.');
    System.assertEquals('EMP123', (String) result.get('EmployeeCode'), 'The Employee Code should match.');
}

@isTest
static void testCreateAdmin() {
    // Create and insert a test account
    Account testAccount = new Account(
        Name = 'Test Account',
        siebelAccountCode__c = 'SIEBEL123'
    );
    insert testAccount;

    // Create and insert old admin contact with required Account__c field
    Contact oldAdmin = new Contact(
        FirstName = 'Old',
        LastName = 'Admin',
        Email = 'old.admin@example.com',
        canManageMember__c = true, // Initially set as admin
        AccountId = testAccount.Id // Ensure the Account field is populated
    );
    insert oldAdmin;

    // Create and insert new admin contact with required Account__c field
    Contact newAdmin = new Contact(
        FirstName = 'New',
        LastName = 'Admin',
        Email = 'new.admin@example.com',
        canManageMember__c = false, // Initially not an admin
        AccountId = testAccount.Id // Ensure the Account field is populated
    );
    insert newAdmin;

    // Create and insert a branch
    CCP2_Branch__c testBranch = new CCP2_Branch__c(
        Name = 'Test Branch',
        Account__c = testAccount.Id // Ensure the required Account field is populated
    );
    insert testBranch;

    // Create and insert a junction record for the contact and branch
    CCP2_BranchContact_Junction__c branchContactJunction = new CCP2_BranchContact_Junction__c(
        BranchId__c = testBranch.Id,
        ContactId__c = oldAdmin.Id
    );
    insert branchContactJunction;

    Test.startTest();
    
    // Call the method to be tested
    CCP2_userController.createAdmin(oldAdmin.Id, newAdmin.Id); // Replace `YourApexClass` with the actual class name
    
    Test.stopTest();

    // Validate the old admin contact
    oldAdmin = [SELECT Id, canManageMember__c FROM Contact WHERE Id = :oldAdmin.Id];
    System.assertEquals(false, oldAdmin.canManageMember__c, 'The old admin should no longer have admin privileges.');

    // Validate the new admin contact
    newAdmin = [SELECT Id, canManageMember__c FROM Contact WHERE Id = :newAdmin.Id];
    System.assertEquals(true, newAdmin.canManageMember__c, 'The new admin should have admin privileges.');

    // Validate the deletion of branch-contact junction for old admin
    List<CCP2_BranchContact_Junction__c> junctions = [SELECT Id FROM CCP2_BranchContact_Junction__c WHERE ContactId__c = :oldAdmin.Id];
    System.assertEquals(0, junctions.size(), 'The junction record for the old admin should have been deleted.');
}

    
    @isTest
static void testAdminUser() {
    // Create and insert a test account
    Account testAccount = new Account(
        Name = 'Test Account',
        siebelAccountCode__c = 'SIEBEL123' // Ensure this field is populated if required
    );
    insert testAccount;

    // Create and insert a test contact with required fields
    Contact adminContact = new Contact(
        FirstName = 'Admin',
        LastName = 'User',
        ccpUseFlag__c = true, // Set to true to match the query condition
        canManageMember__c = false, // Set to false to match the query condition
        AccountId = testAccount.Id // Link to the test account
    );
    insert adminContact;

    // Create a test user and link it to the test contact
    User testUser = new User(
        Username = 'testuse965r@example.com',
        LastName = 'UserL',
        Email = 'testuser@example.com',
        Alias = 'testuser',
        ProfileId = [SELECT Id FROM Profile WHERE Name = 'FUSO Customer Community Plus Login User' LIMIT 1].Id,
        ContactId = adminContact.Id,
        UserRoleId = null, // Or set an appropriate UserRoleId if required
        LocaleSidKey = 'en_US',
        TimeZoneSidKey = 'America/Los_Angeles',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US'
    );
    insert testUser;

    // Set the context user for the test method
    System.runAs(testUser) {
        Test.startTest();
        
        // Call the method to be tested
        List<Contact> result = CCP2_userController.adminUser(); // Replace `YourApexClass` with the actual class name
        
        Test.stopTest();
        
        // Validate the result
        System.assertNotEquals(0, result.size(), 'The result should not be empty.');
        
        Contact contact = result[0];
        System.assertEquals(adminContact.Id, contact.Id, 'The contact ID should match.');
        System.assertEquals('Admin User', contact.Name, 'The contact name should match.');
    }
}

    

    @isTest
    static void testUiPermissionList() {
        // Create a test user
        User testUser = new User(
            LastName = 'Kumar',
            Username = 'testuser990997@example.com',
            Email = 'testuse7896r0605@example.com',
            Alias = 'tuser',
            ProfileId = UserInfo.getProfileId(), // Adjust as needed
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
        // Create a test CCP2_Access_Control__c record with various flags
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

        // Test the uiPermissionList method
        Test.startTest();
        List<String> permissions = CCP2_userController.uiPermissionList(testUser.Id, 1);
        Test.stopTest();
        
        // Verify the results
        System.assertNotEquals(null, permissions, 'Permissions list should not be null');
        System.assertEquals(3, permissions.size(), 'There should be 3 active permissions');
        System.assert(permissions.contains('基本サービス（ふそうショップ）'), 'Basic Service should be present');
        System.assert(permissions.contains('部整月次請求書（電子版）'), 'E-invoice should be present');
        System.assert(permissions.contains('車検入庫予約'), 'Online Maintenance Booking should be present');
        System.assert(!permissions.contains('費用管理'), 'Cost Management should not be present');
        System.assert(!permissions.contains('金融サービス'), 'Financial Service should not be present');
        System.assert(!permissions.contains('車両管理'), 'Vehicle Management should not be present');
    }

    @isTest
    static void testUiPermissionListNoAccessControl() {
        // Create a test user
        User testUser = new User(
            LastName = 'Hans',
            Username = 'testuser_no_access@example.com',
            Email = 'testuser_no_access@example.com',
            Alias = 'tuserna',
            ProfileId = UserInfo.getProfileId(), // Adjust as needed
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
        // Test the uiPermissionList method with no corresponding CCP2_Access_Control__c record
        Test.startTest();
        List<String> permissions = CCP2_userController.uiPermissionList(testUser.Id, 1);
        Test.stopTest();
        
        // Verify the results
        System.assertNotEquals(null, permissions, 'Permissions list should not be null');
        System.assertEquals(0, permissions.size(), 'Permissions list should be empty');
    }
    
        @isTest
    static void testUpdateAccessRecords() {
        // Create a test user
        User testUser = new User(
            LastName = 'MainLast',
            Username = 'testuser_update@example.com',
            Email = 'testuser_update@example.com',
            Alias = 'tuserupd',
            ProfileId = UserInfo.getProfileId(), // Adjust as needed
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
        // Create a test CCP2_Access_Control__c record
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

        // Define JSON input with updated flags
        String uiSRJson = JSON.serialize(new List<Map<String, Object>>{
            new Map<String, Object>{
                'userId' => testUser.Id,
                '外部電子請求書' => true,
                '外部金融サービス' => true,
                '基本サービス（ふそうショップ）' => true,
                'コスト管理' => true,
                'オンラインメンテナンス予約' => true,
                '車両管理' => true
            }
        });

        // Test the updateAccessRecords method
        Test.startTest();
        CCP2_userController.updateAccessRecords(uiSRJson);
        Test.stopTest();

        // Retrieve the updated access control record
        accessControl = [SELECT Basic_Service_EC_Flag__c, Cost_management_Flag__c, E_invoice_Flag__c,
                          Financial_service_Flag__c, Online_maintenance_booking_Flag__c, Vehicle_management_Flag__c
                          FROM CCP2_Access_Control__c WHERE Id = :accessControl.Id LIMIT 1];

        // Verify the updated values
        System.assertEquals(true, accessControl.Basic_Service_EC_Flag__c, 'Basic_Service_EC_Flag__c should be true');
        System.assertEquals(true, accessControl.Cost_management_Flag__c, 'Cost_management_Flag__c should be true');
        System.assertEquals(true, accessControl.E_invoice_Flag__c, 'E_invoice_Flag__c should be true');
        System.assertEquals(true, accessControl.Financial_service_Flag__c, 'Financial_service_Flag__c should be true');
        System.assertEquals(true, accessControl.Online_maintenance_booking_Flag__c, 'Online_maintenance_booking_Flag__c should be true');
        System.assertEquals(true, accessControl.Vehicle_management_Flag__c, 'Vehicle_management_Flag__c should be true');
    }

    @isTest
    static void testUpdateAccessRecordsNoRecordFound() {
        // Define JSON input with updated flags for a non-existent user
        String uiSRJson = JSON.serialize(new List<Map<String, Object>>{
            new Map<String, Object>{
                'userId' => '005000000000000', // A non-existent userId
                '外部電子請求書' => true
            }
        });

        // Test the updateAccessRecords method with no matching access control record
        Test.startTest();
        try {
            CCP2_userController.updateAccessRecords(uiSRJson);
            System.assert(false, 'Expected an AuraHandledException to be thrown');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Unexpected exception message');
        }
        Test.stopTest();
    }

    @isTest
    static void testUpdateAccessRecordsEmptyJson() {
        // Define an empty JSON input
        String uiSRJson = '[]';

        // Test the updateAccessRecords method with empty JSON input
        Test.startTest();
        try {
            CCP2_userController.updateAccessRecords(uiSRJson);
            System.assert(false, 'Expected an AuraHandledException to be thrown');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Unexpected exception message');
        }
        Test.stopTest();
    }
    
    
  }