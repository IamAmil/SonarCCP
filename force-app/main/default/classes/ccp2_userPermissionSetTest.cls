@isTest
public class ccp2_userPermissionSetTest {
    private static final String UNIQUE_SUFFIX = String.valueOf(DateTime.now().getTime());

    @testSetup
    static void setupTestData() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Contact testContact = new Contact(
            LastName = 'Test Contact',
            AccountId = testAccount.Id
        );
        insert testContact;

        Profile p = [SELECT Id FROM Profile WHERE Name = 'FUSO Customer Community Plus Login User' LIMIT 1];
        User testUser = new User(
            Alias = 'testusr',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestUser',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuser1234@example.com',
            ContactId = testContact.Id
        );
        insert testUser;

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
    }

    @isTest
    static void testPermissionValues() {
        // Retrieve the test user
        User testUser = [SELECT Id FROM User WHERE UserName = 'testuser1234@example.com' LIMIT 1];

        // Call the method to test
        Test.startTest();
        ccp2_userPermissionSet.permissionValues(testUser.Id);
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
        ccp2_userPermissionSet.permissionValues(testUserNoPermissions.Id);
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

    @isTest
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
    }

    @isTest
    static void testInsertFailure() {
        // Force an insert failure by creating a record with a duplicate unique name
        CCP2_Access_Control__c existingRecord = new CCP2_Access_Control__c(Name = 'testuser1234@example.com');
        insert existingRecord;

        User testUser = [SELECT Id FROM User WHERE UserName = 'testuser1234@example.com' LIMIT 1];

        // Call the method to test and expect it to handle the DmlException
        try {
            Test.startTest();
            ccp2_userPermissionSet.permissionValues(testUser.Id);
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
                ccp2_userPermissionSet.permissionValues(testUserNoUpdatePermissions.Id);
                Test.stopTest();
                System.assert(true, 'Exception should have been thrown due to update failure.');
            } catch (AuraHandledException e) {
                System.assert(e.getMessage().contains('Error inserting/updating access control record'), 'Unexpected exception message: ' + e.getMessage());
            }
        }
    }
}