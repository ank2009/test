public class CtrlDeleteOfferPackageAndFee
{
    private final Offer_Package_and_Fee__c opf;
    public String name {get; set;}
    public ID retID;

    public CtrlDeleteOfferPackageAndFee(ApexPages.StandardController controller)
    {
        ID offPFId = System.currentPagereference().getParameters().get('id');
        this.opf = [SELECT Id, Name, Offer_Template__r.Status__c, Offer_Template__c FROM Offer_Package_and_Fee__c WHERE Id = :offPFId];
        this.name  = this.opf.Name;
        this.retID = this.opf.Offer_Template__c;
    }

    public PageReference init()
    {
        if (this.opf.Offer_Template__r.Status__c != 'Pending')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Offer Packages and Fees can be deleted only if Offer Template is under Pending status.'));
            return null;
        }
        else
        {
            try
            {
                delete this.opf;
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