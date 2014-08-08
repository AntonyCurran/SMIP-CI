public with sharing abstract class AbstractParentController {
    
    public  AbstractComponentController childComponentController {set;get;} 
    public static  String NEW_MODE                      {get{ return 'NEW';}}
    public static  String EDIT_MODE                     {get{ return 'EDIT';}}
    public static  String VIEW_MODE                     {get{ return 'VIEW';}}
    public         String modeOfScreen                  {get;set;}
    public DeliveryScheduleWrapper wrapper              {get;set;}
    public abstract List<OI> getOIList(); 
    //VG : Implemented for Order. Can be extended for other classess if needed.
    public boolean isEditable(string recStatus){
          string profName=UserHelper.getCurrentUserProfileName();          
          if(profName=='DCC User' && recStatus=='Submitted'){              
              return false;
          }else if(recStatus=='Submitted'  || recStatus=='Approved'){              
              return true;
          }else{              
              return false;
          }
    }

    //VG : Implemented for Order. Can be extended for other classess if needed.
    //More logic can be incorporated based on approval process levels / profiles.
    public boolean isSubmittable(string recStatus){
          
          if(recStatus=='Submitted'  || recStatus=='Approved'){
              return true;
          }else{
              return false;
          }
    }

    
    //VG : Implemented for Order. Can be extended for other classess if needed.
    public String getRecordTypeName(ID recTypeId){
        Map<ID, Schema.RecordTypeInfo> recordtypeinfomap = Schema.SObjectType.Order.getRecordTypeInfosById();
        String rectypeName = recordtypeinfomap.get(recTypeId).getName();
        return recTypeName;
    }
    
    public abstract Order getOrderRecord();
    
        
  	public class OI{
        public String PC{get;set;}
        public String Name{get;set;}
        public ID     productId {get;set;}
        public Integer Qty{get;set;}
        public OrderItem OrdItem{get;set;}
        
        public OI(Product2 tmp){
            this.PC=tmp.ProductCode;
            this.productId = tmp.id;
            this.Name=tmp.Name;
            this.OrdItem=new OrderItem(Quantity=0);            
        }
        
        public OI(Product2 tmp, ID ordid){
            this.PC=tmp.ProductCode;
            this.productId = tmp.id;
            this.Name=tmp.Name;
            Decimal Qnty=0;
            Boolean isExisting=false;
            List<OrderItem> OrdItemList=[Select OrderId , PricebookEntryId, Quantity, PricebookEntry.Product2Id, UnitPrice, IsRecDeleted__c from OrderItem where OrderId=: ordid];
            
            for(OrderItem OrdIt_tmp : OrdItemList){              
              if(OrdIt_tmp.PricebookEntry.Product2Id==tmp.Id){
                  if(OrdIt_tmp.IsRecDeleted__c == true){
                      Qnty=0;
                      OrdIt_tmp.Quantity=0;
                      isExisting=true;
                  }else{
                  	Qnty=OrdIt_tmp.Quantity;
                  }
                  this.OrdItem=OrdIt_tmp;                  
              }
            }
            
            if(Qnty==0 && isExisting==false){
                        this.OrdItem=new OrderItem(Quantity=Qnty);
            }
        }
  }
}