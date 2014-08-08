public class DateHelper {
    List<String> months = new List<String>
        {'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'};
   
    List<String> weekDays  = new List<String>
        {'Saturday', 'Sunday','Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'};
   
    public String nameOfMonth(Date param1){
        Integer month = param1.month();
        return months.get(month-1);
    }
    
    // January = 1, December = 12
    public String nameOfMonth(Integer month) {
    	return months.get(month-1);
    }
    
    public Date dateFor(String month, Integer year){
    	Integer monthIndex = getIndexOfMonth(month);
    	return Date.newInstance(year, monthIndex, 1); 
    }
    
    public Integer getIndexOfMonth(String monthName) 
    {   
    	try 
    	{	
    		integer monthCounter = 1;
    		for(String month: months) 
    		{
    			if(month.equalsIgnoreCase(monthName)) 
    			{
    				return monthCounter;
    			}
    			monthCounter++;
    		}
		}catch(Exception e) 
    	{
    		System.debug('Exception----->DateHelper.getIndexOfMonth()');
    	}
    	return -1;
    }
    
    public Date nextMonth(){
        Date next_month = System.today().addMonths(1);
        return Date.newInstance(next_month.year(), next_month.month(), 1);
    }
    
    public Date forecastStartDate() {
        // start date is today  + nine months
        Date startDate = System.today().addMonths(9);
        return startDate;
    }
    
    public Date forecastEndDate(Date startDate) {
        Date forecastEndDate = startDate.addMonths(24);
        return forecastEndDate;
    }
    
    public Integer forecastStartYear(Date startDate) {
        Integer forecastStartYear = startDate.year();
        return forecastStartYear;
    }
    
    public Integer forecastEndYear(Date endDate) {
        Integer forecastEndYear = endDate.year();
        return forecastEndYear;
    }
    
    public Long getDifferenceInTime(DateTime firstDateTime, DateTime secondDateTime)  
    {
        return firstDateTime.getTime()-secondDateTime.getTime();
    }
}