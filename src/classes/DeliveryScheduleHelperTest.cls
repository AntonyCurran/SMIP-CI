@isTest
public class DeliveryScheduleHelperTest {
    static DeliveryScheduleHelper helper = new DeliveryScheduleHelper();
    
    static Account testAccount;
    static Region__c region;
    static Product2 product1;
    
    static DateHelper dateHelper = new DateHelper();
    static HubHelper hubHelper = new HubHelper();
    
    ////////////////////////////////////////////////////////////////////////////////
    // Setup methods
    public static Delivery_Schedule__c setupCreateHappyPath() {
        Date now = System.today();
        Delivery_Schedule__c deliverySchedule = new Delivery_Schedule__c(); 
        testAccount = new Account(name='Eon', Forecast_Start_Date__c=now);
        insert testAccount;
        region = new Region__c(name='South');
        insert region;
        product1 = new Product2(name='Hub', Family='Communications Hub');
        insert product1;
        
        deliverySchedule.account__c = testAccount.id;
        deliverySchedule.region__c = region.id;
        deliverySchedule.month__c = 'January';
        deliverySchedule.year__c = '2015';
        return deliverySchedule;
    }
    
    public static Delivery_Schedule__c setupSavedDeliverySchedule() {
        Delivery_Schedule__c deliverySchedule = setupCreateHappyPath();
        insert deliverySchedule;
        return deliverySchedule;
    }
    
    public static DeliveryScheduleWrapper setupDeliveryScheduleWrapper(Delivery_Schedule__c deliverySchedule) {
        DeliveryScheduleWrapper wrapper = new DeliveryScheduleWrapper();
        wrapper.deliverySchedule = deliverySchedule;
        wrapper.consignments = new List<Consignment__c>();
        for (Integer index = 1; index <=4; index++){        
            wrapper.consignments.add(createConsignment(index, wrapper));
        }
        return wrapper;
    }

    public static DeliveryScheduleWrapper setupSavedDeliveryScheduleWrapper(Delivery_Schedule__c deliverySchedule) {
        DeliveryScheduleWrapper wrapper = setupDeliveryScheduleWrapper(deliverySchedule);
        Integer count = 1;
        Integer hubTypes = hubHelper.hubTypeCount();
        for (Consignment__c consignment : wrapper.consignments) {
            consignment.Delivery_Schedule__c = wrapper.deliverySchedule.id;
            insert consignment;
            for (ConsignmentItem__c item : wrapper.items.get(count)) {
                item.Consignment__c = consignment.id;
                insert item;
            }
            count++;          
        }
        return wrapper;
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    // Tests
    testMethod static void testCreate_DeliveryScheduleFieldsPopulated() {
        Delivery_Schedule__c  deliverySchedule = setupCreateHappyPath();
        
        DeliveryScheduleWrapper wrapper = helper.create(deliverySchedule);        
 
        System.assertEquals(testAccount.id, wrapper.deliverySchedule.account__c);
        System.assertEquals(region.id, wrapper.deliverySchedule.region__c);
    }
    
    testMethod static void testSave(){
        Delivery_Schedule__c  deliverySchedule = setupCreateHappyPath();
        DeliveryScheduleWrapper wrapper = setupDeliveryScheduleWrapper(deliverySchedule);
        Boolean result = helper.save(wrapper);
        System.assertEquals(true, result);
    }
    
    testMethod static void testLoad(){
        Delivery_Schedule__c  deliverySchedule = setupSavedDeliverySchedule();
        DeliveryScheduleWrapper wrapper = helper.load(deliverySchedule);
    }
    
    testMethod static void testAmend(){
        Delivery_Schedule__c  deliverySchedule = setupSavedDeliverySchedule();
        DeliveryScheduleWrapper wrapper = setupSavedDeliveryScheduleWrapper(deliverySchedule);
        Boolean result = helper.amend(wrapper);
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    // Helper methods
        static Consignment__c createConsignment(Integer index, DeliveryScheduleWrapper wrapper){
        Consignment__c consignment = new Consignment__c();
        consignment.Due__c = dateHelper.nextMonth().addDays((index -1) * 7);
        consignment.Position__c = index;
        consignment.Status__c = 'Created';
        List<Product2> products = hubHelper.hubTypes();
        List<ConsignmentItem__c> consignmentItems = new List<ConsignmentItem__c>();
        wrapper.items.put(index, consignmentItems);
        for (Product2 product : Products){
            ConsignmentItem__c item = new ConsignmentItem__c();
            item.Quantity__c = index * 100;
            item.Product__c = product.id;
            consignmentItems.add(item);
        }
        return consignment;
    } 
}