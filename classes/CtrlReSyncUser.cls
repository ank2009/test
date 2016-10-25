public class CtrlReSyncUser
{
    private final User_Profile__c up;
    
    public CtrlReSyncUser(ApexPages.StandardController controller) 
    {
        this.up = (User_Profile__c)controller.getRecord();
    }
    
    public PageReference init()
    {
        System.Debug('## Init ReSync');
        
        if (!Test.isRunningTest())
            ProvisioningMessages.SendReProvisioning(new List<Id>{this.up.Id});
        
        System.Debug('## End ReSync');
        
        return (Utilities.Redirect(this.up.Id));
    }
}