public with sharing class TLR_ContractHelper 
{
    public static Id CreateNewContract(Opportunity opp, Offer_Template__c offerTemplate)
    {
        Contract contract = new Contract();
        try
        {
            contract.Name            = offerTemplate.Name;
            contract.CurrencyIsoCode = opp.CurrencyIsoCode;
            contract.AccountId       = opp.AccountId;
            contract.OwnerId         = UserInfo.getUserId();
            Date dateToday           = Date.today();
            contract.StartDate       = dateToday; //(dateToday.toStartOfMonth().isSameDay(dateToday) ? dateToday : dateToday.addMonths(1).toStartOfMonth());
            if (offerTemplate.Contract_Term__c > 0)
                contract.EndDate = contract.StartDate.addMonths(offerTemplate.Contract_Term__c.intValue());
            contract.Contract_Language__c           = 'English';
            contract.Extended_Welcome_Process__c    = 'None';
            if (offerTemplate.Default_Invoice_Level__c != 'Not Specified')
                contract.Invoice_Level__c = offerTemplate.Default_Invoice_Level__c;
            contract.Consolidation_Level__c = 'Site';
            contract.Invoice_Layout_ID__c   = 'a';
            if (offerTemplate.Default_Invoice_Media__c != 'Not Specified')
                contract.Invoice_Media__c = offerTemplate.Default_Invoice_Media__c;
            if (offerTemplate.Default_Payment_Method__c != 'Not Specified')
                contract.Payment_Method__c = offerTemplate.Default_Payment_Method__c;
            contract.Terms_Conditions__c    = 'General';
            contract.Status__c              = 'Draft';
            contract.Cancellation_Reason__c = '';
            contract.Status                 = 'Draft';
            contract.Invoice_Status__c = 'Active';
            contract.Skip_Bank_information_validation__c = offerTemplate.Skip_Bank_information_validation__c;
            contract.Product__c = opp.Product_Interest__c;
            if(opp.Product_Interest__c == 'TAS')
                contract.RecordTypeId = TLR_RecordTypeHelper.getId('Contract', 'TAS Contract');
            if(opp.Product_Interest__c == 'TWD' && opp.RecordTypeId == TLR_RecordTypeHelper.getId('Opportunity','WKTS Opportunity'))
                contract.RecordTypeId = TLR_RecordTypeHelper.getId('Contract', 'TWA Contract');
            
            insert contract;
        }
        catch (Exception e)
        {
            Generic.StandardException ex = new Generic.StandardException();
            ex.SetMessage('Error: Contract creation failed! ' + e.getMessage());
            throw ex;
        }
        
        return contract.Id;
    } // CreateNewContract
    
    public static Id CreateNewContract(Id oppId)
    {
        Opportunity oppty = [
            SELECT
                Id, Name, CurrencyIsoCode, AccountId, RecordTypeId,
                Offer_Template__r.Name, Offer_Template__r.Contract_Term__c, Offer_Template__r.Default_Payment_Method__c,
                Offer_Template__r.Default_Invoice_Level__c, Offer_Template__r.Default_Invoice_Media__c,
                Offer_Template__r.Skip_Bank_information_validation__c, Product_Interest__c
            FROM Opportunity
            WHERE Id=:oppId
        ];
        
        return CreateNewContract(oppty, oppty.Offer_Template__r);
    }
}