// The responsibility of this class is to manage the persistant state of the 
// aggregate orders
public class AggregateOrderHelper {

    private UserHelper userHelper = new UserHelper();
    private DateHelper dateHelper = new DateHelper();

    public AggregateOrderWrapper create(AggregateOrder__c aggregateOrder){
        System.debug('Creating a new aggregate order');
        
        Date thisMonth = System.today();
        String month = dateHelper.nameOfMonth(thisMonth);
        String year = '' + thisMonth.year();
        List<Order> orders = findOrdersByMonthAndYear(month, year);
        AggregateOrderWrapper wrapper = new AggregateOrderWrapper();
        wrapper.detailsByStatus = organiseDetailsByStatus(orders);
        wrapper.order = buildOrder(aggregateOrder, month, year, wrapper.detailsByStatus);
        return wrapper;
    }
    
    public AggregateOrderWrapper load(AggregateOrder__c aggregateOrder){
        AggregateOrderWrapper wrapper = new AggregateOrderWrapper();
        wrapper.order = aggregateOrder;
        List<Aggregate_Order_Detail__c> details = [
        	SELECT id, Account__c, Hub__c, Order_Status__c, Order_Number__c, Order__c, Quantity__c, Min_Tolerance__c, Max_Tolerance__c, Region__c, Aggregate_Order__c
        	FROM Aggregate_Order_Detail__c
        	WHERE Aggregate_Order__c = :aggregateOrder.id
        	];
        wrapper.detailsByStatus = sortDetailsByStatus(details);
        return wrapper;
    }
    
    public Boolean save(AggregateOrderWrapper wrapper) {
        Savepoint sp = Database.setSavepoint();
        List<Aggregate_Order_Detail__c> details = wrapper.details();
        try {
            insert wrapper.order;
            if(Debug.Status){
                System.debug('Saved order ' + wrapper.order);
            }
            
            if(Debug.Status){
                System.debug('Saving order details ' + details);
            }
            for (Aggregate_Order_Detail__c detail : details){
                detail.Aggregate_Order__c = wrapper.order.id;
            }
            insert details;
            if(Debug.Status){
                System.debug('Saved order details ' + details);
            }
            return true;
        } catch (Exception e) {
        	wrapper.order.id = null;
        	for (Aggregate_Order_Detail__c detail : details){
                detail.id = null;
            }
            ApexPages.addMessages(e);
            Database.rollback(sp);
            return false;
        }
        
        return false;
    }
    
    public AggregateOrder__c getRecord(ApexPages.StandardController controller) {
        List<String> fields = new List<String>();
        fields.add('Region__c');
        fields.add('Month__c');
        fields.add('Year__c');
        fields.add('Total_Number__c');
        fields.add('Status__c');
        fields.add('Min_Tolerance__c');
        fields.add('Max_Tolerance__c');
        
        if (!Test.isRunningTest()) {
            controller.addFields(fields);
        }    
        return (AggregateOrder__c)controller.getRecord();
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // Helper methods
    
    private Map<String, List<Aggregate_Order_Detail__c>> sortDetailsByStatus(List<Aggregate_Order_Detail__c> details) {
    	Map<String, List<Aggregate_Order_Detail__c>> detailsByStatus = new Map<String, List<Aggregate_Order_Detail__c>>();
    	for(Aggregate_Order_Detail__c detail : details){
    		addDetailToDetailsByStatus(detail, detailsByStatus);
    	}
    	return detailsByStatus;
    }
    
    private List<Order> findOrdersByMonthAndYear(String month, String year) {
        List<Order> orders = [
            Select id, Name, RecordType.name, Month__c, Year__c, Status, Account.name, Account.id, Region__c, OrderNumber
            FROM Order
            Where RecordType.name = 'Communication Hub Order'
                AND Month__c = :month
                AND Year__C = :year        
            ];
        return orders;
    }
   
    private AggregateOrder__c buildOrder(AggregateOrder__c aggregateOrder, String month, String year, Map<String, List<Aggregate_Order_Detail__c>> detailsPerStatus) {
        aggregateOrder.Month__c = month;
        aggregateOrder.Year__c = year;
        aggregateOrder.Total_Number__c = totalHubs(detailsPerStatus); 
        aggregateOrder.Min_Tolerance__c = aggregateOrder.Total_Number__c; 
        aggregateOrder.Max_Tolerance__c = aggregateOrder.Total_Number__c; 
        aggregateOrder.Status__c = 'Created';
        return aggregateOrder;
    }
    
    
    private Map<String, List<Aggregate_Order_Detail__c>>  organiseDetailsByStatus(List<Order> orders) {
        Map<String, List<Aggregate_Order_Detail__c>> detailsByStatus = new Map<String, List<Aggregate_Order_Detail__c>>();
        Integer count = 0;
        for (Order order : orders) {
            for (OrderItem orderItem : orderItemsForOrder(order)) {
                Aggregate_Order_Detail__c detail = createNewDetail(orderItem, order);
                addDetailToDetailsByStatus(detail, detailsByStatus);
                count++;
            }
        }
        
        System.debug('Found details: ' + count);
        return detailsByStatus;
    }

    private List<OrderItem> orderItemsForOrder(Order order) {
        return  [
                SELECT id, OrderId, Quantity, PricebookEntryId
                FROM OrderItem
                WHERE OrderId = :order.id
            ];
    }
    
    private void addDetailToDetailsByStatus(Aggregate_Order_Detail__c detail, Map<String, List<Aggregate_Order_Detail__c>> detailsByStatus) {
        List<Aggregate_Order_Detail__c> order_details = detailsByStatus.get(detail.Order_Status__c);
        if (order_details == null){
            System.debug('Created a list for list ' + order.Status);
            order_details = new List<Aggregate_Order_Detail__c>();
            detailsByStatus.put(detail.Order_Status__c, order_details);
        }
        order_details.add(detail);  
    }
    
    private Aggregate_Order_Detail__c createNewDetail(OrderItem orderItem, Order order){
                PriceBookEntry priceBookEntry = [
                    SELECT id, Product2.Name, ProductCode
                    FROM PriceBookEntry
                    WHERE Id = :orderItem.PricebookEntryId
                ];
                
                
        Aggregate_Order_Detail__c detail = new Aggregate_Order_Detail__c();
        detail.Account__c = order.AccountId;
        detail.Hub__c = priceBookEntry.Product2Id;
        detail.Order_Status__c = order.Status;
        detail.Order_Number__c = order.OrderNumber;
        detail.Order__c = order.Id;
        detail.Quantity__c = orderItem.Quantity;
        detail.Min_Tolerance__c = orderItem.Quantity;
        detail.Max_Tolerance__c = orderItem.Quantity;
        detail.Region__c = userHelper.regionForName(order.Region__c).id;
        if(Debug.Status){
            System.debug('Detail for order ' + order.id + ' Status:' + detail.Order_Status__c + ' hub:' + detail.hub__c + ' quantity: ' + detail.Quantity__c);
            System.debug(detail);
        }
        return detail;
    }

    private Decimal totalHubs (Map<String, List<Aggregate_Order_Detail__c>> orderDetailsByOrder) {
        Decimal total = 0;
        for (List<Aggregate_Order_Detail__c> details : orderDetailsByOrder.values()) {
            for (Aggregate_Order_Detail__c detail : details) {
                total += detail.Quantity__c;
            }
        }
        return total;
        
    }
}