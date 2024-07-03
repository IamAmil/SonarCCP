@isTest
public class ccp2_filedmap_Test {
    
    @isTest
    static void testUiFieldInput() {

        System.assertEquals('FirstName', ccp2_filedmap.uiFieldInput('名'));
        System.assertEquals('LastName', ccp2_filedmap.uiFieldInput('姓'));
        System.assertEquals('Title', ccp2_filedmap.uiFieldInput('役職'));
        System.assertEquals('Employee_Code__c', ccp2_filedmap.uiFieldInput('社員番号'));
        System.assertEquals('Email', ccp2_filedmap.uiFieldInput('メールアドレス'));
        System.assertEquals('Phone', ccp2_filedmap.uiFieldInput('電話番号'));
        System.assertEquals('MobilePhone', ccp2_filedmap.uiFieldInput('携帯番号'));
        System.assertEquals('firstNameKana__c', ccp2_filedmap.uiFieldInput('名（フリガナ）'));
        System.assertEquals('lastNameKana__c', ccp2_filedmap.uiFieldInput('姓（フリガナ）'));
        System.assertEquals('Branch__c', ccp2_filedmap.uiFieldInput('所属'));
        System.assertEquals('Department', ccp2_filedmap.uiFieldInput('部署'));
        
        System.assertEquals(null, ccp2_filedmap.uiFieldInput('NonExistingField'));
    }
}