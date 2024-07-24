//getAccountId
//allVehicleList
//vehicleByChassis
//vehicleNotRegistered
//branchList
//insertRegisteredVehicles
//branchExceptMine
//getContactByBranch
//getVehicleByBranch
//insertBranchVehicleJunctions
//insertBranchContactJunctions
//vehicleinput
public with sharing class CCP2_VehicleManagment {
    @AuraEnabled
     public static Id getAccountId(){
        Id returnValue = null;
        User portalUser = [SELECT ContactId, Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        if (portalUser != null && portalUser.ContactId != null) {
            returnValue = portalUser.Contact.AccountId;
        }
        return returnValue;
    }
    
    @AuraEnabled(cacheable=true)
    Public static List<SObject> allVehicleList(){
        //List<String> vehicleData = new List<String>();
        //Id accId='001Io000003ITP2IAO';
        Id accId = getAccountId();
        List<Account> accountHQLBC = [Select id,Name,lbc_head_office_id__c from Account where Id =:accId];
        String headOfficeId = accountHQLBC[0].lbc_head_office_id__c;
        List<Account> accountList = [Select Id,name from Account where lbc_head_office_id__c =:headOfficeId];
        Set<Id> accIds = new Set<Id>();
        for(Account accountId :accountList ){
            accIds.add(accountId.Id);
        }
        /*List<VehicleInfo__c> vehicleDetails = [Select Id, Name,carPlatformNo__c,registrationNumberSequence__c from VehicleInfo__c where userAccountCode__c IN :accIds];
        System.debug(vehicleDetails);
        vehicleData.add(vehicleDetails);
        List<ccp2_Registered_Vehicle__c> vehicleRegistered = [Select Id, Name,Chassis_number__c,Registration_Number__c from ccp2_Registered_Vehicle__c where Account__c IN :accIds]; 
		System.debug(vehicleRegistered);        
        vehicleData.add(vehicleRegistered);*/
        List<VehicleInfo__c> vehicleDetails = [SELECT Id, Name, carPlatformNo__c, registrationNumberSequence__c FROM VehicleInfo__c WHERE userAccountCode__c IN :accIds];
    	List<ccp2_Registered_Vehicle__c> vehicleRegistered = [SELECT Id, Name, Chassis_number__c, Registration_Number__c FROM ccp2_Registered_Vehicle__c WHERE Account__c IN :accIds];

    	// Combine both lists into a single list of type SObject
    	List<SObject> allVehicles = new List<SObject>();
        allVehicles.addAll(vehicleRegistered);
    	allVehicles.addAll(vehicleDetails);
        System.debug(allVehicles);
    	// Return the combined list
    	return allVehicles;    
    }
    
    @AuraEnabled
    public static Map<String, List<Map<String, Object>>> vehicleByChassis(List<String> chassisNumbers) {
    Map<String, List<Map<String, Object>>> resultMap = new Map<String, List<Map<String, Object>>>();
    resultMap.put('Registered Vehicle', new List<Map<String, Object>>());
    resultMap.put('Vehicle Info', new List<Map<String, Object>>());

    try {
        if (chassisNumbers.isEmpty()) {
            return resultMap;
        }

        // Query RegisteredVehicle on ccp2_Registered_Vehicle__c
        List<ccp2_Registered_Vehicle__c> registeredVehicles = [SELECT Chassis_number__c FROM ccp2_Registered_Vehicle__c 
                                                               WHERE Chassis_number__c IN :chassisNumbers];
        
        for (ccp2_Registered_Vehicle__c rv : registeredVehicles) {
            resultMap.get('Registered Vehicle').add(convertSObjectToMap(rv));
        }

        Set<String> foundChassisNumbers = new Set<String>();
        for (ccp2_Registered_Vehicle__c rv : registeredVehicles) {
            foundChassisNumbers.add(rv.Chassis_number__c);
        }

        List<String> remainingChassisNumbers = new List<String>();
        for (String chassis : chassisNumbers) {
            if (!foundChassisNumbers.contains(chassis)) {
                remainingChassisNumbers.add(chassis);
            }
        }

        // Any chassis numbers left, query vehicleInfo__c
        if (!remainingChassisNumbers.isEmpty()) {
            List<vehicleInfo__c> vehicleInfos = [SELECT carPlatformNo__c FROM vehicleInfo__c
                                                 WHERE carPlatformNo__c IN :remainingChassisNumbers];
            
            for (vehicleInfo__c vi : vehicleInfos) {
                resultMap.get('Vehicle Info').add(convertSObjectToMap(vi));
            }
        }

        System.debug(resultMap);
    } 	catch (Exception e) {
        CCP2_HandlerForException.LogException(e);
        System.debug('An error occurred: ' + e.getMessage());
    }
    return resultMap;
	}
    
   @AuraEnabled(cacheable=true)
    public static Map<String, List<Map<String, Object>>> vehicleNotRegistered(List<String> chassisNumbers) {
    Map<String, List<Map<String, Object>>> resultMap = new Map<String, List<Map<String, Object>>>();
    resultMap.put('VehicleInfo', new List<Map<String, Object>>());

    try {
        if (chassisNumbers.isEmpty()) {
            return resultMap;
        }

        // Query Vehicle Not Registered 
        List<vehicleInfo__c> vehicleInfo = [SELECT Id, Name, type__c, carPlatformNo__c, registrationNumberSequence__c, initialRegistrationDate__c,
                                            expiringDateofEffectivePeriod__c, vehicleBrandName__c, bodyShape__c, selfEmployedCategory__c,
                                            fullModel__c, vehicleWeight__c, Payload__c, mileage__c
                                            FROM vehicleInfo__c 
                                            WHERE carPlatformNo__c IN :chassisNumbers];
        
        for (vehicleInfo__c uv : vehicleInfo) {
            resultMap.get('VehicleInfo').add(convertSObjectToMap(uv));
        }
        System.debug(resultMap);
    } catch (Exception e) {
        CCP2_HandlerForException.LogException(e);
        System.debug('An error occurred: ' + e.getMessage());
    }
    
    return resultMap;
	}
    
    @AuraEnabled(cacheable=true)
    public static List<CCP2_Branch__c> branchList(){
        //Id accId = '001Io000003ITP2IAO';
        Id accId = getAccountId();
		List<CCP2_Branch__c> branches = [Select Id,Name from CCP2_Branch__c where Account__c = :accId];
        System.debug(branches);
        return branches;
    }   
    
    @AuraEnabled
	public static Map<String, Object> convertSObjectToMap(SObject record) {
    Map<String, Object> recordMap = new Map<String, Object>();
    for (String fieldName : record.getPopulatedFieldsAsMap().keySet()) {
        recordMap.put(fieldName, record.get(fieldName));
    }
    return recordMap;
	}
    
  	@AuraEnabled
    public static void insertRegisteredVehicles(String jsonInput,String contentVersionIdsJson) {
    System.debug(jsonInput);

    // Define a wrapper class to represent the structure of your JSON
    List<VehicleInputWrapper> vehicleDataList = (List<VehicleInputWrapper>) JSON.deserialize(jsonInput, List<VehicleInputWrapper>.class);
    System.debug(vehicleDataList);

    List<ccp2_Registered_Vehicle__c> vehicleList = new List<ccp2_Registered_Vehicle__c>();
    
    //Map<String,List<Id>> vehicleBranchMap = new Map<String,List<Id>>();
      List<Id> branchIds = new List<Id>();
    try {
        for (VehicleInputWrapper vehicleData : vehicleDataList) {
            ccp2_Registered_Vehicle__c vehicle = new ccp2_Registered_Vehicle__c();
            vehicle.Account__c = getAccountId();
            //vehicle.Account__c = '001Io000003ITP2IAO';
            // Extracting affiliation ids
            if (vehicleData.affiliation != null) {
                for (String branchId : vehicleData.affiliation) {
                    branchIds.add(Id.valueOf(branchId));
                }
            }
			String carPlatformNo = vehicleData.carPlatformNoPart1 + '-' + vehicleData.carPlatformNoPart2;
            String loginNumber = vehicleData.loginNumberPart1 + '-' + vehicleData.loginNumberPart2 + '-' + vehicleData.loginNumberPart3 + '-' + vehicleData.loginNumberPart4;
            String model = vehicleData.model1 + '-' + vehicleData.model2;
            // Assigning values to vehicle fields
            vehicle.Body_Shape__c = vehicleData.bodyShape;
            vehicle.Delivery_Date__c = Date.valueOf(vehicleData.dateOfIssuance);
            vehicle.Registration_Number__c = loginNumber;
            vehicle.Vehicle_Name__c = vehicleData.carName;
            vehicle.Chassis_number__c = carPlatformNo;
            vehicle.First_Registration_Date__c = Date.valueOf(vehicleData.initialRegistrationDate);
            vehicle.fullModel__c = model;
            vehicle.Vehicle_Number__c = vehicleData.vehicleNumber;
            //vehicle.Registration_Number__c = vehicleData.registrationNumberSequence;
            //vehicle.Vehicle_Expiration_Date__c = Date.valueOf(vehicleData.expirationDate);
            vehicle.Vehicle_Expiration_Date__c = vehicleData.expirationDate;
            vehicle.vehicleWeight__c = vehicleData.curbWeight;
            vehicle.Private_Business_use__c = vehicleData.privateOrBusinessUse;
            vehicle.Use__c = vehicleData.use;
            vehicle.Mileage__c = Integer.Valueof(vehicleData.mileage);
            vehicle.Vehicle_Type__c = vehicleData.typeOfVehicle;
            vehicle.Door_Number__c = vehicleData.doorNumber;
            vehicle.Work_Location__c = vehicleData.worklocation;
            vehicle.Fuel_Type__c = vehicleData.fuelType;

            // Add the vehicle to the list
            vehicleList.add(vehicle);
            
        }

        // Insert the list of registered vehicles
        insert vehicleList;
        String vehicleId = vehicleList[0].Id;
        System.debug(vehicleId);
        
        
        // Create junction objects between vehicles and branches
        List<CCP2_BranchVehicle_Junction__c> vehicleToInsert = new List<CCP2_BranchVehicle_Junction__c>();
        for (Id branchId : branchIds) {
            for (ccp2_Registered_Vehicle__c vehicle : vehicleList) {
                CCP2_BranchVehicle_Junction__c vehicleInsert = new CCP2_BranchVehicle_Junction__c();
                vehicleInsert.VehicleId__c = vehicle.Id;
                vehicleInsert.BranchId__c = branchId;
                vehicleToInsert.add(vehicleInsert);
            }
        }
        insert vehicleToInsert;
        //CCP2_vehcileImageUploader.uploadImage(jsonStrings,vehicleId);
        CCP2_vehcileImageUploader.updateFirstPublishLocationId(contentVersionIdsJson,vehicleId);
    } catch (Exception e) {
        // Handle any exceptions
        System.debug('Error inserting Registered Vehicles: ' + e.getMessage());
        CCP2_HandlerForException.LogException(e);
    }
}
    
    @AuraEnabled(cacheable=true)
    public static List<CCP2_Branch__c> branchExceptMine(Id branchId) {
    	List<CCP2_Branch__c> branches = new List<CCP2_Branch__c>();
        Id accId = getAccountId();
    	try {
        	if (branchId != null) {
            	branches = [SELECT Id, Name FROM CCP2_Branch__c WHERE Id != :branchId And Account__c = :accId];
        	} else {
            	return branches;
        	}
    	} catch (Exception e) {
            CCP2_HandlerForException.LogException(e);
        	System.debug('Exception: ' + e.getMessage()); 
    	}

    	System.debug(branches);
    	return branches;
	}
    
    @AuraEnabled(cacheable=true)
	public static List<Contact> getContactByBranch(Id branchId) {
    	List<Contact> conList = new List<Contact>();
    	try {
        	List<CCP2_BranchContact_Junction__c> contacts = [Select Id, ContactId__C from CCP2_BranchContact_Junction__c 
                                                         where BranchId__c = :branchId];
        
        	Set<Id> contactIds = new Set<Id>();
        	for (CCP2_BranchContact_Junction__c con : contacts) {
            	contactIds.add(con.ContactId__c);
        	}

        	conList = [Select Id, Name from Contact where Id = :contactIds];
        	System.debug(conList);

    	} catch (Exception e) {
        	CCP2_HandlerForException.LogException(e);
        	System.debug('Error fetching contacts: ' + e.getMessage());
    	}
        return conList;
	}
    
    @AuraEnabled(cacheable=true)
	public static List<ccp2_Registered_Vehicle__c> getVehicleByBranch(Id branchId) {
    	List<ccp2_Registered_Vehicle__c> vehList = new List<ccp2_Registered_Vehicle__c>();
    	try {
        	List<CCP2_BranchVehicle_Junction__c> vehicles = [Select Id, VehicleId__C from CCP2_BranchVehicle_Junction__c 
                                                         where BranchId__c = :branchId];

        Set<Id> vehicleIds = new Set<Id>();
        for (CCP2_BranchVehicle_Junction__c veh : vehicles) {
            vehicleIds.add(veh.VehicleId__c);
        	}

        vehList = [Select Id, Name from ccp2_Registered_Vehicle__c where Id = :vehicleIds];
        System.debug(vehList);

    	} catch (Exception e) {
            CCP2_HandlerForException.LogException(e);
        	System.debug('Error fetching vehicles: ' + e.getMessage());
    	}
    	return vehList;
	}
    
   
    
    
    public class BranchVehicleWrapper {
        public String branch;
        public List<String> vehicles;
    }
    
    /*@AuraEnabled
    public static void insertBranchVehicleJunctions(String jsonBranchVehicle) {
        List<CCP2_BranchVehicle_Junction__c> junctionsToInsert = new List<CCP2_BranchVehicle_Junction__c>();
        
        try {
            List<BranchVehicleWrapper> branchVehicleList = (List<BranchVehicleWrapper>) JSON.deserialize(jsonBranchVehicle, List<BranchVehicleWrapper>.class);
            
            for (BranchVehicleWrapper branchVehicle : branchVehicleList) {
                String branchId = branchVehicle.branch;
                List<String> vehicleIds = branchVehicle.vehicles;
                
                for (String vehicleId : vehicleIds) {
                    CCP2_BranchVehicle_Junction__c junction = new CCP2_BranchVehicle_Junction__c();
                    junction.BranchId__c = branchId;
                    junction.VehicleId__c = vehicleId;
                    
                    junctionsToInsert.add(junction);
                }
            }
            
            if (!junctionsToInsert.isEmpty()) {
                insert junctionsToInsert;
            }
        } catch (DmlException e) {
            CCP2_HandlerForException.LogException(e);
            System.debug('Error inserting Branch Vehicle Junctions: ' + e.getMessage());
        } 
    }*/
    
    @AuraEnabled
	public static void insertBranchVehicleJunctions(String jsonBranchVehicle) {
    	List<CCP2_BranchVehicle_Junction__c> junctionsToInsert = new List<CCP2_BranchVehicle_Junction__c>();
    
    	try {
        	List<BranchVehicleWrapper> branchVehicleList = (List<BranchVehicleWrapper>) JSON.deserialize(jsonBranchVehicle, List<BranchVehicleWrapper>.class);
        
        	for (BranchVehicleWrapper branchVehicle : branchVehicleList) {
            	String branchId = branchVehicle.branch;
            	List<String> vehicleIds = branchVehicle.vehicles;
            
                // Retrieve existing vehicle IDs for the branch
            	Map<Id, CCP2_BranchVehicle_Junction__c> existingJunctionMap = new Map<Id, CCP2_BranchVehicle_Junction__c>(
                	[SELECT VehicleId__c FROM CCP2_BranchVehicle_Junction__c WHERE BranchId__c = :branchId]);
            	Set<String> existingVehicleIds = new Set<String>();
            	for (CCP2_BranchVehicle_Junction__c junction : existingJunctionMap.values()) {
                	existingVehicleIds.add(junction.VehicleId__c);
            	}
            
            	for (String vehicleId : vehicleIds) {
                	if (!existingVehicleIds.contains(vehicleId)) {
                    	CCP2_BranchVehicle_Junction__c junction = new CCP2_BranchVehicle_Junction__c();
                    	junction.BranchId__c = branchId;
                    	junction.VehicleId__c = vehicleId;
                    	junctionsToInsert.add(junction);
                	}
            	}
        	}
        
        	if (!junctionsToInsert.isEmpty()) {
            	insert junctionsToInsert;
        	}
    	} catch (DmlException e) {
        	CCP2_HandlerForException.LogException(e);
        	System.debug('Error inserting Branch Vehicle Junctions: ' + e.getMessage());
    	}
	}
    
    
    public class BranchContactWrapper {
        public String branch;
        public List<String> users;
    }
    
    /*@AuraEnabled
    public static void insertBranchContactJunctions(String jsonBranchContact) {
        List<CCP2_BranchContact_Junction__c> junctionsToInsert = new List<CCP2_BranchContact_Junction__c>();
        
        try {
            List<BranchContactWrapper> branchContactList = (List<BranchContactWrapper>) JSON.deserialize(jsonBranchContact, List<BranchContactWrapper>.class);
            
            for (BranchContactWrapper branchContact : branchContactList) {
                String branchId = branchContact.branch;
                List<String> contactIds = branchContact.users;
                
                for (String contactId : contactIds) {
                    CCP2_BranchContact_Junction__c junction = new CCP2_BranchContact_Junction__c();
                    junction.BranchId__c = branchId;
                    junction.ContactId__c = contactId															;
                    
                    junctionsToInsert.add(junction);
                }
            }
            
            if (!junctionsToInsert.isEmpty()) {
                insert junctionsToInsert;
            }
        } catch (DmlException e) {
            CCP2_HandlerForException.LogException(e);
            System.debug('Error inserting Branch Vehicle Junctions: ' + e.getMessage());
        } 
    }*/
    
    @AuraEnabled
	public static void insertBranchContactJunctions(String jsonBranchContact) {
    	List<CCP2_BranchContact_Junction__c> junctionsToInsert = new List<CCP2_BranchContact_Junction__c>();
    
    	try {
        	List<BranchContactWrapper> branchContactList = (List<BranchContactWrapper>) JSON.deserialize(jsonBranchContact, List<BranchContactWrapper>.class);
        
        	for (BranchContactWrapper branchContact : branchContactList) {
            	String branchId = branchContact.branch;
            	List<String> contactIds = branchContact.users;
            
            // Retrieve existing contact IDs for the branch
            	Map<Id, CCP2_BranchContact_Junction__c> existingJunctionMap = new Map<Id, CCP2_BranchContact_Junction__c>(
                	[SELECT ContactId__c FROM CCP2_BranchContact_Junction__c WHERE BranchId__c = :branchId]);
            	Set<String> existingContactIds = new Set<String>();
            	for (CCP2_BranchContact_Junction__c junction : existingJunctionMap.values()) {
                	existingContactIds.add(junction.ContactId__c);
            	}
            
            	for (String contactId : contactIds) {
                	if (!existingContactIds.contains(contactId)) {
                    	CCP2_BranchContact_Junction__c junction = new CCP2_BranchContact_Junction__c();
                    	junction.BranchId__c = branchId;
                    	junction.ContactId__c = contactId;
                    	junctionsToInsert.add(junction);
                	}
            	}
        	}
        
        	if (!junctionsToInsert.isEmpty()) {
            	insert junctionsToInsert;
        	}
    	} catch (DmlException e) {
        	CCP2_HandlerForException.LogException(e);
        	System.debug('Error inserting Branch Contact Junctions: ' + e.getMessage());
    	}
	}
    
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> vehicleinput(String carPlatformNumber) {
        // Query the vehicle details
        String chassisNumberReq = carPlatformNumber.trim();
        List<ccp2_Registered_Vehicle__c> vehicleDetailsData = [
            SELECT Id, Body_Shape__c, Delivery_Date__c, Registration_Number__c, Vehicle_Name__c, Chassis_number__c,
                   First_Registration_Date__c, fullModel__c, Name,Vehicle_Expiration_Date__c,vehicleWeight__c,Vehicle_Number__c,
                   Private_Business_use__c, Use__c, Mileage__c, Vehicle_Type__c, Door_Number__c, Work_Location__c,Fuel_Type__c
            FROM ccp2_Registered_Vehicle__c 
            WHERE Chassis_number__c = :chassisNumberReq
        ];
        
        List<Map<String, Object>> combinedData = new List<Map<String, Object>>();

        if (vehicleDetailsData.isEmpty()) {
            return combinedData;
        }

        for (ccp2_Registered_Vehicle__c vehicle : vehicleDetailsData) {
            String vehicleId = vehicle.Id;

            // Query the branch vehicle junctions
            List<CCP2_BranchVehicle_Junction__c> branchId = [
                SELECT BranchId__c 
                FROM CCP2_BranchVehicle_Junction__c 
                WHERE VehicleId__c = :vehicleId
            ];

            Set<Id> branchIds = new Set<Id>();
            for (CCP2_BranchVehicle_Junction__c reqIds : branchId) {
                branchIds.add(reqIds.BranchId__c);
            }

            // Query the branch details
            List<CCP2_Branch__c> branchDetails = [
                SELECT Id, Name 
                FROM CCP2_Branch__c 
                WHERE Id IN :branchIds
            ];

            // Combine vehicle and branch details in a map
            Map<String, Object> vehicleAndBranches = new Map<String, Object>();
            vehicleAndBranches.put('vehicle', vehicle);
            vehicleAndBranches.put('branches', branchDetails);
            
            combinedData.add(vehicleAndBranches);
        }
		System.debug(combinedData);
        return combinedData;
    }

	// Define a wrapper class for deserializing the JSON input
	public class VehicleInputWrapper {
    	public List<String> affiliation;
    	public String bodyShape;
    	public String carName;
    	public String carPlatformNo;
    	public String initialRegistrationDate;
    	public String dateOfIssuance;
    	public String model;
    	public String vehicleNumber;
    	public String loginNumber;
    	public String expirationDate;
    	public String curbWeight;
    	public String privateOrBusinessUse;
    	public String use;
    	public String mileage;
    	public String typeOfVehicle;
    	public String doorNumber;
    	public String worklocation;
        public String carPlatformNoPart1;
        public String carPlatformNoPart2;
        public String loginNumberPart1;
        public String loginNumberPart2;
        public String loginNumberPart3;
        public String loginNumberPart4;
        public String model1;
        public String model2;
        public String fuelType;
	}
}