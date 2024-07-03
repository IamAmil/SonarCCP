@IsTest
public class CCP2_callPermissionSet_Test {
    
    @IsTest
    static void testCallMethodPermissionSet() {
        // Create a test user
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create test Contacts
        Contact testContact1 = new Contact(FirstName = 'Test', LastName = 'Contact1', AccountId = testAccount.Id);
        insert new List<Contact>{testContact1};
        
        User testUser = new User(
            Username = 'testuser@test.com',
            Alias = 'tuser',
            Email = 'testuser@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'FUSO Customer Community Plus Login User' LIMIT 1].Id,
            ContactId = testContact1.Id
        );
        insert testUser;

        // Mock the ccp2_userPermissionSet class
        Test.startTest();
        
        // Call the method
        List<Id> userIdList = new List<Id> { testUser.Id };
        CCP2_callPermissionSet.callMethodPermissionSet(userIdList);

        Test.stopTest();

        // Add assertions to verify the expected behavior
        // Note: You need to mock and assert calls to ccp2_userPermissionSet.permissionValues if it's not a void method.
        // Example:
        // System.assert(...);
    }
}