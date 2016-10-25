public class MultiEditOTLIExt 
{
    // Custom page information
    public Boolean error { get; set; }
    public String title { get; set; }
    List<Offer_Line_Item__c> queriedRecords;
    
    // Predefined values
    public List<SelectOption> consolidationItems { get; set; }
    public List<SelectOption> appliedToItems     { get; set; }
    public List<SelectOption> frequencyItems     { get; set; }
    public List<SelectOption> unitTypeItems      { get; set; }
    public List<SelectOption> billingBaseItems   { get; set; }
    
    // Checkboxes for application
    public Boolean billableToBeApplied      { get; set; }
    public Boolean consolidationToBeApplied { get; set; }
    public Boolean minPriceToBeApplied      { get; set; }
    public Boolean maxPriceToBeApplied      { get; set; }
    public Boolean appliedToToBeApplied     { get; set; }
    public Boolean frequencyToBeApplied     { get; set; }
    public Boolean unitTypeToBeApplied      { get; set; }
    public Boolean billingBaseToBeApplied   { get; set; }
    public Boolean billingLimitToBeApplied  { get; set; }

    // Values to apply
    public Boolean billableToApply      { get; set; }
    public String  consolidationToApply { get; set; }
    public String  minPriceToApply      { get; set; }
    public String  maxPriceToApply      { get; set; }
    public String  appliedToToApply     { get; set; }
    public String  frequencyToApply     { get; set; }
    public String  unitTypeToApply      { get; set; }
    public String  billingBaseToApply   { get; set; }
    public String  billingLimitToApply  { get; set; }
    
    Set<Id> ids;
    
    /**
     * Constructor
     */
    public MultiEditOTLIExt(ApexPages.StandardSetController controller)
    {
        if (controller.getSelected().size() == 0)
        {
            error = true;
            title = 'Error';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Please select at least one item before clicking the button'));
            return;
        }
        else
        {
            error = false;
            title = 'Multi-Edit';
                
            List<Offer_Line_Item__c> sels = controller.getSelected();
            
            ids = new Set<Id>();
            for (Offer_Line_Item__c current : sels)
                ids.add(current.Id);

            queriedRecords = [SELECT Id, Name, Applied_To__c, Billable_Service__c, 
                                         Billing_Base_pl__c, Consolidation_Level__c, 
                                         Frequency_pl__c, Min_Price__c, Max_Price__c, 
                                         Offer_Template__r.Status__c, Unit_Type_pl__c
                              FROM Offer_Line_Item__c
                              WHERE Id IN : ids ORDER BY Name ASC];
        }
        
        if (queriedRecords[0].Offer_Template__r.Status__c != 'Pending')
        {
            error = true;
            title = 'Error';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Offer Template should be in status Pending to modify these Line Items'));
            return;
        }
        
        //
        // Build Picklists
        //
        Schema.DescribeFieldResult F;
        List<Schema.PicklistEntry> P;
        String currentItem;
        
        // Consolidation Level
        F = Offer_Line_Item__c.Consolidation_Level__c.getDescribe();
        P = F.getPicklistValues();
        
        this.consolidationItems = new List<SelectOption>();
        
        for (Schema.PicklistEntry currentEntry : P)
        {
            currentItem = currentEntry.getValue();
            consolidationItems.add(new SelectOption(currentItem, currentItem));
        }
        
        // Applied To
        F = Offer_Item_Subservice__c.Applied_To__c.getDescribe();
        P = F.getPicklistValues();
        
        this.appliedToItems = new List<SelectOption>();
        
        for(Schema.PicklistEntry currentEntry : P)
        {
            currentItem = currentEntry.getValue();
            appliedToItems.add(new SelectOption(currentItem, currentItem));
        }
        
        // Frequency
        F = Offer_Item_Subservice__c.Frequency__c.getDescribe();
        P = F.getPicklistValues();
        
        this.frequencyItems = new List<SelectOption>();
        
        frequencyItems.add(new SelectOption('','-None-'));
        for(Schema.PicklistEntry currentEntry : P)
        {
            currentItem = currentEntry.getValue();
            frequencyItems.add(new SelectOption(currentItem, currentItem));
        }        

        // Unit Type
        F = Offer_Item_Subservice__c.Unit_Type__c.getDescribe();
        P = F.getPicklistValues();
        
        this.unitTypeItems = new List<SelectOption>();
        
        unitTypeItems.add(new SelectOption('','-None-'));
        for(Schema.PicklistEntry currentEntry : P)
        {
            currentItem = currentEntry.getValue();
            unitTypeItems.add(new SelectOption(currentItem, currentItem));
        }
        
        // Billing Base
        F = Offer_Item_Subservice__c.Billing_Base__c.getDescribe();
        P = F.getPicklistValues();
        
        this.billingBaseItems = new List<SelectOption>();
        
        for(Schema.PicklistEntry currentEntry : P)
        {
            currentItem = currentEntry.getValue();
            billingBaseItems.add(new SelectOption(currentItem, currentItem));
        }
        
        billableToBeApplied      = false;
        consolidationToBeApplied = false;
        minPriceToBeApplied      = false;
        maxPriceToBeApplied      = false;
        appliedToToBeApplied     = false;
        frequencyToBeApplied     = false;
        unitTypeToBeApplied      = false;
        billingBaseToBeApplied   = false;
        billingLimitToBeApplied  = false;
    }
    
    public List<Offer_Line_Item__c> getQueriedRecords()
    {
        return queriedRecords;
    }

    public PageReference save()
    {
        // Check data filled
        List<String> missing = new List<String>();
        
        if (minPriceToBeApplied && (minPriceToApply == null || minPriceToApply == ''))
            missing.add('Min Price');
        if (maxPriceToBeApplied && (maxPriceToApply == null || maxPriceToApply == ''))
            missing.add('Max Price');
        
        if (missing.size() > 0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Following information is missing: ' + missing));
            return null;
        }
        
        // Check data format    
        Boolean badFormatMinPrice     = false;
        Boolean badFormatMaxPrice     = false;
        Boolean badFormatBillingLimit = false;
        Double  minPrice;
        Double  maxPrice;
        Integer billingLimit;
        
        try
        {
            minPrice = Double.valueOf(minPriceToApply);
        }
        catch (TypeException e)
        {
            badFormatMinPrice = true;
        }
        
        try
        {
            maxPrice = Double.valueOf(maxPriceToApply);
        }
        catch (TypeException e)
        {
            badFormatMaxPrice = true;
        }
        
        try
        {
            if (billingLimitToApply != null && billingLimitToApply != '')
                billingLimit = Integer.valueOf(billingLimitToApply);
        }
        catch (TypeException e)
        {
            badFormatBillingLimit = true;
        }
        
        List<String> badFormat = new List<String>();
        
        if (minPriceToBeApplied && badFormatMinPrice)
            badFormat.add('Min Price');
        if (maxPriceToBeApplied && badFormatMaxPrice)
            badFormat.add('Max Price');
        if (billingLimitToBeApplied && badFormatBillingLimit)
            badFormat.add('Billing Limit');
        
        if (badFormat.size() > 0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Invalid format: ' + badFormat));
            return null;
        }
        
        // Check Invalid data
        else if (minPriceToBeApplied && minPrice < 0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Min Price should be greater than or equal to 0'));
            return null;
        }
        else if (minPriceToBeApplied && maxPriceToBeApplied && maxPrice < minPrice)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Max Price should be greater than or equal to Min Price'));
            return null;
        }
        else if (maxPriceToBeApplied && maxPrice < 0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Max Price should be greater than or equal to 0'));
            return null;
        }
        else if (billingLimitToBeApplied && billingLimitToApply != null && billingLimit <= 0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Billing Limit must be positive'));
            return null;
        }
    
        for (Offer_Line_Item__c curr : queriedRecords)
        {
            if (billableToBeApplied)
                curr.Billable_Service__c = billableToApply;
            if (consolidationToBeApplied)
                curr.Consolidation_Level__c = consolidationToApply;
            if (billingBaseToBeApplied)
                curr.Billing_Base_pl__c = billingBaseToApply;
            if (unitTypeToBeApplied)
                curr.Unit_Type_pl__c = unitTypeToApply;
            if (frequencyToBeApplied)
                curr.Frequency_pl__c = frequencyToApply;
            if (appliedToToBeApplied)
                curr.Applied_To__c = appliedToToApply;
        }
        
        List<Offer_Item_Subservice__c> lstOIS = [SELECT Id, Billing_Base__c, Unit_Type__c, Frequency__c, 
                                                        Applied_To__c, Min_Price__c, Max_Price__c, Billing_Limit__c
                                                 FROM Offer_Item_Subservice__c
                                                 WHERE Offer_Line_Item__c IN :ids];
        
        for (Offer_Item_Subservice__c curr : lstOIS)
        {
            if (minPriceToBeApplied)
                curr.Min_Price__c = minPrice;
            if (maxPriceToBeApplied)
                curr.Max_Price__c = maxPrice;
            if (billingBaseToBeApplied)
                curr.Billing_Base__c = billingBaseToApply;
            if (unitTypeToBeApplied)
                curr.Unit_Type__c = unitTypeToApply;
            if (frequencyToBeApplied)
                curr.Frequency__c = frequencyToApply;
            if (appliedToToBeApplied)
                curr.Applied_To__c = appliedToToApply;
            if (billingLimitToBeApplied)
                curr.Billing_Limit__c = ((billingLimitToApply != null && billingLimitToApply != '') ? billingLimit : null);
        }
        
        try 
        {
            update queriedRecords;
            update lstOIS;
            
            return (Utilities.Redirect(ApexPages.currentPage().getParameters().get('retURL').substring(1)));
        }
        catch(DmlException e) 
        {
            String msg = 'Update error: ' + e.getDmlMessage(0);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, msg));
            return null;
        }
    }
}