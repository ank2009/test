public class TLR_NewRightsTemplateDefaultController 
{
    private final Offer_Template__c ot;
    public Rights_Template_Default__c rightsTpl;
    public Boolean cugAllowed {get; set;}
    public List<SelectOption> optionsCUG;
    public List<SelectOption> optionsPUGs;
    public List<SelectOption> optionsPIA;
    
    public TLR_NewRightsTemplateDefaultController(ApexPages.StandardController controller){
	
        ID otId = System.currentPagereference().getParameters().get('id');
        this.ot = [SELECT Id, CUG_allowed__c FROM Offer_Template__c WHERE Id = :otId];
        cugAllowed = this.ot.CUG_allowed__c;
    }
    
    public PageReference init(){
	
        this.rightsTpl = new Rights_Template_Default__c();
        this.rightsTpl.Offer_Template__c = this.ot.Id;
        this.rightsTpl.Status__c = 'Pending';
        
        if (optionsCUG == null){		
			optionsCUG = new List<SelectOption>();
			if (cugAllowed){
				List <Schema.PicklistEntry> vals = Schema.getGlobalDescribe().get('Rights_Template_Default__c').getDescribe().fields.getMap().get('Private_Exchange_ID__c').getDescribe().getPicklistValues();
				for (Schema.PicklistEntry val : vals){
					optionsCUG.add(new SelectOption(val.getValue(), val.getLabel()));
				}
			}else{
					optionsCUG.add(new SelectOption('OPEN','OPEN'));
				}
            this.rightsTpl.Private_Exchange_ID__c = 'OPEN';
        }       
        if (optionsPUGs == null){
                optionsPUGs = new List<SelectOption>();
               // List <Schema.PicklistEntry> vals = Schema.getGlobalDescribe().get('User_Profile__c').getDescribe().fields.getMap().get('User_PUG_Name__c').getDescribe().getPicklistValues();
				 List <Schema.PicklistEntry> vals = Schema.getGlobalDescribe().get('Rights_Template_Default__c').getDescribe().fields.getMap().get('PUG_Name__c').getDescribe().getPicklistValues();
				for (Schema.PicklistEntry val : vals)
					optionsPUGs.add(new SelectOption(val.getValue(), val.getLabel()));
        }
        
        if (optionsPIA == null){
                optionsPIA = new List<SelectOption>();
                List <Schema.PicklistEntry> vals = Schema.getGlobalDescribe().get('Rights_Template_Default__c').getDescribe().fields.getMap().get('PIA_Interface__c').getDescribe().getPicklistValues();
                for (Schema.PicklistEntry val : vals)
                    optionsPIA .add(new SelectOption(val.getValue(), val.getLabel()));
        }        
        return null;
    }
    
    public Rights_Template_Default__c getRT(){
        return rightsTpl;
    }    
    public List<SelectOption> getOptionsCUG(){
        return optionsCUG;
    }    
    public List<SelectOption> getOptionsPUGs(){
        return optionsPUGs;
    }    
    public List<SelectOption> getOptionsPIA(){
        return optionsPIA;
    }
    
    public PageReference Save(){   
        List<Rights_Template_Default__c> templates = [SELECT Id, Name,Default__c FROM Rights_Template_Default__c WHERE Offer_Template__c = :this.ot.Id];
        Set<String> names = new Set<String>();
        for (Rights_Template_Default__c template : templates){
            names.add(template.Name);
        }
        //Default for first creation
        if(templates.isEmpty()){
        	rightsTpl.Default__c = true;
        }
        if (names.contains(rightsTpl.Name)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Rights Template name must be unique in a Offer Template object'));
            return null;
        }
        else{
		 try{
			insert rightsTpl;
			}catch(Exception e){
				System.debug('RT Default insetion Failed=>'+e);
			}
		}
        
        return (Utilities.Redirect(this.rightsTpl.Id));
    }
    
    public PageReference SaveAndNew(){   
    	List<Rights_Template_Default__c> rTemplates = [SELECT Id, Name, Default__c FROM Rights_Template_Default__c WHERE Offer_Template__c = :this.ot.Id];
    	//Default for first creation
        if(rTemplates.isEmpty()){
        	rightsTpl.Default__c = true;
        }
        try{
				insert rightsTpl;
			}catch(Exception e){
				System.debug('RT Default insetion Failed=>'+e);
			}        
        return (Utilities.Redirect('apex/TLR_NewRightsTemplateDefault?id=' + this.ot.Id));
    }
    
    public PageReference Cancel(){
        return (Utilities.Redirect(this.ot.Id));
    }
}