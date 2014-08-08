public with sharing class AlertEmail {
	
	
	public void sendEmainAlert(EmailTemplate templateId, Contact contactObj, String DisplayName ){

		Messaging.SingleEmailMessage notifyMail = new Messaging.SingleEmailMessage();
        notifyMail.setTemplateID(templateId.Id); 
        notifyMail.setTargetObjectId(contactObj.id);
        notifyMail.setSenderDisplayName('Telefonica:Dev');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {notifyMail});
	}

}