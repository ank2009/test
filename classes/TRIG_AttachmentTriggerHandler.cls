public class TRIG_AttachmentTriggerHandler extends TRIG_TriggerHandlerAbstract
{
	public boolean IsTriggerContext { get { return isTriggerExecuting;} }

    public TRIG_AttachmentTriggerHandler (boolean isTriggerExecuting) 
    {
        super(isTriggerExecuting);
    }
    
    public override void OnBeforeInsert(List<sObject> newTriggerValues) 
    {
    }
    public override void OnAfterInsert(List<sObject> newTriggerValues, Map<ID, sObject> newTriggerValuesMap)
    {
        SendUpdatesToJira(newTriggerValues);
    } 
    
    public override void OnBeforeUpdate (List<sObject> oldTriggerValues, List<sObject> newTriggerValues, Map<ID, sObject> oldTriggerValuesMap, Map<ID, sObject> newTriggerValuesMap) 
    {
    }
    
    public override void OnAfterUpdate  (List<sObject> oldTriggerValues, List<sObject> newTriggerValues, Map<ID, sObject> oldTriggerValuesMap, Map<ID, sObject> newTriggerValuesMap) 
    {
    }
    
    public override void OnBeforeDelete (List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap) {}
    public override void OnAfterDelete  (List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap) 
    {
        SendUpdatesToJira(oldTriggerValues);
    }

    public override void OnAfterUndelete(List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap) {}

    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2015 September 22
    * @description  if attachment is added/removed from Case - we need to update Jira
    **/
    public void SendUpdatesToJira(List<sObject> objects)
    {
        string casePrefix = Schema.getGlobalDescribe().get('Case').getDescribe().getKeyPrefix();
        Set<string> casesIdSet = new Set<string>();
        
        for(sObject o : objects)
        {
            Attachment att = (Attachment)o;
            string oId = att.ParentId;
            
            if(oId.startsWith(casePrefix))		// if our attachment related to case
                if(!casesIdSet.contains(oId))	// in case we already have this caseId in our set
                	casesIdSet.add(oId);
        }
        for(string sId : casesIdSet)
            JIRA_Proxy.NotifyCaseUpdated(sId);
    }
}