@isTest
class ViewDeliveryScheduleExtensionTest {
    static DeliveryScheduleHelper helper = new DeliveryScheduleHelper();
    testMethod static void testConstructorCreatesWrapper() {
        Delivery_Schedule__c deliverySchedule = DeliveryScheduleHelperTest.setupSavedDeliverySchedule();
        DeliveryScheduleWrapper wrapper = DeliveryScheduleHelperTest.setupSavedDeliveryScheduleWrapper(deliverySchedule);
        
        // Change wrapper
        ApexPages.StandardController controller = new ApexPages.StandardController(deliverySchedule);
        ViewDeliveryScheduleExtension extension = new ViewDeliveryScheduleExtension(controller);
        System.assert(extension.wrapper != null);
    }

}