public class MultiEditOPLIExt 
{
    private final Offer_Promo__c promo;
    public Boolean error { get; set; }
    public String title { get; set; }
    public List<Offer_Promo_Line_Item__c> opliSet;
    

    public MultiEditOPLIExt(ApexPages.StandardController controller) 
    {
        title = 'Multi-Edit';
        error = false;
        
        ID idPromo = System.currentPagereference().getParameters().get('id');
        promo      = [SELECT Id, Offer_Template__c FROM Offer_Promo__c WHERE Id = :idPromo];
        
        opliSet    = [SELECT Id, Name, Min_Duration__c, Max_Duration__c, Min_Discount_Percentage__c, 
                             Max_Discount_Percentage__c, Min_Discount__c, Max_Discount__c, Min_Price__c, Max_Price__c 
                      FROM Offer_Promo_Line_Item__c 
                      WHERE Offer_Promotion__c = :this.promo.Id];
        
        String status = [SELECT Status__c FROM Offer_Template__c WHERE Id = :this.promo.Offer_Template__c].Status__c;
        
        if (status != 'Pending')
        {
            title = 'Error';
            error = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Offer Template should be in status Pending to modify these Line Items!'));
        }
        else if (opliSet.size() == 0)
        {
            title = 'Error';
            error = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'No offer promotion line item to edit.'));
        }
    }
    
    
    public PageReference save()
    {
        try
        {
            update opliSet;
        }
        catch (DmlException e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getDmlMessage(0)));
            return null;
        }
        
        return Utilities.Redirect(promo.Id);
    }
    
    public List<Offer_Promo_Line_Item__c> getOpliSet()
    {
        return opliSet;
    }
    
}