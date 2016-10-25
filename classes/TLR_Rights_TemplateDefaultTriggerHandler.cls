/*
* @ Description :- Class handles all before and after Rights_Templates of Rights_Template object
* @ Author      :- HCL Technologies LTD
* @ Date        :- 28-02-2013 
**/

public without sharing class TLR_Rights_TemplateDefaultTriggerHandler {
    public Boolean isExecuting;
    public Integer size;   
    /**
    *TLR_Rights_TemplateTriggerHandler Constructor
    *@param isExecuting: Returns true if the current context for the Apex code is a trigger, not a Visualforce page
    *@param size: The total number of records in a trigger invocation, both old and new.
    **/
    public TLR_Rights_TemplateDefaultTriggerHandler(boolean isExecuting,Integer size){
        this.isExecuting = isExecuting;
        this.size = size;
    }
    /**
    *onBeforeInsert method is used to perform the before insert operation
    *@param newRights_Templates Rights_Template list with new values
    **/ 
    public void OnBeforeInsert(Rights_Template_Default__c[] newRights_Templates){
       // EXECUTE BEFORE INSERT LOGIC
     }
    /**
    *OnAfterInsert method is used to perform the after insert operation
    *@param newRights_Templates Rights_Template list with new values
    *@param oldRights_Templates Rights_Template list with old values
    *@param newRights_Templates Rights_Template map with new map of Rights_Template object and id
    *@param oldRights_Templates Rights_Template map with old values of Rights_Template object and id
    **/
    public void OnAfterInsert(Rights_Template_Default__c[] newRights_Templates, Rights_Template_Default__c[] oldRights_Templates, Map <Id,Rights_Template_Default__c> newRights_TemplateMap,Map <Id,Rights_Template_Default__c> oldRights_TemplateMap){
        // EXECUTE AFTER INSERT LOGIC
    }
    /**
    *OnBeforeUpdate method is used to perform the before update operation
    *@param newRights_Templates Rights_Template list with new values
    *@param oldRights_Templates Rights_Template list with old values
    *@param newRights_Templates Rights_Template map with new map of Rights_Template object and id
    *@param oldRights_Templates Rights_Template map with old values of Rights_Template object and id
    **/
    public void OnBeforeUpdate(Rights_Template_Default__c[] newRights_Templates, Rights_Template_Default__c[] oldRights_Templates, Map <Id,Rights_Template_Default__c> newRights_TemplateMap,Map <Id,Rights_Template_Default__c> oldRights_TemplateMap){
       // BEFORE UPDATE LOGIC
       //call updateDefaultFlag trigger logic
       updateDefaultFlag(newRights_Templates,oldRights_Templates);
    } 
    /**
    *OnAfterUpdate method is used to perform the after update operation
    *@param newRights_Templates Rights_Template list with new values
    *@param oldRights_Templates Rights_Template list with old values
    *@param newRights_Templates Rights_Template map with new map of Rights_Template object and id
    *@param oldRights_Templates Rights_Template map with old values of Rights_Template object and id
    **/
    public void OnAfterUpdate(Rights_Template_Default__c[] newRights_Templates, Rights_Template_Default__c[] oldRights_Templates, Map <Id,Rights_Template_Default__c> newRights_TemplateMap,Map <Id,Rights_Template_Default__c> oldRights_TemplateMap){
        // AFTER UPDATE LOGIC
     }
    /**
    *OnBeforeDelete method is used to perform the before delete operation
    *@param old Rights_Template map with old values
    **/
    public void OnBeforeDelete(Map <Id,Rights_Template_Default__c> oldRights_TemplateMap){
        // BEFORE DELETE LOGIC
    }
    /**
    *OnAfterDelete method is used to perform the after delete operation
    *@param old Rights_Template map with old values
    **/
    public void OnAfterDelete(Map <Id,Rights_Template_Default__c> oldRights_TemplateMap){
        // AFTER DELETE LOGIC
     }
    /**
    *OnUndelete method is used to perform the after undelete operation
    *@param old Rights_Template map with old values
    **/
    public void OnUndelete(Map <Id,Rights_Template_Default__c> oldRights_TemplateMap){
        // AFTER UNDELETE LOGIC
    }
    //Implement updateDefaultFlag trigger logic-BEFORE UPDATE
    public void updateDefaultFlag(Rights_Template_Default__c[] newRights_Templates,Rights_Template_Default__c[] oldRights_Templates){
        if(newRights_Templates.size()==1)
        {
            if(newRights_Templates.get(0).Default__c && !oldRights_Templates.get(0).Default__c)
            {
                List<Rights_Template_Default__c> rightTemplatelist = [SELECT Id, Default__c
																		FROM Rights_Template_Default__c
																		WHERE Default__c = true
																		AND Offer_Template__c =: newRights_Templates.get(0).Offer_Template__c];
                if(rightTemplatelist.size()>0)
                {
                    for(Rights_Template_Default__c rightTemplate : rightTemplatelist)
                    {
                        if(rightTemplate.Id != newRights_Templates.get(0).Id){                            
                            rightTemplate.Default__c = false;
                        }
                    }
                    if(! rightTemplatelist.isEmpty()){
                        try{
                            update rightTemplatelist;
                        }catch(Exception ex){
                            System.debug('Update failed RT==>'+ex);
                        }
                    }
                }
            }
        }
    } //end of updateDefaultFlag method 
   
}//end of TLR_Rights_TemplateTriggerHandler class