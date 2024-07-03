@isTest
public class CCP2_branchUpdate_Test {

    @testSetup
    static void setup() {
        Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;

        CCP2_Branch__c branch = new CCP2_Branch__c(
            Address__c = '123 Test St',
            Contact_No__c = '123-456-7890',
            Name = 'Test Branch',
            Account__c = testAccount.Id
        );
        insert branch;
    }

    @isTest
    static void testUpdateBranchById() {
        CCP2_Branch__c branch = [SELECT Id, Address__c, Contact_No__c, Name FROM CCP2_Branch__c];
        
        // New data to update
        String newAddress = '456 New Address';
        String newContactNo = '987-654-3210';
        String newBranchName = 'New Branch Name';

        CCP2_branchUpdate.updateBranchById(branch.Id, newAddress, newContactNo, newBranchName);

        CCP2_Branch__c updatedBranch = [SELECT Id, Address__c, Contact_No__c, Name FROM CCP2_Branch__c WHERE Id = :branch.Id];

        System.assertEquals(newAddress, updatedBranch.Address__c);
        System.assertEquals(newContactNo, updatedBranch.Contact_No__c);
        System.assertEquals(newBranchName, updatedBranch.Name);
    }

    @isTest
    static void testUpdateBranchByIdPartialUpdate() {

        CCP2_Branch__c branch = [SELECT Id, Address__c, Contact_No__c, Name FROM CCP2_Branch__c LIMIT 1];
        
        String newAddress = '789 Another Address';

        CCP2_branchUpdate.updateBranchById(branch.Id, newAddress, null, null);

        CCP2_Branch__c updatedBranch = [SELECT Id, Address__c, Contact_No__c, Name FROM CCP2_Branch__c WHERE Id = :branch.Id];

        System.assertEquals(newAddress, updatedBranch.Address__c);
        System.assertEquals(branch.Contact_No__c, updatedBranch.Contact_No__c);
        System.assertEquals(branch.Name, updatedBranch.Name);
    }

    @isTest
    static void testUpdateBranchByIdNoUpdate() {

        CCP2_Branch__c branch = [SELECT Id, Address__c, Contact_No__c, Name FROM CCP2_Branch__c LIMIT 1];
        
        CCP2_branchUpdate.updateBranchById(branch.Id, null, null, null);

        CCP2_Branch__c updatedBranch = [SELECT Id, Address__c, Contact_No__c, Name FROM CCP2_Branch__c WHERE Id = :branch.Id];

        System.assertEquals(branch.Address__c, updatedBranch.Address__c);
        System.assertEquals(branch.Contact_No__c, updatedBranch.Contact_No__c);
        System.assertEquals(branch.Name, updatedBranch.Name);
    }
}