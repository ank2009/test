public  class ApplySubsPromotionExt 
{
    public class SubStatus
    {
        public ID id {get; set;}
        public Boolean status {get; set;}
        public String error {get; set;}
        
        public SubStatus(ID i)
        {
            id = i;
            status = true;
            error = '';
        }
    }
    
    private final Campaign_Promotion__c cp;
    public List<SubStatus> statuses;
    public Boolean data {get; set;}
    
    public ApplySubsPromotionExt(ApexPages.StandardController controller) 
    {
        ID cpId = System.currentPagereference().getParameters().get('id');
        this.cp = [SELECT Name, Level__c, Id, Start_Date__c, End_Date__c, SalesPrice__c, Discount__c, Discount_Percentage__c, CurrencyIsoCode,
                  (SELECT Subservice__c, Subservice__r.Name, Package_and_Fee__c, Package_and_Fee__r.Name 
                   FROM Campaign_Promotion_Line_Items__r),
                  (SELECT Subscription__c FROM Campaign_Promotion_Subscription_LIs__r)
                   FROM Campaign_Promotion__c WHERE ID = :cpId];
    }
    
    public List<SubStatus> getStatuses()
    {
        return statuses;
    }
    
    public PageReference init()
    {
        data = false;
        
        if (this.cp.Level__c == 'Service(s)' && this.cp.Campaign_Promotion_Line_Items__r.size() == 0)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Subscription with Service(s) level must contain service(s)!'));
            return null;
        }
        else if (this.cp.Level__c == 'Package(s)/Fee(s)' && this.cp.Campaign_Promotion_Line_Items__r.size() == 0)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Subscription with Package(s)/Fee(s)(s) level must contain package(s) or fee(s)!'));
            return null;
        }
        else if (this.cp.Campaign_Promotion_Subscription_LIs__r.size() == 0)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Campaign must contain subscription before it can be applied!'));
            return null;
        }
        else
        {
            data = true;
            statuses = new List<SubStatus>();
            
            if (this.cp.Level__c == 'Service(s)' || this.cp.Level__c == 'Package(s)/Fee(s)')
            {
                Set<ID> idsubs            = new Set<ID>();
                Set<ID> iditems           = new Set<ID>();
                Map<ID, String> itemNames = new Map<ID, String>();
                
                for (Campaign_Promotion_Line_Item__c cpli : this.cp.Campaign_Promotion_Line_Items__r)
                {
                    if (this.cp.Level__c == 'Service(s)')
                    {
                        iditems.add(cpli.Subservice__c);
                        itemNames.put(cpli.Subservice__c, cpli.Subservice__r.Name);
                    }
                    else
                    {
                        iditems.add(cpli.Package_and_Fee__c);
                        itemNames.put(cpli.Package_and_Fee__c, cpli.Package_and_Fee__r.Name);
                    }
                }

                for (Campaign_Promotion_Subscription_LI__c cpsli : this.cp.Campaign_Promotion_Subscription_LIs__r)
                    idsubs.add(cpsli.Subscription__c);
                
                // Subs Item Subservices
                Map<Id, List<Subs_Item_Subservice__c>> mapSubSubserv = new Map<Id, List<Subs_Item_Subservice__c>>();
                
                List<Subs_Item_Subservice__c> lstSubsItemSub = [SELECT Id, Subservice__c, Subscription_Line_Item__r.Subscription__c 
                                                                FROM Subs_Item_Subservice__c
                                                                WHERE Subscription_Line_Item__r.Subscription__c IN :idsubs
                                                                AND Subservice__c IN :iditems];
                                                                
                for (Subs_Item_Subservice__c subsItemSub : lstSubsItemSub)
                {
                    if (!mapSubSubserv.containsKey(subsItemSub.Subscription_Line_Item__r.Subscription__c))
                        mapSubSubserv.put(subsItemSub.Subscription_Line_Item__r.Subscription__c, new List<Subs_Item_Subservice__c>());
                    
                    mapSubSubserv.get(subsItemSub.Subscription_Line_Item__r.Subscription__c).add(subsItemSub);  
                }   
                
                // Subs Package and Fee
                Map<Id, List<Subs_Package_And_Fee__c>> mapSubPAF = new Map<Id, List<Subs_Package_And_Fee__c>>();
                
                List<Subs_Package_And_Fee__c> lstSubsPAF = [SELECT Id, Package_and_Fee__c, Subscription__c 
                                                            FROM Subs_Package_And_Fee__c
                                                            WHERE Subscription__c IN :idsubs
                                                            AND Package_and_Fee__c IN :iditems];
                                                                
                for (Subs_Package_And_Fee__c subsPAF : lstSubsPAF)
                {
                    if (!mapSubPAF.containsKey(subsPAF.Subscription__c))
                        mapSubPAF.put(subsPAF.Subscription__c, new List<Subs_Package_And_Fee__c>());
                    
                    mapSubPAF.get(subsPAF.Subscription__c).add(subsPAF);
                }   
            
                //List<Subs_Promotion__c> lstSubP                 = new List<Subs_Promotion__c>();
                //List<Subscription_Promo_Line_Item__c> lstSubPLI = new List<Subscription_Promo_Line_Item__c>();
                
                Map<ID, Subscription__c> subscriptions = new Map<ID, Subscription__c>([SELECT Id, CurrencyIsoCode FROM Subscription__c WHERE Id IN :idsubs]);
                
                for (ID sub : idsubs)
                {
                    SubStatus s = new SubStatus(sub);
                    
                    if (subscriptions.get(sub).CurrencyIsoCode != this.cp.CurrencyIsoCode)
                    {
                        s.status   = false;
                        s.error    = 'Currencies of campaign promotion and subscription are different';
                    }
                    else
                    {
                        Boolean allPresent = true;
                        
                        if (this.cp.Level__c == 'Service(s)')
                        {
                            if (!mapSubSubserv.containsKey(sub) || mapSubSubserv.get(sub).size() != iditems.size())
                            {
                                allPresent = false;
                                s.status   = false;
                                s.error    = '';
                                Integer nbNotFound = 0;
                                
                                for (ID subserv : iditems)
                                {
                                    Boolean found = false;
                                    if (mapSubSubserv.containsKey(sub))
                                    {
                                        for (Subs_Item_Subservice__c subsItemSub : mapSubSubserv.get(sub))
                                        {
                                            if (subsItemSub.Subservice__c == subserv)
                                            {
                                                found = true;
                                                break;
                                            }
                                        }
                                    }
                                    
                                    if (!found)
                                    {
                                        nbNotFound++;
                                        s.error += itemNames.get(subserv) + ', ';
                                    }
                                }
                                
                                if (nbNotFound == 1)
                                    s.error = 'Following service is missing: ' + s.error.substring(0, s.error.length() - 2);
                                else
                                    s.error = 'Following services are missing: ' + s.error.substring(0, s.error.length() - 2);
                            }
                        }
                        else if (this.cp.Level__c == 'Package(s)/Fee(s)')
                        {
                            if (!mapSubPAF.containsKey(sub) || mapSubPAF.get(sub).size() != iditems.size())
                            {
                                allPresent = false;
                                s.status   = false;
                                s.error    = '';
                                Integer nbNotFound = 0;
                                
                                for (ID paf : iditems)
                                {
                                    Boolean found = false;
                                    if (mapSubPAF.containsKey(sub))
                                    {
                                        for (Subs_Package_And_Fee__c subspaf : mapSubPAF.get(sub))
                                        {
                                            if (subspaf.Package_and_Fee__c == paf)
                                            {
                                                found = true;
                                                break;
                                            }
                                        }
                                    }
                                    
                                    if (!found)
                                    {
                                        nbNotFound++;
                                        s.error += itemNames.get(paf) + ', ';
                                    }
                                }
                                
                                if (nbNotFound == 1)
                                    s.error = 'Following package/fee is missing: ' + s.error.substring(0, s.error.length() - 2);
                                else
                                    s.error = 'Following packages/fees are missing: ' + s.error.substring(0, s.error.length() - 2);
                            }
                        }
                        
                        if (allPresent)
                        {
                            // Add Subscription Promotion
                            Subs_Promotion__c sp     = new Subs_Promotion__c();
                            sp.Name                  = this.cp.Name;
                            sp.Subscription__c       = sub;
                            sp.CurrencyIsoCode       = this.cp.CurrencyIsoCode;
                            sp.Campaign_Promotion__c = this.cp.Id;
                            insert sp;
                           
                            Subscription_Promo_Line_Item__c sprli = new Subscription_Promo_Line_Item__c();
                            sprli.End_Date__c                     = this.cp.End_Date__c;
                            sprli.Sales_Price__c                  = this.cp.SalesPrice__c;
                            sprli.Start_Date__c                   = this.cp.Start_Date__c;
                            sprli.Subscription__c                 = sub;
                            sprli.Subs_Promotion__c               = sp.Id;
                            sprli.Discount__c                     = this.cp.Discount__c;
                            sprli.Discount_Percentage__c          = this.cp.Discount_Percentage__c;
                            sprli.CurrencyIsoCode                 = this.cp.CurrencyIsoCode;
                            insert sprli;
                           
                            List<Subs_Promo_Link__c> lstSubPL = new List<Subs_Promo_Link__c>();
                            
                            if (this.cp.Level__c == 'Service(s)')
                            {
                                for (Subs_Item_Subservice__c subISub : mapSubSubserv.get(sub))
                                {
                                    Subs_Promo_Link__c subsPL       = new Subs_Promo_Link__c();
                                    subsPL.Subs_Item_Subservice__c  = subISub.Id;
                                    subsPL.Subs_Promotion__c        = sp.Id;
                                    subsPL.CurrencyIsoCode          = this.cp.CurrencyIsoCode;
                                    lstSubPL.add(subsPL);
                                }
                            }
                            else
                            {
                                for (Subs_Package_And_Fee__c subPAF : mapSubPAF.get(sub))
                                {
                                    Subs_Promo_Link__c subsPL       = new Subs_Promo_Link__c();
                                    subsPL.Subs_Package_And_Fee__c  = subPAF.Id;
                                    subsPL.Subs_Promotion__c        = sp.Id;
                                    subsPL.CurrencyIsoCode          = this.cp.CurrencyIsoCode;
                                    lstSubPL.add(subsPL);
                                }
                            }
                            
                            if (lstSubPL.size() > 0)
                                insert lstSubPL;
                        }
                    }
                    
                    statuses.add(s);
                }
            }
            else
            {
                statuses = new List<SubStatus>();
                
                Set<ID> idsubs = new Set<ID>();
                for (Campaign_Promotion_Subscription_LI__c cpsli : this.cp.Campaign_Promotion_Subscription_LIs__r)
                    idsubs.add(cpsli.Subscription__c);
                    
                Map<ID, Subscription__c> subscriptions = new Map<ID, Subscription__c>([SELECT Id, CurrencyIsoCode FROM Subscription__c WHERE Id IN :idsubs]);
                
                for (Campaign_Promotion_Subscription_LI__c cpsli : this.cp.Campaign_Promotion_Subscription_LIs__r)
                {
                    SubStatus s = new SubStatus(cpsli.Subscription__c);
                    
                    if (subscriptions.get(cpsli.Subscription__c).CurrencyIsoCode != this.cp.CurrencyIsoCode)
                    {
                        s.status   = false;
                        s.error    = 'Currencies of campaign promotion and subscription are different';
                    }
                    else
                    {
                        // Add Subscription Promotion
                        Subs_Promotion__c sp     = new Subs_Promotion__c();
                        sp.Name                  = this.cp.Name;
                        sp.Subscription__c       = cpsli.Subscription__c;
                        sp.Campaign_Promotion__c = this.cp.Id;
                        sp.CurrencyIsoCode       = this.cp.CurrencyIsoCode;
                        insert sp;
                       
                        Subscription_Promo_Line_Item__c sprli = new Subscription_Promo_Line_Item__c();
                        sprli.End_Date__c                     = this.cp.End_Date__c;
                        sprli.Sales_Price__c                  = this.cp.SalesPrice__c;
                        sprli.Start_Date__c                   = this.cp.Start_Date__c;
                        sprli.Subscription__c                 = cpsli.Subscription__c;
                        sprli.Subs_Promotion__c               = sp.Id;
                        sprli.Discount__c                     = this.cp.Discount__c;
                        sprli.Discount_Percentage__c          = this.cp.Discount_Percentage__c;
                        sprli.CurrencyIsoCode                 = this.cp.CurrencyIsoCode;
                        insert sprli;
                    }
                    
                    statuses.add(s);
                }
            }
        }
        
        return null;
    }
    
    public PageReference Cancel() 
    {
        return (Utilities.Redirect(this.cp.id));
    }

}