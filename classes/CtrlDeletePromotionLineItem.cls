public class CtrlDeletePromotionLineItem
{
    private final Promotion_Line_Item__c pli;
    public String name {get; set;}
    public ID retID;

    public CtrlDeletePromotionLineItem(ApexPages.StandardController controller)
    {
        ID pliId = System.currentPagereference().getParameters().get('id');
        this.pli = [SELECT Id, Name, Promotion__r.Status__c, Promotion__c FROM Promotion_Line_Item__c WHERE Id = :pliId];
        this.name  = this.pli.Name;
        this.retID = this.pli.Promotion__c;
    }

    public PageReference init()
    {
        if (this.pli.Promotion__r.Status__c != 'Pending')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Promotion Line Items can be deleted only if Promotion is under Pending status.'));
            return null;
        }
        else
        {
            try
            {
                delete this.pli;
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