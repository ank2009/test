/*
* @ Description :- Class handles all before and after events of OfferLineItem object
* @ Author      :- HCL Technologies LTD
* @ Date        :- 06-03-2013
**/

public without sharing class TLR_OfferLineItemTriggerHandler {

    private boolean isExecuting = false;
	public TLR_OfferLineItemTriggerHandler(boolean isExecuting){
        isExecuting = isExecuting;
    }

    public void OnBeforeInsert(Offer_Line_Item__c[] newOLItems, Offer_Line_Item__c[] oldOLItems, Map <Id,Offer_Line_Item__c> newOLItemsMap,Map <Id,Offer_Line_Item__c> oldOLItemsMap){
        // EXECUTE BEFORE INSERT LOGIC
        system.debug('Account Before insert is called################');
    }

    public void OnAfterInsert(Offer_Line_Item__c[] newOLItems, Offer_Line_Item__c[] oldOLItems, Map <Id,Offer_Line_Item__c> newOLItemsMap,Map <Id,Offer_Line_Item__c> oldOLItemsMap){
        // EXECUTE AFTER INSERT LOGIC
    }

    public void OnBeforeUpdate(Offer_Line_Item__c[] newOLItems, Offer_Line_Item__c[] oldOLItems, Map <Id,Offer_Line_Item__c> newOLItemsMap,Map <Id,Offer_Line_Item__c> oldOLItemsMap){
        // BEFORE UPDATE LOGIC
         /**
	     * Called by Trigger on Offer LineItem before Update
	     *
	     * Step 1: The system automatically applies the selected Volume Discount to all Offer Line Item Subservices of the pertinent Offer Line Item.
	     * Step 2: For each created Offer Line Item Subservice Volume Discount, the system automatically creates an Offer Line Item Subservice Volume Discount Line Item per Volume Discount Bracket of the selected Volume Discount. 
	     *
	    **/
        OfferLineItem.AppendVDToLineItemSubservice(newOLItems, oldOLItems);
    }

    public void OnAfterUpdate(Offer_Line_Item__c[] newOLItems, Offer_Line_Item__c[] oldOLItems, Map <Id,Offer_Line_Item__c> newOLItemsMap,Map <Id,Offer_Line_Item__c> oldOLItemsMap){
        // AFTER UPDATE LOGIC
    }

    public void OnBeforeDelete(Offer_Line_Item__c[] newOLItems, Offer_Line_Item__c[] oldOLItems, Map <Id,Offer_Line_Item__c> newOLItemsMap,Map <Id,Offer_Line_Item__c> oldOLItemsMap){
        // BEFORE DELETE LOGIC
    }

    public void OnAfterDelete(Offer_Line_Item__c[] newOLItems, Offer_Line_Item__c[] oldOLItems, Map <Id,Offer_Line_Item__c> newOLItemsMap,Map <Id,Offer_Line_Item__c> oldOLItemsMap){
        // AFTER DELETE LOGIC
        deletRightTemplates(oldOLItems);
    }

    public void OnUndelete(Offer_Line_Item__c[] newOLItems, Offer_Line_Item__c[] oldOLItems, Map <Id,Offer_Line_Item__c> newOLItemsMap,Map <Id,Offer_Line_Item__c> oldOLItemsMap){
        // AFTER UNDELETE LOGIC
    }

    public boolean IsTriggerContext{
        get{ return isExecuting;}
    }
    
    //Implement Delete Right Templates Logic-AFTER DELETE event
    public void deletRightTemplates(Offer_Line_Item__c[] oldOLItems){
    	Set<Id> OTIds = new Set<Id>();
    	List<Rights_Template_Default__c> listOfRTD = new List<Rights_Template_Default__c>();
    	if(! oldOLItems.isEmpty()){    		
    		for(Offer_Line_Item__c objOLT : oldOLItems){
    				OTIds.add(objOLT.Offer_Template__c);
    		}  		
    	}
    	if(!OTIds.isEmpty()){
    		for(Rights_Template_Default__c objRTD : [Select Id from Rights_Template_Default__c where Offer_Template__c IN : OTIds]){
    			listOfRTD.add(objRTD);
    		}
    	}
    	if(!listOfRTD.isEmpty()){
    		try{
    			delete listOfRTD;
    		}catch(Exception e){
    			System.debug('Rights_Template_Default__c Delete Failed=>'+e);
    		}
    	}    
    }//end of delete RTD
   
}