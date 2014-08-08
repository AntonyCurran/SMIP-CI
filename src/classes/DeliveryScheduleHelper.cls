public class DeliveryScheduleHelper {
    private HubHelper hubHelper = new HubHelper();
    private UserHelper userHelper = new UserHelper();
    private DateHelper dateHelper = new DateHelper();
    
     
    public DeliveryScheduleWrapper create(Delivery_Schedule__c deliverySchedule, String prdFamily) {
        DeliveryScheduleWrapper wrapper = new DeliveryScheduleWrapper();
        wrapper.deliverySchedule = deliverySchedule;        
        wrapper.deliverySchedule.Account__c = userHelper.accountForCurrentUser().id;
        wrapper.deliverySchedule.Region__c = userHelper.regionForCurrentUser().id;
        wrapper.items = new Map<Integer, List<ConsignmentItem__c>>();
        Date nextMonth = dateHelper.nextMonth();
        wrapper.deliverySchedule.Month__c = dateHelper.nameOfMonth(nextMonth);
        wrapper.deliverySchedule.Year__c = String.valueof(nextMonth.year());

        wrapper.consignments = new List<Consignment__c>();
        for (Integer index = 1; index <=4; index++){
        	//VG - Modified to make OrderType dynamically selected        
            //wrapper.consignments.add(createConsignment(index, wrapper));
            wrapper.consignments.add(createConsignment(index, wrapper, prdFamily));
        }

        return wrapper;
    }
  
    public Delivery_Schedule__c getRecord(ApexPages.StandardController controller) {
        List<String> fields = new List<String>();
        fields.add('Account__c');
        fields.add('Region__c');
        fields.add('Month__c');
        fields.add('Year__c');
        fields.add('Order__c');
        if (!Test.isRunningTest()) {
            controller.addFields(fields);
        }    
        return (Delivery_Schedule__c)controller.getRecord();
    }
    
    public DeliveryScheduleWrapper load(Delivery_Schedule__c delivery_schedule) {
       DeliveryScheduleWrapper wrapper = new DeliveryScheduleWrapper();
       wrapper.deliverySchedule = delivery_schedule;
       wrapper.items = new Map<Integer, List<ConsignmentItem__c>>();

        wrapper.consignments = [
                SELECT id, Name, Delivery_Schedule__c, Position__c, Due__c, ReceivedOn__c,Delivery_Location__c, Instructions__c, Status__c
                FROM Consignment__c 
                WHERE Delivery_Schedule__c = :wrapper.deliverySchedule.id
            ];
        for(Consignment__c consignment : wrapper.consignments) {
            loadItems(consignment,wrapper);
        }
        return wrapper;
    }
    
    public Boolean save(DeliveryScheduleWrapper wrapper) {
        Savepoint sp = Database.setSavepoint();
        try {
            wrapper.deliverySchedule.order__c = wrapper.selectedOrder.id;
            insert wrapper.deliverySchedule;
            
            Integer count = 1;
            Integer hubTypes = hubHelper.hubTypeCount(); 
            for (Consignment__c consignment : wrapper.consignments) {
                consignment.Delivery_Schedule__c = wrapper.deliverySchedule.id;
                insert consignment;
                
                for (ConsignmentItem__c item : wrapper.items.get(count)) {
                    item.Consignment__c = consignment.id;
                    upsert item;
                }
                count++; 
            }
            return true;
        } catch (Exception e) {
            ApexPages.addMessages(e);
            Database.rollback(sp);
            return false;
        }
    }
    
    public Boolean amend(DeliveryScheduleWrapper wrapper) {
        Savepoint sp = Database.setSavepoint();
        try {
            Integer count = 1;
            List<ConsignmentItem__c> updated_consignment_items = new List<ConsignmentItem__c>();
            for (Consignment__c consignment : wrapper.consignments) {
            	for (ConsignmentItem__c item : wrapper.items.get(count)) {
                    updated_consignment_items.add(item);
                }
            count++;
            }
            update wrapper.deliverySchedule;
            update wrapper.consignments;
            update updated_consignment_items;
            return true;
        } catch (Exception e) {
            Database.rollback(sp);
            apexpages.Message message = new Apexpages.Message(ApexPages.Severity.Error,'Cannot Save the Delivery Schedule');
            Apexpages.addMessage(message); 
            return false;
        }
    }
    
    public Consignment__c createConsignment(Integer index, DeliveryScheduleWrapper wrapper, String prdFamily){
    	
        Consignment__c consignment = new Consignment__c();
        consignment.Due__c = dateHelper.nextMonth().addDays((index -1) * 7);
        consignment.Position__c = index;
        consignment.Status__c = 'Created';
        List<Product2> products = hubHelper.hubTypes(prdFamily);
        List<ConsignmentItem__c> consignmentItems = new List<ConsignmentItem__c>();
        wrapper.items.put(index, consignmentItems);
        for (Product2 product : Products){
            ConsignmentItem__c item = new ConsignmentItem__c();
            item.Quantity__c = 0;
            item.Product__c = product.id;
            consignmentItems.add(item);
        }
        return consignment;
    } 
    
    private void loadItems(Consignment__c consignment, DeliveryScheduleWrapper wrapper) {
        List<ConsignmentItem__c> itemList = 
            [
                SELECT id, Name, Product__c, Quantity__c, Consignment__c ,Product__r.name
                 FROM ConsignmentItem__c 
                 WHERE Consignment__c = :consignment.id
            ];
        wrapper.items.put(consignment.Position__c.intValue(), itemList);
    }
    
    
    
           
}