@isTest
public class CreateDeliveryScheduleExtensionTest {

    static HubHelper hubHelper = new HubHelper();
    static DateHelper dateHelper = new DateHelper(); 
    
    static testMethod void testSaveStoresTheRightInformationInTheDatabase() {
        DeliveryScheduleHelperTest.setupCreateHappyPath();
        Delivery_Schedule__c deliverySchedule = new Delivery_Schedule__c();
        ApexPages.StandardController controller = new ApexPages.StandardController(deliverySchedule);
        CreateDeliveryScheduleExtension extension = new CreateDeliveryScheduleExtension(controller);
        PageReference result = extension.save();
        
        // Check that the page reference has been created
        System.assert(result != null);
        
        // Check that the delivery schedule has been created correctly
        Account account = [SELECT id,name FROM Account WHERE name = 'Eon'];
        Region__c region = [SELECT id,name FROM Region__c WHERE name = 'South'];
        Date expectedMonth = dateHelper.nextMonth();

        Delivery_Schedule__c actualDeliverySchedule = [
            SELECT id, name, Account__c, Region__c, Month__c, Year__c 
            FROM Delivery_Schedule__c 
            WHERE 
                Account__c = :account.id 
                AND Region__c = :region.id 
        ];
        System.assert(actualDeliverySchedule != null);
        System.assert( dateHelper.nameOfMonth(expectedMonth) == actualDeliverySchedule.Month__c);
        System.assert( String.valueof(expectedMonth.year()) == actualDeliverySchedule.Year__c);
        
        // Check that consignments and items have been saved
        List<Consignment__c> actualConsignments = [
            SELECT id, name, Delivery_Location__c, Delivery_Schedule__c, Due__c, Instructions__c, Position__c, Status__c
            FROM Consignment__c 
            WHERE Delivery_Schedule__c = :actualDeliverySchedule.id
        ];
        
        Integer position = 1;
        Integer item_number = 1;
        for (Consignment__c consignment : actualConsignments) {
            // Each should have
            System.assert(consignment.Delivery_Location__c == null);
            System.assert(consignment.Delivery_Schedule__c == actualDeliverySchedule.id);
            System.assert(consignment.Due__c != null);
            System.assert(consignment.Instructions__c == null);
            System.assert(consignment.Position__c == position);
            System.assert(consignment.Status__c == 'Created');
            
            for (Product2 hub : hubHelper.hubTypes()) {
                ConsignmentItem__c item = [
                    SELECT id,name,Consignment__c, Product__c, Quantity__c
                    FROM ConsignmentItem__c
                    WHERE
                        Consignment__c = :consignment.id
                        AND Product__c = :hub.id                
                ];
                System.assert(item != null);
                System.assert(item.quantity__c == item_number*100);
                item_number++;
            }
            position++;
        }
    }
    
    static testMethod void testSaveReturnsCorrectPageReference() {
        DeliveryScheduleHelperTest.setupCreateHappyPath();
        Delivery_Schedule__c deliverySchedule = new Delivery_Schedule__c();
        ApexPages.StandardController controller = new ApexPages.StandardController(deliverySchedule);
        CreateDeliveryScheduleExtension extension = new CreateDeliveryScheduleExtension(controller);
        PageReference result = extension.save();
        System.assert('/a02/o' == result.getUrl());
    }

}