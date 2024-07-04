public with sharing class ccp2_filedmap {
		public final static Map<String, String> filedMap = new Map<String, String>{
        '名' => 'FirstName',//contact
         '姓' => 'LastName',//contact
        '役職' => 'Title',//contact
        '社員番号'=>'Employee_Code__c',//contact
        'メールアドレス' => 'Email',//contact
        '電話番号' => 'Phone',//contactPhone
        '携帯番号' => 'MobilePhone',//contact
         '名（フリガナ）' => 'firstNameKana__c',//contact
         '姓（フリガナ）' => 'lastNameKana__c',//contact
         '所属' => 'Branch__c',//contact
         'ContactId' => 'ContactId',//contact
         '部署' => 'Department'//contact
    };
        @AuraEnabled(cacheable=true)
        public static String uiFieldInput(String uiField) {
        String returnField = null;
        try {
            if (filedMap.containsKey(uiField)) {
                returnField = filedMap.get(uiField);
            }
            System.debug(returnField);
        } catch (Exception e) {
            CCP2_HandlerForException.LogException(e);
            System.debug('Error in uiFieldInput: ' + e.getMessage());
        }
        return returnField;
    }
}