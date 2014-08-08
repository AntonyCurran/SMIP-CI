public abstract class AbstractComponentController {
	public   AbstractParentController parentController	{get;set
		{
			if(value!=null) 
			{
				parentController = value;
			} 
			
		}}
	public static  String NEW_MODE  					{get{ return 'NEW';}}
	public static  String EDIT_MODE 					{get{ return 'EDIT';}}
	public static  String VIEW_MODE 					{get{ return 'VIEW';}}
	public         String modeOfScreen 					{get;set;}
	public abstract boolean save();  
	public abstract boolean amend(); 
    
	
}