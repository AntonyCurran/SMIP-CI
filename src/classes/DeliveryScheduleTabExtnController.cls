public class DeliveryScheduleTabExtnController {
    public List<Delivery_Schedule__c> schedules {get
    
    {
        RETURN [SELECT ID, NAME, ACCOUNT__C, REGION__C, YEAR__C, MONTH__C FROM DELIVERY_SCHEDULE__C ORDER BY ID DESC];
    }}
    public DeliveryScheduleTabExtnController(ApexPages.StandardSetController controller) {

    }

}