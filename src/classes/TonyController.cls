public with sharing class TonyController {
	
	public Delivery_Schedule__c deliverySched {get;set;}
	
	public TonyController()
	{
		deliverySched = new Delivery_Schedule__c();
	}

}