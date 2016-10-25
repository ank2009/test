/** 
* @author       Andrey Gordienko (andrey_gordienko@epam.com)
* @date         2013 November 14
* @description  Trigger handler for Case events
**/
public with sharing class TRIG_CaseTriggerHandler extends TRIG_TriggerHandlerAbstract
{
    public boolean IsTriggerContext
    {
        get
        {
            return isTriggerExecuting;
        }
    }
    public TRIG_CaseTriggerHandler (boolean isTriggerExecuting)
    {
        super(isTriggerExecuting);
    }
    
    public override void OnBeforeInsert(List<sObject> newTriggerValues)
    {
        this.linkCaseToDefaulterAccount(newTriggerValues);
        this.fillAndUpdateCasePriority(newTriggerValues);
        this.linkCaseToEntitlement(newTriggerValues);
        this.fillPrefereeCompanys(newTriggerValues);
    }
    public override void OnAfterInsert(List<sObject> newTriggerValues, Map<ID, sObject> newTriggerValuesMap)
    {
        this.calculationOfDebtFields(newTriggerValues);
        this.maxAndMinSanctionDate(newTriggerValues);
        this.createChatterMessage(newTriggerValues);
    }
    
    public override void OnBeforeUpdate (List<sObject> oldTriggerValues, List<sObject> newTriggerValues, Map<ID, sObject> oldTriggerValuesMap, Map<ID, sObject> newTriggerValuesMap)
    {
        this.linkCaseToDefaulterAccount(newTriggerValues);
        this.fillAndUpdateCasePriority(newTriggerValues);
        this.createSanctionActivities(newTriggerValues);
    }
    public override void OnAfterUpdate  (List<sObject> oldTriggerValues, List<sObject> newTriggerValues, Map<ID, sObject> oldTriggerValuesMap, Map<ID, sObject> newTriggerValuesMap)
    {
        this.calculationOfDebtFields(newTriggerValues);
        this.maxAndMinSanctionDate(newTriggerValues);
        this.caseSubmitForApproval(oldTriggerValues, newTriggerValues, oldTriggerValuesMap, newTriggerValuesMap);
        SendUpdatesToJira(newTriggerValues, oldTriggerValuesMap);
    }
    
    public override void OnBeforeDelete (List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap)
    {
    
    }
    public override void OnAfterDelete(List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap)
    {
        this.calculationOfDebtFields(oldTriggerValues);
        this.maxAndMinSanctionDate(oldTriggerValues);
    }

    public override void OnAfterUndelete(List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap)
    {
    
    }
    
    /**
    * @author       Andrey Gordienko (andrey_gordienko@epam.com)
    * @date         2013 November 14
    * @description  set Defaulter_Account_Name__c using Defaulter_Contact_Name__c
    **/
    private void linkCaseToDefaulterAccount(List<Case> newTriggerValues)
    {
        List<Id> ContactIds = new List<Id>();
        for(Case newCase :newTriggerValues)
        {
            ContactIds.add(newCase.Defaulter_Contact_Name__c);
        }
        Map<Id, Contact> ContactMap = new Map<Id, Contact>([SELECT Id, AccountId FROM Contact WHERE Id IN :ContactIds]);
        for(Case myCase : newTriggerValues)
        {
            if(myCase.Defaulter_Contact_Name__c <> null)
            {
                myCase.Defaulter_Account_Name__c = ContactMap.get(myCase.Defaulter_Contact_Name__c).AccountId;
            }
        }
    } //linkCaseToDefaulterAccount
    
    /** 
    * @author       Andrey Gordienko (andrey_gordienko@epam.com)
    * @date         2013 November 14
    * @description  updates Priority dependent on Case_Type__c
    **/
    private void fillAndUpdateCasePriority(List<Case> newTriggerValues)
    {
        if(!newTriggerValues.isEmpty())
        {
            Set<String> listComplaintReasonForMedium = new Set<String>{'Legal Issues', 'Payment', 'Offer Content', 'Offer Handling',
                                                                        'Professionnal Conduct', 'Company not reachable', 'Delivery & Quality',
                                                                        'Cash Collection', 'Safe Market Place', 'DMS Full Service' };
            for(Case newCase : newTriggerValues)
            {
                if((newCase.Case_Type__c =='Complaint' || newCase.Case_Type__c =='Debt Mediation') && listComplaintReasonForMedium.contains(newCase.Complaint_Reason__c))
                {
                    newCase.Priority = 'Medium';
                }
                if(newCase.Case_Type__c =='Complaint' && newCase.Complaint_Reason__c == 'Rumours')
                {
                    newCase.Priority = 'Low';
                }
                if(newCase.Case_Type__c =='Complaint' && newCase.Complaint_Reason__c == 'Fraud & Criminality')
                {
                    newCase.Priority = 'High';
                }
            }
        }
    } //fillAndUpdateCasePriority
    
    /** 
    * @author       Andrey Gordienko (andrey_gordienko@epam.com)
    * @date         2013 November 14
    * @description  updating EntitlementId dependent on Case_Type__c
    **/
    //@author aleh_tsilko@epam.com
    //@date Aug 2016
    //@description WKTSCRM-2656, mass bulk Entitlements for Cases
    
    private void linkCaseToEntitlement(List<Case> newTriggerValues)
    {
        if(!newTriggerValues.isEmpty())
        {           
            Id ENTIT_SUPPORT_ID = null;
            Id ENTIT_COMPLAINT_ID = null;
            Id ENTIT_MEDIATION_ID = null;
            List<String> entitNames = New List<String> {'TLR Support SLO','TLR Complaint SLO','TLR DMS SLO'};
            List<Entitlement> allCaseEnts = [Select Id, Name From Entitlement Where Name IN : entitNames];
            for(Entitlement currEntit:allCaseEnts)
            {
                if(currEntit.Name == entitNames.get(0)) ENTIT_SUPPORT_ID = currEntit.Id;
                if(currEntit.Name == entitNames.get(1)) ENTIT_COMPLAINT_ID = currEntit.Id;
                if(currEntit.Name == entitNames.get(2)) ENTIT_MEDIATION_ID = currEntit.Id;
            }   
            for(Case myCase : newTriggerValues)
            {
                if(myCase.EntitlementId == null && myCase.Case_Type__c =='Customer Support' && String.isNotBlank(ENTIT_SUPPORT_ID))
                {
                    myCase.EntitlementId = ENTIT_SUPPORT_ID;  
                }
                if(myCase.EntitlementId == null && myCase.Case_Type__c == 'Complaint' && String.isNotBlank(ENTIT_COMPLAINT_ID))
                {
                    myCase.EntitlementId = ENTIT_COMPLAINT_ID;
                    myCase.Handling_Side__c = 'Complainer';
                }
                if(myCase.EntitlementId == null && myCase.Case_Type__c == 'Debt Mediation' && String.isNotBlank(ENTIT_MEDIATION_ID))
                {
                    myCase.EntitlementId = ENTIT_MEDIATION_ID;
                    myCase.Handling_Side__c = 'Complainer';
                }
            }
        }
    } //linkCaseToEntitlement
    
    /** 
    * @author       Andrey Gordienko (andrey_gordienko@epam.com)
    * @date         2013 November 14
    * @description  updates Number_CH_Open__c, CH_LM12__c, Number_DM_Open__c, DM_L12M__c 
                    fields of Account object via call to future method
    **/
    private void calculationOfDebtFields(List<Case> triggerValues)
    {
        if(UpdateTriggers.updateTriggerToBeCalled())
        {
            Set<ID> accIds = new Set<ID>();
            for (Case newCase :triggerValues)
            {
                accIds.add(newCase.Defaulter_Account_Name__c);
            }
            if(!accIds.isEmpty())
            {
                calculationOfDebtFields_CommonMethod(accIds);
            }
        }
    } //calculationOfDebtFields
    
    /** 
    * @author       Andrey Gordienko (andrey_gordienko@epam.com)
    * @date         2013 November 14
    * @description  updates Number_CH_Open__c, CH_LM12__c, Number_DM_Open__c, DM_L12M__c fields of Account object
    **/
    //@author aleh_tsilko@epam.com
    //@date Aug 2016
    //@description WKTSCRM-2656, mass bulk update for Accounts    
        
    @future
    private static void calculationOfDebtFields_CommonMethod(Set<ID> acctIds)
    {
        Map<Id, Case> allCases = new Map<Id, Case>([ SELECT Id, 
                                                            Defaulter_Account_Name__c, 
                                                            RecordTypeId, 
                                                            Status, 
                                                            NumberDays__c
                                                       FROM Case
                                                      WHERE Defaulter_Account_Name__c in :acctIds
                                                        AND Is_Counted_Star_Index__c=true
                                                        AND (   (RecordType.Name='TLR Complaint Case' AND ( Status <> 'Closed' OR NumberDays__c <=360 ))
                                                             OR (RecordType.Name='TLR DMS Case' AND ( Status <> 'Closed' OR NumberDays__c <=360 ))
                                                            )
                                                        ]);
        
        Map<ID, Account> allAcctsToUpdate = new Map<ID, Account>([SELECT Id, 
                                                                         Number_CH_Open__c,
                                                                         CH_LM12__c, 
                                                                         Number_DM_Open__c, 
                                                                         DM_L12M__c 
                                                                    FROM Account 
                                                                   WHERE Id IN :acctIds]);        

        Map<ID, Case> casesForAccountsCH = new Map<ID, Case>();
        Map<ID, Case> casesForAccountsCHL12M = new Map<ID, Case>();
        Map<ID, Case> casesForAccountsDM = new Map<ID, Case>();        
        Map<ID, Case> casesForAccountsDML12M = new Map<ID, Case>();        
                
        for(Case currCase:allCases.values())
        {
            if(currCase.RecordTypeId == TLR_RecordTypeHelper.getId('Case','TLR Complaint Case') && currCase.Status <>'Closed')
            {
                casesForAccountsCH.put(currCase.Id, currCase);
            }
            if(currCase.RecordTypeId == TLR_RecordTypeHelper.getId('Case','TLR Complaint Case') && currCase.NumberDays__c <= 360)
            {
                casesForAccountsCHL12M.put(currCase.Id, currCase);
            }
            if(currCase.RecordTypeId == TLR_RecordTypeHelper.getId('Case','TLR DMS Case') && currCase.Status <>'Closed')
            {
                casesForAccountsDM.put(currCase.Id, currCase);
            }
            if(currCase.RecordTypeId == TLR_RecordTypeHelper.getId('Case','TLR DMS Case') && currCase.Status <>'Closed')
            {
                casesForAccountsDML12M.put(currCase.Id, currCase);
            }                       
        }
        
        for(Account currAcc : allAcctsToUpdate.values()) 
        {
            Set<ID> caseIdsDML12M = new Set<ID>();
            for(Case cseDML12M : casesForAccountsDML12M.values()) 
            {
                if(cseDML12M.Defaulter_Account_Name__c == currAcc.Id)
                {
                    caseIdsDML12M.add(cseDML12M.Id);
                }
            }
            if(currAcc.DM_L12M__c != caseIdsDML12M.size())
            {
                currAcc.DM_L12M__c = caseIdsDML12M.size();
            }
            
            Set<ID> caseIdsCH = new Set<ID>();
            for(Case cseCH : casesForAccountsCH.values())
            {
                if(cseCH.Defaulter_Account_Name__c == currAcc.Id)
                {
                    caseIdsCH.add(cseCH.Id);
                }
            }
            if(currAcc.Number_CH_Open__c != caseIdsCH.size())
            {
                currAcc.Number_CH_Open__c = caseIdsCH.size();
            }
            
            Set<ID> caseIdsCHL12M = new Set<ID>();
            for(Case cseCHL12M : casesForAccountsCHL12M.values()) 
            {
                if(cseCHL12M.Defaulter_Account_Name__c == currAcc.Id)
                {
                    caseIdsCHL12M.add(cseCHL12M.Id);
                }
            }
            if (currAcc.CH_LM12__c != caseIdsCHL12M.size())
            {
                currAcc.CH_LM12__c = caseIdsCHL12M.size();
            }
            
            Set<ID> caseIdsDM = new Set<ID>();
            for(Case cseDM : casesForAccountsDM.values()) 
            {
                if(cseDM.Defaulter_Account_Name__c == currAcc.Id)
                {
                    caseIdsDM.add(cseDM.Id);
                }
            }
            if (currAcc.Number_DM_Open__c != caseIdsDM.size())
            {
                currAcc.Number_DM_Open__c = caseIdsDM.size();
            }                        
        }
                
        if (allAcctsToUpdate.size() > 0)
        {
            UpdateTriggers.doNotCallUpdateTrigger();
            try
            {
                update allAcctsToUpdate.values();
            }
            catch(Exception ex)
            {
                System.debug('Account Update Failed on Case=>'+ex);
            }
        }
    } //calculationOfDebtFields_CommonMethod
    
    /** 
    * @author       Andrey Gordienko (andrey_gordienko@epam.com)
    * @date         2013 November 14
    * @description  
    **/
    private void maxAndMinSanctionDate(List<Case> triggerValues)
    {
        Set<ID> accIds = new Set<ID>();
        for(Case newCase :triggerValues)
        {
            accIds.add(newCase.Defaulter_Account_Name__c);
        }
        if(!accIds.isEmpty())
        {
            ID DMSrecordTypeId = TLR_RecordTypeHelper.getId('Case', 'TLR DMS Case');
            ID CHrecordTypeId = TLR_RecordTypeHelper.getId('Case', 'TLR Complaint Case');
            Map<ID, Account> acctsToUpdate = new Map<ID, Account>([SELECT Id, Last_IC_Closure_Date__c FROM Account WHERE Id IN :accIds]);
            
            if(acctsToUpdate.size()>0)
            {
                for(Id AccId: acctsToUpdate.keySet())
                {
                    AggregateResult maxi = [SELECT MAX(ClosedDate) endDate FROM Case WHERE Defaulter_Account_Name__c = :AccId];
                    Datetime MaxCloseDate = (Datetime)maxi.get('endDate');
                    if(MaxCloseDate != null)
                    {
                        acctsToUpdate.get(AccId).Last_IC_Closure_Date__c = Date.NewInstance(MaxCloseDate.year(), MaxCloseDate.month(), MaxCloseDate.day());
                    }
                    else
                    {
                        acctsToUpdate.get(AccId).Last_IC_Closure_Date__c=null;
                    }
                }
                try
                {
                    update acctsToUpdate.values();
                }
                catch(Exception ex)
                {
                    System.debug('Account Update Failed on Case=>'+acctsToUpdate.values());
                }
            }
        }
    } //maxAndMinSanctionDate
    
    /** 
    * @author       Andrey Gordienko (andrey_gordienko@epam.com)
    * @date         2013 November 14
    * @description  
    **/
    private void caseSubmitForApproval(List<Case> oldTriggerValues, List<Case> newTriggerValues, Map<ID, sObject> oldTriggerValuesMap, Map<ID, sObject> newTriggerValuesMap)
    {
        if(!newTriggerValues.isEmpty() && !oldTriggerValues.isEmpty())
        {
            for(Case newCase : newTriggerValues)
            {
                Case oldCase = (Case)oldTriggerValuesMap.get(newCase.Id);
                if(newCase.Status == 'Pending Approval' && oldCase.Status =='Need Approval')
                {
                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                    req.setComments('Submitted for approval. Please approve.');
                    req.setObjectId(newCase.Id);
                    Approval.ProcessResult result = Approval.process(req);
                }
            }
        }
    } //caseSubmitForApproval
    
    /** 
    * @author       Andrey Gordienko (andrey_gordienko@epam.com)
    * @date         2013 November 14
    * @description  inserts Tasks for cases with changed sanctions
    **/
    private void createSanctionActivities(List<Case> newTriggerValues)
    {
        List<Task> listTasks = new List<Task>();
        if(!newTriggerValues.isEmpty())
        {
            for(Case newCase : newTriggerValues)
            {
                if((newCase.Status == 'Action Applied') && (newCase.Action_Start_Date__c != null) && (newCase.TlrGenerateSanctionActivities__c))
                {
                    listTasks.add(new Task(whatid = newCase.Id,
                                OwnerId = newCase.OwnerId,
                                WhoId = newCase.ContactId,
                                Description = 'Activate Sanction',
                                Priority = 'Normal',
                                Type = 'Other',
                                Status = 'Not Started',
                                ActivityDate = newCase.Action_Start_Date__c,
                                Subject = 'Activate Sanction'));
                }
                if((newCase.Status == 'Action Applied') && (newCase.Action_End_Date__c != null) && (newCase.TlrGenerateSanctionActivities__c))
                {
                    listTasks.add(new Task(whatid = newCase.Id,
                                OwnerId = newCase.OwnerId,
                                WhoId = newCase.ContactId,
                                Description = 'Deactivate Sanction',
                                Priority = 'Normal',
                                Type = 'Other',
                                Status = 'Not Started',
                                ActivityDate = newCase.Action_End_Date__c,
                                Subject = 'Deactivate Sanction'));
                }
            }
        }
        if(!listTasks.isEmpty())
        {
            try
            {
                insert listTasks;
            }
            catch(Exception e)
            {
                System.debug('Task list insert Failed==>' + e);
            }
        }
    } //createSanctionActivities
    
    /** 
    * @author       Andrey Gordienko (andrey_gordienko@epam.com)
    * @date         2013 November 14
    * @description  create chatter subscription: Author follows case created
    **/
    private void createChatterMessage(List<SObject> lstCases)
    {
        // this method causing unit tests to fail when doing callouts

        List<FeedItem> lstPosts = new List<FeedItem>();
        List<EntitySubscription> lstSubs = new List<EntitySubscription>();
        for(SObject obj : lstCases)
        {
            Case newCase = (Case)obj;
            FeedItem swarmNotification = new FeedItem();
            swarmNotification.Type = 'LinkPost';
            swarmNotification.ParentId = newCase.OwnerId;
            swarmNotification.Title = 'Link to Case Record Swarmed';
            swarmNotification.Body = String.format('You have automatically followed a Case number {0} ({1})',
                                                    new String[] {newCase.CaseNumber, newCase.Subject});
            swarmNotification.LinkUrl = Utilities.Redirect(newCase.Id).getUrl(); // url to case in currect SF ORG
            EntitySubscription subs = new EntitySubscription();
            subs.SubscriberId = newCase.OwnerId;
            subs.ParentId = newCase.Id;
            lstSubs.add(subs);
            lstPosts.add(swarmNotification);
        }
        try
        {
            if(Test.isRunningTest())
            return;
                
            insert lstPosts;
            insert lstSubs;
        }
        catch(Exception e)
        {
            system.debug('Case Swarm subscriptions were not all inserted successfully.  Error: ' + e);
        }
    } //createChatterMessage
    
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2015 September 22
    * @description  Performs special servlet call to synchronize SF Cases with Jira issues
    **/
    private void SendUpdatesToJira(List<sObject> newValues, Map<ID, sObject> oldValuesMap)
    {
        
        for(sObject so : newValues)
        {
            Case c = (Case)so;
            if(NeedToSyncWithJira(c, (Case)oldValuesMap.get(c.Id)))
                JIRA_Proxy.NotifyCaseUpdated(c.Id);
        }
    } //SendUpdatesToJira
    
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2015 September 22
    * @description  returns 'true' if we need to synchronize this case with Jira.
    **/
    private boolean NeedToSyncWithJira(Case oldCase, Case newCase)
    {
        List<string> fieldsToSync = new List<string> { 'AccountNumber__c', 'Transferred_L2_Date__c', 
            'ContactUsername__c', 'Priority_L2__c', 'Subject', 'Description' };
        boolean isChanged = false;
        
        for(string field : fieldsToSync)
            isChanged |= (oldCase.get(field) != newCase.get(field));
        
        return isChanged;
    } //JiraFieldsChanged
    
    //@author aleh_tsilko@epam.com
    //@date jule 2016
    //@description WKTSCRM-2555, fill Preferee company field for Record Type: TWD Case from Description
    private void fillPrefereeCompanys(List<Case> newTriggerValues)
    {
        //collect Account Numbers
        Map<String,String> subj2AccNumMap = New Map<String,String>();
        Set<String> prefAccNumbers = New Set<String>();
        Id TwdCase = TLR_RecordTypeHelper.getId('Case', 'TWD Case');
        for(Case newCase : newTriggerValues)
        {
            String currAccNum = getAccNumFromDescription(newCase.Description);         
            if(TwdCase == newCase.RecordTypeId && currAccNum != null)
            {         
                subj2AccNumMap.put(newCase.Subject,currAccNum);
                prefAccNumbers.add(currAccNum);                
            }            
        }          
        if(prefAccNumbers.Size() > 0)
        {
            //get Accounts Map
            Map<ID, Account> accNum2AccMap = new Map<ID, Account>([SELECT Id, AccountNumber FROM Account WHERE AccountNumber IN :prefAccNumbers]);
            Map<String,Id> accNum2IdMap = New Map<String,Id>();
            for(Id currAccId:accNum2AccMap.keySet())
            {
                accNum2IdMap.put(accNum2AccMap.get(currAccId).AccountNumber,currAccId);
            }
            if(accNum2IdMap.Size() > 0)
            {
                //update new cases
                for(Case newCase : newTriggerValues)
                {             
                    if(subj2AccNumMap.containsKey(newCase.Subject)
                    && accNum2IdMap.containsKey(subj2AccNumMap.get(newCase.Subject)))
                    {                                    
                        newCase.TWD_Prefere_company__c = accNum2IdMap.get(subj2AccNumMap.get(newCase.Subject));
                    }    
                }
            }
        }            
    }//end fillPrefereeCompanys
    
    private String getAccNumFromDescription(String inDescr)
    {
        String keyPhrase = 'Preferee company:';
        String result = null;
        if(!String.isBlank(inDescr))
        {
            List<String> separatedDescription = New List<String>(inDescr.split('\n'));
            if(!separatedDescription.isEmpty())
            {
                Integer i = 0;
                Do
                {
                    String currLine = separatedDescription.get(i); 
                    i++;   
                    if(currLine.contains(keyPhrase)
                    && currLine.contains('(')
                    && currLine.contains(')'))
                    {
                        result = currLine.subString(currLine.indexOf('(')+1, currLine.indexOf(')')).deleteWhitespace();               
                    }            
                }       
                While (result == null && (separatedDescription.Size()-1) > i);    
            }     
        }    
        return result;
    }
}