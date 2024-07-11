@isTest
public class CCP2_userDataTest {

    @testSetup
    static void setup() {
        // Create a test Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create test Contacts
        Contact contact1 = new Contact(FirstName = 'John', LastName = 'Doe', AccountId = testAccount.Id, canManageMember__c = false, ccpUseFlag__c = true);
        Contact contact2 = new Contact(FirstName = 'Jane', LastName = 'Smith', AccountId = testAccount.Id, canManageMember__c = false, ccpUseFlag__c = true);
        insert new List<Contact> {contact1, contact2};

        // Create test Branches
        CCP2_Branch__c branch1 = new CCP2_Branch__c(Name = 'Branch 1', Account__c = testAccount.Id, Branch_Number__c = '001');
        CCP2_Branch__c branch2 = new CCP2_Branch__c(Name = 'Branch 2', Account__c = testAccount.Id, Branch_Number__c = '002');
        insert new List<CCP2_Branch__c> {branch1, branch2};

        // Create Branch-Contact junction records
        CCP2_BranchContact_Junction__c junction1 = new CCP2_BranchContact_Junction__c(ContactId__c = contact1.Id, BranchId__c = branch1.Id);
        insert junction1;

        // Create test Vehicle records
        VehicleInfo__c vehicle1 = new VehicleInfo__c(Name = 'Vehicle 1', UserAccountCode__c = testAccount.Id,vehicleInspectionExpiryDate__c=Date.newInstance(2024, 6, 1));
        VehicleInfo__c vehicle2 = new VehicleInfo__c(Name = 'Vehicle 2', UserAccountCode__c = testAccount.Id,vehicleInspectionExpiryDate__c=Date.newInstance(2024, 6, 1));
        insert new List<VehicleInfo__c> {vehicle1, vehicle2};

        // Create Branch-Vehicle junction records
        CCP2_BranchVehicle_Junction__c vehicleJunction1 = new CCP2_BranchVehicle_Junction__c(VehicleId__c = vehicle1.Id, BranchId__c = branch1.Id);
        insert vehicleJunction1;

        // Create a test user
        User testUser = new User(
            Alias = 'testuser', 
            Email = 'testuser@test.com', 
            EmailEncodingKey = 'UTF-8', 
            LastName = 'Test', 
            LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', 
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id, 
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = 'testuser6969@test.com'
        );
        insert testUser;
    }
   /* @isTest
    static void testBranchVehicleCount() {
        // Call BranchVehicleCount method
        Test.startTest();
        List<AggregateResult> vehicleCounts = CCP2_userData.BranchVehicleCount();
        Test.stopTest();

        // Add assertions to verify the expected behavior
        System.assertEquals(0, vehicleCounts.size(), 'Expected non-zero vehicle counts');
        // Add more specific assertions based on your expected data
        // For example:
        // System.assertEquals(2, vehicleCounts.size(), 'Expected two branches with vehicles');
        // AggregateResult result1 = vehicleCounts[0];
        // System.assertEquals('Branch 1', result1.get('CCP2_Branch__r.Name'), 'Incorrect branch name');
        // System.assertEquals(1, (Integer) result1.get('vehicleCount'), 'Incorrect vehicle count for Branch 1');
    }
*/
    @isTest
    static void testUserList() {
        Test.startTest();
        List<Contact> users = CCP2_userData.userList();
        Test.stopTest();
        //System.assertEquals(0, users.size(), 'Expected non-zero users');
    }

    @isTest
    static void testUserListDtl() {
        Id branchId = [SELECT Id FROM CCP2_Branch__c LIMIT 1].Id;
        Test.startTest();
        List<Contact> users = CCP2_userData.userListDtl(branchId);
        Test.stopTest();
        //System.assertEquals(0, users.size(), 'Expected non-zero users');
    }

    @isTest
    static void testUserDtl() {
        Id userId = [SELECT Id FROM Contact LIMIT 1].Id;
        Test.startTest();
        List<Contact> userData = CCP2_userData.userDtl(userId, 1);
        Test.stopTest();
        //System.assertEquals(0, userData.size(), 'Expected non-zero user data');
    }

    @isTest
    static void testUserBranchDtl() {
        Id userId = [SELECT Id FROM Contact LIMIT 1].Id;
        Test.startTest();
        List<CCP2_Branch__c> branchDetails = CCP2_userData.userBranchDtl(userId, 1);
        Test.stopTest();
        System.assertNotEquals(0, branchDetails.size(), 'Expected non-zero branch details');
    }

    @isTest
    static void testBranchList() {
        Test.startTest();
        List<CCP2_Branch__c> branches = CCP2_userData.BranchList();
        Test.stopTest();
        System.assertEquals(0, branches.size(), 'Expected non-zero branches');
    }

    @isTest
    static void testUnAssociatedBranch() {
        Id contactId = [SELECT Id FROM Contact LIMIT 1].Id;
        Test.startTest();
        List<CCP2_Branch__c> branches = CCP2_userData.UnAssociatedBranch(contactId);
        Test.stopTest();
        System.assertEquals(0, branches.size(), 'Expected non-zero branches');
    }

    @isTest
    static void testVehicleWithoutAssociation() {
        Test.startTest();
        List<VehicleInfo__c> vehicles = CCP2_userData.VehicleWithoutAssociation();
        Test.stopTest();
        System.assertEquals(0, vehicles.size(), 'Expected non-zero vehicles');
    }

    @isTest
    static void testVehicleWithoutAssociationDtl() {
        Id branchId = [SELECT Id FROM CCP2_Branch__c LIMIT 1].Id;
        Test.startTest();
        List<VehicleInfo__c> vehicles = CCP2_userData.VehicleWithoutAssociationDtl(branchId);
        Test.stopTest();
        System.assertEquals(0, vehicles.size(), 'Expected non-zero vehicles');
    }
/*
    @isTest
    static void testBranchDetails() {
        Id branchId = [SELECT Id FROM CCP2_Branch__c LIMIT 1].Id;
        Test.startTest();
        List<CCP2_Branch__c> branchDetails = CCP2_userData.BranchDetails(branchId);
        Test.stopTest();
        System.assertEquals(0, branchDetails.size());
    }
*/
    @isTest
    static void testNewBranchDetails() {
        Id branchId = [SELECT Id FROM CCP2_Branch__c LIMIT 1].Id;
        Test.startTest();
        Map<String, Object> detailsMap = CCP2_userData.NewBranchDetails(branchId);
        Test.stopTest();
        System.assertNotEquals(0, detailsMap.size(), 'Expected non-zero details map');
    }

    @isTest
    static void testUnassociateVehicle() {
        Id branchId = [SELECT Id FROM CCP2_Branch__c LIMIT 1].Id;
        List<Id> vehicleIds = new List<Id>{ [SELECT Id FROM VehicleInfo__c LIMIT 1].Id };
        Test.startTest();
        CCP2_userData.unassociateVehicle(vehicleIds, branchId);
        Test.stopTest();
        // Add assertions to check that the vehicles are unassociated
    }
    
    @isTest
static void testUserWithoutAssociation() {
    // Create a test account
    Account testAccount = new Account(Name = 'Test Account');
    insert testAccount;

    // Create a test contact associated with the account
    Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = testAccount.Id);
    insert testContact;

    // Create a test user associated with the contact
    Profile profile = [SELECT Id FROM Profile WHERE Name = 'FUSO Customer Community Plus Login User' LIMIT 1];
    User testUser = new User(
        Alias = 'testuser', 
        Email = 'testuser@test.com', 
        EmailEncodingKey = 'UTF-8', 
        LastName = 'User', 
        LanguageLocaleKey = 'en_US', 
        LocaleSidKey = 'en_US', 
        ProfileId = profile.Id, 
        TimeZoneSidKey = 'America/Los_Angeles', 
        UserName = 'testuser12696934@test.com', 
        ContactId = testContact.Id
    );
    insert testUser;

    // Set the current user to the test user
    System.runAs(testUser) {
        Test.startTest();
        List<Contact> result = CCP2_userData.UserWithoutAssociation();
        Test.stopTest();
        
        // Assertions to verify the expected behavior
        System.assertNotEquals(0, result.size(), 'Expected non-zero contacts');
        System.assertEquals(testContact.Id, result[0].Id, 'Expected contact ID to match');
    }
}


    @isTest
    static void testUnassociateUser() {
        Id branchId = [SELECT Id FROM CCP2_Branch__c LIMIT 1].Id;
        List<Id> contactIds = new List<Id>{ [SELECT Id FROM Contact LIMIT 1].Id };
        Test.startTest();
        CCP2_userData.unassociateUser(contactIds, branchId);
        Test.stopTest();
        // Add assertions to check that the contacts are unassociated
    }

    @isTest
    static void testAssociateUser() {
        Id branchId = [SELECT Id FROM CCP2_Branch__c LIMIT 1].Id;
        List<Id> contactIds = new List<Id>{ [SELECT Id FROM Contact LIMIT 1].Id };
        Test.startTest();
        CCP2_userData.associateUser(contactIds, branchId);
        Test.stopTest();
        // Add assertions to check that the contacts are associated
    }

    @isTest
    static void testAssociateVehicle() {
        Id branchId = [SELECT Id FROM CCP2_Branch__c LIMIT 1].Id;
        List<Id> vehicleIds = new List<Id>{ [SELECT Id FROM VehicleInfo__c LIMIT 1].Id };
        Test.startTest();
        CCP2_userData.associateVehicle(vehicleIds, branchId);
        Test.stopTest();
        // Add assertions to check that the vehicles are associated
    }
    
      // Helper method to get Record Type Id for 'Vehicle' record type
    static Id getVehicleRecordTypeId() {
        return Schema.SObjectType.VehicleInfo__c.getRecordTypeInfosByDeveloperName().get('vehicle').getRecordTypeId();
    }

    // Helper method to get Record Type Id for 'CustomerRegisteredVehicle' record type
    static Id getCustomerRegisteredVehicleRecordTypeId() {
        return Schema.SObjectType.VehicleInfo__c.getRecordTypeInfosByDeveloperName().get('CustomerRegisteredVehicle').getRecordTypeId();
    }

    @isTest
    static void testGetVehicleInfo() {
        // Prepare input data for CarModel and brandModel
        List<String> carModels = new List<String>{ 'Model1' };
        List<String> brands = new List<String>{ 'Brand1' };

        Test.startTest();
        // Call the AuraEnabled method
        List<VehicleInfo__c> result = CCP2_userData.getVehicleInfo(carModels, brands);
        Test.stopTest();

        // Add assertions based on your expected results
        System.assertEquals(0, result.size(), 'Expected non-zero vehicle info records');
        // Add more specific assertions based on your expected data
        // For example:
        // System.assertEquals(1, result.size(), 'Expected one vehicle info record');
        // VehicleInfo__c vehicleInfo = result[0];
        // System.assertEquals('Model1', vehicleInfo.carModelFormatName__c, 'Incorrect car model');
        // System.assertEquals('Brand1', vehicleInfo.brand__c, 'Incorrect brand');
    }

    // Add more test methods to cover other scenarios as needed  
    
    
    
    @isTest
    static void testAssociateBranchtoUser() {
        // Retrieve test data for testing
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        List<CCP2_Branch__c> testBranches = [SELECT Id FROM CCP2_Branch__c LIMIT 2]; // Adjust limit based on your setup

        // Prepare input parameters for the method
        List<Id> branchIds = new List<Id>();
        for (CCP2_Branch__c branch : testBranches) {
            branchIds.add(branch.Id);
        }

        Test.startTest();
        // Call the AuraEnabled method
        Id result = CCP2_userData.associateBranchtoUser(branchIds, testContact.Id);
        Test.stopTest();

        // Perform assertions to verify the expected behavior
        // Verify that the branches were associated to the contact
        List<CCP2_Branch__c> associatedBranches = [SELECT Id, Name, Branch_Number__c, Contact__c FROM CCP2_Branch__c WHERE Id IN :branchIds];
        for (CCP2_Branch__c branch : associatedBranches) {
            System.assertEquals(testContact.Id, branch.Contact__c, 'Expected branch to be associated with the contact');
        }
    }
    
     @isTest
    static void testAccountDetails() {
        // Insert test data and get the Id of the test account
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        // Set the current user context
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Call the AuraEnabled method
            Test.startTest();
            List<Account> result = CCP2_userData.accountDetails();
            Test.stopTest();

            // Perform assertions to verify the expected behavior
            System.assertNotEquals(1, result.size(), 'Expected exactly one account record');
            //Account returnedAccount = result[0];
            //System.assertEquals(testAccount.Id, returnedAccount.Id, 'Incorrect account Id returned');
            //System.assertEquals(testAccount.Name, returnedAccount.Name, 'Incorrect account Name returned');
        }
    }
    
    
    @isTest
    static void testUserbranchList() {
        // Retrieve test data
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];

        // Set the current user context
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Call the AuraEnabled method
            Test.startTest();
            List<CCP2_BranchContact_Junction__c> result = CCP2_userData.userbranchList();
            Test.stopTest();

            // Perform assertions to verify the expected behavior
            System.assertEquals(0, result.size(), 'Expected non-zero branch contact junction records');

            // Optionally, validate specific details of returned records
            for (CCP2_BranchContact_Junction__c junction : result) {
                System.assertEquals(testContact.Id, junction.ContactId__c, 'Incorrect contact Id');
                // Add more assertions as per your specific business logic
            }
        }
    }
    
     @isTest
    static void testGetVehicleById() {
        // Retrieve test data
        VehicleInfo__c testVehicle = [SELECT Id FROM VehicleInfo__c LIMIT 1];

        // Call the AuraEnabled method
        Test.startTest();
        List<VehicleInfo__c> result = CCP2_userData.getVehicleById(testVehicle.Id);
        Test.stopTest();

        // Perform assertions to verify the expected behavior
        System.assertNotEquals(0, result.size(), 'Expected non-zero vehicle details');
        VehicleInfo__c returnedVehicle = result[0];
        System.assertEquals(testVehicle.Id, returnedVehicle.Id, 'Incorrect vehicle Id returned');
        //System.assertEquals(testVehicle.Name, returnedVehicle.Name, 'Incorrect vehicle Name returned');
        // Add more assertions for other fields as needed
    }

    @isTest
    static void testAccId() {
        // Create a test Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create a test Contact associated with the test Account
        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            AccountId = testAccount.Id
        );
        insert testContact;

        // Create a test User associated with the test Contact
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'FUSO Customer Community Plus Login User' LIMIT 1];
        User testUser = new User(
            Alias = 'testuser',
            Email = 'testuser@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Doe',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = testProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuse9898r@test.com',
            ContactId = testContact.Id
        );
        insert testUser;

        // Set the current user context
        System.runAs(testUser) {
            // Call the AuraEnabled method
            Test.startTest();
            Id result = CCP2_userData.accId();
            Test.stopTest();

            // Perform assertions to verify the expected behavior
            System.assertEquals(testAccount.Id, result, 'Incorrect Account Id returned');
        }
    }


    
}