@isTest
private class CCP2_branchControllerTest {
    
    @isTest
    static void testCreateBranch() {
        // Setup test data
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;
        
        // Ensure no branches are initially present
        List<CCP2_Branch__c> branches = [SELECT Id FROM CCP2_Branch__c WHERE Account__c = :testAccount.Id];
        System.assertEquals(0, branches.size(), 'Initial branches count should be zero.');
        
        // Create and insert contacts
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 2; i++) {
            Contact con = new Contact(LastName='Test Contact ' + i, AccountId=testAccount.Id);
            contacts.add(con);
        }
        insert contacts;
        
        List<Id> contactIds = new List<Id>();
        for (Contact c : contacts) {
            contactIds.add(c.Id);
        }
        
        List<Id> vehicleIds = new List<Id>();
        // Add vehicle records if necessary for testing

        // Execute method
        Test.startTest();
        String result = CCP2_branchController.createBranch(
            testAccount.Id, '12345', 'Test Prefecture', 'Test Municipality', '123 Test Street', 
            'Test Building', 'Test Company', 'Test Branch', '123-456-7890', '098-765-4321', 
            contactIds, vehicleIds
        );
        Test.stopTest();
        
        // Verify results
        System.assertEquals('Branch Created', result, 'Branch creation should succeed.');

        // Check if the branch is created
        List<CCP2_Branch__c> createdBranches = [SELECT Id, Name FROM CCP2_Branch__c WHERE Account__c = :testAccount.Id];
        System.assertEquals(1, createdBranches.size(), 'There should be one branch created.');
    }
    
@isTest
static void testGetBranchList() {
    // Setup test data
    Account testAccount = new Account(Name='Test Account');
    insert testAccount;
	Contact con1 = new Contact(FirstName = 'Test1', LastName = 'Contact1', AccountId = testAccount.Id);
    insert con1;
    // Create branches
    CCP2_Branch__c branch1 = new CCP2_Branch__c(
        Account__c = testAccount.Id, Name = 'Branch 1', Postal_Code__c = '12345'
    );
    insert branch1;
    
    CCP2_Branch__c branch2 = new CCP2_Branch__c(
        Account__c = testAccount.Id, Name = 'Branch 2', Postal_Code__c = '67890'
    );
    insert branch2;
    
    // Create vehicle records
    ccp2_Registered_Vehicle__c vehicle1 = new ccp2_Registered_Vehicle__c(Vehicle_Number__c='Vehicle 1', Account__c = testAccount.Id);
    ccp2_Registered_Vehicle__c vehicle2 = new ccp2_Registered_Vehicle__c(Vehicle_Number__c='Vehicle 2', Account__c = testAccount.Id);
    insert new List<ccp2_Registered_Vehicle__c>{vehicle1, vehicle2};
    
    // Create branch vehicle junction records
    CCP2_BranchVehicle_Junction__c junction1 = new CCP2_BranchVehicle_Junction__c(
        BranchId__c = branch1.Id, 
        VehicleId__c = vehicle1.Id
    );
    CCP2_BranchVehicle_Junction__c junction2 = new CCP2_BranchVehicle_Junction__c(
        BranchId__c = branch1.Id, 
        VehicleId__c = vehicle2.Id
    );
    insert new List<CCP2_BranchVehicle_Junction__c>{junction1, junction2};

    // Create a user and assign the test account to the user context
    Profile testProfile = [SELECT Id FROM Profile WHERE Name='FUSO Customer Community Plus Login User' LIMIT 1];
    User testUser = new User(
        LastName = 'OkLast',
        Alias = 'tuser', 
        Email = 'testuser@example.com',
        EmailEncodingKey = 'UTF-8', 
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = testProfile.Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        Username = 'testuser000@example.com',
        IsActive = true,
        ContactId = con1.Id
    );
    insert testUser;
    
    // Execute method as test user
    System.runAs(testUser) {
        Map<Integer, Map<String, Object>> branchList = CCP2_branchController.getBranchList();
        System.debug(branchList);
//        Test.stopTest();
        
        // Debug logs to inspect branchList content
        System.debug('Branch List: ' + branchList);
        
        // Verify results
        System.assertNotEquals(null, branchList, 'Branch list should not be null.');
        System.assertEquals(2, branchList.size(), 'Branch list should contain two branches.');
        
        // Verify branch 1
        Map<String, Object> branchInfo1 = branchList.get(0);
        System.assertEquals(branch1.Id, branchInfo1.get('BranchId'), 'Branch 1 ID should match.');
        System.assertEquals(branch1.Name, branchInfo1.get('BranchName'), 'Branch 1 Name should match.');
        System.assertEquals(2, branchInfo1.get('VehicleCount'), 'Branch 1 should have 2 vehicles.');
        
        // Verify branch 2
        Map<String, Object> branchInfo2 = branchList.get(1);
        System.assertEquals(branch2.Id, branchInfo2.get('BranchId'), 'Branch 2 ID should match.');
        System.assertEquals(branch2.Name, branchInfo2.get('BranchName'), 'Branch 2 Name should match.');
        System.assertEquals(0, branchInfo2.get('VehicleCount'), 'Branch 2 should have 0 vehicles.');
    }
}

    @isTest
    static void testUpdateBranchById() {
        // Setup test data
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;
        
        CCP2_Branch__c branch = new CCP2_Branch__c(
            Account__c = testAccount.Id, Name = 'Old Branch', Postal_Code__c = '12345'
        );
        insert branch;
        
        // Execute method
        Test.startTest();
        CCP2_branchController.updateBranchById(
            branch.Id, '67890', 'New Prefecture', 'New Municipality', '456 New Street',
            'New Building', 'New Contact No', 'New Branch Name'
        );
        Test.stopTest();
        
        // Verify results
        branch = [SELECT Name, Postal_Code__c, Prefecture__c FROM CCP2_Branch__c WHERE Id = :branch.Id];
        System.assertEquals('New Branch Name', branch.Name, 'Branch name should be updated.');
        System.assertEquals('67890', branch.Postal_Code__c, 'Postal code should be updated.');
    }
    
    @isTest
    static void testAddBranch() {
        // Setup test data
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;
        
        CCP2_Branch__c branch1 = new CCP2_Branch__c(
            Account__c = testAccount.Id, Name = 'Branch 1'
        );
        insert branch1;
        
        CCP2_Branch__c branch2 = new CCP2_Branch__c(
            Account__c = testAccount.Id, Name = 'Branch 2'
        );
        insert branch2;
        
        Contact contact = new Contact(LastName='Test Contact', AccountId=testAccount.Id);
        insert contact;
        
        // Execute method
        Test.startTest();
        CCP2_branchController.addBranch(testAccount.Id, contact.Id, new List<Id>{branch1.Id, branch2.Id});
        Test.stopTest();
        
        // Verify results
        List<CCP2_BranchContact_Junction__c> junctions = [SELECT Id FROM CCP2_BranchContact_Junction__c WHERE ContactId__c = :contact.Id];
        System.assertEquals(2, junctions.size(), 'There should be two junction records.');
    }
    
    @isTest
    static void testDeleteBranchById() {
        // Setup test data
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;
        
        CCP2_Branch__c branch = new CCP2_Branch__c(
            Account__c = testAccount.Id, Name = 'Branch to Delete'
        );
        insert branch;
        
        // Execute method
        Test.startTest();
        CCP2_branchController.deleteBranchById(branch.Id);
        Test.stopTest();
        
        // Verify results
        List<CCP2_Branch__c> branches = [SELECT Id FROM CCP2_Branch__c WHERE Id = :branch.Id];
        System.assertEquals(0, branches.size(), 'Branch should be deleted.');
    }
}