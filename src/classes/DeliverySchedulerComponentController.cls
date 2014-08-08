public  class DeliverySchedulerComponentController extends AbstractComponentController {

    public DeliveryScheduleWrapper wrapper           { get;set;}
    public DeliveryScheduleHelper deliveryHelper     { get;set;} 
    public Delivery_Schedule__c delivery_schedule   { get;set;}
    public String consId{get;set;}
    public boolean manageDeliveryReceivedButton {get;set;}     
    
  public boolean hasErrorMessages 
  {
    get 
    {
        return Apexpages.hasMessages(ApexPages.Severity.Error);
    }
  }
    public DeliverySchedulerComponentController () {
        initValues();
    }
    
    //private void initValues()
    private void initValues() 
    {
        modeOfScreen = NEW_MODE;
        wrapper = new DeliveryScheduleWrapper();
        deliveryHelper = new DeliveryScheduleHelper();        
        delivery_schedule = new Delivery_Schedule__c();

        //VG - Modified to make OrderType dynamically selected
    	String RecType=ApexPages.currentPage().getParameters().get('RecordType');
    	//if(RecType != null){
    		System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>> DELIVERYSCHEDULERCOMPONENTCONTROLLER >>>>>>>>>>>> RECORD TYPE'+ RecType);
    		Map<ID, Schema.RecordTypeInfo> recordtypeinfomap = Schema.SObjectType.Order.getRecordTypeInfosById();
        	String RectypeName = recordtypeinfomap.get(RecType).getName();
        
        	LIST<OrderRT_ProductFLY_Mapping__c> OPM = [Select Product_Family__c from OrderRT_ProductFLY_Mapping__c where Order_Record_Type__c =: RectypeName];
        	String prdFamily=String.valueOf(OPM[0].Product_Family__c);
    	//} else {
    	//}
        //wrapper = deliveryHelper.create(delivery_schedule);
        wrapper = deliveryHelper.create(delivery_schedule, prdFamily);
        
    }
    
    public override boolean save() {
    	//VG : Added for SMIP-104
    	/* String RecType=ApexPages.currentPage().getParameters().get('RecordType');
    	System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>> DELIVERYSCHEDULERCOMPONENTCONTROLLER >>>>>>>>>>>> RECORD TYPE'+ RecType);
    	Map<ID, Schema.RecordTypeInfo> recordtypeinfomap = Schema.SObjectType.Order.getRecordTypeInfosById();
        String RectypeName = recordtypeinfomap.get(RecType).getName();
        
        LIST<OrderRT_ProductFLY_Mapping__c> OPM = [Select Product_Family__c from OrderRT_ProductFLY_Mapping__c where Order_Record_Type__c =: RectypeName];
        String prdFamily=String.valueOf(OPM[0].Product_Family__c);
        
    	*/
        return deliveryHelper.save(wrapper);
        //return deliveryHelper.save(wrapper, prdFamily);
    }
    
   public void acknowledgeDelivery(){
        List<Consignment__c> gds = [select status__c,ReceivedOn__c from Consignment__c where id=:consId];
        if(gds.size()>0){
        	gds[0].status__c='Goods Received';
            gds[0].ReceivedOn__c=System.now();
            System.debug('Goods Received at'+ System.now()+':********'+gds[0].Status__c);
        }
       update gds;
   }
         
           
       
    public override boolean amend() 
    {
        return (deliveryHelper.amend(wrapper));
    }
    
    public  AbstractParentController parentController   {get;set
        {
            if(value!=null) 
            {
                parentController = value;
                setValuesFromParentController();
            }
        }}
    private void setValuesFromParentController() 
    {   
    	parentController.childComponentController = this;
    	manageDeliveryReceivedButton = false;
    	
    	if((parentController.modeOfScreen.equalsIgnoreCase(VIEW_MODE)||parentController.modeOfScreen.equalsIgnoreCase(EDIT_MODE))&& parentController instanceof OrderFormExistOrderController)
        { 
           OrderFormExistOrderController pController = (OrderFormExistOrderController) parentController;           
           ID orderId = pController.ordid;
           if(parentController.wrapper!=null) 
           {
           		wrapper = parentController.wrapper;
           }
           else {
           		delivery_schedule = [SELECT ID, NAME,Account__c,Region__c,Month__c,Year__c FROM Delivery_Schedule__c where Order__c =:orderId ];
               	wrapper = deliveryHelper.load(delivery_schedule);
           }
           displayErrorAndWarningMessages();
        }
        
        
        if(parentController.modeOfScreen.equalsIgnoreCase(VIEW_MODE)&& parentController instanceof ViewDeliveryScheduleExtension)
        { 
           
           System.debug('user Profile**:'+UserHelper.getCurrentUserProfileName());
           if(UserHelper.getCurrentUserProfileName()=='Energy Supplier - New'){
           			manageDeliveryReceivedButton = true;
        }
           ViewDeliveryScheduleExtension pController = (ViewDeliveryScheduleExtension) parentController;           
           ID orderId = pController.ordid;
           Delivery_Schedule__c delivery_schedule = [SELECT ID, NAME,Account__c,Region__c,Month__c,Year__c FROM Delivery_Schedule__c where Order__c =:orderId ];
           //..Delivery_Schedule__c delivery_schedule = [SELECT ID, NAME,Account__c,Region__c,Month__c,Year__c FROM Delivery_Schedule__c where Order__c =:orderId ];
           wrapper = deliveryHelper.load(delivery_schedule);
           
        }
        
        if(parentController.modeOfScreen.equalsIgnoreCase(EDIT_MODE) && parentController instanceof EditDeliveryScheduleExtension)
        { 
           
          EditDeliveryScheduleExtension editDelExtn = (EditDeliveryScheduleExtension) parentController;
          wrapper = editDelExtn.wrapper;
        }
        
        
    }
     
   private void displayErrorAndWarningMessages() 
   {  
    
        List<Apexpages.Message> messageList = new List<Apexpages.Message>();
        
        OrderFormControllerErrorHandler errorHandler = new OrderFormControllerErrorHandler(parentController,messageList);   
       	errorHandler.processErrorAndWarningMessages(); 
        for(ApexPages.Message errMessage : messageList) 
        {
            Apexpages.addMessage(errMessage);
        }
       //.. Apexpages.
    }
    
    
}