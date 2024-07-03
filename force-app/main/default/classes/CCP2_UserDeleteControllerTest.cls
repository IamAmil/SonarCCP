@isTest
public class CCP2_UserDeleteControllerTest {
    @testSetup
    static void setupTestData() {
        // Create a test Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'testcontact@example.com', AccountId = testAccount.Id, IsSiteUser__c = true);
        insert testContact;

        Profile p = [SELECT Id FROM Profile WHERE Name='FUSO Customer Community Plus Login User' LIMIT 1];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles',
                          UserName='Login_user123@testorg.com', ContactId = testContact.Id);

        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert u;

            PermissionSet ps = new PermissionSet(Label = 'Test Permission Set', Name = 'Test_Permission_Set');
            insert ps;

            PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);
            insert psa;
        }
    }

    @isTest
    static void testDeleteUser() {

        Contact testContact = [SELECT Id, IsSiteUser__c FROM Contact WHERE Email = 'testcontact@example.com' LIMIT 1];
        System.assertEquals(true, testContact.IsSiteUser__c, 'The contact should initially have IsSiteUser__c set to true');

        Test.startTest();
        CCP2_UserDeleteController.deleteUser(testContact.Id);
        Test.stopTest();

        // Verify that the contact's IsSiteUser__c field was updated
        Contact updatedContact = [SELECT Id, IsSiteUser__c FROM Contact WHERE Id = :testContact.Id];
        System.assertEquals(false, updatedContact.IsSiteUser__c, 'The contact should have IsSiteUser__c set to false');
    }

    /*@isTest
    static void testDeleteUser_ExceptionHandling() {
        // Create a test Contact that will trigger an exception (e.g., by setting a required field to null)
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'ExceptionContact', Email = 'exceptioncontact@example.com', AccountId = testAccount.Id, IsSiteUser__c = true);
        insert testContact;

        // Intentionally cause an exception by setting IsSiteUser__c to null and try updating it
        testContact.IsSiteUser__c = null;
        update testContact;

        // Call the deleteUser method and handle the exception
        Test.startTest();
        try {
            CCP2_UserDeleteController.deleteUser(testContact.Id);
            System.assert(false, 'Expected a DmlException to be thrown');
        } catch (DmlException e) {
            System.assert(true, 'Caught expected DmlException: ' + e.getMessage());
        }
        Test.stopTest();
    }*/
}