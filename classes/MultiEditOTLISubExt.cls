public class MultiEditOTLISubExt 
{
    // Custom page information
    public Boolean error { get; set; }
    public String title { get; set; }
    List<Offer_Item_Subservice__c> queriedRecords;
    
    // Predefined values
    public List<SelectOption> appliedToItems { get; set; }
    public List<SelectOption> frequencyItems { get; set; }
    public List<SelectOption> unitTypeItems { get; set; }
    public List<SelectOption> billingBaseItems { get; set; }
    
    // Checkboxes for application
    public Boolean minPriceToBeApplied { get; set; }
    public Boolean maxPriceToBeApplied { get; set; }
    public Boolean appliedToToBeApplied { get; set; }
    public Boolean frequencyToBeApplied { get; set; }
    public Boolean unitTypeToBeApplied { get; set; }
    public Boolean billingBaseToBeApplied { get; set; }
    public Boolean billingLimitToBeApplied { get; set; }

    // Values to apply
    public String minPriceToApply { get; set; }
    public String maxPriceToApply { get; set; }
    public String appliedToToApply { get; set; }
    public String frequencyToApply { get; set; }
    public String unitTypeToApply { get; set; }
    public String billingBaseToApply { get; set; }
    public String billingLimitToApply { get; set; }
    
    
    /**
     * Constructor
     */
    public MultiEditOTLISubExt(ApexPages.StandardSetController controller)
    {
        if (controller.getSelected().size() == 0)
        {
            error = true;
            title = 'Error';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,
                 'Please select at least one item before clicking the button'));
            return;
        }
        else
        {
            error = false;
            title = 'Multi-Edit';
                
            List<Offer_Item_Subservice__c> sels = controller.getSelected();
            
            Set<Id> ids = new Set<Id>();
            for(Offer_Item_Subservice__c current : sels)
                ids.add(current.Id);

            queriedRecords = [SELECT Id, Name, Billing_Base__c, Unit_Type__c,
                                     Frequency__c, Applied_To__c, Min_Price__c,
                                     Max_Price__c, Offer_Line_Item__r.Offer_Template__r.Status__c,
                                     Billing_Limit__c
                              FROM Offer_Item_Subservice__c
                              WHERE Id IN : ids ORDER BY Name ASC];
        }
        
        if(queriedRecords[0].Offer_Line_Item__r.Offer_Template__r.Status__c != 'Pending')
        {
            error = true;
            title = 'Error';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,
                 'Offer Template should be in status Pending to modify these Line Items'));
            return;
        }
        
        //
        // Build Picklists
        //
        Schema.DescribeFieldResult F;
        List<Schema.PicklistEntry> P;
        String currentItem;
        
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
        
        minPriceToBeApplied     = false;
        maxPriceToBeApplied     = false;
        appliedToToBeApplied    = false;
        frequencyToBeApplied    = false;
        unitTypeToBeApplied     = false;
        billingBaseToBeApplied  = false;
        billingLimitToBeApplied = false;
    }
    
    public List<Offer_Item_Subservice__c> getQueriedRecords()
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
    
        for (Offer_Item_Subservice__c curr : queriedRecords)
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