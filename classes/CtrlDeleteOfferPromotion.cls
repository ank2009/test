public class CtrlDeleteOfferPromotion
{
    private final Offer_Promo__c op;
    public String name {get; set;}
    public ID retID;

    public CtrlDeleteOfferPromotion(ApexPages.StandardController controller)
    {
        ID opId = System.currentPagereference().getParameters().get('id');
        this.op = [SELECT Id, Name, Offer_Template__r.Status__c, Offer_Template__c FROM Offer_Promo__c WHERE Id = :opId];
        this.name  = this.op.Name;
        this.retID = this.op.Offer_Template__c;
    }

    public PageReference init()
    {
        if (this.op.Offer_Template__r.Status__c != 'Pending')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Offer Promotions can be deleted only if Offer Template is under Pending status.'));
            return null;
        }
        else
        {
            try
            {
                delete this.op;
                return (Utilities.Redirect(retID));
            }
            catch (Exception e)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Error during deletion: ' + e.getMessage()));
                return null;
            }
        }
    }
    
    public PageReference Cancel()
    {
        return (Utilities.Redirect(retID));
    }
}