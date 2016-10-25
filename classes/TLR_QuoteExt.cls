/**
* @author       Anton Solovyev (anton_soloveyv@epam.com)
* @date         2013 September 10
* @description  Controller extension for Quote
**/
public with sharing class TLR_QuoteExt
{
    private Quote myQuote;
    //--------------------------------------------------------------------------------------
    // Quote mirror properties
    //--------------------------------------------------------------------------------------
    public double Modules_subtotal { get { return myQuote.Modules_subtotal__c; } }
    public double Consulting_subtotal { get { return myQuote.Consulting_subtotal__c; } }
    public double NewDiscount { get { return myQuote.NewDiscount__c; } }
    public double NewSubtotal { get { return myQuote.NewSubtotal__c; } }
    public double NewTotalPrice { get { return myQuote.NewTotalPrice__c; } }
    public Account client { get { return myQuote.Account__r; }}
    public date quoteDate { get { return date.valueOf(myQuote.CreatedDate); } }
    public string quoteName { get { return myQuote.Name; } }
    public string quoteNumber { get { return myQuote.QuoteNumber; } }
    public string quoteDescription { get { return myQuote.Description; } }
    //--------------------------------------------------------------------------------------
    // Quote PDF page properties
    //--------------------------------------------------------------------------------------
    public List<Quote_Package_And_Fee__c> modules { get; set; }
    public List<Quote_Package_And_Fee__c> consulting { get; set; }
    public List<string> emptyStrings { get; set; }
    public string oppOwnerName { get; set; }
    public string oppOwnerEmail{ get; set; }
    public string contactName { get { return myQuote.Contact.Name; } }
    public double totalMaintenance { get; set; }
    public double discountPrecent { get { return (Modules_subtotal == 0 ? 0 : NewDiscount / Modules_subtotal); } } // precentage calculated on VF page side
    public double maintenanceDiscount { get; set; }
    public double maintenanceWihtoutDiscount { get { return (totalMaintenance + maintenanceDiscount); } }

    public boolean maintenanceHasDiscount { get { return maintenanceDiscount != 0; } }
    //--------------------------------------------------------------------------------------
    // constructor
    //--------------------------------------------------------------------------------------
    public TLR_QuoteExt(ApexPages.StandardController stdController)
    {
        this(stdController.getId());
    }
    public TLR_QuoteExt(Id quoteId)
    {
        myQuote = [
            SELECT
                Id, Name,QuoteNumber, NewDiscount__c, NewTotalPrice__c, Modules_subtotal__c, Consulting_subtotal__c, NewSubtotal__c,
                CreatedDate, Account__r.BillingStreet, Account__r.BillingPostalCode, Account__r.BillingCity, Account__r.VAT__c,
                Account__r.Fax, Account__r.Phone, Account__r.Name, RecordTypeId,
                Opportunity.Owner.Name, Opportunity.Owner.Email, Contact.Name, Description
            FROM Quote
            WHERE Id = :quoteId
        ];
		oppOwnerName = myQuote.Opportunity.Owner.Name;
        oppOwnerEmail = myQuote.Opportunity.Owner.Email;
        List<Quote_Package_And_Fee__c> allPackFees = [
            SELECT
                Id, Name, Real_Quantity__c, List_Price__c, Sales_Price__c, TAS_service_kind__c, Maintenance_Discount__c,
                Comment__c, Discount__c
            FROM Quote_Package_And_Fee__c
            WHERE Quote__c = :myQuote.Id
            ORDER BY Flag_Sorting__c ASC NULLS LAST
        ];system.debug('--------------------------------------------'+allPackFees);
        modules = new List<Quote_Package_And_Fee__c>();
        consulting = new List<Quote_Package_And_Fee__c>();
        emptyStrings = new List<string>();
        for(Quote_Package_And_Fee__c pf : allPackFees)
        {
            if(pf.TAS_service_kind__c == 'Module')
                modules.add(pf);
            else if(pf.TAS_service_kind__c == 'Consulting')
                consulting.add(pf);
            else if (pf.Name == 'Total Maintenance')
                totalMaintenance = pf.Sales_Price__c;
        }
		if(modules.size()+consulting.size()<4)
        {
            for(integer i=(modules.size()+consulting.size()+1);i<=4;i++)
            {
                emptyStrings.add('');
            }
        }
        // calculate total discount on maintenance
        maintenanceDiscount = 0;
        for(Quote_Package_And_Fee__c pf : modules)
            if(pf.Maintenance_Discount__c != null)
                maintenanceDiscount += pf.Maintenance_Discount__c;

        //maintenanceWihtoutDiscount = totalMaintenance + maintenanceDiscount;
    } // ctor
    //---------------------------------------------------------------------------------------------------------------
    // Quote PDF page methods
    //---------------------------------------------------------------------------------------------------------------
    public PageReference InitQuotePDF()
    {
        if(myQuote.RecordTypeId == TLR_RecordTypeHelper.getId('Quote', 'TAS Existing quote'))
            return Page.TASQuotePDFUpsell;
        return null;
    }
}