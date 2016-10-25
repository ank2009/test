public class CtrlEditVolumeDiscountBracket 
{
    public Boolean error {get; set;}
    public Volume_Discount_Bracket__c vdb {get; set;}
    public Integer maxValue = -1;
    public List<Volume_Discount_Bracket__c> vdbs;

    public CtrlEditVolumeDiscountBracket(ApexPages.StandardController controller) 
    {
        error = false;
        ID idVDB = System.currentPagereference().getParameters().get('id');
        this.vdb = [SELECT Name, Volume_Discount__c, Volume_Discount__r.Status__c, 
                           Volume_Discount__r.Name, Min_Value__c, Max_Value__c 
                    FROM Volume_Discount_Bracket__c WHERE Id = :idVDB];
        
        vdbs = new List<Volume_Discount_Bracket__c>();
        
        if (this.vdb.Volume_Discount__r.Status__c != 'Pending')
        {
            error = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Volume Discount status must be Pending to edit this bracket!'));
        }
        else
        {
            vdbs = [SELECT Name, Min_Value__c, Max_Value__c 
                    FROM Volume_Discount_Bracket__c 
                    WHERE Volume_Discount__c = :this.vdb.Volume_Discount__c 
                    AND Min_Value__c >= :this.vdb.Max_Value__c + 1 
                    ORDER BY Min_Value__c ASC 
                    LIMIT 1];
            
            if (vdbs.size() > 0)
                maxValue = Integer.valueOf(vdbs[0].Max_Value__c) - 1;
        }
    }
    
    public PageReference Save() 
    {
        if (maxValue >= 0 && this.vdb.Max_Value__c > maxValue)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Max Value must be less than or equal to ' + maxValue + ' not to entirely overlap next bracket')); 
            return null;
        }
        
        this.vdb.Name = this.vdb.Volume_Discount__r.Name + '_' + this.vdb.Min_Value__c + '_' + this.vdb.Max_Value__c;
        
        try 
        {
            if (vdbs.size() > 0)
            {
                vdbs[0].Min_Value__c = this.vdb.Max_Value__c + 1;
                vdbs[0].Name         = this.vdb.Volume_Discount__r.Name + '_' + vdbs[0].Min_Value__c + '_' + vdbs[0].Max_Value__c;
                update vdbs[0];
            }
            
            update this.vdb;        
            return (Utilities.Redirect(this.vdb.Volume_Discount__c));
        }
        catch (DMLException e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getDmlMessage(0))); 
            return null;
        }
    }

    public PageReference Cancel() 
    {
        return (Utilities.Redirect(this.vdb.Volume_Discount__c));
    }
}