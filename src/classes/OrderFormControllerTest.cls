@isTest
public class OrderFormControllerTest{
    
    public static testMethod void testOrderFormController() {
        LIST<RecordType> RT=[Select Id from RecordType where SobjectType='Order'];
        Account tst=new Account(Name='Test Account', Forecast_Start_Date__c=system.today());
        insert tst;
        ID accId=tst.Id;
            
        Contact cont = new Contact( lastname='Testing Last Name' , type__c='Notifier', accountId=accId);  
        insert cont;
     
        Order Order_rec = new Order(
            RecordTypeId=RT[2].Id,
            AccountId=tst.Id,
            EffectiveDate=system.today()
            //Status='Draft'            
        );
        PageReference pageRef = Page.OrderForm;
        pageRef.getParameters().put('RecordType',RT[2].Id);
        Test.setCurrentPage(pageRef);
            
        ApexPages.StandardController sc = new ApexPages.StandardController(Order_rec);
        OrderFormController testPlan = new OrderFormController(sc);   
        
        DeliverySchedulerComponentController deliveryScheduleController = new DeliverySchedulerComponentController();
        testPlan.childComponentController = deliveryScheduleController;
        DeliveryScheduleWrapper wrapper = deliveryScheduleController.wrapper;
        PageReference pageReferenceBeforeSave = Apexpages.currentPage();     
        PageReference testPlanPageSaveReference =   testPlan.recsave();
        String orderId = testPlan.Order_rec.id;
        
        if(testPlanPageSaveReference!=null)     
        {   
            String pg=testPlanPageSaveReference.getURL();
            PageReference pgRf = new PageReference('/' + orderId);
            String pg1=pgRf.getUrl();
            String OrderIdFromPg1 = pg1.substring(0, pg1.length()-3);
            System.assertEquals(pg,OrderIdFromPg1);
        }
        else 
        {    
             System.assertEquals(ApexPages.currentPage().getUrl(),pageReferenceBeforeSave.getUrl());
        
        }
        
    }
   
}