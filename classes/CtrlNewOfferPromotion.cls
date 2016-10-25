public class CtrlNewOfferPromotion
{
    private final Offer_Template__c ot;
    public Boolean error {get; set;}
    public Offer_Promo__c offerPromo;
    
    public CtrlNewOfferPromotion(ApexPages.StandardController controller)
    {
        String url = System.currentPagereference().getParameters().get('retURL');
        this.ot = [SELECT Id, CurrencyIsoCode, Status__c FROM Offer_Template__c WHERE Id = :url.substring(1)];
        this.offerPromo = new Offer_Promo__c();
        this.offerPromo.Offer_Template__c = this.ot.Id;
        this.offerPromo.CurrencyIsoCode   = this.ot.CurrencyIsoCode;
    }
    
    public PageReference init()
    {
        if (this.ot.Status__c != 'Pending')
        {
            error = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Offer Template should be under Pending status for adding Promotion'));
        }
        return null;
    }

    public Offer_Promo__c getOfferPromo()
    {
        return offerPromo;
    }
    
    public PageReference Save() 
    {   
        this.offerPromo.Name = [SELECT Name FROM Promotion__c WHERE Id =: offerPromo.Promotion__c].Name;
        createRecord();
        
        return (Utilities.Redirect(this.offerPromo.Id));
    }
    
    public PageReference Cancel() 
    {
        return (Utilities.Redirect(this.ot.Id));
    }
    
    public void createRecord()
    {
        insert offerPromo;
    }
}