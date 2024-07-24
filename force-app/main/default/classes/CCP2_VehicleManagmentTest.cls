@isTest
public class CCP2_VehicleManagmentTest {

    @testSetup
    static void setupTestData() {
        // Create a Head Office Account
        Account headOffice = new Account(Name = 'Head Office', lbc_head_office_id__c = 'HO123');
        insert headOffice;

        // Create multiple Accounts related to the Head Office
        Account acc1 = new Account(Name = 'Branch 1', lbc_head_office_id__c = headOffice.lbc_head_office_id__c);
        Account acc2 = new Account(Name = 'Branch 2', lbc_head_office_id__c = headOffice.lbc_head_office_id__c);
        insert new List<Account>{acc1, acc2};

        // Create Contacts related to the Accounts
        Contact con1 = new Contact(FirstName = 'Test1', LastName = 'Contact1', AccountId = acc1.Id);
        Contact con2 = new Contact(FirstName = 'Test2', LastName = 'Contact2', AccountId = acc2.Id);
        insert new List<Contact>{con1, con2};

        // Create a User related to one of the Contacts
        Profile p = [SELECT Id FROM Profile WHERE Name='FUSO Customer Community Plus Login User'];
        User portalUser = new User(
            Alias = 'testuser',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'testuserVM@example.com' + System.currentTimeMillis(),
            ContactId = con1.Id
        );
        insert portalUser;

        // Create VehicleInfo__c records
        VehicleInfo__c vehicle1 = new VehicleInfo__c(Name = 'Vehicle 1', carPlatformNo__c = 'CPN789', registrationNumberSequence__c = 123, userAccountCode__c = acc1.Id, vehicleInspectionExpiryDate__c = Date.today().addYears(1));
        VehicleInfo__c vehicle2 = new VehicleInfo__c(Name = 'Vehicle 2', carPlatformNo__c = 'CPN012', registrationNumberSequence__c = 456, userAccountCode__c = acc2.Id, vehicleInspectionExpiryDate__c = Date.today().addYears(1));
        insert new List<VehicleInfo__c>{vehicle1, vehicle2};

        // Create ccp2_Registered_Vehicle__c records
        ccp2_Registered_Vehicle__c regVehicle1 = new ccp2_Registered_Vehicle__c(Vehicle_Number__c = 'Reg Vehicle 1', Chassis_number__c = 'CH123', Account__c = acc1.Id);
        ccp2_Registered_Vehicle__c regVehicle2 = new ccp2_Registered_Vehicle__c(Vehicle_Number__c = 'Reg Vehicle 2', Chassis_number__c = 'CH456', Account__c = acc2.Id);
        insert new List<ccp2_Registered_Vehicle__c>{regVehicle1, regVehicle2};
    }            

    @isTest
    static void testGetAccountId() {
        // Fetch the test user created during test setup
        User portalUser = [SELECT Id FROM User WHERE Username LIKE 'testuserVM%' LIMIT 1];

        // Run the test as the portal user
        System.runAs(portalUser) {
            // Fetch the Account ID using the method to be tested
            Id accountId = CCP2_VehicleManagment.getAccountId();

            // Fetch the Contact to verify the correct Account ID
            User testUser = [SELECT Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

            // Validate the result
            System.assertNotEquals(null, accountId, 'The Account ID should not be null.');
            System.assertEquals(testUser.Contact.AccountId, accountId, 'The Account ID should match the expected value.');
        }
    }

    @isTest
    static void testAllVehicleList() {
        // Fetch the test user created during test setup
        User portalUser = [SELECT Id FROM User WHERE Username LIKE 'testuserVM%' LIMIT 1];

        // Run the test as the portal user
        System.runAs(portalUser) {
            // Fetch the list of vehicles using the method to be tested
            List<SObject> allVehicles = CCP2_VehicleManagment.allVehicleList();

            // Validate the result
            System.assertNotEquals(0, allVehicles.size(), 'The list of vehicles should not be empty.');
            System.assertEquals(4, allVehicles.size(), 'The list should contain 4 vehicles (2 VehicleInfo__c and 2 ccp2_Registered_Vehicle__c).');

            // Check if the list contains instances of VehicleInfo__c and ccp2_Registered_Vehicle__c
            Integer vehicleInfoCount = 0;
            Integer regVehicleCount = 0;
            for (SObject vehicle : allVehicles) {
                if (vehicle instanceof VehicleInfo__c) {
                    vehicleInfoCount++;
                } else if (vehicle instanceof ccp2_Registered_Vehicle__c) {
                    regVehicleCount++;
                }
            }

            System.assertEquals(2, vehicleInfoCount, 'The list should contain 2 VehicleInfo__c records.');
            System.assertEquals(2, regVehicleCount, 'The list should contain 2 ccp2_Registered_Vehicle__c records.');
        }
    }

    @isTest
    static void testVehicleByChassis() {
        // Define test chassis numbers
        List<String> testChassisNumbers = new List<String>{'CH123', 'CH456', 'CPN789', 'CPN012', 'UNKNOWN'};
        List<String> testChassisNumbersEmpty = new List<String>{};
        // Call the method to be tested
        Test.startTest();
        Map<String, List<Map<String, Object>>> result = CCP2_VehicleManagment.vehicleByChassis(testChassisNumbers);
        Map<String, List<Map<String, Object>>> resultEmpty = CCP2_VehicleManagment.vehicleByChassis(testChassisNumbersEmpty);
        Test.stopTest();

        // Verify the result
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.containsKey('Registered Vehicle'), 'Result should contain "Registered Vehicle" key');
        System.assert(result.containsKey('Vehicle Info'), 'Result should contain "Vehicle Info" key');

        // Check for empty
        List<Map<String, Object>> regVehicleResultsEmpty = resultEmpty.get('Registered Vehicle');
        System.debug('Registered Vehicle Results: ' + regVehicleResultsEmpty);
        System.assertEquals(0, regVehicleResultsEmpty.size());

        // Check the "Registered Vehicle" results
        List<Map<String, Object>> regVehicleResults = result.get('Registered Vehicle');
        System.debug('Registered Vehicle Results: ' + regVehicleResults);
        System.assertEquals(2, regVehicleResults.size(), 'There should be 2 registered vehicles');

        Set<String> expectedRegChassisNumbers = new Set<String>{'CH123', 'CH456'};
        for (Map<String, Object> regVehicle : regVehicleResults) {
            System.assert(expectedRegChassisNumbers.contains((String)regVehicle.get('Chassis_number__c')), 'Registered vehicle chassis number should be in the expected set');
            // Optionally, validate other fields like Registration_Number__c
            // System.assertEquals('RN123', regVehicle.get('Registration_Number__c'), 'Registration number should match');
        }

        // Check the "Vehicle Info" results
        List<Map<String, Object>> vehicleInfoResults = result.get('Vehicle Info');
        System.assertEquals(2, vehicleInfoResults.size(), 'There should be 2 vehicle info records');

        Set<String> expectedVehicleChassisNumbers = new Set<String>{'CPN789', 'CPN012'};
        for (Map<String, Object> vehicleInfo : vehicleInfoResults) {
            System.assert(expectedVehicleChassisNumbers.contains((String)vehicleInfo.get('carPlatformNo__c')), 'Vehicle info chassis number should be in the expected set');
        }
    }

   @isTest
static void testVehicleNotRegistered() {
    // Define test chassis numbers
    List<String> testChassisNumbers = new List<String>{'CH123', 'CH456', 'CPN789', 'CPN012', 'UNKNOWN'};

    // Call the method to be tested
    Test.startTest();
    Map<String, List<Map<String, Object>>> result = CCP2_VehicleManagment.vehicleNotRegistered(testChassisNumbers);
    Test.stopTest();

    // Verify the result
    System.assertNotEquals(null, result, 'Result should not be null');
    System.assert(result.containsKey('VehicleInfo'), 'Result should contain "VehicleInfo" key');

    // Check the "VehicleInfo" results
    List<Map<String, Object>> vehicleInfoResults = result.get('VehicleInfo');
    System.assertEquals(2, vehicleInfoResults.size(), 'There should be 2 vehicle info records');

    // Check expected values for each vehicle info record
    Map<String, Object> vehicle1 = findVehicleByChassis(vehicleInfoResults, 'CPN789');
    System.assertNotEquals(null, vehicle1, 'Vehicle 1 should be present');
    System.assertEquals('Vehicle 1', vehicle1.get('Name'), 'Vehicle 1 Name should match');
    System.assertEquals('CPN789', vehicle1.get('carPlatformNo__c'), 'Vehicle 1 Chassis Number should match');
    System.assertEquals(123, vehicle1.get('registrationNumberSequence__c'), 'Vehicle 1 Registration Number Sequence should match');
    Map<String, Object> vehicle2 = findVehicleByChassis(vehicleInfoResults, 'CPN012');
    System.assertNotEquals(null, vehicle2, 'Vehicle 2 should be present');
    System.assertEquals('Vehicle 2', vehicle2.get('Name'), 'Vehicle 2 Name should match');
    System.assertEquals('CPN012', vehicle2.get('carPlatformNo__c'), 'Vehicle 2 Chassis Number should match');
    System.assertEquals(456, vehicle2.get('registrationNumberSequence__c'), 'Vehicle 2 Registration Number Sequence should match');
    }

private static Map<String, Object> findVehicleByChassis(List<Map<String, Object>> vehicles, String chassis) {
    for (Map<String, Object> vehicle : vehicles) {
        if (vehicle.get('carPlatformNo__c') == chassis) {
            return vehicle;
        }
    }
    return null;
}
    
    @isTest
static void testBranchList() {
    // Create test account
    Account testAccount = new Account(Name = 'Test Account');
    insert testAccount;

    // Create test branches
    CCP2_Branch__c branch1 = new CCP2_Branch__c(Name = 'Branch 1', Account__c = testAccount.Id);
    CCP2_Branch__c branch2 = new CCP2_Branch__c(Name = 'Branch 2', Account__c = testAccount.Id);
    insert new List<CCP2_Branch__c> { branch1, branch2 };

    // Create test contact and user associated with the account
    Contact testContact = new Contact(LastName = 'Test', AccountId = testAccount.Id);
    insert testContact;

    Profile p = [SELECT Id FROM Profile WHERE Name='FUSO Customer Community Plus Login User'];
    User testUser = new User(
        Alias = 'testuser',
        Email = 'testuser@example.com',
        EmailEncodingKey = 'UTF-8',
        LastName = 'Test',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = p.Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        UserName = 'testuser999@example.com' + System.currentTimeMillis(),
        ContactId = testContact.Id
    );
    insert testUser;

    // Run test in context of the test user
    System.runAs(testUser) {
        Test.startTest();
        List<CCP2_Branch__c> branches = CCP2_VehicleManagment.branchList();
        Test.stopTest();

        // Assertions to validate the results
        System.assertNotEquals(0, branches.size(), 'The list of branches should not be empty.');
        System.assertEquals(2, branches.size(), 'The list should contain 2 branches.');
       }
}
    
    
    @isTest
static void testInsertRegisteredVehicles() {
    // Create test account
    Account testAccount = new Account(Name = 'Test Account');
    insert testAccount;

    // Create test branches
    CCP2_Branch__c branch1 = new CCP2_Branch__c(Name = 'Branch 1', Account__c = testAccount.Id);
    CCP2_Branch__c branch2 = new CCP2_Branch__c(Name = 'Branch 2', Account__c = testAccount.Id);
    insert new List<CCP2_Branch__c> { branch1, branch2 };

    // Create test contact and user associated with the account
    Contact testContact = new Contact(LastName = 'Test', AccountId = testAccount.Id);
    insert testContact;

    Profile p = [SELECT Id FROM Profile WHERE Name='FUSO Customer Community Plus Login User'];
    User testUser = new User(
        Alias = 'testuser',
        Email = 'testuser@example.com',
        EmailEncodingKey = 'UTF-8',
        LastName = 'Test',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = p.Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        UserName = 'testuser999@example.com' + System.currentTimeMillis(),
        ContactId = testContact.Id
    );
    insert testUser;

    // Run test in context of the test user
    System.runAs(testUser) {
        Test.startTest();

        // Prepare JSON input
        String jsonInput = '[{"carPlatformNoPart1": "CPN789", "carPlatformNoPart2": "012", "loginNumberPart1": "123", "loginNumberPart2": "456", "loginNumberPart3": "789", "loginNumberPart4": "012", "model1": "ModelX", "model2": "2024", "bodyShape": "Sedan", "dateOfIssuance": "2023-07-20", "carName": "Test Car", "initialRegistrationDate": "2023-07-20", "vehicleNumber": "VN123", "expirationDate": "2025-07-20", "curbWeight": 1500, "privateOrBusinessUse": "Private", "use": "Personal", "mileage": 1000, "typeOfVehicle": "TypeX", "doorNumber": 4, "worklocation": "Test Location", "affiliation": ["' + branch1.Id + '", "' + branch2.Id + '"]}]';
        String jsonStrings = '["imageData1", "imageData2"]'; // Replace with appropriate test data

        // Call the method
        CCP2_VehicleManagment.insertRegisteredVehicles(jsonInput, jsonStrings);

        // Verify the results
        List<ccp2_Registered_Vehicle__c> insertedVehicles = [SELECT Id, Vehicle_Name__c FROM ccp2_Registered_Vehicle__c WHERE Vehicle_Name__c = 'Test Car'];
        System.assertEquals(1, insertedVehicles.size(), 'One vehicle should have been inserted');
        ccp2_Registered_Vehicle__c insertedVehicle = insertedVehicles[0];
        System.assertEquals('Test Car', insertedVehicle.Vehicle_Name__c, 'Vehicle name should match');

        List<CCP2_BranchVehicle_Junction__c> junctionRecords = [SELECT Id, VehicleId__c, BranchId__c FROM CCP2_BranchVehicle_Junction__c WHERE VehicleId__c = :insertedVehicle.Id];
        System.assertEquals(2, junctionRecords.size(), 'Two junction records should have been inserted');
        
        Test.stopTest();
    }
}


    @isTest
static void testGetContactByBranch() {
    // Create test account
    Account testAccount = new Account(Name = 'Test Account');
    insert testAccount;

    // Create test branches
    CCP2_Branch__c branch1 = new CCP2_Branch__c(Name = 'Branch 1', Account__c = testAccount.Id);
    insert branch1;

    // Create test contacts
    Contact contact1 = new Contact(FirstName = 'John', LastName = 'Doe', AccountId = testAccount.Id);
    Contact contact2 = new Contact(FirstName = 'Jane', LastName = 'Smith', AccountId = testAccount.Id);
    insert new List<Contact> { contact1, contact2 };

    // Create junction objects between branch and contacts
    CCP2_BranchContact_Junction__c junction1 = new CCP2_BranchContact_Junction__c(BranchId__c = branch1.Id, ContactId__c = contact1.Id);
    CCP2_BranchContact_Junction__c junction2 = new CCP2_BranchContact_Junction__c(BranchId__c = branch1.Id, ContactId__c = contact2.Id);
    insert new List<CCP2_BranchContact_Junction__c> { junction1, junction2 };

    Test.startTest();

    // Call the method
    List<Contact> contacts = CCP2_VehicleManagment.getContactByBranch(branch1.Id);

    // Verify the results
    System.assertEquals(2, contacts.size(), 'Two contacts should have been retrieved');
    Set<Id> contactIds = new Set<Id>();
    for (Contact con : contacts) {
        contactIds.add(con.Id);
    }
    System.assert(contactIds.contains(contact1.Id), 'Contact 1 should be retrieved');
    System.assert(contactIds.contains(contact2.Id), 'Contact 2 should be retrieved');

    Test.stopTest();
}

    @isTest
static void testGetVehicleByBranch() {
    // Create test account
    Account testAccount = new Account(Name = 'Test Account');
    insert testAccount;

    // Create test branches
    CCP2_Branch__c branch1 = new CCP2_Branch__c(Name = 'Branch 1', Account__c = testAccount.Id);
    insert branch1;

    // Create test vehicles
    ccp2_Registered_Vehicle__c vehicle1 = new ccp2_Registered_Vehicle__c(Vehicle_Number__c = 'Vehicle 1', Account__c = testAccount.Id);
    ccp2_Registered_Vehicle__c vehicle2 = new ccp2_Registered_Vehicle__c(Vehicle_Number__c = 'Vehicle 2', Account__c = testAccount.Id);
    insert new List<ccp2_Registered_Vehicle__c> { vehicle1, vehicle2 };

    // Create junction objects between branch and vehicles
    CCP2_BranchVehicle_Junction__c junction1 = new CCP2_BranchVehicle_Junction__c(BranchId__c = branch1.Id, VehicleId__c = vehicle1.Id);
    CCP2_BranchVehicle_Junction__c junction2 = new CCP2_BranchVehicle_Junction__c(BranchId__c = branch1.Id, VehicleId__c = vehicle2.Id);
    insert new List<CCP2_BranchVehicle_Junction__c> { junction1, junction2 };

    Test.startTest();

    // Call the method
    List<ccp2_Registered_Vehicle__c> vehicles = CCP2_VehicleManagment.getVehicleByBranch(branch1.Id);

    // Verify the results
    System.assertEquals(2, vehicles.size(), 'Two vehicles should have been retrieved');
    Set<Id> vehicleIds = new Set<Id>();
    for (ccp2_Registered_Vehicle__c veh : vehicles) {
        vehicleIds.add(veh.Id);
    }
    System.assert(vehicleIds.contains(vehicle1.Id), 'Vehicle 1 should be retrieved');
    System.assert(vehicleIds.contains(vehicle2.Id), 'Vehicle 2 should be retrieved');

    Test.stopTest();
}
    
    @isTest
static void testInsertBranchVehicleJunctions() {
    // Create test account
    Account testAccount = new Account(Name = 'Test Account');
    insert testAccount;

    // Create test branches
    CCP2_Branch__c branch1 = new CCP2_Branch__c(Name = 'Branch 1', Account__c = testAccount.Id);
    CCP2_Branch__c branch2 = new CCP2_Branch__c(Name = 'Branch 2', Account__c = testAccount.Id);
    insert new List<CCP2_Branch__c> { branch1, branch2 };

    // Create test vehicles
    ccp2_Registered_Vehicle__c vehicle1 = new ccp2_Registered_Vehicle__c(Vehicle_Number__c = 'Vehicle 1', Account__c = testAccount.Id);
    ccp2_Registered_Vehicle__c vehicle2 = new ccp2_Registered_Vehicle__c(Vehicle_Number__c = 'Vehicle 2', Account__c = testAccount.Id);
    ccp2_Registered_Vehicle__c vehicle3 = new ccp2_Registered_Vehicle__c(Vehicle_Number__c = 'Vehicle 3', Account__c = testAccount.Id);
    insert new List<ccp2_Registered_Vehicle__c> { vehicle1, vehicle2, vehicle3 };

    // Create JSON input
    String jsonBranchVehicle = '[{"branch":"'+branch1.Id+'","vehicles":["'+vehicle1.Id+'","'+vehicle2.Id+'"]},{"branch":"'+branch2.Id+'","vehicles":["'+vehicle2.Id+'","'+vehicle3.Id+'"]}]';

    Test.startTest();

    // Call the method
    CCP2_VehicleManagment.insertBranchVehicleJunctions(jsonBranchVehicle);

    Test.stopTest();

    // Verify the results
    List<CCP2_BranchVehicle_Junction__c> junctions = [SELECT Id, BranchId__c, VehicleId__c FROM CCP2_BranchVehicle_Junction__c];
    System.assertEquals(4, junctions.size(), 'Four junctions should have been created');

    Set<Id> expectedBranchIds = new Set<Id> { branch1.Id, branch2.Id };
    Set<Id> expectedVehicleIds = new Set<Id> { vehicle1.Id, vehicle2.Id, vehicle3.Id };

    for (CCP2_BranchVehicle_Junction__c junction : junctions) {
        System.assert(expectedBranchIds.contains(junction.BranchId__c), 'Branch ID should be correct');
        System.assert(expectedVehicleIds.contains(junction.VehicleId__c), 'Vehicle ID should be correct');
    }
}

    
    @isTest
static void testInsertBranchContactJunctions() {
    // Create test accounts and branches
    Account testAccount = new Account(Name = 'Test Account');
    insert testAccount;

    CCP2_Branch__c branch1 = new CCP2_Branch__c(Name = 'Branch 1', Account__c = testAccount.Id);
    CCP2_Branch__c branch2 = new CCP2_Branch__c(Name = 'Branch 2', Account__c = testAccount.Id);
    insert new List<CCP2_Branch__c> { branch1, branch2 };

    // Create test contacts
    Contact contact1 = new Contact(FirstName = 'John', LastName = 'Doe', AccountId = testAccount.Id);
    Contact contact2 = new Contact(FirstName = 'Jane', LastName = 'Doe', AccountId = testAccount.Id);
    Contact contact3 = new Contact(FirstName = 'Alice', LastName = 'Smith', AccountId = testAccount.Id);
    insert new List<Contact> { contact1, contact2, contact3 };

    // Create JSON input
    String jsonBranchContact = '[{"branch":"'+branch1.Id+'","users":["'+contact1.Id+'","'+contact2.Id+'"]},{"branch":"'+branch2.Id+'","users":["'+contact2.Id+'","'+contact3.Id+'"]}]';

    Test.startTest();

    // Call the method
    CCP2_VehicleManagment.insertBranchContactJunctions(jsonBranchContact);

    Test.stopTest();

    // Verify the results
    List<CCP2_BranchContact_Junction__c> junctions = [SELECT Id, BranchId__c, ContactId__c FROM CCP2_BranchContact_Junction__c];
    System.assertEquals(4, junctions.size(), 'Four junctions should have been created');

    Set<Id> expectedBranchIds = new Set<Id> { branch1.Id, branch2.Id };
    Set<Id> expectedContactIds = new Set<Id> { contact1.Id, contact2.Id, contact3.Id };

    for (CCP2_BranchContact_Junction__c junction : junctions) {
        System.assert(expectedBranchIds.contains(junction.BranchId__c), 'Branch ID should be correct');
        System.assert(expectedContactIds.contains(junction.ContactId__c), 'Contact ID should be correct');
    }
}

 @isTest
static void testVehicleInput() {
    Account testAccount = new Account(Name = 'Test Account');
    insert testAccount;
    
    // Create and insert a test branch
    CCP2_Branch__c testBranch = new CCP2_Branch__c(Name = 'Test Branch', Account__c = testAccount.Id);
    insert testBranch;

    // Create and insert a test registered vehicle
    ccp2_Registered_Vehicle__c testVehicle = new ccp2_Registered_Vehicle__c(
        Body_Shape__c = 'Sedan',
        Delivery_Date__c = Date.today(),
        Registration_Number__c = '123-456-789',
        Vehicle_Name__c = 'Test Vehicle',
        Chassis_number__c = 'CH123',
        First_Registration_Date__c = Date.today().addYears(-1),
        fullModel__c = '2023-Model',
        Vehicle_Number__c = 'Test Vehicle Name',
        Vehicle_Expiration_Date__c = String.valueOf(Date.today().addYears(1)),
        vehicleWeight__c = String.valueOf(1500),
        Private_Business_use__c = 'Private',
        Use__c = 'Personal',
        Mileage__c = 12000,
        Vehicle_Type__c = 'Sedan',
        Door_Number__c = '4',
        Work_Location__c = 'Location A',
        Account__c = testAccount.Id
    );
    insert testVehicle;

    // Create and insert a junction record for the vehicle and branch
    CCP2_BranchVehicle_Junction__c branchVehicleJunction = new CCP2_BranchVehicle_Junction__c(
        BranchId__c = testBranch.Id,
        VehicleId__c = testVehicle.Id
    );
    insert branchVehicleJunction;

    Test.startTest();
    
    // Call the method to be tested
    List<Map<String, Object>> result = CCP2_VehicleManagment.vehicleinput('CH123'); // Replace YourApexClass with the actual class name
    
    Test.stopTest();

    // Validate the result
    System.assertNotEquals(0, result.size(), 'The result should not be empty.');
	}
    
    @isTest
static void testBranchExceptMine() {
    // Create and insert test accounts
    Account testAccount1 = new Account(Name = 'Test Account 1');
    Account testAccount2 = new Account(Name = 'Test Account 2');
    insert new List<Account>{ testAccount1, testAccount2 };

    // Create and insert test branches for account 1
    CCP2_Branch__c testBranch1 = new CCP2_Branch__c(Name = 'Branch 1', Account__c = testAccount1.Id);
    CCP2_Branch__c testBranch2 = new CCP2_Branch__c(Name = 'Branch 2', Account__c = testAccount1.Id);
    insert new List<CCP2_Branch__c>{ testBranch1, testBranch2 };

    // Create and insert test branches for account 2
    CCP2_Branch__c testBranch3 = new CCP2_Branch__c(Name = 'Branch 3', Account__c = testAccount2.Id);
    insert testBranch3;

    // Set the current user's Account ID to be testAccount1.Id
    // Simulate the behavior of getAccountId()
    Test.startTest();
    
    // You need to ensure that the getAccountId method returns testAccount1.Id in your test class
    // This requires making getAccountId() method available or using a different approach to mock its behavior

    // Call the method to be tested
    List<CCP2_Branch__c> result = CCP2_VehicleManagment.branchExceptMine(testBranch1.Id); // Replace YourApexClass with the actual class name
    
    Test.stopTest();

    // Check that Branch 1 is not in the result
    for (CCP2_Branch__c branch : result) {
        System.assertNotEquals(testBranch1.Id, branch.Id, 'Branch 1 should not be in the result.');
    }

    Boolean branch2Found = false;
    for (CCP2_Branch__c branch : result) {
        if (branch.Id == testBranch2.Id) {
            branch2Found = true;
            break;
        }
    }
    // Check that Branch 3 is not in the result (since it belongs to a different account)
    Boolean branch3Found = false;
    for (CCP2_Branch__c branch : result) {
        if (branch.Id == testBranch3.Id) {
            branch3Found = true;
            break;
        }
    }
    System.assert(!branch3Found, 'Branch 3 should not be in the result.');
}


}