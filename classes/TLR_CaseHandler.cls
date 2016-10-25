public without sharing class TLR_CaseHandler{
    
    @future
    public static void updateAccountFromCase(Set<Id> acctIds){
        // Number_CH_Open__c
        Map<ID, Case> casesForAccountsCH = new Map<ID, Case>([select Id , Defaulter_Account_Name__c from Case where Defaulter_Account_Name__c in :acctIds AND RecordType.Name='TLR Complaint Case' AND Status <>'Closed' AND Is_Counted_Star_Index__c=true]);
        Map<ID, Account> acctsToUpdateCH = new Map<ID, Account>([select Id , Number_CH_Open__c from Account where Id in :acctIds]);
        for (Account acctCH : acctsToUpdateCH.values())
        {
            Set<ID> caseIdsCH = new Set<ID>();
            for (Case cseCH : casesForAccountsCH.values()) {
                if (cseCH.Defaulter_Account_Name__c == acctCH.Id)
                    caseIdsCH.add(cseCH.Id);
            }
            if (acctCH.Number_CH_Open__c != caseIdsCH.size())
                acctCH.Number_CH_Open__c = caseIdsCH.size();
        }
        // CH_LM12__c
        Map<ID, Case> casesForAccountsCHL12M = new Map<ID, Case>([select Id , Defaulter_Account_Name__c from Case where Defaulter_Account_Name__c in :acctIds AND RecordType.Name='TLR Complaint Case' AND NumberDays__c <=360 AND Is_Counted_Star_Index__c =true]);
        Map<ID, Account> acctsToUpdateCHL12M = new Map<ID, Account>([select Id ,CH_LM12__c from Account where Id in :acctIds]);
                                                                    
        for (Account acctCHL12M : acctsToUpdateCHL12M.values()) {
            Set<ID> caseIdsCHL12M = new Set<ID>();
            for (Case cseCHL12M : casesForAccountsCHL12M.values()) {
                if (cseCHL12M.Defaulter_Account_Name__c == acctCHL12M.Id)
                    caseIdsCHL12M.add(cseCHL12M.Id);
            }
            if (acctCHL12M.CH_LM12__c != caseIdsCHL12M.size())
                acctCHL12M.CH_LM12__c = caseIdsCHL12M.size();
        }

        // Number_DM_Open__c
        Map<ID, Case> casesForAccountsDM = new Map<ID, Case>([select Id , Defaulter_Account_Name__c from Case where Defaulter_Account_Name__c in :acctIds AND RecordType.Name='TLR DMS Case' AND Status <>'Closed' AND Is_Counted_Star_Index__c=true]);
        Map<ID, Account> acctsToUpdateDM = new Map<ID, Account>([select Id , Number_DM_Open__c from Account where Id in :acctIds]);
                                                                    
        for (Account acctDM : acctsToUpdateDM.values())
        {
            Set<ID> caseIdsDM = new Set<ID>();
            for (Case cseDM : casesForAccountsDM.values()) {
                if (cseDM.Defaulter_Account_Name__c == acctDM.Id)
                    caseIdsDM.add(cseDM.Id);
            }
            if (acctDM.Number_DM_Open__c != caseIdsDM.size())
                acctDM.Number_DM_Open__c = caseIdsDM.size();
        }
        //DM_L12M__c
        Map<ID, Case> casesForAccountsDML12M = new Map<ID, Case>([select Id , Defaulter_Account_Name__c from Case where Defaulter_Account_Name__c in :acctIds AND RecordType.Name='TLR DMS Case' AND NumberDays__c <=360 AND Is_Counted_Star_Index__c=true]);
        Map<ID, Account> acctsToUpdateDML12M = new Map<ID, Account>([select Id ,DM_L12M__c from Account where Id in :acctIds]);
                                                                    
        for (Account acctDML12M : acctsToUpdateDML12M.values()) {
            Set<ID> caseIdsDML12M = new Set<ID>();
            for (Case cseDML12M : casesForAccountsDML12M.values()) {
                if (cseDML12M.Defaulter_Account_Name__c == acctDML12M.Id)
                    caseIdsDML12M.add(cseDML12M.Id);
            }
            if (acctDML12M.DM_L12M__c != caseIdsDML12M.size())
                acctDML12M.DM_L12M__c = caseIdsDML12M.size();
        }
        
        if ((acctsToUpdateCH.size() > 0 || acctsToUpdateCHL12M.size() > 0) || (acctsToUpdateDM.size() > 0 || acctsToUpdateDML12M.size() > 0))
        {
            UpdateTriggers.doNotCallUpdateTrigger();
            system.debug('acctsToUpdateCH.values()----------'+acctsToUpdateCH.values());
            update acctsToUpdateCH.values();
            update acctsToUpdateCHL12M.values();
            update acctsToUpdateDM.values();
            update acctsToUpdateDML12M.values();
        }
    }

}