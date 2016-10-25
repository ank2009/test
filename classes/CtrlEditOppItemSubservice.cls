public class CtrlEditOppItemSubservice
{
    public Opp_Item_Subservice__c oppItemSubserv {get; set;}

    public CtrlEditOppItemSubservice(ApexPages.StandardController controller)
    {
        ID oissId = System.currentPagereference().getParameters().get('id');
        this.oppItemSubserv = [SELECT Id, Name, Subservice__c, Opportunity_Line_Item__c,
                                      Subservice_Volume_Discount__c, Sales_Price__c,
                                      Estimated_Quantity__c, Min_Price__c, Max_Price__c
                               FROM Opp_Item_Subservice__c WHERE Id = :oissId];
    }

    public PageReference Save() 
    {
        try {
            update oppItemSubserv;        
            return (Utilities.Redirect(this.oppItemSubserv.Id));
        } catch (DmlException ex) {
            ApexPages.addMessages(ex);
            return null;
        }
    }

    public PageReference Cancel() 
    {
        return (Utilities.Redirect(this.oppItemSubserv.Id));
    }
}