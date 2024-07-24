//updateRecords
//branchContactDelete
//branchContactAdd
//deleteUser
//permissionValuesAccessControl
//updateAccessRecords 
//uiPermissionList
//permissionValues
//updateAccessControl
//callMethodPermissionSet
//createAndAssociateBranch
public with sharing class CCP2_userController {
    @AuraEnabled
    //@future
    public static void updateRecords(String uiFieldJson) {
        System.debug(uiFieldJson);
        //String input = uiFieldJson;
        // Deserialize the JSON string into a list of maps
        List<Object> fieldMapListRaw = (List<Object>) JSON.deserializeUntyped(uiFieldJson);
        
		System.debug(fieldMapListRaw);
        
        System.debug(fieldMapListRaw.isEmpty());
        if (fieldMapListRaw.isEmpty()) {
            throw new AuraHandledException('Input JSON is empty');
        }

        // Assuming the list contains maps
        Map<String, Object> fieldMap = (Map<String, Object>) fieldMapListRaw[0];

        // Maintain the existing logic of using ccp2_filedmap
        Map<String, String> updatedFieldMap = new Map<String, String>();
        for (String uiFieldKey : fieldMap.keySet()) {
            Object uiFieldValueObj = fieldMap.get(uiFieldKey);
            String uiFieldValue = uiFieldValueObj != null ? String.valueOf(uiFieldValueObj) : null; // Convert to String

            // Get the corresponding Salesforce field name
            String sfFieldKey = ccp2_filedmap.uiFieldInput(uiFieldKey);
            if (sfFieldKey != null) {
                updatedFieldMap.put(sfFieldKey, uiFieldValue);
            } else {
                updatedFieldMap.put(uiFieldKey, uiFieldValue);
            }
        }
        System.debug('Updated Field Map: ' + updatedFieldMap);

        String contactId = updatedFieldMap.get('ContactId');
        if (String.isBlank(contactId)) {
            throw new AuraHandledException('ContactId is required');
        }

        Contact contactToUpdate;
        try {
            contactToUpdate = [SELECT Id, FirstName, LastName, Email, Title, Employee_Code__c, MobilePhone, Phone, firstNameKana__c, lastNameKana__c, Department
                               FROM Contact 
                               WHERE Id = :contactId 
                               LIMIT 1];
            System.debug('Contact to Update: ' + contactToUpdate);
        } catch (Exception e) {
            throw new AuraHandledException('Contact not found');
        }

        // Update fields if they exist in the map
        if (updatedFieldMap.containsKey('FirstName')) {
            contactToUpdate.FirstName = updatedFieldMap.get('FirstName');
        }
        if (updatedFieldMap.containsKey('LastName')) {
            contactToUpdate.LastName = updatedFieldMap.get('LastName');
        }
        if (updatedFieldMap.containsKey('Department')) {
            contactToUpdate.Department = updatedFieldMap.get('Department');
        }
        if (updatedFieldMap.containsKey('Email')) {
            contactToUpdate.Email = updatedFieldMap.get('Email');
        }
        if (updatedFieldMap.containsKey('Phone')) {
            contactToUpdate.Phone = updatedFieldMap.get('Phone');
        }
        if (updatedFieldMap.containsKey('MobilePhone')) {
            contactToUpdate.MobilePhone = updatedFieldMap.get('MobilePhone');
        }
        if (updatedFieldMap.containsKey('firstNameKana__c')) {
            contactToUpdate.firstNameKana__c = updatedFieldMap.get('firstNameKana__c');
        }
        /*if (updatedFieldMap.containsKey('Branch__c')) {
            contactToUpdate.Branch__c = updatedFieldMap.get('Branch__c');
        }*/
        if (updatedFieldMap.containsKey('Title')) {
            contactToUpdate.Title = updatedFieldMap.get('Title');
        }
        if (updatedFieldMap.containsKey('Employee_Code__c')) {
            contactToUpdate.Employee_Code__c = updatedFieldMap.get('Employee_Code__c');
        }
        if (updatedFieldMap.containsKey('lastNameKana__c')) {
            contactToUpdate.lastNameKana__c = updatedFieldMap.get('lastNameKana__c');
        }
        if (updatedFieldMap.containsKey('mostLikelyWeekdayStartTimesForAppoint__c')) {
            String timeString = updatedFieldMap.get('mostLikelyWeekdayStartTimesForAppoint__c');
            
            // Convert the string to an integer representing milliseconds
            Long milliseconds = Long.valueOf(timeString);

            // Calculate hours, minutes, seconds, and milliseconds
            Integer hours = (Integer)(milliseconds / (1000 * 60 * 60));
            Long remainingMillisAfterHours = milliseconds - (hours * 1000 * 60 * 60);

            Integer minutes = (Integer)(remainingMillisAfterHours / (1000 * 60));
            Long remainingMillisAfterMinutes = remainingMillisAfterHours - (minutes * 1000 * 60);

            Integer seconds = (Integer)(remainingMillisAfterMinutes / 1000);
            Integer millis = (Integer)(remainingMillisAfterMinutes - (seconds * 1000));
            // Create the Time object
            Time timeValue = Time.newInstance(hours, minutes, seconds, millis);

            // Assign the Time object to the contact field
            contactToUpdate.mostLikelyWeekdayStartTimesForAppoint__c = timeValue;
        }
        if (updatedFieldMap.containsKey('mostLikelyWeekdayEndTimesForAppoint__c')) {
            String timeString = updatedFieldMap.get('mostLikelyWeekdayEndTimesForAppoint__c');
            
            // Convert the string to an integer representing milliseconds
            Long milliseconds = Long.valueOf(timeString);

            // Calculate hours, minutes, seconds, and milliseconds
            Integer hours = (Integer)(milliseconds / (1000 * 60 * 60));
            Long remainingMillisAfterHours = milliseconds - (hours * 1000 * 60 * 60);

            Integer minutes = (Integer)(remainingMillisAfterHours / (1000 * 60));
            Long remainingMillisAfterMinutes = remainingMillisAfterHours - (minutes * 1000 * 60);

            Integer seconds = (Integer)(remainingMillisAfterMinutes / 1000);
            Integer millis = (Integer)(remainingMillisAfterMinutes - (seconds * 1000));
            // Create the Time object
            Time timeValue = Time.newInstance(hours, minutes, seconds, millis);

            // Assign the Time object to the contact field
            contactToUpdate.mostLikelyWeekdayEndTimesForAppoint__c = timeValue;
        }
        if (updatedFieldMap.containsKey('mostLikelyHolidayStartTimesForAppoint__c')) {
			String timeString = updatedFieldMap.get('mostLikelyHolidayStartTimesForAppoint__c');
            
            // Convert the string to an integer representing milliseconds
            Long milliseconds = Long.valueOf(timeString);

            // Calculate hours, minutes, seconds, and milliseconds
            Integer hours = (Integer)(milliseconds / (1000 * 60 * 60));
            Long remainingMillisAfterHours = milliseconds - (hours * 1000 * 60 * 60);

            Integer minutes = (Integer)(remainingMillisAfterHours / (1000 * 60));
            Long remainingMillisAfterMinutes = remainingMillisAfterHours - (minutes * 1000 * 60);

            Integer seconds = (Integer)(remainingMillisAfterMinutes / 1000);
            Integer millis = (Integer)(remainingMillisAfterMinutes - (seconds * 1000));
            // Create the Time object
            Time timeValue = Time.newInstance(hours, minutes, seconds, millis);

            // Assign the Time object to the contact field
            contactToUpdate.mostLikelyHolidayStartTimesForAppoint__c = timeValue;
        }
        if (updatedFieldMap.containsKey('mostLikelyHolidayEndTimesForAppoint__c')) {
			String timeString = updatedFieldMap.get('mostLikelyHolidayEndTimesForAppoint__c');
            
            // Convert the string to an integer representing milliseconds
            Long milliseconds = Long.valueOf(timeString);

            // Calculate hours, minutes, seconds, and milliseconds
            Integer hours = (Integer)(milliseconds / (1000 * 60 * 60));
            Long remainingMillisAfterHours = milliseconds - (hours * 1000 * 60 * 60);

            Integer minutes = (Integer)(remainingMillisAfterHours / (1000 * 60));
            Long remainingMillisAfterMinutes = remainingMillisAfterHours - (minutes * 1000 * 60);

            Integer seconds = (Integer)(remainingMillisAfterMinutes / 1000);
            Integer millis = (Integer)(remainingMillisAfterMinutes - (seconds * 1000));
            // Create the Time object
            Time timeValue = Time.newInstance(hours, minutes, seconds, millis);

            // Assign the Time object to the contact field
            contactToUpdate.mostLikelyHolidayEndTimesForAppoint__c = timeValue;
        }

        try {
            System.debug('Final Contact to Update: ' + contactToUpdate);
            update contactToUpdate;
        } catch (Exception e) {
             CCP2_HandlerForException.LogException(e);
            throw new AuraHandledException('Error updating Contact record: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
        public static void branchContactDelete(Id contactId, List<Id> branchesToDelete) {
        if (!branchesToDelete.isEmpty()) {
            // Fetch child records to be deleted
            List<CCP2_BranchContact_Junction__c> childRecords = [
                SELECT Id, ContactId__c, BranchId__c 
                FROM CCP2_BranchContact_Junction__c 
                WHERE ContactId__c = :contactId AND BranchId__c IN :branchesToDelete
            ];

            if (!childRecords.isEmpty()) {
                try {
                    delete childRecords;
                } catch (Exception e) {
                    CCP2_HandlerForException.LogException(e);
                    throw new AuraHandledException('Failed to delete Branch records: ' + e.getMessage());
                }
            }
        }
    }
    
    @AuraEnabled
    public static void branchContactAdd(Id contactId, List<Id> branchesToAdd) {
        List<CCP2_BranchContact_Junction__c> branchRecords = new List<CCP2_BranchContact_Junction__c>();

        // Iterate through the branches list and create Branch records
        for (Id branchId : branchesToAdd) {
            CCP2_BranchContact_Junction__c branch = new CCP2_BranchContact_Junction__c();
            branch.BranchId__c = branchId;
            branch.ContactId__c = contactId;
            branchRecords.add(branch);
        }

        // Insert the Branch records if there are any
        if (!branchRecords.isEmpty()) {
            try {
                insert branchRecords;
            } catch (Exception e) {
                CCP2_HandlerForException.LogException(e);
                throw new AuraHandledException('Failed to insert Branch records: ' + e.getMessage());
            }
        }
    }
    
    @AuraEnabled
    public static void deleteUser(String contactId) {
        try {
            // Query the Contact record based on the given contactId
            Contact contact = [SELECT Id, OwnerId, UserId__c, ccpUseFlag__c FROM Contact WHERE Id = :contactId LIMIT 1];
            System.debug(contact);
            contact.ccpUseFlag__c = false;
      		 System.debug(contact.ccpUseFlag__c);
            update contact;
            // Check if the Contact has an associated User record
            if (contact.UserId__c != null) {
                // Query the UserLogin record based on the UserId
                UserLogin userLogin = [SELECT Id, IsFrozen FROM UserLogin WHERE UserId = :contact.UserId__c LIMIT 1];
                System.debug(userLogin);
                
                // Freeze the User by setting the IsFrozen field to true
                userLogin.IsFrozen = true;
                update userLogin;
                System.debug('User record frozen successfully for user ID: ' + contact.UserId__c);
            } else {
                System.debug('No associated User record found for contact ID: ' + contactId);
            }
        } catch (Exception e) {
             CCP2_HandlerForException.LogException(e);
            System.debug('An error occurred: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> permissionValuesAccessControl(Id userId, Integer refresh) {
        try {
            if (userId == null) {
                throw new AuraHandledException('Input is empty');
            }
            
            List<CCP2_Access_Control__c> accessList = [
                SELECT Name, Basic_Service_EC_Flag__c, Cost_management_Flag__c, E_invoice_Flag__c,
                       Financial_service_Flag__c, Online_maintenance_booking_Flag__c, Vehicle_management_Flag__c
                FROM CCP2_Access_Control__c 
                WHERE Name = :userId
                LIMIT 1
            ];
            
            System.debug('userId: ' + userId);
            System.debug('accessList: ' + accessList);
            
            List<String> activePermissions = new List<String>();
            Boolean x = !accessList.isEmpty();
            System.debug('x: ' + x);
            
            if (!accessList.isEmpty()) {
                CCP2_Access_Control__c accessControl = accessList[0];
                
                /*if (accessControl.Basic_Service_EC_Flag__c) {
                    activePermissions.add('Basic_Service_EC_Flag__c');
                }*/
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
                //'Basic_Service_EC_Flag__c' => '基本サービス（ふそうショップ）',
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
        } catch (Exception e) {
            CCP2_HandlerForException.LogException(e);
            throw new AuraHandledException('An error occurred: ' + e.getMessage());
        }
    }
    
    //Contactupdate method is used instead updateAccessRecords
    @AuraEnabled
    public static void updateAccessRecords(String uiSRJson) {
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
        } catch (Exception e) {
            CCP2_HandlerForException.LogException(e);
            System.debug('An error occurred while updating the access control record: ' + e.getMessage());
            throw new AuraHandledException('Error updating access control record: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
	public static List<String> uiPermissionList(Id userId, Integer refresh) {
    	try {
        // Query the access control record for the given user ID
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
    } catch (Exception e) {
        CCP2_HandlerForException.LogException(e);
        System.debug('An error occurred: ' + e.getMessage());
        throw new AuraHandledException('An error occurred while fetching permissions: ' + e.getMessage());
    }
	}
    
    @AuraEnabled
    public static void updateAccessControl(CCP2_Access_Control__c con) {
        try {
            System.debug(con);
            CCP2_Access_Control__c result = [SELECT Id, E_invoice_flag__c, Financial_service_Flag__c, 
                                             Basic_Service_EC_Flag__c, Cost_management_Flag__c, 
                                             Online_maintenance_booking_Flag__c, Vehicle_management_Flag__c 
                                             FROM CCP2_Access_Control__c 
                                             WHERE Name = :con.Name 
                                             LIMIT 1];
 
            // Update fields based on the input CCP2_Access_Control__c record
            if (result != null) {
                result.E_invoice_flag__c = con.E_invoice_flag__c;
                result.Financial_service_Flag__c = con.Financial_service_Flag__c;
                //result.Basic_Service_EC_Flag__c = con.Basic_Service_EC_Flag__c;
                result.Online_maintenance_booking_Flag__c = con.Online_maintenance_booking_Flag__c;
                result.Vehicle_management_Flag__c = con.Vehicle_management_Flag__c;
                result.Cost_management_Flag__c = con.Cost_management_Flag__c;
                
                System.debug(result);
                update result;
                
                Id userId = con.Name;  
            Boolean bsChecked = con.Basic_Service_EC_Flag__c;
            Boolean eiChecked = con.E_invoice_flag__c;
            Boolean fsChecked = con.Financial_service_Flag__c;
            Boolean ombChecked = con.Online_maintenance_booking_Flag__c;
            Boolean vmChecked = con.Vehicle_management_Flag__c;
            Boolean cmChecked = con.Cost_management_Flag__c;
                    
                System.debug('CCP2_Access_Control__c updated successfully: ' + result.Id);
            } else {
                System.debug('No CCP2_Access_Control__c record found with Name: ' + con.Name);
            }
        } catch (Exception e) {
            CCP2_HandlerForException.LogException(e);
            System.debug('Error updating CCP2_Access_Control__c: ' + e.getMessage());
        }
    }
    
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
        } catch (Exception e) {
             CCP2_HandlerForException.LogException(e);
            System.debug('An error occurred while inserting/updating the access control record: ' + e.getMessage());
            throw new AuraHandledException('Error inserting/updating access control record: ' + e.getMessage());
           
        }
    }
    
    @InvocableMethod(label='userId' description ='userId')
    public static void callMethodPermissionSet(List<Id> userId){
       permissionValues(userId[0]);  
    }
    
    @AuraEnabled
    public static Void createAndAssociateBranch(CCP2_Access_Control__c con){
        Id userId = con.Name;  
            Boolean bsChecked = con.Basic_Service_EC_Flag__c;
            Boolean eiChecked = con.E_invoice_flag__c;
            Boolean fsChecked = con.Financial_service_Flag__c;
            Boolean ombChecked = con.Online_maintenance_booking_Flag__c;
            Boolean vmChecked = con.Vehicle_management_Flag__c;
            Boolean cmChecked = con.Cost_management_Flag__c;
   
        List<PermissionSet> permissionSets = [Select Id, Name from permissionSet where Name IN ('E_invoice','FUSO_CCP_External_Financial_service','Direct_Booking','FUSO_CCP_External_Cost_management','FUSO_CCP_External_Online_maintenance_booking','FUSO_CCP_External_Vehicle_management')];
        List<Id> permissionSetIds = new List<Id>();
            for (PermissionSet ps : permissionSets) {
                permissionSetIds.add(ps.Id);
            }
        
        PermissionSet bsCheck = [Select Id from permissionSet where Name = 'Direct_Booking'];
        Id bsCheckedId = bsCheck.Id;
        PermissionSet eiCheck = [Select Id from permissionSet where Name = 'E_invoice'];
        Id eiCheckedId = eiCheck.Id;
        PermissionSet fsCheck = [Select Id from permissionSet where Name = 'FUSO_CCP_External_Financial_service'];
        Id fsCheckedId = fsCheck.Id;
        PermissionSet ombCheck = [Select Id from permissionSet where Name = 'FUSO_CCP_External_Online_maintenance_booking'];
        Id ombCheckedId = ombCheck.Id;
        PermissionSet vmCheck = [Select Id from permissionSet where Name = 'FUSO_CCP_External_Vehicle_management'];
        Id vmCheckedId = vmCheck.Id;
        PermissionSet cmCheck = [Select Id from permissionSet where Name = 'FUSO_CCP_External_Cost_management'];
        Id cmCheckedId = cmCheck.Id;
        
        List<PermissionSetAssignment> psaList = [SELECT Id,AssigneeId,PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :userId and PermissionSetId IN:permissionSetIds ];
        System.debug(psaList);
           if (!psaList.isEmpty()) {
                try {
                    //psaList[0].AssigneeId = null;
                    System.debug(psaList[0].AssigneeId);
                    Delete psaList;
                } catch (Exception e) {
                        CCP2_HandlerForException.LogException(e);
                        System.debug('An error occurred while deleting PermissionSetAssignment record: ' + e.getMessage());
                }
        } 
        else {
            System.debug('No PermissionSetAssignment record found for user ID: ' + userId);
        	}
        try{
             System.debug('No1');
            if(bsChecked){
                PermissionSetAssignment vsa = new PermissionSetAssignment(PermissionSetId = bsCheckedId, AssigneeId = userId);
                insert vsa;
            }
             if(eiChecked){
                PermissionSetAssignment vsa = new PermissionSetAssignment(PermissionSetId = eiCheckedId, AssigneeId = userId);
                insert vsa;
            }
             if(fsChecked){
                PermissionSetAssignment vsa = new PermissionSetAssignment(PermissionSetId = fsCheckedId, AssigneeId = userId);
                insert vsa;
            }
             if(ombChecked){
                PermissionSetAssignment vsa = new PermissionSetAssignment(PermissionSetId = ombCheckedId, AssigneeId = userId);
                insert vsa;
            }
             if(vmChecked){
                PermissionSetAssignment vsa = new PermissionSetAssignment(PermissionSetId = vmCheckedId, AssigneeId = userId);
                insert vsa;
            }
             if(cmChecked){
                PermissionSetAssignment vsa = new PermissionSetAssignment(PermissionSetId = cmCheckedId, AssigneeId = userId);
                insert vsa;
            }
         }
             catch(Exception e){
            throw new DmlException('setPermissionSetforUser error :'+e.getMessage());
        }
     }
     @AuraEnabled
     public static Id getAccountId(){
        Id returnValue = null;
        User portalUser = [SELECT ContactId, Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        if (portalUser != null && portalUser.ContactId != null) {
            returnValue = portalUser.Contact.AccountId;
        }
        return returnValue;
    }
    @AuraEnabled(cacheable=true)
    public static List<Contact> adminUser() {
    Id accId = getAccountId();
    //Id accId='001Io000003ITP2IAO';
    List<Contact> adminList = [SELECT Id, Name FROM Contact WHERE ccpUseFlag__c = true and canManageMember__c = false AND AccountId = :accId];
    System.debug(adminList);
        return adminList;
}
    
	@AuraEnabled(cacheable=true)
	public static Map<String, Object> userBasicInfo(String ContactId,Integer refresh) {
    Map<String, Object> userInfo = new Map<String, Object>();
	/*List<User> userList = [SELECT ContactId FROM User WHERE Id = :UserId];
        String reqId = userList[0].ContactId;
        System.debug('ContactId: ' + reqId);*/
    List<Contact> contactInfoList = [SELECT Id, FirstName, LastName, firstNameKana__c, lastNameKana__c, Department, Title, Email, Phone, MobilePhone,
                                     Account.Name, Account.siebelAccountCode__c, mostLikelyWeekdayStartTimesForAppoint__c, mostLikelyWeekdayEndTimesForAppoint__c, 
                                     mostLikelyHolidayStartTimesForAppoint__c, mostLikelyHolidayEndTimesForAppoint__c, Employee_Code__c
                                     FROM Contact WHERE Id = :ContactId];

    if (!contactInfoList.isEmpty()) {
        Contact contactInfo = contactInfoList[0];
        
        // Add contact information to userInfo map
        userInfo.put('Id', String.valueOf(contactInfo.Id));
        userInfo.put('FirstName', String.valueOf(contactInfo.FirstName));
        userInfo.put('LastName', String.valueOf(contactInfo.LastName));
        userInfo.put('FirstNameKana', String.valueOf(contactInfo.firstNameKana__c));
        userInfo.put('LastNameKana', String.valueOf(contactInfo.lastNameKana__c));
        userInfo.put('Department', String.valueOf(contactInfo.Department));
        userInfo.put('Title', String.valueOf(contactInfo.Title));
        userInfo.put('Email', String.valueOf(contactInfo.Email));
        userInfo.put('Phone', String.valueOf(contactInfo.Phone));
        userInfo.put('MobilePhone', String.valueOf(contactInfo.MobilePhone));
        userInfo.put('AccountName', String.valueOf(contactInfo.Account.Name));
        userInfo.put('AccountSiebelAccountCode', String.valueOf(contactInfo.Account.siebelAccountCode__c));
        userInfo.put('MostLikelyWeekdayStartTimesForAppoint', contactInfo.mostLikelyWeekdayStartTimesForAppoint__c);
        userInfo.put('MostLikelyWeekdayEndTimesForAppoint', contactInfo.mostLikelyWeekdayEndTimesForAppoint__c);
        userInfo.put('MostLikelyHolidayStartTimesForAppoint', contactInfo.mostLikelyHolidayStartTimesForAppoint__c);
        userInfo.put('MostLikelyHolidayEndTimesForAppoint', contactInfo.mostLikelyHolidayEndTimesForAppoint__c);
        userInfo.put('EmployeeCode', String.valueOf(contactInfo.Employee_Code__c));
    }

    List<CCP2_BranchContact_Junction__c> branchIds = [SELECT BranchId__c FROM CCP2_BranchContact_Junction__c WHERE ContactId__c = :ContactId];
    List<Id> branchIdList = new List<Id>();

    for (CCP2_BranchContact_Junction__c branchContact : branchIds) {
        branchIdList.add(branchContact.BranchId__c);
    }
    List<CCP2_Branch__c> branchNameList = [SELECT Name FROM CCP2_Branch__c WHERE Id IN :branchIdList];
    List<String> branchNames = new List<String>();
    for (CCP2_Branch__c branch : branchNameList) {
        branchNames.add(String.valueOf(branch.Name));
    }
    userInfo.put('BranchNames', branchNames);

    System.debug(userInfo);
    return userInfo;
}
    @AuraEnabled
    public static void createAdmin(String oldAdmin, String newAdmin) {
    try {
        List<Contact> oldAdminList = [SELECT Id, canManageMember__c FROM Contact WHERE Id = :oldAdmin LIMIT 1];
        System.debug(oldAdminList);
        if (!oldAdminList.isEmpty()) {
            Contact oldAdminUpdate = oldAdminList[0];
            oldAdminUpdate.canManageMember__c = false;
            try {
                update oldAdminUpdate;
            } catch (DmlException e) {
                System.debug('Error updating old admin: ' + e.getMessage());
            }
        }
        
        List<Contact> newAdminList = [SELECT Id, canManageMember__c FROM Contact WHERE Id = :newAdmin LIMIT 1];
        if (!newAdminList.isEmpty()) {
            Contact newAdminUpdate = newAdminList[0];
            newAdminUpdate.canManageMember__c = true;
            try {
                update newAdminUpdate;
            } catch (DmlException e) {
                System.debug('Error updating new admin: ' + e.getMessage());
            }
        }
        
        List<CCP2_BranchContact_Junction__c> oldAdminBranchDeleteJunction = [SELECT Id FROM CCP2_BranchContact_Junction__c WHERE ContactId__c = :oldAdmin];
        if (!oldAdminBranchDeleteJunction.isEmpty()) {
            try {
                delete oldAdminBranchDeleteJunction;
            } catch (DmlException e) {
                System.debug('Error deleting old admin branch junction: ' + e.getMessage());
            }
        }
    } catch (Exception e) {
        System.debug('Error in createAdmin method: ' + e.getMessage());
    }
}
}