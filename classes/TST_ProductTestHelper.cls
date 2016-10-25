/**
* @author		Brian Kessler (Brian_Kessler@epam.com)
* @date			2013 June 26
* @description	This class is intended to facilitate creating and populating dummy BaseProducts for unit testing.
**/
@isTest
public with sharing class TST_ProductTestHelper
{
	// Methods for creating one BaseProduct -----------------------------------------------------------------------

	/**	
	* @author		Brian Kessler (Brian_Kessler@epam.com)
	* @date			2013 June 26
	* @description	Method to create dummy BaseProduct for testing.
	* @param		Account dummyAccount : Which dummy Account to associate the dummy BaseProduct with.
	* @param		Id recordTypeId : Which BaseProduct Record Type to Create
	* @param		Boolean insertNow : Whether to insert into SFDC DB now, or wait for latter processing.
	* @return		Product__c
	**/
	public static Product__c createDummyProduct(string productName, Id recordTypeId, Boolean insertNow)
	{
		Product__c dummyBaseProduct = new Product__c();
		dummyBaseProduct.RecordTypeId              = recordTypeId;
 		dummyBaseProduct.Name     	             = productName;
		dummyBaseProduct.Status__c   		 		 = 'Pending';
		dummyBaseProduct.Access_Roles__c   		 = 'T_PRO';
		dummyBaseProduct.Access_Kind__c   		 = 'FTFR';
		dummyBaseProduct.Start_Date__c			 = Date.today();
		dummyBaseProduct.End_Date__c			 	 = Date.today();

		if (insertNow) 
		{ 
			insert dummyBaseProduct; 
		}	
		return dummyBaseProduct;
	}
	
	public static Product__c createDummyProduct(Id recordTypeId, Boolean insertNow)
	{
		Integer unique     = (Integer) (Math.random() * 2147483647);
		String  uniqueName = 'Dummy BaseProduct ' + unique;
		 
		Product__c dummyBaseProduct = new Product__c();
						  dummyBaseProduct.RecordTypeId              = recordTypeId;
 		  				  dummyBaseProduct.Name     	             = uniqueName;
		                  dummyBaseProduct.Status__c   		 		 = 'Pending';
		                  dummyBaseProduct.Access_Roles__c   		 = 'T_PRO';
		                  dummyBaseProduct.Access_Kind__c   		 = 'FTFR';
		                  dummyBaseProduct.Start_Date__c			 = Date.today();
		                  dummyBaseProduct.End_Date__c			 	 = Date.today();

		if (insertNow) { insert dummyBaseProduct; }	
		return dummyBaseProduct;
	}

	/**	
	* @author		Brian Kessler (Brian_Kessler@epam.com)
	* @date			2013 June 26
	* @description	Method to create dummy BaseProduct for testing; won't be inserted into SFDC DB at create time.
	* @param		Account dummyAccount : Which dummy Account to associate the dummy BaseProduct with.
	* @param		Id recordTypeId : Which BaseProduct Record Type to Create
	* @return		Product__c
	**/
	public static Product__c createDummyProduct(Id recordTypeId) 
	{ 
		return createDummyProduct(recordTypeId, false); 
	}

	/**	
	* @author		Brian Kessler (Brian_Kessler@epam.com)
	* @date			2013 July 03
	* @description	Method to update dummy BaseProduct status for testing.
	* @param		Product__c dummyBaseProduct : Which BaseProduct to activate.
	* @param		String status : desired status.
	* @param		Boolean updateNow : Whether to update in SFDC DB now, or wait for latter processing.
	* @return		Product__c
	**/
	public static Product__c updateDummyProductStatus (Product__c dummyBaseProduct, String status, Boolean updateNow) 
	{
        dummyBaseProduct.Status__c = status;
		if (updateNow) { update dummyBaseProduct; }	
		return dummyBaseProduct;
	}
	
	/**	
	* @author		Brian Kessler (Brian_Kessler@epam.com)
	* @date			2013 July 03
	* @description	Method to activate dummy BaseProduct for testing.
	* @param		Product__c dummyBaseProduct : Which BaseProduct to activate.
	* @param		Boolean updateNow : Whether to update in SFDC DB now, or wait for latter processing.
	* @return		Product__c
	**/
	public static Product__c activateDummyProduct (Product__c dummyBaseProduct, Boolean updateNow) 
	{
		return updateDummyProductStatus (dummyBaseProduct, 'Active', updateNow); 
	}

	/**	
	* @author		Brian Kessler (Brian_Kessler@epam.com)
	* @date			2013 July 03
	* @description	Method to create and activate dummy BaseProduct for testing.
	* @param		Id recordTypeId : Which BaseProduct Record Type to Create
	* @return		Product__c
	**/
	public static Product__c createActiveDummyProduct (Id recordTypeId)
	{
		return activateDummyProduct((
									updateDummyProductStatus(
										createDummyProduct( recordTypeId, true),
											'Pending Activation Approval',
											true)
								), true);	
	}

	// Methods for creating multiple BaseProducts -----------------------------------------------------------------------
	
	/**	
	* @author		Brian Kessler (Brian_Kessler@epam.com)
	* @date			2013 June 26
	* @description	Method to create dummy BaseProduct list for testing.
	* @param		Integer numberOfBaseProducts : How many BaseProducts to create
	* @param		Id recordTypeId : Which BaseProduct Record Type to Create
	* @param		Boolean insertNow : Whether to insert into SFDC DB now, or wait for latter processing.
	* @return		List<Product__c>
	**/
	public static List<Product__c> createDummyProductList( Id recordTypeId, Integer numberOfBaseProducts, Boolean insertNow)
	{
		List<Product__c> dummyBaseProductList = new List<Product__c>();
		for (Integer i=1; i<=numberOfBaseProducts; i++)
		{
			dummyBaseProductList.add(createDummyProduct( recordTypeId));
		}
		if (insertNow) { insert dummyBaseProductList; }	
		return dummyBaseProductList;
	}
	
	/**	
	* @author		Brian Kessler (Brian_Kessler@epam.com)
	* @date			2013 June 26
	* @description	Method to create dummy BaseProduct list for testing; won't be inserted into SFDC DB at create time.
	* @param		Integer numberOfBaseProducts : How many BaseProducts to create
	* @param		Id recordTypeId : Which BaseProduct Record Type to Create
	* @return		List<Product__c>
	**/
	public static List<Product__c> createDummyProductList(Id recordTypeId, Integer numberOfBaseProducts) 
	{ 
		return createDummyProductList(recordTypeId, numberOfBaseProducts, false); 
	}
	
	public static Product_Line_Item__c createProductWithLineItem(Product__c product, Service__c service, Boolean insertNow)
	{
		Product_Line_Item__c line = new Product_Line_Item__c();
		line.RecordTypeId = TLR_RecordTypehelper.getId('Product_Line_Item__c', 'TLR Product Line Item');
		line.Parent__c = product.Id;
		line.Service__c = service.Id;
		if (insertNow) 
		{ 
			insert line; 
		}	
		return line;
	}
}