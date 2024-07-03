@isTest
public class CCP2_branchManagementTest {
    
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
            //userAccountCodeName__c = testAccount.Id
        );
        /*VehicleInfo__c testVehicle2 = new VehicleInfo__c(
            Name = 'Test Vehicle2',
            userAccountCode__c = '001Io000002PqfvIAC',
            vehicleInspectionExpiryDate__c = Date.today().addYears(1)
            //userAccountCode__r.Id = testAccount.Id
        );*/
        insert new List<VehicleInfo__c>{testVehicle1};

        // Prepare contact and vehicle Ids
        List<Id> contactIds = new List<Id>{testContact1.Id, testContact2.Id};
        List<Id> vehicleIds = new List<Id>{testVehicle1.Id};

        // Test the createAndAssociateBranch method
        Test.startTest();
        String result = CCP2_branchManagement.createAndAssociateBranch(
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
    }
    
    @isTest
    static void testBranchAlreadyExists() {
        // Create test Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create an existing branch
        CCP2_Branch__c existingBranch = new CCP2_Branch__c(
            Account__c = testAccount.Id,
            Company_Name__c = 'Existing Company',
            Name = 'Existing Branch',
            Address__c = '123 Existing St',
            Contact_No__c = '111-111-1111',
            cellPhone_No__c = '222-222-2222'
        );
        insert existingBranch;

        // Test the createAndAssociateBranch method with an existing branch name
        Test.startTest();
        String result = CCP2_branchManagement.createAndAssociateBranch(
            testAccount.Id,
            'New Company',
            'Existing Branch',
            '456 New St',
            '333-333-3333',
            '444-444-4444',
            new List<Id>(),
            new List<Id>()
        );
        Test.stopTest();

        // Verify that the branch was not created and the correct message is returned
        System.assertEquals('Branch with same name Exists', result, 'The method did not return the expected message for an existing branch.');
    }
}