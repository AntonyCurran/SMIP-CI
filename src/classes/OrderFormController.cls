public with sharing class OrderFormController extends AbstractParentController{

  public String RecType{get;set;}
  public String RectypeName{get;set;}
  public Order Order_rec{get;set;}
  public List<OI> OIS {get;set;} 
  private DateHelper dateHelperObj = new DateHelper();    
  
  public AbstractParentController getThis() {
    return this;
  }
 
  public override Order getOrderRecord(){return Order_rec;}
  
  public override List<OI> getOIList()     {return OIS;}
  
  public apexpages.standardController controller {get; set;}

  public OrderFormController(ApexPages.StandardController stdController){
      String pageName = apexpages.currentPage().getParameters().get('Name');
      modeOfScreen = NEW_MODE;
      RecType=ApexPages.currentPage().getParameters().get('RecordType');
      Map<ID, Schema.RecordTypeInfo> recordtypeinfomap = Schema.SObjectType.Order.getRecordTypeInfosById();
      RectypeName = recordtypeinfomap.get(RecType).getName();
      
      LIST<OrderRT_ProductFLY_Mapping__c> OPM = [Select Product_Family__c from OrderRT_ProductFLY_Mapping__c where Order_Record_Type__c =: RectypeName];
      String prdFamily=String.valueOf(OPM[0].Product_Family__c);
      
      List<Product2> searchList=[SELECT ProductCode, Family, Name FROM Product2 where IsActive=true and Family=:prdFamily];
        
      controller=stdController;
      this.Order_rec=(Order)Controller.getRecord();     
      this.Order_rec.RecordTypeID=RecType;
      Order_rec.RecordTypeId=RecType;
      
      OIS=new List<OI>();
      
      for(Product2 tmp : searchList){            
            OIS.add(new OI(tmp));            
      }
  }
 
  public PageReference recsave(){
        String parentIdentifier=Order_rec.Account.Name+string.valueOf(DateTime.now());
        Order newOrdRef=new Order( 
            Parent_ID__c=parentIdentifier
        );
  
        LIST<Ord_PB_Mapping__c> OPB = [Select PriceBook_Name__c from Ord_PB_Mapping__c where Order_Record_Type__c =: RectypeName];
        String PBName = OPB[0].PriceBook_Name__c;
      
        Pricebook2 standardBook=[SELECT Id FROM Pricebook2 WHERE Name=: PBName];
        Account acc=[Select Id from Account where Id=:Order_rec.AccountId];
        LIST<Contact> custAuthId = [select id from Contact where AccountId=:Order_rec.AccountId and Type__c ='Notifier' limit 1];
        
        Order newOrd;
        if(custAuthId.size()>0){
            newOrd= new Order(
            RecordTypeId=RecType, 
            Account=acc, 
            AccountId=acc.Id, 
            EffectiveDate=Order_rec.EffectiveDate,             
            Status='Created',
            Region__c=Order_rec.Region__c, 
            Pricebook2Id=standardBook.Id, 
            Parent_ID__c=parentIdentifier,
            CustomerAuthorizedById=custAuthId[0].id
        );
        }else{
            newOrd = new Order(
            RecordTypeId=RecType, 
            Account=acc, 
            AccountId=acc.Id, 
            EffectiveDate=Order_rec.EffectiveDate, 
            Status='Created',
            Region__c=Order_rec.Region__c, 
            Pricebook2Id=standardBook.Id, 
            Parent_ID__c=parentIdentifier
            );
            
        }
        
        Integer oit=0;
    
        for(Integer i=0; i<OIS.size(); i++){
            OI tmp=OIS[i];            
            Product2 prd=[Select Id from Product2 where ProductCode=:tmp.PC];
            PricebookEntry entry = [SELECT Id, UnitPrice FROM PricebookEntry WHERE Pricebook2Id = :standardBook.Id AND Product2.ProductCode =: tmp.PC];
      
            OrderItem newOdIt=new OrderItem( 
                PricebookEntryId=entry.Id, 
                Quantity=tmp.OrdItem.Quantity, 
                UnitPrice=entry.UnitPrice, 
                Order=newOrdRef 
            );        
            try{     
                if(oit==0 && tmp.OrdItem.Quantity>0){
                    insert new List<Sobject>{newOrd, newOdIt};
                    oit=1;
                }else if(tmp.OrdItem.Quantity>0) {
                    insert new List<Sobject>{newOdIt};
                }
            }catch(Exception e)
            {
                ApexPages.addMessages(e);
            }
        }
    
        if(oit==0){
            insert new List<Sobject>{newOrd};
        }
        
        PageReference pageRef = new ApexPages.StandardController(newOrd).View();
        pageRef.setRedirect(true);
        Order_rec = newOrd;
        DeliverySchedulerComponentController childController = (DeliverySchedulerComponentController) childComponentController;
        childController.wrapper.selectedOrder= Order_rec;
        boolean deliveryScheduleControllerSaved = childComponentController.save();
        if(!deliveryScheduleControllerSaved) 
        {
             //..Database.rollback(intialSavePoint);
             return null;
        }
        return pageRef;
  }
    
//  public PageReference AddDeliverySchedule(){    
//          PageReference newocp = new PageReference('/apex/Create_Schedule_Page');
//        newocp.setRedirect(true);
//        return newocp;
//  }
}