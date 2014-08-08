public class AggregatedForecastDetailController {
   public String                                forecastMonthYear                   {get;set;}
   public AggregatedDetailedForecastHelper      aggregateDetailForecastHelper       = new AggregatedDetailedForecastHelper();
   public AggregatedDetailedForecastWrapper             aggregateDetailForecastWrapper      {get;set;}
   
    public AggregatedForecastDetailController(ApexPages.StandardSetController controller){
        forecastMonthYear =  apexpages.currentPage().getParameters().get('ForecastMonthYear');
        loadWrapper();
    }
    //method for load wrapper.
    private void loadWrapper() 
    {
        aggregateDetailForecastWrapper =aggregateDetailForecastHelper.createAggregateDetailedForecast(forecastMonthYear); 
        
    } 
    
    
    public Component.Apex.SectionHeader getDynamicComponentWithForecastMonth() {
        Component.Apex.SectionHeader sectionHeader = new Component.Apex.SectionHeader();
        sectionHeader.title   = 'Detailed Aggregated Forecast';
        sectionHeader.subTitle= 'Aggregated Forcast details for the month of  :'+forecastMonthYear ; 
        return sectionHeader;
    }
    
}