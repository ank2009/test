public class addPaFServicesExt 
{
	private List<Id> recordTypeIds;
	
    private final PackFee__c packfee;
    public List<String> valChk { get; set; }
    public List<SelectOption> options;
    public Map<ID, String> mapServices;
    public Boolean error {get; set;}
    
    public addPaFServicesExt(ApexPages.StandardController controller) 
    {
        ID idPF = System.currentPagereference().getParameters().get('id');
        this.packfee = [SELECT Status__c, Level__c, CurrencyIsoCode FROM PackFee__c WHERE Id = :idPF];
        
        recordTypeIds = new List<Id>();
        recordTypeIds.add(TLR_RecordTypeHelper.getId('Service__c', 'TLR Service'));
        recordTypeIds.add(TLR_RecordTypeHelper.getId('Service__c', 'TAS Module'));
        recordTypeIds.add(TLR_RecordTypeHelper.getId('Service__c', 'TAS Maintenance'));
        recordTypeIds.add(TLR_RecordTypeHelper.getId('Service__c', 'TAS Consulting'));
    }

    public PageReference init()
    {
        error = false;
        
        if (this.packfee.Status__c != 'Pending')
        {
            error = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Package and Fee status must be Pending to link services!'));
            return null;
        }
        
        if (this.packfee.Level__c == 'Subscription')
        {
            error = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Package and Fee level cannot be set to Subscription to link services!'));
            return null;
        }
        
        if (options == null)
            options = new SelectOption[0];
        if (valChk == null)
            valChk = new String[0];
        if (mapServices == null)
            mapServices = new Map<ID, String>();

       
        List<Service__c> services = [
        	SELECT Name, Id 
        	FROM Service__c 
        	WHERE 
        		RecordTypeId IN :recordTypeIds 
        		AND Status__c = 'Active' 
        		AND Start_Date__c <= :Date.today() 
        	ORDER BY Name ASC
        ];
        
        Map<Id, integer> svcMap = new Map<Id, integer>(); 
        AggregateResult[] aRes = [
        	SELECT 
        		Service__c,
        		count(Id) 
        	FROM Package_and_Fee_Line_Item__c 
        	WHERE 
        		Parent__c = :packfee.id 
        	GROUP BY
        		Service__c
        ];
        for(AggregateResult ar : aRes)
        	svcMap.put((Id)ar.get('Service__c'), (Integer)ar.get('expr0'));
                
        for (Service__c service : services)
        {
            if (!svcMap.containsKey(service.Id) || svcMap.get(service.Id) == 0)
            {
                options.add(new SelectOption(service.Id, service.Name));
                mapServices.put(service.Id, service.Name);
            }
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
        Package_and_Fee_Line_Item__c[] pafLis = new Package_and_Fee_Line_Item__c[]{};
        ID tlrServRecType = Schema.getGlobalDescribe().get('Package_and_Fee_Line_Item__c').getDescribe().getRecordTypeInfosByName().get('TLR P&F Line Item').getRecordTypeId();
        for (String service : valChk)
        {
            Integer cpt = [SELECT count() FROM Package_and_Fee_Line_Item__c WHERE Parent__c = :packfee.id AND Service__c = :service];
            
            if (cpt == 0)
            {
                Package_and_Fee_Line_Item__c pafli = new Package_and_Fee_Line_Item__c();
                pafli.CurrencyIsoCode              = this.packfee.CurrencyIsoCode;
                pafli.Parent__c                    = packfee.id;
                pafli.Service__c                   = service;
                pafli.Weight__c                    = 1;
                pafLi.RecordTypeId                 = tlrServRecType;
                pafLis.add(pafli);
            }
        }
        
        try {
            insert pafLis;
            return (Utilities.Redirect(this.packfee.id));
        } catch( DmlException e ){
            ApexPages.addMessages(e);
            return null;
        }
    }
    
    public PageReference Cancel() 
    {
        return (Utilities.Redirect(this.packfee.id));
    }
}