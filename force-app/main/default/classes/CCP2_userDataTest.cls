@isTest
public class CCP2_userDataTest {
    
    // Test data setup
    private static void setupTestData() {
        // Create test account
        Account acc = new Account(Name = 'Test Account', siebelAccountCode__c = 'Test123');
        insert acc;
        
        // Create test branch
        CCP2_Branch__c branch = new CCP2_Branch__c(Name = 'Test Branch', Account__c = acc.Id, Branch_Number__c = '12345');
        insert branch;
        
        // Create test contact
        Contact contact1 = new Contact(FirstName = 'Test', LastName = 'User', AccountId = acc.Id, ccpUseFlag__c = true, canManageMember__c = false);
        insert contact1;

        Contact contact2 = new Contact(FirstName = 'Test', LastName = 'User2', AccountId = acc.Id, ccpUseFlag__c = true, canManageMember__c = false);
        insert contact2;
        
        // Create test vehicle
        VehicleInfo__c vehicle = new VehicleInfo__c(Name = 'Test Vehicle', userAccountCode__c = acc.siebelAccountCode__c);
        insert vehicle;

        // Create junction records
        CCP2_BranchContact_Junction__c contactJunction = new CCP2_BranchContact_Junction__c(ContactId__c = contact1.Id, BranchId__c = branch.Id);
        insert contactJunction;

        CCP2_BranchVehicle_Junction__c vehicleJunction = new CCP2_BranchVehicle_Junction__c(VehicleId__c = vehicle.Id, BranchId__c = branch.Id);
        insert vehicleJunction;
    }
    
    @isTest
    static void testUserList() {
        setupTestData();
        
        Test.startTest();
        List<Contact> result = CCP2_userData.userList();
        Test.stopTest();
        
        System.assertNotEquals(0, result.size(), 'User list should not be empty');
    }
    
    @isTest
    static void testUserListDtl() {
        setupTestData();
        
        CCP2_Branch__c branch = [SELECT Id FROM CCP2_Branch__c LIMIT 1];
        
        Test.startTest();
        List<Contact> result = CCP2_userData.userListDtl(branch.Id);
        Test.stopTest();
        
        System.assertNotEquals(0, result.size(), 'User list detail should not be empty');
    }
    
    @isTest
    static void testUserDtl() {
        setupTestData();
        
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        
        Test.startTest();
        List<Contact> result = CCP2_userData.userDtl(contact.Id, 1);
        Test.stopTest();
        
        System.assertNotEquals(0, result.size(), 'User detail should not be empty');
    }
    
    @isTest
    static void testUserBranchDtl() {
        setupTestData();
        
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        
        Test.startTest();
        List<CCP2_Branch__c> result = CCP2_userData.userBranchDtl(contact.Id, 1);
        Test.stopTest();
        
        System.assertNotEquals(0, result.size(), 'User branch detail should not be empty');
    }
    
    @isTest
    static void testBranchList() {
        setupTestData();
        
        Test.startTest();
        List<CCP2_Branch__c> result = CCP2_userData.BranchList();
        Test.stopTest();
        
        System.assertNotEquals(0, result.size(), 'Branch list should not be empty');
    }
    
    @isTest
    static void testUnAssociatedBranch() {
        setupTestData();
        
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        
        Test.startTest();
        List<CCP2_Branch__c> result = CCP2_userData.UnAssociatedBranch(contact.Id);
        Test.stopTest();
        
        System.assertNotEquals(0, result.size(), 'Unassociated branch list should not be empty');
    }
    
    @isTest
    static void testVehicleWithoutAssociation() {
        setupTestData();
        
        Test.startTest();
        List<VehicleInfo__c> result = CCP2_userData.VehicleWithoutAssociation();
        Test.stopTest();
        
        System.assertNotEquals(0, result.size(), 'Vehicle without association list should not be empty');
    }
    
    @isTest
    static void testVehicleWithoutAssociationDtl() {
        setupTestData();
        
        CCP2_Branch__c branch = [SELECT Id FROM CCP2_Branch__c LIMIT 1];
        
        Test.startTest();
        List<VehicleInfo__c> result = CCP2_userData.VehicleWithoutAssociationDtl(branch.Id);
        Test.stopTest();
        
        System.assertNotEquals(0, result.size(), 'Vehicle without association detail list should not be empty');
    }
    
    @isTest
    static void testBranchDetails() {
        setupTestData();
        
        CCP2_Branch__c branch = [SELECT Id FROM CCP2_Branch__c LIMIT 1];
        
        Test.startTest();
        List<CCP2_Branch__c> result = CCP2_userData.BranchDetails(branch.Id);
        Test.stopTest();
        
        System.assertNotEquals(0, result.size(), 'Branch details should not be empty');
    }
    
    @isTest
    static void testNewBranchDetails() {
        setupTestData();
        
        CCP2_Branch__c branch = [SELECT Id FROM CCP2_Branch__c LIMIT 1];
        
        Test.startTest();
        Map<String, Object> result = CCP2_userData.NewBranchDetails(branch.Id);
        Test.stopTest();
        
        System.assertNotEquals(0, result.size(), 'New branch details should not be empty');
    }
    
    @isTest
    static void testUnassociateVehicle() {
        setupTestData();
        
        CCP2_Branch__c branch = [SELECT Id FROM CCP2_Branch__c LIMIT 1];
        VehicleInfo__c vehicle = [SELECT Id FROM VehicleInfo__c LIMIT 1];
        
        Test.startTest();
        CCP2_userData.unassociateVehicle(new List<Id>{vehicle.Id}, branch.Id);
        Test.stopTest();
        
        List<CCP2_BranchVehicle_Junction__c> result = [SELECT Id FROM CCP2_BranchVehicle_Junction__c WHERE VehicleId__c = :vehicle.Id];
        System.assertEquals(0, result.size(), 'Vehicle should be unassociated');
    }
    
    @isTest
    static void testUnassociateUser() {
        setupTestData();
        
        CCP2_Branch__c branch = [SELECT Id FROM CCP2_Branch__c LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        
        Test.startTest();
        CCP2_userData.unassociateUser(new List<Id>{contact.Id}, branch.Id);
        Test.stopTest();
        
        List<CCP2_BranchContact_Junction__c> result = [SELECT Id FROM CCP2_BranchContact_Junction__c WHERE ContactId__c = :contact.Id];
        System.assertEquals(0, result.size(), 'User should be unassociated');
    }
    
    @isTest
    static void testAssociateUser() {
        setupTestData();
        
        CCP2_Branch__c branch = [SELECT Id FROM CCP2_Branch__c LIMIT 1];
        Contact contact = [SELECT Id FROM Contact WHERE Name = 'Test User2' LIMIT 1];
        
        Test.startTest();
        CCP2_userData.associateUser(new List<Id>{contact.Id}, branch.Id);
        Test.stopTest();
        
        List<CCP2_BranchContact_Junction__c> result = [SELECT Id FROM CCP2_BranchContact_Junction__c WHERE ContactId__c = :contact.Id];
        System.assertNotEquals(0, result.size(), 'User should be associated');
    }
    
    @isTest
    static void testAssociateVehicle() {
        setupTestData();
        
        CCP2_Branch__c branch = [SELECT Id FROM CCP2_Branch__c LIMIT 1];
        VehicleInfo__c vehicle = [SELECT Id FROM VehicleInfo__c WHERE Name = 'Test Vehicle' LIMIT 1];
        
        Test.startTest();
        CCP2_userData.associateVehicle(new List<Id>{vehicle.Id}, branch.Id);
        Test.stopTest();
        
        List<CCP2_BranchVehicle_Junction__c> result = [SELECT Id FROM CCP2_BranchVehicle_Junction__c WHERE VehicleId__c = :vehicle.Id];
        System.assertNotEquals(0, result.size(), 'Vehicle should be associated');
    }
    
    @isTest
    static void testAccId() {
        setupTestData();
        
        Test.startTest();
        Id result = CCP2_userData.accId();
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Account ID should not be null');
    }
}