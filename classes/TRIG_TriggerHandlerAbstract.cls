/*
* @author		Anton Solovyev (anton_soloveyv@epam.com)
* @date			2013 June 31
* @description	base class for all the trigger handlers
**/
abstract public class TRIG_TriggerHandlerAbstract implements TRIG_TriggerHandlerInterface
{
	protected boolean isTriggerExecuting;

	public TRIG_TriggerHandlerAbstract(boolean isTriggerExecuting) { this.isTriggerExecuting = isTriggerExecuting; }

	public virtual void OnBeforeInsert (List<sObject> newTriggerValues) {}
	public virtual void OnAfterInsert  (List<sObject> newTriggerValues, Map<ID, sObject> newTriggerValuesMap) {}

	public virtual void OnBeforeUpdate (List<sObject> oldTriggerValues, List<sObject> newTriggerValues, Map<ID, sObject> oldTriggerValuesMap, Map<ID, sObject> newTriggerValuesMap) {}
	public virtual void OnAfterUpdate  (List<sObject> oldTriggerValues, List<sObject> newTriggerValues, Map<ID, sObject> oldTriggerValuesMap, Map<ID, sObject> newTriggerValuesMap) {}

	public virtual void OnBeforeDelete (List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap) {}
	public virtual void OnAfterDelete  (List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap) {}

	public virtual void OnAfterUndelete(List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap) {}
}