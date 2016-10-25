public  class TR004ProductLI {

public static void UnlinkServicefromProduct(Product_Line_Item__c[] lstProductLI){
	
	PAD.myLog('START TR004ProductLI.UnlinkServicefromProduct');
		
	
		 Set<ID> setIdProductLIs = new Set<ID>();
		  Set<ID> setIdProducts = new Set<ID>();
		    for (Product_Line_Item__c ProductLI : lstProductLI) {
              
            setIdProductLIs.add(ProductLI.Id);
            setIdProducts.add(ProductLI.Parent__c);
            	 }
		
		Map<ID, Offer_template__c> lstOfferTemplate = new Map<ID, Offer_template__c >([select Name ,Base_Product__c from Offer_template__c  where Base_Product__c in :setIdProducts]);
						
		if (lstOfferTemplate.size()==0)
		delete lstProductLI;
		//else
		
		//system.addError('At least one subservice template must be activated first !');


			 
	
	
	PAD.myLog('END TR004ProductLI.UnlinkServicefromProduct');
	}


}