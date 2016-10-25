/**
* @author       Brian Kessler (Brian_Kessler@epam.com)
* @date         2013 June 26
* @description  This class is intended to facilitate creating and populating dummy OfferTemplates for unit testing.
**/
@isTest
public class TST_OfferTemplateTestHelper
{
	// Methods for creating one OfferTemplate -----------------------------------------------------------------------

	/**	
	* @author		Brian Kessler (Brian_Kessler@epam.com)
	* @date			2013 June 26
	* @description	Method to create dummy OfferTemplate for testing.
	* @param		Product__c dummyBaseProduct : Which dummy Base Product to associate the dummy OfferTemplate with.
	* @param		Id recordTypeId : Which OfferTemplate Record Type to Create
	* @param		Boolean insertNow : Whether to insert into SFDC DB now, or wait for latter processing.
	* @return		OfferTemplate
	**/
	public static Offer_Template__c createDummyOfferTemplate(Product__c dummyBaseProduct, Id recordTypeId, Boolean insertNow)
	{
		Integer unique     = (Integer) (Math.random() * 2147483647);
		String  uniqueName = 'Dummy OfferTemplate ' + unique;
		
		Offer_Template__c dummyOfferTemplate = new Offer_Template__c();
		dummyOfferTemplate.RecordTypeId              = recordTypeId;
		dummyOfferTemplate.Name     	               = uniqueName;
        dummyOfferTemplate.Access_Kind__c   		   = 'FTFR';
        dummyOfferTemplate.Base_Product__c   		   = dummyBaseProduct.id;
		
        dummyOfferTemplate.Contract_Term__c   	   = 30;
        dummyOfferTemplate.Default_Invoice_Level__c  = 'Site';
        dummyOfferTemplate.Default_Invoice_Media__c  = 'Site';
        dummyOfferTemplate.Default_Payment_Method__c = 'Direct Debit';
        dummyOfferTemplate.CurrencyIsoCode		   = 'EUR';
        dummyOfferTemplate.Start_Date__c			   = Date.today();
		
		if (insertNow) { insert dummyOfferTemplate; }	
		return dummyOfferTemplate;
	}
	
	public static Offer_Template__c createDummyOfferTemplate(Id recordTypeId, Boolean insertNow)
	{
		Product__c baseProduct = TST_ProductTestHelper.createActiveDummyProduct(TLR_RecordTypeHelper.getId('Product__c', 'TLR Product'));
		return createDummyOfferTemplate(baseProduct, recordTypeId, insertNow);
	}

	/**	
	* @author		Brian Kessler (Brian_Kessler@epam.com)
	* @date			2013 June 26
	* @description	Method to create dummy OfferTemplate for testing; won't be inserted into SFDC DB at create time.
	* @param		Product__c dummyBaseProduct : Which dummy Base Product to associate the dummy OfferTemplate with.
	* @param		Id recordTypeId : Which OfferTemplate Record Type to Create
	* @return		OfferTemplate
	**/
	public static Offer_Template__c createDummyOfferTemplate(Product__c dummyBaseProduct, Id recordTypeId) 
	{ 
		return createDummyOfferTemplate(dummyBaseProduct, recordTypeId); 
	}
	

	// Methods for creating multiple OfferTemplates -----------------------------------------------------------------------
	
	/**	
	* @author		Brian Kessler (Brian_Kessler@epam.com)
	* @date			2013 June 26
	* @description	Method to create dummy OfferTemplate list for testing.
	* @param		Product__c dummyBaseProduct : Which dummy Base Product to associate the dummy OfferTemplate with.
	* @param		Id recordTypeId : Which OfferTemplate Record Type to Create
	* @param		Integer numberOfOfferTemplates : How many OfferTemplates to create

	* @param		Boolean insertNow : Whether to insert into SFDC DB now, or wait for latter processing.
	* @return		List<OfferTemplate>
	**/
	public static List<Offer_Template__c> createDummyOfferTemplateList(Product__c dummyBaseProduct, Id recordTypeId, Integer numberOfOfferTemplates, Boolean insertNow)
	{
		List<Offer_Template__c> dummyOfferTemplateList = new List<Offer_Template__c>();
		for (Integer i=1; i<=numberOfOfferTemplates; i++)
		{
			dummyOfferTemplateList.add(createDummyOfferTemplate(dummyBaseProduct, recordTypeId));
		}
		if (insertNow) { insert dummyOfferTemplateList; }	
		return dummyOfferTemplateList;
	}
	
	/**	
	* @author		Brian Kessler (Brian_Kessler@epam.com)
	* @date			2013 June 26
	* @description	Method to create dummy OfferTemplate list for testing; won't be inserted into SFDC DB at create time.
	* @param		Product__c dummyBaseProduct : Which dummy Base Product to associate the dummy OfferTemplate with.
	* @param		Id recordTypeId : Which OfferTemplate Record Type to Create
	* @param		Integer numberOfOfferTemplates : How many OfferTemplates to create
	* @param		Id recordTypeId : Which OfferTemplate Record Type to Create
	* @return		List<OfferTemplate>
	**/
	public static List<Offer_Template__c> createDummyOfferTemplateList(Product__c dummyBaseProduct, Id recordTypeId, Integer numberOfOfferTemplates) 
	{ 
		return createDummyOfferTemplateList(dummyBaseProduct, recordTypeId, numberOfOfferTemplates, false); 
	}


    /**
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2013 September 26
    * @description  Method to perform offer template activation inaccordance to validation rules
    **/
    public static void activateOfferTemplate(Offer_Template__c offerTemplate)
    {
    	// we will perform consequent activation
    	if(offerTemplate.Status__c == 'Pending')
    	{
    		offerTemplate.Status__c = 'Pending Approval for Activation';
    		update offerTemplate;
    	}
    	if(offerTemplate.Status__c == 'Pending Approval for Activation')
    	{
    		offerTemplate.Status__c = 'Active';
    		update offerTemplate;
    	}
    }
    
    public static Offer_Template__c createFullOfferTemplate(string productName, string offerName, List<String> packageNames)
    {
    	Service__c ser = new  Service__c();
        ser.Name = 'TestServ';
        ser.Status__c = 'Pending';
        ser.Billable_Service__c = true;
        ser.Start_Date__c = Date.Today();
        insert ser;
        
        Product__c product = TST_ProductTestHelper.createDummyProduct(productName,TLR_RecordTypehelper.getId('Product__c', 'TLR Product'), true);
	    TST_ProductTestHelper.updateDummyProductStatus(product, 'Pending Activation Approval', true);
	    TST_ProductTestHelper.activateDummyProduct(product, true);
        
        Product_Line_Item__c pLine = new Product_Line_Item__c();
        pLine.Parent__c = product.Id;
        pLine.Service__c = ser.Id;
        
        List<PackFee__c> packages = new List<PackFee__c>();
        for(String name:packageNames)
        {
            PackFee__c pack = new PackFee__c();
            pack.Name = name;
            pack.Type__c = 'Fee';
            pack.Level__c = 'Subscription';
            pack.Status__c = 'Pending';
            pack.CurrencyIsoCode = 'EUR';
            pack.Frequency__c = 'Monthly';
            pack.Start_Date__c = Date.Today();
            packages.add(pack);
        }      
		insert packages;     
        
        Service_Attribute__c serAttr = new Service_Attribute__c();
        serAttr.RecordTypeId = TLR_RecordTypehelper.getId('Service_Attribute__c', 'TLR Service Attribute');
        serAttr.Access_Role__c = 'DailyReposting';
        serAttr.Name = 'Active Daily Reposting';
        serAttr.Start_Date__c = Date.today();
        serAttr.Parent__c = ser.Id;
        serAttr.Status__c = 'Pending';
        insert serAttr;
        
        Service_Attribute_Template__c serTempAttr = new Service_Attribute_Template__c();
        serTempAttr.Name = 'TestServAttr';
        serTempAttr.Start_Date__c = Date.today();
        serTempAttr.Default__c = true;
        serTempAttr.Parent__c = ser.Id;
        insert serTempAttr;
        
        Service_Attribute_Template_Line_Item__c serAtrrTempLine = new Service_Attribute_Template_Line_Item__c();
        serAtrrTempLine.Service_Attribute__c = serAttr.Id;
        serAtrrTempLine.Service_Attribute_Template__c = serTempAttr.Id;
        insert serAtrrTempLine;
        
        Subservice__c subSer = new Subservice__c();
        subSer.Start_Date__c = Date.Today();
        subSer.Status__c = 'Pending';
        subSer.Attribute__c ='asdas';
        subSer.Name = 'Name';
        subSer.Parent_Service__c = ser.Id;
        insert subSer;
        
        
        Subservice_Template__c subServTemp = new Subservice_Template__c();
        subServTemp.Name ='asds';
        subServTemp.Parent_Service__c = ser.Id;
        subServTemp.Start_Date__c = Date.Today(); 
        insert subServTemp;
        
        
        Subservice_Template_Line_Item__c subServLI = new Subservice_Template_Line_Item__c();
        subServLI.Template__c = subServTemp.Id;
        subServLI.Subservice__c = subSer.Id;
        insert subServLI;
        subSer.Status__c = 'Active';
        update subSer;
        ser.Status__c = 'Active';
        update ser; 
        
        List<Package_and_Fee_Line_Item__c> packLines = new List<Package_and_Fee_Line_Item__c>();
        for(PackFee__c p:packages)
        {
            Package_and_Fee_Line_Item__c packLine = new Package_and_Fee_Line_Item__c();
            packLine.PackFee__c = p.Id;
            packLine.Service__c = ser.Id;
            packLine.Parent__c = p.Id;
            packLine.Weight__c = 1;  
            packLines.add(packLine);
            p.Status__c = 'Active';
        }
        insert packLines;       
        update packages;
        
        Offer_Template__c off = TST_OfferTemplateTestHelper.createDummyOfferTemplate(product, TLR_RecordTypehelper.getId('Offer_Template__c', 'TLR Offer Template'), true);
        
        Offer_Line_Item__c offLine = new Offer_Line_Item__c();
        offLine.Billable_Service__c = true;
        offLine.Offer_Template__c = off.Id;
        offLine.Service__c = ser.Id;
        offLine.Service_Attribute_Template__c = serTempAttr.Id;
        insert offLine;
        List<Offer_Package_And_Fee__c> offPacks = new List<Offer_Package_And_Fee__c>();
        for(PackFee__c p:packages)
        {
            Offer_Package_And_Fee__c offPack = new Offer_Package_And_Fee__c();
            offPack.Package_Fee__c = p.Id;
            offPack.Name = p.Name;
            offPack.Max_Price__c = 100;
            offPack.Min_Price__c = 0;
            offPack.Offer_Template__c = off.Id;
            offPacks.add(offPack);
        }
        insert offPacks;
        List<Offer_Package_And_Fee_Line_Item__c> offPackLines= new List<Offer_Package_And_Fee_Line_Item__c>();
        Integer i=0;
        for(Offer_Package_And_Fee__c p:offPacks)
        {
            Offer_Package_And_Fee_Line_Item__c offPackLine = new Offer_Package_And_Fee_Line_Item__c();
            offPackLine.Offer_Package_And_Fee__c = p.Id;
            offPackLine.PackFee__c = p.Id;
            offPackLine.PackFee_Line_Item__c = packLines[i].Id;
            offPackLine.Service__c = ser.id;
            offPackLines.add(offPackLine);
            i++;
        }
        insert offPackLines;
        
        off.Name = offerName;
        off.Status__c = 'Pending Approval for Activation';
        update off;
        TST_OfferTemplateTestHelper.activateOfferTemplate(off);
        return off;
    }
}