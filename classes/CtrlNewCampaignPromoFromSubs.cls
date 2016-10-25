public with sharing class CtrlNewCampaignPromoFromSubs 
{
    public class subserviceWrapper
    {
        public Subs_Item_Subservice__c subserv {get; set;}
        public String subservName {get; set;}
        public Boolean selected {get; set;}
        
        public subserviceWrapper(Subs_Item_Subservice__c s)
        {
            subserv     = s;
            subservName = s.Subservice__r.Name;
            selected    = false;
        }
    }
    
    public class packfeeWrapper
    {
        public Subs_Package_And_Fee__c paf {get; set;}
        public String pafName {get; set;}
        public Boolean selected {get; set;}
        
        public packfeeWrapper(Subs_Package_And_Fee__c p)
        {
            paf      = p;
            pafName  = p.Package_and_Fee__r.Name;
            selected = false;
        }
    }
    
    public Campaign_Promotion__c cp {get; set;}
    private final Subscription__c subs;
    public List<subserviceWrapper> subservices;
    public List<packfeeWrapper>    pafs;
    public Boolean selAllSub {get; set;}
    public Boolean selAllPaf {get; set;}
    public Boolean error {get; set;}
    
    public CtrlNewCampaignPromoFromSubs(ApexPages.StandardController controller) 
    {
        ID subsId = System.currentPagereference().getParameters().get('id');
        this.subs = [SELECT Id, Name, Contract__c, Contract__r.AccountId, CurrencyIsoCode
                     FROM Subscription__c 
                     WHERE Id = :subsId];
        
        this.cp                         = new Campaign_Promotion__c();
        this.cp.Name                    = this.subs.Name + ' - Promotion';
        this.cp.OwnerId                 = userInfo.getUserId();
        this.cp.Start_Date__c           = Date.Today();
        this.cp.End_Date__c             = Date.Today();
        this.cp.Level__c                = 'Subscription';
        this.cp.CurrencyIsoCode         = this.subs.CurrencyIsoCode;
        
        error = false;
    }
    
    public PageReference init()
    {
        Subscription__c sub = [SELECT Start_Date__c FROM Subscription__c WHERE Id = :this.subs.Id];
         
        try
        {
            update sub;
        }
        catch (DMLException e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Insufficient Privileges!')); 
            error = true;
            return null;
        }
        
        selAllSub = false;
        selAllPaf = false;
        
        if (subservices == null)
        {
            subservices = new List<subserviceWrapper>();
            
            List<Subs_Item_Subservice__c> subsItemSubs = [SELECT Subservice__c, Subservice__r.Name 
                                                          FROM Subs_Item_Subservice__c
                                                          WHERE Subscription_Line_Item__r.Subscription__c = :this.subs.Id 
                                                          ORDER BY Subscription_Line_Item__r.Service__r.Name ASC];
                                                          
            for (Subs_Item_Subservice__c subsItemSub : subsItemSubs)
                subservices.add(new subserviceWrapper(subsItemSub));
        }
        
        if (pafs == null)
        {
            pafs = new List<packfeeWrapper>();
            
            List<Subs_Package_And_Fee__c> subsPAFs = [SELECT Package_and_Fee__c, Package_and_Fee__r.Name 
                                                      FROM Subs_Package_And_Fee__c
                                                      WHERE Subscription__c = :this.subs.Id 
                                                      ORDER BY Package_and_Fee__r.Name ASC];
                                                          
            for (Subs_Package_And_Fee__c subsPAF : subsPAFs)
                pafs.add(new packfeeWrapper(subsPAF));
        }
        
        return null;
    }
    
    public List<subserviceWrapper> getSubservices()
    {
        return subservices;
    }
    
    public List<packfeeWrapper> getPafs()
    {
        return pafs;
    }
    
    public void selectAllSub()
    {
        for (subserviceWrapper s : subservices)
            s.selected = selAllSub;
    }
    
    public void selectAllPaf()
    {
        for (packfeeWrapper p : pafs)
            p.selected = selAllPaf;
    }
    
    public PageReference Save()
    {
        if (this.cp.Start_Date__c < Date.Today())
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Start date must be in future!'));
            return null;
        }
        else if (this.cp.End_Date__c < this.cp.Start_Date__c)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'End Date has to be after Start Date!'));
            return null;
        }
        else if (this.cp.SalesPrice__c == null && this.cp.Discount__c == null && this.cp.Discount_Percentage__c == null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'One of the three pricing information must be filled!'));
            return null;
        }
        else if (!((this.cp.SalesPrice__c != null && this.cp.Discount__c == null && this.cp.Discount_Percentage__c == null) ||
                   (this.cp.SalesPrice__c == null && this.cp.Discount__c != null && this.cp.Discount_Percentage__c == null) ||
                   (this.cp.SalesPrice__c == null && this.cp.Discount__c == null && this.cp.Discount_Percentage__c != null)))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'You can set only one value among Sales Price, Discount and Discount Percentage!'));
            return null;
        }
        else if (this.cp.SalesPrice__c < 0 || this.cp.Discount__c < 0 || this.cp.Discount_Percentage__c < 0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Pricing information must be positive!'));
            return null;
        }
        else
        {
            Boolean oneItemSelected = false;
            
            if (this.cp.Level__c == 'Service(s)')
            {
                for (subserviceWrapper s : subservices)
                {
                    if (s.selected)
                    {
                        oneItemSelected = true;
                        break;
                    }
                }
            }
            else if (this.cp.Level__c == 'Package(s)/Fee(s)')
            {
                for (packfeeWrapper p : pafs)
                {
                    if (p.selected)
                    {
                        oneItemSelected = true;
                        break;
                    }
                }
            }
            
            if (this.cp.Level__c == 'Subscription' || oneItemSelected)
            {
                insert this.cp;
                
                List<Campaign_Promotion_Line_Item__c> lstCpli = new List<Campaign_Promotion_Line_Item__c>();
                
                if (this.cp.Level__c == 'Service(s)')
                {
                    for (subserviceWrapper s : subservices)
                    {
                        if (s.selected)
                        {
                            Campaign_Promotion_Line_Item__c cpli = new Campaign_Promotion_Line_Item__c();
                            cpli.Campaign_Promotion__c           = this.cp.Id;
                            cpli.Subservice__c                   = s.subserv.Subservice__c;
                            cpli.CurrencyIsoCode                 = this.cp.CurrencyIsoCode;
                            
                            lstCpli.add(cpli);
                        }
                    }
                }
                else if (this.cp.Level__c == 'Package(s)/Fee(s)')
                {
                    for (packfeeWrapper p : pafs)
                    {
                        if (p.selected)
                        {
                            Campaign_Promotion_Line_Item__c cpli = new Campaign_Promotion_Line_Item__c();
                            cpli.Campaign_Promotion__c           = this.cp.Id;
                            cpli.Package_and_Fee__c              = p.paf.Package_and_Fee__c;
                            cpli.CurrencyIsoCode                 = this.cp.CurrencyIsoCode;
                            
                            lstCpli.add(cpli);
                        }
                    }
                }
                
                if (lstCpli.size() > 0)
                    insert lstCpli;
                
                Campaign_Promotion_Subscription_LI__c cpsli = new Campaign_Promotion_Subscription_LI__c();
                cpsli.Campaign_Promotion__c                 = this.cp.Id;
                cpsli.Subscription__c                       = this.subs.Id;
                cpsli.Contract__c                           = this.subs.Contract__c;
                cpsli.Account__c                            = this.subs.Contract__r.AccountId;
                cpsli.CurrencyIsoCode                       = this.subs.CurrencyIsoCode;
                
                insert cpsli;
                    
                return (Utilities.Redirect(this.cp.Id));
            }
            else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Select at least one item (Subservice or Package/Fee) or change Level to \'Subscription\'!'));
                return null;
            }
        }
    }
    
    public PageReference Cancel()
    {
        return (Utilities.Redirect(this.subs.Id));
    }
}