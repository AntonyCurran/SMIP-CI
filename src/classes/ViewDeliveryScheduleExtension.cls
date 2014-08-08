public class ViewDeliveryScheduleExtension  extends AbstractParentController{
    
    public ID  ordid {get;set;}
    public override List<OI> getOIList()     {return null;}
    public AbstractParentController getThis() {
         return this;
    }
    
    public override Order getOrderRecord(){return null;}


    private DeliveryScheduleHelper deliveryHelper = new DeliveryScheduleHelper();  

    public boolean valuesReadOnly { get {return true;} }
    public DeliveryScheduleWrapper wrapper { get; set; }
        
    private DeliveryScheduleHelper deliveryScheduleHelper;
    
    
    public ViewDeliveryScheduleExtension(ApexPages.StandardController stdController) {
        modeOfScreen = VIEW_MODE;
        ID deliveryScheduleId=ApexPages.currentPage().getParameters().get('ID');
        Delivery_Schedule__c schedule = [SELECT ID, NAME,Account__c,Region__c,Month__c,Year__c, Order__C FROM Delivery_Schedule__c WHERE ID=: deliveryScheduleId ];
        ordid = schedule.Order__c;
    }   
    
    public PageReference viewOrder() {
        Order selOrder = [SELECT ID, ORDERNUMBER FROM ORDER WHERE ID =:ordid];
        PageReference pageRef = new ApexPages.StandardController(selOrder).View();
        return pageRef;
    }    
}