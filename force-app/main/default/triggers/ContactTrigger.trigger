trigger ContactTrigger on Contact (after update) {
    // Collect user IDs from the updated contacts
    Set<Id> userIds = new Set<Id>();
    for (Contact con : Trigger.new) {
        // Check if UserId__c is not null
        if (con.UserId__c != null) {
            userIds.add(con.UserId__c);
        }
    }
    
    // Call the method from the ccp2_userPermissionSet class for each userId
    for (Id userId : userIds) {
        try {
            ccp2_userPermissionSet.permissionValues(userId);
        } catch (Exception e) {
            System.debug('Error in ContactTrigger: ' + e.getMessage());
        }
    }
}