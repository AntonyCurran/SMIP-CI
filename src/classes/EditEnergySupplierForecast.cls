public with sharing class EditEnergySupplierForecast 
{
 public List<Energy_Supplier_Forecast__c> supplierForecast {get;set;}
    public Id forecastId {get;set;}
    public Energy_Supplier_Forecast__c monthDisplay {get;set;}
    public Boolean submitted {get;set;}
    private Forecast_Header__c forecastHeader {get;set;}
    DateHelper dateHelper = new DateHelper();
    
    public PageReference Submit()
    {
        PageReference pageRef = new PageReference('/a0A/o');
        //submit logic here
        if(forecastHeader.Status__c == 'Created')
        {
            forecastHeader.Status__c = 'Submitted';
            forecastHeader.Forecast_Submitted_Month__c = dateHelper.nameOfMonth(System.today());
        }
        //additional checks?
        
        update forecastHeader;
        pageRef.setRedirect(True);
        return pageRef;
    }
    
    public PageReference Cancel()
    {
        PageReference pageRef = new PageReference('/a0A/o');
        pageRef.setRedirect(True);
        return pageRef;
    }
    
    public PageReference Save()
    {
        PageReference pageRef = new PageReference('/a0A/o');
        pageRef.setRedirect(True);
        //put some save stuff here
        update supplierForecast;
        return pageRef;
    }
    
    public Boolean getSubmitState()
    {
        If(forecastHeader.Status__c == 'Submitted')
        {
            submitted=true;
        }
        else
        {
        	submitted=false;
        }
        return submitted;	
    }
        
    public EditEnergySupplierForecast(ApexPages.StandardController controller)
    {
        
        forecastId = ApexPages.currentPage().getParameters().get('Id');
        
        // get the header status
        try
        {
        	forecastHeader = [SELECT Status__c
                              FROM Forecast_Header__c
                              WHERE id = :forecastId];
        }
        catch (QueryException e) 
        {
            //handle this here
        }
                                  
        try 
        { 
            supplierForecast = [SELECT e.Previous_Month_9__c, e.Previous_Month_8__c, e.Previous_Month_7__c, e.Previous_Month_6__c, 
                                       e.Previous_Month_5__c, e.Previous_Month_4__c, e.Previous_Month_3__c, e.Previous_Month_2__c, 
                                       e.Previous_Month_24__c, e.Previous_Month_23__c, e.Previous_Month_22__c, e.Previous_Month_21__c, 
                                       e.Previous_Month_20__c, e.Previous_Month_1__c, e.Previous_Month_19__c, e.Previous_Month_18__c, 
                                       e.Previous_Month_17__c, e.Previous_Month_16__c, e.Previous_Month_15__c, e.Previous_Month_14__c, 
                                       e.Previous_Month_13__c, e.Previous_Month_12__c, e.Previous_Month_11__c, e.Previous_Month_10__c, 
                                       e.Month_9__c, e.Month_8__c, e.Month_7__c, e.Month_6__c, e.Month_5__c, e.Month_4__c, e.Month_3__c, 
                                       e.Month_2__c, e.Month_24__c, e.Month_23__c, e.Month_22__c, e.Month_21__c, e.Month_20__c, 
                                       e.Month_1__c, e.Month_19__c, e.Month_18__c, e.Month_17__c, e.Month_16__c, e.Month_15__c, 
                                       e.Month_14__c, e.Month_13__c, e.Month_12__c, e.Month_11__c, e.Month_10__c, e.Forecast_Header__c, 
                                       e.Energy_Supplier__c, e.Current_Month_9__c, e.Current_Month_8__c, e.Current_Month_7__c, 
                                       e.Current_Month_6__c, e.Current_Month_5__c, e.Current_Month_4__c, e.Current_Month_3__c, 
                                       e.Current_Month_2__c, e.Current_Month_24__c, e.Current_Month_23__c, e.Current_Month_22__c, 
                                       e.Current_Month_21__c, e.Current_Month_20__c, e.Current_Month_1__c, e.Current_Month_19__c, 
                                       e.Current_Month_18__c, e.Current_Month_17__c, e.Current_Month_16__c, e.Current_Month_15__c, 
                                       e.Current_Month_14__c, e.Current_Month_13__c, e.Current_Month_12__c, e.Current_Month_11__c, 
                                       e.Current_Month_10__c, e.Comm_Hub_Variant__c 
                                 FROM Energy_Supplier_Forecast__c e
                                 WHERE e.Forecast_Header__c = :forecastId];
          
           getSubmitState();
           monthDisplay = supplierForecast.get(0);               
        }
        catch (QueryException e) 
        {
            //handle this here
        }
        
    }
}