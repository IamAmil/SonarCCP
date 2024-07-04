public with sharing class ccp2_UIpermissionList {
    

 @AuraEnabled
    public static void updateRecords(String uiSRJson) {
        List<Object> fieldMapListRaw = (List<Object>) JSON.deserializeUntyped(uiSRJson);
        System.debug(fieldMapListRaw);

        if (fieldMapListRaw.isEmpty()) {
            throw new AuraHandledException('Input JSON is empty');
        }

        Map<String, Object> fieldMap = (Map<String, Object>) fieldMapListRaw[0];
        System.debug(fieldMap);

        Id userId = (Id) fieldMap.get('userId');
        if (userId == null) {
            throw new AuraHandledException('userId is missing in the input JSON');
        }

        List<CCP2_Access_Control__c> accessList = [
            SELECT Id, Name, Basic_Service_EC_Flag__c, Cost_management_Flag__c, E_invoice_Flag__c,
                   Financial_service_Flag__c, Online_maintenance_booking_Flag__c, Vehicle_management_Flag__c
            FROM CCP2_Access_Control__c 
            WHERE Name = :userId
            LIMIT 1
        ];
        System.debug(accessList);

        if (accessList.isEmpty()) {
            throw new AuraHandledException('No access control record found for the given userId');
        }

        CCP2_Access_Control__c accessControl = accessList[0];

        // Map the JSON keys to the corresponding fields
        Map<String, String> fieldMapping = new Map<String, String>{
            'FUSO_CCP_External_E_invoice_new' => '外部電子請求書',
            'FUSO_CCP_External_Financial_service' => '外部金融サービス',
            'FUSO_CCP_External_Basic_Service_EC' => '基本サービス（ふそうショップ）',
            'FUSO_CCP_External_Cost_management' => 'コスト管理',
            'FUSO_CCP_External_Online_maintenance_booking' => 'オンラインメンテナンス予約',
            'FUSO_CCP_External_Vehicle_management' => '車両管理'
        };

        // Update the fields based on the input JSON
        for (String key : fieldMapping.keySet()) {
            String fieldName = fieldMapping.get(key);
            if (fieldMap.containsKey(fieldName)) {
                Boolean fieldValue = (Boolean) fieldMap.get(fieldName);
                if (key == 'FUSO_CCP_External_E_invoice_new') {
                    accessControl.E_invoice_Flag__c = fieldValue;
                } else if (key == 'FUSO_CCP_External_Financial_service') {
                    accessControl.Financial_service_Flag__c = fieldValue;
                } else if (key == 'FUSO_CCP_External_Basic_Service_EC') {
                    accessControl.Basic_Service_EC_Flag__c = fieldValue;
                } else if (key == 'FUSO_CCP_External_Cost_management') {
                    accessControl.Cost_management_Flag__c = fieldValue;
                } else if (key == 'FUSO_CCP_External_Online_maintenance_booking') {
                    accessControl.Online_maintenance_booking_Flag__c = fieldValue;
                } else if (key == 'FUSO_CCP_External_Vehicle_management') {
                    accessControl.Vehicle_management_Flag__c = fieldValue;
                }
            }
        }

        // Perform the update
        try {
            System.debug(accessControl);
            update accessControl;
            System.debug('Access control record updated successfully: ' + accessControl.Id);
        } catch (DmlException e) {
            CCP2_HandlerForException.LogException(e);
            System.debug('An error occurred while updating the access control record: ' + e.getMessage());
            throw new AuraHandledException('Error updating access control record: ' + e.getMessage());
        }
    }
     @AuraEnabled(cacheable=true)
    public static List<String> uiPermissionList(Id userId,Integer refresh) {
        // Query the access control record for the given user ID
       // if(refresh){
        List<CCP2_Access_Control__c> accessList = [
            SELECT Name, Basic_Service_EC_Flag__c, Cost_management_Flag__c, E_invoice_Flag__c,
                   Financial_service_Flag__c, Online_maintenance_booking_Flag__c, Vehicle_management_Flag__c
            FROM CCP2_Access_Control__c 
            WHERE Name = :userId
            LIMIT 1
        ];
        System.debug(accessList);
        List<String> activePermissions = new List<String>();

        if (!accessList.isEmpty()) {
            CCP2_Access_Control__c accessControl = accessList[0];
            if (accessControl.Basic_Service_EC_Flag__c) {
                activePermissions.add('基本サービス（ふそうショップ）');
            }
            if (accessControl.Cost_management_Flag__c) {
                activePermissions.add('費用管理');
            }
            if (accessControl.E_invoice_Flag__c) {
                activePermissions.add('部整月次請求書（電子版）');
            }
            if (accessControl.Financial_service_Flag__c) {
                activePermissions.add('金融サービス');
            }
            if (accessControl.Online_maintenance_booking_Flag__c) {
                activePermissions.add('車検入庫予約');
            }
            if (accessControl.Vehicle_management_Flag__c) {
                activePermissions.add('車両管理');
            }
        }

        // Return the list of active permissions
        System.debug(activePermissions);
        return activePermissions;
   /* }
    
    else{
        List<CCP2_Access_Control__c> accessList = [
            SELECT Name, Basic_Service_EC_Flag__c, Cost_management_Flag__c, E_invoice_Flag__c,
                   Financial_service_Flag__c, Online_maintenance_booking_Flag__c, Vehicle_management_Flag__c
            FROM CCP2_Access_Control__c 
            WHERE Name = :userId
            LIMIT 1
        ];
        System.debug(accessList);
        List<String> activePermissions = new List<String>();

        if (!accessList.isEmpty()) {
            CCP2_Access_Control__c accessControl = accessList[0];
            if (accessControl.Basic_Service_EC_Flag__c) {
                activePermissions.add('基本サービス（ふそうショップ）');
            }
            if (accessControl.Cost_management_Flag__c) {
                activePermissions.add('費用管理');
            }
            if (accessControl.E_invoice_Flag__c) {
                activePermissions.add('部整月次請求書（電子版）');
            }
            if (accessControl.Financial_service_Flag__c) {
                activePermissions.add('金融サービス');
            }
            if (accessControl.Online_maintenance_booking_Flag__c) {
                activePermissions.add('車検入庫予約');
            }
            if (accessControl.Vehicle_management_Flag__c) {
                activePermissions.add('車両管理');
            }
        }

        // Return the list of active permissions
        System.debug(activePermissions);
        return activePermissions;
    }*/
    }
}