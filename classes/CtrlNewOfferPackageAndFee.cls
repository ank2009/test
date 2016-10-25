public class CtrlNewOfferPackageAndFee
{
    private final Offer_Template__c ot;
    public Boolean error { get; set; }
    public Offer_Package_And_Fee__c offerPackageAndFee;
    public Id otId;
    
    public CtrlNewOfferPackageAndFee(ApexPages.StandardController controller)
    {
        Map<string,string> params = System.currentPagereference().getParameters();        
        for(string key : params.keySet())
        {
            if(key.right(5) == '_lkid')
            {
                otId = params.get(key);
                continue;
            }
        }
        
        this.ot = [SELECT Id, Status__c, CurrencyIsoCode FROM Offer_Template__c WHERE Id = : otId];
        this.offerPackageAndFee = new Offer_Package_And_Fee__c();
        this.offerPackageAndFee.Offer_Template__c = this.ot.Id;
        this.error = false;
    }
    
    public PageReference init()
    {
        if (this.ot.Status__c != 'Pending')
        {
            error = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Offer Template should be under Pending status for adding Package and Fee'));
        }
        return null;
    }

    public Offer_Package_And_Fee__c getOfferPackageAndFee()
    {
        return offerPackageAndFee;
    }
    
    public PageReference Save() 
    {
        try 
        {
            PackFee__c packFee = [SELECT Name, Default_Price__c, Default_Overusage_Price__c,
                                      (SELECT Service__c FROM Package_and_Fee_Line_Items__r)
                                  FROM PackFee__c 
                                  WHERE Id =: offerPackageAndFee.Package_Fee__c];
            
            Set<Id> servicesSet = new Set<Id>();
            for(Package_and_Fee_Line_Item__c currPFLI : packFee.Package_and_Fee_Line_Items__r)
                servicesSet.add(currPFLI.Service__c);
            
            List<Offer_Line_Item__c> oLIs = [SELECT Id
                                               FROM Offer_Line_Item__c
                                              WHERE Offer_Template__c =: otId
                                                AND Service__c IN : servicesSet];

            if(oLIs.size() != packFee.Package_and_Fee_Line_Items__r.size())
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'You cannot link this Package and Fee because its Line Items do not match with Line Items of parent Offer Template'));
                return null;
            }
            
            offerPackageAndFee.Name                     = packFee.Name;
            
            Double price = ((packFee.Default_Price__c != null) ? packFee.Default_Price__c : 0.0);
            offerPackageAndFee.CurrencyIsoCode          = this.ot.CurrencyIsoCode;
            offerPackageAndFee.Min_Price__c             = price;
            offerPackageAndFee.Max_Price__c             = price;
            offerPackageAndFee.Default_Price__c         = price;
            offerPackageAndFee.Min_Overusage_Price__c   = packFee.Default_Overusage_Price__c;
            offerPackageAndFee.Max_Overusage_Price__c   = packFee.Default_Overusage_Price__c;
            offerPackageAndFee.Overusage_Price__c       = packFee.Default_Overusage_Price__c;
            
            insert offerPackageAndFee;
            
            return (Utilities.Redirect(this.offerPackageAndFee.Id));
        } 
        catch (DmlException e) 
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getDmlMessage(0)));
            return null;
        }
        
    }
    
    public PageReference Cancel() 
    {
        return (Utilities.Redirect(this.ot.Id));
    }
}