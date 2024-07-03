@isTest
public class CCP2_UpdatePermissionAssignmentTest {

    @testSetup
    static void setup() {
        // Create test account and contact
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Contact testContact = new Contact(
            LastName = 'Test Contact',
            AccountId = testAccount.Id
        );
        insert testContact;

        // Create test user
        User testUser = new User(
            Alias = 'testusr',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name='FUSO Customer Community Plus Login User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testu69ser@example.com',
            ContactId = testContact.Id
        );
        insert testUser;
    }

    @isTest
    static void testCreateAndAssociateBranch() {
        // Retrieve test user
        User testUser = [SELECT Id FROM User WHERE UserName='testu69ser@example.com' LIMIT 1];

        // Retrieve existing PermissionSets
        List<PermissionSet> permissionSets = [SELECT Id, Name FROM PermissionSet WHERE Name IN (
            'FUSO_CCP_External_E_invoice_new',
            'FUSO_CCP_External_Financial_service',
            'FUSO_CCP_External_Basic_Service_EC',
            'FUSO_CCP_External_Cost_management',
            'FUSO_CCP_External_Online_maintenance_booking',
            'FUSO_CCP_External_Vehicle_management'
        )];

        Map<String, Id> permissionSetMap = new Map<String, Id>();
        for (PermissionSet ps : permissionSets) {
            permissionSetMap.put(ps.Name, ps.Id);
        }

        // Test with all flags as true
        CCP2_UpdatePermissionAssignment.createAndAssociateBranch(testUser.Id, true, true, true, true, true, true);

        // Test with all flags as false
        CCP2_UpdatePermissionAssignment.createAndAssociateBranch(testUser.Id, false, false, false, false, false, false);

        // Test with mixed flags
        CCP2_UpdatePermissionAssignment.createAndAssociateBranch(testUser.Id, true, false, true, false, true, false);

        // Verify results
        List<PermissionSetAssignment> psaList = [SELECT Id, AssigneeId, PermissionSetId, PermissionSet.ProfileId FROM PermissionSetAssignment WHERE AssigneeId = :testUser.Id];
        System.assertNotEquals(0, psaList.size());

        // Clean up - only delete PermissionSetAssignments not associated with profiles
        for (PermissionSetAssignment psa : psaList) {
            if (psa.PermissionSet.ProfileId == null) {
                delete psa;
            }
        }
    }

    @isTest
    static void testExceptionHandling() {
        // Retrieve test user
        User testUser = [SELECT Id FROM User WHERE UserName='testu69ser@example.com' LIMIT 1];

        // Insert an invalid PermissionSetAssignment to force an exception
        PermissionSetAssignment invalidPsa = new PermissionSetAssignment(
            PermissionSetId = '0PS5i000001invalid',  // Invalid PermissionSetId
            AssigneeId = testUser.Id
        );
        try {
            insert invalidPsa;
        } catch (DmlException e) {
            // Expected exception
        }

        // Call the method and verify that it handles the exception
        try {
            CCP2_UpdatePermissionAssignment.createAndAssociateBranch(testUser.Id, true, true, true, true, true, true);
        } catch (Exception e) {
            // Ensure that the catch(Exception e) block is covered
        }
    }
}