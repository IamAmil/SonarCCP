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
//getVehicleInfo
//registeredVehicleList
//getVehicleById
public with sharing class CCP2_userData {
    @AuraEnabled(cacheable=true)
    public static List<Contact> userList()
    {
         Id accId=accId();
        List<Contact> user;
            if(accId!=null)
            {
                 user=[select Id, Name,UserId__c, Account.siebelAccountCode__c from Contact where accountId=:accId and canManageMember__c = false and ccpUseFlag__c= true];
                
            }
        
        System.debug('user ' +user);
        return user;
    }
 @AuraEnabled(cacheable=true)
public static List<Map<String, Object>> userListwithbranch() {
    Id accId = accId();
    System.debug(accId);

    List<Map<String, Object>> combinedData = new List<Map<String, Object>>();
    
    // Check if accId is not null
    if (accId == null) {
        return combinedData;
    }  
    // Query to get the contact details
    List<Contact> contactDetails = [
        SELECT Id, Name, UserId__c, Account.siebelAccountCode__c 
        FROM Contact 
        WHERE AccountId = :accId 
          AND canManageMember__c = false 
          AND ccpUseFlag__c = true
    ];
    System.debug(contactDetails);

    if (contactDetails.isEmpty()) {
        return combinedData;
    }

    // Collect Contact IDs
    Set<Id> contactIds = new Set<Id>();
    for (Contact contact : contactDetails) {
        contactIds.add(contact.Id);
    }

    // Query to get the branch contact junctions
    List<CCP2_BranchContact_Junction__c> branchContactJunctions = [
        SELECT ContactId__c, BranchId__c 
        FROM CCP2_BranchContact_Junction__c 
        WHERE ContactId__c IN :contactIds
    ];
    System.debug(branchContactJunctions);

    // Collect Branch IDs
    Set<Id> branchIds = new Set<Id>();
    for (CCP2_BranchContact_Junction__c bcj : branchContactJunctions) {
        branchIds.add(bcj.BranchId__c);
    }

    // Query to get the branch details
    List<CCP2_Branch__c> branchDetails = [
        SELECT Id, Name 
        FROM CCP2_Branch__c 
        WHERE Id IN :branchIds
    ];
    System.debug(branchDetails);

    // Map to hold Branch Id to Branch details
    Map<Id, CCP2_Branch__c> branchMap = new Map<Id, CCP2_Branch__c>();
    for (CCP2_Branch__c branch : branchDetails) {
        branchMap.put(branch.Id, branch);
    }

    // Combine contact and branch data
    for (Contact contact : contactDetails) {
        Map<String, Object> contactData = new Map<String, Object>();
        contactData.put('contact', contact);

        List<CCP2_Branch__c> associatedBranches = new List<CCP2_Branch__c>();
        for (CCP2_BranchContact_Junction__c bcj : branchContactJunctions) {
            if (bcj.ContactId__c == contact.Id) {
                if (branchMap.containsKey(bcj.BranchId__c)) {
                    associatedBranches.add(branchMap.get(bcj.BranchId__c));
                }
            }
        }

        contactData.put('branches', associatedBranches);
        combinedData.add(contactData);
    }
    System.debug(combinedData);

    return combinedData;
} 
    @AuraEnabled(cacheable=true)
    public static List<Contact> userListDtl(Id branchId)
    {
         Id accId=accId();
        List<Contact> user;
        if (accId != null) {
        user = [SELECT Id, Name FROM Contact WHERE accountId = :accId and ccpUseFlag__c= true AND canManageMember__c = false AND Id NOT IN (SELECT ContactId__c FROM CCP2_BranchContact_Junction__c WHERE BranchId__c = :branchId)];

        }
        System.debug('user ' +user);
        return user;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Contact> userDtl(Id User,Integer refresh)
    {
        //if(refresh){
            Id accId=accId();
        	List<Contact> userData;
            if(accId!=null)
            {
                 userData=[select Name , id ,Employee_Code__c,Title,firstNameKana__c,lastNameKana__c,Department,Email,Phone , account.id, account.name, account.siebelAccountCode__c, account.Industry, MobilePhone from Contact where accountId=:accId AND Id=:User];
            }
               
        return userData;
    }
       @AuraEnabled(cacheable=true)
    public static List<CCP2_Branch__c> userBranchDtl(Id User,Integer refresh) {
       // if(refresh){
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

    @AuraEnabled(cacheable=true)
    public static List<CCP2_Branch__c> BranchList()
    {
        //List<CCP2_Branch__c> branch;
        Id accId=accId();
        List<AggregateResult> veh;
        List<CCP2_Branch__c> branch= [select id,Account__c, name, Branch_Code__c from CCP2_Branch__c where Account__c=:accId];
    	Integer i=0;
        System.debug(branch);
        return branch;
    }
    
     @AuraEnabled(cacheable=true)
    public static List<CCP2_Branch__c> UnAssociatedBranch(Id contactId)
    {
        //List<CCP2_Branch__c> branch;
        Id accId=accId();
        List<CCP2_Branch__c> branch = [SELECT Id, Name FROM ccp2_Branch__c WHERE account__c =: accId AND Id NOT IN 
 (SELECT BranchId__c FROM CCP2_BranchContact_Junction__c WHERE ContactId__c =:contactId)];
        System.debug(branch);
        return branch;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<ccp2_Registered_Vehicle__c> VehicleWithoutAssociation()
    {
        //List<CCP2_Branch__c> branch;
        Id accId=accId();
        //Id accId = '001Io000003ITP2IAO';
        List<ccp2_Registered_Vehicle__c	> vehicle= [select id, Name from ccp2_Registered_Vehicle__c where Account__c=:accId ];
        System.debug(vehicle);
        return vehicle;
    }
    
     @AuraEnabled(cacheable=true)
    public static List<ccp2_Registered_Vehicle__c> VehicleWithoutAssociationDtl(Id branchId)
    {
        //List<CCP2_Branch__c> branch;
        Id accId=accId();
        List<ccp2_Registered_Vehicle__c> vehicle= [SELECT Id, Name FROM ccp2_Registered_Vehicle__c WHERE Account__c = :accId 
                                                   AND Id NOT IN (SELECT VehicleId__c FROM CCP2_BranchVehicle_Junction__c WHERE BranchId__c = :branchId)
                                                   ];
        System.debug(vehicle);
        return vehicle;
    }
    
@AuraEnabled(cacheable=true)
public static Map<String, Object> NewBranchDetails(Id branchId) {
    Id accId = accId();
    System.debug('branchId:' + branchId);
    System.debug('accId:' + accId);

    // Map to store the combined details
    Map<String, Object> detailsMap = new Map<String, Object>();

    // Query to get branch details
    List<CCP2_Branch__c> branchDetails = [SELECT Id, Name, Company_Name__c, Tip_Number__c, Branch_Code__c, Contact_No__c, Mention_Name__c, Address__c,Postal_Code__c,Prefecture__c,Minicipalities__c,Street_Address__c,Building_Name_Company_name__c, Account__c, Account__r.siebelAccountCode__c 
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
    List<CCP2_BranchVehicle_Junction__c> vehicleJunctions = [SELECT VehicleId__c FROM CCP2_BranchVehicle_Junction__c WHERE BranchId__c = :branchId];

    // Set to store unique vehicle IDs
    Set<Id> vehicleIds = new Set<Id>();
    for (CCP2_BranchVehicle_Junction__c junction : vehicleJunctions) {
        vehicleIds.add(junction.VehicleId__c);
    }

    // Query to get vehicle details
    List<ccp2_Registered_Vehicle__c> vehicleDetails = [SELECT Id, Name 
                                           FROM ccp2_Registered_Vehicle__c 
                                           WHERE Id IN :vehicleIds];

    // Add branch details to the map
    for (CCP2_Branch__c branch : branchDetails) {
        Map<String, Object> branchMap = new Map<String, Object>();
        branchMap.put('Id', branch.Id);
        branchMap.put('Name', branch.Name);
        branchMap.put('Company', branch.Company_Name__c);
        branchMap.put('Tip', branch.Tip_Number__c);
        branchMap.put('BranchNo', branch.Branch_Code__c);
        branchMap.put('ContactNo', branch.Contact_No__c);
        branchMap.put('Mention', branch.Mention_Name__c);
        branchMap.put('Address', branch.Address__c);
        branchMap.put('PostalCode', branch.Postal_Code__c);
        branchMap.put('Prefecture', branch.Prefecture__c);
        branchMap.put('municipalities', branch.Minicipalities__c);
        branchMap.put('streetAddress', branch.Street_Address__c);
        branchMap.put('BuldingName', branch.Building_Name_Company_name__c);

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
    for (ccp2_Registered_Vehicle__c vehicle : vehicleDetails) {
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
            List<CCP2_BranchVehicle_Junction__c> childRecords = [SELECT Id, VehicleId__c,BranchId__c FROM CCP2_BranchVehicle_Junction__c WHERE VehicleId__c IN :vehicles and BranchId__c =:branchId];
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
            List<CCP2_BranchContact_Junction__c> childRecords = [SELECT Id,ContactId__c FROM CCP2_BranchContact_Junction__c WHERE ContactId__c IN :Contact and BranchId__c =:branchId];
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
            List<CCP2_BranchVehicle_Junction__c> vehicleToInsert = new List<CCP2_BranchVehicle_Junction__c>();

            for (Id vehicleId : vehicles) {
            CCP2_BranchVehicle_Junction__c vehicleInsert = new CCP2_BranchVehicle_Junction__c();
            vehicleInsert.VehicleId__c = vehicleId;
            vehicleInsert.BranchId__c = branch;
            vehicleToInsert.add(vehicleInsert);
        }
        	 try
                {
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
         List<CCP2_Branch__c> branchs= [select id, name, Branch_Code__c from CCP2_Branch__c where Id=:Branch];
         for (CCP2_Branch__c br : branchs) 
         {
          	br.Contact__c= ConId;
         }
         List<Contact> contacts = [SELECT AccountId FROM Contact WHERE Id =: ConId];
         Update branchs;
     return abcd;
    }
    
    @AuraEnabled(cacheable=true)
	public static List<Map<String, Object>> accountDetails() {
    Id accId = accId();  
    
    List<Account> currentUserAccount = [SELECT Id, Name, Current_Branch_Code__c,siebelAccountCode__c FROM Account WHERE Id = :accId];

    List<Map<String, Object>> modifiedAccounts = new List<Map<String, Object>>();
    
    // Iterate through the queried accounts
    for (Account acc : currentUserAccount) {
        // Calculate the incremented branch count
        //Decimal incrementedBranchCount = (acc.Branch_Count__c != null) ? acc.Branch_Count__c + 1 : 1;
        
        Map<String, Object> accMap = new Map<String, Object>();
        accMap.put('Id', acc.Id);
        accMap.put('Name', acc.Name);
        accMap.put('siebelAccountCode__c', acc.siebelAccountCode__c);
        accMap.put('Current_Branch_Code__c', acc.Current_Branch_Code__c);
        
        // Add the map to the list
        modifiedAccounts.add(accMap);
    }   
    System.debug(modifiedAccounts); 
    return modifiedAccounts;
}
    
    @AuraEnabled(cacheable=true)
    public static List<CCP2_BranchContact_Junction__c> userbranchList() {
        Id accId=accId();
        List<CCP2_BranchContact_Junction__c> contactBranchDetail = new List<CCP2_BranchContact_Junction__c>();

        try {
            if (accId != null) {
                List<Contact> contactIds = [SELECT Id 
                                            FROM Contact 
                                            WHERE AccountId = :accId 
                                              AND canManageMember__c = false 
                                              AND ccpUseFlag__c = true];

                for (Contact contact : contactIds) {
                    List<CCP2_BranchContact_Junction__c> branchDetails = [SELECT ContactId__c, 
                                                                               ContactId__r.Name, 
                                                                               ContactId__r.UserId__c, 
                                                                               ContactId__r.Account.siebelAccountCode__c, 
                                                                               BranchId__c, 
                                                                               BranchId__r.Name 
                                                                        FROM CCP2_BranchContact_Junction__c 
                                                                        WHERE ContactId__c = :contact.Id];
                    contactBranchDetail.addAll(branchDetails);
                }

                System.debug(contactBranchDetail);
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }

        System.debug('user ' + contactBranchDetail);
        return contactBranchDetail;
    }
   
    @AuraEnabled
	public static List<VehicleInfo__c> getVehicleInfo(List<String> CarModel, List<String> brandModel) {
    try {
        Id accountId = accId();
        Boolean adminFlag = false; // Default value in case no records are found
        List<Contact> contacts = [SELECT canManageMember__c FROM Contact WHERE AccountId = :accountId LIMIT 1];
		
        if (!contacts.isEmpty()) {
            adminFlag = contacts[0].canManageMember__c;
        }
        System.debug(adminFlag);
        System.debug(contacts);
        System.debug(accountId);

        ID vehicleRecordTypeId = Schema.SObjectType.VehicleInfo__c.getRecordTypeInfosByDeveloperName().get('vehicle').getRecordTypeId();
        ID customerRegisteredRecordTypeId = Schema.SObjectType.VehicleInfo__c.getRecordTypeInfosByDeveloperName().get('CustomerRegisteredVehicle').getRecordTypeId();
        
        String queryString = 'SELECT Id, Name, VehiclebrandName__c, Customer_Name__c, Mileage__c, lastArrivalDateTime__c, vehicleInspectionExpiryDate__c, TruckImg__c, carModelFormatName__c, newCarFlag__c, vehicleManagementNumber__c, ' +
                             'carPlatformNo__c, RecordType.Name, initialRegistrationDate__c, brand__c ' +
                             'FROM VehicleInfo__c ' +
                             'WHERE (RecordTypeId = :vehicleRecordTypeId OR RecordTypeId = :customerRegisteredRecordTypeId) ';
                             
        if (adminFlag) {
            queryString += 'AND userAccountCode__c = :accountId ';
        }
        
        if (!CarModel.isEmpty() || !brandModel.isEmpty()) {
            queryString += 'AND (';
            
            if (!CarModel.isEmpty()) {
                queryString += 'carModelFormatName__c IN :CarModel ';
            }
            
            if (!CarModel.isEmpty() && !brandModel.isEmpty()) {
                queryString += 'AND ';
            }
            
            if (!brandModel.isEmpty()) {
                queryString += 'brand__c IN :brandModel ';
            }
            
            queryString += ') ';
        }
                       
        List<VehicleInfo__c> vehicleInfoList = Database.query(queryString);
        System.debug(vehicleInfoList);
        return vehicleInfoList;
    } catch (Exception e) {
        CCP2_HandlerForException.LogException(e);
        throw new AuraHandledException('An error occurred while fetching vehicle info: ' + e.getMessage());
    }
	}
    
    @AuraEnabled(cacheable=true)
    public static List<ccp2_Registered_Vehicle__c> getVehicleById(String vehicleId) {
        List<ccp2_Registered_Vehicle__c> newList = new List<ccp2_Registered_Vehicle__c>();
        try {
            newList = [SELECT Id, Name, Body_Shape__c,Capacity__c,Vehicle_Name__c, Vehicle_Type__c,Chassis_number__c,Delivery_Date__c,
                       Displacement__c,First_Registration_Date__c,Fuel_Type__c,fullModel__c,Model_Prime_Mover__c,Payload__c,
                       Private_Business_use__c,Registration_Number__c,Use__c,Vehicle_Expiration_Date__c,Work_Location__c,vehicleWeight__c
                       FROM ccp2_Registered_Vehicle__c WHERE Id = :vehicleId];
        } catch (Exception e) {
            CCP2_HandlerForException.LogException(e);
            System.debug('An error occurred while fetching vehicle details: ' + e.getMessage());
        }
        return newList;
    }
    @AuraEnabled(cacheable=true)
    public static List<ccp2_Registered_Vehicle__c> registeredVehicleList(){
        Id accountId = accId();
        List<ccp2_Registered_Vehicle__c> vehicleList = new List<ccp2_Registered_Vehicle__c>();
        try {
            vehicleList = [SELECT Id, Name, Body_Shape__c,Capacity__c,Vehicle_Name__c, Vehicle_Type__c,Chassis_number__c,Delivery_Date__c,
                       Displacement__c,First_Registration_Date__c,Fuel_Type__c,fullModel__c,Model_Prime_Mover__c,Payload__c,
                       Private_Business_use__c,Registration_Number__c,Use__c,Vehicle_Expiration_Date__c,Work_Location__c,vehicleWeight__c
                       FROM ccp2_Registered_Vehicle__c WHERE Account__c = :accountId];
        } catch (Exception e) {
            CCP2_HandlerForException.LogException(e);
            System.debug('An error occurred while fetching vehicle details: ' + e.getMessage());
        }
        System.debug(vehicleList);
        return vehicleList; 
    }
}