public without sharing class CCP2_UserDeleteController {
    @AuraEnabled
    public static void deleteUser(String contactId) {
        try {
            // Query the Contact record based on the given contactId
            Contact contact = [SELECT Id, OwnerId, UserId__c, ccpUseFlag__c FROM Contact WHERE Id = :contactId LIMIT 1];
            System.debug(contact);
            contact.ccpUseFlag__c = false;
      		 System.debug(contact.ccpUseFlag__c);
            update contact;
            // Check if the Contact has an associated User record
            if (contact.UserId__c != null) {
                // Query the UserLogin record based on the UserId
                UserLogin userLogin = [SELECT Id, IsFrozen FROM UserLogin WHERE UserId = :contact.UserId__c LIMIT 1];
                System.debug(userLogin);
                
                // Freeze the User by setting the IsFrozen field to true
                userLogin.IsFrozen = true;
                update userLogin;
                System.debug('User record frozen successfully for user ID: ' + contact.UserId__c);
            } else {
                System.debug('No associated User record found for contact ID: ' + contactId);
            }
        } catch (Exception e) {
             CCP2_HandlerForException.LogException(e);
            System.debug('An error occurred: ' + e.getMessage());
        }
    }
}