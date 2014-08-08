public class EditDeliveryScheduleExtension extends AbstractParentController{
        public AbstractParentController getThis() {
        return this;
    }
    Delivery_Schedule__c deliverySchedule;
    public override Order getOrderRecord(){return null;}
    public override List<OI> getOIList()     {return null;}
    public DeliveryScheduleWrapper wrapper { get; set; }
    private DeliveryScheduleHelper deliveryScheduleHelper;
    
    public EditDeliveryScheduleExtension(ApexPages.StandardController stdController) {
        modeOfScreen=EDIT_MODE;
        deliveryScheduleHelper = new deliveryScheduleHelper();
        deliverySchedule = deliveryScheduleHelper.getRecord(stdController);
        wrapper = deliveryScheduleHelper.load(deliverySchedule);
     }   

    public PageReference save() {
        
        if(childComponentController.amend()) 
        {
            PageReference pageRef = new ApexPages.StandardController(deliverySchedule).View();
            pageRef.setRedirect(true);
      
            return pageRef;
        }
        return null;
      
     }
}