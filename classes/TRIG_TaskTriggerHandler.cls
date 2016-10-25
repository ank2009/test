public with sharing class TRIG_TaskTriggerHandler extends TRIG_TriggerHandlerAbstract
{
    public boolean IsTriggerContext { get { return isTriggerExecuting;} }
    private ID SalesTaskRecordTypeId;
    private ID TLRTaskRecordTypeId;
    
    public TRIG_TaskTriggerHandler (boolean isTriggerExecuting) 
    {
        super(isTriggerExecuting);
        SalesTaskRecordTypeId = TLR_RecordTypeHelper.getId('Task','Sales Task'); 
        TLRTaskRecordTypeId = TLR_RecordTypeHelper.getId('Task','TLR Task'); 
    }
    
    public override void OnBeforeInsert(List<sObject> newTriggerValues)
    {
        TLR_EventAndTaskHelper.UpdateTaskOrEventSubject(null, newTriggerValues);
        TlrTaskTGOregistrationCreation(newTriggerValues); // 2 SOQL query, 3 custom settings get requset, 2 dml statements
        UpdateTaskFieldsForReporting(newTriggerValues); // 1 describe call
    }
    public override void OnAfterInsert(List<sObject> newTriggerValues, Map<ID, sObject> newTriggerValuesMap)
    {
        UpdateAccountLastVisitedDateTask(newTriggerValues, newTriggerValuesMap); // 1 soql query, 1 describe call, 1 dml statement
        UpdateOpptyScreenShare(newTriggerValues, null,false);
        TLR_EventAndTaskHelper.UpdateLeadCounter(newTriggerValues, null);
        TLR_EventAndTaskHelper.UpdateCampaignCounter(newTriggerValues, null);
    }

    public override void OnBeforeUpdate (List<sObject> oldTriggerValues, List<sObject> newTriggerValues, Map<ID, sObject> oldTriggerValuesMap, Map<ID, sObject> newTriggerValuesMap)
    {
        TLR_EventAndTaskHelper.UpdateTaskOrEventSubject(oldTriggerValues, newTriggerValues);
        UpdateTaskFieldsForReporting(newTriggerValues);  // 1 describe call
    }

    public override void OnAfterUpdate  (List<sObject> oldTriggerValues, List<sObject> newTriggerValues, Map<ID, sObject> oldTriggerValuesMap, Map<ID, sObject> newTriggerValuesMap)
    {
        UpdateAccountLastVisitedDateTask(newTriggerValues, newTriggerValuesMap); // 1 soql query, 1 describe call, 1 dml statement
        UpdateOpptyScreenShare(newTriggerValues, oldTriggerValuesMap,false);
        TLR_EventAndTaskHelper.UpdateLeadCounter(newTriggerValues, oldTriggerValuesMap);
        TLR_EventAndTaskHelper.UpdateCampaignCounter(newTriggerValues, oldTriggerValuesMap);
    }

    public override void OnBeforeDelete (List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap) {}
    public override void OnAfterDelete  (List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap) 
    {
        UpdateOpptyScreenShare(oldTriggerValues, null, true);
        TLR_EventAndTaskHelper.UpdateLeadCounter(oldTriggerValues, null);
        TLR_EventAndTaskHelper.UpdateCampaignCounter(oldTriggerValues, null);
    }

    public override void OnAfterUndelete(List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap) {}
    
    
    public void UpdateTaskFieldsForReporting(Task[] newTasks)
    {
        List<Task> taskObjectList = new List<Task>();
        ID recordTypeId = TLR_RecordTypeHelper.getId('Task', 'TLR Task');

        if (!newTasks.isEmpty())
        {
            for (Task task : newTasks)
            {
                if (task.RecordTypeId == recordTypeId)
                {
                    if (task.Type!=null)
                    {
                        task.Activity_Type__c = task.Type;
                    }
                    if (task.Subject!= null)
                    {
                        task.Activity_Task_Subject__c = task.Subject;
                    }
                    if (task.CallDurationInSeconds!=null)
                    {
                        task.Activity_Task_Duration__c = task.CallDurationInSeconds;
                    }
                    if (task!=null)
                    {
                        taskObjectList.add(task);
                    }
                }
            }
        }
    } //updateTaskFieldsForReporting end
    
    // 2 SOQL query, 3 custom settings get requset, 2 dml statements, 1 future method call
    public void TlrTaskTGOregistrationCreation(Task[] newTasks)
    {
        //We process only tasks created lonely.
        if(!newTasks.isEmpty() && (newTasks.get(0).Subject=='TGO_Approval' || newTasks.get(0).Subject=='TGO_Suspension'))
        {
            newTasks.get(0).Subject=newTasks.get(0).Subject.split('_')[1];
            newTasks.get(0).Subject_Group__c='TGO Administration';
            newTasks.get(0).Type='Administration';

            User_Profile__c up = [select Id, Contact__c,Suspension_Start_Date__c,Suspension_Reason__c,Status__c,Contact__r.AccountId,Contact__r.Username__c from User_Profile__c where Provisioning__c=:newTasks.get(0).WhatId];
            Account acc = [select Level_of_Certification__c,TCD_Published_status__c from Account where Id=:up.Contact__r.AccountId];
            String listIdentifier = SIMSettings__c.getValues('SIMSettings').TLR_Contact_List_Identifier__c;

            if(newTasks.get(0).Subject=='Approval')
            {
                String approvalProcessName = SIMSettings__c.getValues('SIMSettings').Approval_Process_Name__c;
                IndividualSoapASync.TriggerCampaignForUser(listIdentifier, approvalProcessName, 'SFDC_ID', up.Contact__c);
                if(acc.Level_of_Certification__c != '2' && acc.Level_of_Certification__c != '3')
                    acc.Level_of_Certification__c = '1';
                up.Status__c = 'Waiting for provisioning';
                up.Suspension_Start_Date__c = null;
                up.Suspension_Reason__c = '';
                acc.TCD_Published_status__c = 'Part 1 + 2 Activated by CRM';
            }
            else
            {
                if(newTasks.get(0).Subject=='Suspension')
                {
                    String suspensionProcessName = SIMSettings__c.getValues('SIMSettings').Suspension_Process_Name__c;
                    IndividualSoapASync.TriggerCampaignForUser(listIdentifier, suspensionProcessName, 'SFDC_ID', up.Contact__c);
                    //We add the TGO limited right
                    try
                    {
                        if(Generic.StringNotEmpty(up.Contact__r.Username__c))
                            Generic.AddRight(up.Contact__r.Username__c,'270');
                    }
                    catch(Exception ex)
                    {
                        system.debug('Exception : Add TGO limited right : '+ex.getMessage());
                    }
                    up.Status__c = 'Suspended';
                    up.Suspension_Start_Date__c = Date.today();
                    up.Suspension_Reason__c = 'None';
                    acc.TCD_Published_status__c = 'Part 1 + 2 Removed by CRM';
                }
            }
            try
            {
                update up;
                update acc;
            }
            catch(Exception ex)
            {
                System.debug('Update failed on TlrTaskTGOregistrationCreation=>'+ex);
            }
        }
    }//end of TlrTaskTGOregistrationCreation method
    
    // 1 soql query, 1 describe call, 1 dml statement
    public void UpdateAccountLastVisitedDateTask(List<sObject> newValues, Map<Id, sObject> newValuesMap) //, Task[] oldTasks, Map <Id,Task> oldTaskMap)
    {
        Set<ID> acctIds= new Set<ID>();
        if(! newValues.isEmpty())
        {
            for(sObject o : newValues)
            {
                Task t = (Task)o;
                if(t.AccountId != null) //acctIds.add(t.WhatId);
                    acctIds.add(t.AccountId);
            }
            Map<ID, Account> accounts = new Map<ID, Account>([SELECT Id, Last_Visited__c FROM Account WHERE Id IN :acctIds]);
            Account Acc =null;
            ID recordTypeId = TLR_RecordTypeHelper.getId('Task', 'TLR Task');
            for (sObject o : newValues)
            {
                Task NewTask = (Task)o;
                if(NewTask.RecordTypeId == recordTypeId && NewTask.Type =='23 Visit out' && NewTask.Status=='Completed' && NewTask.AccountId != null)
                {
                    String AccID = NewTask.AccountId;
                    Acc = accounts.get(AccID);
                    Acc.Last_Visited__c = System.today();
                    accounts.put(AccID, Acc);
                }
            }
            if(!accounts.isEmpty())
            {
                try
                {
                    update accounts.values();
                }
                catch(Exception ex)
                {
                    System.debug('Failed Update Account on Task->'+ex);
                }
            }
        }
    }//end of UpdateAccountLastVisitedDateTask method
    
 /*
     * @author       Andrey Gordienko (andrey_gordienko@epam.com)
     * @date         2014 October 28
     * @description  Updates oppty fields with count of specific tasks
     */
    private void UpdateOpptyScreenShare(List<Task> newTasks, Map<ID,SObject> oldTriggerValues, boolean isRemoved)
    {
        System.Debug('-------Counter--');
        string oppPrefix = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getKeyPrefix();
        Set<Id> opptyIdSet = new Set<Id>();
        string screenshareTaskType = General_Settings__c.getInstance('Default').ScreenSharing_TaskType__c; // '21 Screen sharing';
        
        for(Task e : newTasks)
        {
            if(e.WhatId != null)
            {
                string sId = string.valueOf(e.WhatId);
                if(sId.startsWith(oppPrefix))
                    opptyIdSet.add(e.WhatId);
            }
        }
        System.Debug('---------'+opptyIdSet.size());
        if(opptyIdSet.size() > 0)
        {
            Map<Id, Opportunity> opptyMap = new Map<Id, Opportunity>([
                SELECT
                    Id, Name, Screenshsare_Count__c
                FROM Opportunity
                WHERE Id IN :opptyIdSet
            ]);
            Map<ID, Opportunity> oppToUpdate = new Map<ID,Opportunity>();
            // fix null field values
            for(Id oppId : opptyMap.keySet())
            {
                if(opptyMap.get(oppId).Screenshsare_Count__c == null)
                {
                    opptyMap.get(oppId).Screenshsare_Count__c = 0;
                }
            }
            for(Task e : newTasks)
            {
                if(opptyMap.containsKey(e.WhatId))
                {
                    if(e.Type == screenshareTaskType)
                    {
                        opptyMap.get(e.WhatId).Screenshsare_Count__c = (isRemoved ? opptyMap.get(e.WhatId).Screenshsare_Count__c-1 : opptyMap.get(e.WhatId).Screenshsare_Count__c+1);
                        if(!oppToUpdate.containsKey(e.WhatId))
                            oppToUpdate.put(e.WhatId,opptyMap.get(e.WhatId));
                    }
                    if(oldTriggerValues != null)
                    {
                        Task oldTask = (Task)oldTriggerValues.get(e.Id);
                        if(oldTask.Type == screenshareTaskType)
                        {
                            opptyMap.get(e.WhatId).Screenshsare_Count__c = opptyMap.get(e.WhatId).Screenshsare_Count__c-1;
                            if(!oppToUpdate.containsKey(e.WhatId))
                                oppToUpdate.put(e.WhatId,opptyMap.get(e.WhatId));                
                        }
                    }
                    if(opptyMap.get(e.WhatId).Screenshsare_Count__c < 0)
                    {
                        opptyMap.get(e.WhatId).Screenshsare_Count__c = 0;
                        if(!oppToUpdate.containsKey(e.WhatId))
                            oppToUpdate.put(e.WhatId,opptyMap.get(e.WhatId));
                    }
                }
            }
            
            update oppToUpdate.values();

        }
    }//UpdateOpptyScreenShare
    
}