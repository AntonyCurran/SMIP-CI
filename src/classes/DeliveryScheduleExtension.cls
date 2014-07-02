public class DeliveryScheduleExtension {
    public Delivery_Schedule__c deliverySchedule { get; set; }
    public List<Order> consignments {get; set;}
    private ApexPages.StandardController stdController;
    
    public DeliveryScheduleExtension(ApexPages.StandardController stdController) {
        deliverySchedule = (Delivery_Schedule__c)stdController.getRecord();
        
        if (deliverySchedule == null) {
            deliverySchedule = new Delivery_Schedule__c();
        }
        
        consignments = new List<Order>();
        consignments.add(new Order());
        consignments.add(new Order());
        consignments.add(new Order());
        consignments.add(new Order());
        
        System.debug('There are now ' + consignments.size() + ' consignments');
    }

    public PageReference save() {
        insert deliverySchedule;
        return new PageReference('/a01/o');
    }
}