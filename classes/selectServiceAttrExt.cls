public class selectServiceAttrExt 
{
    private final Service_Attribute_Template__c templ;
    public List<String> valChk { get; set; }
    public List<SelectOption> options;
    public Boolean dataToDisplay { get; set; }
    public String title { get; set; }
 
    public selectServiceAttrExt(ApexPages.StandardController controller) 
    {
        //this.templ = (Service_Attribute_Template__c)controller.getRecord();
        Id idTpl = System.currentPagereference().getParameters().get('id');
        this.templ = [SELECT Id, Start_Date__c FROM Service_Attribute_Template__c WHERE Id = :idTpl];
    }
    
    public PageReference init()
    {
        ID idServ = [SELECT Parent__c FROM Service_Attribute_Template__c WHERE Id = :this.templ.Id].Parent__c;
        List<Service_Attribute__c> servattr = [SELECT Name, Id FROM Service_Attribute__c WHERE (Parent__c = null OR Parent__c = :idServ) AND Status__c = 'Active' AND Start_Date__c <= :this.templ.Start_Date__c ORDER BY Name ASC];
        
        if (options == null)
            options = new SelectOption[0];
        if (valChk == null)
            valChk = new String[0];
            
        for (Service_Attribute__c servA : servattr)
        {
            Integer cpt = [SELECT count() FROM Service_Attribute_Template_Line_Item__c WHERE Service_Attribute_Template__c = :this.templ.id AND Service_Attribute__c = :servA.Id];
            
            if (cpt == 0)
                options.add(new SelectOption(servA.Id, servA.Name));
        }

        dataToDisplay = true;
        title = 'Select Service Attribute(s)';    
        
        String serviceStatus = [SELECT Status__c FROM Service__c WHERE Id = :idServ].Status__c;
        
        if(serviceStatus != 'Pending')
        {
            dataToDisplay = false;
            title = 'Error';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Service Attributes can be linked only if Service is under Pending status.'));
        }
        else if (options.size() == 0)
        {
            dataToDisplay = false;
            title = 'Error';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'No Service Attribute available. Either no Active Service Attribute with compatible Start Date is existing for this service or all existing Service Attributes have already been added.'));
        }
        
        return null;
    }
    
    public List<SelectOption> getOptions()
    {
        return options;
    }
    
    public void selectAll()
    {
        PAD.Log('TR003 Begin Prepare');
        valChk.clear();
        for (SelectOption s : options)
            valChk.add(s.getValue());
    }
    
    public void deselectAll()
    {
        PAD.Log('TR003 End Prepare');
        valChk.clear();
    }
    
    public PageReference Save() 
    {
        for (String s : valChk)
        {
            Integer cpt = [SELECT count() FROM Service_Attribute_Template_Line_Item__c WHERE Service_Attribute_Template__c = :this.templ.id AND Service_Attribute__c = :s];
            
            if (cpt == 0)
            {
                Service_Attribute_Template_Line_Item__c link = new Service_Attribute_Template_Line_Item__c();
                link.Service_Attribute_Template__c = this.templ.id;
                link.Service_Attribute__c = s;
                insert link;
            }
        }

        return (Utilities.Redirect(this.templ.id));
    }
    
    public PageReference Cancel() 
    {
        return (Utilities.Redirect(this.templ.id));
    }
}