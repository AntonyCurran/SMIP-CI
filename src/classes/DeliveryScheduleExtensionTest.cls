@isTest
public class DeliveryScheduleExtensionTest {
    static testMethod void testThatADeliveryScheduleIsCreatedWhenSaveIsPressed(){
        Date now = System.today();
        Delivery_Schedule__c deliverySchedule = new Delivery_Schedule__c(); 
        Account testAccount = new Account(name='Bob\'s Energy Supplier', Forecast_Start_Date__c=now);
        insert testAccount;
        Region__c region = new Region__c(name='God\'s Land');
        insert region;
        
        deliverySchedule.account__c = testAccount.id;
        deliverySchedule.region__c = region.id;
        deliverySchedule.month__c = 'January';
        deliverySchedule.year__c = '2015';

        ApexPages.StandardController controller = new ApexPages.StandardController(deliverySchedule);
        DeliveryScheduleExtension extension = new DeliveryScheduleExtension(controller);
        extension.save();
        
        Delivery_Schedule__c result = [SELECT account__c, region__c FROM Delivery_Schedule__c WHERE month__c = 'January' AND year__c = '2015'];
        System.debug(result.account__c);
        System.debug(result.region__c);
        System.assertEquals(testAccount.id, result.account__c);
        System.assertEquals(region.id, result.region__c);
    }
}