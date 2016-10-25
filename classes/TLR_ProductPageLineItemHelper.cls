/**
 *	@describe A class to help with the custom [Base] Product's Line Item Details on [Base] Product VisualForce Pages.
 				(Specifically created to enhance the ATOS original selectProductServiceExt.cls )
 *	@author   Brian Kessler
 *  @date     2013 July 
 **/
public class TLR_ProductPageLineItemHelper 
{
	/**
	 *	@describe A private method to selects Product Line Item Record Type
	 *	@author   Brian Kessler
	 *  @date     2013 July 
	 *  @param    Id serviceRecordTypeId : The record Type for the original Service
	 *  @return   Id : Product Line Item Record Type Id
	 **/
	private static Id selectRecordType(Id serviceRecordTypeId)
	{
		return TLR_RecordTypeHelper.getId( 
												'Product_Line_Item__c', 
												(TLR_RecordTypeHelper.getName(serviceRecordTypeId).left(3) + ' Product Line Item')
											);
	}
	
	private static Map<Id, Id> FillRecordTypesMap()
	{ 
		Map<Id, Id> RTMap = new Map<Id, Id>();
		RTMap.put(
    		TLR_RecordTypeHelper.getId('Service__c','TAS Module'), 
    		TLR_RecordTypeHelper.getId('Product_Line_Item__c','TAS Module'));
    	
    	RTMap.put(
    		TLR_RecordTypeHelper.getId('Service__c','TAS Maintenance'), 
    		TLR_RecordTypeHelper.getId('Product_Line_Item__c','TAS Maintenance'));
    	
    	RTMap.put(
    		TLR_RecordTypeHelper.getId('Service__c','TAS Consulting'), 
    		TLR_RecordTypeHelper.getId('Product_Line_Item__c','TAS Consulting'));
    		
    	/*RTMap.put(
    		TLR_RecordTypeHelper.getId('Service__c','TLR Service'), 
    		TLR_RecordTypeHelper.getId('Product_Line_Item__c','TLR Product Line Item'));
    	RTMap.put(
    		TLR_RecordTypeHelper.getId('Service__c','TAS Service'), 
    		TLR_RecordTypeHelper.getId('Product_Line_Item__c','TAS Consulting'));*/
    		
    	return RTMap;
	}
	
	/**
	 *	@describe A method to save selected Services as [Base] Product Line Items
	 *	@author   Brian Kessler
	 *  @date     2013 July 
	 *  @param    List<String> checkboxValueList : List of checkboxValues (equates to list of Service Ids)
	 *  @param    Product__c product : The product the Services will be added to.
	 *  @return   PageReference : Where to [re]direct the enduser.
	 **/
    public static PageReference Save(List<String> checkboxValueList, Product__c product) 
    {
		List<Product_Line_Item__c> existingServiceList = [SELECT Service__c FROM Product_Line_Item__c WHERE Parent__c = :product.id];
		
		Set<Id> existingServiceSet = new Set<Id>();
		for (Product_Line_Item__c existingService : existingServiceList) { existingServiceSet.add(existingService.Service__c); }		

		Set<String> missingCheckboxValueList = new Set<String>();
        for (String checkboxValue : checkboxValueList)
        {
            if (!(existingServiceSet.contains(checkboxValue))) { missingCheckboxValueList.add(checkboxValue); }
        }            
        
        if (missingCheckboxValueList.size() == 0){ return (Utilities.Redirect(product.id)); }
        
        List <Service__c> serviceToCloneList = [ SELECT id, recordTypeId FROM Service__c WHERE id IN :missingCheckboxValueList ];

		Set<Id> serviceRecordTypSet = new Set<Id>();
        for (Service__c serviceToClone : serviceToCloneList) { serviceRecordTypSet.add(serviceToClone.recordTypeId); }
        Map<Id, String> serviceRecordTypeNameMape = TLR_RecordTypeHelper.getNameMap(serviceRecordTypSet);	 

		List<Product_Line_Item__c> newServiceList = new List<Product_Line_Item__c>();
		
		Map<Id, Id> RTMap = FillRecordTypesMap();
		
        for (Service__c serviceToClone : serviceToCloneList)
        {
                Product_Line_Item__c newService = new Product_Line_Item__c();
					                 newService.Parent__c    = product.id;
					                 newService.Service__c   = serviceToClone.id;
					                 if(RTMap.containsKey(serviceToClone.recordTypeId)) // to leave default value if no mapping
					                 	newService.RecordTypeId = RTMap.get(serviceToClone.recordTypeId); //selectRecordType(serviceToClone.recordTypeId); 
					                 newServiceList.add(newService);
        }        

        insert newServiceList;
        return (Utilities.Redirect(product.id));
    }

}