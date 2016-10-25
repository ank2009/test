public class CtrlEditOfferLineItem
{
    public Boolean error {get; set;}
    public Offer_Line_Item__c oLI {get; set;}
    
    public CtrlEditOfferLineItem(ApexPages.StandardController controller) 
    {
        error    = false;
        ID oLIid = System.currentPagereference().getParameters().get('id');
        this.oLI = [
        	SELECT 
        		Name, Billable_Service__c, Consolidation_Level__c, 
        		Offer_Template__c, Offer_Template__r.Status__c, 
        		Service__c, Service_Attribute_Template__c, 
        		Service_mandatory__c, Dependent_Services__c, Module_has_Value__c, 
        		Consulting_Type__c, Enabled_Maintenance__c
        	FROM 
        		Offer_Line_Item__c 
        	WHERE Id =:oLIid
        ];
        
        if (this.oLI.Offer_Template__r.Status__c != 'Pending')
        {
            error = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Offer Template should be in status Pending to modify this Line Item!'));
        }
    }
    
    public PageReference Save() 
    {
        try 
        {
            update oLI;        
            return (Utilities.Redirect(this.oLI.Offer_Template__c));
        }
        catch (DMLException e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getDmlMessage(0))); 
            return null;
        }
    }

    public PageReference Cancel() 
    {
        return (Utilities.Redirect(this.oLI.Offer_Template__c));
    }
}