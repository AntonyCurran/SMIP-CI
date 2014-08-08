/*
Type Name:        class AggregatedForecastWrapper
Author:           MJ
Created Date:     08-August-2014
Reason:           This class is a wrapper class for  Aggregated Forecast.
					it holds selected row index, aggregated list and energy supplier forecastlist.
*/
public class AggregatedForecastWrapper { 
	
	public   integer               			    selectedRowIndex          {get;set;}
	public   List<AggregatedForecastListRow> 	aggregatedList            {get;set;}
	public   List<Energy_Supplier_Forecast__c>  energySupplierForecastList = new List<Energy_Supplier_Forecast__c>();
	//Constructor for initializing the fields.
	public AggregatedForecastWrapper() 
	{
		aggregatedList = new List<AggregatedForecastListRow>();
		selectedRowIndex = 0;
	} 
	// returns row object at slected row index.
	public AggregatedForecastListRow getSelectedRow() 
	{
	    return aggregatedList.get(selectedRowIndex);
	}
}