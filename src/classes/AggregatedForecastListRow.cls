/*
Type Name:        class AggregatedForecastListRow
Author:           MJ
Created Date:     08-August-2014
Reason:           This class is a row object in Aggregated Forecast Page.
*/

public class AggregatedForecastListRow implements Comparable{
	
	public String     forecastMonthDisplayValue     {get;set;}
	public String     forecastYearDisplayValue      {get;set;}
	public String     forecastMonthFormatInDB 	    {get;set;}
	public String     forecastMonth 			    {get;set;}
	public String     forecastYear     			    {get;set;}
	public DateTime   lastModifiedDate  			{get;set;}
	public DateTime   forecastMothInDateTimeFormat  {get;set;}
	public Integer    rowIndex                  {get;set;}
	public DateHelper dateHelper = new DateHelper();
		 
	// Construct to pass Forecast Month and last modified date while creating the object.	 
	public AggregatedForecastListRow(String forecastYearMonth, DateTime lastModifiedDate) 
	{
	    rowIndex = 0;
		calculateForecastYearAndMonth(forecastYearMonth);
		this.forecastMonthFormatInDB = forecastYearMonth;
		this.lastModifiedDate = lastModifiedDate;
		this.forecastMonthDisplayValue = getThreeLetterMonth(forecastMonth.touppercase());
		this.forecastYearDisplayValue    = forecastYear;
		this.forecastMothInDateTimeFormat = Datetime.newInstance(Integer.valueOf(forecastYear),
																 dateHelper.getIndexOfMonth(forecastMonth),
																 1,
																 9,0,0);
	  
	}
	
	// Method for indentifying month and year from month and year concatenated string.
    private void calculateForecastYearAndMonth(String forecastMonthYear) 
	{   
		
		String[] splitValue = forecastMonthYear.split(' ');
		if(splitValue.size()!=2) 
		{
			return ;
		}
	    this.forecastMonth = splitValue[0].touppercase();
	    this.forecastYear  = splitValue[1];
	}
		
	//Mehtod for returning the three character month value.
	private String getThreeLetterMonth(String month) 
	{
		return month.substring(0,3);
	}

	// Implement the compareTo() method
	// sort method is called on list of the object,so this method defines the sorting criterion.
    public Integer compareTo(Object compareTo) {
        AggregatedForecastListRow compareToObj = (AggregatedForecastListRow)compareTo;
        if (forecastMothInDateTimeFormat == compareToObj.forecastMothInDateTimeFormat)
        	 return 0;
        if (forecastMothInDateTimeFormat > compareToObj.forecastMothInDateTimeFormat)
        	 return 1;
        return -1;        
    }
}