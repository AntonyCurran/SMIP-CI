trigger NotifyEmailOnOrderApproveOrReject on Order (after update) {
	
	Order ord = Trigger.new[0];
	
	System.debug('Order Changed is :'+ord);

}