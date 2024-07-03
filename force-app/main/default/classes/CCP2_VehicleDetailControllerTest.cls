@isTest
public class CCP2_VehicleDetailControllerTest {
    @testSetup
    static void setup() {
        Account account = new Account(Name = 'Test1 Account');
        insert account;
        
        VehicleInfo__c testVehicle = new VehicleInfo__c(
            VehicleBrandName__c = 'Test Brand',
            Registration_Year__c = '2021',
            Mileage__c = 10000,
            ChassisNumberVIN__c = '1HGBH41JXMN109186',
            LastArrivalDateTime__c = Date.today(),
            BodyMakerNo__c = 'BM123',
            BodyShape__c = 'Sedan',
            DatefronInitialRegistrationDate__c = 20210601,
            InitialRegistrationDate__c = Date.newInstance(2021, 6, 1),
            vehicleInspectionExpiryDate__c =  Date.newInstance(2024, 1, 15),
            userAccountCode__c = account.Id
        );
        
        insert testVehicle;
    }

    @isTest
    static void testGetVehicleById() {

        VehicleInfo__c testVehicle = [SELECT Id FROM VehicleInfo__c LIMIT 1];
        
        Test.startTest();
        List<VehicleInfo__c> result = CCP2_VehicleDetailController.getVehicleById(testVehicle.Id);
        Test.stopTest();
        
        System.assertEquals(1, result.size(), 'Expected exactly one record to be returned');
        VehicleInfo__c returnedVehicle = result[0];
        
        System.assertEquals(testVehicle.Id, returnedVehicle.Id, 'Vehicle Id should match');
        System.assertEquals('Test Brand', returnedVehicle.VehicleBrandName__c, 'Vehicle Brand Name should match');
        System.assertEquals('2021', returnedVehicle.Registration_Year__c, 'Registration Year should match');
        System.assertEquals(10000, returnedVehicle.Mileage__c, 'Mileage should match');
        System.assertEquals('1HGBH41JXMN109186', returnedVehicle.ChassisNumberVIN__c, 'Chassis Number VIN should match');
        System.assertEquals(Date.today(), returnedVehicle.LastArrivalDateTime__c, 'Last Arrival DateTime should match');
        System.assertEquals('BM123', returnedVehicle.BodyMakerNo__c, 'Body Maker No should match');
        System.assertEquals('Sedan', returnedVehicle.BodyShape__c, 'Body Shape should match');
        System.assertEquals(20210601, returnedVehicle.DatefronInitialRegistrationDate__c, 'Date From Initial Registration should match');
        System.assertEquals(Date.newInstance(2021, 6, 1), returnedVehicle.InitialRegistrationDate__c, 'Initial Registration Date should match');
    }
}