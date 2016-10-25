public class CtrlNewVolumeDiscountBracket 
{
    public Boolean error {get; set;}
    public Volume_Discount_Bracket__c volumeDiscountBracket {get; set;}
    private Volume_Discount__c vd;
    
    public CtrlNewVolumeDiscountBracket(ApexPages.StandardController controller) 
    {
        error = false;
        
        this.volumeDiscountBracket = (Volume_Discount_Bracket__c)controller.getRecord();
        
        this.vd = [SELECT Name, Status__c FROM Volume_Discount__c WHERE Id = :this.volumeDiscountBracket.Volume_Discount__c];
        
        if (vd.Status__c != 'Pending')
        {
            error = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Volume discount status must be Pending to add brackets!'));
        }
        else
        {
            List<Volume_Discount_Bracket__c> vdbs = [SELECT Max_Value__c 
                                                     FROM Volume_Discount_Bracket__c 
                                                     WHERE Volume_Discount__c = :this.volumeDiscountBracket.Volume_Discount__c];
                                                     
            Integer maxValue = 0;
            for (Volume_Discount_Bracket__c vdb : vdbs)
                maxValue = Math.max(maxValue, Integer.valueOf(vdb.Max_Value__c));
                
            this.volumeDiscountBracket.Min_Value__c = maxValue + 1;
        }
    }
    
    public PageReference Save()
    {
        this.volumeDiscountBracket.Name = this.vd.Name + '_' + this.volumeDiscountBracket.Min_Value__c + '_' + this.volumeDiscountBracket.Max_Value__c;
        try
        {
            insert this.volumeDiscountBracket;
        }
        catch (DMLException e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getDmlMessage(0))); 
            return null;
        }
        
        return (Utilities.Redirect(this.volumeDiscountBracket.Volume_Discount__c));
    }
    
    public PageReference Cancel()
    {
        return (Utilities.Redirect(this.volumeDiscountBracket.Volume_Discount__c));
    }
}