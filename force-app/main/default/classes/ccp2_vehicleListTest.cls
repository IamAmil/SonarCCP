@isTest
public class ccp2_vehicleListTest {
@testSetup
static void setup() {
    Account account = new Account(Name = 'Test Account');
    insert account;

    RecordType vehicleRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'VehicleInfo__c' AND DeveloperName = 'vehicle'];
    RecordType customerRegisteredRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'VehicleInfo__c' AND DeveloperName = 'CustomerRegisteredVehicle'];

    Contact contact = new Contact(LastName = 'Test Contact', AccountId = account.Id, canManageMember__c = true);
    insert contact;

    Profile portalProfile;
    try {
        portalProfile = [SELECT Id FROM Profile WHERE Name = 'FUSO Customer Community Plus Login User' LIMIT 1];
    } catch (Exception e) {
        System.debug('No profile found with the name FUSO Customer Community Plus Login User');
        return;
    }

    String orgId = UserInfo.getOrganizationId();
    String dateString = String.valueOf(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
    Integer RandomId = Integer.valueOf(Math.rint(Math.random() * 1000000));
    String uniqueName = orgId + dateString + RandomId;

    User portalUser = new User(
        Alias = 'tstusr',
        Email = uniqueName + '@test.com',
        EmailEncodingKey = 'UTF-8',
        LastName = 'Testing',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = portalProfile.Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        UserName = uniqueName + '@test.com',
        ContactId = contact.Id
    );
    insert portalUser;

    VehicleInfo__c vehicle1 = new VehicleInfo__c(
        Name = 'Vehicle 1',
        RecordTypeId = vehicleRecordType.Id,
        brand__c = 'FUSO',
        userAccountCode__c = account.Id,
        vehicleInspectionExpiryDate__c = Date.newInstance(2024, 1, 15)
    );
    insert vehicle1;
}


@isTest
static void testGetVehicleInfoWithAdminFlag() {
    User portalUser = [SELECT Id FROM User WHERE UserName LIKE '%@test.com' LIMIT 1];
    Contact contact = [SELECT Id, canManageMember__c FROM Contact LIMIT 1];
    contact.canManageMember__c = true;
    update contact;
    
    System.runAs(portalUser) {
        List<String> carModels = new List<String>{};
        List<String> brandModels = new List<String>{};

        Test.startTest();
        List<VehicleInfo__c> vehicleInfoList = ccp2_vehicleList.getVehicleInfo(carModels, brandModels);
        System.assertNotEquals(0, vehicleInfoList.size());
        Test.stopTest();
        
    }
}


    @isTest
    static void testGetVehicleInfoWithoutAdminFlag() {
        Contact contact = [SELECT Id, canManageMember__c FROM Contact LIMIT 1];
        contact.canManageMember__c = false;
        update contact;

        User portalUser = [SELECT Id FROM User WHERE UserName LIKE '%@test.com' LIMIT 1];
        System.runAs(portalUser) {
            List<String> carModels = new List<String>{};
            List<String> brandModels = new List<String>{};

            Test.startTest();
            List<VehicleInfo__c> vehicleInfoList = ccp2_vehicleList.getVehicleInfo(carModels, brandModels);
            Test.stopTest();

            System.assertNotEquals(0, vehicleInfoList.size(), 'VehicleInfo list should not be empty');
        }
    }

    @isTest
    static void testGetVehicleInfoWithNoFilters() {
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE '%@test.com' LIMIT 1];
        System.runAs(portalUser) {
            Test.startTest();
            List<VehicleInfo__c> vehicleInfoList = ccp2_vehicleList.getVehicleInfo(new List<String>(), new List<String>());
            Test.stopTest();

            System.assertNotEquals(0, vehicleInfoList.size(), 'VehicleInfo list should not be empty');
        }
    }

    @isTest
    static void testGetVehicleInfoWithFilters() {
        User portalUser = [SELECT Id FROM User WHERE UserName LIKE '%@test.com' LIMIT 1];
        System.runAs(portalUser) {
            List<String> carModels = new List<String>{};
            List<String> brandModels = new List<String>{};

            Test.startTest();
            List<VehicleInfo__c> vehicleInfoList = ccp2_vehicleList.getVehicleInfo(carModels, brandModels);
            Test.stopTest();

            System.assertNotEquals(0, vehicleInfoList.size(), 'VehicleInfo list should not be empty');
        }
    }
}