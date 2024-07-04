public with sharing class CCP2_ServicesList {
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> permissionValues(Id userId,Integer refresh) {
        if(userId == null){
            throw new AuraHandledException('Input is empty');
        }
        List<CCP2_Access_Control__c> accessList = [
            SELECT Name, Basic_Service_EC_Flag__c, Cost_management_Flag__c, E_invoice_Flag__c,
                   Financial_service_Flag__c, Online_maintenance_booking_Flag__c, Vehicle_management_Flag__c
            FROM CCP2_Access_Control__c 
            WHERE Name = :userId
            LIMIT 1
        ];
        System.debug('userId'+userId);
        System.debug('accessList'+accessList);
        List<String> activePermissions = new List<String>();
		Boolean x=!accessList.isEmpty();
        System.debug('x'+!accessList.isEmpty());
        if (!accessList.isEmpty()) {
            CCP2_Access_Control__c accessControl = accessList[0];
            if (accessControl.Basic_Service_EC_Flag__c) {
                activePermissions.add('Basic_Service_EC_Flag__c');
            }
            if (accessControl.Cost_management_Flag__c) {
                activePermissions.add('Cost_management_Flag__c');
            }
            if (accessControl.E_invoice_Flag__c) {
                activePermissions.add('E_invoice_Flag__c');
            }
            if (accessControl.Financial_service_Flag__c) {
                activePermissions.add('Financial_service_Flag__c');
            }
            if (accessControl.Online_maintenance_booking_Flag__c) {
                activePermissions.add('Online_maintenance_booking_Flag__c');
            }
            if (accessControl.Vehicle_management_Flag__c) {
                activePermissions.add('Vehicle_management_Flag__c');
            }
        }

        List<Map<String, Object>> permissionStatusList = new List<Map<String, Object>>();
        Map<String, String> permissionMap = new Map<String, String>{
            'Basic_Service_EC_Flag__c' => '基本サービス（ふそうショップ）',
            'Cost_management_Flag__c' => '費用管理',
            'E_invoice_Flag__c' => '部整月次請求書（電子版）',
            'Financial_service_Flag__c' => '金融サービス',
            'Online_maintenance_booking_Flag__c' => '車検入庫予約',
            'Vehicle_management_Flag__c' => '車両管理'
        };

        for (String apiName : permissionMap.keySet()) {
            Map<String, Object> permissionStatus = new Map<String, Object>();
            permissionStatus.put('apiName', apiName);
            permissionStatus.put('japaneseName', permissionMap.get(apiName));
            permissionStatus.put('isActive', activePermissions.contains(apiName));
            permissionStatusList.add(permissionStatus);
        }
		System.debug(permissionStatusList);
        return permissionStatusList;
    }
}