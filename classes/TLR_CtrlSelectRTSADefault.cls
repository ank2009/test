public class TLR_CtrlSelectRTSADefault 
{
    private final Rights_Template_Service_Default__c rightsTplServ;
    private final Id rightTpl;
    public List<String> valChk { get; set; }
    public List<SelectOption> options;
    public Map<ID, String> mapServiceAttributes;
    public Boolean dataToDisplay { get; set; }
    public String title { get; set; }
    
    public TLR_CtrlSelectRTSADefault(ApexPages.StandardController controller) 
    {
        Id idRTS = System.currentPagereference().getParameters().get('id');
        this.rightsTplServ = [SELECT Id, Rights_Template__c, Rights_Template__r.Status__c, Service__c, Rights_Template__r.Offer_Template__c FROM Rights_Template_Service_Default__c WHERE Id = :idRTS];
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
        
        Offer_Line_Item__c oFLItemObj = [SELECT Id,Service__c,Service_Attribute_Template__c FROM Offer_Line_Item__c WHERE Offer_Template__c = :this.rightsTplServ.Rights_Template__r.Offer_Template__c AND Service__c = :this.rightsTplServ.Service__c];
		
		if(oFLItemObj != null && oFLItemObj.Service_Attribute_Template__c != null){		
			
			List<Service_Attribute_Template_Line_Item__c> servAttrTplLIs = [SELECT Id,Name,Service_Attribute__c,Service_Attribute__r.Name FROM Service_Attribute_Template_Line_Item__c WHERE Service_Attribute_Template__c =:oFLItemObj.Service_Attribute_Template__c AND Service_Attribute__c 
																			       NOT IN (SELECT Service_Attribute__c FROM Rights_Template_Service_Attribute_Def__c WHERE Rights_Template_Service__c = :this.rightsTplServ.Id) ORDER BY Service_Attribute__r.Name ASC];			
		
			for (Service_Attribute_Template_Line_Item__c serviceAttribute : servAttrTplLIs){
			
				options.add(new SelectOption(serviceAttribute.Service_Attribute__c, serviceAttribute.Service_Attribute__r.Name));
				mapServiceAttributes.put(serviceAttribute.Service_Attribute__c, serviceAttribute.Service_Attribute__r.Name);
			}
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
            Integer cpt = [SELECT count() FROM Rights_Template_Service_Attribute_Def__c WHERE Rights_Template_Service__c = :this.rightsTplServ.Id AND Service_Attribute__c = :s];
            
            if (cpt == 0)
            {
                Rights_Template_Service_Attribute_Def__c servAttr = new Rights_Template_Service_Attribute_Def__c();
                servAttr.Name = mapServiceAttributes.get(s);
                servAttr.Rights_Template_Service__c = this.rightsTplServ.Id;
                servAttr.Service_Attribute__c = s;
             try{
					insert servAttr;
				}catch(Exception ex){
					System.debug('Rights_Template_Service_Attribute_Def__c insertion Faield=>'+ex);
				}
            }
        }
        
        return (Utilities.Redirect(this.rightsTplServ.id));
    }
    
    public PageReference Cancel() 
    {
        return (Utilities.Redirect(this.rightsTplServ.id));
    }
}