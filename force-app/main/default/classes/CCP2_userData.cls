//userList
//userListDtl
//userDtl
//BranchList
//NewBranchDetails
//UnAssociatedBranch
//VehicleWithoutAssociation
//VehicleWithoutAssociationDtl
//unassociateVehicle
//unassociateUser
//associateUser
//associateVehicle
//accId
//associateBranchtoUser
//BranchVehicleCount
public with sharing class CCP2_userData {
    @AuraEnabled(cacheable=true)
    public static List<Contact> userList()
    {
         //Id accId=accId();
         Id accId='001Io000003ITP2IAO';
        
        List<Contact> user;
            if(accId!=null)
            {
                 user=[select Id, Name,UserId__c, Account.siebelAccountCode__c, Branch__r.Name from Contact where accountId=:accId and canManageMember__c = false and ccpUseFlag__c= true];
            }
        
        System.debug('user ' +user);
        return user;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Contact> userListDtl(Id branchId)
    {
         Id accId=accId();
         //Id accId='001Io000003ITP2IAO';
        
        List<Contact> user;
            /*if(accId!=null)
            {
                 user=[select Id, Name,UserId__c, Account.siebelAccountCode__c, Branch__r.Name from Contact where accountId=:accId and canManageMember__c = false and ccpUseFlag__c= true];
            }*/
        
        if (accId != null) {
        user = [SELECT Id, Name FROM Contact WHERE accountId = :accId AND Id NOT IN (SELECT ContactId__c FROM CCP2_BranchContact_Junction__c WHERE BranchId__c = :branchId)];

        }
        System.debug('user ' +user);
        return user;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Contact> userDtl(Id User,Boolean refresh)
    {
        if(refresh){
            Id accId=accId();
        	List<Contact> userData;
            if(accId!=null)
            {
                 userData=[select Name , id ,Employee_Code__c,Title,firstNameKana__c,lastNameKana__c,Department,Email,Phone , account.id, account.name, account.siebelAccountCode__c, account.Industry, MobilePhone from Contact where accountId=:accId AND Id=:User];
            }
               
        return userData;
        }
        else{
            Id accId=accId();
        	List<Contact> userData;
            if(accId!=null)
            {
                 userData=[select Name , id ,Employee_Code__c,Title,firstNameKana__c,lastNameKana__c,Department,Email,Phone , account.id, account.name, account.siebelAccountCode__c, account.Industry, MobilePhone  from Contact where accountId=:accId AND Id=:User];
            }
               
        	return userData;
        }
         
    }
       @AuraEnabled(cacheable=true)
    public static List<CCP2_Branch__c> userBranchDtl(Id User) {
        try {
            // Query the Branch Ids related to the given User
            List<CCP2_BranchContact_Junction__c> BranchIds = [SELECT BranchId__c FROM CCP2_BranchContact_Junction__c WHERE ContactId__c = :User];
            System.debug(BranchIds);
            // Create a list to hold the Branch Ids
            List<Id> junctionbranchIds = new List<Id>();
            for (CCP2_BranchContact_Junction__c junction : BranchIds) {
                junctionbranchIds.add(junction.BranchId__c);
            }
            System.debug(junctionbranchIds);
            // Query the Branch details using the Branch Ids
            List<CCP2_Branch__c> branchDetails = [SELECT Id, Name FROM CCP2_Branch__c WHERE Id IN :junctionbranchIds];
            system.debug(branchDetails);
            return branchDetails;
        } catch (Exception e) {
            System.debug('Error in userDtl: ' + e.getMessage());
            throw new AuraHandledException('An error occurred while fetching branch details');
        }
    }
    /* @AuraEnabled(cacheable=true)
    public static List<CCP2_BranchContact_Junction__c> userDtl(Id User,Boolean refresh)
    {
        if(refresh){
            //Id accId=accId();
        	//List<Contact> userData;
            //if(accId!=null)
            
           List<CCP2_BranchContact_Junction__c> userData1=[select ContactId__r.Name , ContactId__c,ContactId__r.Employee_Code__c,ContactId__r.Title,ContactId__r.firstNameKana__c,ContactId__r.lastNameKana__c,ContactId__r.Department,ContactId__r.Email,ContactId__r.Phone , ContactId__r.account.id, ContactId__r.account.name, ContactId__r.account.siebelAccountCode__c, ContactId__r.account.Industry, ContactId__r.MobilePhone,BranchId__c,BranchId__r.Name  from CCP2_BranchContact_Junction__c where ContactId__c=:User];
            System.debug(userData1);
               
        return userData1;
        }
        else{
           // Id accId=accId();
        	//List<Contact> userData;
           // if(accId!=null)
            
            List<CCP2_BranchContact_Junction__c> userData1=[select ContactId__r.Name , ContactId__c,ContactId__r.Employee_Code__c,ContactId__r.Title,ContactId__r.firstNameKana__c,ContactId__r.lastNameKana__c,ContactId__r.Department,ContactId__r.Email,ContactId__r.Phone , ContactId__r.account.id, ContactId__r.account.name, ContactId__r.account.siebelAccountCode__c, ContactId__r.account.Industry, ContactId__r.MobilePhone,BranchId__c,BranchId__r.Name  from CCP2_BranchContact_Junction__c where ContactId__c=:User];
            
            System.debug(userData1);   
        	return userData1;
        }
         
    }*/
    
    
    
    @AuraEnabled(cacheable=true)
    public static List<CCP2_Branch__c> BranchList()
    {
        //List<CCP2_Branch__c> branch;
        Id accId=accId();
        List<AggregateResult> veh;
        //Id accId = '001Io000003ITP2IAO';
        List<CCP2_Branch__c> branch= [select id,Account__c, name, Branch_Number__c from CCP2_Branch__c where Account__c=:accId];
    	Integer i=0;
        //System.debug(veh[0]);
        /*Set<Id> branchIds = new Set<Id>();
        for (CCP2_Branch__c branchId : branch){
            branchIds.add(branch.Account__c);
        }
        List<VehicleInfo__c> vehicleCount = new List<VehicleInfo__c>();
        vehicleCount = [Select Id from VehicleInfo__c where userAccountCode__c =: ]
        /*for (CCP2_Branch__c br : branch)
        {
           veh = [select count(Id) con from VehicleInfo__c where userAccountCode__c=:accId];
           String str = String.valueof(veh[i].get('con'));
       	   Integer b= Integer.valueof(str);
           System.debug(b);
          i++;
        }*/
        System.debug(branch);
        return branch;
    }
    
     @AuraEnabled(cacheable=true)
    public static List<CCP2_Branch__c> UnAssociatedBranch(Id contactId)
    {
        //List<CCP2_Branch__c> branch;
        Id accId=accId();
        //Id accId = '001Io000003ITP2IAO';
        List<CCP2_Branch__c> branch = [SELECT Id, Name FROM ccp2_Branch__c WHERE account__c =: accId AND Id NOT IN 
 (SELECT BranchId__c FROM CCP2_BranchContact_Junction__c WHERE ContactId__c =:contactId)];
        System.debug(branch);
        return branch;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<VehicleInfo__c> VehicleWithoutAssociation()
    {
        //List<CCP2_Branch__c> branch;
        Id accId=accId();
        //Id accId = '001Io000003ITP2IAO';
        List<VehicleInfo__c> vehicle= [select id, name from VehicleInfo__c where userAccountCode__c=:accId ];
        System.debug(vehicle);
        return vehicle;
    }
    
     @AuraEnabled(cacheable=true)
    public static List<VehicleInfo__c> VehicleWithoutAssociationDtl(Id branchId)
    {
        //List<CCP2_Branch__c> branch;
        Id accId=accId();
        //Id accId = '001Io000003ITP2IAO';
        List<VehicleInfo__c> vehicle= [SELECT Id, Name FROM VehicleInfo__c WHERE UserAccountCode__c = :accId AND
                                       Id NOT IN (SELECT VehicleId__c FROM CCP2_BranchVehicle_Junction__c WHERE BranchId__c = :branchId)];
        //List<VehicleInfo__c> vehicle= [select id, name from VehicleInfo__c where userAccountCode__c=:accId ];
        System.debug(vehicle);
        return vehicle;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<CCP2_Branch__c> BranchDetails(Id branchId)
    {
        //List<CCP2_Branch__c> branch;
        //Id accId=accId();
        Id accId = '001Io000003ITP2IAO';
        System.debug('branchId:'+branchId);
        System.debug('accId:'+accId);
        List<String> contactNames = new List<String>();
        List<CCP2_Branch__c> branchDetails= [select id, name, Company_Name__c, (select id,name from VehicleBranch__r), Contact__r.name, Tip_Number__c, Branch_Number__c, Contact_No__c, Mention_Name__c, Address__c  from CCP2_Branch__c where account__c=:accId and Id=:branchId];
        //List<CCP2_Branch__c> branchDetails1= [select id, name, Company_Name__c, Tip_Number__c, Branch_Number__c, Contact_No__c, Mention_Name__c, Address__c  from CCP2_Branch__c where account__c=:accId and Id=:branchId];
       
        //System.debug('branchDetails:'+branchDetails);
        return branchDetails;
    }
@AuraEnabled(cacheable=true)
public static Map<String, Object> NewBranchDetails(Id branchId) {
    // Assuming accId is hardcoded for this example
    //Id accId = '001Io000003EtiQIAS';
    Id accId = accId();
    System.debug('branchId:' + branchId);
    System.debug('accId:' + accId);

    // Map to store the combined details
    Map<String, Object> detailsMap = new Map<String, Object>();

    // Query to get branch details
    List<CCP2_Branch__c> branchDetails = [SELECT Id, Name, Company_Name__c, Tip_Number__c, Branch_Number__c, Contact_No__c, Mention_Name__c, Address__c, Account__c, Account__r.siebelAccountCode__c 
                                          FROM CCP2_Branch__c 
                                          WHERE Account__c = :accId AND Id = :branchId ];

    // Query to get contact IDs associated with the branch
    List<CCP2_BranchContact_Junction__c> contactJunctions = [SELECT ContactId__c 
                                                             FROM CCP2_BranchContact_Junction__c 
                                                             WHERE BranchId__c = :branchId];

    // Set to store unique contact IDs
    Set<Id> contactIds = new Set<Id>();
    for (CCP2_BranchContact_Junction__c junction : contactJunctions) {
        contactIds.add(junction.ContactId__c);
    }

    // Query to get contact details
    List<Contact> contactDetails = [SELECT Id, Name 
                                    FROM Contact 
                                    WHERE Id IN :contactIds];

    // Query to get vehicle IDs associated with the branch
    List<CCP2_BranchVehicle_Junction__c> vehicleJunctions = [SELECT VehicleId__c 
                                                             FROM CCP2_BranchVehicle_Junction__c 
                                                             WHERE BranchId__c = :branchId];

    // Set to store unique vehicle IDs
    Set<Id> vehicleIds = new Set<Id>();
    for (CCP2_BranchVehicle_Junction__c junction : vehicleJunctions) {
        vehicleIds.add(junction.VehicleId__c);
    }

    // Query to get vehicle details
    List<VehicleInfo__c> vehicleDetails = [SELECT Id, Name 
                                           FROM VehicleInfo__c 
                                           WHERE Id IN :vehicleIds];

    // Add branch details to the map
    for (CCP2_Branch__c branch : branchDetails) {
        Map<String, Object> branchMap = new Map<String, Object>();
        branchMap.put('Id', branch.Id);
        branchMap.put('Name', branch.Name);
        branchMap.put('Company', branch.Company_Name__c);
        branchMap.put('Tip', branch.Tip_Number__c);
        branchMap.put('BranchNo', branch.Branch_Number__c);
        branchMap.put('ContactNo', branch.Contact_No__c);
        branchMap.put('Mention', branch.Mention_Name__c);
        branchMap.put('Address', branch.Address__c);

        Map<String, Object> accountMap = new Map<String, Object>();
        accountMap.put('siebelAccountCode__c', branch.Account__r.siebelAccountCode__c);
        accountMap.put('Id', branch.Account__c);

        branchMap.put('Account', accountMap);

        detailsMap.put('BranchDetails', branchMap);
    }

    // Add contact details to the map
    List<Map<String, Object>> contactList = new List<Map<String, Object>>();
    for (Contact contact : contactDetails) {
        Map<String, Object> contactMap = new Map<String, Object>();
        contactMap.put('Id', contact.Id);
        contactMap.put('Name', contact.Name);
        contactList.add(contactMap);
    }
    detailsMap.put('Contacts', contactList);

    // Add vehicle details to the map
    List<Map<String, Object>> vehicleList = new List<Map<String, Object>>();
    for (VehicleInfo__c vehicle : vehicleDetails) {
        Map<String, Object> vehicleMap = new Map<String, Object>();
        vehicleMap.put('Id', vehicle.Id);
        vehicleMap.put('Name', vehicle.Name);
        vehicleList.add(vehicleMap);
    }
    detailsMap.put('Vehicles', vehicleList);

    System.debug(detailsMap);
    return detailsMap;
}
      @AuraEnabled(cacheable=true)
    public static List<contact> UserWithoutAssociation()
    {
        //List<CCP2_Branch__c> branch;
        Id ccpUserId = UserInfo.getUserId();
        //Id accId = '001Io000003EtiQIAS';
        List<User> user;
        List<Contact> contacts;
        List<User> ccpUser = [SELECT ContactId FROM User WHERE Id = :ccpUserId];
        System.debug('ccpUser '+ccpUser);
        if(ccpUser[0].ContactId != null)
        {
            contacts = [SELECT Id , Name FROM Contact WHERE Id = :ccpUser[0].ContactId];
            System.debug('contacts '+contacts);System.debug(User);
        }
        return contacts;
    }
    
    @AuraEnabled
    public static void unassociateVehicle(List<Id> vehicles,Id branchId) {
   
        if (vehicles == null || vehicles.isEmpty()) 
        {
            throw new IllegalArgumentException('ChildRecordIds cannot be null or empty');
        }
        else
        {
            /*List<VehicleInfo__c> childRecords = [SELECT Id, CCP2_Branch__c FROM VehicleInfo__c WHERE Id IN :vehicles];
            for (VehicleInfo__c child : childRecords) {
                child.CCP2_Branch__c = null;
            }*/
            List<CCP2_BranchVehicle_Junction__c> childRecords = [SELECT Id, VehicleId__c FROM CCP2_BranchVehicle_Junction__c WHERE VehicleId__c IN :vehicles and BranchId__c =:branchId];
            /*for (CCP2_BranchVehicle_Junction__c child : childRecords) {
                child.VehicleId__c = null;
            }*/
            System.debug(childRecords);
            delete childRecords;
        }
    }
    
     @AuraEnabled
    public static void unassociateUser(List<Id> Contact,Id branchId) {
   
        if (Contact == null || Contact.isEmpty()) 
        {
            throw new IllegalArgumentException('ChildRecordIds cannot be null or empty');
        }
        else
        {
            /*List<CCP2_Branch__c> childRecords = [SELECT Id,Name FROM CCP2_Branch__c WHERE Contact__c IN :Contact];
            for (CCP2_Branch__c child : childRecords) {
                child.Contact__c = null;
            }*/
            List<CCP2_BranchContact_Junction__c> childRecords = [SELECT Id,ContactId__c FROM CCP2_BranchContact_Junction__c WHERE ContactId__c IN :Contact and BranchId__c =:branchId];
            /*for (CCP2_BranchContact_Junction__c child : childRecords) {
                child.ContactId__c = null;
            }*/
            delete childRecords;
        }
    }
    
     @AuraEnabled
    public static void associateUser(List<Id> Contact, Id branch) {
   
        if (Contact == null || Contact.isEmpty()) 
        {
            throw new IllegalArgumentException('User List cannot be null or empty');
        }
        else
        {
            /*List<CCP2_Branch__c> childRecords = [SELECT Id FROM CCP2_Branch__c WHERE Id=:branch];
            for (CCP2_Branch__c child : childRecords) {
                child.Contact__c= Contact[0];
            }
            update childRecords;*/
            List<CCP2_BranchContact_Junction__c> contactsToInsert = new List<CCP2_BranchContact_Junction__c>();

            for (Id contactId : Contact) {
                CCP2_BranchContact_Junction__c contactInsert = new CCP2_BranchContact_Junction__c();
                contactInsert.ContactId__c = contactId;
                contactInsert.BranchId__c = branch;
                contactsToInsert.add(contactInsert);
            }
        
            insert contactsToInsert;
        }
    }
    
     @AuraEnabled
    public static void associateVehicle(List<Id> vehicles, Id branch) {
   
        if (vehicles == null || vehicles.isEmpty()) 
        {
            throw new IllegalArgumentException('ChildRecordIds cannot be null or empty');
        }
        else
        {
            /*List<VehicleInfo__c> childRecords = [SELECT Id, CCP2_Branch__c FROM VehicleInfo__c WHERE Id IN :vehicles];
            for (VehicleInfo__c child : childRecords) 
            {
               
                  child.CCP2_Branch__c = branch;    
                
            }*/
            List<CCP2_BranchVehicle_Junction__c> vehicleToInsert = new List<CCP2_BranchVehicle_Junction__c>();

            for (Id vehicleId : vehicles) {
            CCP2_BranchVehicle_Junction__c vehicleInsert = new CCP2_BranchVehicle_Junction__c();
            vehicleInsert.VehicleId__c = vehicleId;
            vehicleInsert.BranchId__c = branch;
            vehicleToInsert.add(vehicleInsert);
        }
        	 try
                {
            		//database.update(childRecords, true);
            		insert vehicleToInsert;
                }
                catch(DmlException e)
                {
                    throw e;
                    
                }
        }
    }
    
   @AuraEnabled(cacheable=true) 
    public static Id accId(){
        
        Id ccpUserId = UserInfo.getUserId();
        System.debug('ccpUserId '+ccpUserId);
        Id accountId = null;
        List<User> user;
        List<User> ccpUser = [SELECT ContactId FROM User WHERE Id = :ccpUserId];
        System.debug('ccpUser '+ccpUser);
        if(ccpUser[0].ContactId != null)
        {
            List<Contact> contacts = [SELECT AccountId FROM Contact WHERE Id = :ccpUser[0].ContactId];
            System.debug('contacts '+contacts);
            if(contacts[0].AccountId != null)
            {
                accountId = contacts[0].AccountId;
            }
        }
        return accountId;
    
    }
    
    @AuraEnabled
    public static Id associateBranchtoUser(List<Id> Branch, Id ConId)
    {
       	 Id abcd;
         Id accId=accId();
         List<CCP2_Branch__c> branchs= [select id, name, Branch_Number__c from CCP2_Branch__c where Id=:Branch];
         for (CCP2_Branch__c br : branchs) 
         {
          	br.Contact__c= ConId;
         }
         List<Contact> contacts = [SELECT AccountId FROM Contact WHERE Id =: ConId];
         Update branchs;
     return abcd;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> BranchVehicleCount() {
    //Id accId = '001Io000003ITP2IAO';  
	Id accId=accId();
    List<CCP2_Branch__c> branches = [SELECT Id, Account__c, Branch_Number__c FROM CCP2_Branch__c WHERE Account__c = :accId];

    Set<Id> branchIds = new Set<Id>();
    for (CCP2_Branch__c branch : branches) {
        branchIds.add(branch.Id);
    }

    List<AggregateResult> vehicleCounts = [SELECT CCP2_Branch__c,CCP2_Branch__r.Name, COUNT(Id) vehicleCount FROM VehicleInfo__c WHERE CCP2_Branch__c IN :branchIds GROUP BY CCP2_Branch__c,CCP2_Branch__r.Name];

    /* Map<Id, Integer> branchVehicleCountMap = new Map<Id, Integer>();
    for (AggregateResult ar : vehicleCounts) {
        branchVehicleCountMap.put((Id) ar.get('CCP2_Branch__c'), (Integer) ar.get('vehicleCount'));
    }

    List<String> debugInfo = new List<String>();
    for (CCP2_Branch__c branch : branches) {
        Integer vehicleCount = branchVehicleCountMap.containsKey(branch.Id) ? branchVehicleCountMap.get(branch.Id) : 0;
        String debugMessage = 'BranchId: ' + branch.name + ',BranchNumber: ' + branch.Branch_Number__c + ', Vehicle Count: ' + vehicleCount;
        debugInfo.add(debugMessage);
        System.debug(debugMessage);
    }*/
    
    //System.debug(debugInfo);
    //return debugInfo;
     
    System.debug(vehicleCounts);
    return vehicleCounts;
}

}