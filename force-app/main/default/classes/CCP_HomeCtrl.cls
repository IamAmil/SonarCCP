public with sharing class CCP_HomeCtrl {

    @AuraEnabled
    public static List<Knowledge__kav> getCampaignData(){
        ID recordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('campaign').getRecordTypeId();
        List<Knowledge__kav> campaignList = [SELECT Id, Title, campaignLink__c, Description__c FROM Knowledge__kav 
                                                WHERE RecordTypeId = :recordTypeId AND validDateFrom__c  <= TODAY AND validDateTo__c >= TODAY 
                                                AND PublishStatus = 'Online' AND IsVisibleInCsp = true AND IsVisibleInPkb = true];
        return campaignList;
    }
    
    @AuraEnabled
    public static List<Knowledge__kav> getUrgentNews(){
        List<Knowledge__kav> urgentNewsList = new List<Knowledge__kav>();
        ID recordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('UrgentNews').getRecordTypeId();
        urgentNewsList = [SELECT Id, Title, validDateFrom__c, UrlName, Description__c FROM Knowledge__kav 
                            WHERE RecordTypeId = :recordTypeId AND validDateFrom__c <= TODAY AND validDateTo__c >= TODAY AND PublishStatus = 'Online'
                            ORDER BY validDateFrom__c DESC, CreatedDate DESC];
        return urgentNewsList;
    }
    
    @AuraEnabled
    public static List<Knowledge__kav> getNews(Integer limitNumber){
        List<Knowledge__kav> newsList = new List<Knowledge__kav>();
        ID recordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('News').getRecordTypeId();
        newsList = [SELECT Id, Title, postedDate__c, Description__c, UrlName FROM Knowledge__kav 
                        WHERE RecordTypeId = :recordTypeId AND PublishStatus = 'Online' 
                        ORDER BY postedDate__c DESC LIMIT :limitNumber];
        return newsList;
    }

    /** 
    * @description Returns BaseInfo based on the given id
    * @param Id uId - the user Id
    * @return {BaseInfo} BaseInfo - return the BaseInfo 
    */
    @AuraEnabled
    public static BaseInfo getBaseInfoByUserId(Id uId){
        BaseInfo baseInfo = new BaseInfo();
        try{
            Id conId;
            User usr = [SELECT ContactId FROM User WHERE Id = :uId LIMIT 1];
            if(usr != NULL){
                conId = usr.ContactId;
            }
            Contact con = [SELECT Id,Account.FDP__c, Account.EInvoiceFlag__c FROM Contact WHERE Id = :conId LIMIT 1];
            if(con != NULL){
                baseInfo.isFDP = con.Account.FDP__c;
            }
            Integer conut = [SELECT COUNT() FROM PermissionSetAssignment WHERE PermissionSetId = :CCP_CommonConstants.DIRECTBOOKINGID AND AssigneeId = :uId];
            if(conut > 0){
                baseInfo.directBook = true;
            }
            Integer conut1 = [SELECT COUNT() FROM PermissionSetAssignment WHERE PermissionSetId = :CCP_CommonConstants.EINVOICEID AND AssigneeId = :uId];
            if(conut1 > 0 && con.Account.EInvoiceFlag__c){
                baseInfo.eInvoice = true;
            }
            Integer conut2 = [SELECT COUNT() FROM PermissionSetAssignment WHERE PermissionSetId = :CCP_CommonConstants.MANAGERID AND AssigneeId = :uId];
            if(conut2 > 0){
                baseInfo.isManager = true;
            }
			
			
			Integer conut3 = [SELECT COUNT() FROM PermissionSetAssignment WHERE PermissionSetId = :CCP_CommonConstants.COSTMANAGEMENTID AND AssigneeId = :uId];
            if(conut3 > 0){
                baseInfo.costman = true;
            }
			Integer conut4 = [SELECT COUNT() FROM PermissionSetAssignment WHERE PermissionSetId = :CCP_CommonConstants.MAINTENANCEBOOKINGID AND AssigneeId = :uId];
            if(conut4 > 0){
                baseInfo.onlinemaintenance = true;
            }
			Integer conut5 = [SELECT COUNT() FROM PermissionSetAssignment WHERE PermissionSetId = :CCP_CommonConstants.VEHICLEMANAGEMENTID AND AssigneeId = :uId];
            if(conut5 > 0){
                baseInfo.vehman = true;
            }
			Integer conut6 = [SELECT COUNT() FROM PermissionSetAssignment WHERE PermissionSetId = :CCP_CommonConstants.FINANCIALSERVICEID AND AssigneeId = :uId];
            if(conut6 > 0){
                baseInfo.finanserv = true;
            }
        }catch(Exception e){
            throw new AuraHandledException('getBaseInfoByUserId error :'+e.getMessage());
        }
        return baseInfo;
    }

    /** 
    * @description Returns BaseInfo 
    * @return {BaseInfo} BaseInfo - return the BaseInfo 
    */
    @AuraEnabled
    public static BaseInfo getBaseInfo(){
        BaseInfo baseInfo = new BaseInfo();
        try{
            if(System.Label.CCP_Vehicle_Reservation_Switch == 'ON' ){
                baseInfo.isRES = true;
            }
            if(System.Label.CCP_Vehicle_List_Switch == 'ON' ){
                baseInfo.isVList = true;
            }
        }catch(Exception e){
            throw new AuraHandledException('getBaseInfo error :'+e.getMessage());
        }
        return baseInfo;
    }

    public class BaseInfo{
        @AuraEnabled public Boolean eInvoice;
		@AuraEnabled public Boolean directBook;
		@AuraEnabled public Boolean costman;
        @AuraEnabled public Boolean onlinemaintenance;
		@AuraEnabled public Boolean vehman;
		@AuraEnabled public Boolean finanserv;
        @AuraEnabled public Boolean isManager;
        @AuraEnabled public Boolean isFDP;
        @AuraEnabled public Boolean isRES = false;
        @AuraEnabled public Boolean isVList = false;
        
    }
}