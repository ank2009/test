/**
 * Name : PromotionExt
 * Created By : Ronnie Visser <r.visser@vivens.com>
 * Date : 2011-08-24
 * Updated By : François Dubois <francois.dubois@atos.net>
 * Date : 2011-09-12
**/
public with sharing class PromotionExt {
    /**
     * Will contain the Promotion given by the stdController
     * 
    **/
    public Promotion__c promotion{get;set;}
        
    /**
     * Class Constructor with standardController
     *
     * Type : Constructor
    **/ 
    public PromotionExt(ApexPages.StandardController controller) {
        System.Debug('## controller PromotionExt constructor');
        this.promotion = (Promotion__c)controller.getRecord();
        this.promotion.Start_Date__c = Date.today();
        this.promotion.Status__c = 'Pending';
    }   
    
    /** 
     * Default Class constructor
     *
     * Type : Constructor
    **/
    public PromotionExt(){
        
    }
    
    
    /**
     * Called by Trigger on LineItem before deletion
     * Here we check if user can delete a LineItem, of not add an error to current record
    **/
    public static void LineItemBeforeDelete( Promotion_Line_Item__c[] lineitems ){
        Id[] ids = new Id[]{};
        for( Promotion_Line_Item__c lineitem : lineitems ) {    
            ids.add(lineitem.Id);           
        }
        
        for( Promotion_Line_Item__c item : [Select Promotion__r.Status__c From Promotion_Line_Item__c Where Id IN :ids]){   
            if( item.Promotion__r.Status__c != 'Pending' ){
                //item.addError( 'Could not delete Promotion Line Item because parent is not in status Pending' );
                throw new Generic.StandardException('Could not delete Promotion Line Item because parent is not in status Pending');     
            }
        }
    }
}