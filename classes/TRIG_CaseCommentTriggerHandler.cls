public class TRIG_CaseCommentTriggerHandler extends TRIG_TriggerHandlerAbstract
{
	public boolean IsTriggerContext { get { return isTriggerExecuting;} }

    public TRIG_CaseCommentTriggerHandler (boolean isTriggerExecuting) 
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
        SendUpdatesToJira(newTriggerValues);
    }
    
    public override void OnBeforeDelete (List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap) {}
    public override void OnAfterDelete  (List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap) 
    {
        SendUpdatesToJira(oldTriggerValues);
    }
    
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2015 September 22
    * @description  if attachment is added/removed from Case - we need to update Jira
    **/
    public void SendUpdatesToJira(List<sObject> objects)
    {
        Set<string> IdSet = new Set<string>();
        
        for(sObject o : objects)
        {
            CaseComment cc = (CaseComment)o;
            string oId = cc.ParentId;
            
            if(!IdSet.contains(oId))	// in case we already have this caseId in our set
                IdSet.add(oId);
        }
        for(string sId : IdSet)
            JIRA_Proxy.NotifyCaseUpdated(sId);
    }
}