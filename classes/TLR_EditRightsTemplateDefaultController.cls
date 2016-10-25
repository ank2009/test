public class TLR_EditRightsTemplateDefaultController 
{
    public Rights_Template_Default__c rightsTpl;
    public Boolean cugAllowed {get; set;}
    
    public TLR_EditRightsTemplateDefaultController(ApexPages.StandardController controller) 
    {
        ID rtId = System.currentPagereference().getParameters().get('id');
        this.rightsTpl = [SELECT Id, Status__c, Name, Default__c, Offer_Template__c,WKTS_Profiles__c, Offer_Template__r.CUG_allowed__c, Private_Exchange_ID__c, PUG_Name__c, PIA_Interface__c FROM Rights_Template_Default__c WHERE Id = :rtId];
        cugAllowed = this.rightsTpl.Offer_Template__r.CUG_allowed__c;
    }
    
    public Rights_Template_Default__c getRT(){
        return rightsTpl;
    }
    
    public PageReference Save(){   
        try{
            update rightsTpl;
            return (Utilities.Redirect(System.currentPagereference().getParameters().get('retURL')));
        }catch (DmlException e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getDmlMessage(0)));
            return null;
        }
    }
    
    public PageReference Cancel(){
        return (Utilities.Redirect(System.currentPagereference().getParameters().get('retURL')));
    }
}