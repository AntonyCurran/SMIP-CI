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
private class AbstractComponentControllerTest {

    static testMethod void testAbstractComponentController() {
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
        
     	AbstractComponentController componentController = new DeliverySchedulerComponentController();
   		componentController.parentController = testplan;
   		System.assertEquals(AbstractComponentController.VIEW_MODE, 'VIEW'); 
        
        System.assertEquals(AbstractComponentController.NEW_MODE, 'NEW');
        
        System.assertEquals(AbstractComponentController.EDIT_MODE, 'EDIT'); 
      
     }
}