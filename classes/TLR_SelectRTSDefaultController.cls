public class TLR_SelectRTSDefaultController 
{
    private final Rights_Template_Default__c rightsTpl; 
    private final Id prov;
    public List<String> valChk { get; set; }
    public List<SelectOption> options;
    public Map<ID, String> mapServices;
	public Boolean dataToDisplay { get; set; }
    public String title { get; set; }
    
    public TLR_SelectRTSDefaultController(ApexPages.StandardController controller) 
    {
        Id idRT = System.currentPagereference().getParameters().get('id');
        this.rightsTpl = [SELECT Id, Offer_Template__c, Status__c FROM Rights_Template_Default__c WHERE Id = :idRT];
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
   		List<Offer_Line_Item__c> services = [SELECT Name, Id, Service__c,Service_Attribute_Template__c FROM Offer_Line_Item__c WHERE Offer_Template__c = :this.rightsTpl.Offer_Template__c AND Service__c 
                                                 NOT IN (SELECT Service__c FROM Rights_Template_Service_Default__c WHERE Rights_Template__c = :this.rightsTpl.Id) ORDER BY Name ASC];
       
		
        System.Debug('### Query ok');
        
        for (Offer_Line_Item__c service : services){
            System.Debug('### service:' + service);
            options.add(new SelectOption(service.Service__c, service.Name));
            mapServices.put(service.Service__c, service.Name);	
        }        
        // Error : nothing to add
        if (options.size() == 0){
            dataToDisplay = false;
            title = 'Error';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'No Service available. All available services have already been added.'));
        }
        else{
            dataToDisplay = true;
            title = 'Select Service(s)';
        }        
        return null;
    }
    
    public List<SelectOption> getOptions(){
        return options;
    }
    
    public void selectAll(){
        valChk.clear();
        for (SelectOption s : options)
            valChk.add(s.getValue());
    }
    
    public void deselectAll(){
        valChk.clear();
    }
    
    public PageReference Save() 
    {
    	Map<ID, ID> mapRTServices = new Map<ID, ID>();        
        // RT Service Default
        List<Rights_Template_Service_Default__c> rtsToInsert = new List<Rights_Template_Service_Default__c>();                                               
        for (String s : valChk){
            Rights_Template_Service_Default__c serv = new Rights_Template_Service_Default__c();
            serv.Name 						= mapServices.get(s);
            serv.Rights_Template__c 		= this.rightsTpl.Id;
            serv.Service__c 				= s;
            rtsToInsert.add(serv);
        }
        
        if (rtsToInsert.size() > 0){
			try{
				insert rtsToInsert;
				System.debug('******rtsToInsert=>'+rtsToInsert);
			}catch(Exception e){
				System.debug('Rights_Template_Service_Default__c insertion Failed=>'+e);
			}
		}	
        	
        for (Rights_Template_Service_Default__c rts : rtsToInsert){
        	mapRTServices.put(rts.Service__c, rts.Id);
        }  
        System.debug('******mapRTServices=>'+mapRTServices); 
    	List<Service_Attribute_Template_Line_Item__c> servAttrTplLIs = [Select s.Service_Attribute__c,Service_Attribute__r.Name,Service_Attribute__r.Parent__c, s.Service_Attribute_Template__c, s.Name, s.Id 
																				  From Service_Attribute_Template_Line_Item__c s 
																				  where Service_Attribute__r.Parent__c IN : mapRTServices.keySet()]; 
		
		 System.debug('******servAttrTplLIs=>'+servAttrTplLIs);  
		 List<Rights_Template_Service_Attribute_Def__c> rtsaToInsert = new List<Rights_Template_Service_Attribute_Def__c>();	
		 for(Service_Attribute_Template_Line_Item__c objSATLI: servAttrTplLIs){
	 		
		 	if(mapRTServices.containsKey(objSATLI.Service_Attribute__r.Parent__c)){
		 		
		 		Rights_Template_Service_Attribute_Def__c RTSADefault = new Rights_Template_Service_Attribute_Def__c();
	            RTSADefault.Name 								     = objSATLI.Service_Attribute__r.Name;
	            RTSADefault.Rights_Template_Service__c 		         = mapRTServices.get(objSATLI.Service_Attribute__r.Parent__c);
	            RTSADefault.Service_Attribute__c 				     = objSATLI.Service_Attribute__c;
	            rtsaToInsert.add(RTSADefault);
		 	}
	 	}
		System.debug('******rtsaToInsert=>'+rtsaToInsert);  
		if (rtsaToInsert.size() > 0){
  		try{
				insert rtsaToInsert;
			}catch(Exception ex){
				System.debug('Rights_Template_Service_Attribute_Def__c insertion Failed=>'+ex);
			}
		}	
        return (Utilities.Redirect(this.rightsTpl.id));
    }
    
    public PageReference Cancel(){
        return (Utilities.Redirect(this.rightsTpl.id));
    }
}