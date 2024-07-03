public class CCP2_UpdatePermissionAssignment {
    @AuraEnabled
    
    public static Void createAndAssociateBranch(CCP2_Access_Control__c con){
        Id userId = con.Name;  
            Boolean bsChecked = con.Basic_Service_EC_Flag__c;
            Boolean eiChecked = con.E_invoice_flag__c;
            Boolean fsChecked = con.Financial_service_Flag__c;
            Boolean ombChecked = con.Online_maintenance_booking_Flag__c;
            Boolean vmChecked = con.Vehicle_management_Flag__c;
            Boolean cmChecked = con.Cost_management_Flag__c;
   
        //Id userId = '005Io000000thIOIAY';005Io000000tnDUIAY
      /*  List<PermissionSet> permissionSets = [Select Id, Name from permissionSet where Name IN ('FUSO_CCP_External_E_invoice_new','FUSO_CCP_External_Financial_service','FUSO_CCP_External_Basic_Service_EC','FUSO_CCP_External_Cost_management','FUSO_CCP_External_Online_maintenance_booking','FUSO_CCP_External_Vehicle_management')];
        List<Id> permissionSetIds = new List<Id>();
            for (PermissionSet ps : permissionSets) {
                permissionSetIds.add(ps.Id);
            }
        List<PermissionSetAssignment> psaList = [SELECT Id,AssigneeId,PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :userId and PermissionSetId IN:permissionSetIds ];
        System.debug(psaList);
           if (!psaList.isEmpty()) {
                try {
                    //psaList[0].AssigneeId = null;
                    System.debug(psaList[0].AssigneeId);
                    //Update psaList;
                    Delete psaList;
                    //System.debug('PermissionSetAssignment record deleted successfully for ID: ' + psa.Id);
                } catch (DmlException e) {
                        CCP2_HandlerForException.LogException(e);
                        System.debug('An error occurred while deleting PermissionSetAssignment record: ' + e.getMessage());
                        // Optionally, handle or log other exceptions further if needed
                }
        } 
        else {
            System.debug('No PermissionSetAssignment record found for user ID: ' + userId);
        }*/
        List<PermissionSet> permissionSets = [Select Id, Name from permissionSet where Name IN ('E_invoice','FUSO_CCP_External_Financial_service','FUSO_CCP_External_Basic_Service_EC','FUSO_CCP_External_Cost_management','FUSO_CCP_External_Online_maintenance_booking','FUSO_CCP_External_Vehicle_management')];
        List<Id> permissionSetIds = new List<Id>();
            for (PermissionSet ps : permissionSets) {
                permissionSetIds.add(ps.Id);
            }
        List<PermissionSetAssignment> psaList = [SELECT Id,AssigneeId,PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :userId and PermissionSetId IN:permissionSetIds ];
        System.debug(psaList);
           if (!psaList.isEmpty()) {
                try {
                    //psaList[0].AssigneeId = null;
                    System.debug(psaList[0].AssigneeId);
                    //Update psaList;
                    Delete psaList;
                    //Boolean vrChecked = false;
                    //Boolean rbChecked = false;
                    //CCP_AddUserCtrl.setPermissionSetforUser(userId,vrChecked,rbChecked, fsChecked,  ombChecked, vmChecked,  cmChecked);
                    //System.debug('PermissionSetAssignment record deleted successfully for ID: ' + psa.Id);
                } catch (DmlException e) {
                        CCP2_HandlerForException.LogException(e);
                        System.debug('An error occurred while deleting PermissionSetAssignment record: ' + e.getMessage());
                        // Optionally, handle or log other exceptions further if needed
                }
        } 
        else {
            System.debug('No PermissionSetAssignment record found for user ID: ' + userId);
        	}
        try{
             System.debug('No1');
            if(bsChecked){
                PermissionSetAssignment vsa = new PermissionSetAssignment(PermissionSetId ='0PS5i0000090MkgGAE', AssigneeId = userId);
                insert vsa;
            }
             if(eiChecked){
                PermissionSetAssignment vsa = new PermissionSetAssignment(PermissionSetId ='0PS5i0000090MkhGAE', AssigneeId = userId);
                insert vsa;
            }
             if(fsChecked){
                PermissionSetAssignment vsa = new PermissionSetAssignment(PermissionSetId ='0PSIo000000TPCzOAO', AssigneeId = userId);
                insert vsa;
            }
             if(ombChecked){
                PermissionSetAssignment vsa = new PermissionSetAssignment(PermissionSetId ='0PSIo000000TPD4OAO', AssigneeId = userId);
                insert vsa;
            }
             if(vmChecked){
                PermissionSetAssignment vsa = new PermissionSetAssignment(PermissionSetId ='0PSIo000000TPD9OAO', AssigneeId = userId);
                insert vsa;
            }
             if(cmChecked){
                PermissionSetAssignment vsa = new PermissionSetAssignment(PermissionSetId ='0PSIo000000TPDEOA4', AssigneeId = userId);
                insert vsa;
            }
         }
             catch(Exception e){
            throw new DmlException('setPermissionSetforUser error :'+e.getMessage());
        }
     }
}