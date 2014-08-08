public class AggregatedDetailedForecastWrapper { 
	public List<AggregateDetailedForecastSubmittedRow> engerySupplierSubmittedNotSubmittedList  {get;set;} 
	public   List<Energy_Supplier_Forecast__c>  energySupplierForecastList 		= new List<Energy_Supplier_Forecast__c>();
	List<Account> 								accountList                		= new List<Account>();
	List<Account> 								ForecastSubmittedAccountList    = new List<Account>();  
	
	public String 								forecastMonthYear 					{get;set;}
  
	public AggregatedDetailedForecastWrapper() 
	{
		engerySupplierSubmittedNotSubmittedList = new List<AggregateDetailedForecastSubmittedRow>();
		
	} 	 

}