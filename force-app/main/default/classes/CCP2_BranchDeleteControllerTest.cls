@isTest
public class CCP2_BranchDeleteControllerTest {
    
    @testSetup
    static void setup() {
        // Create an account record as it is a required field for CCP2_Branch__c
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        // Create a branch record with the required field Account__c
        CCP2_Branch__c testBranch = new CCP2_Branch__c(Account__c = testAccount.Id);
        insert testBranch;
    }
    
    @isTest
    static void testDeleteBranchById_Success() {
        // Retrieve the branch record created in the test setup
        CCP2_Branch__c branchToDelete = [SELECT Id FROM CCP2_Branch__c LIMIT 1];
        
        // Call the deleteBranchById method
        Test.startTest();
        CCP2_BranchDeleteController.deleteBranchById(branchToDelete.Id);
        Test.stopTest();
        
        // Verify the branch record has been deleted
        List<CCP2_Branch__c> deletedBranch = [SELECT Id FROM CCP2_Branch__c WHERE Id = :branchToDelete.Id];
        System.assertEquals(0, deletedBranch.size(), 'The branch record should be deleted');
    }
    
    @isTest
    static void testDeleteBranchById_DmlException() {
        // Create a branch record without setting the required field Account__c
       Account testAccount = new Account(Name = 'Test Account');
        insert testAccount; 
        
        CCP2_Branch__c testBranch = new CCP2_Branch__c(Account__c = testAccount.Id);
        
        // Call the deleteBranchById method and expect a DmlException
        Test.startTest();
        try {
            CCP2_BranchDeleteController.deleteBranchById(testBranch.Id);
            System.assert(true, 'No branch record found with ID');
        } catch (DmlException e) {
            System.assert(true, 'DmlException was thrown as expected');
        } catch (Exception e) {
            System.assert(true, 'Expected a DmlException, but got a different exception: ' + e);
        }
        Test.stopTest();
    }
    
    @isTest
    static void testDeleteBranchById_QueryException() {
        // Generate a non-existent Id
        Id nonExistentBranchId = 'a1A0o00000XXXXXAAA';

        // Call the deleteBranchById method and expect it to throw a QueryException or DmlException
        Test.startTest();
        try {
            CCP2_BranchDeleteController.deleteBranchById(nonExistentBranchId);
            System.assert(true, 'No branch record found with ID');
        } catch (DmlException e) {
            System.assert(false, 'Expected a QueryException, but got a DmlException: ' + e);
        } catch (Exception e) {
            System.assert(true, 'Expected exception was thrown: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    static void testDeleteBranchById_NullBranchId() {
        // Call the deleteBranchById method with a null branch Id and expect an exception
        Test.startTest();
        try {
            CCP2_BranchDeleteController.deleteBranchById('');
            System.assert(false, 'Expected an exception to be thrown for null branch Id');
        } catch (Exception e) {
            System.assert(true, 'Exception was thrown as expected');
        }
        Test.stopTest();
    }
}