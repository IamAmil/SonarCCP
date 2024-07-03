@isTest
public class ccp2_userupdate_Test {

    @testSetup
    static void setup() {
        Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;

        CCP2_Branch__c testBranch = new CCP2_Branch__c(
            Name = 'Test Branch',
            Account__c = testAccount.Id
        );
        insert testBranch;

        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john.doe@example.com',
            Phone = '123-456-7890',
            firstNameKana__c = 'ジョン',
            Branch__c = testBranch.Id,
            Department = 'Test Department',
            AccountId = testAccount.Id
        );
        insert testContact;
    }

    @isTest
    static void testUpdateRecordsMissingContactId() {
        String uiFieldJson = '[{"FirstName": "Jane"}]';

        try {
            Test.startTest();
            ccp2_userupdate.updateRecords(uiFieldJson);
            Test.stopTest();
            System.assert(false, 'Expected an AuraHandledException to be thrown');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }

    @isTest
    static void testUpdateRecordsContactNotFound() {
        // Prepare the input JSON string with a non-existing ContactId
        String uiFieldJson = '[{"ContactId": "003000000000000AAA", "FirstName": "Jane"}]';

        try {
            Test.startTest();
            ccp2_userupdate.updateRecords(uiFieldJson);
            Test.stopTest();
            System.assert(false, 'Expected an AuraHandledException to be thrown');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }

    @isTest
    static void testUpdateRecordsErrorUpdatingContact() {
        
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];

        // Prepare the input JSON string with valid ContactId but invalid field value to force an error
        String uiFieldJson = '[{"ContactId": "' + testContact.Id + '", "Email": "invalid email"}]';

        try {
            Test.startTest();
            ccp2_userupdate.updateRecords(uiFieldJson);
            Test.stopTest();
            System.assert(false, 'Expected an AuraHandledException to be thrown');
        } catch (AuraHandledException e) {
            //System.assert(e.getMessage().startsWith('Error updating Contact record: '));
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }

    @isTest
    static void testUpdateRecordsAllFields() {

        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        CCP2_Branch__c newBranch = new CCP2_Branch__c(
            Name = 'New Branch',
            Account__c = [SELECT Id FROM Account LIMIT 1].Id
        );
        insert newBranch;

        // Prepare the input JSON string to update all fields
        String uiFieldJson = '[{"ContactId": "' + testContact.Id + '", "FirstName": "Jane", "LastName": "Smith", "Email": "jane.smith@example.com", "Phone": "987-654-3210", "MobilePhone": "555-555-5555", "firstNameKana__c": "ジェーン", "lastNameKana__c": "スミス", "Branch__c": "' + newBranch.Id + '", "Department": "New Department", "Title": "Manager", "Employee_Code__c": "E12345"}]';

        Test.startTest();
        ccp2_userupdate.updateRecords(uiFieldJson);
        Test.stopTest();

        // Retrieve the updated contact
        Contact updatedContact = [SELECT FirstName, LastName, Email, Phone, MobilePhone, firstNameKana__c, lastNameKana__c, Branch__c, Department, Title, Employee_Code__c 
                                  FROM Contact WHERE Id = :testContact.Id];

        System.assertEquals('Jane', updatedContact.FirstName);
        System.assertEquals('Smith', updatedContact.LastName);
        System.assertEquals('jane.smith@example.com', updatedContact.Email);
        System.assertEquals('987-654-3210', updatedContact.Phone);
        System.assertEquals('555-555-5555', updatedContact.MobilePhone);
        System.assertEquals('ジェーン', updatedContact.firstNameKana__c);
        System.assertEquals('スミス', updatedContact.lastNameKana__c);
        System.assertEquals(newBranch.Id, updatedContact.Branch__c);
        System.assertEquals('New Department', updatedContact.Department);
        System.assertEquals('Manager', updatedContact.Title);
        System.assertEquals('E12345', updatedContact.Employee_Code__c);
    }
}