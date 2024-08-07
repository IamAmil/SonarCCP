/**
* @Author: Dominic Li
* @Date: 2023-04-20 
* @LastEditTime: 2023-04-20 
* @Description 共通資源
*/
public without sharing class CCP_CommonConstants {
    // 発行状況
    public final static String UNISSUED = '未発行';
    public final static String ISSUED = '発行済み';
    public final static String REISSUED = '再発行申請中';
    public final static String MAILED = '再発行郵送済み';
    public final static String REISSUEDDONE = '再発行受取済';

    // 発行ボタン
    public final static String PUBLISH = '発行';
    public final static String REPUBLISH = '再発行';
    public final static String RECEIPTCOMPLETED = '受取確認';
    

    //ケースレコードタイプ：CPお問い合わせ
    public final static String CPCASEID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('cpCase') .getRecordTypeId();

    //knowledgeレコードタイプ：ニュース
    public final static String NEWSID = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('News') .getRecordTypeId();

    //ニュース 内容
    public final static String NEWSCONTENT = '【2023年5月（10日締め）】請求書発行のお知らせ';
    //ニュース url内容
    public final static String NEWSURLCONTENT = '請求書公開のお知らせ';

    //問い合わせの種類
    public final static String MONTHLYAPPLYCASE = '部整月次請求書（電子版）に関するお問い合わせ';
    public final static String USERINFOAPPLYCASE = '会員情報に関するお問い合わせ';
    public final static String OTHERAPPLYCASE = 'その他のお問い合わせ';

    //問い合わせの発生源
    public final static String CUSTOMERPORTAL = 'Customer Portal';

    //問い合わせの内容
    public final static String MONTHLYAPPLYCASEDESCRIPTION = 'について、再発行の依頼が来ました。';

    //日
    public final static String DAY = '日';
    //年
    public final static String YEAR = '年';
    //月
    public final static String MONTH = '月';
    //月末
    public final static String MONTHEND = '月末';
    //締め日リスト
    public final static List<String> SIMEBILSIT = new List<String>{'10日', '20日', '月末'};
    //月末
    public final static String FILEMONTHEND = 'EO';
    //締め
    public final static String FINISH = '締め';
    //FUSO Customer Community
    public final static Id FUSOCOMMUNITYPROFILEID = [SELECT Id FROM Profile WHERE Name = 'FUSO Customer Community Plus Login User' LIMIT 1].Id;
    //FUSO group Id
    public final static Id FUSOGROUPID = [SELECT Id FROM Group WHERE DeveloperName = 'fuso' LIMIT 1].Id;
    //運用事務局キューId
    public final static Id OPERATIONID = [SELECT Id,Name FROM Group WHERE Type = 'Queue' AND Name = '運用事務局キュー'].Id;
    //権限セットDirect_BookingId
    public final static Id DIRECTBOOKINGID = [SELECT Id FROM permissionset WHERE Name = 'Direct_Booking'].Id;
    //権限セットE_invoiceId
    public final static Id EINVOICEID = [SELECT Id FROM permissionset WHERE Name = 'E_invoice'].Id;
	
	//public final static Id EINVOICENEWID = [SELECT Id FROM permissionset WHERE Name = 'FUSO_CCP_External_E_invoice_new'].Id;
	public final static Id FINANCIALSERVICEID = [SELECT Id FROM permissionset WHERE Name = 'FUSO_CCP_External_Financial_service'].Id;
	//public final static Id BASICSERVICEID = [SELECT Id FROM permissionset WHERE Name = 'FUSO_CCP_External_Basic_Service_EC'].Id;
	public final static Id COSTMANAGEMENTID = [SELECT Id FROM permissionset WHERE Name = 'FUSO_CCP_External_Cost_management'].Id;
	public final static Id MAINTENANCEBOOKINGID = [SELECT Id FROM permissionset WHERE Name = 'FUSO_CCP_External_Online_maintenance_booking'].Id;
	public final static Id VEHICLEMANAGEMENTID = [SELECT Id FROM permissionset WHERE Name = 'FUSO_CCP_External_Vehicle_management'].Id;
    //権限セットFUSO CCP External User Manager
    public final static Id MANAGERID = [SELECT Id FROM permissionset WHERE Name = 'FUSO_CCP_External_User_Manager'].Id;
    //custom portal domain
    public final static String COMMUNITYALT = [SELECT Domain FROM Domain where httpsoption = :System.Label.CCP_Domain_Httpsoption].Domain;
    //case status クローズ
    public final static String CLOSED = 'Closed';
    //case status 郵送済み
    public final static String MAILDONE = 'MailDone';
    //category リリースニュース
    public final static String CATEGORY5 = 'Category5';
    //category グループ
    public final static String FUSOKNOWLEDGECATEGORY = 'FusoKnowledgeCategory';
    //ナレッジ 承認公開状況
    public final static String PUBLISHWAITING = '承認済み';
    public final static String NOTAPPROVAL = '未承認';
}