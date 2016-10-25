public with sharing class CtrlEditSubscription 
{
    public Subscription__c subscr {get; set;}
    public Boolean startDateEditable {get; set;}
    public Boolean endDateEditable {get; set;}
    public Boolean endDateRequired {get; set;}
    public Boolean consolidationEditable {get; set;}
    public Boolean statusEditable {get; set;}
    
    public CtrlEditSubscription(ApexPages.StandardController controller) 
    {
        ID subsId = System.currentPagereference().getParameters().get('id');
        this.subscr = [SELECT Id, Name, Contract__c, Status__c, Terms_Conditions__c,
                              Offer_Template__c, Product__c, Siebel_agreement_id__c,
                              History__c, Price_List_Code__c, Notes__c, Purchase_Order__c,
                              Payment_date__c, Start_Date__c, Start_Usage_Payment__c,
                              End_Date__c, CUG_allowed__c, Opportunity__c, Consolidation_Level__c
                         FROM Subscription__c
                        WHERE Id =:subsId];
                        
        startDateEditable = (this.subscr.Status__c != 'Active' && 
                             this.subscr.Status__c != 'On Notice' && 
                            this.subscr.Status__c != 'Cancelled');
        endDateEditable = ( this.subscr.Status__c != 'On Notice' && 
                            this.subscr.Status__c != 'Cancelled');                   
        statusEditable =  ( this.subscr.Status__c != 'Cancelled');

    }
    
    public PageReference Save() 
    {
        try {
            update subscr ;
            
            // Update Subs Promo Line Items
            SubsPromoLineItemsUtils.updatePromoLineItemsDates(subscr.Id, subscr.Start_Date__c, subscr.End_Date__c);
        }
        catch(DmlException e)
        {
            ApexPages.addMessages(e);
            return null;
        }
        
        return (Utilities.Redirect(this.subscr.Id));
    }

    public PageReference Cancel() 
    {
        return (Utilities.Redirect(this.subscr.Id));
    }
}