public class MultiEditVDBExt 
{
    // Custom page information
    public Boolean error { get; set; }
    public String title { get; set; }
    List<Offer_Item_Subservice__c> queriedRecords;
    List<Volume_Discount__c> availableVolumeDiscounts;
    public Boolean displayVDB { get; set; }
    
    Map<Id, List<LineItem>> vdBracketMap;
    
    public List<LineItem> displayedVDB;
    
    public List<SelectOption> vdItems { get; set; }
    public String selectedVD { get; set; }
    
    // Values to apply
    public Double minPriceToApply { get; set; }
    public Double maxPriceToApply { get; set; }

    /**
     * Constructor
     */
    public MultiEditVDBExt(ApexPages.StandardSetController controller)
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

            queriedRecords = [SELECT Id, Name, Subservice_Volume_Discount__c,
                                     Min_Price__c, Max_Price__c,
                                     Offer_Line_Item__r.Offer_Template__r.Start_Date__c,
                                     Offer_Line_Item__r.Offer_Template__r.End_Date__c,
                                     Offer_Line_Item__r.Offer_Template__r.Status__c,
                                     Offer_Line_Item__r.Offer_Template__r.CurrencyIsoCode
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
        
        Date otStartDate = queriedRecords[0].Offer_Line_Item__r.Offer_Template__r.Start_Date__c;
        Date otEndDate   = queriedRecords[0].Offer_Line_Item__r.Offer_Template__r.End_Date__c;

        // Recover Volume Discounts
        if(otEndDate == null)
            availableVolumeDiscounts = [SELECT Id, Name, Start_Date__c, End_Date__c,
                                               Discount_Type__c, Status__c
                                        FROM Volume_Discount__c
                                        WHERE Status__c = 'Active' AND Start_Date__c <= :otStartDate AND End_Date__c = null ORDER BY Name ASC];
        else
            availableVolumeDiscounts = [SELECT Id, Name, Start_Date__c, End_Date__c,
                                               Discount_Type__c, Status__c
                                        FROM Volume_Discount__c
                                        WHERE Status__c = 'Active' AND Start_Date__c <= :otStartDate AND End_Date__c >= :otEndDate ORDER BY Name ASC];


        // Populate Volume Bracket Picklist
        vdItems = new List<SelectOption>();
        vdItems.add(new SelectOption('None', '-None-'));
        for(Volume_Discount__c currentVD : availableVolumeDiscounts)
            vdItems.add(new SelectOption(currentVD.Id, currentVD.Name));

        // Populate vdBracketMap
        vdBracketMap = new Map<Id, List<LineItem>>();
        List<Volume_Discount_Bracket__c> currentVDBList = [SELECT Name, Min_Value__c, Max_Value__c, Volume_Discount__c
                                                           FROM Volume_Discount_Bracket__c
                                                           WHERE Volume_Discount__c IN :availableVolumeDiscounts ORDER BY Min_Value__c ASC];

        for(Volume_Discount_Bracket__c currentVDB : currentVDBList)
        {
            if (!vdBracketMap.containsKey(currentVDB.Volume_Discount__c))
                vdBracketMap.put(currentVDB.Volume_Discount__c, new List<LineItem>());
                
            vdBracketMap.get(currentVDB.Volume_Discount__c).add(new LineItem(currentVDB, 0, 0));
        }
        
        selectedVD = vdItems[0].getValue();
        updateVDBSection();
    }
    
    
    public void updateVDBSection()
    {
        if (selectedVD == 'None')
        {
            displayVDB = false;
            displayedVDB = null;
        }
        else
        {
            displayVDB = true;
            displayedVDB = vdBracketMap.get(selectedVD);
        }
    }
    
    public List<Offer_Item_Subservice__c> getQueriedRecords()
    {
        return queriedRecords;
    }
    
    public List<LineItem> getDisplayedVDB()
    {
        
        return displayedVDB;
    }

    public PageReference save()
    {
        List<Offer_Item_Sub_VD_Line_Item__c> oisvdliList = new List<Offer_Item_Sub_VD_Line_Item__c>();
        List<Offer_Item_Subservice__c> oisList = new List<Offer_Item_Subservice__c>();
        
        List<Offer_Item_Sub_VD_Line_Item__c> lstOISVDLITodelete = [SELECT Id FROM Offer_Item_Sub_VD_Line_Item__c 
                                                                   WHERE Offer_Item_Subservice__c IN :queriedRecords];  

        for(Offer_Item_Subservice__c currentOIS : queriedRecords)
        {
            currentOIS.Subservice_Volume_Discount__c = (selectedVD == 'None' ? null : selectedVD);
            currentOIS.Volume_Discount_cb__c = (selectedVD != 'None');
            oisList.add(currentOIS);
            
            if (displayedVDB != null)
            {
                for(LineItem currentItem : displayedVDB)
                {
                    Offer_Item_Sub_VD_Line_Item__c oisvdli = new Offer_Item_Sub_VD_Line_Item__c();
                    oisvdli.Name = currentItem.bracket.Name;
                    oisvdli.CurrencyIsoCode = currentOIS.Offer_Line_Item__r.Offer_Template__r.CurrencyIsoCode;
                    oisvdli.Min_Price__c = currentItem.minPrice;
                    oisvdli.Max_Price__c = currentItem.maxPrice;
                    oisvdli.Offer_Item_Subservice__c = currentOIS.Id;
                    oisvdli.Volume_Discount_Bracket__c = currentItem.bracket.Id;
                    oisvdliList.add(oisvdli);
                }
            }
        }
        
        // Update offer item sub
        if(oisList.size() > 0)
        {
            FollowUpTriggerOfferItemSubBeforeUpdate.doNotCallTrigger();
            update oisList;
        }
        
        // delete old offer item sub vdli
        if (lstOISVDLITodelete.size() > 0)
        {
            try
            {
                delete lstOISVDLITodelete;
            }
            catch(DmlException e)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getDmlMessage(0)));
                return null;
            }
        }

        // insert nex offer item sub vdli
        if(oisvdliList.size() > 0)
        {
            try
            {
                insert oisvdliList;
            }
            catch(DmlException e)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,
                                     e.getDmlMessage(0)));
                 return null;
            }
        }
        
        return (Utilities.Redirect(ApexPages.currentPage().getParameters().get('retURL').substring(1)));
    }
    
    /**
     * Volume Discount Bracket wrapper
     */
    public class LineItem
    {
        public Volume_Discount_Bracket__c bracket { get; set; }
        public Double minPrice { get; set; }
        public Double maxPrice { get; set; }
        
        public LineItem(Volume_Discount_Bracket__c b, Double minP, Double maxP)
        {
            bracket = b;
            minPrice = minP;
            maxPrice = maxP;
        }
    }
}