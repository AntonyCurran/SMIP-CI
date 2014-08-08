public class AggregateOrderWrapper {
    public AggregateOrder__c order {get; set;}
    
    public Map<String,List<Aggregate_Order_Detail__c>> detailsByStatus {get;set;}

    public AggregateOrderWrapper() {
        order = new AggregateOrder__c();
        detailsByStatus = new Map<String,List<Aggregate_Order_Detail__c>>();
    }
    
    public List<Aggregate_Order_Detail__c> details() { 
    	List<Aggregate_Order_Detail__c> detailsList = new List<Aggregate_Order_Detail__c>();
    	for (List<Aggregate_Order_Detail__c> details: detailsByStatus.values()){
    		for (Aggregate_Order_Detail__c detail : details){
    			detailsList.add(detail);
    		}
    	}
    	return detailsList;
    }
    
    public List<Aggregate_Order_Detail__c> viewDetails() { 
    	List<Aggregate_Order_Detail__c> details = createViewDetails(detailsByStatus);
    	return details;
    }
    
    //////////////////////////////////////////////////////////////////////
    // Helper methods
    private List<Aggregate_Order_Detail__c> createViewDetails(Map<String, List<Aggregate_Order_Detail__c>> detailsByStatus) {
    	List<Aggregate_Order_Detail__c> viewDetails = new List<Aggregate_Order_Detail__c>();
        for (List<Aggregate_Order_Detail__c> detailList : detailsByStatus.values()){
            Aggregate_Order_Detail__c previousDetail = null;
            Aggregate_Order_Detail__c viewDetail = null;
            for (Aggregate_Order_Detail__c detail : detailList){
                viewDetail = detail.clone();
                hideDuplicateFields(viewDetail, previousDetail);
                viewDetails.add(viewDetail);
                previousDetail = detail;
            }
        }
    	return viewDetails;
    }
    
    private void hideDuplicateFields(Aggregate_Order_Detail__c detail, Aggregate_Order_Detail__c previousDetail) {
        if (previousDetail != null) {
            if (previousDetail.Account__c == detail.Account__c){
                detail.Account__c = null;
                if (previousDetail.Region__c == detail.Region__c){
                    detail.Region__c = null;
                    if (previousDetail.Order_Number__c == detail.Order_Number__c){
                        detail.Order_Number__c = null;
                    }
                }
            }
        }
    }
    
}