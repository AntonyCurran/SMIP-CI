/*
Type Name:        class AggregatedForecastExtnController
Author:           MJ
Created Date:     08-August-2014
Reason:           Extension Controller for  Aggregated Forecast Page.
*/

public class AggregatedForecastExtnController {

    public AggregatedForecastExtnController(ApexPages.StandardController controller) {

    }

    // aggregate forecast Helper
    AggregatedForecastHelper          aggForecastHelper      = new AggregatedForecastHelper();
    // Aggregate forecast Wrapper
    public AggregatedForecastWrapper aggForecastWrapper     {get;set;}  
    // Date helper
    private DateHelper               dateHelperObj          = new DateHelper();
    // Forecast Month year
    public String                    forecastMonthYear      {get;set;}

    // Constructor
    public AggregatedForecastExtnController(ApexPages.StandardSetController sc) {
        loadWrapper();
    }
    //method for load wrapper.
    private void loadWrapper() 
    {
        aggForecastWrapper =aggForecastHelper.createAggregateForecast(); 
    }
    
    //returns dynamic section header for the current month.
    public Component.Apex.SectionHeader getDynamicSectionHeaderForForecastMonth() {
        Component.Apex.SectionHeader sectionHeader = new Component.Apex.SectionHeader();
        Date currentDate = Date.today();
        sectionHeader.title   = 'Aggregated Forecast';
        sectionHeader.subTitle= 'Aggregated Forcast : submitted in the month of '+dateHelperObj.nameOfMonth(currentDate)+' - '+currentDate.year(); 
        return sectionHeader;
    }
   
    // Method when view details link is clicked.   
    public PageReference openAggregatedForecastPage() 
    {   
        PageReference pageRef = Page.AggregatedForecastDetailedViewPage;
        AggregatedForecastListRow selectedRow = aggForecastWrapper.getSelectedRow();
        pageRef.getParameters().put('ForecastMonthYear',selectedRow.forecastMonthFormatInDB);
        return pageRef;
    }
}