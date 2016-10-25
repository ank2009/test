public class SubserviceTemplateExt 
{
    public final Subservice_Template__c subservTpl {get; set;}
    public Subservice_Template__c clonedSubservTpl {get; set;}
    public Boolean error {get; set;}
    
    public Subservice_Template__c subservTplPage 
    {
        get 
        {
            if (subservTplPage == null)
            {
                subservTplPage = [SELECT Name, RecordTypeId, Description__c, 
                                         Start_Date__c, 
                                         End_Date__c, Parent_Service__c
                                  FROM Subservice_Template__c  
                                  WHERE Id = :this.subservTpl.Id];
                                   
                subservTplPage.Start_Date__c = Date.Today();
                subservTplPage.End_Date__c   = null;
            }
            
            return subservTplPage;
        } 
        set;
    }
    
    public Subservice_Template_Line_Item__c[] subservTplLineItems 
    {
        get 
        {
            if (subservTplLineItems == null)
                subservTplLineItems = [SELECT Name, Id, RecordTypeId, Subservice__c, Template__c
                                       FROM Subservice_Template_Line_Item__c
                                       WHERE Template__c = :this.subservTpl.Id];
            
            return subservTplLineItems;
        } 
        set;
    }
    
    
    public SubserviceTemplateExt(ApexPages.StandardController controller) 
    {
        this.subservTpl = (Subservice_Template__c)controller.getRecord();
        
        error = false;
        String status = [SELECT Parent_Service__r.Status__c
                         FROM Subservice_Template__c  
                         WHERE Id = :this.subservTpl.Id].Parent_Service__r.Status__c;
        
        if (status != 'Pending')
        {
            error = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Subservice Templates can be cloned only if Service is under Pending status.'));
        }
    }
    
    
    public PageReference SaveClone()
    {
        // Set a Database savepoint so we can rollback if needed
        Savepoint sp = Database.setSavepoint();
        
        // Clone Subservice Template
        this.clonedSubservTpl = this.subservTplPage.clone(false, true);
        
        try {
            // Insert Subservice Template
            insert this.clonedSubservTpl;
            
            // Clone Subservice Template Line Items
            if (this.subservTplLineItems.size() > 0)
            {
                Subservice_Template_Line_Item__c[] listSubservTplLineItems = this.subservTplLineItems.deepClone(false);
                
                for (Subservice_Template_Line_Item__c lineItem : listSubservTplLineItems) 
                    lineItem.Template__c = this.clonedSubservTpl.Id;
                
                insert listSubservTplLineItems;
            }
            
            // Everything succeeded so we can go to the cloned Template 
            return Utilities.redirect(this.clonedSubservTpl.Id);
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