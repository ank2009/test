public with sharing class TRIG_OfferPackageAndFeeTriggerHandler extends TRIG_TriggerHandlerAbstract
{
    public boolean IsTriggerContext { get { return isTriggerExecuting;} }

    public TRIG_OfferPackageAndFeeTriggerHandler (boolean isTriggerExecuting) 
    {
        super(isTriggerExecuting);
        
    }
    
    public override void OnBeforeInsert(List<sObject> newTriggerValues) { }
    public override void OnAfterInsert(List<sObject> newTriggerValues, Map<ID, sObject> newTriggerValuesMap) 
    { 
    	if (FollowUpTriggerOfferPackFeeAfterInsert.triggerToBeCalled())
        {
    		SaveOfferPack(newTriggerValues,newTriggerValuesMap);
        }
    }
    public override void OnBeforeUpdate (List<sObject> oldTriggerValues, List<sObject> newTriggerValues, Map<ID, sObject> oldTriggerValuesMap, Map<ID, sObject> newTriggerValuesMap) { }    
    public override void OnAfterUpdate  (List<sObject> oldTriggerValues, List<sObject> newTriggerValues, Map<ID, sObject> oldTriggerValuesMap, Map<ID, sObject> newTriggerValuesMap) 
    { 
    	UpdateOfferPackageAndFee(newTriggerValues,oldTriggerValuesMap,newTriggerValuesMap);
    }
    public override void OnBeforeDelete (List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap) 
    {
    	OfferPackageAndFeeBeforeDelete(oldTriggerValuesMap);
    }
    public override void OnAfterDelete  (List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap) {}
    public override void OnAfterUndelete(List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap) {}
    
    private void SaveOfferPack(List<Offer_Package_And_Fee__c> newTriggerValues, Map<ID, sObject> newTriggerValuesMap)
	{
        // Create a Map with a List of Package_and_Fee_Line_Item__c so we can work with it
        if(newTriggerValuesMap.size() > 0) 
        {
            Map<Id,List<Package_and_Fee_Line_Item__c>> offerPackageAndFeeLineItem = new Map<Id,List<Package_and_Fee_Line_Item__c>>();
            for(Package_and_Fee_Line_Item__c lineItem : [Select Weight__c, Service__c, RecordTypeId, PackFee__c, Parent__c From Package_and_Fee_Line_Item__c Where Parent__r.Id IN: newTriggerValuesMap.KeySet()])
            {
                List<Package_and_Fee_Line_Item__c> items;
                if(offerPackageAndFeeLineItem.containsKey(lineItem.Parent__c)) 
                {
                    items = offerPackageAndFeeLineItem.get(lineItem.Parent__c);
                    items.add(lineItem);
                    offerPackageAndFeeLineItem.put(lineItem.Parent__c,items);
                } 
                else 
                {
                    items = new List<Package_and_Fee_Line_Item__c>();
                    items.add(lineItem);    
                    if( items != null )
                    {
                        offerPackageAndFeeLineItem.put(lineItem.Parent__c,items);
                    }
                }   
            }
            
            //Create a Map of Services per Offer Template so we can check if service exists in offer template before insert
            Set<ID> offerTemplatesId = new Set<ID>();
            for (Offer_Package_and_Fee__c opf : newTriggerValues)
            {
                offerTemplatesId.add(opf.Offer_Template__c);
            }
                
            Map<ID, Set<ID>> mapOTServs = new Map<ID, Set<ID>>();
            for (Offer_Template__c ot : [SELECT Id, (SELECT Id, Service__c FROM Offer_Line_Items__r) 
                                         FROM Offer_Template__c WHERE Id IN :offerTemplatesId])
            {
                mapOTServs.put(ot.Id, new Set<ID>());
                for (Offer_Line_Item__c otli : ot.Offer_Line_Items__r)
                {
                    mapOTServs.get(ot.Id).add(otli.Service__c);
                }
            }
            
            // Do the real action here, get all the line items and create Offer line items of them.
            Offer_Package_And_Fee_Line_Item__c[] offerLineItems = new Offer_Package_And_Fee_Line_Item__c[]{};
            ID tlrServRecType = Schema.getGlobalDescribe().get('Offer_Package_And_Fee_Line_Item__c').getDescribe().getRecordTypeInfosByName().get('TLR Offer P&F Line Item').getRecordTypeId();
            for(SObject pack : newTriggerValuesMap.values()) 
            {
            	Offer_Package_And_Fee__c packageAndFee = (Offer_Package_And_Fee__c)pack;
                if( offerPackageAndFeeLineItem.get(packageAndFee.Package_Fee__c) != null )
                {
                    for( Package_and_Fee_Line_Item__c packageAndFeeLineItem : offerPackageAndFeeLineItem.get( packageAndFee.Package_Fee__c ) ) 
                    {
                        if (mapOTServs.containsKey(packageAndFee.Offer_Template__c))
                        {
                            if (mapOTServs.get(packageAndFee.Offer_Template__c).contains(packageAndFeeLineItem.Service__c))
                            {
                                Offer_Package_And_Fee_Line_Item__c offerLineItem = new Offer_Package_And_Fee_Line_Item__c();    
                                offerLineItem.CurrencyIsoCode                    = packageAndFee.CurrencyIsoCode;
                                offerLineItem.Weight__c                          = packageAndFeeLineItem.Weight__c;
                                offerLineItem.Service__c                         = packageAndFeeLineItem.Service__c;
                                offerLineItem.RecordTypeId                       = tlrServRecType;
                                offerLineItem.Offer_Package_And_Fee__c           = packageAndFee.Id;
                                offerLineItem.PackFee__c                         = packageAndFee.Id;
                                offerLineItem.PackFee_Line_Item__c               = packageAndFeeLineItem.Id;
                                offerLineItems.add( offerLineItem );
                            }
                        }
                    }   
                }   
            }
            
            try 
            {
                // And finally save the Offer line items
                insert offerLineItems; 
            } catch( DMLException e )
            {
                // Error occured, debugger
                system.debug( 'Error inserting Offer Package And Fee LineItems' );      
            }   
        }       
    }
    
    private void OfferPackageAndFeeBeforeDelete(Map<ID, sObject> oldTriggerValuesMap)
    {
        Map<ID, Offer_Package_And_Fee__c> mapIdOPF = new Map<ID, Offer_Package_And_Fee__c>([Select Offer_Template__r.Status__c From Offer_Package_And_Fee__c Where Id IN :oldTriggerValuesMap.keySet()]);
        
        for(SObject pack : oldTriggerValuesMap.values())
        {
        	Offer_Package_And_Fee__c item = (Offer_Package_And_Fee__c)pack;
            if(mapIdOPF.get(item.Id).Offer_Template__r.Status__c != 'Pending')
            {
                item.addError( 'Could not delete Offer Package And Fee because Offer Template is not in status Pending' );  
            }
        }
    }
    
    private  void UpdateOfferPackageAndFee(List<Offer_Package_And_Fee__c> newTriggerValues, Map<ID, sObject> oldTriggerValuesMap, Map<ID, sObject> newTriggerValuesMap)
    {
    	List<Offer_Package_And_Fee__c> offerPFToUpdate = new List<Offer_Package_And_Fee__c>();	
    	Set<ID> setIdForRemove = new Set<ID>();
    	for (Offer_Package_And_Fee__c offerPF : newTriggerValues)
    	{ 
        	Offer_Package_And_Fee__c beforeUpdate = (Offer_Package_And_Fee__c)oldTriggerValuesMap.get(offerPF.Id); 	
        	if (offerPF.Package_Fee__c != beforeUpdate.Package_Fee__c)
        	{
        		offerPFToUpdate.add(offerPF);
        		setIdForRemove.add(offerPF.id);
        	}
    	}
        
        if (offerPFToUpdate.size() > 0)
        {
            List<Offer_Package_And_Fee_Line_Item__c> lstOfferPFLIs = [SELECT Id FROM Offer_Package_And_Fee_Line_Item__c WHERE Offer_Package_And_Fee__c IN :setIdForRemove];
	        if(lstOfferPFLIs.size() > 0)
	            delete lstOfferPFLIs;
	        SaveOfferPack(newTriggerValues,newTriggerValuesMap);
        }
    }
}