public class CtrlSelectRightsTemplateServices 
{
    private final Rights_Template__c rightsTpl;
    private final Id prov;
    public List<String> valChk { get; set; }
    public List<SelectOption> options;
    public Map<ID, String> mapServices;
    public Boolean dataToDisplay { get; set; }
    public String title { get; set; }
    
    public CtrlSelectRightsTemplateServices(ApexPages.StandardController controller) 
    {
        Id idRT = System.currentPagereference().getParameters().get('id');
        this.rightsTpl = [SELECT Id, Provisioning__c, Status__c FROM Rights_Template__c WHERE Id = :idRT];
    }

    public PageReference init()
    {
        System.Debug('### Entry');
        
        if (options == null)
            options = new SelectOption[0];
        if (valChk == null)
            valChk = new String[0];
        if (mapServices == null)
            mapServices = new Map<ID, String>();
        
        // Error : parent status
        if (this.rightsTpl.Status__c != 'Pending')
        {
            System.Debug('### Error not pending');
            dataToDisplay = false;
            title = 'Error';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Services can only be added to \'Pending\' rights templates.'));
            return null;
        }
        
        System.Debug('### Query');
        List<Provisioning_Service__c> services = [SELECT Name, Id, Service__c FROM Provisioning_Service__c WHERE Provisioning__c = :this.rightsTpl.Provisioning__c AND Service__c 
                                                 NOT IN (SELECT Service__c FROM Rights_Template_Service__c WHERE Rights_Template__c = :this.rightsTpl.Id) ORDER BY Name ASC];
        
        System.Debug('### Query ok');
        
        for (Provisioning_Service__c service : services)
        {
            System.Debug('### service:' + service);
            options.add(new SelectOption(service.Service__c, service.Name));
            mapServices.put(service.Service__c, service.Name);
        }
        
        // Error : nothing to add
        if (options.size() == 0)
        {
            dataToDisplay = false;
            title = 'Error';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'No Service available. All available services have already been added.'));
        }
        else
        {
            dataToDisplay = true;
            title = 'Select Service(s)';
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
    	Map<ID, ID> mapRTServices = new Map<ID, ID>();
        
        // Services
        List<Rights_Template_Service__c> rtsToInsert = new List<Rights_Template_Service__c>();
                                                                    
        for (String s : valChk)
        {
            Rights_Template_Service__c serv = new Rights_Template_Service__c();
            serv.Name 						= mapServices.get(s);
            serv.Rights_Template__c 		= this.rightsTpl.Id;
            serv.Service__c 				= s;
            rtsToInsert.add(serv);
        }
        
        if (rtsToInsert.size() > 0)
        	insert rtsToInsert;
        	
        for (Rights_Template_Service__c rts : rtsToInsert)
        	mapRTServices.put(rts.Service__c, rts.Id);
        
        // Service attributes (all added by default - KrN)
        List<Provisioning_Service_Attribute__c> serviceAttributes = [SELECT Name, Id, Service_Attribute__c,
        																	Provisioning_Service__r.Service__c 
    																 FROM Provisioning_Service_Attribute__c 
    																 WHERE Provisioning_Service__r.Provisioning__c = :this.rightsTpl.Provisioning__c 
    																 AND Provisioning_Service__r.Service__c IN :valChk 
    																 ORDER BY Name ASC];
    																 
		List<Rights_Template_Service_Attribute__c> rtsaToInsert = new List<Rights_Template_Service_Attribute__c>();
		
		for (Provisioning_Service_Attribute__c psa : serviceAttributes)
		{
			Rights_Template_Service_Attribute__c servAttr = new Rights_Template_Service_Attribute__c();
            servAttr.Name 								  = psa.Name;
            servAttr.Rights_Template_Service__c 		  = mapRTServices.get(psa.Provisioning_Service__r.Service__c);
            servAttr.Service_Attribute__c 				  = psa.Service_Attribute__c;
            rtsaToInsert.add(servAttr);
		}
		
		if (rtsaToInsert.size() > 0)
        	insert rtsaToInsert;
        
        return (Utilities.Redirect(this.rightsTpl.id));
    }
    
    public PageReference Cancel() 
    {
        return (Utilities.Redirect(this.rightsTpl.id));
    }
}