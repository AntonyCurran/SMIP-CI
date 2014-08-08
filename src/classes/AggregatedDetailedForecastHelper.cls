public class AggregatedDetailedForecastHelper {
		// Aggregated Forecast Wrapper.
	public  AggregatedDetailedForecastWrapper wrapper      {get;set;}
    // Date helper.
    private DateHelper                dateHelper = new DateHelper();
    
    // method to create aggregate forecast.
    public AggregatedDetailedForecastWrapper createAggregateDetailedForecast(String forecastMonthYear) 
    { 
    	wrapper = new AggregatedDetailedForecastWrapper();
    	wrapper.forecastMonthYear = forecastMonthYear;
    	loadDataToWrapper();
     	return wrapper;
    }
    // method to load data to wrapper.
    private void loadDataToWrapper() 
    {
    	loadEnerygyForecastList();
    	loadAggregatedDetailedForecastList();
    }
    // Method to prepaper Aggregate Forecast List.
    private void loadAggregatedDetailedForecastList() 
    {
    	List<AggregateDetailedForecastSubmittedRow> engerySupplierSubmittedNotSubmittedList = new List<AggregateDetailedForecastSubmittedRow>();
    	for(Integer index=0;index<10;++index) 
    	{
    		AggregateDetailedForecastSubmittedRow row = new AggregateDetailedForecastSubmittedRow(new Account(), new Region__c(), wrapper.forecastMonthYear, false);
    		engerySupplierSubmittedNotSubmittedList.add(row);
    	}
    	wrapper.engerySupplierSubmittedNotSubmittedList = engerySupplierSubmittedNotSubmittedList;
    		
    }	
    
    private void loadEnerygyForecastList() 
    {
    	String queryString = 'SELECT Comm_Hub_Variant__c,'+
										    'CreatedById,'+
										    'CreatedDate,'+
										    'Energy_Supplier__c,'+
										    'Forecast_Header__c,'+
										    'Id,  '+
										    'IsDeleted,'+
										    'LastModifiedById,'+
										    'LastModifiedDate,'+
										    'Name,'+
										    'OwnerId,'+
										    'Status__c,'+
										    'SystemModstamp,'+ 
										    
										    'Current_Month_1__c,Current_Month_2__c,Current_Month_3__c,'+
										    'Current_Month_4__c,Current_Month_5__c,Current_Month_6__c,'+
										    'Current_Month_7__c,Current_Month_8__c,Current_Month_9__c,'+
										    'Current_Month_10__c,Current_Month_11__c,Current_Month_12__c,'+
										    'Current_Month_13__c,Current_Month_14__c,Current_Month_15__c,'+
										    'Current_Month_16__c,Current_Month_17__c,Current_Month_18__c,'+
										    'Current_Month_19__c,Current_Month_20__c,Current_Month_21__c,'+
										    'Current_Month_22__c,Current_Month_23__c,Current_Month_24__c,'+
										    
										    
										    'Month_1__c,Month_2__c,Month_3__c,Month_4__c,Month_5__c,Month_6__c,'+
										    'Month_7__c,Month_8__c,Month_9__c,Month_10__c,Month_11__c,Month_12__c,'+
										    'Month_13__c,Month_14__c,Month_15__c,Month_16__c,Month_17__c,Month_18__c,'+
										    'Month_19__c,Month_20__c,Month_21__c,Month_22__c,Month_23__c,Month_24__c,'+
										    
										    'Previous_Month_1__c,Previous_Month_2__c,Previous_Month_3__c,Previous_Month_4__c,'+
										    'Previous_Month_5__c,Previous_Month_6__c,Previous_Month_7__c,Previous_Month_8__c,'+
										    'Previous_Month_9__c,Previous_Month_10__c,Previous_Month_11__c,Previous_Month_12__c,'+
										    'Previous_Month_13__c,Previous_Month_14__c,Previous_Month_15__c,Previous_Month_16__c,'+
										    'Previous_Month_17__c,Previous_Month_18__c,Previous_Month_19__c,Previous_Month_20__c,'+
										    'Previous_Month_21__c,Previous_Month_22__c,Previous_Month_23__c,Previous_Month_24__c'+
							' FROM Energy_Supplier_Forecast__c' + ' WHERE CreatedDate = THIS_MONTH';
	    wrapper.energySupplierForecastList = Database.query(queryString);
     }
    
    /*
    	List<AggregatedDetailedForecastListRow>  aggregatedList = new List<AggregatedDetailedForecastListRow>();
    	for(Energy_Supplier_Forecast__c forecastItem:   wrapper.energySupplierForecastList)  
    	{   
    		
    		if(forecastItem.Current_Month_1__c!=0) {
	    		addOrUpdateLastModifiedDate(forecastItem.lastmodifiedDate, aggregatedList,forecastItem.Month_1__c);
			}
	    	if(forecastItem.Current_Month_2__c!=0) {
	    		addOrUpdateLastModifiedDate(forecastItem.lastmodifiedDate, aggregatedList,forecastItem.Month_2__c);
	    	}
	    	if(forecastItem.Current_Month_3__c!=0) {
	    		addOrUpdateLastModifiedDate(forecastItem.lastmodifiedDate, aggregatedList,forecastItem.Month_3__c);
	    	}
	    	if(forecastItem.Current_Month_4__c!=0) {
	    		addOrUpdateLastModifiedDate(forecastItem.lastmodifiedDate, aggregatedList,forecastItem.Month_4__c);
	    	}
	    	if(forecastItem.Current_Month_5__c!=0) {
	    		addOrUpdateLastModifiedDate(forecastItem.lastmodifiedDate, aggregatedList,forecastItem.Month_5__c);
	    	}
	    	if(forecastItem.Current_Month_6__c!=0) {
	    		addOrUpdateLastModifiedDate(forecastItem.lastmodifiedDate, aggregatedList,forecastItem.Month_6__c);
	    	}
	    	if(forecastItem.Current_Month_7__c!=0) {
	    		addOrUpdateLastModifiedDate(forecastItem.lastmodifiedDate, aggregatedList,forecastItem.Month_7__c);
	    	}
	    	if(forecastItem.Current_Month_8__c!=0) {
	    		addOrUpdateLastModifiedDate(forecastItem.lastmodifiedDate, aggregatedList,forecastItem.Month_8__c);
	    	}
	    	if(forecastItem.Current_Month_9__c!=0) {
	    		addOrUpdateLastModifiedDate(forecastItem.lastmodifiedDate, aggregatedList,forecastItem.Month_9__c);
	    	}
	    	if(forecastItem.Current_Month_10__c!=0) {
	    		addOrUpdateLastModifiedDate(forecastItem.lastmodifiedDate, aggregatedList,forecastItem.Month_10__c);
	    	}
	    	
	    	if(forecastItem.Current_Month_11__c!=0) {
	    		addOrUpdateLastModifiedDate(forecastItem.lastmodifiedDate, aggregatedList,forecastItem.Month_11__c);
	    	}
	    	if(forecastItem.Current_Month_12__c!=0) {
	    		addOrUpdateLastModifiedDate(forecastItem.lastmodifiedDate, aggregatedList,forecastItem.Month_12__c);
	    	}
	    	if(forecastItem.Current_Month_13__c!=0) {
	    		addOrUpdateLastModifiedDate(forecastItem.lastmodifiedDate, aggregatedList,forecastItem.Month_13__c);
	    	}
	    	if(forecastItem.Current_Month_14__c!=0) {
	    		addOrUpdateLastModifiedDate(forecastItem.lastmodifiedDate, aggregatedList,forecastItem.Month_14__c);
	    	}
	    	if(forecastItem.Current_Month_15__c!=0) {
	    		addOrUpdateLastModifiedDate(forecastItem.lastmodifiedDate, aggregatedList,forecastItem.Month_15__c);
	    	}
	    	if(forecastItem.Current_Month_16__c!=0) {
	    		addOrUpdateLastModifiedDate(forecastItem.lastmodifiedDate, aggregatedList,forecastItem.Month_16__c);
	    	}
	    	if(forecastItem.Current_Month_17__c!=0) {
	    		addOrUpdateLastModifiedDate(forecastItem.lastmodifiedDate, aggregatedList,forecastItem.Month_17__c);
	    	}
	    	if(forecastItem.Current_Month_18__c!=0) {
	    		addOrUpdateLastModifiedDate(forecastItem.lastmodifiedDate, aggregatedList,forecastItem.Month_18__c);
	    	}
	    	if(forecastItem.Current_Month_19__c!=0) {
	    		addOrUpdateLastModifiedDate(forecastItem.lastmodifiedDate, aggregatedList,forecastItem.Month_19__c);
	    	}
	    	if(forecastItem.Current_Month_20__c!=0) {
	    		addOrUpdateLastModifiedDate(forecastItem.lastmodifiedDate, aggregatedList,forecastItem.Month_20__c);
	    	}
	    	if(forecastItem.Current_Month_21__c!=0) {
	    		addOrUpdateLastModifiedDate(forecastItem.lastmodifiedDate, aggregatedList,forecastItem.Month_21__c);
	    	}
	    	if(forecastItem.Current_Month_22__c!=0) {
	    		addOrUpdateLastModifiedDate(forecastItem.lastmodifiedDate, aggregatedList,forecastItem.Month_22__c);
	    	}
	    	if(forecastItem.Current_Month_23__c!=0) {
	    		addOrUpdateLastModifiedDate(forecastItem.lastmodifiedDate, aggregatedList,forecastItem.Month_23__c);
	    	}
	    	if(forecastItem.Current_Month_24__c!=0) {
	    		addOrUpdateLastModifiedDate(forecastItem.lastmodifiedDate, aggregatedList,forecastItem.Month_24__c);
	    	}
    		aggregatedList.sort();
    		setRowIndecesInWrapper();
    		wrapper.aggregatedList = aggregatedList; 
    	}
    }
    // Method to set row indices for aggregated list in the wrapper.
    private void setRowIndecesInWrapper() 
    {
    	Integer indexCounter = 0;
    	for(AggregatedDetailedForecastListRow rowElement : wrapper.aggregatedList) 
    	{
    		rowElement.rowIndex = indexCounter++;
    	}
    }
    // method to to update the existing row or adding new reow depending on the last modified date.
    private void addOrUpdateLastModifiedDate(DateTime lastmodifiedDate,List<AggregatedDetailedForecastListRow> aggregatedList,String forecastYearMonth) 
    {
     	Integer position =containsAtPosition(forecastYearMonth,aggregatedList);
     	Integer indexCounter = 0;
    	AggregatedDetailedForecastListRow row = new AggregatedDetailedForecastListRow(forecastYearMonth,lastmodifiedDate);
    	if(position==-1) 
    	{   
    		addRow(row,aggregatedList);
    		row.rowIndex = indexCounter;
    		indexCounter++;
    	}
    	else 
    	{
    		AggregatedDetailedForecastListRow existingRow = getRowAt(position,aggregatedList);
    		if(existingRow.lastModifiedDate<lastmodifiedDate) 
    		{
    			existingRow.lastModifiedDate = lastModifiedDate;
    		}
    	}
    }
    
    // Method to return position of the object where Forecast Month and year matches.
    private Integer containsAtPosition(String ForecastMonthYear, List<AggregatedDetailedForecastListRow> aggregatedList) 
	{
		Integer counter = 0;
		for(AggregatedDetailedForecastListRow row : aggregatedList) 
		{
			if((row.forecastMonthFormatInDB).equalsIgnoreCase(ForecastMonthYear))
			{
				return counter;
			}
			counter++;
		}
		return -1;
	}
    //method to get row at a specified postion.
    private AggregatedDetailedForecastListRow getRowAt(Integer index, List<AggregatedDetailedForecastListRow> aggregatedList) 
	{
		return aggregatedList.get(index);
	}
	//Method to add a row to the list.	
	private void addRow(AggregatedDetailedForecastListRow row, List<AggregatedDetailedForecastListRow> aggregatedList) 
	{
		aggregatedList.add(row);
	}
	//Method to load energy forecast list.
    private void loadEnerygyForecastList() 
    {
    	String queryString = 'SELECT Comm_Hub_Variant__c,'+
										    'CreatedById,'+
										    'CreatedDate,'+
										    'Energy_Supplier__c,'+
										    'Forecast_Header__c,'+
										    'Id,  '+
										    'IsDeleted,'+
										    'LastModifiedById,'+
										    'LastModifiedDate,'+
										    'Name,'+
										    'OwnerId,'+
										    'Status__c,'+
										    'SystemModstamp,'+ 
										    
										    'Current_Month_1__c,Current_Month_2__c,Current_Month_3__c,'+
										    'Current_Month_4__c,Current_Month_5__c,Current_Month_6__c,'+
										    'Current_Month_7__c,Current_Month_8__c,Current_Month_9__c,'+
										    'Current_Month_10__c,Current_Month_11__c,Current_Month_12__c,'+
										    'Current_Month_13__c,Current_Month_14__c,Current_Month_15__c,'+
										    'Current_Month_16__c,Current_Month_17__c,Current_Month_18__c,'+
										    'Current_Month_19__c,Current_Month_20__c,Current_Month_21__c,'+
										    'Current_Month_22__c,Current_Month_23__c,Current_Month_24__c,'+
										    
										    
										    'Month_1__c,Month_2__c,Month_3__c,Month_4__c,Month_5__c,Month_6__c,'+
										    'Month_7__c,Month_8__c,Month_9__c,Month_10__c,Month_11__c,Month_12__c,'+
										    'Month_13__c,Month_14__c,Month_15__c,Month_16__c,Month_17__c,Month_18__c,'+
										    'Month_19__c,Month_20__c,Month_21__c,Month_22__c,Month_23__c,Month_24__c,'+
										    
										    'Previous_Month_1__c,Previous_Month_2__c,Previous_Month_3__c,Previous_Month_4__c,'+
										    'Previous_Month_5__c,Previous_Month_6__c,Previous_Month_7__c,Previous_Month_8__c,'+
										    'Previous_Month_9__c,Previous_Month_10__c,Previous_Month_11__c,Previous_Month_12__c,'+
										    'Previous_Month_13__c,Previous_Month_14__c,Previous_Month_15__c,Previous_Month_16__c,'+
										    'Previous_Month_17__c,Previous_Month_18__c,Previous_Month_19__c,Previous_Month_20__c,'+
										    'Previous_Month_21__c,Previous_Month_22__c,Previous_Month_23__c,Previous_Month_24__c'+
							' FROM Energy_Supplier_Forecast__c' + ' WHERE CreatedDate = THIS_MONTH';
	    wrapper.energySupplierForecastList = Database.query(queryString);
     }
	 */
}