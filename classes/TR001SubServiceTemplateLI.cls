/**
 * Name : TR001SubServiceTemplateLI 
 * Created By : Abdallah Dahjou <abdllah.dahjou@kerensen.com>
 * Date : 2011-08-23
 *Called by Trigger SubServiceTemplateLIAfterInsert to update Subservice parent
**/


public  class TR001SubServiceTemplateLI {
public static void updateSubserviceParent(Subservice_Template_Line_Item__c[] lstSubServiceTemplateLI){
    
    PAD.myLog('START TR001SubServiceTemplateLI.updateSubserviceParent');
        
    
         Set<ID> setIdSubserviceTLIs = new Set<ID>();
          Set<ID> setIdSubservices = new Set<ID>();
           Set<ID> setIdSubserviceTemplates = new Set<ID>();
            for (Subservice_Template_Line_Item__c SubserviceTLI : lstSubServiceTemplateLI) {
            setIdSubserviceTLIs.add(SubserviceTLI.Id);   
            setIdSubservices.add(SubserviceTLI.Subservice__c);
            setIdSubserviceTemplates.add(SubserviceTLI.Template__c);
                 }
        
        
        Map<ID, Subservice_Template_Line_Item__c> SubstliList = new Map<ID, Subservice_Template_Line_Item__c>([select Subservice__c,Template__c from Subservice_Template_Line_Item__c where Id in :setIdSubserviceTLIs]);
        
        Map<ID, Subservice__c> SubsList = new Map<ID, Subservice__c>([select Name,Parent_Service__c from Subservice__c where Id in :setIdSubservices]);
        
        Map<ID, Subservice_Template__c> SubstList = new Map<ID, Subservice_Template__c>([select Name,Parent_Service__c from Subservice_Template__c where Id in :setIdSubserviceTemplates]);
        
        
        for(Subservice_Template_Line_Item__c substliobject : SubstliList.values() ){
        
        for(Subservice__c subsobject : SubsList.values() ){
        
        for(Subservice_Template__c substobject : SubstList.values() ){
        if(substliobject.Subservice__c == subsobject.Id && substliobject.Template__c == substobject.Id )
        
        subsobject.Parent_Service__c = substobject.Parent_Service__c;
        }
        }
        
        }
        update SubsList.values();

    
    PAD.myLog('END TR001SubServiceTemplateLI.updateSubserviceParent');
    }
    
    
    public static void updateSubserviceToInactive(Subservice_Template_Line_Item__c[] lstSubServiceTemplateLI){
    
    PAD.myLog('START TR001SubServiceTemplateLI.updateSubserviceToInactive');
        
    
         Set<ID> setIdSubserviceTLIs = new Set<ID>();
          Set<ID> setIdSubservices = new Set<ID>();
           Set<ID> setIdSubserviceTemplates = new Set<ID>();
            for (Subservice_Template_Line_Item__c SubserviceTLI : lstSubServiceTemplateLI) {
            setIdSubserviceTLIs.add(SubserviceTLI.Id);   
            setIdSubservices.add(SubserviceTLI.Subservice__c);
            setIdSubserviceTemplates.add(SubserviceTLI.Template__c);
                 }
        
        
        Map<ID, Subservice_Template_Line_Item__c> SubstliList = new Map<ID, Subservice_Template_Line_Item__c>([select Subservice__c,Template__c from Subservice_Template_Line_Item__c where Id in :setIdSubserviceTLIs]);
        
        Map<ID, Subservice__c> SubsList = new Map<ID, Subservice__c>([select Name,Parent_Service__c from Subservice__c where Id in :setIdSubservices]);
        
        Map<ID, Subservice_Template__c> SubstList = new Map<ID, Subservice_Template__c>([select Name,Parent_Service__c from Subservice_Template__c where Id in :setIdSubserviceTemplates]);
        
        
        for(Subservice_Template_Line_Item__c substliobject : SubstliList.values() ){
        
        for(Subservice__c subsobject : SubsList.values() ){
        
        for(Subservice_Template__c substobject : SubstList.values() ){
        if(substliobject.Subservice__c == subsobject.Id && substliobject.Template__c == substobject.Id )
        
        subsobject.Parent_Service__c = substobject.Parent_Service__c;
        }
        }
        
        }
        update SubsList.values();

    
    PAD.myLog('END TR001SubServiceTemplateLI.updateSubserviceToInactive');
    }

}