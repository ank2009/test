/**
 * Name : PackageAndFeeExt
 * Created By : Ronnie Visser <r.visser@vivens.com>
 * Date : 2011-08-24
**/
public with sharing class PackageAndFeeExt {
    
    public final Offer_Package_And_Fee__c offerPackageAndFee{get;set;}
    
    
    public PackFee__c packFee{get;set;}
    
    /**
     * Class Constructor with standardController
     *
     * Type : Constructor
    **/ 
    public PackageAndFeeExt(ApexPages.StandardController controller) {
        this.packFee = (PackFee__c)controller.getRecord();
        this.packFee.Start_Date__c = Date.today();
        this.packFee.Status__c = 'Pending';
    }
    
    /** 
     * Default Class constructor
     *
     * Type : Constructor
    **/
    public PackageAndFeeExt(){
        
    }
    
    /**
     * Called by Trigger on LineItem before deletion
     * Here we check if user can delete a LineItem, of not add an error to current record
    **/
    public static void LineItemBeforeDelete( Package_and_Fee_Line_Item__c[] lineitems ){
        Id[] ids = new Id[]{};
        for( Package_and_Fee_Line_Item__c lineitem : lineitems ) {  
            ids.add(lineitem.Id);           
        }
        
        for( Package_and_Fee_Line_Item__c item : [Select Parent__r.Status__c,Parent__r.Name From Package_and_Fee_Line_Item__c Where Id IN :ids]){
            if( item.Parent__r.Status__c != 'Pending' ){
                System.debug('## item.PackFee__r.Name= '+item.Parent__r.Name);
                System.debug('## item.PackFee__r.Status__c = '+item.Parent__r.Status__c);
                //item.addError( 'Could not delete Package And Fee Line Item because parent is not in status Pending' );  
                throw new Generic.StandardException('Could not delete Package And Fee Line Item because parent is not in status Pending');
            }   
        }       
    }
    
    /**
     * Called by Trigger on Offer Package And Fee before deletion
     * Here we check if user can delete a Offer Promotion, of not add an error to current record
    **/
    public static void OfferPackageAndFeeBeforeDelete( Offer_Package_And_Fee__c[] offerPackageAndFees ){
        Id[] Ids = new Id[]{};
        for (Offer_Package_And_Fee__c offerPackageAndFee : offerPackageAndFees)
            Ids.add(offerPackageAndFee.Id);
        
        Map<ID, Offer_Package_And_Fee__c> mapIdOPF = new Map<ID, Offer_Package_And_Fee__c>([Select Offer_Template__r.Status__c From Offer_Package_And_Fee__c Where Id IN :ids]);
        
        for( Offer_Package_And_Fee__c item : offerPackageAndFees){
            if( mapIdOPF.get(item.Id).Offer_Template__r.Status__c != 'Pending' ){
                item.addError( 'Could not delete Offer Package And Fee because Offer Template is not in status Pending' );  
            }
        }
    }
        
    /**
     * Called by Trigger on Offer Package And Fee After Update
     *
     * This method will create some sort of clone of the Package And Fee Line items
     *
    **/
    public static void SaveOfferPackageAndFee( Offer_Package_And_Fee__c[] offerPackageAndFeeNew ){
        // First collect all data and create workable maps/list of it
        Map<Id, Offer_Package_And_Fee__c> offerPackageAndFee = new Map<Id, Offer_Package_And_Fee__c>();
        for(Offer_Package_And_Fee__c pf : offerPackageAndFeeNew){
            offerPackageAndFee.put( pf.Package_Fee__c, pf );    
        }
        
        // Create a Map with a List of Package_and_Fee_Line_Item__c so we can work with it
        if( offerPackageAndFee.size() > 0 ) {
            Map<Id,List<Package_and_Fee_Line_Item__c>> offerPackageAndFeeLineItem = new Map<Id,List<Package_and_Fee_Line_Item__c>>();
            for( Package_and_Fee_Line_Item__c lineItem : [Select Weight__c, Service__c, RecordTypeId, PackFee__c, Parent__c From Package_and_Fee_Line_Item__c Where Parent__r.Id IN: offerPackageAndFee.KeySet()]){
                List<Package_and_Fee_Line_Item__c> items;
                if(offerPackageAndFeeLineItem.containsKey(lineItem.Parent__c)) {
                    items = offerPackageAndFeeLineItem.get(lineItem.Parent__c);
                    items.add(lineItem);
                    offerPackageAndFeeLineItem.put(lineItem.Parent__c,items);
                } else {
                    items = new List<Package_and_Fee_Line_Item__c>();
                    items.add(lineItem);    
                    if( items != null ){
                        offerPackageAndFeeLineItem.put(lineItem.Parent__c,items);
                    }
                }   
            }
            
            //Create a Map of Services per Offer Template so we can check if service exists in offer template before insert
            Set<ID> offerTemplatesId = new Set<ID>();
            for (Offer_Package_and_Fee__c opf : offerPackageAndFeeNew)
                offerTemplatesId.add(opf.Offer_Template__c);
                
            Map<ID, Set<ID>> mapOTServs = new Map<ID, Set<ID>>();
            for (Offer_Template__c ot : [SELECT Id, (SELECT Id, Service__c FROM Offer_Line_Items__r) 
                                         FROM Offer_Template__c WHERE Id IN :offerTemplatesId])
            {
                mapOTServs.put(ot.Id, new Set<ID>());
                for (Offer_Line_Item__c otli : ot.Offer_Line_Items__r)
                    mapOTServs.get(ot.Id).add(otli.Service__c);
            }
            
            // Do the real action here, get all the line items and create Offer line items of them.
            Offer_Package_And_Fee_Line_Item__c[] offerLineItems = new Offer_Package_And_Fee_Line_Item__c[]{};
            ID tlrServRecType = Schema.getGlobalDescribe().get('Offer_Package_And_Fee_Line_Item__c').getDescribe().getRecordTypeInfosByName().get('TLR Offer P&F Line Item').getRecordTypeId();
            for( Offer_Package_And_Fee__c packageAndFee : offerPackageAndFee.values() ) {
                if( offerPackageAndFeeLineItem.get( packageAndFee.Package_Fee__c ) != null ){
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
            
            try {
                // And finally save the Offer line items
                insert offerLineItems;
            } catch( DMLException e ){
                // Error occured, debugger
                system.debug( 'Error inserting Offer Package And Fee LineItems' );      
            }   
        }       
    }
    
    /**
     * Called by Trigger on Offer Package And Fee After Update
    **/
    public static void UpdateOfferPackageAndFee(Offer_Package_And_Fee__c[] offerPFToUpdate)
    {
        // Remove old line items
        Set<ID> setIdOfferPF = new Set<ID>();
        for (Offer_Package_And_Fee__c offerPF : offerPFToUpdate)
            setIdOfferPF.add(offerPF.Id);
            
        List<Offer_Package_And_Fee_Line_Item__c> lstOfferPFLIs = [SELECT Id FROM Offer_Package_And_Fee_Line_Item__c WHERE Offer_Package_And_Fee__c IN :setIdOfferPF];
        if (lstOfferPFLIs.size() > 0)
            delete lstOfferPFLIs;
        
        // Add new line items
        SaveOfferPackageAndFee(offerPFToUpdate);
    }
}