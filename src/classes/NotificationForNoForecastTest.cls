/*
Once status field added to Energy Supplier Forecase asserts will be added to class to match the records the status updated and count emails being sent.
*/
@isTest
public class NotificationForNoForecastTest{
    
   static testMethod void test()    {
       Account[] al = new List<Account>();
       Contact[] c1 = new List<Contact>();
       for (Integer i=0;i<3;i++) {
           Account m = new Account(
               Name='Merchandise ' + i,
               Description='Some description',
           Forecast_Start_Date__c=Date.today()+30);
           al.add(m);
           Contact c = new Contact(LastName='graham',AccountId=m.id, Email='mailtosguptha@gmail.com', Type__c='Notifier');
           c1.add(c);
       }
       
       insert al;
       insert c1;
        NotificationForNoForecast bc = new NotificationForNoForecast();
        bc.query='select id,name from Account where id not in(select Energy_Supplier__c from Energy_Supplier_Forecast__c where CreatedDate = THIS_MONTH)';
        Test.startTest();
        Database.executeBatch(bc);
        Test.stopTest();
        }
        
}