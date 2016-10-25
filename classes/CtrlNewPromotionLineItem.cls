public class CtrlNewPromotionLineItem 
{
    public Boolean error {get; set;}
    public Promotion_Line_Item__c promotionLI {get; set;}
    private Promotion__c promo;
    
    public CtrlNewPromotionLineItem(ApexPages.StandardController controller) 
    {
        error = false;
        
        this.promotionLI = (Promotion_Line_Item__c)controller.getRecord();
        
        this.promo = [SELECT Name, Status__c FROM Promotion__c WHERE Id = :this.promotionLI.Promotion__c];
        
        if (promo.Status__c != 'Pending')
        {
            error = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Promotion status must be Pending to add line items!'));
        }
        
        List<Promotion_Line_Item__c> promoLIs = [SELECT Sort_Order__c FROM Promotion_Line_Item__c WHERE Promotion__c = :this.promotionLI.Promotion__c]; 
        
        List<Integer> sortOrders = new List<Integer>();
        for (Promotion_Line_Item__c promoLI : promoLIs)
            sortOrders.add(Integer.valueOf(promoLI.Sort_Order__c));
        
        sortOrders.sort();
        
        Integer index = 1;
        for (Integer i : sortOrders)
        {
            if (i != index)
                break;
            index++;
        }
        
        this.promotionLI.sort_Order__c = index;
    }
    
    public PageReference Save()
    {
        try
        {
            String pLIname = this.promo.Name + ' - ' + this.promotionLI.Sort_Order__c.format();
            this.promotionLI.Name = pLIname;
            insert this.promotionLI;
        }
        catch (DMLException e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getDmlMessage(0))); 
            return null;
        }
        
        return (Utilities.Redirect(this.promotionLI.Promotion__c));
    }
    
    public PageReference Cancel()
    {
        return (Utilities.Redirect(this.promotionLI.Promotion__c));
    }
}