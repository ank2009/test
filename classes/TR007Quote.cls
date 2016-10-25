/**
* @author       (who knows? i've refactored this) Anton Solovyev (anton_soloveyv@epam.com)
* @date         ?
* @description  Helper class for Quote
**/
public class TR007Quote
{
    private Map<ID, ID> mapping = new Map<ID, ID>();

    private Id TASModuleRecordTypeId = TLR_RecordTypeHelper.getId('Service__c', 'TAS Module');
    private Id TASConsultingRecordTypeId = TLR_RecordTypeHelper.getId('Service__c', 'TAS Consulting');

    public void CreateQuote(List<Opportunity> lstOpportunity)
    {
        Id recordTypeId = TLR_RecordTypeHelper.getId('Quote', 'TLR Quote');
        CreateQuote(lstOpportunity, null, recordTypeId);
    }

    public void CreateQuote(List<Opportunity> lstOpportunity, date validUntil, Id recordTypeId)
    {
        mapping.clear();
        List<Id> oppIdList = new List<Id>();
        // 1. create quotes
        //List<Quote> quotes = new List<Quote>();

        for (Opportunity Opp : lstOpportunity)
        {
            if(Opp.Product_Interest__c != 'TAS')
                continue;
            
            Quote quote                       = new Quote();
            quote.OpportunityId               = Opp.Id;
            quote.Name                        = Opp.Name;
            quote.ExpirationDate              = Opp.CloseDate;
            quote.Offer_Template__c           = Opp.Offer_Template__c;
            quote.Maximum_Invoice_Amount__c   = Opp.Maximum_Invoice_Amount__c;
            quote.CUG_allowed__c              = Opp.CUG_allowed__c;
            quote.Account__c                  = Opp.AccountId;
            quote.RecordTypeId                = recordTypeId;
            quote.Valid_until__c              = validUntil;

            //quotes.add(quote);
            insert quote;
            mapping.put(Opp.Id, quote.Id);
            oppIdList.add(Opp.Id);
        }
        //insert quotes;
        CreateQuotePackFees(oppIdList);
    } // CreateQuote

       
    /*
        uses Opportunity => Quote mapping
        put Opp_Package_And_Fee__c => Quote_Package_And_Fee__c in mapping
    */
    private void CreateQuotePackFees(List<Id> oppIdList)
    {
        List<Opp_Package_And_Fee_Line_Item__c> oppPackFeeLineItems = [
            SELECT
                Opp_Package_And_Fee__r.Sales_Price__c, Opp_Package_And_Fee__r.Name, Opp_Package_And_Fee__r.Id, Opp_Package_And_Fee__r.Opportunity__c,
                Opp_Package_And_Fee__r.Overusage_Price__c, Opp_Package_And_Fee__r.CurrencyIsoCode, Opp_Package_And_Fee__r.Offer_Package_And_Fee__c,
                Opp_Package_And_Fee__r.Real_Quantity__c, Opp_Package_And_Fee__r.Discount__c, Service__r.RecordTypeId,
                Opp_Package_And_Fee__r.Offer_Package_And_Fee__r.Default_Price__c, Opp_Package_And_Fee__r.Discount_precent__c,
                Opp_Package_And_Fee__r.Discount_on_maintenance__c, Opp_Package_And_Fee__r.Maintenance_precent__c, Opp_Package_And_Fee__r.Flag_Sorting__c
            FROM Opp_Package_And_Fee_Line_Item__c
            WHERE Opp_Package_And_Fee__r.Opportunity__c IN :oppIdList
        ];

        if (oppPackFeeLineItems.size() > 0)
        {
            List<Quote_Package_And_Fee__c> quotePackFees = new List<Quote_Package_And_Fee__c>();
            for (Opp_Package_And_Fee_Line_Item__c OppPFLI : oppPackFeeLineItems)
            {
                Quote_Package_And_Fee__c quotePF = new Quote_Package_And_Fee__c ();
                quotePF.Name                     = OppPFLI.Opp_Package_And_Fee__r.Name;
                quotePF.CurrencyIsoCode          = OppPFLI.Opp_Package_And_Fee__r.CurrencyIsoCode;
                quotePF.Quote__c                 = mapping.get(OppPFLI.Opp_Package_And_Fee__r.Opportunity__c);
                quotePF.Sales_Price__c           = OppPFLI.Opp_Package_And_Fee__r.Sales_Price__c;
                quotePF.Overusage_Price__c       = OppPFLI.Opp_Package_And_Fee__r.Overusage_Price__c;
                quotePF.Opp_Package_And_Fee__c   = OppPFLI.Opp_Package_And_Fee__r.Id;
                quotePF.Offer_Package_And_Fee__c = OppPFLI.Opp_Package_And_Fee__r.Offer_Package_And_Fee__c;
                quotePF.Real_Quantity__c         = OppPFLI.Opp_Package_And_Fee__r.Real_Quantity__c;
                quotePF.Discount__c              = OppPFLI.Opp_Package_And_Fee__r.Discount__c;
                quotePF.Flag_Sorting__c          = OppPFLI.Opp_Package_And_Fee__r.Flag_Sorting__c;
                // special case for TAS products:
                if(OppPFLI.Service__r.RecordTypeId == TASModuleRecordTypeId)
                {
                    quotePF.TAS_service_kind__c = 'Module';

                    double salesPrice = quotePF.Real_Quantity__c *
                        OppPFLI.Opp_Package_And_Fee__r.Offer_Package_And_Fee__r.Default_Price__c; // list price * quantity

                    double salesPriceWithDiscount = salesPrice - quotePF.Discount__c;

                    quotePF.Sales_Price__c = salesPriceWithDiscount;

                    quotePF.Maintenance_Discount__c =
                        (salesPrice * OppPFLI.Opp_Package_And_Fee__r.Maintenance_precent__c / 100.0) // maintenance amount
                        * OppPFLI.Opp_Package_And_Fee__r.Discount_on_maintenance__c / 100.0;
                }
                if(OppPFLI.Service__r.RecordTypeId == TASConsultingRecordTypeId)
                    quotePF.TAS_service_kind__c = 'Consulting';

                quotePackFees.add(quotePF);
            }

            if (quotePackFees.size() > 0)
            {
                insert quotePackFees;
                for (Quote_Package_And_Fee__c quotePF : quotePackFees)
                    mapping.put(quotePF.Opp_Package_And_Fee__c, quotePF.Id);

                List<Opp_Package_And_Fee__c> oppPackFees = new List<Opp_Package_And_Fee__c>();
                for (Opp_Package_And_Fee_Line_Item__c OppPFLI : oppPackFeeLineItems)
                    oppPackFees.add(OppPFLI.Opp_Package_And_Fee__r);

                CreateQuotePackFeeLineItems(oppPackFees);
            }
        }
    } // CreateQuotePackFees

    private void CreateQuotePackFeeLineItems(List<Opp_Package_And_Fee__c> oppPackFees)
    {
        List<Opp_Package_And_Fee_Line_Item__c> oppPackFeeLineItems = [
            SELECT o.Service__c, o.PackFee__c, o.Opp_Package_And_Fee__c, o.CurrencyIsoCode,
                o.Offer_Package_And_Fee_Line_Item__c, o.Id
            FROM Opp_Package_And_Fee_Line_Item__c o
            WHERE Opp_Package_And_Fee__c IN :oppPackFees
        ];

        if (oppPackFeeLineItems.size() > 0)
        {
            List<Quote_Package_And_Fee_Line_Item__c> quotePackFeeLineItems = new List<Quote_Package_And_Fee_Line_Item__c>();
            for (Opp_Package_And_Fee_Line_Item__c OppPFLI : oppPackFeeLineItems)
            {
                Quote_Package_And_Fee_Line_Item__c quotePFLI = new Quote_Package_And_Fee_Line_Item__c ();
                quotePFLI.Service__c                         = OppPFLI.Service__c;
                quotePFLI.CurrencyIsoCode                    = OppPFLI.CurrencyIsoCode;
                quotePFLI.Opp_Package_And_Fee_Line_Item__c   = OppPFLI.Id;
                quotePFLI.Quote_Package_And_Fee__c           = mapping.get(OppPFLI.Opp_Package_And_Fee__c);
                quotePFLI.PackFee__c                         = OppPFLI.PackFee__c;
                quotePackFeeLineItems.add(quotePFLI);
            }

            if (quotePackFeeLineItems.size() > 0)
                insert quotePackFeeLineItems;
        }
    } // CreateQuotePackFeeLineItems
}