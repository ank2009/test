public with sharing class CtrlEditOfferPromotion 
{
    public Offer_Promo__c op    {get; set;}
    public Boolean        error {get; set;}
    
    public CtrlEditOfferPromotion(ApexPages.StandardController controller) 
    {
        ID opId = System.currentPagereference().getParameters().get('id');
        this.op = [SELECT Name, Offer_Template__c, Promotion__c, 
                          Level__c, Offer_Template__r.Status__c
                   FROM Offer_Promo__c
                   WHERE Id =:opId];
        
        error = false;
        
        if (this.op.Offer_Template__r.Status__c != 'Pending')
        {
            error = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Offer Template should be in status Pending to modify this Offer Promotion'));
        }
    }
    
    public PageReference Save() 
    {
        this.op.Name = [SELECT Name FROM Promotion__c WHERE Id =: this.op.Promotion__c].Name;
        
        try 
        {
            update op;        
            return (Utilities.Redirect(System.currentPagereference().getParameters().get('retURL')));
        }
        catch (DMLException e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getDmlMessage(0))); 
            return null;
        }
    }
}