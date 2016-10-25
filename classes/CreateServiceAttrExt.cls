public class CreateServiceAttrExt 
{
    private final Service_Attribute_Template__c servattrtemp;
    public Service_Attribute__c serv;
    
    public CreateServiceAttrExt(ApexPages.StandardController controller) 
    {
        this.servattrtemp = (Service_Attribute_Template__c)controller.getRecord();
    }
    
    public PageReference init()
    {
        this.serv = new Service_Attribute__c();
        serv.OwnerId = UserInfo.getUserId();
        serv.Parent__c = [SELECT Parent__c FROM Service_Attribute_Template__c WHERE Id = :this.servattrtemp.Id].Parent__c;
        
        return null;
    }
    
    public Service_Attribute__c getServ()
    {
        return serv;
    }
    
    public PageReference Save() 
    {   
        createRecord();
        
        return (Utilities.Redirect(this.servattrtemp.Id));
    }
    
    public PageReference SaveAndNew() 
    {   
        createRecord();
        
         return (Utilities.Redirect('apex/CreateServiceAttr?id=' + this.servattrtemp.Id));
    }
    
    public PageReference Cancel() 
    {
         return (Utilities.Redirect(this.servattrtemp.Id));
    }
    
    public void createRecord()
    {
        insert serv;
        
        Service_Attribute_Template_Line_Item__c lineitem = new Service_Attribute_Template_Line_Item__c();
        lineitem.Service_Attribute__c = serv.Id;
        lineitem.Service_Attribute_Template__c = this.servattrtemp.Id;
        insert lineitem;
    }
}