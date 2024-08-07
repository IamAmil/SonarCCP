@IsTest
private class CCP_UserUtilTest {
    @TestSetup
    static void makeData(){
        Profile customerProfile = [SELECT Id FROM Profile WHERE Name = 'FUSO Customer Community Plus Login User' LIMIT 1];
        //Profile adProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        Profile adProfile = [SELECT Id FROM Profile WHERE Name = :System.Label.CCP_Administrator_Profile LIMIT 1];
        //Profile guestUserProfile = [SELECT Id FROM Profile WHERE name = 'Portal Profile' LIMIT 1];
        Profile guestUserProfile = [SELECT Id FROM Profile WHERE name = :System.Label.CCP_Portal_Profile LIMIT 1];
        UserRole adRole = [SELECT Id FROM UserRole WHERE PortalType = 'None' AND Name = '国内販売・カスタマーサービス本部'];
     
        User portalAccountOwner = new User(
            UserRoleId = adRole.Id,
            ProfileId = adProfile.Id,
            Username = 'administrator@portaltest.com',
            Alias = 'batman',
            Email='bruce.wayne@wayneenterprises.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='ja',
            LocaleSidKey='ja_JP',
            TimeZoneSidKey='Asia/Tokyo',
            UserPermissionsKnowledgeUser = true
        );
        insert portalAccountOwner;
        
        System.runAs ( portalAccountOwner ) {
            Account account = new Account();
            account.Name = 'Portal Test';
            account.OwnerId = portalAccountOwner.Id;
            account.siebelAccountCode__c = '123321123';
            insert account;

            Contact contact = new Contact();
            contact.AccountId = account.Id;
            contact.FirstName = 'contact';
            contact.LastName = 'test';
            contact.Email = 'test@sample.com';
            insert contact;

            User portalUser = new User();
            portalUser.ProfileId = customerProfile.Id;
            portalUser.ContactId = contact.Id;
            portalUser.FirstName = 'ユーザー';
            portalUser.LastName = 'テスト';
            portalUser.Email = 'test_user@example.com';
            portalUser.EmailEncodingKey = 'UTF-8';
            portalUser.LanguageLocaleKey = 'ja';
            portalUser.LocaleSidKey = 'ja_JP';
            portalUser.TimeZoneSidKey = 'Asia/Tokyo';
            portalUser.Username = 'test_user@portalexample.com';
            portalUser.Alias = 'テユ';
            portalUser.CommunityNickname = 'テストユーザー';
            portalUser.UserPermissionsKnowledgeUser = true;
            portalUser.IsActive = true;
            insert portalUser;

            User guestUser = new User();
            guestUser.ProfileId = guestUserProfile.Id;
            guestUser.FirstName = 'guest';
            guestUser.LastName = 'user';
            guestUser.Email = 'guestuser@example.com';
            guestUser.EmailEncodingKey = 'UTF-8';
            guestUser.LanguageLocaleKey = 'ja';
            guestUser.LocaleSidKey = 'ja_JP';
            guestUser.TimeZoneSidKey = 'Asia/Tokyo';
            guestUser.Username = 'guestuser@portalexample.com';
            guestUser.Alias = 'テユ';
            guestUser.CommunityNickname = 'テストユーザーguestuser';
            guestUser.IsActive = true;
            insert guestUser;
        }
    }
    
    @IsTest
    static void createUserTest(){
        User portalUser = [SELECT Id FROM User WHERE Username = 'test_user@portalexample.com'];
        User guestUser = [SELECT Id FROM User WHERE Username = 'guestuser@portalexample.com'];
        Account ac = [SELECT Id, siebelAccountCode__c FROM Account LIMIT 1];
        ContactInputData cd = new ContactInputData();
        cd.lastName = 'Test LastName';
        cd.firstName = 'Test FirstName';
        cd.lastNameKana = 'ユーザー';
        cd.firstNameKana = 'テスト';
        cd.title = 'manager';
        cd.department = 'sales';
        cd.email = 'test@sample.com';
        cd.phone = '1231233321';
        cd.mobilePhone = '213233121';

        Contact contact = new Contact();
        contact.AccountId = ac.Id;
        contact.FirstName = 'contact';
        contact.LastName = 'test';
        contact.Email = 'test1@sample.com';
        insert contact;

        Test.startTest();
        System.runAs(portalUser){
            String userId = CCP_UserUtil.createCustomerCommonUser(contact.Id, ac.siebelAccountCode__c, JSON.serialize(cd));
            System.assertEquals(true, userId!=null);
            User u = CCP_UserUtil.getUserInfo();
            System.assertEquals(true, u!=null);
            CCP_UserUtil.isGuestUser();
        }
        System.runAs(guestUser){
            CCP_UserUtil.isGuestUser();
        }
        Test.stopTest();
    }

    @isTest
    static void checkUserEmailTest() {
        Test.startTest();
        String checkUserEmailResult = CCP_UserUtil.checkUserEmail('test@sample.com');
        System.assertEquals(true, checkUserEmailResult!=null);
        Test.stopTest();
    }

    @isTest
    static void getUserWithAccountInfoTest() {
        User portalUser = [SELECT Id FROM User WHERE Username = 'test_user@portalexample.com'];
        Test.startTest();
        System.runAs(portalUser){
            User u = CCP_UserUtil.getUserWithAccountInfo();
            System.assertEquals(true, u!=null);
        }
        Test.stopTest();
    }

    @isTest
    static void updateContactInfoTest() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        Test.startTest();
            c.LastName = 'test1';
            CCP_UserUtil.updateContactInfo(c);
        Test.stopTest();
    }

    @isTest
    static void getGroupUserTest() {
        Test.startTest();
            List<User> result = CCP_UserUtil.getGroupUser();
            System.assertEquals(true, result!=null);
        Test.stopTest();
    }

    @isTest
    static void getUserInfoByIdTest() {
        User portalUser = [SELECT Id FROM User WHERE Username = 'test_user@portalexample.com'];
        Test.startTest();
        Set<Id> ids = new Set<Id>();
        ids.add(portalUser.Id);

        List<User> result = CCP_UserUtil.getUserInfoById(ids);
        System.assertEquals(true, result!=null);
        Test.stopTest();
    }

    @isTest
    static void checkTest() {
        User portalUser = [SELECT Id FROM User WHERE Username = 'test_user@portalexample.com'];
        Test.startTest();
        CCP_UserUtil.permissionDBCheck(portalUser.Id);
        CCP_UserUtil.permissionEICheck(portalUser.Id);
        CCP_UserUtil.userFDPCheck(portalUser.Id);
        Test.stopTest();
    }

    private class ContactInputData{
        public String lastName{get; set;}
        public String firstName{get; set;}
        public String lastNameKana{get; set;}
        public String firstNameKana{get; set;}
        public String title{get; set;}
        public String department{get; set;}
        public String email{get; set;}
        public String phone{get; set;}
        public String mobilePhone{get; set;}
    }
}