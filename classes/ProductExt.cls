public class ProductExt 
{
	private id tasRecortTypeId;
	
    public Product__c prod {get; set;}
    
    public Product__c clonedProduct {get; set;}
    
    public Product__c productPage 
    {
        get 
        {
            if (productPage == null)
            {
                productPage = [SELECT Status__c, Start_Date__c, RecordTypeId, OwnerId, 
                                      Name, End_Date__c, Add_on__c, Description__c, 
                                      Access_Kind__c, Access_Roles__c
                               FROM Product__c WHERE Id = :this.prod.Id];
                               
                productPage.Status__c     = 'Pending';       
                productPage.Start_Date__c = Date.Today();
                productPage.End_Date__c   = null;
            }
            
            return productPage;
        } 
        set;
    }
    
    public Product_Line_Item__c[] productLineItems 
    {
        get 
        {
            if (productLineItems == null)
                productLineItems = [SELECT RecordTypeId, Name, Id, Description__c, Parent__c, Service__c
                                    FROM Product_Line_Item__c 
                                    WHERE Parent__c = :this.prod.Id];
            
            return productLineItems;
        } 
        set;
    }
    
    public Add_on_Parent__c[] addOnParents 
    {
        get 
        {
            if (addOnParents == null)
                addOnParents = [SELECT RecordTypeId, Name, Id, Add_on__c, Product__c
                                FROM Add_on_Parent__c 
                                WHERE Add_on__c = :this.prod.Id];
            
            return addOnParents;
        } 
        set;
    }
    
    public ProductExt(ApexPages.StandardController controller) 
    {
    	tasRecortTypeId = TLR_RecordTypeHelper.getId('Product__c', 'TAS Product');
    		 
        ID prodID = System.currentPagereference().getParameters().get('id');
        this.prod = [SELECT Id, Status__c, Nb_Children__c, RecordTypeId FROM Product__c WHERE Id = :prodID];
    }
    
    public PageReference SaveClone()
    {
        // Set a Database savepoint so we can rollback if needed
        Savepoint sp = Database.setSavepoint();
        
        // Clone Product
        this.clonedProduct = this.productPage.clone(false, true);
        
        try {
            // Insert Product
            insert this.clonedProduct;
            
            // Clone ProductLineItems
            if (this.productLineItems.size() > 0)
            {
                Product_Line_Item__c[] listProductLineItems = this.productLineItems.deepClone(false);
                
                for (Product_Line_Item__c lineItem : listProductLineItems) 
                    lineItem.Parent__c = this.clonedProduct.Id;
                
                insert listProductLineItems;
            }
            
            // Clone AddOnParents
            if (this.addOnParents.size() > 0)
            {
                Add_on_Parent__c[] listAddOnParents = this.addOnParents.deepClone(false);
                
                for (Add_on_Parent__c parent : listAddOnParents)
                    parent.Add_on__c = this.clonedProduct.Id;
                
                insert listAddOnParents;
            }
            
            // Everything succeeded so we can go to the cloned Product 
            return Utilities.redirect(this.clonedProduct.Id);
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

    public PageReference ActivateApproval()
    {
        if (this.prod.Status__c != 'Pending')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Product must be under Pending status to be activated.'));
            return null;
        }
        else if (this.prod.Nb_Children__c <= 0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Products with no line items cannot to be activated.'));
            return null;
        }
        else if (this.prod.RecordTypeId == tasRecortTypeId)
        {
        	this.prod.Access_Kind__c = 'TAS';
        	this.prod.Status__c = 'Pending Activation Approval';
            update this.prod;
        	this.prod.Status__c = 'Active';
        	update this.prod;
        	return Utilities.redirect( this.prod.Id );
        }
        else
        {
            this.prod.Status__c = 'Pending Activation Approval';
            update this.prod;
            
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(this.prod.Id);
                                
            Approval.ProcessResult result = Approval.process(req1);             
            return Utilities.redirect( this.prod.Id );
        }
    }
    
    public PageReference DeactivateApproval()
    {
        if( this.prod.Status__c != 'Active' )
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Product must be under Active status to be deactivated.'));
            return null;
        } 
        else 
        {
            this.prod.Status__c = 'Pending Deactivation Approval';
            update this.prod;
            
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(this.prod.Id);
                                
            Approval.ProcessResult result = Approval.process(req1);             
            return Utilities.redirect( this.prod.Id );
        }
    }
    
    public PageReference ReactivateApproval()
    {
        if( this.prod.Status__c != 'Inactive' )
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Product must be under Inactive status to be reactivated.'));
            return null;
        } 
        else 
        {
            this.prod.Status__c = 'Pending';
            update this.prod;

            return Utilities.redirect( this.prod.Id );
        }
    }
}