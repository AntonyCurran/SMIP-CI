public class DeliveryScheduleWrapper {
    public Delivery_Schedule__c deliverySchedule { get; set; }
    public List<Consignment__c> consignments {get; set;}
    public Map<Integer, List<ConsignmentItem__c>> items {get; set;}
    public Order selectedOrder {get;set;}
    
   
    public DeliveryScheduleWrapper() {
        deliverySchedule = new Delivery_Schedule__c();
        consignments = new List<Consignment__c>();
        items = new Map<Integer, List<ConsignmentItem__c>>();
    }
}