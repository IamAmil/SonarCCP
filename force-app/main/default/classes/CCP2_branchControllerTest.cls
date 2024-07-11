@isTest
private class CCP2_branchControllerTest {
    @testSetup
    static void setup() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Contact testContact = new Contact(LastName = 'Test Contact', AccountId = testAccount.Id);
        insert testContact;
    }
    
    
    
    @isTest
    static void testCreateAndAssociateBranch() {
        // Create test Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create test Contacts
        Contact testContact1 = new Contact(FirstName = 'Test', LastName = 'Contact1', AccountId = testAccount.Id);
        Contact testContact2 = new Contact(FirstName = 'Test', LastName = 'Contact2', AccountId = testAccount.Id);
        insert new List<Contact>{testContact1, testContact2};

        // Create test user and associate it with a contact
        Profile p = [SELECT Id FROM Profile WHERE Name='FUSO Customer Community Plus Login User'];
        User testUser = new User(
            Username = 'testuser@test24.com', 
            Email = 'testuser@test.com', 
            LastName = 'Test', 
            Alias = 'test', 
            TimeZoneSidKey = 'America/Los_Angeles', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            ProfileId = p.Id, 
            LanguageLocaleKey = 'en_US',
            ContactId = testContact1.Id
        );
        insert testUser;

        // Create test Vehicles (assuming VehicleInfo__c is the custom object for vehicles)
        VehicleInfo__c testVehicle1 = new VehicleInfo__c(
            Name = 'Test Vehicle1',
            userAccountCode__c = testAccount.Id,
            vehicleInspectionExpiryDate__c = Date.today().addYears(1)
        );
        insert new List<VehicleInfo__c>{testVehicle1};

        // Prepare contact and vehicle Ids
        List<Id> contactIds = new List<Id>{testContact1.Id, testContact2.Id};
        List<Id> vehicleIds = new List<Id>{testVehicle1.Id};

        // Test the createAndAssociateBranch method
        Test.startTest();
        String result = CCP2_branchController.createBranch(
            testAccount.Id,
            'Test Company',
            'Test Branch',
            '123 Test St',
            '123-456-7890',
            '098-765-4321',
            contactIds,
            vehicleIds
        );
        Test.stopTest();

        // Verify the branch creation
        System.assertEquals('Branch Created', result, 'The branch was not created successfully.');

        // Verify that the branch was created in the database
        CCP2_Branch__c newBranch = [SELECT Id, Account__c, Company_Name__c, Name, Address__c, Contact_No__c, cellPhone_No__c FROM CCP2_Branch__c WHERE Name = 'Test Branch' AND Account__c = :testAccount.Id LIMIT 1];
        System.assertNotEquals(null, newBranch, 'The new branch was not found in the database.');
        System.assertEquals('Test Company', newBranch.Company_Name__c, 'The company name does not match.');
        System.assertEquals('123 Test St', newBranch.Address__c, 'The address does not match.');
        System.assertEquals('123-456-7890', newBranch.Contact_No__c, 'The telephone number does not match.');
        System.assertEquals('098-765-4321', newBranch.cellPhone_No__c, 'The cellphone number does not match.');

        // Verify that junction records were created
        List<CCP2_BranchContact_Junction__c> branchContactJunctions = [SELECT Id, BranchId__c, ContactId__c FROM CCP2_BranchContact_Junction__c WHERE BranchId__c = :newBranch.Id];
        System.assertEquals(2, branchContactJunctions.size(), 'The number of branch-contact junction records does not match.');

        List<CCP2_BranchVehicle_Junction__c> branchVehicleJunctions = [SELECT Id, BranchId__c, VehicleId__c FROM CCP2_BranchVehicle_Junction__c WHERE BranchId__c = :newBranch.Id];
        System.assertEquals(1, branchVehicleJunctions.size(), 'The number of branch-vehicle junction records does not match.');
    }
    


    @isTest
    static void testUpdateBranchById() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        CCP2_Branch__c testBranch = new CCP2_Branch__c(Account__c = testAccount.Id, Name = 'Test Branch 3', Address__c = 'Old Address', Contact_No__c = '111-111-1111');
        insert testBranch;

        Test.startTest();
        CCP2_branchController.updateBranchById(testBranch.Id, 'New Address', '222-222-2222', 'Updated Branch 3');
        Test.stopTest();
        
 

        CCP2_Branch__c updatedBranch = [SELECT Id, Address__c, Contact_No__c, Name FROM CCP2_Branch__c WHERE Id = :testBranch.Id];
        System.assertEquals('New Address', updatedBranch.Address__c);
        System.assertEquals('222-222-2222', updatedBranch.Contact_No__c);
        System.assertEquals('Updated Branch 3', updatedBranch.Name);
    }
    @isTest
    static void testUpdateBranchByIdCatch() {
        Test.startTest();  
        try {
            CCP2_branchController.updateBranchById('', 'Ramu', 'Kaka', '');
        } catch (Exception e) {
            //System.assert(true, 'Expected a DmlException, but got a different exception: ' + e);
       		System.assertNotEquals(e.getMessage(), 'List has no rows for assignment to SObject');
        }
        Test.stopTest(); 
    }
    
    
    
    @isTest
    static void testAddBranch() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact WHERE AccountId = :testAccount.Id LIMIT 1];
        CCP2_Branch__c testBranch = new CCP2_Branch__c(Account__c = testAccount.Id, Name = 'Test Branch 4');
        insert testBranch;

        Test.startTest();
        CCP2_branchController.addBranch(testAccount.Id, testContact.Id, new List<Id>{testBranch.Id});
        Test.stopTest();

        CCP2_BranchContact_Junction__c junctionRecord = [SELECT Id, BranchId__c, ContactId__c FROM CCP2_BranchContact_Junction__c WHERE BranchId__c = :testBranch.Id];
        System.assertEquals(testBranch.Id, junctionRecord.BranchId__c);
        System.assertEquals(testContact.Id, junctionRecord.ContactId__c);
    }
    
    @isTest
    static void testDeleteBranchById() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        CCP2_Branch__c testBranch = new CCP2_Branch__c(Account__c = testAccount.Id, Name = 'Test Branch 5');
        insert testBranch;

        Test.startTest();
        CCP2_branchController.deleteBranchById(testBranch.Id);
        Test.stopTest();

        List<CCP2_Branch__c> deletedBranch = [SELECT Id FROM CCP2_Branch__c WHERE Id = :testBranch.Id];
        System.assertEquals(0, deletedBranch.size());
    }
    
    @isTest
    static void testGetBranchList() {
        // Create test Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Contact testContact2 = new Contact(FirstName = 'Test', LastName = 'Contact1', AccountId = testAccount.Id);
        insert testContact2;

        // Create a user and associate it with the test account
        Profile p = [SELECT Id FROM Profile WHERE Name='FUSO Customer Community Plus Login User'];
        User testUser = new User(
            Username = 'testuser@test24.com', 
            Email = 'testuser@test.com', 
            LastName = 'Test', 
            Alias = 'test', 
            TimeZoneSidKey = 'America/Los_Angeles', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            ProfileId = p.Id, 
            LanguageLocaleKey = 'en_US',
            ContactId = testContact2.Id
            //AccountId = testAccount.Id
        );
        insert testUser;

        // Create branches
        CCP2_Branch__c branch1 = new CCP2_Branch__c(Account__c = testAccount.Id, Name = 'Branch 1');
        CCP2_Branch__c branch2 = new CCP2_Branch__c(Account__c = testAccount.Id, Name = 'Branch 2');
        insert new List<CCP2_Branch__c>{branch1, branch2};

        // Create vehicle junction records
        VehicleInfo__c testVehicle1 = new VehicleInfo__c(
            Name = 'Test Vehicle1',
            userAccountCode__c = testAccount.Id,
            vehicleInspectionExpiryDate__c = Date.today().addYears(1)
        );
        VehicleInfo__c testVehicle2 = new VehicleInfo__c(
            Name = 'Test Vehicle2',
            userAccountCode__c = testAccount.Id,
            vehicleInspectionExpiryDate__c = Date.today().addYears(1)
        );
        insert new List<VehicleInfo__c>{testVehicle1, testVehicle2};

        CCP2_BranchVehicle_Junction__c junction1 = new CCP2_BranchVehicle_Junction__c(BranchId__c = branch1.Id, VehicleId__c = testVehicle1.Id);
        CCP2_BranchVehicle_Junction__c junction2 = new CCP2_BranchVehicle_Junction__c(BranchId__c = branch1.Id, VehicleId__c = testVehicle2.Id);
        CCP2_BranchVehicle_Junction__c junction3 = new CCP2_BranchVehicle_Junction__c(BranchId__c = branch2.Id, VehicleId__c = testVehicle2.Id);
        insert new List<CCP2_BranchVehicle_Junction__c>{junction1, junction2, junction3};

        // Run the test
        Test.startTest();
        System.runAs(testUser) {
            Map<Integer, Map<String, Object>> branchList = CCP2_branchController.getBranchList();
            Test.stopTest();
    
            // Verify the branch list
            System.assertEquals(2, branchList.size(), 'The number of branches does not match.');
            System.assertEquals('Branch 1', branchList.get(0).get('BranchName'), 'The first branch name does not match.');
            System.assertEquals(2, branchList.get(0).get('VehicleCount'), 'The vehicle count for the first branch does not match.');
            System.assertEquals('Branch 2', branchList.get(1).get('BranchName'), 'The second branch name does not match.');
            System.assertEquals(1, branchList.get(1).get('VehicleCount'), 'The vehicle count for the second branch does not match.');
        }
    }
    
    
    
    
}