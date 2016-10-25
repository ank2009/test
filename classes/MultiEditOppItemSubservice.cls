public class MultiEditOppItemSubservice {
    
    public Boolean error { get; set; }
    public String title { get; set; }
    public Decimal minOfMax;
    public Decimal maxOfMin;
    List<Opp_Item_Subservice__c> queriedRecords;
    public Boolean editPrice { get; set; }
    public Double priceToApply { get; set; }
    public Integer quantityToApply { get; set; }
    
    public MultiEditOppItemSubservice(ApexPages.StandardSetController controller)
    {
        if (controller.getSelected().size() == 0)
        {
            error = true;
            title = 'Error';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Please select at least one item before clicking the button'));
        }
        else
        {
            error = false;
            title = 'Multi-Edit';
                
            List<Opp_Item_Subservice__c> sels = controller.getSelected();
            
            Set<Id> ids = new Set<Id>();
            for(Opp_Item_Subservice__c current : sels)
                ids.add(current.Id);

            queriedRecords = [SELECT Id, Name, Sales_Price__c, Min_Price__c, Max_Price__c, Estimated_Quantity__c, Opportunity_Line_Item__r.Opportunity__r.CloseDate FROM Opp_Item_Subservice__c WHERE Id IN : ids ORDER BY Name ASC];

            if (queriedRecords[0].Opportunity_Line_Item__r.Opportunity__r.CloseDate < Date.Today())
            {
                error = true;
                title = 'Error';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'You cannot edit Opportunity Item Subservices if Opportunity close date is in the past'));
            }
            
            // Calculate minOfMax / maxOfMin
            for(Opp_Item_Subservice__c currentOIS : queriedRecords)
            {
                if(minOfMax == null)
                    minOfMax = currentOIS.Max_Price__c;
                if(maxOfMin == null)
                    maxOfMin = currentOIS.Min_Price__c;
                    
                maxOfMin = Math.max(maxOfMin, currentOIS.Min_Price__c);
                minOfMax = Math.min(minOfMax, currentOIS.Max_Price__c);
            }
            
            priceToApply    = minOfMax;
            quantityToApply = 0;
            
            editPrice = (maxOfMin <= minOfMax);
            
            if(!editPrice)
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Min and Max Prices of items below do not allow you to enter a price to propagate.'));
        }
    }
    
    public String getMinOfMax()
    {
        String result = this.minOfMax.format();
        if(result.indexOf('.') == -1)
            return result + '.0000';

        Integer cpt = this.minOfMax.scale();
        while(cpt < 4)
        {
            result += '0';
            cpt++;
        }
        return result;
    }
    
    public String getMaxOfMin()
    {
        String result = this.maxOfMin.format();
        if(result.indexOf('.') == -1)
            return result + '.0000';
        
        Integer cpt = this.maxOfMin.scale();
        while(cpt < 4)
        {
            result += '0';
            cpt++;
        }
        return result;
    }
    
    public List<Opp_Item_Subservice__c> getQueriedRecords()
    {
        return queriedRecords;
    }
    
    public PageReference save()
    {
        if (quantityToApply < 0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Please enter a positive estimated quantity'));
            return null;
        }

        if (editPrice && (priceToApply < maxOfMin || priceToApply > minOfMax))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Please enter a sales price between €' + getMaxOfMin() + ' and €' + getMinOfMax()));
            return null;
        }
        
        for (Opp_Item_Subservice__c curr : queriedRecords)
        {
            if (editPrice && curr.Sales_Price__c != null)
                curr.Sales_Price__c         = priceToApply;
            if (curr.Estimated_Quantity__c != null)
                curr.Estimated_Quantity__c  = quantityToApply;
        }
        
        try 
        {
            update queriedRecords;
            
            return (Utilities.Redirect(ApexPages.currentPage().getParameters().get('retURL').substring(1)));
        } 
        catch(DmlException e) 
        {
            String msg = e.getDmlMessage(0);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, msg));
            return null;
        }
    }
}