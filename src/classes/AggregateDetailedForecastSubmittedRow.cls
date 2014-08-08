public class AggregateDetailedForecastSubmittedRow {
		public Account     energySupplierAccount     			{get;set;}
		public Region__c   energySupplierRegion  	    		{get;set;}
		public String      energySupplierAccountDisplayValue    {get;set;}
		public String      energySupplierRegionDisplayValue     {get;set;}
        public String      forecastMonthYear                    {get;set;}
        public Boolean     submittedForecast                    {get;set;}
        public String      submittedForecastDisplayValue        {get {
        				if(submittedForecast) {
        					return 'SUBMITTED';
        				}
        				return 'NOT SUBMITTED';
        }}
        
        public AggregateDetailedForecastSubmittedRow( Account    energySupplierAccount,
													 Region__c  energySupplierRegion,		
													 String     forecastMonthYear,                    
        											 Boolean     submittedForecast) 
        {
        	this.energySupplierAccount = energySupplierAccount;
        	this.energySupplierRegion  = energySupplierRegion;
        	this.forecastMonthYear     = forecastMonthYear;
        	this.submittedForecast     = submittedForecast;
            this.energySupplierAccountDisplayValue = 'Sample Account';
            this.energySupplierRegionDisplayValue  = 'Sample Region';
            submittedForecast = false;
        
        
        }

}