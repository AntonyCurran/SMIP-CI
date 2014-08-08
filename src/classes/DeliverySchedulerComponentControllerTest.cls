/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(SeeAllData=true)
private class DeliverySchedulerComponentControllerTest {

    private static OrderFormController     orderController;
    private static DeliveryScheduleWrapper wrapper;
    private static DeliverySchedulerComponentController deliveryScheduleController;
    private static PageReference pageRef;
    
     
    private static void prepareBasicTestData() 
    {
    	    
        LIST<RecordType> RT=[Select Id from RecordType where SobjectType='Order'];
        Account tst=new Account(Name='Test Account', Forecast_Start_Date__c=system.today());
        insert tst;
        ID accId=tst.Id;
         
          
        Contact cont = new Contact( lastname='Testing Last Name' , type__c='Notifier', accountId=accId);  
        insert cont;
      
        Order Order_rec = new Order(
            RecordTypeId=RT[2].Id,
            AccountId=tst.Id
         );
        order_rec.EffectiveDate = Date.newInstance(2014, 7, 28);
        pageRef = Page.OrderForm;
        pageRef.getParameters().put('RecordType',RT[2].Id);
        Test.setCurrentPage(pageRef);
            
        ApexPages.StandardController standarController = new ApexPages.StandardController(Order_rec);
        orderController = new OrderFormController(standarController);
        
        deliveryScheduleController = new DeliverySchedulerComponentController();
        OrderController.childComponentController = deliveryScheduleController;
        wrapper = deliveryScheduleController.wrapper;
    
    
    }
    
    static testMethod void testDeliveryScheduleComponentController() {
    	prepareBasicTestData();
      	deliveryScheduleController.parentController = orderController;
        
        Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.Error, 'Error'));
        
        System.assertEquals(deliveryScheduleController.hasErrorMessages, true);
    }
    
    
    static testMethod void testDeliveryScheduleComponentControllerForOrderExist() {
    	
    	prepareBasicTestData();
        orderController.recsave();
        
        Order orderRec = orderController.getOrderRecord();
        
        
        pageRef.getParameters().put('ID',orderRec.Id);
        
        ApexPages.Standardcontroller sController= new ApexPages.Standardcontroller(orderRec);
        
        OrderFormExistOrderController orderExistController = new OrderFormExistOrderController(sController);
        
        DeliverySchedulerComponentController scheduleController = new DeliverySchedulerComponentController();
        
        orderExistController.childComponentController = scheduleController;
        
        scheduleController.parentController = orderExistController;
        
        Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.Error, 'Error'));
               
        orderExistController.recsave();
         
        System.assertEquals(deliveryScheduleController.hasErrorMessages, true);
        
        
    } 
    
    static testMethod void testAcknowledgeDelivery(){
    	
    	prepareBasicTestData();
        orderController.recsave();
        
        Order orderRec = orderController.getOrderRecord();
    
       
        Test.startTest();
        List<Consignment__c> consignmentList = wrapper.consignments;
        Consignment__c secondConsignment = consignmentList.get(1);
        List<ConsignmentItem__c> consignmentItemsList = wrapper.items.get((secondConsignment.Position__c).intValue());
   	    consignmentItemsList.get(0).Quantity__c = 3;
   	    
   	    pageRef.getParameters().put('ID',orderRec.Id);
        
        ApexPages.Standardcontroller sController= new ApexPages.Standardcontroller(orderRec);
        
        OrderFormExistOrderController orderExistController = new OrderFormExistOrderController(sController);
        
        DeliverySchedulerComponentController scheduleController = new DeliverySchedulerComponentController();
        
        scheduleController.consId=secondConsignment.Id;
        
        scheduleController.acknowledgeDelivery();
        System.assertEquals(secondConsignment.id, scheduleController.consId);
         List<Consignment__c> gds = [select status__c from Consignment__c where id=:secondConsignment.Id];
        System.assertEquals('Goods Received',gds[0].status__C );
        Test.stopTest();
   	    
   	    
    	
    }
}