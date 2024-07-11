public without sharing class CCP_UserUtil {

    /** 
    * @Description Create a new User based on the information provided
    * @param {Id} contactId - The user contact id
    * @param {String} accountCode - The user accountCode
    * @param {String} contactInputDataStr - The input contact info
    * @return {Id} - return the id of the newly created user
    */
    public static Id createCustomerCommonUser(Id contactId, String accountCode, String contactInputDataStr){
        ContactInputData contactInputData = (ContactInputData)JSON.deserialize(contactInputDataStr, ContactInputData.class);
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'FUSO Customer Community Plus Login User' Limit 1];
        String domainUrl = System.Url.getSalesforceBaseUrl().getHost();
        String domain = domainUrl.substringBefore('.');
        //Create Portal User
        String nickName = contactInputData.email.subString(0, contactInputData.email.indexof('@')); 
        User user = new User();
        user.UserName = contactInputData.email + '.' + domain;
        user.FirstName = contactInputData.firstName;
        user.LastName = contactInputData.lastName;
        user.Email = contactInputData.email;
        user.ContactId = contactId;
        user.ProfileId = portalProfile.Id;
        user.FederationIdentifier = contactInputData.email;
        user.UserPermissionsKnowledgeUser = true;
        user.Alias = nickName.left(8);
        user.EmailEncodingKey = 'UTF-8';
        user.CommunityNickname = nickName;
        user.TimeZoneSidKey = 'Asia/Tokyo';
        user.LocaleSidKey = 'ja_JP';
        user.LanguageLocaleKey = 'ja';
        if(contactInputData.phone != null){
            user.Phone = contactInputData.phone;
        }
        if(contactInputData.mobilePhone != null){
            user.MobilePhone = contactInputData.mobilePhone;
        }
        if(contactInputData.department != null){
            user.Department = contactInputData.department;
        }
        if(contactInputData.title != null){
            user.Title = contactInputData.title;
        }
        Savepoint sp = Database.setSavepoint();
        try {
            insert user;
            return user.Id;
        } catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /** 
    * @Description update contact info
    * @return contact Id
    */
    public static void updateContactInfo(Contact contact){
        update contact;
    }

    /** 
    * @Description get all user email on the system
    * @return {List} - return all user email list
    */
    public static String checkUserEmail(String userEmail){
        String userEmailExist = 'false';
        List<User> userList = [SELECT Id, Email FROM User WHERE Email = :userEmail];
        if(userList.size() > 0){
            userEmailExist = 'true';
        }
        return userEmailExist;
    }

    /** 
    * @Description get current User Info
    * @return {User} - return the current User Info
    */
    public static User getUserInfo(){
        Id userId = UserInfo.getUserId();
        User user = [SELECT Id, Name, ContactId, ProfileId, ManagerId, Manager.Name FROM User WHERE Id = :userId];
        return user;
    }

    /** 
    * @Description check current user wheather guest user
    * @return {Boolean} - return the current User Info
    */
    public static Boolean isGuestUser(){
        //Profile guestUserProfile = [SELECT Id FROM Profile WHERE Name = 'portal Profile'];
        Profile guestUserProfile = [SELECT Id FROM Profile WHERE Name = :System.Label.CCP_Portal_Profile];
        User user = getUserInfo();
        if(user.ProfileId != guestUserProfile.Id){
            return false;
        }
        return true;
    }
    /**
     * @return ユーザ情報が取引先住所とId含めています。
     */
    public static User getUserWithAccountInfo(){
        return [
                SELECT
                        Id, Name, ContactId, Contact.FirstName,Contact.LastName, Contact.firstNameKana__c, Contact.lastNameKana__c,
                        Contact.Email,Contact.Phone,Contact.MobilePhone,Contact.Department,Contact.Title,
                        Contact.AccountId,Contact.Account.lbc_company_pref_id__c,Contact.Account.lbc_company_city_id__c,
                        Contact.Account.prefectureCodeForce__c,Contact.Account.cityTownCodeForce__c,
                        Contact.Account.sectionOfVillageAkaCodeForce__c,Contact.Account.azaChomeCodeForce__c,
                        Contact.Account.Name, Contact.Account.siebelAccountCode__c,
                        Contact.Account.lbc_company_addr1__c,Contact.Account.lbc_company_addr2__c,
                        Contact.Account.lbc_company_addr3__c,Contact.Account.lbc_company_addr4__c,
                        Contact.Account.lbc_company_addr5__c,Contact.Account.lbc_company_addr6__c
                FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
    }

    /** 
    * @Description return ccpSecretariatGroup user info
    * @return {List} userList - the user List
    */
    public static List<User> getGroupUser(){
        return [SELECT Id, Name FROM User 
                    WHERE isActive = TRUE AND Id IN 
                        (SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'ccpSecretariatGroup')];
    }
    
    /** 
    * @Description return user info by Id
    * @return {List} userList - the user List
    */
    public static List<User> getUserInfoById(Set<Id> userIds){
        return [SELECT Id, Name, ManagerId, Manager.Name FROM User WHERE Id IN :userIds];
    }

    /** 
    * @method: permissionDBCheck(Id uId)
    * @Description: check if this user has the permission.
    * @return {Boolean} - return Boolean value.
    * 
    */
    @AuraEnabled
    public static Boolean permissionDBCheck(Id uId){

        //Direct_booking権限
        Integer conut1 = [SELECT COUNT() FROM PermissionSetAssignment WHERE PermissionSetId = :CCP_CommonConstants.DIRECTBOOKINGID AND AssigneeId = :uId];
        if(conut1 == 0){
            return false;
        }
        return true;
    }

    /** 
    * @method: permissionEICheck(Id uId)
    * @Description: check if this user has the permission.
    * @return {Boolean} - return Boolean value.
    * 
    */
    @AuraEnabled
    public static Boolean permissionEICheck(Id uId){

        //EINVOICE権限
        Integer conut1 = [SELECT COUNT() FROM PermissionSetAssignment WHERE PermissionSetId = :CCP_CommonConstants.EINVOICEID AND AssigneeId = :uId];
        if(conut1 == 0){
            return false;
        }
        return true;
    }

    /** 
    * @method: userFDPCheck(Id uId)
    * @Description: check if this user has the permission.
    * @return {Boolean} - return Boolean value.
    * 
    */
    @AuraEnabled
    public static Boolean userFDPCheck(Id uId){
        try{
            //FDP user
            Id conId;
            User usr = [SELECT ContactId FROM User WHERE Id = :uId LIMIT 1];
            if(usr != NULL){
                conId = usr.ContactId;
            }
            Contact con = [SELECT Id,Account.FDP__c FROM Contact WHERE Id = :conId LIMIT 1];
            Boolean carSwitch = false;
            if(System.Label.CCP_Vehicle_Reservation_Switch == 'ON' ){
                carSwitch = true;
            }
            if(con != NULL){
                if(con.Account.FDP__c){
                    return true;
                }else{
                    return !carSwitch;
                }
            }

            return false;
        }catch(Exception e){
            throw new DmlException('userFDPCheck error :'+e.getMessage());
        }
    }
    
    public class ContactInputData{
        @AuraEnabled
        public String lastName{ get; set; }
        @AuraEnabled
        public String firstName{ get; set; }
        @AuraEnabled
        public String lastNameKana{ get; set; }
        @AuraEnabled
        public String firstNameKana{ get; set; }
        @AuraEnabled
        public String department{ get; set; }
        @AuraEnabled
        public String title{ get; set; }
        @AuraEnabled
        public String email{ get; set; }
        @AuraEnabled
        public String phone{ get; set; }
        @AuraEnabled
        public String employeeCode{ get; set; }
        @AuraEnabled
        public String mobilePhone{ get; set; }
    }
}