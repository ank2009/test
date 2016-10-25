global class UpdateAccountsBatch implements Database.Batchable<sObject>, Database.AllowsCallouts
{

    global final string query;
    global Enum Tasks
    {
        CreateContractAndSubs,
        ActivateSubscription,
        UpdateContractStatus,
        RemoveAkimContracts,
        ReSendEsb,
        ReSendSubscription,
        RecalculatePLC,
        CreateContractAndSubsForMBAccs,
        SetLastVisitedDate,
        CreateContractAndSubsForTodaysOpps
	}
    private Tasks jobTask;
    global UpdateAccountsBatch(Tasks t)
    {
        jobTask = t;
        if(jobTask == tasks.CreateContractAndSubs)
        {
            query = 'Select ID From Opportunity Where Name = \'Nolis Migration - 2015\' and Offer_Accepted_By__c = null';
        }
        else if(jobTask == tasks.ActivateSubscription)
        {
            query = 'Select ID From Subscription__c Where Status__c != \'Active\' and Name = \'Subscription - Nolis Migration - 2015\'';
        }
        else if(jobTask == tasks.RemoveAkimContracts)
        {
            query = 'Select ID, Status From Contract Where CreatedByID = \'005D0000001qZC1\' and Name = \'Contract - TFX Migration\' and Status = \'Draft\'';
        }
        else if(jobTask == tasks.UpdateContractStatus)
        {
            query = 'Select ID, Status From Contract Where CreatedByID = \'005D0000002UKdK\' and Status = \'Draft\'';
        }
        else if(jobTask == tasks.ReSendEsb)
        {
            query = 'Select Id, Body__c, Message_direction__c From ESB_Interaction_Logs__c Where ESB_response_status__c = -1';
        }
        else if(jobTask == tasks.RecalculatePLC)
        {
            query = 'Select Id From Account';
        }
        else if(jobTask == tasks.ReSendSubscription)
        {
            query = 'Select Name From Subscription__c Where CreatedById = \'005D0000002UKdK\' and Status__c=\'Provisioning initiated\'';
        }
        else if(jobTask == tasks.CreateContractAndSubsForMBAccs)
        {
            query = 'Select ID From Opportunity Where Name = \'Migrated Billing Account\' and Offer_Accepted_By__c = null';
        }
        else if(jobTask == tasks.SetLastVisitedDate)
        {
            query = 'Select ID,Last_Visited__c , (Select ActivityType,Activity_Event_Start__c,StartDateTime,LastModifiedDate,IsTask,Status From ActivityHistories Where (ActivityType = \'23 Visit Out\' or (ActivityType = \'26 Demonstration\' AND IsTask=false)) or (IsTask = true and Status = \'Complete\' AND ActivityType = \'23 Visit Out\')) From Account Where Last_Visited__c != null';
        }
        else if(jobTask == tasks.CreateContractAndSubsForTodaysOpps)
        {
            query = 'Select ID From Opportunity Where CreatedDate = Today and  CreatedById = \'00557000005tZLZ\' and Offer_Accepted_By__c = null';
        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        if(jobTask == tasks.CreateContractAndSubs || jobTask == tasks.CreateContractAndSubsForTodaysOpps)
        {
            CreateContractAndSubscription(scope);
        }
        else if(jobTask == tasks.ActivateSubscription)
        {
            ActivateSubscription(scope);
        }
        else if(jobTask == tasks.RemoveAkimContracts)
        {
            RemoveAkimContracts(scope);
        }
        else if(jobTask == tasks.UpdateContractStatus)
        {
            UpdateContractStatus(scope);
        }
        else if(jobTask == tasks.ReSendEsb)
        {
            ReSendEsb(scope);
        }
        else if(jobTask == tasks.RecalculatePLC)
        {
            RecalculatePLC(scope);
        }
        else if(jobTask == tasks.ReSendSubscription)
        {
            ReSendSubscription(scope);
        }
        else if(jobTask == tasks.CreateContractAndSubsForMBAccs)
        {
            CreateContractAndSubsForMBAccs(scope);
        }
        else if(jobTask == tasks.SetLastVisitedDate)
        {
            UpdateLastVisitedDate(scope);
        }
    }
    
    private void CreateContractAndSubscription(List<sObject> scope)
    {
        Opportunity opp;
        for(sObject obj:scope)
        {
            opp = (Opportunity)obj;
            TLR_OpportunityExt ext = new TLR_OpportunityExt(opp.Id);
            ext.InitCreateContractPage();
            
            List<Subscription__c> sub = [Select Id,Status__c,Flag_IntegrityChecks__c From subscription__c Where Opportunity__c =: opp.Id];
            if(sub.size() == 0)
            {
                ext.CreateContract();
                sub = [Select Id,Status__c,Flag_IntegrityChecks__c From subscription__c Where Opportunity__c =: opp.Id];
            }
            sub[0].Status__c = 'Waiting For Verification';
            sub[0].Flag_IntegrityChecks__c = true;
            update sub[0];
            sub[0].Status__c = 'Waiting For Provisioning';
            update sub[0];
        }
    }
    
    private void ActivateSubscription(List<sObject> scope)
    {
       System.enqueueJob(new QueueableCreateProvisioning(new Map<Id, sObject>(scope).keySet(), false));
    }
    
    private void UpdateContractStatus(List<sObject> scope)
    {
        Contract contr;
        List<Contract> contrs = new List<Contract>();
        for(sObject obj:scope)
        {
            contr = (Contract)obj;
            contr.Status = 'Activated';
            contrs.add(contr);
        }
        if(contrs.size() > 0)
            update contrs;
    }
    
    private void RemoveAkimContracts(List<sObject> scope)
    {
        List<Contract> contrs = new List<Contract>();
        for(sObject obj:scope)
        {
            contrs.add((Contract)obj);
        }
        delete contrs;
    }
    
    private void ReSendEsb(List<SObject> scope)
    {
        ESB_Interaction_Logs__c esb_log;
        for(sObject obj:scope)
        {
            esb_log = (ESB_Interaction_Logs__c)obj;
            if(esb_log.Message_direction__c == 'Outgoing')
            {
                FXSettings__c settings = FXSettings__c.getValues('FXSettings');
                HttpResponse response;
                try
                {
                    response = SoapHttp.sendSOAPRequest(esb_log.Body__c, settings.ESB_Url__c, 10000, settings.ESB_Certificate_name__c);
                    esb_log.ESB_response_status__c = response.getStatusCode();
                    esb_log.ESB_response__c = response.getBody();
                }
                catch(System.CalloutException ex)
                {
                    esb_log.ESB_response_status__c = -1;               
                    esb_log.ESB_response__c = ex.getMessage();               
                    throw new Generic.StandardException('ESB Log is NOT resend, Error:'+esb_log.ESB_response__c);
                }
                if(esb_log.ESB_response_status__c != -1)
                {                             
                    upsert esb_log;
                }
            }
            else
            {
                throw new Generic.StandardException('Sorry, You can do Re-Send only for Outgoing Messages!');
            }
        }
    }
    private void RecalculatePLC(List<SObject> scope)
    {
        Account acc;
        for(sObject obj:scope)
        {
            acc = (Account)obj;
            TLR_AccountMembershipLifeCycleController c = new TLR_AccountMembershipLifeCycleController(acc.Id);
        }
    }
    private void ReSendSubscription(List<sObject> scope)
    {
       System.enqueueJob(new QueueableCreateProvisioning(new Map<Id, sObject>(scope).keySet(),true));
    }
    private void CreateContractAndSubsForMBAccs(List<sObject> scope)
    {
          Opportunity opp;
        for(sObject obj:scope)
        {
            opp = (Opportunity)obj;
            TLR_OpportunityExt ext = new TLR_OpportunityExt(opp.Id);
            ext.InitCreateContractPage();
            
            List<Subscription__c> sub = [Select Id,Status__c,Flag_IntegrityChecks__c From subscription__c Where Opportunity__c =: opp.Id];
            if(sub.size() == 0)
            {
                ext.CreateContract();
                sub = [Select Id,Status__c,Flag_IntegrityChecks__c From subscription__c Where Opportunity__c =: opp.Id];
            }
            sub[0].Status__c = 'Active';
            sub[0].Flag_IntegrityChecks__c = true;
            update sub[0];
          	delete [select id from Subs_Current_Fee__c Where Subscription__c =: sub[0].id];
        }
    }
    private void UpdateLastVisitedDate(List<sObject> scope)
    {
        Account ev;
        
        for(sObject obj:scope)
        {
            ev = (Account)obj;
            boolean wasModified = false;
			for(ActivityHistory a : ev.ActivityHistories)           
            {
                if(a.IsTask && ev.Last_Visited__c < Date.valueOf(a.LastModifiedDate))
                {
                    wasModified = true;
                    ev.Last_Visited__c = Date.valueOf(a.LastModifiedDate);
                }
                else if(ev.Last_Visited__c < Date.valueOf(a.StartDateTime))
                {
                    ev.Last_Visited__c = Date.valueOf(a.StartDateTime);
                    wasModified = true;
                }
            }
            if(wasModified)
            	update ev;
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
       
    }
}