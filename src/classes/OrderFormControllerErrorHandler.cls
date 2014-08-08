/*
Type Name:        class OrderFormControllerErrorHandler
Author:           MJ
Created Date:     01-August-2014
Reason:           This class is for Validation Messages for OrderForm.
*/

public class OrderFormControllerErrorHandler {
    /*
        Private Inner Class for holding the product type, ordered and consolidated Quantity.
    */
    private class OrderedAndConsolidatedQuantity 
    {   
        String productType {get;set;} 
        Double orderedQuantity {get;set;} 
        Double consolidatedQuntityForConsignment {get;set;}     
        String productName {get;set;}
        //Constructor to pass product type, product name , quantity and consolidated quantity. 
        public OrderedAndConsolidatedQuantity(String ptype, String prodName, Decimal oQuantity, Decimal consQuantity) 
        {
            productType = ptype;
            orderedQuantity = oQuantity;
            consolidatedQuntityForConsignment = consQuantity;
            productName = prodName;
        }    
    }
    
    public order                                Order_rec                                    {get;set;}
    public DeliveryScheduleWrapper              wrapper                                      {get;set;}
    public AbstractComponentController          childComponentController                     {get;set;} 
    public AbstractParentController             orderController                              {get;set;}
    public Date                                 expectedDeliveryScheduleStartDate            {get;set;}
    public Date                                 expectedDeliveryScheduleMonthEndDate         {get;set;}
    public Date                                 expectedDeliveryScheduleMonthCutoffDate      {get;set;}
    public List<Apexpages.Message>              messageList                                  {get;set;}
    public Set<Integer>                         invalidConsignmentsSet                       {get;set;}
    public List<Consignment__c>                 validConsignments                            {get;set;}
    private DateHelper                          dateHelperObj = new DateHelper();
     
    // Constructor for passing the order controller and message list.
    public OrderFormControllerErrorHandler(AbstractParentController orderController,List<Apexpages.Message> messageList) 
    {
        this.childComponentController = orderController.childComponentController;
        this.orderController = orderController;
        this.Order_rec = orderController.getOrderRecord(); 
        this.wrapper = ((DeliverySchedulerComponentController) orderController.childComponentController).wrapper;
        this.messageList = messageList;
        initData();
        
    }
    // Method for validating all the error and warning messages.   
    public void processErrorAndWarningMessages() 
    {
        validateDeliveryScheduleDateForErrors();
        validateConsignmentDueDateForErrors();
        validateIfConsignmentDueDateOnWeekend(); 
        validateIfDueDateTimeInWorkingHours();
        validateConsignmentDueDateForInformation();
        validateIfDueDatesAreonSameDateAndSameTime();
        validateIfQuantityMultipleOfPaletteSize();
        validateIfQuantityMultipleOfPaletteSizeForConsignments();
        validateErrorForConsolidateHubsAgainstQuantity();
    }
   
   // private method for initializing all the required data.
    private void initData() 
    {
        Date effectiveDate = order_rec.EffectiveDate;
        Date expectedDeliveryScheduleDate = effectiveDate.addMonths(5);
         
        expectedDeliveryScheduleStartDate       = expectedDeliveryScheduleDate;
        expectedDeliveryScheduleMonthEndDate    = expectedDeliveryScheduleDate;
        expectedDeliveryScheduleMonthCutoffDate = expectedDeliveryScheduleDate; 
        prepareValidConsignments();
        expectedDeliveryScheduleStartDate = Date.newInstance(expectedDeliveryScheduleDate.year(), expectedDeliveryScheduleDate.month(), 1);
        Date deliveryScheduleNextMonth = expectedDeliveryScheduleStartDate.addMonths(1).toStartOfMonth();
        
        expectedDeliveryScheduleMonthEndDate = deliveryScheduleNextMonth.addDays(-1);
        expectedDeliveryScheduleMonthCutoffDate = expectedDeliveryScheduleMonthEndDate.addDays(-5);
    }
    
    //To prepare the valid consignments.
    private void prepareValidConsignments() 
    {
        validConsignments = new List<Consignment__c>();
        Map<Integer, List<ConsignmentItem__c>> consignmentItemMap = wrapper.items; 
        invalidConsignmentsSet = new Set<Integer>();
        for(Integer consignmentNo : consignmentItemMap.keySet()) 
        {
            boolean nonZeroFound = false;
            for(ConsignmentItem__c consItem : consignmentItemMap.get(consignmentNo)) 
            {
                if(consItem.Quantity__c!=0) 
                {
                    nonZeroFound = true;
                }
            }
            if(!nonZeroFound) 
            {    
                invalidConsignmentsSet.add(consignmentNo);
            }
        }
        List<Consignment__c> consignments = wrapper.consignments;
        for(Consignment__c consignment : consignments) 
        {
            if(!invalidConsignmentsSet.contains((consignment.Position__c).intValue())) 
            {
                validConsignments.add(consignment);
            }
        }
    }
    
    
    //Validation Rule (Error)- delivery scheule date should be 5 months after ordered date.  
    public void validateDeliveryScheduleDateForErrors() 
    {
        Integer enteredDeliveryYear = Integer.valueOf(wrapper.deliverySchedule.year__c);
        Integer enteredDeliveryMonth = dateHelperObj.getIndexOfMonth(wrapper.deliverySchedule.Month__c);
        
        Integer exptedDeliverySchedulMonthIntVal = expectedDeliveryScheduleStartDate.month();
        Integer exptedDeliverySchedulyearIntVal = expectedDeliveryScheduleStartDate.year();
        String exptedDeliveryDateMonthStringVal = dateHelperObj.nameOfMonth(expectedDeliveryScheduleStartDate);
        if((enteredDeliveryMonth!=exptedDeliverySchedulMonthIntVal) || (enteredDeliveryYear!=exptedDeliverySchedulYearIntVal)) 
        {
             apexpages.Message message = new Apexpages.Message(ApexPages.Severity.Error,'Delivery Schedule Month should be '+exptedDeliveryDateMonthStringVal+' '+exptedDeliverySchedulYearIntVal+' (Four months from the Order Month).');
             messageList.add(message);  
        }
        
    }
    
   //Validation Rule (Warning)- ordered quantity should be multiple of Palette size.  
    public void validateIfQuantityMultipleOfPaletteSize() 
    {
        for(AbstractParentController.OI prodObj :  orderController.getOIList()) 
        {   
            integer modValue = 0;
            if(prodObj!=null && prodObj.OrdItem.quantity!=null) 
            {
                modValue = MATH.MOD(Integer.valueOf(prodObj.OrdItem.quantity),896); 
            }
            if(modValue!=0) 
            {   
            	apexpages.Message message = new Apexpages.Message(ApexPages.Severity.info,'Quantity entered is not multiple of palette size (896) for the Product Type : '+prodObj.Name+'.');
                messageList.add(message); 
                
            }
         }
      }
    
    
   //Validation Rule (Error)- validate due dates of consignments - due date should be within the delivery scheudle month.  
    public void validateConsignmentDueDateForErrors() 
    {
        Integer exptedDeliverySchedulMonthIntVal = expectedDeliveryScheduleStartDate.month();
        Integer exptedDeliverySchedulyearIntVal = expectedDeliveryScheduleStartDate.year();
        String exptedDeliveryDateMonthStringVal = dateHelperObj.nameOfMonth(expectedDeliveryScheduleStartDate);
        for(Consignment__c consignment : validConsignments) 
        {
            DateTime consignmentDate =  consignment.Due__c; 
            if((ConsignmentDate < expectedDeliveryScheduleStartDate) || (ConsignmentDate > expectedDeliveryScheduleMonthEndDate)) 
            {
                apexpages.Message message = new Apexpages.Message(ApexPages.Severity.Error,'Due date should be within the delivery schedule month ('+exptedDeliveryDateMonthStringVal+' '+exptedDeliverySchedulYearIntVal+') for Consignment - '+consignment.Position__c.intValue()+'.');
                messageList.add(message); 
            }
        
        }
    }
        
   //Validation Rule (Info)- Quantity in the consignment should be multiple of palette size.  
    private void validateIfQuantityMultipleOfPaletteSizeForConsignments()
    {
        for(Consignment__c consignment : validConsignments) 
        {   
            for(ConsignmentItem__c item: wrapper.items.get((consignment.Position__c).intValue())) 
            {
                Double modValue = MATH.MOD(Integer.valueOf(item.Quantity__c),896); 
                if(modValue!=0) 
                {   System.debug('====OrderFormControllerHelper=====144==='+item);
                    apexpages.Message message = new Apexpages.Message(ApexPages.Severity.info,'Quantity entered is not multiple of palette size (896) for the Product Type : '+item.Product__r.name+', for the Consignment - '+consignment.Position__c+'.');
                    messageList.add(message); 
                }
            }
        }
    }
    
   //Validation Rule (Info)- due date for the consignment cannot be within last 5 days of the month.  
    private void validateConsignmentDueDateForInformation() 
    {
        for(Consignment__c consignment : validConsignments) 
        {
            Date ConsignmenDate = (consignment.Due__c).date();
            if(ConsignmenDate > expectedDeliveryScheduleMonthCutoffDate)
            {
                apexpages.Message message = new Apexpages.Message(ApexPages.Severity.Info,'Due date cannot be in last Five days of the month for Consignment - '+consignment.Position__c.intValue()+'.');
                messageList.add(message); 
            }
        } 
    }
    
   //Validation Rule (Error)- consolidated quantity for all consignments product type should match ordered quantity for the product type.  
    public void validateErrorForConsolidateHubsAgainstQuantity() 
    {
        Map<String, Double> prodTypeQuantityMap = new Map<String, Double>();
        Map<String, OrderedAndConsolidatedQuantity> orderedAndConsolidatedQuantityMap = new  Map<String, OrderedAndConsolidatedQuantity>();
       
        for(AbstractParentController.OI prodObj :  orderController.getOIList()) 
        { 
            OrderedAndConsolidatedQuantity orderedConsolidatedQtyObj =new OrderedAndConsolidatedQuantity(prodObj.productId, prodObj.name, prodObj.OrdItem.quantity,0.0);
            orderedAndConsolidatedQuantityMap.put(prodObj.productId, orderedConsolidatedQtyObj );
        }    
        
        List<ConsignmentItem__c> fullConsignmentItemList = new List<ConsignmentItem__c>(); 
        Set<Integer> consignmentKeySet = wrapper.items.keySet();
        for(Integer index: consignmentKeySet) 
        {
            fullConsignmentItemList.addAll(wrapper.items.get(index));
            
        }
        for(ConsignmentItem__c consignmentItem : fullConsignmentItemList)
        {
            OrderedAndConsolidatedQuantity orderedConsolidatedQtyObj = orderedAndConsolidatedQuantityMap.get(consignmentItem.Product__c);
            if(orderedConsolidatedQtyObj!=null) 
            {
                orderedConsolidatedQtyObj.consolidatedQuntityForConsignment = orderedConsolidatedQtyObj.consolidatedQuntityForConsignment + consignmentItem.Quantity__c;
            }
        }
        Set<String> prodTypeSet = orderedAndConsolidatedQuantityMap.keySet();
        for(String prodType: prodTypeSet) 
        {
            OrderedAndConsolidatedQuantity orderedConsolidatedQtyObj = orderedAndConsolidatedQuantityMap.get(prodType);
            if(orderedConsolidatedQtyObj.orderedQuantity != orderedConsolidatedQtyObj.consolidatedQuntityForConsignment)
            {
                apexpages.Message message = new Apexpages.Message(ApexPages.Severity.Error,'Total Delivery Quantity doesnt match the Ordered Quantity for the Product Type : '+orderedConsolidatedQtyObj.productName+'.');
                messageList.add(message); 
            }
            
        }
   } 
   
   //Validation Rule (Error)- due dates can not be on weekend - saturday or sunday.  
   public void validateIfConsignmentDueDateOnWeekend() 
   {   
   	   for(Consignment__c consignment : validConsignments)
        {   
            String threeLetterWeekDay = consignment.Due__c.format('E'); 
            if(threeLetterWeekDay.equalsIgnoreCase('SAT')) 
            {
                apexpages.Message message = new Apexpages.Message(ApexPages.Severity.Error,'Due Date cannot be on Saturday for Consignment - '+consignment.Position__c);
                messageList.add(message); 
            
            }
            if(threeLetterWeekDay.equalsIgnoreCase('SUN')) 
            {
                apexpages.Message message = new Apexpages.Message(ApexPages.Severity.Error,'Due Date cannot be on Sunday for Consignment - '+consignment.Position__c);
                messageList.add(message); 
            }
        }
   }  
     
   //Validation Rule (Error)- due dates time should be working hours between 07 Hours and 17 Hours.  
   public void validateIfDueDateTimeInWorkingHours() 
   {    
        for(Consignment__c consignment : validConsignments)
        {   
            
            DateTime consignmentDueTime = consignment.Due__c;
            
            DateTime workStartTime = DateTime.newInstance(consignmentDueTime.year(),
                                                          consignmentDueTime.month(),
                                                          consignmentDueTime.day(),
                                                          7,0,0);
                                                          
            DateTime workEndTime = DateTime.newInstance(consignmentDueTime.year(),
                                                          consignmentDueTime.month(),
                                                          consignmentDueTime.day(),
                                                          17,0,0);
            Long differenceWithStartTime = consignmentDueTime.getTime() - workStartTime.getTime();
            Long differenceWithWorkEndTime = workEndTime.getTime() - consignmentDueTime.getTime();
            if(differenceWithStartTime<0 || differenceWithWorkEndTime < 0 ) 
            {    
                
                apexpages.Message message = new Apexpages.Message(ApexPages.Severity.Error,'Due time must be within the working hours (between 7:00 and 17:00) for Consignment - '+consignment.Position__c);
                messageList.add(message); 
            }   
        }

   }
   
   //Validation Rule (Error)- due dates can be Same Date, but not same time.  
   public void validateIfDueDatesAreonSameDateAndSameTime() 
   {    
   		for(Integer index=0; index<validConsignments.size();index++) 
        {
        	for(Integer nextIndex=index+1; nextIndex<validConsignments.size();nextIndex++) 
        	{
        		Consignment__c consignment      = validConsignments.get(index);
        		Consignment__c nextConsignment  = validConsignments.get(nextIndex);
        		
        		if((consignment.Due__c)==(nextConsignment.Due__c)) 
        		{
        			apexpages.Message message = new Apexpages.Message(ApexPages.Severity.Error,'Due date time cannot be same for Consignment - '+consignment.Position__c+' and Consignment- '+nextConsignment.Position__c+'.');
                	messageList.add(message); 
        		}
        	}
        }
   } 
}