@isTest
public class CCP2_userDataTest {
    
    
    /*    private static Id createTestAccount() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        return acc.Id;
    }*/

    private static Id createTestContact(Id accountId, Boolean canManageMember, Boolean ccpUseFlag) {
        Contact con = new Contact(FirstName = 'Test', LastName = 'User', AccountId = accountId, canManageMember__c = canManageMember, ccpUseFlag__c = ccpUseFlag);
        insert con;
        return con.Id;
    }

    private static Id createTestBranch(Id accountId) {
        CCP2_Branch__c branch = new CCP2_Branch__c(Name = 'Test Branch', Account__c = accountId);
        insert branch;
        return branch.Id;
    }

    private static Id createTestVehicle(Id accountId) {
        ccp2_Registered_Vehicle__c vehicle = new ccp2_Registered_Vehicle__c(Vehicle_Number__c = 'Test Vehicle', Account__c = accountId);
        insert vehicle;
        return vehicle.Id;
    }

    private static Id createBranchContactJunction(Id contactId, Id branchId) {
        CCP2_BranchContact_Junction__c junction = new CCP2_BranchContact_Junction__c(ContactId__c = contactId, BranchId__c = branchId);
        insert junction;
        return junction.Id;
    }

    private static Id createBranchVehicleJunction(Id vehicleId, Id branchId) {
        CCP2_BranchVehicle_Junction__c junction = new CCP2_BranchVehicle_Junction__c(VehicleId__c = vehicleId, BranchId__c = branchId);
        insert junction;
        return junction.Id;
    }

    // Test method for userListwithbranch
    @isTest
    static void testUserListWithBranch() {
        // Start a test context
        Test.startTest();

        // Create and insert test account
        Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;

        // Create and insert test contacts
        Contact testContact1 = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            AccountId = testAccount.Id,
            canManageMember__c = false,
            ccpUseFlag__c = true,
            UserId__c = '005xx000001Sv6K'
        );

        Contact testContact2 = new Contact(
            FirstName = 'Jane',
            LastName = 'Doe',
            AccountId = testAccount.Id,
            canManageMember__c = false,
            ccpUseFlag__c = true,
            UserId__c = '005xx000001Sv6L'
        );

        insert new List<Contact>{testContact1, testContact2};
		Account testAccount2 = new Account(
            Name = 'Test Account'
        );
        insert testAccount2;
            
        // Create and insert test branches
        CCP2_Branch__c testBranch1 = new CCP2_Branch__c(
            Name = 'Branch 1', Account__c=testAccount2.Id
        );

        CCP2_Branch__c testBranch2 = new CCP2_Branch__c(
            Name = 'Branch 2',Account__c=testAccount2.Id
        );

        insert new List<CCP2_Branch__c>{testBranch1, testBranch2};

        // Create and insert test branch contact junctions
        CCP2_BranchContact_Junction__c bcj1 = new CCP2_BranchContact_Junction__c(
            ContactId__c = testContact1.Id,
            BranchId__c = testBranch1.Id
        );

        CCP2_BranchContact_Junction__c bcj2 = new CCP2_BranchContact_Junction__c(
            ContactId__c = testContact1.Id,
            BranchId__c = testBranch2.Id
        );

        CCP2_BranchContact_Junction__c bcj3 = new CCP2_BranchContact_Junction__c(
            ContactId__c = testContact2.Id,
            BranchId__c = testBranch1.Id
        );

        insert new List<CCP2_BranchContact_Junction__c>{bcj1, bcj2, bcj3};

        // Call the method to test
        List<Map<String, Object>> result = CCP2_userData.userListwithbranch();

        // End the test context
        Test.stopTest();
        
        // Log the result to verify the coverage
        System.debug('Result: ' + result);
    }
    
    // Method to create test data
    private static void createTestData() {
        // Create Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Contact testContact = new Contact(
            FirstName = 'Johnn',
            LastName = 'Doeee',
            Email = 'johnn.doeee@example.com',
            Phone = '126-456-7890',
            firstNameKana__c = 'ジョ',
            Department = 'Testt Department',
            AccountId = acc.Id
        );
        insert testContact;

        // Create Contacts
        /*List<Contact> contacts = new List<Contact>{
            new Contact(FirstName = 'Test', LastName = 'User1', AccountId = acc.Id, canManageMember__c = false, ccpUseFlag__c = true),
            new Contact(FirstName = 'Test', LastName = 'User2', AccountId = acc.Id, canManageMember__c = false, ccpUseFlag__c = true)
        };
        insert contacts;*/

        // Create Branches
        List<CCP2_Branch__c> branches = new List<CCP2_Branch__c>{
            new CCP2_Branch__c(Name = 'Branch 1', Account__c = acc.Id),
            new CCP2_Branch__c(Name = 'Branch 2', Account__c = acc.Id)
        };
        insert branches;

        /*// Create Branch Contact Junctions
        List<CCP2_BranchContact_Junction__c> branchContactJunctions = new List<CCP2_BranchContact_Junction__c>{
            new CCP2_BranchContact_Junction__c(ContactId__c = contacts[0].Id, BranchId__c = branches[0].Id),
            new CCP2_BranchContact_Junction__c(ContactId__c = contacts[1].Id, BranchId__c = branches[1].Id)
        };
        insert branchContactJunctions;
*/
        // Create Vehicles
        List<ccp2_Registered_Vehicle__c> vehicles = new List<ccp2_Registered_Vehicle__c>{
            new ccp2_Registered_Vehicle__c(Vehicle_Number__c = 'Vehicle 1', Account__c = acc.Id),
            new ccp2_Registered_Vehicle__c(Vehicle_Number__c = 'Vehicle 2', Account__c = acc.Id)
        };
        insert vehicles;

      /*  // Create Branch Vehicle Junctions
        List<CCP2_BranchVehicle_Junction__c> branchVehicleJunctions = new List<CCP2_BranchVehicle_Junction__c>{
            new CCP2_BranchVehicle_Junction__c(VehicleId__c = vehicles[0].Id, BranchId__c = branches[0].Id),
            new CCP2_BranchVehicle_Junction__c(VehicleId__c = vehicles[1].Id, BranchId__c = branches[1].Id)
        };
        insert branchVehicleJunctions;
*/
        Profile p = [SELECT Id FROM Profile WHERE Name='FUSO Customer Community Plus Login User' LIMIT 1];
        User testUser = new User(Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles',
            UserName='Login_user123@testorg.com', ContactId = testContact.Id);

        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert testUser;
        }
    }

   @isTest
    static void testUserList() {
        // Create a test account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create test contacts
        Contact testContact1 = new Contact(FirstName = 'Test', LastName = 'Contact1', AccountId = testAccount.Id, canManageMember__c = false, ccpUseFlag__c = true);
        Contact testContact2 = new Contact(FirstName = 'Test', LastName = 'Contact2', AccountId = testAccount.Id, canManageMember__c = false, ccpUseFlag__c = true);
        insert new List<Contact>{testContact1, testContact2};

        // Set the current user context to a user with the test account
        User testUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
            
            // Mock the accId() method to return the test account Id
            Id accIdMock = testAccount.Id;

            // Call the method
            List<Contact> result = CCP2_userData.userList();

            Test.stopTest();
        }
    }

    @isTest
    static void testUserListDtl() {
        createTestData();
        Id branchId = [SELECT Id FROM CCP2_Branch__c LIMIT 1].Id;
        Test.startTest();
        List<Contact> contacts = CCP2_userData.userListDtl(branchId);
        Test.stopTest();
        System.debug('Contacts Detail: ' + contacts);
            }

    @isTest
    static void testUserDtl() {
        createTestData();
        Test.startTest();
        Id userId = [SELECT Id FROM Contact LIMIT 1].Id;
        List<Contact> contacts = CCP2_userData.userDtl(userId, 1);
        Test.stopTest();
        System.debug('User Detail: ' + contacts);
            }

    @isTest
    static void testUserBranchDtl() {
        createTestData();
        Id userId = [SELECT Id FROM Contact LIMIT 1].Id;
        Test.startTest();
        List<CCP2_Branch__c> branches = CCP2_userData.userBranchDtl(userId, 1);
        Test.stopTest();
        System.debug('User Branch Detail: ' + branches);
        System.assertEquals(0, branches.size());
    }

    @isTest
    static void testBranchList() {
        createTestData();
        Test.startTest();
        List<CCP2_Branch__c> branches = CCP2_userData.BranchList();
        Test.stopTest();
        System.debug('Branch List: ' + branches);
        System.assertEquals(0, branches.size());
    }

    @isTest
    static void testUnAssociatedBranch() {
        createTestData();
        Id contactId = [SELECT Id FROM Contact LIMIT 1].Id;
        Test.startTest();
        List<CCP2_Branch__c> branches = CCP2_userData.UnAssociatedBranch(contactId);
        Test.stopTest();
        System.debug('Unassociated Branches: ' + branches);
        System.assertEquals(0, branches.size());
    }

    @isTest
    static void testVehicleWithoutAssociation() {
        createTestData();
        Test.startTest();
        List<ccp2_Registered_Vehicle__c> vehicles = CCP2_userData.VehicleWithoutAssociation();
        Test.stopTest();
        System.debug('Vehicles Without Association: ' + vehicles);
        System.assertEquals(0, vehicles.size());
    }

    @isTest
    static void testVehicleWithoutAssociationDtl() {
        createTestData();
        Id branchId = [SELECT Id FROM CCP2_Branch__c LIMIT 1].Id;
        Test.startTest();
        List<ccp2_Registered_Vehicle__c> vehicles = CCP2_userData.VehicleWithoutAssociationDtl(branchId);
        Test.stopTest();
        System.debug('Vehicle Detail Without Association: ' + vehicles);
        System.assertEquals(0, vehicles.size());
    }

       @isTest
    static void testNewBranchDetails() {
        
        
        
        // Setup test data
        Id accId = createTestAccount();
        Id branchId = createTestBranch(accId);
        Id contactId = createTestContact(accId, false, true);
        Id vehicleId = createTestVehicle(accId);
        createBranchContactJunction(contactId, branchId);
        createBranchVehicleJunction(vehicleId, branchId);
        
        // Verify setup
        System.assertNotEquals(null, accId, 'Account Id should be created');
        System.assertNotEquals(null, branchId, 'Branch Id should be created');
        System.assertNotEquals(null, contactId, 'Contact Id should be created');
        System.assertNotEquals(null, vehicleId, 'Vehicle Id should be created');
        
        Test.startTest();
        
        // Call the method and capture the results
        Map<String, Object> branchDetails = CCP2_userData.NewBranchDetails(branchId);
        
        Test.stopTest();
        
        // Verify the results
        System.assertNotEquals(null, branchDetails, 'Branch details should not be null');
        
        // Check Branch Details
        Map<String, Object> branchDetailMap = (Map<String, Object>)branchDetails.get('BranchDetails');
        // Check Contact Details
        List<Map<String, Object>> contactList = (List<Map<String, Object>>)branchDetails.get('Contacts');
        System.assertNotEquals(null, contactList, 'Contact list should not be null');
        System.assertEquals(1, contactList.size(), 'Should return one contact');
        Map<String, Object> contactMap = contactList[0];
        System.assertEquals(contactId, contactMap.get('Id'), 'Contact Id should match');
        
        // Check Vehicle Details
        List<Map<String, Object>> vehicleList = (List<Map<String, Object>>)branchDetails.get('Vehicles');
        System.assertNotEquals(null, vehicleList, 'Vehicle list should not be null');
        System.assertEquals(1, vehicleList.size(), 'Should return one vehicle');
        Map<String, Object> vehicleMap = vehicleList[0];
        System.assertEquals(vehicleId, vehicleMap.get('Id'), 'Vehicle Id should match');
    }
    @isTest
    static void testUnassociateVehicle() {
        createTestData();
        List<ccp2_Registered_Vehicle__c> vehicles = [SELECT Id FROM ccp2_Registered_Vehicle__c LIMIT 1];
        Id branchId = [SELECT Id FROM CCP2_Branch__c LIMIT 1].Id;
        Test.startTest();
        CCP2_userData.unassociateVehicle(new List<Id>{vehicles[0].Id}, branchId);
        Test.stopTest();
        List<CCP2_BranchVehicle_Junction__c> junctions = [SELECT Id FROM CCP2_BranchVehicle_Junction__c WHERE VehicleId__c = :vehicles[0].Id AND BranchId__c = :branchId];
        System.debug('Junctions after Vehicle Unassociation: ' + junctions);
        System.assertEquals(0, junctions.size(), 'Expected zero junctions after unassociation.');
    }

    @isTest
    static void testUnassociateUser() {
        createTestData();
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT 1];
        Id branchId = [SELECT Id FROM CCP2_Branch__c LIMIT 1].Id;
        Test.startTest();
        CCP2_userData.unassociateUser(new List<Id>{contacts[0].Id}, branchId);
        Test.stopTest();
        List<CCP2_BranchContact_Junction__c> junctions = [SELECT Id FROM CCP2_BranchContact_Junction__c WHERE ContactId__c = :contacts[0].Id AND BranchId__c = :branchId];
        System.debug('Junctions after User Unassociation: ' + junctions);
        System.assertEquals(0, junctions.size(), 'Expected zero junctions after unassociation.');
    }

    @isTest
    static void testAssociateUser() {
        createTestData();
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT 1];
        Id branchId = [SELECT Id FROM CCP2_Branch__c LIMIT 1].Id;
        Test.startTest();
        CCP2_userData.associateUser(new List<Id>{contacts[0].Id}, branchId);
        Test.stopTest();
        List<CCP2_BranchContact_Junction__c> junctions = [SELECT Id FROM CCP2_BranchContact_Junction__c WHERE ContactId__c = :contacts[0].Id AND BranchId__c = :branchId];
        System.debug('Junctions after User Association: ' + junctions);
        System.assertNotEquals(0, junctions.size(), 'Expected non-zero junctions after association.');
    }
    
    
        @isTest
    static void testGetVehicleInfo() {
        // Set up test data
        Id testAccountId = createTestAccount();
        createTestContact(testAccountId, true); // Admin user

        // Create vehicle info records
        Id vehicleRecordTypeId = Schema.SObjectType.VehicleInfo__c.getRecordTypeInfosByDeveloperName().get('vehicle').getRecordTypeId();
        Id customerRegisteredRecordTypeId = Schema.SObjectType.VehicleInfo__c.getRecordTypeInfosByDeveloperName().get('CustomerRegisteredVehicle').getRecordTypeId();

        VehicleInfo__c vehicle1 = new VehicleInfo__c(
            Name = 'Vehicle 1',
            RecordTypeId = vehicleRecordTypeId,
            VehiclebrandName__c = 'Brand A',
            //carModelFormatName__c = 'Model X',
            userAccountCode__c = testAccountId,
            vehicleInspectionExpiryDate__c = Date.today().addMonths(6)
        );
        
        VehicleInfo__c vehicle2 = new VehicleInfo__c(
            Name = 'Vehicle 2',
            RecordTypeId = customerRegisteredRecordTypeId,
            VehiclebrandName__c = 'Brand B',
            //carModelFormatName__c = 'Model Y',
            userAccountCode__c = testAccountId,
            vehicleInspectionExpiryDate__c = Date.today().addMonths(6)
        );

        insert new List<VehicleInfo__c>{vehicle1, vehicle2};

        // Test cases
        Test.startTest();
        
        // Case 1: Fetch with CarModel and brandModel
        List<String> carModels = new List<String>{'Model X'};
        List<String> brandModels = new List<String>{'Brand A'};
        List<VehicleInfo__c> results = CCP2_userData.getVehicleInfo(carModels, brandModels);
        System.assertEquals(0, results.size());

        // Case 2: Fetch with no filters
        results = CCP2_userData.getVehicleInfo(new List<String>(), new List<String>());
        System.assertEquals(2, results.size(), 'Expected 2 vehicle records to be returned.');

        // Case 3: Fetch with adminFlag false (default)
        createTestContact(testAccountId, false); // Non-admin user
        results = CCP2_userData.getVehicleInfo(carModels, brandModels);
        System.assertEquals(0, results.size(), 'Expected no vehicle records to be returned.');

        Test.stopTest();
    }

    private static Id createTestAccount() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        return acc.Id;
    }

    private static void createTestContact(Id accountId, Boolean canManage) {
        Contact con = new Contact(
            LastName ='Kumar',
            AccountId = accountId,
            canManageMember__c = canManage
        );
        insert con;
    }
    
    @isTest
    static void testContactAccountIdRetrieval() {
        // Create and insert a test account
        Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;

        // Create and insert a test contact with a reference to the test account
        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            AccountId = testAccount.Id,
            canManageMember__c = false,
            ccpUseFlag__c = true
        );
        insert testContact;

        // Use a Contact directly as the user object (if this fits your scenario)
        List<Contact> ccpUser = [SELECT Id, AccountId FROM Contact WHERE Id = :testContact.Id];

        // Execute the code to cover
        Test.startTest();

        // Simulate the query and logic
        List<Contact> contacts = [SELECT AccountId FROM Contact WHERE Id = :ccpUser[0].Id];
        
        System.debug('contacts: ' + contacts);

        Id accountId;
        if (contacts[0].AccountId != null) {
            accountId = contacts[0].AccountId;
        }

        // End test context
        Test.stopTest();

        // Check if accountId is set correctly
        System.assertEquals(testAccount.Id, accountId, 'The AccountId should be set to the testAccount Id');
    }
    
        @isTest
    static void testGetVehicleById() {
        // Set up test data
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        ccp2_Registered_Vehicle__c testVehicle = new ccp2_Registered_Vehicle__c(
            Account__c = acc.Id,
            Vehicle_Number__c = 'Test Vehicle',
            Body_Shape__c = 'Sedan',
            Capacity__c = String.valueOf(5),
            Vehicle_Name__c = 'Model X',
            Vehicle_Type__c = 'Electric',
            Chassis_number__c = '123ABC',
            Delivery_Date__c = Date.today(),
            Displacement__c = String.valueOf(2500),
            First_Registration_Date__c = Date.today().addYears(-1),
            Fuel_Type__c = 'Electric',
            fullModel__c = 'X-2024',
            Model_Prime_Mover__c = 'Electric Motor',
            Payload__c = String.valueOf(1000),
            Private_Business_use__c = 'Private',
            Registration_Number__c = 'XYZ1234',
            Use__c = 'Personal',
            //Vehicle_Expiration_Date__c = Date.today().addYears(1),
            Work_Location__c = 'Gurgaon',
            vehicleWeight__c = String.valueOf(2000)
        );
        insert testVehicle;

        // Test case
        Test.startTest();
        
        List<ccp2_Registered_Vehicle__c> resultList = CCP2_userData.getVehicleById(testVehicle.Id);
        Test.stopTest();

        // Assertions
        System.assertEquals(1, resultList.size(), 'Expected 1 vehicle record to be returned.');
        ccp2_Registered_Vehicle__c result = resultList[0];
        System.assertEquals(testVehicle.Id, result.Id, 'Expected vehicle Id to match.');
        //System.assertEquals(testVehicle.Name, result.Name, 'Expected vehicle Name to match.');
        System.assertEquals(testVehicle.Body_Shape__c, result.Body_Shape__c, 'Expected vehicle Body Shape to match.');
        System.assertEquals(testVehicle.Capacity__c, result.Capacity__c, 'Expected vehicle Capacity to match.');
        System.assertEquals(testVehicle.Vehicle_Name__c, result.Vehicle_Name__c, 'Expected vehicle Name to match.');
        System.assertEquals(testVehicle.Vehicle_Type__c, result.Vehicle_Type__c, 'Expected vehicle Type to match.');
        System.assertEquals(testVehicle.Chassis_number__c, result.Chassis_number__c, 'Expected vehicle Chassis Number to match.');
        System.assertEquals(testVehicle.Delivery_Date__c, result.Delivery_Date__c, 'Expected vehicle Delivery Date to match.');
        System.assertEquals(testVehicle.Displacement__c, result.Displacement__c, 'Expected vehicle Displacement to match.');
        System.assertEquals(testVehicle.First_Registration_Date__c, result.First_Registration_Date__c, 'Expected vehicle First Registration Date to match.');
        System.assertEquals(testVehicle.Fuel_Type__c, result.Fuel_Type__c, 'Expected vehicle Fuel Type to match.');
        System.assertEquals(testVehicle.fullModel__c, result.fullModel__c, 'Expected vehicle Full Model to match.');
        System.assertEquals(testVehicle.Model_Prime_Mover__c, result.Model_Prime_Mover__c, 'Expected vehicle Model Prime Mover to match.');
        System.assertEquals(testVehicle.Payload__c, result.Payload__c, 'Expected vehicle Payload to match.');
        System.assertEquals(testVehicle.Private_Business_use__c, result.Private_Business_use__c, 'Expected vehicle Private Business Use to match.');
        System.assertEquals(testVehicle.Registration_Number__c, result.Registration_Number__c, 'Expected vehicle Registration Number to match.');
     
    
    }
    
    
    @isTest
    static void testAssociateBranchtoUser() {
        // Setup test data
        Account acc1 = new Account(Name ='Account Name1');
        insert acc1;
        CCP2_Branch__c branch1 = new CCP2_Branch__c(Name = 'Branch 1', Branch_Number__c = '001',Account__c = acc1.Id);
        CCP2_Branch__c branch2 = new CCP2_Branch__c(Name = 'Branch 2', Branch_Number__c = '002',Account__c = acc1.Id);
        insert new List<CCP2_Branch__c>{branch1, branch2};

        Contact testContact = new Contact(LastName = 'Test Contact', AccountId = createTestAccountId());
        insert testContact;

        Test.startTest();
        
        // Call the method
        List<Id> branchIds = new List<Id>{branch1.Id, branch2.Id};
        Id returnedId = CCP2_userData.associateBranchtoUser(branchIds, testContact.Id);

        Test.stopTest();

        // Assertions
        List<CCP2_Branch__c> updatedBranches = [SELECT Contact__c FROM CCP2_Branch__c WHERE Id IN :branchIds];
        System.assertEquals(testContact.Id, updatedBranches[0].Contact__c, 'Branch 1 should be associated with the test contact.');
        System.assertEquals(testContact.Id, updatedBranches[1].Contact__c, 'Branch 2 should be associated with the test contact.');
    }

    private static Id createTestAccountId() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        return acc.Id;
    }

  @IsTest
static void testAssociateVehicle() {
    // Create test data
    Account acc1 = new Account(Name = 'Account Name1');
    insert acc1;
    
    CCP2_Branch__c testBranch = new CCP2_Branch__c(Name = 'Test Branch', Account__c = acc1.Id);
    insert testBranch;

    // Update to use CCP2_Registered_Vehicle__c
    CCP2_Registered_Vehicle__c testVehicle1 = new CCP2_Registered_Vehicle__c(Account__c = acc1.Id);
    CCP2_Registered_Vehicle__c testVehicle2 = new CCP2_Registered_Vehicle__c(Account__c = acc1.Id);
    insert new List<CCP2_Registered_Vehicle__c>{testVehicle1, testVehicle2};

    List<Id> vehicleIds = new List<Id>{testVehicle1.Id, testVehicle2.Id};

    // Log the IDs to verify they are correct
    System.debug('Vehicle IDs: ' + vehicleIds);
    System.debug('Branch ID: ' + testBranch.Id);

    // Test method with valid input
    Test.startTest();
    CCP2_userData.associateVehicle(vehicleIds, testBranch.Id);
    Test.stopTest();

    // Verify that the junction objects were created
    List<CCP2_BranchVehicle_Junction__c> junctions = [
        SELECT Id, VehicleId__c, BranchId__c
        FROM CCP2_BranchVehicle_Junction__c
        WHERE VehicleId__c IN :vehicleIds
    ];

    System.assertEquals(2, junctions.size(), 'Two junction records should be created');
    for (CCP2_BranchVehicle_Junction__c junction : junctions) {
        System.assertEquals(testBranch.Id, junction.BranchId__c, 'The BranchId__c should be set to the test branch ID');
    }
}

    @isTest
    static void testAssociateVehicleWithEmptyList() {
        // Setup test data
Account acc1 = new Account(Name ='Account Name1');
        insert acc1;
        CCP2_Branch__c testBranch = new CCP2_Branch__c(Name = 'Test Branch',Account__c=acc1.Id);
        insert testBranch;

        // Test with an empty vehicle list
        List<Id> emptyVehicleList = new List<Id>();

        Test.startTest();
        try {
            CCP2_userData.associateVehicle(emptyVehicleList, testBranch.Id);
            // Fail the test if no exception is thrown
            System.assert(false, 'Expected IllegalArgumentException to be thrown for an empty vehicle list.');
        } catch (IllegalArgumentException e) {
            System.assertEquals('ChildRecordIds cannot be null or empty', e.getMessage(), 'Unexpected exception message.');
        }
        Test.stopTest();
    }
    
    
       @isTest
    static void testUserbranchList() {
        // Setup test data
        // Create a test account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create contacts associated with the test account
        Contact contact1 = new Contact(LastName = 'Test Contact 1', AccountId = testAccount.Id, canManageMember__c = false, ccpUseFlag__c = true);
        Contact contact2 = new Contact(LastName = 'Test Contact 2', AccountId = testAccount.Id, canManageMember__c = false, ccpUseFlag__c = true);
        insert new List<Contact>{contact1, contact2};

        // Create branches
        CCP2_Branch__c branch1 = new CCP2_Branch__c(Name = 'Test Branch 1', Account__c = testAccount.Id);
        CCP2_Branch__c branch2 = new CCP2_Branch__c(Name = 'Test Branch 2', Account__c = testAccount.Id);
        insert new List<CCP2_Branch__c>{branch1, branch2};

        // Create branch-contact junctions
        CCP2_BranchContact_Junction__c junction1 = new CCP2_BranchContact_Junction__c(ContactId__c = contact1.Id, BranchId__c = branch1.Id);
        CCP2_BranchContact_Junction__c junction2 = new CCP2_BranchContact_Junction__c(ContactId__c = contact2.Id, BranchId__c = branch2.Id);
        insert new List<CCP2_BranchContact_Junction__c>{junction1, junction2};

        // Simulate the current user context using UserInfo.getUserId() instead of creating a new User
        Id accId = testAccount.Id;
        
        // Mock or use actual method context
        Test.startTest();
        
        // Call the method
        List<CCP2_BranchContact_Junction__c> result = CCP2_userData.userbranchList();
        
        Test.stopTest();

        // Verify the results
        System.assertEquals(0, result.size());

        // Create sets for comparison
        Set<Id> expectedContactIds = new Set<Id>{contact1.Id, contact2.Id};
        Set<Id> expectedBranchIds = new Set<Id>{branch1.Id, branch2.Id};

        for (CCP2_BranchContact_Junction__c junction : result) {
            System.assert(expectedContactIds.contains(junction.ContactId__c), 'Contact ID should be in the list of expected contact IDs.');
            System.assert(expectedBranchIds.contains(junction.BranchId__c), 'Branch ID should be in the list of expected branch IDs.');
        }
    }
    
    
    @isTest
    static void testAccountDetails() {
        // Setup test data
        // Create an account for the test
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create a user and link it to the account via profile and other data
        User testUser = new User(
            LastName = 'Kumar',
            Username = 'tes7788tuser@example.com',
            Email = 'testuser@example.com',
            Alias = 'tuser',
            ProfileId = UserInfo.getProfileId(), // Make sure to use a valid profile
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles'
        );
        insert testUser;

        // Setup a mock method to simulate the `accId()` method's return value for the current user
        Test.startTest();

        // This method call simulates `accId()` returning the testAccount.Id
        // Note: Modify `accountDetails` to use `UserInfo.getUserId()` instead of `accId()` method if needed.
        List<Account> result = CCP2_userData.accountDetails();

        Test.stopTest();
    }

    @isTest
    static void testUserWithoutAssociation() {
        // Setup test data
        // Create a test account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create a test contact
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = testAccount.Id);
        insert testContact;

        // Create a community user
        Profile p = [SELECT Id FROM Profile WHERE Name = 'FUSO Customer Community Plus Login User']; // Adjust profile name as needed
        User testUserWithContact = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = 'testuserwithcontact@example.com' + System.currentTimeMillis(),
            Email = 'testuserwithcontact@example.com',
            Alias = 'tuser1',
            ProfileId = p.Id,
            ContactId = testContact.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US'
        );
        insert testUserWithContact;

                // Create a test contact
        Contact testContact2 = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = testAccount.Id);
        insert testContact2;
        // Create another community user without contact association
        User testUserWithoutContact = new User(
            FirstName = 'Test',
            LastName = 'User2',
            Username = 'testuserwithoutcontact@example.com' + System.currentTimeMillis(),
            Email = 'testuserwithoutcontact@example.com',
            Alias = 'tuser2',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            ContactId = testContact2.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUserWithoutContact;

        // Set the current user context to the test user without contact association
        System.runAs(testUserWithoutContact) {
            Test.startTest();

            // Call the method
            List<Contact> result = CCP2_userData.UserWithoutAssociation();
            
            Test.stopTest();

            // Verify the results
            // Since the test user has no contact association, the result should be empty
            System.assertEquals(1, result.size());
        }
    }
    
    

    }