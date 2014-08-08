@isTest
public class HubHelperTest {
    private static HubHelper helper = new HubHelper();
    
    testMethod static void testAllHubsAreReturned(){
        setupHappyProducts();
        List<Product2> hubs = helper.hubTypes();
        System.assertEquals(hubs.size(), 2);
    }

    testMethod static void testHubsTypeCount(){
        setupHappyProducts();
        Integer hubs = helper.hubTypeCount();
        System.assertEquals(hubs, 2);
    }
    
    private static void setupHappyProducts() {
        Product2 product1 = new Product2(name='Hub1', family='Communication Hubs');
        insert product1;
        Product2 product2 = new Product2(name='Hub2', family='Communication Hubs');
        insert product2;
        insert new Product2(name='Hub3', family='Auxiliary Equipment');
    }
}