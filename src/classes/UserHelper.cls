public class UserHelper {
	private List<Region__c> regions = [SELECT id,name FROM Region__c];
	
    public Region__c regionForCurrentUser(){
       return regionForName('South');
    }
    
    public Account accountForCurrentUser(){
        return energySupplierForName('Eon');
    }
    
    public Region__c regionForName(String name){
    	for(Region__c region : regions){
    		if(name.equalsIgnoreCase(region.Name)){
    			return region;
    		}
    	}
    	return null;
    }
    
    // TC Retrieve the current users profile name
    public static String getCurrentUserProfileName(){
        
        User currentUser = [SELECT profile.Name 
                            FROM user 
                            WHERE Id = :userinfo.getUserId()
                            limit 1];
        
        return currentUser.profile.Name;
        
    }
    
    /* TC Determine if the current user is a energy supplier user (don't use yet!!)
    public static boolean isCurrentUserEnergySupplierUser(){
        
        // This is true if the user type is 
        return  Userinfo.getUserType().equals('');
    }*/

    /* TC Determine if the current user is a management user (don't use yet!!)
    public static boolean isCurrentUserManagementUser()
    {                  
        List<String> managementProfiles = new List<String>{'System Administrator'};
        
        Map<Id, Profile> profileIds = new Map<Id, Profile>([SELECT ID 
                                                            FROM Profile
                                                            WHERE Name IN :managementProfiles]);
        
        return profileIds.containsKey(Userinfo.getProfileId());
    }*/
    
    // TC Retrieve the current energy supplier users Group membership
    public static String getEnergySupplierGroupMembership(){
        
        GroupMember groupMemb = [SELECT groupId 
                                 FROM GroupMember 
                                 WHERE userOrGroupId = :userinfo.getUserId()
                                 LIMIT 1];
        
        return groupMemb.groupId;
        
    }
    
    // TC Retrieve the Group name
    public static String getGroupName(String groupId){
        
        Group groupName = [SELECT Name
                           FROM Group
                           WHERE Id = :groupId
                           LIMIT 1];
        
        return groupName.Name;
        
    }
    
    // TC Retrieve the Account Id (I may deprecate this in favour of the next method below)
    public static String getAccountId(String groupName){
        
        Account eSuppAcc = [SELECT Id 
                            FROM Account
                            WHERE Name = :groupName
                            AND Active__c = 'Yes'
                            LIMIT 1];
                            
        return eSuppAcc.Id;
        
    }
    
    // TC Retrieve the Account information
    public static Account getAccountByName(String groupName){
        
        Account eSuppAcc = [SELECT Id, Name 
                            FROM Account
                            WHERE Name = :groupName
                            AND Active__c = 'Yes'
                            LIMIT 1];
                            
        return eSuppAcc;
        
    }
    
    // TC is this an energy Supplier User
    public static Boolean energySupplier(){
        
        User currentUser = [SELECT Energy_Supplier_User__c 
                            FROM user 
                            WHERE Id = :userinfo.getUserId()
                            limit 1];
        
        return currentUser.Energy_Supplier_User__c;
        
    }
    
    public List<Account> energySuppliers() {
        List<Account> accounts = [
            SELECT id,name 
            FROM account
            WHERE energy_supplier__c = true
        ];
        return accounts;
   }
   
   public Account energySupplierForName(String name){
        List<Account> accounts = [
            SELECT id,name 
            FROM account
            WHERE energy_supplier__c = true
            	AND name = :name 
        ];
        if (accounts.size() > 0){
	        return accounts[0];
        } else {
        	return null;
        }
   }    
}