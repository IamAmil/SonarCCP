public class CCP2_BranchDeleteController { 
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
}