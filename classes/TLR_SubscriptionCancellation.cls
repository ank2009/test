// Below code is written for CR #WKTS CRM-4
// We will put all the business logic in helper class, for now we will keep in trigger itself
/**
* @ Description   : Automatically fill in current fee end date during subscription cancellation 
* @ Business rule : If subscription = cancelled and current fee/end_date is null then current fee/end_date = subscription_end date  
* @ Date          : 22-10-2012    
* @ Author        : HCL Technology
**/
public class TLR_SubscriptionCancellation{ 

    List<Subs_Current_Fee__c> listOfSubCurrentFees= new List<Subs_Current_Fee__c>();
    List<Subs_Current_Fee__c> objSubCurrlist = new List<Subs_Current_Fee__c>();
    Set<ID> idSubs = new Set<ID>();
    
    public void updateEndDateCurrentFee(Set<ID> idSubs,List<Subscription__c> listOfSubs){
        
        for(Subs_Current_Fee__c objSubCurr : [Select Id, Subscription__c,End_Date__c From Subs_Current_Fee__c where Subscription__c IN :idSubs AND End_Date__c = null]){
                objSubCurrlist.add(objSubCurr);//5
        }
        
        for (Subscription__c sub : listOfSubs){
            
            for (Subs_Current_Fee__c objSubCurrR : objSubCurrlist){
            
            System.debug('objSubCurrR.End_Date__c=>'+objSubCurrR.End_Date__c);
            if ((sub.Status__c == 'Cancelled' || sub.Status__c == 'On Notice') && objSubCurrR.End_Date__c == null && objSubCurrR.Subscription__c == sub.Id){
                   // sub.End_Date__c = System.today();
                    objSubCurrR.End_Date__c = sub.End_Date__c;   
                    listOfSubCurrentFees.add(objSubCurrR);   
                   System.debug('listOfSubCurrentFees=>'+listOfSubCurrentFees);                         
                } 
            }
          
        }    
         System.debug('listOfSubCurrentFees=1=>'+listOfSubCurrentFees);   
         if(! listOfSubCurrentFees.isEmpty()){
            try{
                Database.SaveResult[] lsr = Database.update(listOfSubCurrentFees, false);
            }catch(Exception e){
                System.debug('Update Failed on Sub Current Fee object->'+e);
            }
        }
    }
}