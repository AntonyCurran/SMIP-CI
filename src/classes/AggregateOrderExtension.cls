public class AggregateOrderExtension {
    public AggregateOrderWrapper wrapper {get; set;}
    
    private AggregateOrderHelper helper = new AggregateOrderHelper();
    
    public AggregateOrderExtension(ApexPages.StandardController controller){
        AggregateOrder__c aggregateOrder = helper.getRecord(controller);
        if (aggregateOrder.id != null){
        	if(Debug.STATUS){
            	System.debug('Loading order ' + aggregateOrder);
        	}
            wrapper  = helper.load(aggregateOrder);
        } else {
        	if(Debug.STATUS){
	            System.debug('Creating order ' + aggregateOrder);
        	}
            wrapper = helper.create(aggregateOrder);
        }
    }
    
    public PageReference save() {
    	if (helper.save(wrapper)) {
        	return new PageReference('/a08/o');
    	} else {
    		return null;		
    	}
    }
}