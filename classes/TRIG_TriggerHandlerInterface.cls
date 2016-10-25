/*
* @author		Anton Solovyev (anton_soloveyv@epam.com)
* @date			2013 June 31
* @description	interface for trigger handlers.
**/
public interface TRIG_TriggerHandlerInterface 
{
	void OnBeforeInsert(List<sObject> newValues);
	void OnAfterInsert(List<sObject> newValues, Map<ID, sObject> newValuesMap);

	void OnBeforeUpdate(List<sObject> oldValues, List<sObject> newValues, Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap);
	void OnAfterUpdate(List<sObject> oldValues, List<sObject> newValues, Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap);

	void OnBeforeDelete(List<sObject> oldValues, Map<ID, sObject> oldValuesMap);
	void OnAfterDelete(List<sObject> oldValues, Map<ID, sObject> oldValuesMap);

	void OnAfterUndelete(List<sObject> oldValues, Map<ID, sObject> oldValuesMap);
}