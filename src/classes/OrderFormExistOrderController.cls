public class OrderFormExistOrderController extends AbstractParentController{

  public String RecType{get;set;}
  public String RectypeName{get;set;}
  
  public Order Order_rec{get;set;}
  public List<OI> OIS {get;set;}
  
  public ID  ordid {get;set;}
  
  public boolean hasErrorMessages 
  {
    get 
    {
        return Apexpages.hasMessages(ApexPages.Severity.Error);
    }
  }
  
  public boolean editable{get;set;}  
  public boolean submittable{get;set;}  
  public AbstractParentController getThis() {
    return this;
  }
  
  public override List<OI> getOIList()     {return OIS;} 
  public override Order getOrderRecord(){return Order_rec;}

  public apexpages.standardController controller {get; set;}

  public OrderFormExistOrderController(ApexPages.StandardController stdController){  
      modeOfScreen = VIEW_MODE;    
      ordid=ApexPages.currentPage().getParameters().get('ID');
      List<Order> currOrd = [Select ID, RecordTypeID, AccountId, Account.Name, EffectiveDate, Status, Region__c, Pricebook2Id, Month__c, Year__c, OrderNumber from Order where ID =: ordid ];

      controller=stdController;
      this.Order_rec=currOrd[0];
      
      //Methods from Abstract class
      editable=isEditable(Order_rec.Status);
      RectypeName = getRecordTypeName(Order_rec.RecordTypeId);
      submittable = isSubmittable(Order_rec.Status);
      
      LIST<OrderRT_ProductFLY_Mapping__c> OPM = [Select Product_Family__c from OrderRT_ProductFLY_Mapping__c where Order_Record_Type__c =: RectypeName];
      String prdFamily=String.valueOf(OPM[0].Product_Family__c);
      
      List<Product2> searchList=[SELECT Id, ProductCode, Family, Name FROM Product2 where IsActive=true and Family=:prdFamily];

      OIS=new List<OI>();
      for(Product2 tmp : searchList){
          OIS.add(new OI(tmp,ordid));
      }
      
      if(isEditable(Order_rec.Status)){
            apexpages.Message message = new Apexpages.Message(ApexPages.Severity.info,Order_rec.status+' Orders could not be edited.');
            apexpages.addMessage(message);
      }
      
      createDeliveryScheduleWrapper();
  }
  
  private void createDeliveryScheduleWrapper() 
  {
      Delivery_Schedule__c deliverySchedule = [SELECT ID, NAME,Account__c,Region__c,Month__c,Year__c FROM Delivery_Schedule__c where Order__c =:ordid ];
      DeliveryScheduleHelper helper = new DeliveryScheduleHelper();
      wrapper = helper.load(deliverySchedule);
  }
   
  public PageReference recsave(){
      
    LIST<Ord_PB_Mapping__c> OPB = [Select PriceBook_Name__c from Ord_PB_Mapping__c where Order_Record_Type__c =: RectypeName];
    String PBName = OPB[0].PriceBook_Name__c;
    Pricebook2 standardBook=[SELECT Id FROM Pricebook2 WHERE Name=: PBName];

    Integer oit=0;
    List<OrderItem> ordItList=new List<OrderItem>();
    
    //On Edit scenarios - Update existing lineItem, Insert new Line Item, Delete LineItem
    for(Integer i=0; i<OIS.size(); i++){
        OI tmp=OIS[i];
        OrderItem newOdIt=new OrderItem(
            Id=tmp.OrdItem.Id,
            OrderId=Order_rec.Id,
            PricebookEntryId=tmp.OrdItem.PricebookEntryId,
            UnitPrice=tmp.OrdItem.UnitPrice,
            IsRecDeleted__c=tmp.OrdItem.IsRecDeleted__c
        );
        
        if(tmp.OrdItem.Id == null){
            Product2 prd=[Select Id from Product2 where ProductCode=:tmp.PC];
            PricebookEntry entry = [SELECT Id, UnitPrice FROM PricebookEntry WHERE Pricebook2Id = :standardBook.Id AND Product2.ProductCode =: tmp.PC];
            newOdIt.PricebookEntryId=entry.Id;
            newOdIt.UnitPrice=entry.UnitPrice;
        }
        
        if(tmp.OrdItem.Quantity>0){
            newOdIt.Quantity=tmp.OrdItem.Quantity;
            if(tmp.OrdItem.Id != null){
                List<OrderItem> oldOrderItem=[Select Quantity, IsRecDeleted__c from OrderItem where Id=:tmp.OrdItem.Id];
                if(oldOrderItem.size()>0){
                    if((oldOrderItem[0].IsRecDeleted__c==true)||(oldOrderItem[0].Quantity != tmp.OrdItem.Quantity)){                        
                        newOdIt.IsRecDeleted__c=false;
                    }
                }
            }
            ordItList.add(newOdIt);
        }else if(tmp.OrdItem.Id != null && tmp.OrdItem.IsRecDeleted__c != true){
            newOdIt.IsRecDeleted__c=true;
            ordItList.add(newOdIt);            
        }
    }

    try{
          upsert ordItList;
    }catch(Exception e){
          ApexPages.addMessages(e);
    }  
    
        DeliverySchedulerComponentController childController = (DeliverySchedulerComponentController) childComponentController;
        childController.wrapper.selectedOrder= Order_rec;
        boolean deliveryScheduleControllerSaved = childComponentController.amend();
        if(!deliveryScheduleControllerSaved) 
        {
             apexpages.Message message = new Apexpages.Message(ApexPages.Severity.Error,'Failed to save Delivery Schedule.');
             apexpages.addMessage(message);
             //..Database.rollback(intialSavePoint);
             return null;
        }

    Schema.DescribeSObjectResult result = Order.SObjectType.getDescribe();
      
    PageReference pageRef = new ApexPages.StandardController(Order_rec).view();
      pageRef.setRedirect(true);
      return pageRef;
  }

  public PageReference cancel(){
      Schema.DescribeSObjectResult result = Order.SObjectType.getDescribe();
      
      PageReference pageRef = new PageReference('/' + result.getKeyPrefix() + '/o');
      pageRef.setRedirect(true);
      return pageRef;      
  }
  
  public PageReference submit(){
    if(submitContainValidationErrorMessage()) 
    {
        return null;
    }
    
    Approval.ProcessSubmitRequest subReq = new Approval.ProcessSubmitRequest();
    subReq.setComments('Submitted for DCC Approval');
    subReq.setObjectId(Order_rec.Id);

    Approval.ProcessResult AppRes = Approval.process(subReq);
    System.debug('>>>>>>>>>>>>>>>>>>>>>>>>> Submitted for Approval'+AppRes.isSuccess());
      
    Schema.DescribeSObjectResult result = Order.SObjectType.getDescribe();
      
    PageReference pageRef = new PageReference('/' + result.getKeyPrefix() + '/o');
    pageRef.setRedirect(true);
    return pageRef;
  }
  
  
   private Boolean submitContainValidationErrorMessage() 
   {    
        List<Apexpages.Message> messageList = new List<Apexpages.Message>();
        
        OrderFormControllerErrorHandler errorHandler = new OrderFormControllerErrorHandler(this,messageList);   
        errorHandler.processErrorAndWarningMessages();      
        boolean hasErrorMessages = false;
        for(ApexPages.Message errMessage : errorHandler.messageList) 
        {
            Apexpages.addMessage(errMessage);
            if(errMessage!=null && errMessage.getSeverity()==ApexPages.Severity.Error) 
            {
                hasErrorMessages = true;
            }
        
        }
        System.debug('=====OrderFormExistController====199====='+hasErrorMessages);
        return hasErrorMessages;
        
   }
}