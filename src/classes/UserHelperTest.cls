@isTest
public class UserHelperTest {
    private static UserHelper helper = new UserHelper();

    testMethod static void testRegionForCurrentUser(){
        Region__c south = new Region__c(name='South');
        insert south;
        
        // Need to set up real current user with a region
        Region__c result = helper.regionForCurrentUser();
        System.assertEquals(result.name, 'South');        
    }
    
    testMethod static void testAccountForCurrentUser() {
        Account account = new Account(name='Eon', Forecast_Start_Date__c=System.today());
        insert account;
        
        Account result = helper.accountForCurrentUser();
        System.assertEquals(result.name, 'Eon');
    }
    
    testMethod static void testEnergySuppliers() {
        List<Account> accounts = new List<Account>();
        Account account1 = new Account(name='Eon', Forecast_Start_Date__c=System.today(), Energy_Supplier__c=true);
        accounts.add(account1);
        Account account2 = new Account(name='British Gas', Forecast_Start_Date__c=System.today(), Energy_Supplier__c=true);
        accounts.add(account2);
        Account account3 = new Account(name='Telefonica', Forecast_Start_Date__c=System.today(), Energy_Supplier__c=false);
        accounts.add(account3);
        
        Integer number_of_energy_suppliers = 2;
        insert accounts;
        
        List<Account> actualAccounts = helper.energySuppliers();
        System.assert(actualAccounts.size() == number_of_energy_suppliers);
    }
}