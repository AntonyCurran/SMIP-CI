@isTest(seealldata=true)
public class OrderFormControllerErrorHandlerTest 
{
    private static OrderFormController     orderController;
    private static DeliveryScheduleWrapper wrapper;
    private static DeliverySchedulerComponentController deliveryScheduleController;
    
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
        PageReference pageRef = Page.OrderForm;
        pageRef.getParameters().put('RecordType',RT[2].Id);
        Test.setCurrentPage(pageRef);
            
        ApexPages.StandardController standarController = new ApexPages.StandardController(Order_rec);
        orderController = new OrderFormController(standarController);
        
        deliveryScheduleController = new DeliverySchedulerComponentController();
        OrderController.childComponentController = deliveryScheduleController;
        wrapper = deliveryScheduleController.wrapper;
    
    
    }
    
    public static testMethod void testDeliveryScheduleDateValidation() {
    	prepareBasicTestData();
        wrapper.deliverySchedule.Year__c = '2014';
        wrapper.deliverySchedule.Month__c='November';
        
        Test.startTest();
        List<Apexpages.Message> messageList = new List<ApexPages.Message>();
        OrderFormControllerErrorHandler errorHandler = new OrderFormControllerErrorHandler(orderController, messageList);
        errorHandler.processErrorAndWarningMessages();
        
        boolean containsDueDateSaveError = false;
        String dueDateErrorStringForDecember = 'Delivery Schedule Month should be December 2014 (Four months from the Order Month).';
        boolean hasErrorMessages = false;
        for(ApexPages.Message errMessage : messageList) 
        {
            if(errMessage!=null && errMessage.getSeverity()==ApexPages.Severity.Error && (errMessage.getDetail().equalsIgnoreCase(dueDateErrorStringForDecember))) 
            {
                containsDueDateSaveError = true;
            }
        
        }
        System.assertEquals(containsDueDateSaveError,true);
        Test.stopTest(); 
    }
    
    
    public static testMethod void testQuantityOfPaletteSizeValidation() {
    	Test.startTest();
        prepareBasicTestData();
        orderController.OIS = createSampleOIList();
        
        List<Apexpages.Message> messageList = new List<ApexPages.Message>();
        OrderFormControllerErrorHandler errorHandler = new OrderFormControllerErrorHandler(orderController, messageList);
        
        errorHandler.processErrorAndWarningMessages();
        
        boolean containsDueDateSaveError = false;
		String errorMsg2 = 'Quantity entered is not multiple of palette size (896) for the Product Type : Product-2.';
		String errorMsg3 = 'Quantity entered is not multiple of palette size (896) for the Product Type : Product-3.';
		String errorMsg4 = 'Quantity entered is not multiple of palette size (896) for the Product Type : Product-4.';
        boolean hasErrorMessage2 = false;
        boolean hasErrorMessage3 = false;
        boolean hasErrorMessage4 = false;
        for(ApexPages.Message errMessage : messageList) 
        {
            if(errMessage!=null && errMessage.getSeverity()==ApexPages.Severity.Info && (errMessage.getDetail().equalsIgnoreCase(errorMsg2))) 
            {
                hasErrorMessage2 = true;
            }
             if(errMessage!=null && errMessage.getSeverity()==ApexPages.Severity.Info && (errMessage.getDetail().equalsIgnoreCase(errorMsg3))) 
            {
                hasErrorMessage3 = true;
            }
             if(errMessage!=null && errMessage.getSeverity()==ApexPages.Severity.Info && (errMessage.getDetail().equalsIgnoreCase(errorMsg4))) 
            {
                hasErrorMessage4 = true;
            }
        
        }
        System.assertEquals(hasErrorMessage2,true);
        System.assertEquals(hasErrorMessage3,true);
        System.assertEquals(hasErrorMessage4,true);
        
        Test.stopTest(); 
    }
    
    private static List<AbstractParentController.OI> createSampleOIList() 
    {   
    	List<AbstractParentController.OI> prodList = new List<AbstractParentController.OI>();
    	for(Integer index=0;index<4;index++) 
    	{   
    		Product2 prod = new Product2();
    		AbstractParentController.OI prodObj = new AbstractParentController.OI(prod);
    		prodObj.Name = 'Product-'+(index+1);
    		prodObj.OrdItem.Quantity = index*100;
    		prodList.add(prodObj);
    	}
    	return prodList;
    }
    
    public static testMethod void testProcessDueDatewithInDeliverySchedule()
    {    
    	prepareBasicTestData();
        String errorMessage2 = 'Due date should be within the delivery schedule month (December 2014) for Consignment - 2.';
        String errorMessage4 = 'Due date should be within the delivery schedule month (December 2014) for Consignment - 4.';
        
        List<Consignment__c> consignmentList = wrapper.consignments;
        Consignment__c secondConsignment = consignmentList.get(1);
        Consignment__c fourthConsignment = consignmentList.get(3);
        
        (consignmentList.get(0)).Due__c = Datetime.newInstance(2015,
                                                      01,
                                                       2,
                                                       9,0,0);
        (consignmentList.get(2)).Due__c = Datetime.newInstance(2015,
                                                      01,
                                                       2,
                                                       9,0,0);
        secondConsignment.Due__c =  Datetime.newInstance(2015,
                                                      02,
                                                       2,
                                                       9,0,0);     
        
        fourthConsignment.Due__c =  Datetime.newInstance(2014,
                                                      11,
                                                       11,
                                                       9,0,0);
        
        setValidQuantityForConsignment(secondConsignment);                                               
        setValidQuantityForConsignment(fourthConsignment);
        List<Apexpages.Message> messageList = new List<ApexPages.Message>();
        System.debug('====After======');
        OrderFormControllerErrorHandler errorHandler = new OrderFormControllerErrorHandler(orderController, messageList);
        errorHandler.processErrorAndWarningMessages();
        Test.startTest();
        boolean hasErrorMessage2 = false;
        boolean hasErrorMessage4 = false;
        
         for(ApexPages.Message errMessage : messageList)  
        {
            if(errMessage!=null && errMessage.getSeverity()==ApexPages.Severity.Error && (errMessage.getDetail().equalsIgnoreCase(errorMessage2))) 
            {
                hasErrorMessage2 = true;
            }
            if(errMessage!=null && errMessage.getSeverity()==ApexPages.Severity.Error && (errMessage.getDetail().equalsIgnoreCase(errorMessage4))) 
            {
                hasErrorMessage4 = true;
            }
        
        }
        System.assertEquals(hasErrorMessage2,true);
        System.assertEquals(hasErrorMessage4,true);
       
        Test.stopTest();
          
   }
   
   private static void setValidQuantityForConsignment(Consignment__c consignment) 
   {
   	     
   	    
   		List<ConsignmentItem__c> consignmentList = wrapper.items.get((consignment.Position__c).intValue());
   	    consignmentList.get(0).Quantity__c = 3;
   
   }
   
   
    public static testMethod void testProcessDueDatewithInWorkingHours()
    {    
    	prepareBasicTestData();      
        String errorMessage2 = 'Due time must be within the working hours (between 7:00 and 17:00) for Consignment - 2';
        String errorMessage4 = 'Due time must be within the working hours (between 7:00 and 17:00) for Consignment - 4';
        
        List<Consignment__c> consignmentList = wrapper.consignments;
        Consignment__c secondConsignment = consignmentList.get(1);
        Consignment__c fourthConsignment = consignmentList.get(3);
        
        
        DateTime dateTimeVal = 
        
        (consignmentList.get(0)).Due__c = Datetime.newInstance(2015,
                                                      01,
                                                       2,
                                                       9,0,0);
        (consignmentList.get(2)).Due__c = Datetime.newInstance(2015,
                                                      01,
                                                       2,
                                                       9,0,0);
        secondConsignment.Due__c =  Datetime.newInstance(2015,
                                                      02,
                                                       2,
                                                       6,0,0);     
        
        fourthConsignment.Due__c =  Datetime.newInstance(2014,
                                                      11,
                                                       11,
                                                       20,0,0);
        
        setValidQuantityForConsignment(secondConsignment);                                               
        setValidQuantityForConsignment(fourthConsignment);
        List<Apexpages.Message> messageList = new List<ApexPages.Message>();
        OrderFormControllerErrorHandler errorHandler = new OrderFormControllerErrorHandler(orderController, messageList);
        errorHandler.processErrorAndWarningMessages();
        Test.startTest();
        boolean hasErrorMessage2 = false;
        boolean hasErrorMessage4 = false;
         for(ApexPages.Message errMessage : messageList)  
        {
            if(errMessage!=null && errMessage.getSeverity()==ApexPages.Severity.Error && (errMessage.getDetail().equalsIgnoreCase(errorMessage2))) 
            {
                hasErrorMessage2 = true;
            }
            if(errMessage!=null && errMessage.getSeverity()==ApexPages.Severity.Error && (errMessage.getDetail().equalsIgnoreCase(errorMessage4))) 
            {
                hasErrorMessage4 = true;
            }
        
        }
        System.assertEquals(hasErrorMessage2,true);
        System.assertEquals(hasErrorMessage4,true);
       
        Test.stopTest();
          
   }
   
    
    public static testMethod void testProcessDueDatewithInWorkingDays()
    {    
    	prepareBasicTestData(); 
        String errorMessage2 = 'Due Date cannot be on Saturday for Consignment - 2';
        String errorMessage4 = 'Due Date cannot be on Sunday for Consignment - 4';
          
        List<Consignment__c> consignmentList = wrapper.consignments;
        Consignment__c secondConsignment = consignmentList.get(1);
        Consignment__c fourthConsignment = consignmentList.get(3);
        
        
        DateTime dateTimeVal = 
        
        (consignmentList.get(0)).Due__c = Datetime.newInstance(2015,
                                                      01,
                                                       2,
                                                       9,0,0);
        (consignmentList.get(2)).Due__c = Datetime.newInstance(2015,
                                                      01,
                                                       2,
                                                       9,0,0);
        secondConsignment.Due__c =  Datetime.newInstance(2015,
                                                      01,
                                                       10,
                                                       6,0,0);     
        
        fourthConsignment.Due__c =  Datetime.newInstance(2015,
                                                      01,
                                                       11,
                                                       20,0,0);
        
        setValidQuantityForConsignment(secondConsignment);                                               
        setValidQuantityForConsignment(fourthConsignment);
        List<Apexpages.Message> messageList = new List<ApexPages.Message>();
        OrderFormControllerErrorHandler errorHandler = new OrderFormControllerErrorHandler(orderController, messageList);
        errorHandler.processErrorAndWarningMessages();
        Test.startTest();
        boolean hasErrorMessage2 = false;
        boolean hasErrorMessage4 = false;
         for(ApexPages.Message errMessage : messageList)  
        {
            if(errMessage!=null && errMessage.getSeverity()==ApexPages.Severity.Error && (errMessage.getDetail().equalsIgnoreCase(errorMessage2))) 
            {
                hasErrorMessage2 = true;
            }
            if(errMessage!=null && errMessage.getSeverity()==ApexPages.Severity.Error && (errMessage.getDetail().equalsIgnoreCase(errorMessage4))) 
            {
                hasErrorMessage4 = true;
            }
        
        }
        System.assertEquals(hasErrorMessage2,true);
        System.assertEquals(hasErrorMessage4,true);
       
        Test.stopTest();
          
   }
   
   
   
    
    public static testMethod void testProcessDueDateOnSameDateAndTimeForTwoConsignments()
    {    
    
        prepareBasicTestData(); 
                                     
        String errorMessageString = 'Due date time cannot be same for Consignment - 2 and Consignment- 4.';
        
        List<Consignment__c> consignmentList = wrapper.consignments;
        Consignment__c secondConsignment = consignmentList.get(1);
        Consignment__c fourthConsignment = consignmentList.get(3);
        
        
        DateTime dateTimeVal = 
        
        (consignmentList.get(0)).Due__c = Datetime.newInstance(2015,
                                                      01,
                                                       2,
                                                       9,0,0);
        (consignmentList.get(2)).Due__c = Datetime.newInstance(2015,
                                                      01,
                                                       2,
                                                       9,0,0);
        secondConsignment.Due__c =  Datetime.newInstance(2015,
                                                      01,
                                                       2,
                                                       16,0,0);     
        
        fourthConsignment.Due__c =  Datetime.newInstance(2015,
                                                       01,
                                                       2,
                                                       16,0,0); 
        
        setValidQuantityForConsignment(secondConsignment);                                               
        setValidQuantityForConsignment(fourthConsignment);
        List<Apexpages.Message> messageList = new List<ApexPages.Message>();
        
       
        OrderFormControllerErrorHandler errorHandler = new OrderFormControllerErrorHandler(orderController, messageList);
        errorHandler.processErrorAndWarningMessages();
         
        Test.startTest();
          
        boolean hasErrorMessage = false;
        for(ApexPages.Message errMessage : messageList)  
        {   
        	if(errMessage!=null && errMessage.getSeverity()==ApexPages.Severity.Error && (errMessage.getDetail().equalsIgnoreCase(errorMessageString))) 
            {
            	hasErrorMessage = true;
            }
         }
        System.assertEquals(hasErrorMessage,true);
        Test.stopTest();
          
   }
   
   static testMethod void testDeliverySchedulerComponentController() {
       
        prepareBasicTestData();
        deliveryScheduleController.parentController = orderController;
        
        boolean saved = deliveryScheduleController.save();
        boolean amend = deliveryScheduleController.amend();
         	
        apexpages.Message message = new Apexpages.Message(ApexPages.Severity.Error,'Test');
        Apexpages.addMessage(message);
        system.assertEquals(true, deliveryScheduleController.hasErrorMessages);
        
    }
 }