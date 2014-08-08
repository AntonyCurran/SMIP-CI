global class NotificationForNoForecast implements Database.Batchable<sObject>{
   global String query;
    private List<Contact> contactList = new List<Contact>();
    EmailTemplate templateId = [Select id from EmailTemplate where name = 'NotifyDCCUserForNoForecast'];
    
   global Database.QueryLocator start(Database.BatchableContext BC)
   {
       System.debug('Apex job started');
       //Query results list of accounts who aren't yet submitted thier forecast for current month.
       query = 'select id,name from Account where id not in(select Account__c from Forecast_Header__c where CreatedDate = THIS_MONTH and Status__c!=\'Created\')'; 
      
       return Database.getQueryLocator(query); 
   }
  
   global void execute(Database.BatchableContext BC, List<Account> scope)
   {
       for(Account acc: scope) 
        {  
            System.debug('Job execute started for: '+acc);
            contactList = [select id, lastname, title from Contact where Accountid=:acc.id and Type__c='Notifier'];
             
            if(contactList.size()>0 && templateId!=null){
                try{ 
		                System.Debug('Mail Message to Contact'+contactList[0]);
		                AlertEmailUtility.sendEmailToContact(contactList[0], templateId.Id);
                }catch(EmailException em ){
                	System.debug('Mail sent failed for:'+ contactList[0].Title +' '+contactList[0].LastName);
                }
            }
        
         }
        System.debug('Apex job finished'); 
        
   }   
   global void finish(Database.BatchableContext BC) 
   {
       } 
}