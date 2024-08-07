//createBranch
//getBranchList
//updateBranchById
//addBranch
//deleteBranchById
public with sharing class CCP2_branchController {
    @AuraEnabled
    public static String createBranch(Id accId,Decimal BranchNO,String postalCode,String Prefecture,String municipalities,String streetAddress,String BuldingName, String companyName, String branchName, String telephoneNo, String cellPhoneNo, List<Id> contactIds, List<Id> vehicleIds) {
        List<CCP2_Branch__c> existingBranches = [SELECT Id FROM CCP2_Branch__c WHERE Account__c = :accId AND Name = :branchName];
        
        if (!existingBranches.isEmpty()) {
            //return 'Branch with the same name already exists';
            throw new AuraHandledException('Branch with the same name already exists.');
        } else {
            CCP2_Branch__c newBranch = new CCP2_Branch__c();
            newBranch.Account__c = accId;
            newBranch.Company_Name__c = companyName;
            newBranch.Name = branchName;
            //newBranch.Address__c = address;
            newBranch.Contact_No__c = telephoneNo;
            newBranch.cellPhone_No__c = cellPhoneNo;
            newBranch.Postal_Code__c = postalCode;
            newBranch.Prefecture__c = Prefecture;
            newBranch.Minicipalities__c = municipalities;
            newBranch.Street_Address__c = streetAddress;
            newBranch.Building_Name_Company_name__c = BuldingName;
            newBranch.Branch_Code__c = BranchNO;
            
            try {
                insert newBranch;
                System.debug('New Branch inserted successfully: ' + newBranch.Id);

                List<CCP2_BranchContact_Junction__c> junctionInserts = new List<CCP2_BranchContact_Junction__c>();
                for (Id contactId : contactIds) {
                    CCP2_BranchContact_Junction__c junction = new CCP2_BranchContact_Junction__c();
                    junction.BranchId__c = newBranch.Id;
                    junction.ContactId__c = contactId;
                    junctionInserts.add(junction);
                }
                insert junctionInserts;
                System.debug('Junction records inserted successfully.');
				//vehicle created in junction table
				List<CCP2_BranchVehicle_Junction__c> vehicleToInsert = new List<CCP2_BranchVehicle_Junction__c>();

                    for (Id vehicleId : vehicleIds) {
                    CCP2_BranchVehicle_Junction__c vehicleInsert = new CCP2_BranchVehicle_Junction__c();
                    vehicleInsert.VehicleId__c = vehicleId;
                    vehicleInsert.BranchId__c = newBranch.Id;
                    vehicleToInsert.add(vehicleInsert);
                    }
                insert vehicleToInsert;
                
                return 'Branch Created';
            } catch (Exception e) {
                CCP2_HandlerForException.LogException(e);
                
                throw new AuraHandledException('Error creating branch: ' + e.getMessage());
            }
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<Integer, Map<String, Object>> getBranchList() {
        //Id AccountId = '001Io000003ITP2IAO';
        Map<Integer, Map<String, Object>> branchList = new Map<Integer, Map<String, Object>>();
        
        try {
            Id accountId = [SELECT AccountId FROM User WHERE Id = :UserInfo.getUserId()].AccountId;

            List<CCP2_Branch__c> branches = [SELECT Id, Account__c, Name,Branch_Code__c FROM CCP2_Branch__c WHERE Account__c = :accountId ORDER BY CreatedDate ASC];
            
            Set<Id> branchIds = new Set<Id>();
            for (CCP2_Branch__c branch : branches) {
                branchIds.add(branch.Id);
            }

            Map<Id, Integer> vehicleCountMap = new Map<Id, Integer>();
            for (AggregateResult result : [SELECT BranchId__c, COUNT(Id) vehicleCount FROM CCP2_BranchVehicle_Junction__c WHERE BranchId__c IN :branchIds GROUP BY BranchId__c]) {
                vehicleCountMap.put((Id)result.get('BranchId__c'), (Integer)result.get('vehicleCount'));
            }

            Integer index = 0;
            for (CCP2_Branch__c branch : branches) {
                Map<String, Object> branchInfo = new Map<String, Object>();
                branchInfo.put('BranchId', branch.Id);
                branchInfo.put('BranchName', branch.Name);
                branchInfo.put('BranchNO', branch.Branch_Code__c);
                branchInfo.put('VehicleCount', vehicleCountMap.containsKey(branch.Id) ? vehicleCountMap.get(branch.Id) : 0);

                branchList.put(index, branchInfo);
                index++;
            }
        } catch (Exception e) {
            CCP2_HandlerForException.LogException(e);
            System.debug('General Exception: ' + e.getMessage());   
        }
        System.debug(branchList);
        return branchList;
    }
    
    /*@AuraEnabled
    public static void updateBranchById(Id branchId,String postalCode,String Prefecture,String municipalities,String streetAddress,String BuldingName, String contactNo, String branchName) {
        try {
            Id accId = getAccountId();
            //Id accId = '001Io000003ITP2IAO';
            CCP2_Branch__c queryList = [SELECT Id, Address__c, Contact_No__c, Name FROM CCP2_Branch__c WHERE Id = :branchId];
            
            if (postalCode != null) {
                queryList.Postal_Code__c = postalCode;
            }
            if (Prefecture != null) {
                queryList.Prefecture__c = Prefecture;
            }
            if (municipalities != null) {
                queryList.Minicipalities__c = municipalities;
            }
            if (streetAddress != null) {
                queryList.Street_Address__c = streetAddress;
            }
            if (BuldingName != null) {
                queryList.Building_Name_Company_name__c = BuldingName;
            }
            if (contactNo != null) {
                queryList.Contact_No__c = contactNo;
            }
            if (branchName != null) {
            	List<CCP2_Branch__c> existingBranches = [SELECT Id FROM CCP2_Branch__c WHERE Account__c = :accId AND Name = :branchName];
            	if (!existingBranches.isEmpty()) {
                    //System.debug('Branch With same name exixts');
                	throw new AuraHandledException('Same BranchName already exists.');
            	}
                else {
                    queryList.Name = branchName;
                }
            }
            update queryList;
            System.debug('Branch updated successfully: ' + queryList.Id);
        } catch (Exception e) {
            CCP2_HandlerForException.LogException(e);
            System.debug('An error occurred while updating the branch: ' + e.getMessage());
        }
    }*/
    
    @AuraEnabled
    public static void updateBranchById(Id branchId,String postalCode,String Prefecture,String municipalities,String streetAddress,String BuldingName, String contactNo, String branchName) {
		Id accId = getAccountId();
      	//Id accId = '001Io000003ITP2IAO';
        List<CCP2_Branch__c> existingBranches = [SELECT Id FROM CCP2_Branch__c WHERE Account__c = :accId AND Name = :branchName AND Id != :branchId];
        if (!existingBranches.isEmpty()) {
        	//System.debug('Branch With same name exixts');
            throw new AuraHandledException('同じ支店名はすでに存在しています。');
        }
        CCP2_Branch__c queryList = [SELECT Id, Address__c, Contact_No__c, Name FROM CCP2_Branch__c WHERE Id = :branchId];
        if (postalCode != null) {
           queryList.Postal_Code__c = postalCode;
        }
        if (Prefecture != null) {
            queryList.Prefecture__c = Prefecture;
        }
        if (municipalities != null) {
            queryList.Minicipalities__c = municipalities;
        }
        if (streetAddress != null) {
            queryList.Street_Address__c = streetAddress;
        }
        if (BuldingName != null) {
            queryList.Building_Name_Company_name__c = BuldingName;
        }
        if (contactNo != null) {
            queryList.Contact_No__c = contactNo;
        }
        if (branchName != null) {
            queryList.Name = branchName;
        }
        try{
            update queryList;
            System.debug('Branch updated successfully: ' + queryList.Id);
        } catch (Exception e) {
            CCP2_HandlerForException.LogException(e);
            System.debug('An error occurred while updating the branch: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void addBranch(String accountId, String contactId, List<Id> branches) {
        if (String.isBlank(contactId)) {
            throw new IllegalArgumentException('Contact ID cannot be null or empty');
        }
        if (branches == null || branches.isEmpty()) {
            throw new IllegalArgumentException('Branches list cannot be null or empty');
        }

        List<CCP2_BranchContact_Junction__c> branchRecords = new List<CCP2_BranchContact_Junction__c>();

        for (String branchId : branches) {
            CCP2_BranchContact_Junction__c branch = new CCP2_BranchContact_Junction__c();
            branch.BranchId__c = branchId;
            branch.ContactId__c = contactId;
            branchRecords.add(branch);
        }

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
    public static void deleteBranchById(Id branchId) { 
        try {
           CCP2_Branch__c branchesToDelete = [SELECT Id FROM CCP2_Branch__c WHERE Id = :branchId];
            delete branchesToDelete;
            System.debug('Branch record deleted successfully for branch ID: ' + branchId);
        } catch(Exception e) {
            CCP2_HandlerForException.LogException(e);
            System.debug('An error occurred while deleting the branch record: ' + e.getMessage());
       	 throw e;
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
}