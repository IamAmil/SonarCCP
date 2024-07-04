public with sharing class ccp2_branchAddMember {
    @AuraEnabled
    public static void addBranch(String accountId, String contactId, List<Id> branches) {
        // Input validation
        /*if (String.isBlank(accountId)) {
            throw new IllegalArgumentException('Account ID cannot be null or empty');
        }*/
        if (String.isBlank(contactId)) {
            throw new IllegalArgumentException('Contact ID cannot be null or empty');
        }
        if (branches == null || branches.isEmpty()) {
            throw new IllegalArgumentException('Branches list cannot be null or empty');
        }

        // List to hold new Branch records
        List<CCP2_BranchContact_Junction__c> branchRecords = new List<CCP2_BranchContact_Junction__c>();

        // Iterate through the branches list and create Branch records
        for (String branchId : branches) {
            CCP2_BranchContact_Junction__c branch = new CCP2_BranchContact_Junction__c();
            branch.BranchId__c = branchId;
            branch.ContactId__c = contactId;
            //branch.Name = branchName;
            branchRecords.add(branch);
        }

        // Insert the Branch records
        if (!branchRecords.isEmpty()) {
        try {
            insert branchRecords;
        } catch (DmlException e) {
            CCP2_HandlerForException.LogException(e);
            throw new AuraHandledException('Failed to insert Branch records: ' + e.getMessage());
        }
        }
    }
}