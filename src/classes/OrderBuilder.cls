// This class is used by tests to create orders
@isTest
public with sharing class OrderBuilder {
	private DateHelper dateHelper = new DateHelper();
	private UserHelper userHelper = new UserHelper();
	private HubHelper hubHelper = new HubHelper();
	
	private Date orderDate = System.today();
	private Account account = userHelper.energySupplierForName('Eon');
	private Region__c region = userHelper.regionForName('South');
	private Pricebook2 priceBook;
	private List<OrderItem> orderItems = new List<OrderItem>();
	private String orderType;
	RecordType recordType;
	
	// By default a useable order will be created
	public OrderBuilder() {
		orderDate = System.today();
     	withOrderType('Communication Hub Order');
	}
		
	public OrderBuilder forMonth(String month, Integer year) {
		orderDate = dateHelper.dateFor(month, year);
		return this;
	}
	
	public OrderBuilder withAccount(Account account) {
		this.account = account;
		return this;
	}
	
	public OrderBuilder withRegion(Region__c region) {
		this.region = region;
		return this;
	}
	
	public OrderBuilder withRecordType(){
		return this;
	}
	
	public OrderBuilder withItem(Product2 product, Integer quantity){
       	if(priceBook == null){
       		withStandardPriceBook();
       	}
   		PricebookEntry priceBookEntry = [SELECT Id, UnitPrice FROM PricebookEntry WHERE Pricebook2Id = :priceBook.Id AND Product2.ProductCode =: product.ProductCode];
     	OrderItem orderItem=new OrderItem(
       		Quantity=quantity,
       		PricebookEntryId=priceBookEntry.Id,
       		UnitPrice=priceBookEntry.UnitPrice
		);
    	orderItems.add(orderItem);
		return this;
	}
	
	public OrderBuilder withSetOfHubs(Integer quantity){
		if (orderType == null){
       		withOrderType('Communication Hub Order');
		}
       	List<Product2> products =  hubHelper.hubTypes();     	     	
       	for(Product2 product : products){
       		withItem(product, quantity);
       	}		
		return this;
	}
	
	public OrderBuilder withOrderType(String orderType){
		this.orderType = orderType;
		System.debug('The order type is "' + orderType + '"');
		List<RecordType> recordTypes = [Select Id,Name from RecordType where SobjectType='Order' And Name= :orderType];
		if (recordTypes.size() > 0){
			this.recordType = recordTypes.get(0);
			System.debug('Found record type"'+ recordType + '"');
		} 
		return this;
	}
	
	public OrderBuilder withStandardPriceBook() {
		if(orderType == null){
			withOrderType('Communication Hub Order');
		}
		System.debug('Looking for pricebook ' + priceBook + ' for order type ' + recordType.name);
		List<Ord_PB_Mapping__c> orderPriceBook = [Select PriceBook_Name__c from Ord_PB_Mapping__c where Order_Record_Type__c =: recordType.name];
       	System.debug('The price book mapping is ' + orderPriceBook.size());
	    String PBName = orderPriceBook[0].PriceBook_Name__c;
    	priceBook=[SELECT Id FROM Pricebook2 WHERE Name=: PBName];
    	System.debug('Set price book '  + priceBook + ' in builder');
		return this;
	}
	
	public Order build() {
		if(orderType == null){
			withOrderType('Communication Hub Order');
		}

		if(priceBook == null){
			withStandardPriceBook();
		}
		
		System.debug('Builing order using region:' + region);
		System.debug('Builing order using account:' + account);
		System.debug('Builing order using pricebook:' + pricebook);
		
		Order order = new Order(
			effectiveDate=orderDate, 
			account=account, 
			region__c=region.name,
			Pricebook2Id=priceBook.Id
		);
		insert order;
		for (OrderItem orderItem: orderItems) {
			orderItem.OrderId=order.id;
		}
		insert orderItems;
		return order;
	}
}