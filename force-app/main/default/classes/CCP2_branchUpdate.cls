public with sharing class CCP2_branchUpdate {
    @AuraEnabled
    public static void updateBranchById(Id branchId, String address, String contactNo, String branchName) {
        try {
            CCP2_Branch__c queryList = [SELECT Id, Address__c, Contact_No__c, Name FROM CCP2_Branch__c WHERE Id = :branchId];
            
            if (address != null) {
                queryList.Address__c = address;
            }
            if (contactNo != null) {
                queryList.Contact_No__c = contactNo;
            }
            if (branchName != null) {
                queryList.Name = branchName;
            }
            
            update queryList;
            System.debug('Branch updated successfully: ' + queryList.Id);
        } catch (DmlException e) {
            CCP2_HandlerForException.LogException(e);
            System.debug('An error occurred while updating the branch: ' + e.getMessage());
        }
    }
}