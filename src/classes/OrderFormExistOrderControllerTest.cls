@isTest(SeeAllData=true)

public class OrderFormExistOrderControllerTest { 

    public static testMethod void testOrderFormController() {
		Schema.DescribeSObjectResult res = Order.SObjectType.getDescribe();        
        PageReference pgRf = new PageReference('/' + res.getKeyPrefix() + '/o');
        String pg1OrdTab=pgRf.getUrl();

        LIST<RecordType> RT=[Select Id,Name from RecordType where SobjectType='Order'];
        Account tst=new Account(Name='Test Account', Forecast_Start_Date__c=system.today());
        insert tst;
        ID accId=tst.Id;
        Order Order_rec = new Order(
            RecordTypeId=RT[2].Id,
            AccountId=tst.Id,
            EffectiveDate=system.today(),
            Status='Created'
        );
        System.debug('Record type is ' + RT[2].Name);
        insert Order_rec;
        ID ordRec=Order_rec.Id;

        pgRf = new ApexPages.StandardController(Order_rec).view();
        String pg1OrdView=pgRf.getUrl();
        
        PageReference pageRef = Page.OrderFormView;
        pageRef.getParameters().put('ID',Order_rec.Id);
        Test.setCurrentPage(pageRef);
            
        ApexPages.StandardController sc = new ApexPages.StandardController(Order_rec);
        OrderFormExistOrderController testPlan = new OrderFormExistOrderController(sc);        
        String pg=testPlan.cancel().getUrl();
        System.assertequals(pg1OrdTab,pg);
       
        if(testPlan.OIS.size()>0){
	    	testPlan.OIS[0].OrdItem.Quantity=10;
        	pg = testPlan.recsave().getUrl();
        	System.assertequals(pg1OrdView,pg);
        }

		//-----------------------------------------------------------------------
		String RectypeName = testPlan.getRecordTypeName(RT[2].Id);
		System.debug('Record type name: ' + RectypeName);
        LIST<Ord_PB_Mapping__c> OPB = [Select PriceBook_Name__c from Ord_PB_Mapping__c where Order_Record_Type__c =: RectypeName];
		System.debug('Price book name is ' + OPB[0].PriceBook_Name__c);
	    String PBName = OPB[0].PriceBook_Name__c;
    	Pricebook2 standardBook=[SELECT Id FROM Pricebook2 WHERE Name=: PBName];

        Order_rec.Pricebook2Id=standardBook.Id;
        
        update(Order_rec);
        
        
        LIST<OrderRT_ProductFLY_Mapping__c> OPM = [Select Product_Family__c from OrderRT_ProductFLY_Mapping__c where Order_Record_Type__c =: RectypeName];
      	String prdFamily=String.valueOf(OPM[0].Product_Family__c);
		List<Product2> searchList=[SELECT Id, ProductCode, Family, Name FROM Product2 where IsActive=true and Family=:prdFamily];
        
        for(Product2 tmp : searchList){
        	PricebookEntry entry = [SELECT Id, UnitPrice FROM PricebookEntry WHERE Pricebook2Id = :standardBook.Id AND Product2.ProductCode =: tmp.ProductCode];
        	OrderItem OrderItemRec=new OrderItem(
            	Quantity=10,
            	OrderId=ordRec,
            	PricebookEntryId=entry.Id,
            	UnitPrice=entry.UnitPrice
        	);
        
        	insert OrderItemRec;
        }
        if(testPlan.OIS.size()>0){
        	testPlan.OIS[0].OrdItem.Quantity=0;
        }
        
        pg = testPlan.recsave().getUrl();
        System.assertequals(pg1OrdView,pg);

        testPlan.OIS[0].OrdItem.Quantity=30;
        pg = testPlan.recsave().getUrl();
        System.assertequals(pg1OrdView,pg);

        
		//-----------------------------------------------------------------------        
        
        pg = testPlan.submit().getUrl();
        System.assertequals(pg1OrdTab,pg);
    }
}