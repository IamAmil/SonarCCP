public with sharing class ccp2_vehicleList {
    private static Id getAccountId(){
        Id portalUserId = UserInfo.getUserId();
        System.debug(portalUserId);
        Id accountId = null;
        List<User> portalUser = [SELECT ContactId FROM User WHERE Id = :portalUserId];
        if (portalUser.size() > 0 && portalUser[0].ContactId != null) {
            List<Contact> contacts = [SELECT AccountId FROM Contact WHERE Id = :portalUser[0].ContactId];
            if (contacts.size() > 0 && contacts[0].AccountId != null) {
                accountId = contacts[0].AccountId;
            }
        }
        return accountId;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<VehicleInfo__c> getVehicleInfo(List<String> CarModel, List<String> brandModel) {
        Id accountId = getAccountId();
        //Id accountId = '001Io000003IIw3IAG'; 
        Boolean adminFlag = false; // Default value in case no records are found
        List<Contact> contacts = [SELECT canManageMember__c FROM Contact WHERE AccountId = :accountId LIMIT 1];
		
        if (!contacts.isEmpty()) {
            adminFlag = contacts[0].canManageMember__c;
        }
        System.debug(adminFlag);
        System.debug(contacts);
        System.debug(accountId);

        ID vehicleRecordTypeId = Schema.SObjectType.VehicleInfo__c.getRecordTypeInfosByDeveloperName().get('vehicle').getRecordTypeId();
        ID customerRegisteredRecordTypeId = Schema.SObjectType.VehicleInfo__c.getRecordTypeInfosByDeveloperName().get('CustomerRegisteredVehicle').getRecordTypeId();
        
        String queryString = 'SELECT Id, Name, VehiclebrandName__c, Customer_Name__c, Mileage__c, lastArrivalDateTime__c, vehicleInspectionExpiryDate__c, TruckImg__c, carModelFormatName__c, newCarFlag__c, vehicleManagementNumber__c, ' +
                             'carPlatformNo__c, RecordType.Name, initialRegistrationDate__c, brand__c ' +
                             'FROM VehicleInfo__c ' +
                             'WHERE (RecordTypeId = :vehicleRecordTypeId OR RecordTypeId = :customerRegisteredRecordTypeId) ';
                             
        if (adminFlag) {
            queryString += 'AND userAccountCode__c = :accountId ';
        }
        
        if (!CarModel.isEmpty() || !brandModel.isEmpty()) {
            queryString += 'AND (';
            
            if (!CarModel.isEmpty()) {
                queryString += 'carModelFormatName__c IN :CarModel ';
            }
            
            if (!CarModel.isEmpty() && !brandModel.isEmpty()) {
                queryString += 'AND ';
            }
            
            if (!brandModel.isEmpty()) {
                queryString += 'brand__c IN :brandModel ';
            }
            
            queryString += ') ';
        }
                       
        List<VehicleInfo__c> vehicleInfoList = Database.query(queryString);
        System.debug(vehicleInfoList);
        return vehicleInfoList;
    }
}