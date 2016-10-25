/**
 * Name : VolumeDiscountExt
 * Created By : Ronnie Visser <r.visser@vivens.com>
 * Date : 2011-08-22
**/
public class VolumeDiscountExt {
    /**
     * Will contain the Volume Bracket given by the stdController
     * 
    **/
    public Volume_Discount__c volumeDiscount{get;set;}
    
    /**
     * Class Constructor with standardController
     *
     * Type : Constructor
    **/ 
    public VolumeDiscountExt(ApexPages.StandardController controller) {
        this.volumeDiscount = (Volume_Discount__c)controller.getRecord();
        this.volumeDiscount.Start_Date__c = Date.today();
        this.volumeDiscount.Status__c = 'Pending';
    }
    
    /** 
     * Default Class constructor
     *
     * Type : Constructor
    **/
    public VolumeDiscountExt(){
        
    }
    
    /**
     * Called by Trigger on  Bracket before deletion
     * Here we check if user can delete a bracket, of not add an error to current record
    **/
    public static void bracketBeforeDelete( Volume_Discount_Bracket__c[] brackets ){
        Id[] ids = new Id[]{};
        for( Volume_Discount_Bracket__c bracket : brackets ) {  
            ids.add(bracket.Id);            
        }
        
        for( Volume_Discount_Bracket__c bracket : [Select Volume_Discount__r.Status__c From Volume_Discount_Bracket__c Where Id IN :ids] ) {    
            if( bracket.Volume_Discount__r.Status__c != 'Pending' ){
                //bracket.addError( 'Could not delete bracket because parent is not in status Pending' ); 
                throw new Generic.StandardException();
            }
        }
    }
}