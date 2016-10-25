public class ServiceAttributeTemplateExt 
{
    public final Service_Attribute_Template__c servAttrTpl {get; set;}
    public Service_Attribute_Template__c clonedservAttrTpl {get; set;}
    public Boolean error {get; set;}
    
    public Service_Attribute_Template__c servAttrTplPage 
    {
        get 
        {
            if (servAttrTplPage == null)
            {
                servAttrTplPage = [SELECT Name, RecordTypeId, Deactivate_Trigger__c, 
                                          Default__c, Description__c, Start_Date__c, 
                                          End_Date__c, Parent__c
                                   FROM Service_Attribute_Template__c  
                                   WHERE Id = :this.servAttrTpl.Id];
                                   
                servAttrTplPage.Default__c    = false;
                servAttrTplPage.Start_Date__c = Date.Today();
                servAttrTplPage.End_Date__c   = null;
            }
            
            return servAttrTplPage;
        } 
        set;
    }
    
    public Service_Attribute_Template_Line_Item__c[] servAttrTplLineItems 
    {
        get 
        {
            if (servAttrTplLineItems == null)
                servAttrTplLineItems = [SELECT Name, Id, RecordTypeId, Service_Attribute__c, 
                                               Service_Attribute_Template__c
                                        FROM Service_Attribute_Template_Line_Item__c
                                        WHERE Service_Attribute_Template__c = :this.servAttrTpl.Id];
            
            return servAttrTplLineItems;
        } 
        set;
    }
    
    
    public ServiceAttributeTemplateExt(ApexPages.StandardController controller) 
    {
        this.servAttrTpl = (Service_Attribute_Template__c)controller.getRecord();
        
        error = false;
        String status = [SELECT Parent__r.Status__c
                         FROM Service_Attribute_Template__c  
                         WHERE Id = :this.servAttrTpl.Id].Parent__r.Status__c;
        
        if (status != 'Pending')
        {
            error = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Service Attribute Templates can be cloned only if Service is under Pending status.'));
        }
    }
    
    
    public PageReference SaveClone()
    {
        // Set a Database savepoint so we can rollback if needed
        Savepoint sp = Database.setSavepoint();
        
        // Clone Service Attribute Template
        this.clonedservAttrTpl = this.servAttrTplPage.clone(false, true);
        
        try {
            // Insert Service Attribute Template
            insert this.clonedServAttrTpl;
            
            // Clone Service Attribute Template Line Items
            if (this.servAttrTplLineItems.size() > 0)
            {
                Service_Attribute_Template_Line_Item__c[] listServAttrTplLineItems = this.servAttrTplLineItems.deepClone(false);
                
                for (Service_Attribute_Template_Line_Item__c lineItem : listServAttrTplLineItems) 
                    lineItem.Service_Attribute_Template__c = this.clonedServAttrTpl.Id;
                
                insert listServAttrTplLineItems;
            }
            
            // Everything succeeded so we can go to the cloned Offer Template 
            return Utilities.redirect(this.clonedServAttrTpl.Id);
        } 
        catch (DmlException e)
        {
            // Do the rollback transaction
            Database.rollback(sp);
            
            // Add a message with the error in it
            ApexPages.addMessages(e);
            
            return null;            
        }
    }
}