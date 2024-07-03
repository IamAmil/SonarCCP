public class ContactUpdate {
 	 @AuraEnabled
    public static void updateAccessControl(CCP2_Access_Control__c con) {
        try {
            // Query for the existing CCP2_Access_Control__c record based on Name
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
                result.Basic_Service_EC_Flag__c = con.Basic_Service_EC_Flag__c;
                result.Online_maintenance_booking_Flag__c = con.Online_maintenance_booking_Flag__c;
                result.Vehicle_management_Flag__c = con.Vehicle_management_Flag__c;
                result.Cost_management_Flag__c = con.Cost_management_Flag__c;
                
                // Perform the update operation
                System.debug(result);
                update result;
                
                Id userId = con.Name;  
            Boolean bsChecked = con.Basic_Service_EC_Flag__c;
            Boolean eiChecked = con.E_invoice_flag__c;
            Boolean fsChecked = con.Financial_service_Flag__c;
            Boolean ombChecked = con.Online_maintenance_booking_Flag__c;
            Boolean vmChecked = con.Vehicle_management_Flag__c;
            Boolean cmChecked = con.Cost_management_Flag__c;
            //CCP2_UpdatePermissionAssignment.createAndAssociateBranch(userId, bsChecked, eiChecked, fsChecked, ombChecked, vmChecked, cmChecked);
    		//Boolean vrChecked = false;
            //Boolean rbChecked = false;
            //CCP_AddUserCtrl.setPermissionSetforUser(userId,vrChecked,rbChecked, fsChecked,  ombChecked, vmChecked,  cmChecked);
                    
                System.debug('CCP2_Access_Control__c updated successfully: ' + result.Id);
            } else {
                System.debug('No CCP2_Access_Control__c record found with Name: ' + con.Name);
            }
        } catch (Exception e) {
            CCP2_HandlerForException.LogException(e);
            System.debug('Error updating CCP2_Access_Control__c: ' + e.getMessage());
        }
        //Paermissionset work start here
        /*Id userId = con.Name;  
            Boolean bsChecked = con.Basic_Service_EC_Flag__c;
            Boolean eiChecked = con.E_invoice_flag__c;
            Boolean fsChecked = con.Financial_service_Flag__c;
            Boolean ombChecked = con.Online_maintenance_booking_Flag__c;
            Boolean vmChecked = con.Vehicle_management_Flag__c;
            Boolean cmChecked = con.Cost_management_Flag__c;
        try {
            CCP2_UpdatePermissionAssignment.createAndAssociateBranch(userId, bsChecked, eiChecked, fsChecked, ombChecked, vmChecked, cmChecked);
        }
        catch(DmlException e){
            CCP2_HandlerForException.LogException(e);
        }
        
        List<PermissionSet> permissionSets = [Select Id, Name from permissionSet where Name IN ('FUSO_CCP_External_E_invoice_new','FUSO_CCP_External_Financial_service','FUSO_CCP_External_Basic_Service_EC','FUSO_CCP_External_Cost_management','FUSO_CCP_External_Online_maintenance_booking','FUSO_CCP_External_Vehicle_management')];
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
        }
         try{
            if(bsChecked){
                PermissionSetAssignment vsa = new PermissionSetAssignment(PermissionSetId ='0PSIo000000TPCkOAO', AssigneeId = userId);
                insert vsa;
            }
             if(eiChecked){
                PermissionSetAssignment vsa = new PermissionSetAssignment(PermissionSetId ='0PSIo000000TPCpOAO', AssigneeId = userId);
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
        }*/
      
    }
}