public class AlertEmailUtility {
	
	public static void sendEmailToContact(Contact notifycontact, ID templateId ){
	
            System.Debug('Mail Message to Contact'+notifycontact);
            Messaging.SingleEmailMessage notifyMail = new Messaging.SingleEmailMessage();
            notifyMail.setTemplateID(templateId); 
            notifyMail.setTargetObjectId(notifycontact.id);
            notifyMail.setSenderDisplayName('Telefonica:dev');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {notifyMail});
  	
	}

}