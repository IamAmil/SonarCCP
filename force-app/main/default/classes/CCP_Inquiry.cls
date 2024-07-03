public with sharing class CCP_Inquiry {

    /** 
    * @Description get current user contact infomation
    * @return {contact} - return the contact infomation
    */
    @AuraEnabled
    public static Contact getContactInfo(){
        dummy();
        Id contactId = getContactId();
        Contact contact = null;
        if(contactId != null){
            contact = [SELECT Id, FirstName, LastName, Email, AccountId, Account.Name FROM Contact WHERE Id = :contactId];
        }
        return contact;
    }

    /** 
    * @Description get the standard inquiryType__c picklist label and value
    * @return {inquiryTypeLabelValueMap} - return the map include inquiryType__c picklist label and value
    */
    @AuraEnabled
    public static Map<String, String> getTypeOptions(){
        Map<String, String> inquiryTypeLabelValueMap = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = Case.inquiryType__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry pickListVal : ple){
            if(pickListVal.isActive()){
                inquiryTypeLabelValueMap.put(pickListVal.getLabel(), pickListVal.getValue());
            }
        }
        return inquiryTypeLabelValueMap;
    }

    /** 
    * @Description Create a case based on the information entered by the user
    * @param {String} inquiryType - the case inquiryType
    * @param {String} description - the case description
    * @param {String} accountName - the accountName from current user account
    * @param {String} accountId - the accountName from current user account
    * @param {String} contentVersionId - the contentVersionId user upload
    * @return {String} - return the new case id
    */
    @AuraEnabled
    public static String createCase(String inquiryType, String description, String accountName, String accountId,
                                    String contentVersionId) {
        // get Add_Car_Information RecordType
        ID cpCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('cpCase').getRecordTypeId();
        Case ca = new Case();
        ca.Origin = 'Customer Portal';
        ca.Status = 'New'; 
        ca.AccountId = accountId;
        ca.ContactId = getContactId();
        ca.inquiryType__c = inquiryType;
        ca.Subject = accountName + '：' + inquiryType;
        ca.Description = description;
        ca.recordTypeId = cpCaseRecordTypeId;
        
        if(ca.ContactId != null) {

            Contact c = [SELECT Id, Email FROM Contact WHERE Id = :ca.ContactId LIMIT 1];
            ca.SuppliedEmail = c.Email;
        }

        Savepoint sp = Database.setSavepoint();
        try {
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule= true;
            ca.setOptions(dmo);
            insert ca;
            // System.debug('ca:' + ca);
            // // upload file connect to record
            // if(base64 == null || filename == null){
            //     return ca.Id;
            // } else{
            //     uploadFile(base64, filename, ca.Id);
            if(contentVersionId != null){
                createContentLink(contentVersionId, ca.Id);
            }
            sendEmailToUser(ca.Id);
            sendEmailToCCPSecretariatGroup(ca.Id,inquiryType);
            sendNotificationToCCPSecretariatGroup(ca.Id);
            return ca.Id;
            // }
        } catch(DMLException e) {
            // If an error occurs
            Database.rollback(sp);
            System.debug(Logginglevel.ERROR, 'CCP_FileUploaderClass_createCase_error:' + e.getMessage());
            throw new DMLException(e.getMessage());
        }
    }
    
    //Cubastion Code Starts Here Himanshu Kanojia---------------------------------
    @AuraEnabled
    public static String CCPOptOut(String inquiryType, String description, String accountName, String accountId) {
        // get Add_Car_Information RecordType
        ID cpCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CCPOptOut').getRecordTypeId();
        Case ca = new Case();
        ca.Origin = 'Customer Portal';
        ca.Status = 'New'; 
        ca.AccountId = accountId;
        ca.ContactId = getContactId();
        ca.CCPUserTemp__c = inquiryType;
        ca.Subject = accountName + '：' + inquiryType;
        ca.Description = description;
        ca.recordTypeId = cpCaseRecordTypeId;
        
        if(ca.ContactId != null) {

            Contact c = [SELECT Id, Email FROM Contact WHERE Id = :ca.ContactId And canManageMember__c = True];
            ca.SuppliedEmail = c.Email;
        }

        Savepoint sp = Database.setSavepoint();
        try {
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule= true;
            ca.setOptions(dmo);
            insert ca;
            // System.debug('ca:' + ca);
            // // upload file connect to record
            // if(base64 == null || filename == null){
            //     return ca.Id;
            // } else{
            //     uploadFile(base64, filename, ca.Id);
            /*if(contentVersionId != null){
                createContentLink(contentVersionId, ca.Id);
            }
            sendEmailToUser(ca.Id);
            sendEmailToCCPSecretariatGroup(ca.Id,inquiryType);
            sendNotificationToCCPSecretariatGroup(ca.Id);*/
            return ca.Id;
            // }
        } catch(DMLException e) {
            // If an error occurs
            Database.rollback(sp);
            System.debug(Logginglevel.ERROR, 'CCP_FileUploaderClass_createCase_error:' + e.getMessage());
            throw new DMLException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String CCPDeleteUser(String inquiryType, String description, String accountName, String accountId) {
        // get Add_Car_Information RecordType
        ID cpCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CCPDeleteUser').getRecordTypeId();
        Case ca = new Case();
        ca.Origin = 'Customer Portal';
        ca.Status = 'New'; 
        ca.AccountId = accountId;
        ca.ContactId = getContactId();
        ca.CCPUserTemp__c = inquiryType;
        ca.Subject = accountName + '：' + inquiryType;
        ca.Description = description;
        ca.recordTypeId = cpCaseRecordTypeId;
        
        if(ca.ContactId != null) {

            Contact c = [SELECT Id, Email FROM Contact WHERE Id = :ca.ContactId LIMIT 1];
            ca.SuppliedEmail = c.Email;
        }

        Savepoint sp = Database.setSavepoint();
        try {
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule= true;
            ca.setOptions(dmo);
            insert ca;
            // System.debug('ca:' + ca);
            // // upload file connect to record
            // if(base64 == null || filename == null){
            //     return ca.Id;
            // } else{
            //     uploadFile(base64, filename, ca.Id);
            /*if(contentVersionId != null){
                createContentLink(contentVersionId, ca.Id);
            }
            sendEmailToUser(ca.Id);
            sendEmailToCCPSecretariatGroup(ca.Id,inquiryType);
            sendNotificationToCCPSecretariatGroup(ca.Id);*/
            return ca.Id;
            // }
        } catch(DMLException e) {
            // If an error occurs
            Database.rollback(sp);
            System.debug(Logginglevel.ERROR, 'CCP_FileUploaderClass_createCase_error:' + e.getMessage());
            throw new DMLException(e.getMessage());
        }
    }
    
    public static String CCPServiceCreateCase(String accountName, String accountId,String userId) {
        // get Add_Car_Information RecordType
        ID cpCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CCPDeleteUser').getRecordTypeId();
        //Query on Access Control object with user id and get all the service name corresponding with value
		List<CCP2_Access_Control__c> accList = [Select Id,Name,OwnerId,Basic_Service_EC_Flag__c,Cost_management_Flag__c, 
										E_invoice_Flag__c, Financial_service_Flag__c, Online_maintenance_booking_Flag__c, 
										Vehicle_management_Flag__c From CCP2_Access_Control__c where OwnerId  = :userId]; 
		Case ca = new Case();
        ca.Origin = 'Customer Portal';
        ca.Status = 'New'; 
        ca.AccountId = accountId;
        ca.ContactId = getContactId();
        ca.Subject = accountName;
        //ca.Description = description;
		ca.Description = 'description:' + 'Basic Service: ' + accList[0].Basic_Service_EC_Flag__c + ' Cost Management: '+ accList[0].Cost_management_Flag__c + ' Invoice Flag : '+ accList[0].E_invoice_Flag__c +' Financial Flag : '+ accList[0].Financial_service_Flag__c +' maintenance Flag : '+ accList[0].Online_maintenance_booking_Flag__c +' Vehicle Management Flag : '+ accList[0].Vehicle_management_Flag__c;
		
        ca.recordTypeId = cpCaseRecordTypeId;
        
        /*if(ca.ContactId != null) {

            Contact c = [SELECT Id, Email FROM Contact WHERE Id = :ca.ContactId LIMIT 1];
            ca.SuppliedEmail = c.Email;
        }*/

        Savepoint sp = Database.setSavepoint();
        try {
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule= true;
            ca.setOptions(dmo);
            insert ca;
            // System.debug('ca:' + ca);
            // // upload file connect to record
            // if(base64 == null || filename == null){
            //     return ca.Id;
            // } else{
            //     uploadFile(base64, filename, ca.Id);
            /*if(contentVersionId != null){
                createContentLink(contentVersionId, ca.Id);
            }
            sendEmailToUser(ca.Id);
            sendEmailToCCPSecretariatGroup(ca.Id,inquiryType);
            sendNotificationToCCPSecretariatGroup(ca.Id);*/
            return ca.Id;
            // }
        } catch(DMLException e) {
            // If an error occurs
            Database.rollback(sp);
            System.debug(Logginglevel.ERROR, 'CCP_FileUploaderClass_createCase_error:' + e.getMessage());
            throw new DMLException(e.getMessage());
        }
    }

    //Cubastion Code Ends Here Himanshu Kanojia---------------------------------
    /** 
    * @Description send email to inquiry user
    * @param {Id} caseId - the case id
    */
    private static void sendEmailToUser(Id caseId){
        User currentUser = CCP_UserUtil.getUserWithAccountInfo();

        EmailTemplate et = [SELECT Id, Subject, Body, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'inquiryCompleteNotification'];
        //OrgwideEmailAddress[] orgwideaddress = [SELECT Id FROM orgwideEmailAddress WHERE displayname = '三菱ふそう'];
        OrgwideEmailAddress[] orgwideaddress = [SELECT Id FROM orgwideEmailAddress WHERE displayname = :System.Label.CRM_ORG_WIDE_EMAIL_ADDRESS_LABEL];
        
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(et.Id, currentUser.Id, caseId);
        String htmlBody = message.htmlBody;
        String plainTextBody= message.plainTextBody;
        htmlBody = htmlBody.replace('{@AccountName}', currentUser.Contact.Account.Name != null ? currentUser.Contact.Account.Name : '');
        plainTextBody = plainTextBody.replace('{@AccountName}', currentUser.Contact.Account.Name != null ? currentUser.Contact.Account.Name : '');
        htmlBody = htmlBody.replace('{@UserName}', currentUser.Name != null ? currentUser.Name : '');
        plainTextBody = plainTextBody.replace('{@UserName}', currentUser.Name != null ? currentUser.Name : '');
        htmlBody = htmlBody.replace('{@Logo}', Label.CCP_Mail_Logo);
        htmlBody = htmlBody.replace('{@SiteURL}', Label.CCP_SiteURL_ForMail);
        htmlBody = htmlBody.replace('{@InquiryUrl}', Label.CCP_Mail_Inquiry_URL);
        plainTextBody = plainTextBody.replace('{@SiteURL}', Label.CCP_SiteURL_ForMail);

        message.setPlainTextBody(plainTextBody);
        message.setHtmlBody(htmlBody);
        message.setSaveAsActivity(false);
        message.setOrgWideEmailAddressId(orgwideaddress[0].Id);
        allmsg.add(message);

        try {
            CCP_SendEmailUtil.sendEmailUtil(allmsg);
        } catch (Exception e) {
            System.debug('The email failed to send:' + e.getMessage());
        }
    }

    /** 
    * @Description send email to ccpSecretariatGroup
    * @param {Id} caseId - the case id
    */
    private static void sendEmailToCCPSecretariatGroup(Id caseId,String inquiryType){
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        EmailTemplate  et = [SELECT Id, Subject, Body, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'inquiryNotification'];
        OrgwideEmailAddress[] orgwideaddress = [SELECT Id FROM orgwideEmailAddress WHERE displayname = :System.Label.CRM_ORG_WIDE_EMAIL_ADDRESS_LABEL];
        String[] toAddresses;
        if(inquiryType.equals(CCP_CommonConstants.MONTHLYAPPLYCASE)){
            toAddresses = new String[] {System.Label.CCP_Inquiry_Email_Invoice}; 
        }else if(inquiryType.equals(CCP_CommonConstants.USERINFOAPPLYCASE)){
            toAddresses = new String[] {System.Label.CCP_Inquiry_Email_UserInfo}; 
        }else if(inquiryType.equals(CCP_CommonConstants.OTHERAPPLYCASE)){
            toAddresses = new String[] {System.Label.CCP_Inquiry_Email_Other}; 
        }else{
            toAddresses = new String[] {System.Label.CCP_Inquiry_Email_VehicleInfo};
        }
        Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(et.Id, null, caseId);
        String htmlBody = mail.htmlBody;
        String plainTextBody = mail.plainTextBody;
        htmlBody = htmlBody.replace('{@Logo}', Label.CCP_Mail_Logo);
        htmlBody = htmlBody.replace('{@SiteURL}', Label.CCP_SiteURL_ForMail);
        htmlBody = htmlBody.replace('{@InquiryUrl}', Label.CCP_Mail_Inquiry_URL);
        plainTextBody = plainTextBody.replace('{@SiteURL}', Label.CCP_SiteURL_ForMail);
        mail.setToAddresses(toAddresses);
        mail.setPlainTextBody(plainTextBody);
        mail.setHtmlBody(htmlBody);
        mail.setSaveAsActivity(false);
        mail.setOrgWideEmailAddressId(orgwideaddress[0].Id);
        mail.setUseSignature(false);
        allmsg.add(mail);

        try {
            if(!Test.isRunningTest()){
                CCP_SendEmailUtil.sendEmailUtil(allmsg);
            }
        } catch (Exception e) {
            System.debug('The email failed to send:' + e.getMessage());
        }
    }
    
    /** 
    * @Description send Notification to ccpSecretariatGroup
    * @param {Id} caseId - the case id
    */
    private static void sendNotificationToCCPSecretariatGroup(Id caseId){
        Set<String> recipientsIds = new Set<String>();
        Group ccpSecretariatGroup = [SELECT Id FROM Group WHERE DeveloperName= 'ccpSecretariatGroup'];
        recipientsIds.add(ccpSecretariatGroup.Id);
        
        Case ca = [SELECT Id, CaseNumber FROM Case WHERE Id = :caseId];
        
        Id notificationTypeId = CCP_NotificationsUtil.getNotificationTypeId();
        
        String Url = URL.getCurrentRequestUrl().getProtocol() + '://' + URL.getCurrentRequestUrl().getHost() 
                    + '/lightning/r/Case/' + caseId + '/view';
        String title = 'お問合せが作成されました【お問合せ番号:' + ca.CaseNumber + '】';
        String body = 'CCP事務局　各位\n\n'
                    + 'FusoFamilyサイト上でお問合せが起票されました。\n'
                    + '以下URLよりお問合せ内容をご確認の上、お客様へご回答をお願いします。\n\n' + Url;

        CCP_NotificationsUtil.notifyUsers(recipientsIds, caseId, title, body, notificationTypeId);
    }
    
    /*
    * @method uploadFile() 
    * @desc Creates a content version from a given file's base64 and name
    * 
    * @param {String} base64 - base64 string that represents the file
    * @param {String} filename - full file name with extension, i.e. 'products.csv'
    * @param {String} recordId - Id of the record you want to attach this file to
    * 
    * @return {ContentVersion} - returns the created ContentDocumentLink Id if the
    *   upload was successful, otherwise returns null
    */
    // @AuraEnabled
    // public static String uploadFile(String base64, String filename, String recordId) {
    //     System.debug('recordId:' + recordId);
    //     ContentVersion cv = createContentVersion(base64, filename);
    //     ContentDocumentLink cdl = createContentLink(cv.Id, recordId);
    //     if (cv == null || cdl == null) { return null; }
    //     return cdl.Id;
    // }

    /*
    * @method createContentVersion() [private]
    * @desc Creates a content version from a given file's base64 and name
    * 
    * @param {String} base64 - base64 string that represents the file
    * @param {String} filename - full file name with extension, i.e. 'products.csv'
    * 
    * @return {ContentVersion} - returns the newly created ContentVersion, or null
    *   if there was an error inserting the record
    */
    // private static ContentVersion createContentVersion(String base64, String filename) {
    //     ContentVersion cv = new ContentVersion();
    //     cv.VersionData = EncodingUtil.base64Decode(base64);
    //     cv.Title = filename;
    //     cv.PathOnClient = filename;
    //     try {
    //         insert cv;
    //         return cv;
    //     } catch(DMLException e) {
    //         System.debug(e);
    //         return null;
    //     }
    // }

    /*
    * @method createContentLink() [private]
    * @desc Creates a content link for a given ContentVersion and record
    * 
    * @param {String} contentVersionId - Id of the ContentVersion of the file
    * @param {String} recordId - Id of the record you want to attach this file to
    * 
    * @return {ContentDocumentLink} - returns the newly created ContentDocumentLink, 
    *   or null if there was an error inserting the record
    */
    private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        if (contentVersionId == null || recordId == null) {
            return null; 
        }
        ContentDocumentLink cdl = new ContentDocumentLink();
        ContentVersion cv = [SELECT ccpRegisterFlag__c, ContentDocumentId FROM ContentVersion WHERE Id =: contentVersionId];
        cv.ccpRegisterFlag__c = true;
        update cv;
        cdl.ContentDocumentId = cv.ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        // ShareType is either 'V', 'C', or 'I'
        // V = Viewer, C = Collaborator, I = Inferred
        cdl.ShareType = 'V';
        try {
            insert cdl;
            return cdl;
        } catch(DMLException e) {
            System.debug(e);
            throw new DMLException(e.getMessage());
        }
    }

    /** 
    * @Description it will return false if the user is guest user
    * @return {Boolean} - return the page 
    */
    @AuraEnabled
    public static Boolean userTypeJudgment(){
        User user  = CCP_UserUtil.getUserInfo();
        if(CCP_UserUtil.isGuestUser()){
            return false;
        }
        return true;
    }

    private static Id getContactId(){
        User user = CCP_UserUtil.getUserInfo();
        Id contactId = null;
        if(user.ContactId != null){
            contactId = user.ContactId;
        }
        return contactId;
    }

    private static void dummy() {

        Integer d1;
        Integer d2;
        Integer d3;
        Integer d4;
        Integer d5;
        Integer d6;
        Integer d7;
        Integer d8;
        Integer d9;
        Integer d10;
    }
}