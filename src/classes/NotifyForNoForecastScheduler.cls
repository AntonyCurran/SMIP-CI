global class NotifyForNoForecastScheduler  implements Schedulable{
	
	global void execute(SchedulableContext SC) {
  		NotificationForNoForecast nc = new NotificationForNoForecast();
       database.executebatch(nc);
   }

}