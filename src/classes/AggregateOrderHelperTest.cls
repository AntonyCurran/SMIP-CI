@isTest
public class AggregateOrderHelperTest {
    static AggregateOrderHelper helper = new AggregateOrderHelper();
    static HubHelper hubHelper = new HubHelper();
    static UserHelper userHelper = new UserHelper();
    static DateHelper dateHelper = new DateHelper();
    
    static String test_month = 'December';
    static Integer test_year = 2020;
    static Integer numberOfOrders = 3;
    
    private static List<Account> accounts = new List<Account>();
    private static List<Order> orders = new List<Order>();
    private static List<Product2> products = new List<Product2>();
    private static List<Region__c> regions = new List<Region__c>();
    
    static testMethod void create_Fills_In_Month_Test() {
        AggregateOrderWrapper wrapper = helper.create(createDefaultAggregateOrder());
        System.assert(wrapper.order.Month__c == test_month);
    }
    
    static testMethod void create_Fills_In_Year_Test() {
        AggregateOrderWrapper wrapper = helper.create(createDefaultAggregateOrder());
        System.assert(wrapper.order.Year__c == test_year.format());
    }
        
    static testMethod void orders_for_month_and_years_returns_only_orders_for_the_given_month(){
        createRegions();
        createAccounts();
        createProducts();
        createOrders();
        AggregateOrderWrapper wrapper = helper.create(createDefaultAggregateOrder());
        List<Aggregate_Order_Detail__c> details = wrapper.details;
        System.debug('Created wrapper ' + wrapper);
        Set<Id> orderIds = new Set<Id>();
        for(Aggregate_Order_Detail__c detail : details) {
        	orderIds.add(detail.Order__c);
        }
        System.assert(orderIds.size() == numberOfOrders);
    }
    
    static testMethod void orders_for_month_and_years_returns_only_orders_of_type_commications_hub(){
    }


    ////////////////////////////////////////////////////////////////////////////////
    // Helper methods not tests
    private static AggregateOrder__c createDefaultAggregateOrder(){
    	AggregateOrder__c aggregate_order = new AggregateOrder__c();
    	aggregate_order.Month__c = test_month;
    	aggregate_order.Year__c = test_year.format();
    	return aggregate_order;
    }
    
    private static void createOrders() {
       	List<OrderItem> order_items = new List<OrderItem>();     

    	orders.add(new OrderBuilder()
    		.withAccount(accounts.get(0))
    		.withRegion(regions.get(0))
    		.withSetOfHubs(100)
    		.build()
    	);

    	orders.add(new OrderBuilder()
    		.withAccount(accounts.get(0))
    		.withRegion(regions.get(1))
    		.withSetOfHubs(200)
    		.build()
    	);

		
    	orders.add(new OrderBuilder()
    		.withAccount(accounts.get(1))
    		.withRegion(regions.get(0))
    		.withSetOfHubs(300)
    		.build()
    	);

    	orders.add(new OrderBuilder()
    		.withAccount(accounts.get(1))
    		.withRegion(regions.get(1))
    		.withSetOfHubs(400)
    		.build()
    	);
    	
    	orders.add(new OrderBuilder()
    		.withAccount(accounts.get(0))
    		.withRegion(regions.get(0))
    		.withOrderType('Auxiliary Equipment Order')
    		.build()
    	);

    	orders.add(new OrderBuilder()
    		.withAccount(accounts.get(0))
    		.withRegion(regions.get(0))
    		.withOrderType('Catalogue Order')
    		.build()
    	);
	}
    
    private static void createAccounts() {
        Account account1 = new Account(name='Test Eon', Forecast_Start_Date__c=System.today(), Energy_Supplier__c=true);
        accounts.add(account1);
        Account account2 = new Account(name='Test British Gas', Forecast_Start_Date__c=System.today(), Energy_Supplier__c=true);
        accounts.add(account2);
        Account account3 = new Account(name='Test Telefonica', Forecast_Start_Date__c=System.today(), Energy_Supplier__c=false);
        accounts.add(account3);       
        insert accounts;
    }
    
    private static void createProducts(){
        Product2 product1 = new Product2(name='Hub-1', Family='Communications Hub');
        products.add(product1);
        Product2 product2 = new Product2(name='Hub-2', Family='Communications Hub');
        products.add(product2);
        insert products;
    } 
    
    private static void createRegions() {
    	Region__c south = new Region__c(name='South');
    	Region__c north = new Region__c(name='North');
    	regions.add(south);
    	regions.add(north);
    	insert regions;
    }
    
    private static id findRecordTypeForOrder(String name) {
        Map<String,Schema.RecordTypeInfo> recordTypesByName = Schema.SObjectType.Order.getRecordTypeInfosByName();
        Schema.RecordTypeInfo record_type =  recordTypesByName.get(name);
        return record_type.getRecordTypeId(); 
    }  
}