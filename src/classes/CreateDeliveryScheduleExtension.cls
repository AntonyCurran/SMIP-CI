public class CreateDeliveryScheduleExtension extends AbstractParentController{
    public boolean valuesReadOnly { get {return false;} }
    public CreateDeliveryScheduleExtension() {

    }
     public AbstractParentController getThis() {
        return this;
    }
    
    public override Order getOrderRecord(){return null;}

    public override List<OI> getOIList()     {return null;}
    public PageReference savePage() 
    {
         boolean ref =  childComponentController.save();
         return null;
    }
    public DeliveryScheduleWrapper wrapper { get;set;}
       
    private DeliveryScheduleHelper deliveryHelper = new DeliveryScheduleHelper();    
    private ApexPages.StandardController stdController;
    
    public CreateDeliveryScheduleExtension(ApexPages.StandardController stdController) {
        wrapper = deliveryHelper.create((Delivery_Schedule__c)stdController.getRecord());
    }

    public PageReference save() {
        if (deliveryHelper.save(wrapper)) {
            return new PageReference('/a02/o');
        } else {
            return null;
        }
    }
        
}