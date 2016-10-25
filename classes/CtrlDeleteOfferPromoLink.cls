public class CtrlDeleteOfferPromoLink
{
    private final Offer_Promo_Link__c opl;
    public String name {get; set;}
    public ID retID;

    public CtrlDeleteOfferPromoLink(ApexPages.StandardController controller)
    {
        ID offPlId = System.currentPagereference().getParameters().get('id');
        this.opl = [SELECT Id, Name, Offer_Promotion__r.Offer_Template__r.Status__c, Offer_Promotion__r.Offer_Template__c FROM Offer_Promo_Link__c WHERE Id = :offPlId];
        this.name  = this.opl.Name;
        this.retID = this.opl.Offer_Promotion__c;
    }

    public PageReference init()
    {
        if (this.opl.Offer_Promotion__r.Offer_Template__r.Status__c != 'Pending')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Offer Promo Links can be deleted only if Offer Template is under Pending status.'));
            return null;
        }
        else
        {
            try
            {
                delete this.opl;
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