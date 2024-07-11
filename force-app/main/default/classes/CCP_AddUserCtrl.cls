public with sharing class CCP_AddUserCtrl {

    /** 
    * @Description get current portal user contact info
    * @return {contact} - return the contect info
    */
    @AuraEnabled
    public static Contact getContactData(){
        Contact contact = null;
        Id contactId = getContactId();
        if(contactId != null){
            contact = [SELECT Id, FirstName, LastName, firstNameKana__c, lastNameKana__c, Department, Title, Email, Phone, MobilePhone,
                                Account.Name, Account.siebelAccountCode__c, mostLikelyWeekdayStartTimesForAppoint__c, mostLikelyWeekdayEndTimesForAppoint__c, 
                                mostLikelyHolidayStartTimesForAppoint__c, mostLikelyHolidayEndTimesForAppoint__c
                                FROM Contact WHERE Id = :contactId];
        }
        return contact;
    }

    /** 
    * @Description get the emails of all contacts under the current user's account
    * @return {emailList} - return the email List
    */
    @AuraEnabled
    public static List<String> getContactEmail(){
        List<String> emailList = new List<String>();
        Id contactId = getContactId();
        if(contactId != null){
            Contact contact = [SELECT Id, AccountId FROM Contact WHERE Id = :contactId];
            Id accountId = contact.AccountId;
            Account account = [SELECT Id, (SELECT Id, Email FROM Contacts)  FROM Account WHERE Id = :accountId];
            List<Contact> conList = account.Contacts;
            for(Contact con : conList){
                if(con.Email != null){
                    emailList.add(con.Email);
                }
            }
        }
        return emailList;
    }

    /** 
    * @Description check the contact email is exist 
    * @return {List} - return the true or false string
    */
    public static String checkContactEmail(String email){
        String contactEmailExist = 'false';
        List<Contact> contactList = [SELECT Id, Email FROM Contact WHERE Email = :email];
        if(contactList.size() >= 2){
            contactEmailExist = 'true';
        } 
        return contactEmailExist;
    }

    /** 
    * @Description get all user email on the system
    * @return {List} - return the true or false string
    */
    @AuraEnabled
    public static List<String> checkUserEmail(String email){
        List<String> checkEmailList = new List<String>();
        String userEmailExist = CCP_UserUtil.checkUserEmail(email);
        String contactEmailExist = checkContactEmail(email);
        checkEmailList.add(userEmailExist);
        checkEmailList.add(contactEmailExist);
        return checkEmailList;
    }

    /** 
    * @Description check current user if mangeUser, only manageUser can add user
    * @return {Boolean} - return the Boolean whether the user is a manageuser
    */
    @AuraEnabled
    public static Boolean checkManageUser() {
        Boolean returnValue = false;
        Id contactId = getContactId();
        if(contactId != null){
            Contact contact = [SELECT canManageMember__c FROM Contact WHERE Id = :contactId];
            if (contact.canManageMember__c != null) {
                returnValue = contact.canManageMember__c;
            }
        }
        return returnValue;
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
    
    /** 
    * @Description Create a new contact based on the information provided
    * @param {Id} accountId - The user account id
    * @param {String} accountCode - The user accountCode
    * @param {String} contactInputDataStr - The input contact info
    * @return {contact.Id} - return the id of the newly created contact
    */
    @AuraEnabled
    public static string createContact(Id accountId, String accountCode, String contactInputDataStr) {
        CCP_UserUtil.ContactInputData contactInputData = (CCP_UserUtil.ContactInputData)JSON.deserialize(contactInputDataStr, CCP_UserUtil.ContactInputData.class);
        Contact contact = new Contact();
        // These variables are required for the page
        contact.AccountId = accountId;
		contact.LastName = contactInputData.lastName;
        contact.FirstName = contactInputData.firstName;
        contact.lastNameKana__c = contactInputData.lastNameKana;
        contact.firstNameKana__c = contactInputData.firstNameKana;
        contact.Email = contactInputData.email;
        contact.ccpUseFlag__c = true;
        contact.termsOfService__c = true;
		contact.Employee_Code__c = contactInputData.employeeCode;
        contact.dataProtectionRegulations__c = true;
        contact.agreementDate__c = Date.today();
        // the department and title is the optional variable on the page
        if(contactInputData.phone != null){
            contact.Phone = contactInputData.phone;
        }
        if(contactInputData.mobilePhone != null){
            contact.MobilePhone = contactInputData.mobilePhone;
        }
        if(contactInputData.department != null){
            contact.Department = contactInputData.department;
        }
        if(contactInputData.title != null){
            contact.Title = contactInputData.title;
        }
        Savepoint sp = Database.setSavepoint();
        try {
            List<Contact> contactList = [SELECT Id, Email FROM Contact WHERE Email = :contactInputData.email];
            if(contactList.size() == 1){
                contact.Id = contactList[0].Id;
                update contact;
            } else{
                insert contact;
            }
            return contact.Id;
        } catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /** 
    * @Description Create a new user based on the information provided
    * @param {Id} contactId - The user contact id
    * @param {String} accountCode - The user accountCode
    * @param {String} contactInputDataStr - The input contact info
    * @param {Boolean} vrChecked - The vehiclereservation service
    * @param {Boolean} rbChecked - The requestbook service
    * @return {userId} - return the id of the newly created User
    */
    @AuraEnabled
    public static Id createUser(Id contactId, String accountCode, String contactInputDataStr,Boolean vrChecked, Boolean rbChecked,
	Boolean fsChecked, Boolean ombChecked, Boolean vmChecked, Boolean cmChecked){
        Id userId = CCP_UserUtil.createCustomerCommonUser(contactId, accountCode, contactInputDataStr);
        // if(userId != null){
        //     // send welcome email to newly user
        //     sendEmailToUser(userId, contactId);
        // }
        setPermissionSetforUser(userId,vrChecked,rbChecked,
		fsChecked,ombChecked,vmChecked,cmChecked);
        return userId;
    }

    /** 
    * @Description addPermissionSet to user by used service
    * @param {Id} userId - The user id
    * @param {Boolean} vrChecked - The vehiclereservation service
    * @param {Boolean} rbChecked - The requestbook service
    */
    @AuraEnabled
    public static void setPermissionSetforUser(Id userId, Boolean vrChecked, Boolean rbChecked,Boolean fsChecked, Boolean ombChecked, Boolean vmChecked, Boolean cmChecked){
        try{
            if(vrChecked){
                PermissionSetAssignment vsa = new PermissionSetAssignment(PermissionSetId = CCP_CommonConstants.DIRECTBOOKINGID, AssigneeId = userId);
                insert vsa;
            }
            if(rbChecked){
                PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = CCP_CommonConstants.EINVOICEID, AssigneeId = userId);
                insert psa;
            }
			if(fsChecked){
                PermissionSetAssignment fsa = new PermissionSetAssignment(PermissionSetId = CCP_CommonConstants.FINANCIALSERVICEID, AssigneeId = userId);
                insert fsa;
            }
			if(cmChecked){
                PermissionSetAssignment cma = new PermissionSetAssignment(PermissionSetId = CCP_CommonConstants.COSTMANAGEMENTID, AssigneeId = userId);
                insert cma;
            }
			if(ombChecked){
                PermissionSetAssignment mba = new PermissionSetAssignment(PermissionSetId = CCP_CommonConstants.MAINTENANCEBOOKINGID, AssigneeId = userId);
                insert mba;
            }
			if(vmChecked){
                PermissionSetAssignment vma = new PermissionSetAssignment(PermissionSetId = CCP_CommonConstants.VEHICLEMANAGEMENTID, AssigneeId = userId);
                insert vma;
            }
        }catch(Exception e){
            throw new DmlException('setPermissionSetforUser error :'+e.getMessage());
        }
    }

    /** 
    * @Description Send an email to the newly created user
    * @param {Id} userId - the newly user Id
    * @param {Id} contactId - the newly user contactId
    */
    // private static void sendEmailToUser(Id userId, Id contactId){
    //     List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
    //     EmailTemplate emailTemplate = [SELECT Id, Subject, Body, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'accountIssuingNotification'];
    //     Contact contact = [SELECT Id, Email, Account.Name FROM Contact WHERE Id = :contactId];
    //     OrgwideEmailAddress[] orgwideaddress = [SELECT Id FROM orgwideEmailAddress WHERE displayname = '三菱ふそう'];

    //     Set<Id> userIds = new Set<Id>();
    //     userIds.add(userId);
    //     User newlyUser = CCP_UserUtil.getUserInfoById(userIds)[0];
    //     User currentUser = CCP_UserUtil.getUserInfo();

    //     String htmlBody = emailTemplate.HtmlValue;
    //     String plainTextBody= emailTemplate.Body;
    //     String loginUrl = getLoginURL();

    //     htmlBody = htmlBody.replace('{@AccountName}', contact.Account.Name != null ? contact.Account.Name : '');
    //     plainTextBody = plainTextBody.replace('{@AccountName}', contact.Account.Name != null ? contact.Account.Name : '');
    //     htmlBody = htmlBody.replace('{@contactEmail}', contact.Email != null ? contact.Email : '');
    //     plainTextBody = plainTextBody.replace('{@contactEmail}', contact.Email != null ? contact.Email : '');
    //     htmlBody = htmlBody.replace('{@loginLink}', loginUrl != null ? loginUrl : '');
    //     plainTextBody = plainTextBody.replace('{@loginLink}', loginUrl != null ? loginUrl : '');

    //     String htmlBodyToUser = htmlBody;
    //     String plainTextBodyToUser = plainTextBody;
    //     htmlBodyToUser = htmlBodyToUser.replace('{@UserName}', newlyUser.Name != null ? newlyUser.Name : '');
    //     plainTextBodyToUser = plainTextBodyToUser.replace('{@UserName}', newlyUser.Name != null ? newlyUser.Name : '');
        
    //     Messaging.SingleEmailMessage emailToUser = new Messaging.SingleEmailMessage();
    //     emailToUser.subject = emailTemplate.Subject;
    //     emailToUser.plainTextBody = plainTextBodyToUser;
    //     emailToUser.setOrgWideEmailAddressId(orgwideaddress[0].Id);
    //     emailToUser.setHtmlBody(htmlBodyToUser);
    //     emailToUser.setTemplateId(emailTemplate.Id);
    //     emailToUser.setSaveAsActivity(false);
    //     emailToUser.setTargetObjectId(userId);
    //     allmsg.add(emailToUser);

    //     Messaging.SingleEmailMessage emailToManager = new Messaging.SingleEmailMessage();
    //     htmlBody = htmlBody.replace('{@UserName}', currentUser.Name != null ? currentUser.Name : '');
    //     plainTextBody = plainTextBody.replace('{@UserName}', currentUser.Name != null ? currentUser.Name : ''); 

    //     emailToManager.subject = emailTemplate.Subject;
    //     emailToManager.plainTextBody = plainTextBody;
    //     emailToManager.setOrgWideEmailAddressId(orgwideaddress[0].Id);
    //     emailToManager.setHtmlBody(htmlBody);
    //     emailToManager.setTemplateId(emailTemplate.Id);
    //     emailToManager.setSaveAsActivity(false);
    //     emailToManager.setTargetObjectId(currentUser.Id);
    //     allmsg.add(emailToManager);

    //     try {
    //         CCP_SendEmailUtil.sendEmailUtil(allmsg);
    //     } catch (Exception e) {
    //         System.debug('The email failed to send:' + e.getMessage());
    //     }
    // }

    /** 
    * @Description get the site LoginURL
    * @return {String} - return the LoginURL
    */
    public static String getLoginURL() {
        String result = null;
        AuthProvider authResult = [SELECT friendlyName, authorizeUrl, consumerKey, defaultScopes FROM AuthProvider WHERE FriendlyName = 'FUSOSSO_CCP' LIMIT 1];
        String friendlyName = String.valueOf(authResult.friendlyName);
        String authURL = String.valueOf(authResult.authorizeUrl);
        String client_id = String.valueOf(authResult.consumerKey);
        String scope = String.valueOf(authResult.defaultScopes).replaceAll(' ','+');
        String callbackURL = URL.getOrgDomainUrl().toExternalForm() + '/services/authcallback/' + friendlyName;
        callbackURL = callbackURL.replaceAll(':', '%3A').replaceAll('/', '%2F').replace('salesforce', 'site');
        result = authURL + '?response_type=code&client_id=' + client_id + '&redirect_uri=' + callbackURL + '&scope=' + scope;
        return result;
    }
    
    /** 
    * @Description get the contact Id of the current user
    * @return {ContactId} - return the contact id of the current User
    */
    private static Id getContactId(){
        Id contactId = null;
        Id portalUserId = UserInfo.getUserId();
        User portalUser = [SELECT ContactId FROM User WHERE Id = :portalUserId];
        if(portalUser.ContactId != null){
            contactId = portalUser.ContactId;
        }
        return contactId;
    }

    /** 
    * @Description addPermissionSet to user by used service
    * @param {Id} userId - The user id
    * @return 
    */
    @AuraEnabled
    public static Map<String,Boolean> getUserPermissionSet(Id userId){
        try{
            Map<String,Boolean> res = new Map<String,Boolean>();
            Integer conut = [SELECT COUNT() FROM PermissionSetAssignment WHERE PermissionSetId = :CCP_CommonConstants.DIRECTBOOKINGID AND AssigneeId = :userId];
            if(conut > 0){
                res.put('Direct_Booking', true);
            }
            Integer conut1 = [SELECT COUNT() FROM PermissionSetAssignment WHERE PermissionSetId = :CCP_CommonConstants.EINVOICEID AND AssigneeId = :userId];
            if(conut1 > 0){
                res.put('E_invoice', true);
            }
			/*Integer conut2 = [SELECT COUNT() FROM PermissionSetAssignment WHERE PermissionSetId = :CCP_CommonConstants.EINVOICENEWID AND AssigneeId = :userId];
            if(conut2 > 0){
                res.put('FUSO_CCP_External_E_invoice_new', true);
            }*/
			Integer conut3 = [SELECT COUNT() FROM PermissionSetAssignment WHERE PermissionSetId = :CCP_CommonConstants.FINANCIALSERVICEID AND AssigneeId = :userId];
            if(conut3 > 0){
                res.put('FUSO_CCP_External_Financial_service', true);
            }
			/*Integer conut4 = [SELECT COUNT() FROM PermissionSetAssignment WHERE PermissionSetId = :CCP_CommonConstants.BASICSERVICEID AND AssigneeId = :userId];
            if(conut4 > 0){
                res.put('FUSO_CCP_External_Basic_Service_EC', true);
            }*/
			Integer conut5 = [SELECT COUNT() FROM PermissionSetAssignment WHERE PermissionSetId = :CCP_CommonConstants.COSTMANAGEMENTID AND AssigneeId = :userId];
            if(conut5 > 0){
                res.put('FUSO_CCP_External_Cost_management', true);
            }
			Integer conut6 = [SELECT COUNT() FROM PermissionSetAssignment WHERE PermissionSetId = :CCP_CommonConstants.MAINTENANCEBOOKINGID AND AssigneeId = :userId];
            if(conut6 > 0){
                res.put('FUSO_CCP_External_Online_maintenance_booking', true);
            }
			Integer conut7 = [SELECT COUNT() FROM PermissionSetAssignment WHERE PermissionSetId = :CCP_CommonConstants.VEHICLEMANAGEMENTID AND AssigneeId = :userId];
            if(conut7 > 0){
                res.put('FUSO_CCP_External_Vehicle_management', true);
            }
            return res;
        }catch(Exception e){
            throw new DmlException('getUserPermissionSet error :'+e.getMessage());
        }
    }

    /** 
    * @Description addPermissionSet to user by used service
    * @return the Boolean
    */
    @AuraEnabled
    public static Boolean checkUserNumber(){
        try{
            Id conId = getContactId();
            String code = [SELECT Id, Account.siebelAccountCode__c FROM Contact WHERE Id = :conId LIMIT 1].Account.siebelAccountCode__c;
            Integer count = [SELECT count()  FROM Contact WHERE Account.siebelAccountCode__c = :code AND ccpUseFlag__c = true ];
            System.debug('count'+count);
            if(count > 2){
                 return false;
            }
            return true;
            
        }catch(Exception e){
            throw new AuraHandledException('checkUserNumber error :'+e.getMessage());
        }
    }
}