@isTest
public class CCP2_userDataTest {

    @testSetup
    static void setupTestData() {
        Account testAccount = new Account(Name = 'Test Account', siebelAccountCode__c = '00190000001pPvHAAU'); // Assuming siebelAccountCode__c is required
        insert testAccount;

        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'testcontact@example.com', AccountId = testAccount.Id);
        insert testContact;

        Profile communityProfile = [SELECT Id FROM Profile WHERE Name = 'FUSO Customer Community Plus Login User' LIMIT 1];
        String uniqueUserName = 'testuser' + DateTime.now().getTime() + '@example.com';
        User testUser = new User(Alias = 'tuser', Email = 'testuser@example.com', EmailEncodingKey = 'UTF-8',
                                 LastName = 'User', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', 
                                 ProfileId = communityProfile.Id, TimeZoneSidKey = 'America/Los_Angeles', 
                                 UserName = uniqueUserName, ContactId = testContact.Id);
        insert testUser;

        CCP2_Branch__c testBranch = new CCP2_Branch__c(Account__c = testAccount.Id, Name = 'Test Branch');
        insert testBranch;
		ID cpCaseRecordTypeId = Schema.SObjectType.VehicleInfo__c.getRecordTypeInfosByDeveloperName().get('expectedVehicle').getRecordTypeId();
        Account portalAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        VehicleInfo__c v = new VehicleInfo__c();
            v.Name = 'TEST11';
        v.vehicleManagementNumber__c = '12312312';
        v.newCarFlag__c = 'LDT';
        v.mileage__C = 1234;
        v.lastWorkshopCode__c = '1';
        v.carPlatformNo__c = 'FA-TEST';
        v.vehicleInspectionExpiryDate__c = Date.today();
        v.userAccountCode__c = portalAccount.Id;
            //Name = '東京123-45567', 
           // userAccountCode__c = testAccount.siebelAccountCode__c, 
           // recordTypeId = cpCaseRecordTypeId,
           // vehicleInspectionExpiryDate__c = Date.today().addMonths(6) // Assuming this is a required date field
        
        insert v;
    }

    private static User getTestUser() {
        return [SELECT Id, Name FROM User WHERE Email = 'testuser@example.com' LIMIT 1];
    }

    @isTest
    static void testUserList() {
        User testUser = getTestUser();
        
        System.runAs(testUser) {
            Test.startTest();
            List<Contact> result = CCP2_userData.userList();
            Test.stopTest();
			System.debug(result);
            System.assertNotEquals(null, result, 'User list should not be null');
            //System.assert(result.size() > 0, 'User list should contain users');
        }
    }

    @isTest
    static void testUserDtl() {
        User testUser = getTestUser();
        Contact testContact = [SELECT Id FROM Contact WHERE Email = 'testcontact@example.com' LIMIT 1];
        
        System.runAs(testUser) {
            Test.startTest();
            List<Contact> result = CCP2_userData.userDtl(testContact.Id, true);
            Test.stopTest();

            System.assertNotEquals(null, result, 'User detail list should not be null');
            System.assert(result.size() > 0, 'User detail list should contain details');
        }
    }

    @isTest
    static void testUserDtlWithRefreshFalse() {
        User testUser = getTestUser();
        Contact testContact = [SELECT Id FROM Contact WHERE Email = 'testcontact@example.com' LIMIT 1];
        
        System.runAs(testUser) {
            Test.startTest();
            List<Contact> result = CCP2_userData.userDtl(testContact.Id, false);
            Test.stopTest();

            System.assertNotEquals(null, result, 'User detail list should not be null');
            System.assert(result.size() > 0, 'User detail list should contain details');
        }
    }

    @isTest
    static void testBranchList() {
        User testUser = getTestUser();
        
        Id accountId = [SELECT Contact.AccountId FROM User WHERE Id = :testUser.Id].Contact.AccountId;

        List<CCP2_Branch__c> branches = new List<CCP2_Branch__c>();
        for (Integer i = 0; i < 3; i++) {
            branches.add(new CCP2_Branch__c(Account__c = accountId, Name = 'Test Branch ' + i));
        }
        insert branches;
        
        System.runAs(testUser) {
            Test.startTest();
            List<CCP2_Branch__c> result = CCP2_userData.BranchList();
            Test.stopTest();

            System.assertNotEquals(null, result, 'Branch list should not be null');
          //  System.assertEquals(3, result.size(), 'Branch list should contain 3 branches');
            for (Integer i = 0; i < 3; i++) {
                System.assert(result[i].Name.contains('Test Branch'), 'Branch name should contain "Test Branch"');
            }
        }
    }

    @isTest
    static void testUnAssociatedBranch() {
        User testUser = getTestUser();
        
        System.runAs(testUser) {
            Test.startTest();
            List<CCP2_Branch__c> result = CCP2_userData.UnAssociatedBranch();
            Test.stopTest();

            System.assertNotEquals(null, result, 'Unassociated Branch list should not be null');
            // Add further assertions as needed
        }
    }

    @isTest
    static void testVehicleWithoutAssociation() {
        User testUser = getTestUser();
        
        System.runAs(testUser) {
            Test.startTest();
            List<VehicleInfo__c> result = CCP2_userData.VehicleWithoutAssociation();
            Test.stopTest();

            System.assertNotEquals(null, result, 'Vehicle list should not be null');
            // Add further assertions as needed
        }
    }

    @isTest
    static void testAccId() {
        User testUser = getTestUser();
        
        System.runAs(testUser) {
            Test.startTest();
            Id accountId = CCP2_userData.accId();
            Test.stopTest();

            System.assertNotEquals(null, accountId, 'Account Id should not be null');

            Account expectedAccount = [SELECT Id FROM Account WHERE Name = 'Test Account'];
            System.assertEquals(expectedAccount.Id, accountId, 'Account Id should match the test account Id');
        }
    }

    @isTest
    static void testBranchDetails() {
        User testUser = getTestUser();
        CCP2_Branch__c testBranch = [SELECT Id FROM CCP2_Branch__c LIMIT 1];
        
        System.runAs(testUser) {
            Test.startTest();
            List<CCP2_Branch__c> result = CCP2_userData.BranchDetails(testBranch.Id);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Branch details list should not be null');
            //System.assert(result.size() > 0, 'Branch details list should contain details');
        }
    }

    @isTest
    static void testNewBranchDetails() {
        User testUser = getTestUser();
        CCP2_Branch__c testBranch = [SELECT Id FROM CCP2_Branch__c LIMIT 1];
        
        System.runAs(testUser) {
            Test.startTest();
            Map<String, Object> result = CCP2_userData.NewBranchDetails(testBranch.Id);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Branch details map should not be null');
            System.assert(result.containsKey('BranchDetails'), 'Result map should contain branch details');
            System.assert(result.containsKey('Contacts'), 'Result map should contain contacts');
            System.assert(result.containsKey('Vehicles'), 'Result map should contain vehicles');
        }
    }

    @isTest
    static void testUserWithoutAssociation() {
        User testUser = getTestUser();
        
        System.runAs(testUser) {
            Test.startTest();
            List<Contact> result = CCP2_userData.UserWithoutAssociation();
            Test.stopTest();

            System.assertNotEquals(null, result, 'User list should not be null');
            System.assert(result.size() > 0, 'User list should contain users');
        }
    }

    @isTest
    static void testUnassociateVehicle() {
        User testUser = getTestUser();
        VehicleInfo__c testVehicle = [SELECT Id FROM VehicleInfo__c LIMIT 1];
        CCP2_Branch__c testBranch = [SELECT Id FROM CCP2_Branch__c LIMIT 1];

        System.runAs(testUser) {
            Test.startTest();
            CCP2_userData.unassociateVehicle(new List<Id>{testVehicle.Id}, testBranch.Id);
            Test.stopTest();

            // Verify that vehicle was unassociated
            List<CCP2_BranchVehicle_Junction__c> junctions = [SELECT Id FROM CCP2_BranchVehicle_Junction__c WHERE VehicleId__c = :testVehicle.Id];
            System.assertEquals(0, junctions.size(), 'Vehicle should be unassociated from the branch');
        }
    }

    //@isTest
    //static void testEditBranch() {
       // User testUser = getTestUser();
      //  CCP2_Branch__c testBranch = [SELECT Id FROM CCP2_Branch__c LIMIT 1];

        //CCP2_Branch__c updatedBranch = new CCP2_Branch__c(
            //Id = testBranch.Id,
            //Name = 'Updated Test Branch'
        //);

        //System.runAs(testUser) {
            //Test.startTest();
            //CCP2_userData.editBranch(new List<CCP2_Branch__c>{updatedBranch});
            //Test.stopTest();

            // Verify branch update
            //CCP2_Branch__c updatedBranchFromDB = [SELECT Name FROM CCP2_Branch__c WHERE Id = :testBranch.Id];
            //System.assertEquals('Updated Test Branch', updatedBranchFromDB.Name, 'Branch name should be updated');
        //}
    //}

    /*@isTest
    static void testSaveNewBranch() {
        User testUser = getTestUser();

        CCP2_Branch__c newBranch = new CCP2_Branch__c(
            Name = 'New Test Branch'
        );

        System.runAs(testUser) {
            Test.startTest();
            CCP2_userData.saveNewBranch(new List<CCP2_Branch__c>{newBranch});
            Test.stopTest();

            // Verify new branch creation
            CCP2_Branch__c createdBranch = [SELECT Name FROM CCP2_Branch__c WHERE Name = 'New Test Branch' LIMIT 1];
            System.assertNotEquals(null, createdBranch, 'New branch should be created');
        }
    }

    @isTest
    static void testContactList() {
        User testUser = getTestUser();
        
        Id accountId = [SELECT Contact.AccountId FROM User WHERE Id = :testUser.Id].Contact.AccountId;

        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 3; i++) {
            contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact' + i, Email = 'testcontact' + i + '@example.com', AccountId = accountId));
        }
        insert contacts;
        
        System.runAs(testUser) {
            Test.startTest();
            List<Contact> result = CCP2_userData.contactList();
            Test.stopTest();

            System.assertNotEquals(null, result, 'Contact list should not be null');
            System.assert(result.size() > 0, 'Contact list should contain contacts');
        }
    }*/
}