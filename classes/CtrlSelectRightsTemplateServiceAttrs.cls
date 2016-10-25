public class CtrlSelectRightsTemplateServiceAttrs 
{
    private final Rights_Template_Service__c rightsTplServ;
    private final Id rightTpl;
    public List<String> valChk { get; set; }
    public List<SelectOption> options;
    public Map<ID, String> mapServiceAttributes;
    public Boolean dataToDisplay { get; set; }
    public String title { get; set; }
    
    public CtrlSelectRightsTemplateServiceAttrs(ApexPages.StandardController controller) 
    {
        Id idRTS = System.currentPagereference().getParameters().get('id');
        this.rightsTplServ = [SELECT Id, Rights_Template__c, Rights_Template__r.Status__c, Service__c, Rights_Template__r.Provisioning__c FROM Rights_Template_Service__c WHERE Id = :idRTS];
    }
    
    public PageReference init()
    {
        if (options == null)
            options = new SelectOption[0];
        if (valChk == null)
            valChk = new String[0];
        if (mapServiceAttributes == null)
            mapServiceAttributes = new Map<ID, String>();
        
        // Error : parent status
        if (this.rightsTplServ.Rights_Template__r.Status__c != 'Pending')
        {
            dataToDisplay = false;
            title = 'Error';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Service attributes can only be added to \'Pending\' rights templates.'));
            return null;
        }
        
        Id serviceId = [SELECT Id FROM Provisioning_Service__c WHERE Provisioning__c = :this.rightsTplServ.Rights_Template__r.Provisioning__c
                       AND Service__c = :this.rightsTplServ.Service__c].Id;
        List<Provisioning_Service_Attribute__c> serviceAttributes = [SELECT Name, Id, Service_Attribute__c FROM Provisioning_Service_Attribute__c WHERE Provisioning_Service__c = :serviceId AND Service_Attribute__c 
                                                                    NOT IN (SELECT Service_Attribute__c FROM Rights_Template_Service_Attribute__c WHERE Rights_Template_Service__c = :this.rightsTplServ.Id) ORDER BY Name ASC];
        
        for (Provisioning_Service_Attribute__c serviceAttribute : serviceAttributes)
        {
            options.add(new SelectOption(serviceAttribute.Service_Attribute__c, serviceAttribute.Name));
            mapServiceAttributes.put(serviceAttribute.Service_Attribute__c, serviceAttribute.Name);
        }
        
        if (options.size() == 0)
        {
            dataToDisplay = false;
            title = 'Error';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'No Service Attribute available. All available service attributes have already been added.'));
        }
        else
        {
            dataToDisplay = true;
            title = 'Select Service Attribute(s)';
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
        for (String s : valChk)
        {
            Integer cpt = [SELECT count() FROM Rights_Template_Service_Attribute__c WHERE Rights_Template_Service__c = :this.rightsTplServ.Id AND Service_Attribute__c = :s];
            
            if (cpt == 0)
            {
                Rights_Template_Service_Attribute__c servAttr = new Rights_Template_Service_Attribute__c();
                servAttr.Name = mapServiceAttributes.get(s);
                servAttr.Rights_Template_Service__c = this.rightsTplServ.Id;
                servAttr.Service_Attribute__c = s;
                insert servAttr;
            }
        }
        
        return (Utilities.Redirect(this.rightsTplServ.id));
    }
    
    public PageReference Cancel() 
    {
        return (Utilities.Redirect(this.rightsTplServ.id));
    }
}