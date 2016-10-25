/**
 * Name : OfferPromotionExt
 * Created By : Ronnie Visser <r.visser@vivens.com>
 * Date : 2011-08-24
**/
public with sharing class OfferPromotionExt 
{
    /**
     * Will contain the Promotion given by the stdController
     * 
    **/
    public Offer_Promo__c offerPromotion{get;set;}
    
    /**
     * To toggle all on or off
     * 
    **/
    public List<String> valChk{get;set;}
    
    /**
     * All available options
     * 
    **/
    public List<SelectOption> options;
    
    /**
     * Error management
     * 
    **/
    public Boolean error {get; set;}
    
    /**
     * Title
     * 
    **/
    public String title {get; set;}
        
    /**
     * Class Constructor with standardController
     *
     * Type : Constructor
    **/ 
    public OfferPromotionExt(ApexPages.StandardController controller) 
    {
        Id offerPromoId = System.currentPagereference().getParameters().get('promoId');
        this.offerPromotion = [SELECT Id, Level__c, Offer_Template__r.Status__c, CurrencyIsoCode 
                               FROM Offer_Promo__c
                               WHERE Id = :offerPromoId];
        this.error = false;
    }
    
    /**
     * Called by Trigger on Offer Promotion After Update
     *
     * This method will create some sort of clone of the Promotion Line items
     *
    **/
    public static void SaveOfferPromotion( Offer_Promo__c[] offerPromotionNew ) {
        // First collect all data and create workable maps/list of it
        Map<Id, Offer_Promo__c> offerPromotion = new Map<Id, Offer_Promo__c>();
        for(Offer_Promo__c pm : offerPromotionNew){
            offerPromotion.put( pm.Promotion__c, pm );  
        }
        
        // Create a Map with a List of Package_and_Fee_Line_Item__c so we can work with it
        if( offerPromotion.size() > 0 ) {
            Map<Id,List<Promotion_Line_Item__c>> offerPromotionLineItem = new Map<Id,List<Promotion_Line_Item__c>>();
            for( Promotion_Line_Item__c lineItem : [Select Sort_Order__c, Promotion__c, Name, Min_Duration__c, Max_Duration__c, Duration_Type__c
                                                    From Promotion_Line_Item__c Where Promotion__c IN: offerPromotion.KeySet()]){
                List<Promotion_Line_Item__c> items;
                if(offerPromotionLineItem.containsKey(lineItem.Promotion__c)) {
                    items = offerPromotionLineItem.get(lineItem.Promotion__c);
                    items.add(lineItem);
                    offerPromotionLineItem.put(lineItem.Promotion__c,items);
                } else {
                    items = new List<Promotion_Line_Item__c>();
                    items.add(lineItem);    
                    if( items != null ){
                        offerPromotionLineItem.put(lineItem.Promotion__c,items);
                    }
                }   
            }
            // Do the real action here, get all the line items and create Offer line items of them.
            Offer_Promo_Line_Item__c[] offerLineItems = new Offer_Promo_Line_Item__c[]{};
            //ID tlrServRecType = Schema.getGlobalDescribe().get('Offer_Package_And_Fee_Line_Item__c').getDescribe().getRecordTypeInfosByName().get('TLR Offer P&F Line Item').getRecordTypeId();
            for( Offer_Promo__c promotion : offerPromotion.values() ) {
                if( offerPromotionLineItem.get( promotion.Promotion__c ) != null ){
                    for( Promotion_Line_Item__c promotionLineItem : offerPromotionLineItem.get( promotion.Promotion__c ) ) {
                        Offer_Promo_Line_Item__c offerLineItem = new Offer_Promo_Line_Item__c();    
                        offerLineItem.Min_Duration__c = promotionLineItem.Min_Duration__c;
                        offerLineItem.Max_Duration__c = promotionLineItem.Max_Duration__c;
                        offerLineItem.CurrencyIsoCode = promotion.CurrencyIsoCode;
                        offerLineItem.Promotion_Line_Item__c = promotionLineItem.Id;
                        offerLineItem.Offer_Promotion__c = promotion.Id;
                        //offerLineItem.Offer_Template__c = promotion.Offer_Template__c;
                        offerLineItem.Min_Price__c = 0;
                        offerLineItem.Max_Price__c = 0;
                        offerLineItems.add( offerLineItem );
                    }       
                }
            }
            
            try {
                // And finally save the Offer line items
                insert offerLineItems;
            } catch( DmlException e ){
                // Error occured, debugger
                system.debug( 'Error inserting Offer Promotion LineItems' );
                throw e;        
            }   
        }       
    }
    
    /**
     * Called by Trigger on Offer Promotion After Update
    **/
    public static void UpdateOfferPromotion(Offer_Promo__c[] offerPromoToUpdate)
    {
        // Remove old line items
        Set<ID> setIdOfferPromos = new Set<ID>();
        for (Offer_Promo__c offerPromo : offerPromoToUpdate)
            setIdOfferPromos.add(offerPromo.Id);
            
        List<Offer_Promo_Line_Item__c> lstOfferPromoLIs = [SELECT Id FROM Offer_Promo_Line_Item__c WHERE Offer_Promotion__c IN :setIdOfferPromos];
        if (lstOfferPromoLIs.size() > 0)
            delete lstOfferPromoLIs;
        
        
        // Add new line items
        SaveOfferPromotion(offerPromoToUpdate);
    }
    
    /**
     * Called by Trigger on Offer Promotion before deletion
     * Here we check if user can delete a Offer Promotion, of not add an error to current record
    **/
    public static void OfferPromotionBeforeDelete( Offer_Promo__c[] offerPromos ) 
    {
        Id[] Ids = new Id[]{};
        for (Offer_Promo__c offerPromo : offerPromos)
            Ids.add(offerPromo.Id);
        
        Map<ID, Offer_Promo__c> mapIdOfferPromo = new Map<ID, Offer_Promo__c>([Select Offer_Template__r.Status__c From Offer_Promo__c Where Id IN :ids]);
        
        for( Offer_Promo__c item : offerPromos)
        {  
            if( mapIdOfferPromo.get(item.Id).Offer_Template__r.Status__c != 'Pending' ){
                item.addError( 'Could not delete Offer Promotion because Offer Template is not in status Pending' );    
            }
        }
    }
    
    public PageReference init() 
    {
        if (this.offerPromotion.Offer_Template__r.Status__c != 'Pending')
        {
            this.error = true;
            this.title = 'Error';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
            'You can link items only if Offer Template is under \'Pending\' status'));
             
            return null;
        }
        else if (this.offerPromotion.Level__c == 'Subscription')
        {
            this.error = true;
            this.title = 'Error';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
             'You cannot link items if the Offer Promotion level is ' +
             '"Subscription"'));
             return null;
        }

        if (options == null)
            options = new SelectOption[0];
        if (valChk == null)
            valChk = new String[0];
        
        if (this.offerPromotion.Level__c == 'Service(s)')
        {
            this.title = 'Select SubService(s)';
            
            /*Id[] services = new Id[]{};
            for( Offer_Line_Item__c offerLineItem : [Select Id, Service__c From Offer_Line_Item__c Where Offer_template__r.Id =: ApexPages.currentPage().getParameters().get('offerTemplateId') ] ){
                services.add( offerLineItem.Service__c );   
            }
            
            Id[] subServices = new Id[]{};
            for( Subservice__c subservice : [Select Id, Name From Subservice__c Where Parent_Service__c IN :services] ){
                options.add( new SelectOption( subservice.Id, subservice.Name ) );
            }*/
            
            for (Offer_Item_Subservice__c offerItemSubservice : [SELECT Id, Name 
                                                                 FROM Offer_Item_Subservice__c 
                                                                 WHERE Offer_Line_Item__r.Offer_template__r.Id =: ApexPages.currentPage().getParameters().get('offerTemplateId')
                                                                 ORDER BY Name ASC])
                options.add(new SelectOption(offerItemSubservice.Id, offerItemSubservice.Name));
        }
        
        if (this.offerPromotion.Level__c == 'Package(s)/Fee(s)')
        {
            this.title = 'Select Offer Package(s) and Fee(s)';
            
            for (Offer_Package_And_Fee__c offerPackageAndFee : [SELECT Id, Name 
                                                                FROM Offer_Package_And_Fee__c 
                                                                WHERE Offer_template__r.Id =: ApexPages.currentPage().getParameters().get('offerTemplateId')
                                                                ORDER BY Name ASC])
                options.add(new SelectOption(offerPackageAndFee.Id, offerPackageAndFee.Name));
        }
        
        // Error case : no data
        if (options.size() == 0 && this.offerPromotion.Level__c == 'Service(s)')
        {
            this.error = true;
            this.title = 'Error';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
             'There is no available subservice to link.'));
        }
        else if (options.size() == 0 && this.offerPromotion.Level__c == 'Package(s)/Fee(s)')
        {
            this.error = true;
            this.title = 'Error';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
             'There is no available package or fee to link.'));
        }
        
        return null;
    }
    
    public PageReference savePromoLink()
    {
        Offer_Promo_Link__c[] promoLinks = new Offer_Promo_Link__c[]{}; 

        if (this.offerPromotion.Level__c == 'Service(s)')
        {
            for (String offerItemSub : valChk) 
            {
                Offer_Promo_Link__c promoLink      = new Offer_Promo_Link__c(); 
                promoLink.Offer_Item_Subservice__c = offerItemSub;
                promoLink.CurrencyIsoCode          = this.offerPromotion.CurrencyIsoCode;
                promoLink.Offer_Promotion__c       = ApexPages.currentPage().getParameters().get('promoId');
                promoLinks.add(promoLink);    
            }
        }
        
        if (this.offerPromotion.Level__c == 'Package(s)/Fee(s)')
        {
            for (String offerPackAndFee : valChk) 
            {
                Offer_Promo_Link__c promoLink      = new Offer_Promo_Link__c(); 
                promoLink.Offer_Package_And_Fee__c = offerPackAndFee;
                promoLink.CurrencyIsoCode          = this.offerPromotion.CurrencyIsoCode;
                promoLink.Offer_Promotion__c       = ApexPages.currentPage().getParameters().get('promoId');
                promoLinks.add(promoLink);
            }
        }
        
        try
        {
            insert promoLinks;
            return Utilities.Redirect(ApexPages.currentPage().getParameters().get('promoId'));
        }
        catch(DmlException e)
        {
            ApexPages.addMessages(e);
            return null;
        }
    }
    
    /**
     * Getter method for all available SelectOptions
     * 
    **/
    public List<SelectOption> getOptions() {
        return options;
    }
    
    public void selectAll() {
        valChk.clear();
        for (SelectOption s : options)
            valChk.add(s.getValue());
    }
    
    public void deselectAll() {
        valChk.clear();
    }
    
    public PageReference Cancel()
    {
        return Utilities.Redirect(ApexPages.currentPage().getParameters().get('promoId'));
    }
}