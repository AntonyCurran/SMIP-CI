@isTest
public class EditDeliveryScheduleExtensionTest {
    static DeliveryScheduleHelper helper = new DeliveryScheduleHelper();
    static HubHelper hubHelper = new HubHelper();
    
    testMethod static void testEditReturnsCorrectPageReference() {
        Delivery_Schedule__c deliverySchedule = DeliveryScheduleHelperTest.setupSavedDeliverySchedule();
        DeliveryScheduleWrapper wrapper = DeliveryScheduleHelperTest.setupSavedDeliveryScheduleWrapper(deliverySchedule);
        ApexPages.StandardController controller = new ApexPages.StandardController(deliverySchedule);
        EditDeliveryScheduleExtension extension = new EditDeliveryScheduleExtension(controller);
        PageReference result = extension.save();
        System.assertEquals('/a2/0', result.getUrl());
    }

    testMethod static void testEditChangesDatabase_ItemQuantity() {
        Delivery_Schedule__c deliverySchedule = DeliveryScheduleHelperTest.setupSavedDeliverySchedule();
        DeliveryScheduleHelperTest.setupSavedDeliveryScheduleWrapper(deliverySchedule);
        ApexPages.StandardController controller = new ApexPages.StandardController(deliverySchedule);
        EditDeliveryScheduleExtension extension = new EditDeliveryScheduleExtension(controller);
        DeliveryScheduleWrapper wrapper = extension.wrapper;
        List<ConsignmentItem__c> items = wrapper.items.get(1);
        Integer expected_item_quantity = 100000;
        for (ConsignmentItem__c item : items) {
            item.Quantity__c = expected_item_quantity;
        }
        PageReference result = extension.save();
        Consignment__c consignment = [
            SELECT id, name, Delivery_Location__c, Delivery_Schedule__c, Due__c, Instructions__c, Position__c, Status__c
            FROM Consignment__c 
            WHERE Delivery_Schedule__c = :deliverySchedule.id
            AND   Position__c = 1
        ];
        for (Product2 hub : hubHelper.hubTypes()) {
            ConsignmentItem__c item = [
                SELECT id,name,Consignment__c, Product__c, Quantity__c
                FROM ConsignmentItem__c
                WHERE
                    Consignment__c = :consignment.id
                    AND Product__c = :hub.id                
            ];
            System.assert(item != null);
            System.assert(item.quantity__c == expected_item_quantity);
        }
    }
    
    testMethod static void testEditChangesDatabase_ConsignmentDue() {
        Delivery_Schedule__c deliverySchedule = DeliveryScheduleHelperTest.setupSavedDeliverySchedule();
        DeliveryScheduleWrapper wrapper = DeliveryScheduleHelperTest.setupSavedDeliveryScheduleWrapper(deliverySchedule);
        
        // Change wrapper
        ApexPages.StandardController controller = new ApexPages.StandardController(deliverySchedule);
        EditDeliveryScheduleExtension extension = new EditDeliveryScheduleExtension(controller);
        PageReference result = extension.save();
    }
    
    testMethod static void testEditChangesDatabase_ConsignmentInstructions() {
        Delivery_Schedule__c deliverySchedule = DeliveryScheduleHelperTest.setupSavedDeliverySchedule();
        DeliveryScheduleWrapper wrapper = DeliveryScheduleHelperTest.setupSavedDeliveryScheduleWrapper(deliverySchedule);
        
        // Change wrapper
        ApexPages.StandardController controller = new ApexPages.StandardController(deliverySchedule);
        EditDeliveryScheduleExtension extension = new EditDeliveryScheduleExtension(controller);
        PageReference result = extension.save();
    }

}