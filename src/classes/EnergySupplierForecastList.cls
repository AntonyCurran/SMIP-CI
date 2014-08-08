Public class EnergySupplierForecastList 
{
    private Account accountToRestrict {get; set;}
    public String accountName {get; set;}
    public List<Forecast_Header__c> forecastHeader {get;set;}
    public Id forecastHeaderId {get; set;}
    
    public EnergySupplierForecastList (ApexPages.StandardController ctlr)
    {
        retrieveCurrentUserAccount();
        
        getForecastHeader();
        
    }
    
    public pageReference createNewForecast ()
    {
        PageReference pageRef = new PageReference('/apex/CreateForecast');
        
        return pageRef;
    }
    
    public pageReference view ()
    {
        PageReference pageRef = new PageReference('/apex/ViewForecast?id='+forecastHeaderId);
        
        return pageRef;
    }
    
    private void retrieveCurrentUserAccount ()
    {
        try 
        { 
            accountToRestrict = UserHelper.getAccountByName(UserHelper.getGroupName(UserHelper.getEnergySupplierGroupMembership()));  
            accountName = accountToRestrict.Name;
            system.debug('accountToRestrict = '+accountToRestrict);
        }
        catch (QueryException e) 
        {
            accountName = 'All Energy Supplier';
        } 
    }
    
    //public List<Forecast_Header__c> getForecastHeader ()
    public void getForecastHeader ()
    {
        try 
        { 
            if(accountToRestrict != null)
            {
                forecastHeader = [SELECT Name, Status__c, Forecast_Month__c, LastModifiedDate, Account__c
                                  FROM Forecast_Header__c
                                  WHERE Account__c = :accountToRestrict.Id];
            }
            else
            {
                // another query will bring back all supplier Forecasts
                forecastHeader = [SELECT Name, Status__c, Forecast_Month__c, LastModifiedDate, Account__c
                                  FROM Forecast_Header__c
                                  ];
            }
                                
            
        }
        catch (QueryException e) 
        {
            // now what?
        }
        
    }  
}