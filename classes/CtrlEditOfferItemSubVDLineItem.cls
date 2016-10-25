public class CtrlEditOfferItemSubVDLineItem
{
    public Boolean error {get; set;}
    public Offer_Item_Sub_VD_Line_Item__c oisvdLI {get; set;}
    
    public CtrlEditOfferItemSubVDLineItem(ApexPages.StandardController controller) 
    {
        error        = false;
        ID oisvdLIid = System.currentPagereference().getParameters().get('id');
        this.oisvdLI = [SELECT Name, Discount_Type__c, Max_Price__c, Min_Price__c, Max_Value__c, 
                               Min_Value__c, Offer_Item_Subservice__c, 
                               Offer_Item_Subservice__r.Offer_Line_Item__r.Offer_Template__r.Status__c 
                        FROM Offer_Item_Sub_VD_Line_Item__c WHERE Id =:oisvdLIid];
        
        if (this.oisvdLI.Offer_Item_Subservice__r.Offer_Line_Item__r.Offer_Template__r.Status__c != 'Pending')
        {
            error = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Offer Template should be in status Pending to modify this Line Item!'));
        }
    }
    
    public PageReference Save() 
    {
        try 
        {
            update oisvdLI;        
            return (Utilities.Redirect(this.oisvdLI.Offer_Item_Subservice__c));
        }
        catch (DMLException e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getDmlMessage(0))); 
            return null;
        }
    }

    public PageReference Cancel() 
    {
        return (Utilities.Redirect(this.oisvdLI.Offer_Item_Subservice__c));
    }
}