public class selectCampaignPromotionServiceExt 
{
    private final Campaign_Promotion__c cp;
    public List<String> valChk { get; set; }
    public List<SelectOption> options;
    public Map<ID, String> mapServices;
    public Boolean dataToDisplay { get; set; }
    public String title { get; set; }
    
    public selectCampaignPromotionServiceExt(ApexPages.StandardController controller) 
    {
        ID cpId = System.currentPagereference().getParameters().get('id');
        this.cp = [SELECT Id, Start_Date__c, Level__c, CurrencyIsoCode FROM Campaign_Promotion__c WHERE Id = :cpId];
    }
    
    public PageReference init()
    {
        if (this.cp.Level__c == 'Subscription')
        {
            dataToDisplay = false;
            title = 'Error';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Line items cannot be added when level is \'Subscription\'.'));
            return null;
        }
        
        if (options == null)
            options = new SelectOption[0];
        if (valChk == null)
            valChk = new String[0];
        if (mapServices == null)
            mapServices = new Map<ID, String>();
        
        if(this.cp.Level__c == 'Service(s)')
        {
            List<Subservice__c> subServices = [SELECT Id, Name, (SELECT Id FROM Campaign_Promotion_Line_Items__r WHERE Campaign_Promotion__c = :this.cp.Id) FROM Subservice__c WHERE  Status__c = 'Active' AND Start_Date__c <= :this.cp.Start_Date__c ORDER BY Parent_Service__r.Name ASC];
            for (Subservice__c subServ : subServices)
            {
                if (subServ.Campaign_Promotion_Line_Items__r.size() == 0)
                {
                    options.add(new SelectOption(subServ.Id, subServ.Name));
                    mapServices.put(subServ.Id, subServ.Name);
                }
            }
        }
        else if (this.cp.Level__c == 'Package(s)/Fee(s)')
        {
            List<PackFee__c> packFees = [SELECT Id, Name, PrepaidPostpaid__c, Frequency__c, (SELECT Id FROM Campaign_Promotion_Line_Items__r WHERE Campaign_Promotion__c = :this.cp.Id) FROM PackFee__c WHERE  Status__c = 'Active' AND Start_Date__c <= :this.cp.Start_Date__c ORDER BY Name ASC];
            for (PackFee__c packFee : packFees)
            {
                if (packFee.Campaign_Promotion_Line_Items__r.size() == 0)
                {
                    options.add(new SelectOption(packFee.Id, packFee.Name + ' - ' + packFee.PrepaidPostpaid__c + ' - ' + packFee.Frequency__c));
                    mapServices.put(packFee.Id, packFee.Name);
                }
            }
        }
        
        if (options.size() == 0)
        {
            dataToDisplay = false;
            title = 'Error';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'No Service available. Either no active Service is existing or all existing Services have already been added.'));
        }
        else
        {
            dataToDisplay = true;
            title = 'Select items';
        }
        
        return null;
    }
    
    public List<SelectOption> getOptions()
    {
        return options;
    }
    
    public void selectAll()
    {
        valChk.clear();
        for (SelectOption s : options)
            valChk.add(s.getValue());
    }
    
    public void deselectAll()
    {
        valChk.clear();
    }
    
    public PageReference Save() 
    {
        List<Campaign_Promotion_Line_Item__c> cpLIToInsert = new List<Campaign_Promotion_Line_Item__c>();
        
        if(this.cp.Level__c == 'Service(s)')
        {
            for (String s : valChk)
            {
                Integer cpt = [SELECT Count() FROM Campaign_Promotion_Line_Item__c WHERE Campaign_Promotion__c = :this.cp.Id AND Subservice__c = :s];
                
                if (cpt == 0)
                {
                    Campaign_Promotion_Line_Item__c CPserv = new Campaign_Promotion_Line_Item__c();
                    CPserv.Campaign_Promotion__c = this.cp.Id;
                    Cpserv.CurrencyIsoCode       = this.cp.CurrencyIsoCode;
                    CPserv.Subservice__c         = s;
                    cpLIToInsert.add(CPserv);
                }
            }
        }
        else if (this.cp.Level__c == 'Package(s)/Fee(s)')
        {
            for (String s : valChk)
            {
                Integer cpt = [SELECT Count() FROM Campaign_Promotion_Line_Item__c WHERE Campaign_Promotion__c = :this.cp.Id AND Package_and_Fee__c = :s];
                
                if (cpt == 0)
                {
                    Campaign_Promotion_Line_Item__c CPpaf = new Campaign_Promotion_Line_Item__c();
                    CPpaf.Campaign_Promotion__c = this.cp.Id;
                    Cppaf.CurrencyIsoCode       = this.cp.CurrencyIsoCode;
                    CPpaf.Package_and_Fee__c    = s;
                    cpLIToInsert.add(CPpaf);
                }
            }
        }
        if (cpLIToInsert.size() > 0)
            insert cpLIToInsert;
        
        return (Utilities.Redirect(this.cp.Id));
    }
    
    public PageReference Cancel() 
    {
        return (Utilities.Redirect(this.cp.Id));
    }
}