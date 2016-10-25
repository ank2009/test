public class CtrlDeletePackageAndFeeLineItem
{
    private final Package_and_Fee_Line_Item__c pfli;
    public String name {get; set;}
    public ID retID;

    public CtrlDeletePackageAndFeeLineItem(ApexPages.StandardController controller)
    {
        ID pfliId = System.currentPagereference().getParameters().get('id');
        this.pfli = [SELECT Id, Name, Parent__r.Status__c, Parent__c FROM Package_and_Fee_Line_Item__c WHERE Id = :pfliId];
        this.name  = this.pfli.Name;
        this.retID = this.pfli.Parent__c;
    }

    public PageReference init()
    {
        if (this.pfli.Parent__r.Status__c != 'Pending')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Package and Fee Line Items can be deleted only if Package and Fee is under Pending status.'));
            return null;
        }
        else
        {
            try
            {
                delete this.pfli;
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