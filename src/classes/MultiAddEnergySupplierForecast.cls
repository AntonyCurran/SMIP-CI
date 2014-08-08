public class MultiAddEnergySupplierForecast
{
    public List<Product2> hubProducts {get;set;}
    public String hubId {get;set;}
    public String hubName {get;set;}
    DateHelper dateHelper = new DateHelper();
    public String accountId {get;set;}
    public String previousMonth {get;set;}
    public boolean energySuppUser {get;set;}
    public String previousForecastHeader {get;set;}
    
    
    //will hold the Energy_Supplier_Forecast__c records to be saved
    public List<Energy_Supplier_Forecast__c>listEnergySupplierForecast  = new List<Energy_Supplier_Forecast__c>();
    
    //will hold the Forecast_Header__c record
    public Forecast_Header__c forecastHeader = new Forecast_Header__c();
   
    //list of the inner class
    public List<innerClass> listInner {get;set;}
    
    public innerClass monthDisplay {get;set;}
    //will indicate the row to be deleted
    public String selectedRowIndex {get;set;}  
    
    //no. of rows added/records in the inner class list
    public Integer count = 1;
    
    // save the records by adding the elements in the inner class list to listAcct,return to the list page
    public PageReference Save()
    {
        PageReference pageRef = new PageReference('/a0A/o');
        
        insert forecastHeader;
        
        for(Integer j = 0;j<listInner.size();j++)
        {
            listInner[j].esf.Forecast_Header__c = forecastHeader.id;
            listEnergySupplierForecast.add(listInner[j].esf);
        } 
        insert listEnergySupplierForecast;
        pageRef.setRedirect(True);
        return pageRef;
    }
    
    public PageReference Cancel()
    {
        PageReference pageRef = new PageReference('/a0A/o');
        pageRef.setRedirect(True);
        return pageRef;
    }
        
    public MultiAddEnergySupplierForecast(ApexPages.StandardController ctlr)
    {
        
        previousMonth = dateHelper.nameOfMonth(System.today());
        listInner = new List<innerClass>();
        // get the list of hubproducts
        List<Product2> hubProducts = [SELECT Id, Name, ProductCode, Description, IsActive 
                                      FROM  Product2
                                      WHERE Family = 'Communication Hubs'
                                      ORDER BY Name ASC];
                                      
        //check we have an account                              
        try 
        { 
            accountId = UserHelper.getAccountId(UserHelper.getGroupName(UserHelper.getEnergySupplierGroupMembership()));  
            energySuppUser = true;
        }
        catch (QueryException e) 
        {
            energySuppUser = false;
        }
        
        if(energySuppUser)
        {
            try
            {
                previousForecastHeader = [SELECT id
                                          FROM Forecast_Header__c
                                          WHERE Forecast_Month__c = :previousMonth
                                          AND Account__c = :accountId
                                          LIMIT 1].id;
            }
            catch (QueryException e) 
            {
                // the first record has not been found so we will need to check for null when we create 
                previousForecastHeader = '0';
                
                system.debug('forecast header = '+ previousForecastHeader);
            }
        }
        
   
        forecastHeader.Forecast_Month__c = dateHelper.nameOfMonth(system.today());
        forecastHeader.Status__c = ('Created');
        forecastHeader.Account__c = accountId;
        
        
        for (Product2 hub : hubProducts)
        {
            addHub(hub.Id, hub.Name, accountId, previousForecastHeader);
            count = count+1;
        } 
        
        monthDisplay = listInner.get(0);
        selectedRowIndex = '0'; 
    }
    
    public void addHub(String hubId, String hubName,  String accId, String prevForecast)
    {
        //call to the iner class constructor
        innerClass objInnerClass = new innerClass(count, hubName, hubId, accId, prevForecast);
        
        //add the record to the inner class list
        listInner.add(objInnerClass);             
    }
    
    
        
    public class innerClass
    {       
        // recCount acts as a index for a row. This will be helpful to identify the row 
        public String recCount {get;set;}
        public String hubType {get;set;}
        public String hubId {get;set;}
        public String accId {get;set;}
        public String prevId {get;set;}
        
        // DateHelper used to get the name of the month
        DateHelper dateHelper = new DateHelper();
        
        public boolean energySuppUser {get;set;}
        
        public Energy_Supplier_Forecast__c esf {get;set;}
        public Energy_Supplier_Forecast__c previousEsf {get;set;}
        
        public Date nextMonthPlus(Integer noOfMonths)
        {
            Date next_month = System.today().addMonths(noOfMonths);
            return Date.newInstance(next_month.year(), next_month.month(), 1);
        }
        
        public String getYearMonthPlus(Integer yearFromMonth)
        {
            Date dateWithAddedMonth = System.today().addMonths(yearFromMonth);
            return String.valueOf(dateWithAddedMonth.year());
        }
        
        //Inner Class Constructor
        public innerClass(Integer intCount, String hT, String hId, String aId, String pId)
        {
            
            recCount = String.valueOf(intCount); 
            hubType = hT;   
            hubId = hId; 
            accId = aId; 
            prevId = pId;
            // setup previous values but check if we need to by looking at the value of the previous header ID
            if(prevId != '0')
            {
                try
                { 
                    previousEsf = [SELECT Previous_Month_1__c, Previous_Month_2__c, Previous_Month_3__c, Previous_Month_4__c,
                                          Previous_Month_5__c, Previous_Month_6__c, Previous_Month_7__c, Previous_Month_8__c,
                                          Previous_Month_9__c, Previous_Month_10__c, Previous_Month_11__c, Previous_Month_12__c,
                                          Previous_Month_13__c, Previous_Month_14__c, Previous_Month_15__c, Previous_Month_16__c,
                                          Previous_Month_17__c, Previous_Month_18__c, Previous_Month_19__c, Previous_Month_20__c,
                                          Previous_Month_21__c, Previous_Month_22__c, Previous_Month_23__c, Previous_Month_24__c
                                   FROM Energy_Supplier_Forecast__c
                                   WHERE Forecast_Header__c = : prevId
                                   AND Comm_Hub_Variant__c = :hubId];
                }
                catch (QueryException e) 
                { 
                //moved the following
                /*previousEsf.Previous_Month_1__c = 0;
                previousEsf.Previous_Month_2__c = 0;
                previousEsf.Previous_Month_3__c = 0;
                previousEsf.Previous_Month_4__c = 0;
                previousEsf.Previous_Month_5__c = 0;
                previousEsf.Previous_Month_6__c = 0;
                previousEsf.Previous_Month_7__c = 0;
                previousEsf.Previous_Month_8__c = 0;
                previousEsf.Previous_Month_9__c = 0;
                previousEsf.Previous_Month_10__c = 0;
                previousEsf.Previous_Month_11__c = 0;
                previousEsf.Previous_Month_12__c = 0;
                previousEsf.Previous_Month_13__c = 0;
                previousEsf.Previous_Month_14__c = 0;
                previousEsf.Previous_Month_15__c = 0;
                previousEsf.Previous_Month_16__c = 0;
                previousEsf.Previous_Month_17__c = 0;
                previousEsf.Previous_Month_18__c = 0;
                previousEsf.Previous_Month_19__c = 0;
                previousEsf.Previous_Month_20__c = 0;
                previousEsf.Previous_Month_21__c = 0;
                previousEsf.Previous_Month_22__c = 0;
                previousEsf.Previous_Month_23__c = 0;
                previousEsf.Previous_Month_24__c = 0;*/
                }
            }
            else
            {
                system.debug('got here');
                // populate defaults
                previousEsf = new Energy_Supplier_Forecast__c(Previous_Month_1__c = 0,
                                                              Previous_Month_2__c = 0,
                                                              Previous_Month_3__c = 0,
                                                              Previous_Month_4__c = 0,
                                                              Previous_Month_5__c = 0,
                                                              Previous_Month_6__c = 0,
                                                              Previous_Month_7__c = 0,
                                                              Previous_Month_8__c = 0,
                                                              Previous_Month_9__c = 0,
                                                              Previous_Month_10__c = 0,
                                                              Previous_Month_11__c = 0,
                                                              Previous_Month_12__c = 0,
                                                              Previous_Month_13__c = 0,
                                                              Previous_Month_14__c = 0,
                                                              Previous_Month_15__c = 0,
                                                              Previous_Month_16__c = 0,
                                                              Previous_Month_17__c = 0,
                                                              Previous_Month_18__c = 0,
                                                              Previous_Month_19__c = 0,
                                                              Previous_Month_20__c = 0,
                                                              Previous_Month_21__c = 0,
                                                              Previous_Month_22__c = 0,
                                                              Previous_Month_23__c = 0,
                                                              Previous_Month_24__c = 0);
                                                              
                                                  
                
                system.debug('got here' +previousEsf);
            }
            
             
            // create a new Energy_Supplier_Forecast__c
            esf = new Energy_Supplier_Forecast__c(Comm_Hub_Variant__c = hubId,
                                                  Energy_Supplier__c = aId,                                  
                                                  Month_1__c = dateHelper.nameOfMonth(nextMonthPlus(1))+' '+ getYearMonthPlus(1),
                                                  Month_2__c = dateHelper.nameOfMonth(nextMonthPlus(2))+' '+ getYearMonthPlus(2),
                                                  Month_3__c = dateHelper.nameOfMonth(nextMonthPlus(3))+' '+ getYearMonthPlus(3),
                                                  Month_4__c = dateHelper.nameOfMonth(nextMonthPlus(4))+' '+ getYearMonthPlus(4),
                                                  Month_5__c = dateHelper.nameOfMonth(nextMonthPlus(5))+' '+ getYearMonthPlus(5),
                                                  Month_6__c = dateHelper.nameOfMonth(nextMonthPlus(6))+' '+ getYearMonthPlus(6),
                                                  Month_7__c = dateHelper.nameOfMonth(nextMonthPlus(7))+' '+ getYearMonthPlus(7),
                                                  Month_8__c = dateHelper.nameOfMonth(nextMonthPlus(8))+' '+ getYearMonthPlus(8),
                                                  Month_9__c = dateHelper.nameOfMonth(nextMonthPlus(9))+' '+ getYearMonthPlus(9),
                                                  Month_10__c = dateHelper.nameOfMonth(nextMonthPlus(10))+' '+ getYearMonthPlus(10),
                                                  Month_11__c = dateHelper.nameOfMonth(nextMonthPlus(11))+' '+ getYearMonthPlus(11),
                                                  Month_12__c = dateHelper.nameOfMonth(nextMonthPlus(12))+' '+ getYearMonthPlus(12),
                                                  Month_13__c = dateHelper.nameOfMonth(nextMonthPlus(13))+' '+ getYearMonthPlus(13),
                                                  Month_14__c = dateHelper.nameOfMonth(nextMonthPlus(14))+' '+ getYearMonthPlus(14),
                                                  Month_15__c = dateHelper.nameOfMonth(nextMonthPlus(15))+' '+ getYearMonthPlus(15),
                                                  Month_16__c = dateHelper.nameOfMonth(nextMonthPlus(16))+' '+ getYearMonthPlus(16),
                                                  Month_17__c = dateHelper.nameOfMonth(nextMonthPlus(17))+' '+ getYearMonthPlus(17),
                                                  Month_18__c = dateHelper.nameOfMonth(nextMonthPlus(18))+' '+ getYearMonthPlus(18),
                                                  Month_19__c = dateHelper.nameOfMonth(nextMonthPlus(19))+' '+ getYearMonthPlus(19),
                                                  Month_20__c = dateHelper.nameOfMonth(nextMonthPlus(20))+' '+ getYearMonthPlus(20),
                                                  Month_21__c = dateHelper.nameOfMonth(nextMonthPlus(21))+' '+ getYearMonthPlus(21),
                                                  Month_22__c = dateHelper.nameOfMonth(nextMonthPlus(22))+' '+ getYearMonthPlus(22),
                                                  Month_23__c = dateHelper.nameOfMonth(nextMonthPlus(23))+' '+ getYearMonthPlus(23),
                                                  Month_24__c = dateHelper.nameOfMonth(nextMonthPlus(24))+' '+ getYearMonthPlus(24),
                                                  Previous_Month_1__c = previousEsf.Previous_Month_1__c,
                                                  Previous_Month_2__c = previousEsf.Previous_Month_2__c,
                                                  Previous_Month_3__c = previousEsf.Previous_Month_3__c,
                                                  Previous_Month_4__c = previousEsf.Previous_Month_4__c,
                                                  Previous_Month_5__c = previousEsf.Previous_Month_5__c,
                                                  Previous_Month_6__c = previousEsf.Previous_Month_6__c,
                                                  Previous_Month_7__c = previousEsf.Previous_Month_7__c,
                                                  Previous_Month_8__c = previousEsf.Previous_Month_8__c,
                                                  Previous_Month_9__c = previousEsf.Previous_Month_9__c,
                                                  Previous_Month_10__c = previousEsf.Previous_Month_10__c,
                                                  Previous_Month_11__c = previousEsf.Previous_Month_11__c,
                                                  Previous_Month_12__c = previousEsf.Previous_Month_12__c,
                                                  Previous_Month_13__c = previousEsf.Previous_Month_13__c,
                                                  Previous_Month_14__c = previousEsf.Previous_Month_14__c,
                                                  Previous_Month_15__c = previousEsf.Previous_Month_15__c,
                                                  Previous_Month_16__c = previousEsf.Previous_Month_16__c,
                                                  Previous_Month_17__c = previousEsf.Previous_Month_17__c,
                                                  Previous_Month_18__c = previousEsf.Previous_Month_18__c,
                                                  Previous_Month_19__c = previousEsf.Previous_Month_19__c,
                                                  Previous_Month_20__c = previousEsf.Previous_Month_20__c,
                                                  Previous_Month_21__c = previousEsf.Previous_Month_21__c,
                                                  Previous_Month_22__c = previousEsf.Previous_Month_22__c,
                                                  Previous_Month_23__c = previousEsf.Previous_Month_23__c,
                                                  Previous_Month_24__c = previousEsf.Previous_Month_24__c
                                                  );
            
             
        } 
         
    }
}