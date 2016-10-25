public class selectSubserviceExt 
{
    private final Subservice_Template__c templ;
    public List<String> valChk { get; set; }
    public List<SelectOption> options;
    
    public Boolean dataToDisplay { get; set; }
    public String title { get; set; }
    
    public selectSubserviceExt(ApexPages.StandardController controller) 
    {
        //this.templ = (Subservice_Template__c)controller.getRecord();
        Id idTpl = System.currentPagereference().getParameters().get('id');
        this.templ = [SELECT Id, Start_Date__c FROM Subservice_Template__c WHERE Id = :idTpl];
    }
    
    public PageReference init()
    {
        ID idServ = [SELECT Parent_Service__c FROM Subservice_Template__c WHERE Id = :this.templ.Id].Parent_Service__c;
        List<Subservice__c> subservices = [SELECT Name, Id FROM Subservice__c WHERE (Parent_Service__c = null OR Parent_Service__c = :idServ) AND Status__c = 'Active' AND Start_Date__c <= :this.templ.Start_Date__c ORDER BY Name ASC];
       
        if (options == null)
            options = new SelectOption[0];
        if (valChk == null)
            valChk = new String[0];
            
        for (Subservice__c subserv : subservices)
        {
            Integer cpt = [SELECT count() FROM Subservice_Template_Line_Item__c WHERE Template__c = :this.templ.id AND Subservice__c = :subserv.Id];
            
            if (cpt == 0)
                options.add(new SelectOption(subserv.Id, subserv.Name));
        }
        
        dataToDisplay = true;
        title = 'Select Subservice(s)';
        
        String serviceStatus = [SELECT Status__c FROM Service__c WHERE Id = :idServ].Status__c;
        
        if (serviceStatus != 'Pending')
        {
            dataToDisplay = false;
            title = 'Error';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Subservices can be linked only if Service is under Pending status.'));
        }
        else if (options.size() == 0)
        {
            dataToDisplay = false;
            title = 'Error';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'No Subservice available. Either no Active Subservice with compatible Start Date is existing for this service or all existing Subservices have already been added.'));
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
            Integer cpt = [SELECT count() FROM Subservice_Template_Line_Item__c WHERE Template__c = :this.templ.id AND Subservice__c = :s];
            
            if (cpt == 0)
            {
                Subservice_Template_Line_Item__c link = new Subservice_Template_Line_Item__c();
                link.Template__c = this.templ.id;
                link.Subservice__c = s;
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