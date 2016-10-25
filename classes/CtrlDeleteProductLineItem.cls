public with sharing class CtrlDeleteProductLineItem 
{
    private final Product_Line_Item__c pli;
    public String name {get; set;}
    public ID retID;
    
    public CtrlDeleteProductLineItem(ApexPages.StandardController controller) 
    {
        ID pliID   = System.currentPagereference().getParameters().get('id');
        this.pli   = [SELECT Id, Service__r.Name, Parent__r.Status__c, Parent__c FROM Product_Line_Item__c WHERE Id = :pliID];
        this.name  = this.pli.Service__r.Name;
        this.retID = this.pli.Parent__c;
    }
    
    public PageReference init()
    {
        if (this.pli.Parent__r.Status__c != 'Pending')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Product Line Items can be deleted only if Product is under Pending status.'));
            return null;
        }
        else
        {
            try
            {
                delete this.pli;
                return (Utilities.Redirect(retID));
            }
            catch (DMLException e)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getDMLMessage(0)));
                return null;
            }
        }
    }
    
    public PageReference Cancel()
    {
        return (Utilities.Redirect(retID));
    }
}