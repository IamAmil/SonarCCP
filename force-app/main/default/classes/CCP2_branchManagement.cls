public class CCP2_branchManagement {
    @AuraEnabled
    public static String createAndAssociateBranch(Id accId, String companyName, String branchName, String address, String telephoneNo, String cellPhoneNo, List<Id> contactIds, List<Id> vehicleIds) {
        List<CCP2_Branch__c> existingBranches = [SELECT Id FROM CCP2_Branch__c WHERE Account__c = :accId AND Name = :branchName];
        
        if (!existingBranches.isEmpty()) {
            return 'Branch with the same name already exists';
        } else {
            CCP2_Branch__c newBranch = new CCP2_Branch__c();
            newBranch.Account__c = accId;
            newBranch.Company_Name__c = companyName;
            newBranch.Name = branchName;
            newBranch.Address__c = address;
            newBranch.Contact_No__c = telephoneNo;
            newBranch.cellPhone_No__c = cellPhoneNo;
            
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

                return 'Branch Created';
            } catch (DmlException e) {
                CCP2_HandlerForException.LogException(e);
                System.debug('An error occurred while inserting branch or junction records: ' + e.getMessage());
                throw new AuraHandledException('Error creating branch: ' + e.getMessage());
            }
        }
    }
    @AuraEnabled(cacheable=true)
    public static Map<Integer, Map<String, Object>> getBranchList() {
        // Get the Id of the logged-in user's account
        //Id AccountId = '001Io000003ITP2IAO';
        Map<Integer, Map<String, Object>> branchList = new Map<Integer, Map<String, Object>>();
        
        try {
            Id accountId = [SELECT AccountId FROM User WHERE Id = :UserInfo.getUserId()].AccountId;

            List<CCP2_Branch__c> branches = [SELECT Id, Account__c, Name FROM CCP2_Branch__c WHERE Account__c = :accountId];
            
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
}