public class CtrlNewRightsTemplate 
{
    private final Provisioning__c prov;
    public Rights_Template__c rightsTpl;
    public Boolean cugAllowed {get; set;}
    public List<SelectOption> optionsCUG;
    public List<SelectOption> optionsPUGs;
    public List<SelectOption> optionsPIA;
    
    public CtrlNewRightsTemplate(ApexPages.StandardController controller) 
    {
        ID provId = System.currentPagereference().getParameters().get('id');
        this.prov = [SELECT Id, Subscription__r.CUG_allowed__c FROM Provisioning__c WHERE Id = :provId];
        cugAllowed = this.prov.Subscription__r.CUG_allowed__c;
    }
    
    public PageReference init()
    {
        this.rightsTpl = new Rights_Template__c();
        this.rightsTpl.Provisioning__c = this.prov.Id;
        this.rightsTpl.Status__c = 'Pending';
        
        if (optionsCUG == null)
        {
                optionsCUG = new List<SelectOption>();
                if (cugAllowed)
                {
                        List <Schema.PicklistEntry> vals = Schema.getGlobalDescribe().get('Rights_Template__c').getDescribe().fields.getMap().get('Private_Exchange_ID__c').getDescribe().getPicklistValues();
                    for (Schema.PicklistEntry val : vals)
                        optionsCUG.add(new SelectOption(val.getValue(), val.getLabel()));
                }
                else
                        optionsCUG.add(new SelectOption('OPEN','OPEN'));

            this.rightsTpl.Private_Exchange_ID__c = 'OPEN';
        }
        
        if (optionsPUGs == null)
        {
                optionsPUGs = new List<SelectOption>();
                List <Schema.PicklistEntry> vals = Schema.getGlobalDescribe().get('User_Profile__c').getDescribe().fields.getMap().get('User_PUG_Name__c').getDescribe().getPicklistValues();
            for (Schema.PicklistEntry val : vals)
                optionsPUGs.add(new SelectOption(val.getValue(), val.getLabel()));
        }
        
        if (optionsPIA == null)
        {
                optionsPIA = new List<SelectOption>();
                List <Schema.PicklistEntry> vals = Schema.getGlobalDescribe().get('Rights_Template__c').getDescribe().fields.getMap().get('PIA_Interface__c').getDescribe().getPicklistValues();
                for (Schema.PicklistEntry val : vals)
                    optionsPIA .add(new SelectOption(val.getValue(), val.getLabel()));
        }
        
        return null;
    }
    
    public Rights_Template__c getRT()
    {
        return rightsTpl;
    }
    
    public List<SelectOption> getOptionsCUG()
    {
        return optionsCUG;
    }
    
    public List<SelectOption> getOptionsPUGs()
    {
        return optionsPUGs;
    }
    
    public List<SelectOption> getOptionsPIA()
    {
        return optionsPIA;
    }
    
    public PageReference Save() 
    {   
        List<Rights_Template__c> templates = [SELECT Id, Name FROM Rights_Template__c WHERE Provisioning__c = :this.prov.Id];
        Set<String> names = new Set<String>();
        for (Rights_Template__c template : templates)
            names.add(template.Name);
        
        if (names.contains(rightsTpl.Name))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Rights Template name must be unique in a provisioning object'));
            return null;
        }
        else
                insert rightsTpl;
        
        return (Utilities.Redirect(this.rightsTpl.Id));
    }
    
    public PageReference SaveAndNew() 
    {   
        insert rightsTpl;
        
        return (Utilities.Redirect('apex/NewRightsTemplate?id=' + this.prov.Id));
    }
    
    public PageReference Cancel() 
    {
        return (Utilities.Redirect(this.prov.Id));
    }
}