public class CtrlDeleteVolumeDiscountBracket
{
    private final Volume_Discount_Bracket__c vdb;
    public String name {get; set;}
    public ID retID;

    public CtrlDeleteVolumeDiscountBracket(ApexPages.StandardController controller)
    {
        ID vdbId = System.currentPagereference().getParameters().get('id');
        this.vdb = [SELECT Id, Name, Volume_Discount__r.Status__c, Volume_Discount__c FROM Volume_Discount_Bracket__c WHERE Id = :vdbId];
        this.name  = this.vdb.Name;
        this.retID = this.vdb.Volume_Discount__c;
    }

    public PageReference init()
    {
        if (this.vdb.Volume_Discount__r.Status__c != 'Pending')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Volume Discount Brackets can be deleted only if Volume Discount is under Pending status.'));
            return null;
        }
        else
        {
            try
            {
                delete this.vdb;
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