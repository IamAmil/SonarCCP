public with sharing class ccp2_userPermissionSet {
    @AuraEnabled
    public static void permissionValues(ID userId) {
        // Predefined permissions
        Set<String> predefinedPermissions = new Set<String>{
            //'FUSO_CCP_External_E_invoice_new',
            'E_invoice',
            'FUSO_CCP_External_Financial_service',
            //'FUSO_CCP_External_Basic_Service_EC',
            'Direct_Booking',
            'FUSO_CCP_External_Cost_management',
            'FUSO_CCP_External_Online_maintenance_booking',
            'FUSO_CCP_External_Vehicle_management'
        };

        // Query the user's permission set assignments
        List<PermissionSetAssignment> Listvalue = [
            SELECT Id, PermissionSetId, PermissionSet.Name, AssigneeId, Assignee.Name 
            FROM PermissionSetAssignment 
            WHERE AssigneeId = :userId
        ];
		System.debug(Listvalue);
        List<Map<String, Object>> permissionStatusList = new List<Map<String, Object>>();
        Map<String, Boolean> permissionMap = new Map<String, Boolean>();

        for (String permission : predefinedPermissions) {
            Map<String, Object> permissionStatus = new Map<String, Object>();
            permissionStatus.put('name', permission);
            permissionStatus.put('isActive', false);
			System.debug(permission);
            for (PermissionSetAssignment psa : Listvalue) {
                if (permission.equals(psa.PermissionSet.Name)) {
                    permissionStatus.put('isActive', true);
                    break;
                }
            }
            permissionStatusList.add(permissionStatus);
            permissionMap.put(permission, (Boolean) permissionStatus.get('isActive'));
        }

        System.debug(permissionStatusList);

        // Query for existing access control record
        CCP2_Access_Control__c existingRecord;
        try {
            existingRecord = [SELECT Id 
                              FROM CCP2_Access_Control__c 
                              WHERE Name = :userId
                              LIMIT 1];
        } catch (Exception e) {
            CCP2_HandlerForException.LogException(e);
            existingRecord = null;
        }

        // Create or update the access control record
        CCP2_Access_Control__c accessControlRecord = existingRecord != null ? existingRecord : new CCP2_Access_Control__c();
        accessControlRecord.Basic_Service_EC_Flag__c = permissionMap.get('Direct_Booking');
        accessControlRecord.Cost_management_Flag__c = permissionMap.get('FUSO_CCP_External_Cost_management');
        accessControlRecord.E_invoice_Flag__c = permissionMap.get('E_invoice');
        accessControlRecord.Financial_service_Flag__c = permissionMap.get('FUSO_CCP_External_Financial_service');
        accessControlRecord.Online_maintenance_booking_Flag__c = permissionMap.get('FUSO_CCP_External_Online_maintenance_booking');
        accessControlRecord.Vehicle_management_Flag__c = permissionMap.get('FUSO_CCP_External_Vehicle_management');
        accessControlRecord.Name = Listvalue[0].AssigneeId;

        try {
            if (existingRecord == null) {
                insert accessControlRecord;
                System.debug('Access control record inserted successfully: ' + accessControlRecord.Id);
            } else {
                update accessControlRecord;
                System.debug('Access control record updated successfully: ' + accessControlRecord.Id);
            }
        } catch (DmlException e) {
             CCP2_HandlerForException.LogException(e);
            System.debug('An error occurred while inserting/updating the access control record: ' + e.getMessage());
            throw new AuraHandledException('Error inserting/updating access control record: ' + e.getMessage());
           
        }
    }
}