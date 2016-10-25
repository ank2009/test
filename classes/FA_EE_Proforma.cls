public class FA_EE_Proforma {
    
    @InvocableMethod 
    public static void SetPaymentTerms(List<ID> contractId)
    {
        Contract contr = [Select Id, Payment_Terms__c, Direct_Debit__c, AccountId From Contract Where Id =: contractId[0]];
        if(contr.Payment_Terms__c == null)
        {
            Boolean contractWasChanged = false;
            Account acc = [Select Organization_Country__c From Account Where Id =: contr.AccountId];
            if(acc.Organization_Country__c == 'Germany' || acc.Organization_Country__c == 'Austria' 
               || acc.Organization_Country__c == 'Switzerland' || acc.Organization_Country__c == 'Finland' 
               || acc.Organization_Country__c == 'Norway' || acc.Organization_Country__c == 'Denmark' 
               || acc.Organization_Country__c == 'Sweden')
            {
                contr.Payment_Terms__c = 14;
                contractWasChanged = true;
            }
            if(acc.Organization_Country__c == 'Netherlands')
            {
                contr.Payment_Terms__c = contr.Direct_Debit__c ? 28 : 14;
                contractWasChanged = true;
            }
            if(acc.Organization_Country__c == 'Belgium'|| acc.Organization_Country__c == 'Luxenbourg')
            {
                contr.Payment_Terms__c = 10;
                contractWasChanged = true;
            }
            if(acc.Organization_Country__c == 'United Kingdom' || acc.Organization_Country__c == 'Ireland')
            {
                contr.Payment_Terms__c = 30;
                contractWasChanged = true;
            }
            if(acc.Organization_Country__c == 'Poland' || acc.Organization_Country__c == 'Albania' 
                || acc.Organization_Country__c == 'Belarus' || acc.Organization_Country__c == 'Bulgaria' 
                || acc.Organization_Country__c == 'Croatia' || acc.Organization_Country__c == 'Czech Republic' 
                || acc.Organization_Country__c == 'Estonia' || acc.Organization_Country__c == 'Hungary' 
                || acc.Organization_Country__c == 'Latvia' || acc.Organization_Country__c == 'Lithuania' 
                || acc.Organization_Country__c == 'Macedonia' || acc.Organization_Country__c == 'Russia' 
                || acc.Organization_Country__c == 'Slovakia' || acc.Organization_Country__c == 'Slovenia' 
                || acc.Organization_Country__c == 'Turkey' || acc.Organization_Country__c == 'Ukraine' 
                || acc.Organization_Country__c == 'Bosnia-Herzegovina' || acc.Organization_Country__c == 'Malta' 
                || acc.Organization_Country__c == 'Moldavia' || acc.Organization_Country__c == 'Romania' 
                || acc.Organization_Country__c == 'Serbia–Montenegro')
            {
                contr.Payment_Terms__c = contr.Direct_Debit__c ? null : 21;
                contractWasChanged = !contr.Direct_Debit__c;
            }
            if(contractWasChanged)
                update contr;
        }
    }

}