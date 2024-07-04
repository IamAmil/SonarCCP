public with sharing class CCP2_callPermissionSet {
    @InvocableMethod(label='userId' description ='userId')
    public static void callMethodPermissionSet(List<Id> userId){
       ccp2_userPermissionSet.permissionValues(userId[0]);  
    }
}