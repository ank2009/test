/**
 * Name : OfferLineItem
 * Created By : Ronnie Visser <r.visser@vivens.com>
 * Date : 2011-08-30
**/
public class OfferLineItem {
    /**
     * Called by Trigger on Offer LineItem before Update
     *
     * Step 1: The system automatically applies the selected Volume Discount to all Offer Line Item Subservices of the pertinent Offer Line Item.
     * Step 2: For each created Offer Line Item Subservice Volume Discount, the system automatically creates an Offer Line Item Subservice Volume Discount Line Item per Volume Discount Bracket of the selected Volume Discount. 
     *
    **/
    public static void AppendVDToLineItemSubservice( Offer_Line_Item__c[] offerLineItems, Offer_Line_Item__c[] offerLineItemsOld ){
        Savepoint sp = Database.setSavepoint();     
        
        // Create a map of old data so we can get it. 
        Map<Id,Offer_Line_Item__c> oldMap = new Map<Id,Offer_Line_Item__c>();
        for(Offer_Line_Item__c oliOld : offerLineItemsOld ){
            oldMap.put( oliOld.Id, oliOld );    
        }
        
        //Create a map of new Ids based on if the Service_Volume_Discount__chas been changed 
        Map<Id, Offer_Line_Item__c> offerLineItem = new Map<Id, Offer_Line_Item__c>();
        for(Offer_Line_Item__c oli : offerLineItems){
            if( oldMap.get(oli.Id).Service_Volume_Discount__c != oli.Service_Volume_Discount__c ) {
                offerLineItem.put( oli.Id, oli );
            }   
        }
        
        // If there are Offer Line Item returned
        if( offerLineItem.size() > 0 ){
            Map<Id,List<Offer_Item_Subservice__c>> offerItemSubservices = new Map<Id,List<Offer_Item_Subservice__c>>();
            for( Offer_Item_Subservice__c subservice : [Select Id, Name, Volume_Discount_cb__c, Unit_Type__c, Subservice__c, Min_Price__c, Max_Price__c, Frequency__c, Billing_Base__c, Applied_To__c, Offer_Line_Item__c, Subservice_Volume_Discount__c, CurrencyIsoCode From Offer_Item_Subservice__c Where Offer_Line_Item__c IN :offerLineItem.KeySet()] ){
                List<Offer_Item_Subservice__c> items;
                if(offerItemSubservices.containsKey(subservice.Offer_Line_Item__c)) {
                    items = offerItemSubservices.get(subservice.Offer_Line_Item__c);
                    items.add(subservice);
                    offerItemSubservices.put(subservice.Offer_Line_Item__c,items);
                } else {
                    items = new List<Offer_Item_Subservice__c>();
                    items.add(subservice);  
                    if( items != null ){
                        offerItemSubservices.put(subservice.Offer_Line_Item__c,items);
                    }
                }   
            }
            
            //Build a list of subservices that needs to be updated
            // STEP 1
            Offer_Item_Subservice__c[] toUpdateSubservices = new Offer_Item_Subservice__c[]{}; 
            for(Offer_Line_Item__c oli : offerLineItems){
                Offer_Item_Subservice__c[] toUpdateSubservice = offerItemSubservices.get( oli.Id );
                for( Offer_Item_Subservice__c toUpdate : toUpdateSubservice ){
                    toUpdate.Subservice_Volume_Discount__c = oli.Service_Volume_Discount__c;
                    toUpdateSubservices.add( toUpdate );
                }   
            }
            
            try {
                update toUpdateSubservices; //STEP 1
            } catch( DmlException e ){
                system.debug( 'Subservice could not be updated' );
                throw e;
            }   
            
            // STEP 2
            Set<Id> vdIds = new Set<Id>();
            for( Offer_Item_Subservice__c VDitem : toUpdateSubservices ) {
                vdIds.add( VDitem.Subservice_Volume_Discount__c );
            }
                    
            // Load all Volume Discount Brackets
            Volume_Discount_Bracket__c[] brackets = new Volume_Discount_Bracket__c[]{};
            for( Volume_Discount_Bracket__c bracket : [Select Id, Name From Volume_Discount_Bracket__c Where Volume_Discount__c IN :vdIds]) {
                brackets.add( bracket );        
            }
            
            // And create Offer_Item_Sub_VD_Line_Item__c per bracket            
            Offer_Item_Sub_VD_Line_Item__c[] offerLISubserviceVDs = new Offer_Item_Sub_VD_Line_Item__c[]{}; 
            if( toUpdateSubservices.size() > 0 ){
                for( Offer_Item_Subservice__c subservice : toUpdateSubservices ){
                    for( Volume_Discount_Bracket__c newBracket : brackets ){
                        Offer_Item_Sub_VD_Line_Item__c offerLISubserviceVD = new Offer_Item_Sub_VD_Line_Item__c();  
                        offerLISubserviceVD.Min_Price__c     = subservice.Min_Price__c;
                        offerLISubserviceVD.Max_Price__c     = subservice.Max_Price__c;
                        offerLISubserviceVD.CurrencyIsoCode  = subservice.CurrencyIsoCode;
                        offerLISubserviceVD.Offer_Item_Subservice__c = subservice.Id;
                        offerLISubserviceVD.Volume_Discount_Bracket__c = newBracket.Id;
                        offerLISubserviceVDs.add( offerLISubserviceVD );
                    }
                }   
            }
            
            try {
                insert offerLISubserviceVDs; // STEP 2
            } catch( Exception e ){
                // Or log an error
                system.debug( 'Update of Offer_Item_Sub_VD_Line_Item__c failed' );
                throw e;
            }
        }
    }
}