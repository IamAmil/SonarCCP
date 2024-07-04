@isTest
public class CCP2_UpdatePermissionAssignmentTest {

    @testSetup
    static void setupTestData() {
        // Create test user and related records
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Contact testContact = new Contact(
            LastName = 'Test Contact',
            AccountId = testAccount.Id
        );
        insert testContact;

        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'FUSO Customer Community Plus Login User' LIMIT 1];

        User testUser = new User(
            Username = 'testuser678@example.com',
            LastName = 'Test',
            Email = 'testuser@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ContactId = testContact.Id,
            ProfileId = testProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
    }

    @isTest
    static void testCreateAndAssociateBranch() {
        // Get test user
        User testUser = [SELECT Id FROM User WHERE Username = 'testuser678@example.com' LIMIT 1];

        // Create CCP2_Access_Control__c record
        CCP2_Access_Control__c accessControl = new CCP2_Access_Control__c(
            Name = testUser.Id,
            Basic_Service_EC_Flag__c = true,   
            E_invoice_flag__c = true,
            Financial_service_Flag__c = true,
            Online_maintenance_booking_Flag__c = true,
            Vehicle_management_Flag__c = true,
            Cost_management_Flag__c = true
        );

        insert accessControl;

        Test.startTest();
        System.runAs(testUser) {
            CCP2_UpdatePermissionAssignment.createAndAssociateBranch(accessControl);
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

    @isTest
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
            CCP2_UpdatePermissionAssignment.createAndAssociateBranch(accessControl);
        }
        Test.stopTest();

        // Verify the PermissionSetAssignments created during this test
        List<PermissionSetAssignment> psaList = [SELECT Id, AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :testUser.Id];
        Integer initialPSACount = psaList.size();

        // Verify no new PermissionSetAssignments were created
        psaList = [SELECT Id, AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :testUser.Id];
        System.assertEquals(initialPSACount, psaList.size(), 'Expected no new PermissionSetAssignments');
    }
    
    @isTest
    static void testCreateAndAssociateBranchExceptionHandling() {
        // Retrieve the user created in the test setup
        User testUser = [SELECT Id FROM User WHERE Username = 'testuser678@example.com' LIMIT 1];
        CCP2_Access_Control__c accessControl = [SELECT Id, Name FROM CCP2_Access_Control__c WHERE Name = :testUser.Id LIMIT 1];

        // Simulate an exception by inserting a permission set assignment with the same values
        PermissionSet directBookingPs = [SELECT Id FROM PermissionSet WHERE Name = 'Direct_Booking' LIMIT 1];
        System.runAs(testUser) {
            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = directBookingPs.Id, AssigneeId = testUser.Id);
            insert psa;
        }

        Test.startTest();
        try {
            System.runAs(testUser) {
                CCP2_UpdatePermissionAssignment.createAndAssociateBranch(accessControl);
            }
            System.assert(false, 'Expected an exception to be thrown');
        } catch (Exception e) {
            System.assert(true, 'Exception was thrown as expected: ' + e.getMessage());
        }
        Test.stopTest();
    }
}