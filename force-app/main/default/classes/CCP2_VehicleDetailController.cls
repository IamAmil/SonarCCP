public with Sharing class CCP2_VehicleDetailController {
    @AuraEnabled(cacheable=true)
    public static List<VehicleInfo__c> getVehicleById(String vehicleId) {
        List<VehicleInfo__c> newList = new List<VehicleInfo__c>();
        try {
            newList = [SELECT Id, Name, VehicleBrandName__c, type__c, brand__c, mileage__c, vehicleManagementNumber__c,
                               exteriorColorSymbol__c, carPlatformNo__c, fullModel__c, lastArrivalDateTime__c, registeredDate__c, 
                               BodyMakerNo__c, bodyShape__c, initialRegistrationDate__c FROM VehicleInfo__c WHERE Id = :vehicleId];
        } catch (Exception e) {
            CCP2_HandlerForException.LogException(e);
            System.debug('An error occurred while fetching vehicle details: ' + e.getMessage());
        }
        //System.debug(newList);
        return newList;
    }
    /*public static List<VehicleInfo__c> upsertVehicle(String vehicleId){
        List<VehicleInfo__c> existingVehicles = [SELECT Id FROM VehicleInfo__c WHERE Id = :vehicleId];
        VehicleInfo__c vehicle;
        if (!existingVehicles.isEmpty()) {
            vehicle = existingVehicles[0];
            System.debug('A record with this Id already exists. It will be updated.');
        } else {
            vehicle = new VehicleInfo__c();
            System.debug('No record with this Id exists. A new record will be created.');
        }
        
        vehicle.VehicleBrandName__c = 'Test1 Brand';
        vehicle.Registration_Year__c = '2021';
        vehicle.Mileage__c = 6166;
        vehicle.ChassisNumberVIN__c = 'GEG-D76568GX';
        vehicle.userAccountCode__c = '001Io000003ITP2IAO';
        vehicle.vehicleInspectionExpiryDate__c = Date.today();
        vehicle.LastArrivalDateTime__c = Date.today();
        vehicle.BodyMakerNo__c = 'Cub12345';
        //vehicle.CarModelFormatName__c = '2021';
        vehicle.BodyShape__c = 'Mini Truck';
        //newVehicle.DateFronInitialRegistrationDate__c = Date.today();
        vehicle.InitialRegistrationOfJapaneseCalender__c = '2022/6/30';
        
         try {
            upsert vehicle;
            System.debug('Vehicle record upserted successfully.');
        } catch (DmlException e) {
            System.debug('An error occurred while inserting the vehicle record: ' + e.getMessage());
            throw e;
        }
        return existingVehicles;
   }*/
}