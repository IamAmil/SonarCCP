@IsTest
public class ccp2_branchAddMemberTest {
    
    @IsTest
    static void testAddBranch() {
        // Setup test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Contact testContact = new Contact(FirstName = 'John', LastName = 'Doe', AccountId = testAccount.Id);
        insert testContact;
        
        List<String> branches = new List<String>{'Branch1', 'Branch2'};
        
        // Call the method with valid data
        Test.startTest();
        ccp2_branchAddMember.addBranch(testAccount.Id, testContact.Id, branches);
        Test.stopTest();
        
        // Verify that the Branch records were created
        List<CCP2_Branch__c> branchRecords = [SELECT Id, Name, Account__c, Contact__c FROM CCP2_Branch__c WHERE Account__c = :testAccount.Id AND Contact__c = :testContact.Id];
        System.assertEquals(2, branchRecords.size(), 'Expected two branch records to be created');
        System.assertEquals('Branch1', branchRecords[0].Name);
        System.assertEquals('Branch2', branchRecords[1].Name);
    }
    
    @IsTest
    static void testAddBranchNullAccountId() {
        // Setup test data
        List<String> branches = new List<String>{'Branch1', 'Branch2'};
        
        try {
            ccp2_branchAddMember.addBranch(null, 'someContactId', branches);
            System.assert(false, 'Expected IllegalArgumentException for null accountId');
        } catch (IllegalArgumentException e) {
            System.assert(e.getMessage().contains('Account ID cannot be null or empty'), e.getMessage());
        }
    }
    
    @IsTest
    static void testAddBranchNullContactId() {
        // Setup test data
        List<String> branches = new List<String>{'Branch1', 'Branch2'};
        
        try {
            ccp2_branchAddMember.addBranch('someAccountId', null, branches);
            System.assert(false, 'Expected IllegalArgumentException for null contactId');
        } catch (IllegalArgumentException e) {
            System.assert(e.getMessage().contains('Contact ID cannot be null or empty'), e.getMessage());
        }
    }
    
    @IsTest
    static void testAddBranchEmptyBranches() {
        // Setup test data
        List<String> branches = new List<String>();
        
        try {
            ccp2_branchAddMember.addBranch('someAccountId', 'someContactId', branches);
            System.assert(false, 'Expected IllegalArgumentException for empty branches list');
        } catch (IllegalArgumentException e) {
            System.assert(e.getMessage().contains('Branches list cannot be null or empty'), e.getMessage());
        }
    }
    
    @IsTest
    static void testAddBranchDmlException() {
        // Setup test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Contact testContact = new Contact(FirstName = 'John', LastName = 'Doe', AccountId = testAccount.Id);
        insert testContact;
        
        // Create branches with invalid data
        List<String> branches = new List<String>{'InvalidNameWithSpecialCharacters!@#$%', 'AnotherInvalidBranchName123456789012345678901234567890123456789012345678901234567890'};
        
        Test.startTest();
        try {
            ccp2_branchAddMember.addBranch(testAccount.Id, testContact.Id, branches);
            System.assert(false, 'Expected AuraHandledException due to DML failure');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Script-thrown exception'), e.getMessage());
        }
        Test.stopTest();
    }
}