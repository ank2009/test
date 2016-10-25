public class CtrlReSyncAll
{
    private final Provisioning__c prov;
    
    public CtrlReSyncAll(ApexPages.StandardController controller) 
    {
        this.prov = (Provisioning__c)controller.getRecord();
    }
    
    public PageReference init()
    {
        System.Debug('## Init ReSyncAll');
        
        List<User_Profile__c> userProfiles = [SELECT Id FROM User_Profile__c WHERE Provisioning__c = :this.prov.Id];
        
        List<Id> userProfileIds = new List<Id>();
        for (User_Profile__c up : userProfiles)
            userProfileIds.add(up.Id);
        
        System.Debug('## User Profile ids: ' + userProfileIds);
        
        if (userProfileIds.size() > 0 && !Test.isRunningTest())
            ProvisioningMessages.SendReProvisioning(userProfileIds);
        
        System.Debug('## End ReSyncAll');
        
        return (Utilities.Redirect(this.prov.Id));
    }
}