public class HubHelper {
    private List<Product2> hubTypes;
    //VG -- ADDED
    //private Integer hubTypesSize;
    
    //VG - Modified to make OrderType dynamically selected
    //public List<Product2> hubTypes() {
    public List<Product2> hubTypes(String prdFamily) {	
    	if (hubTypes == null){
    		//VG - Modified to make OrderType dynamically selected
        	//hubTypes = [SELECT name,id FROM Product2 WHERE Family = 'Communication Hubs'];
        	hubTypes = [SELECT name,id FROM Product2 WHERE Family =: prdFamily];
    	}
    	//if(hubTypesSize==null) {
    		//hubTypesSize=hubTypes.size();
    	//}
    	return hubTypes;
    }
    
    public Integer hubTypeCount() {
    	//VG Modified
        //return hubTypes().size();
        return hubTypes.size();
    }
}