/**
 * @author Nicolas Dolet
 * @date 23/12/2011
 * @description Test MyProducts
 */
@isTest
public class MyProductsTest {

    /**
     * @author Nicolas Dolet
     * @date 23/12/2011
     * @description test addPackage
     */
    public static testMethod void testAddPackage() {
        MyProducts.AddPackageInput input = new MyProducts.AddPackageInput();
        input.Login = 'TestLogin';
        input.Active = 'true';
        input.Product = 'T-PRO';
        input.PackName = 'Test PackName';
        input.ProratePaid = 'Test ProratePaid';
        input.CodeAppli = 'WEB3S';
//        input.SubscriptionType = ?
        
        Generic.StandardOutput output = MyProducts.addPackage(input);        
    }

    /**
     * @author Nicolas Dolet
     * @date 23/12/2011
     * @description test removePackage
     */
    public static testMethod void testRemovePackage() {
        MyProducts.RemovePackageInput input = new MyProducts.RemovePackageInput();
        input.Login = 'TestLogin';
        input.Product = 'T-PRO';
        input.PackName = 'Test PackName';
        input.CodeAppli = 'WEB3S';
//        input.SubscriptionType = ?
        
        Generic.StandardOutput output = MyProducts.removePackage(input);
    }

    /**
     * @author Nicolas Dolet
     * @date 23/12/2011
     * @description test getProducts
     */
    public static testMethod void testGetProducts() {
    
                                   List<ID> services = TestData.createTestServices(10);
                        Map<ID, Integer> serviceNbSA = new Map<ID, Integer>();
    
            for (ID id : services)
                serviceNbSA.put(id, 2);
                
            Map<ID, List<ID>> servWithServAttributes = TestData.createTestServiceAttributes(serviceNbSA);
                                        Id productId = TestData.createTestProductAndLineItems(services, false, true).Id;
    
        MyProducts.BasicUserInfo input = new MyProducts.BasicUserInfo();
        input.Login = 'TestLogin';
        input.Country = 'T-PRO';
        input.AccessKind = 'WEB3N';
        
        MyProducts.GetProductsResult output = MyProducts.getProducts(input);
    }

    /**
     * @author Nicolas Dolet
     * @date 23/12/2011
     * @description test readCompany
     */
    public static testMethod void testReadCompany()
    {
		List<ID> services = TestData.createTestServices(10);
        Map<ID, Integer> serviceNbSA = new Map<ID, Integer>();
        for (ID id : services)
			serviceNbSA.put(id, 2);
		
		TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
		
        Map<ID, List<ID>> servWithServAttributes = TestData.createTestServiceAttributes(serviceNbSA);
		Id productId = TestData.createTestProductAndLineItems(services, false, true).Id;
		
		Account a = TST_AccountTestHelper.createDummyAccount(true);
        Contact c = TST_ContactTestHelper.createDummyContact(a, TLR_RecordTypeHelper.getId('Contact', 'TLR Contact'), true);
		
        String tstLogin = 'TSTLOGIN';
        c.Username__c = tstLogin;
        MyProducts.ReadCompanyInput input = new MyProducts.ReadCompanyInput();
        input.ContactLogin = tstLogin;
        
        MyProducts.ReadCompanyOutput output = MyProducts.readCompany(input);
    }

    /**
     * @author Nicolas Dolet
     * @date 23/12/2011
     * @description test readProfile 
     */
    public static testMethod void testReadProfile ()
    {
		List<ID> services = TestData.createTestServices(10);
        Map<ID, Integer> serviceNbSA = new Map<ID, Integer>();
        for (ID id : services)
            serviceNbSA.put(id, 2);

		TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Map<ID, List<ID>> servWithServAttributes = TestData.createTestServiceAttributes(serviceNbSA);
        Id productId = TestData.createTestProductAndLineItems(services, false, true).Id;
        Account a = TST_AccountTestHelper.createDummyAccount(true);
        Contact c = TST_ContactTestHelper.createDummyContact(a, TLR_RecordTypeHelper.getId('Contact', 'TLR Contact'), true);

        String tstLogin = 'TSTLOGIN';
        c.Username__c = tstLogin;

        MyProducts.ReadProfileContactOutput output = MyProducts.ReadProfile(tstLogin);
    }
}