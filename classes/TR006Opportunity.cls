/** 
* @author       (who knows? i've refactored this) Anton Solovyev (anton_soloveyv@epam.com)
* @date         2013 July 19
* @description  Helper class for Opportunity
**/
public class TR006Opportunity 
{
    /**
    * mapping to store sub-items correspondence in offer template and opportunitie
    **/
    private Map<Id, Id> mapping = new Map<Id, Id>();
    
    /** 
    * @author       (who knows? i've refactored this) Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2013 July 19
    * @description  Sets sub-items for opportunities: Opp LineItems, Opp PackFees and Opp Promotions
    * @param        list of Opportunities
    **/
    public void AddOpportunityElement(Opportunity[] opportunities)
    {
        //PAD.myLog('START TR006Opportunity.AddOpportunityElement');
        System.Debug('## AddOpportunityElement start.');   

        for (Opportunity opp : opportunities)
        { 
            AddOpportunityElement(opp, null);            
        }
        
        System.Debug('## AddOpportunityElement end');
        //PAD.myLog('END TR006Opportunity.AddOpportunityElement');
    }
    
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2013 July 22
    * @description  Sets sub-items for single opportunity: Opp LineItems, Opp PackFees and Opp Promotions
    * @param        Opportunity
    * @param        List of needed Offer_Line_Item Ids, all items in case of null
    *
    * 10 SELECT quesies + 10 DML statements
    **/
    public void AddOpportunityElement(Opportunity opp, List<Id> offerLineItemIDs)
    {
        // 3 SELECT queries + 3 DML(delete)
        DeleteOpportunitySubItems(opp.id);
        
        // 1) create Opportunity_Line_Item__c, Opp_Item_Subservice__c, Opp_Item_Sub_VD_Line_Item__c
        // 2 SELECT queries + 2 DML(insert)
        CreateOpportunityLineItems(opp.Offer_Template__c, opp.id, offerLineItemIDs);
    
        // 2) Opp_Package_And_Fee__c, Opp_Package_And_Fee_Line_Item__c
        // 2 SELECT queries + 2 DML(insert)
        CreateOpportunityPackageFees(opp.Offer_Template__c, opp.id, offerLineItemIDs);
    }
    
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2013 July 19
    * @description  deletes all sub-items items for given Opportunity Id
    * @param        Opportunity
    * @param        List of needed Offer_Line_Item Ids, all items in case of null
    **/
    private void DeleteOpportunitySubItems(Id opptyId)
    {
        // Objects to delete 
        Opportunity_Line_Item__c [] oppLineItemsToDelete = [SELECT Id FROM Opportunity_Line_Item__c WHERE Opportunity__c =: opptyId];
        Opp_Promotion__c [] oppPromosToDelete = [SELECT Id FROM Opp_Promotion__c WHERE Opportunity__c =: opptyId];  
        Opp_Package_And_Fee__c [] oppPackageFeesToDelete = [SELECT Id FROM Opp_Package_And_Fee__c WHERE Opportunity__c =: opptyId]; 
        
        // delete object 
        System.Debug('### DeleteOpportunitySubItems: found Opportunity_Line_Item__c to delete: ' + oppLineItemsToDelete.size());
        System.Debug('### DeleteOpportunitySubItems; found Opp_Promotion__c to delete: ' + oppPromosToDelete.size());
        System.Debug('### DeleteOpportunitySubItems: found Opp_Package_And_Fee__c to delete: ' + oppPackageFeesToDelete.size());
           
        if (oppLineItemsToDelete.size() > 0)
            delete oppLineItemsToDelete;
        if (oppPromosToDelete.size() > 0)
            delete oppPromosToDelete;
        if (oppPackageFeesToDelete.size() > 0)
            delete oppPackageFeesToDelete;  
    }
    
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2013 July 19
    * @description  create Opportunity Line items (with subservices and VD Line items) for given offer template
    * @param        Offer_Template Id
    * @param        Opportunity Id
    * @param        List of needed services Ids, all items in case of null
    **/
    private void CreateOpportunityLineItems(Id offerTemplateId, Id opptyId, List<Id> offerLineItemIDs)
    {
        Opportunity_Line_Item__c[] oppLineItems = new Opportunity_Line_Item__c[]{};     
        string query = 'SELECT '+
                'o.Service__c, o.Service__r.Name, o.RecordTypeId,' +
                'o.Offer_Template__c, o.CurrencyIsoCode, o.Id,' + 
                'o.Frequency_pl__c,o.Billing_Base_pl__c,' + 
                'o.Billable_Service__c, o.Service_Attribute_Template__c ' +
            'FROM ' +
                'Offer_Line_Item__c o ' + 
            'WHERE ' +
                'Offer_Template__c = :offerTemplateId ' + 
                'AND Billable_Service__c = true ';
        if(offerLineItemIDs != null)
            query += 'AND Id in :offerLineItemIDs';
        
        System.Debug('### CreateOpportunityLineItems: query: ' + query);
        System.Debug('### CreateOpportunityLineItems: offerTemplateId: ' + offerTemplateId);
        System.Debug('### CreateOpportunityLineItems: offerLineItemIDs: ' + offerLineItemIDs);
        
        List<Offer_Line_Item__c> offerLineItems = Database.query(query);
                
        System.Debug('## CreateOpportunityLineItems: query returned: ' + offerLineItems.size());

        if (offerLineItems.size() > 0)
        {
            for (Offer_Line_Item__c offerLineItem : offerLineItems)
            {
                Opportunity_Line_Item__c OppLI      = new Opportunity_Line_Item__c();
                OppLI.Name                          = offerLineItem.Service__r.Name;
                OppLI.CurrencyIsoCode               = offerLineItem.CurrencyIsoCode;
                OppLI.Opportunity__c                = opptyId;
                OppLI.Offer_Line_Item__c            = offerLineItem.Id;
                OppLI.Service__c                    = offerLineItem.Service__c;
                OppLI.Service_Attribute_Template__c = offerLineItem.Service_Attribute_Template__c;
                oppLineItems.add(OppLI);
            }
            
            if (oppLineItems.size() > 0)
            {
                insert oppLineItems;
                for (Opportunity_Line_Item__c oppLI : oppLineItems)
                    mapping.put(oppLI.Offer_Line_Item__c, oppLI.Id);
                    
                CreateOppItemSubservices(offerLineItems);
            }
        } // if offerLineItems is not empty
    }
    
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2013 July 19
    * @description  create Opportunity Line items subservices for given offer line items
    * @param        offerLineItems - list of Offer_Line_Item__c to add to Opportunity
    *
    * Offer_Line_Item__c must exist in mapping
    **/
    private void CreateOppItemSubservices(List<Offer_Line_Item__c> offerLineItems)
    {
        Opp_Item_Subservice__c[] oppItemSubservices = new Opp_Item_Subservice__c[]{};
        List<Offer_Item_Subservice__c> offerLineItemSubservices = [
            SELECT 
                o.Volume_Discount_cb__c, o.Unit_Type__c, o.Subservice__c, 
                o.Subservice_Volume_Discount__c, o.RecordTypeId, o.Offer_Line_Item__c, o.Name, 
                o.Min_Price__c, o.Max_Price__c,  o.Id, o.Frequency__c, o.Billing_Base__c, o.CurrencyIsoCode,
                o.Applied_To__c 
            FROM 
                Offer_Item_Subservice__c o 
            WHERE 
                Offer_Line_Item__c IN :offerLineItems
            ];
            
        System.Debug('## CreateOppItemSubservices: subservices to process: ' + offerLineItemSubservices.size());
            
        if (offerLineItemSubservices.size() > 0)
        {
            for (Offer_Item_Subservice__c offerItemSubservice : offerLineItemSubservices)
            {
                if(!mapping.containsKey(offerItemSubservice.Offer_Line_Item__c))
                    throw new Generic.StandardException('CreateOpportunityLineItems() must be called before CreateOppItemSubservices()');
                
                Opp_Item_Subservice__c OppIS   = new Opp_Item_Subservice__c ();
                OppIS.Name                     = offerItemSubservice.Name;
                OppIS.CurrencyIsoCode          = offerItemSubservice.CurrencyIsoCode;
                OppIS.Subservice__c            = offerItemSubservice.Subservice__c;
                OppIS.Estimated_Quantity__c    = 0;
                OppIS.Opportunity_Line_Item__c =  mapping.get(offerItemSubservice.Offer_Line_Item__c);
                OppIS.Offer_Item_Subservice__c = offerItemSubservice.Id;
                OppIS.Subservice_Volume_Discount__c = offerItemSubservice.Subservice_Volume_Discount__c;
                OppIS.Sales_Price__c           = offerItemSubservice.Max_Price__c;
                OppIS.Volume_Discount_cb__c    = offerItemSubservice.Volume_Discount_cb__c;
                oppItemSubservices.add(OppIS);
            }
            
            if (oppItemSubservices.size() > 0)
            {
                insert oppItemSubservices;
                for (Opp_Item_Subservice__c oppIS : oppItemSubservices)
                    mapping.put(oppIS.Offer_Item_Subservice__c, oppIS.Id);
                    
                CreateOpportunityItemSubVDLineItems(offerLineItemSubservices);
            }
        } // if offerLineItemSubservices is not empty
    }
    
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2013 July 19
    * @description  create Opportunity Line items subservices VD for given offer line item subservices
    * @param        offerLineItemSubservices - list of Offer_Item_Subservice__c to add to Offer_Line_Item__c
    *
    * Offer_Item_Subservice__c must exist in mapping
    **/
    private void CreateOpportunityItemSubVDLineItems(List<Offer_Item_Subservice__c> offerLineItemSubservices)
    {
        Opp_Item_Sub_VD_Line_Item__c[] /*lstOppISVDLI*/ oppItemSubVDLineItems   = new Opp_Item_Sub_VD_Line_Item__c[]{};
        List<Offer_Item_Sub_VD_Line_Item__c> offerItemSubVDLineItems = [
            SELECT 
                o.Volume_Discount_Bracket__c, o.Offer_Item_Subservice__c, 
                o.Name,o.Min_Value__c, o.Min_Price__c, o.Max_Value__c, o.Max_Price__c, o.CurrencyIsoCode,
                o.LastModifiedDate, o.Id, o.Discount_Type__c 
            FROM Offer_Item_Sub_VD_Line_Item__c o 
            WHERE 
                Offer_Item_Subservice__c IN :offerLineItemSubservices
        ];
        
        System.Debug('## Opportunity Item Sub VD LI');
        
        if (offerItemSubVDLineItems.size() > 0)
        {
            oppItemSubVDLineItems.clear();
            for (Offer_Item_Sub_VD_Line_Item__c oisvli : offerItemSubVDLineItems)
            {
                if(!mapping.containsKey(oisvli.Offer_Item_Subservice__c))
                    throw new Generic.StandardException('CreateOppItemSubservices() must be called before CreateOpportunityItemSubVDLineItems()');
                    
                Opp_Item_Sub_VD_Line_Item__c OppISVDLI   = new Opp_Item_Sub_VD_Line_Item__c ();
                OppISVDLI.Name                           = oisvli.Name;
                OppISVDLI.CurrencyIsoCode                = oisvli.CurrencyIsoCode;
                OppISVDLI.Offer_Item_Sub_VD_Line_Item__c = oisvli.Id;
                OppISVDLI.Opp_Item_Subservice__c         = mapping.get(oisvli.Offer_Item_Subservice__c);
                OppISVDLI.Sales_Price__c                 = oisvli.Max_Price__c;
                OppISVDLI.Volume_Discount_Bracket__c     = oisvli.Volume_Discount_Bracket__c;
                oppItemSubVDLineItems.add(OppISVDLI);
            }
            
            if (oppItemSubVDLineItems.size() > 0)
                insert oppItemSubVDLineItems;
        }
    }
    
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2013 July 19
    * @description  create Opportunity Package and Fee (with subitems) from OfferTemplate
    * @param        Offer_Template Id
    * @param        Opportunity Id
    **/
    private void CreateOpportunityPackageFees(Id offerTemplateId, Id opptyId, List<Id> offerLineItemIDs)
    {
        Opp_Package_And_Fee__c[] oppPackageFees = new Opp_Package_And_Fee__c[]{};
        List<Id> serviceIds = new List<Id>();
        string query = '';
        if(offerLineItemIDs == null)
        {
        	query = 'SELECT ' +
                'Package_Fee__c, Overusage_Price__c, ' +
                'Offer_Template__c, CurrencyIsoCode, ' +
                'Name, Default_Price__c, Flag_Sorting__c ' +
            'FROM Offer_Package_And_Fee__c ' + 
            'WHERE ' +
                'Offer_Template__c = :offerTemplateId ';
        }
        else //if(offerLineItemIDs != null)
        {
            
            for(Offer_Line_Item__c oli : [SELECT Service__c FROM Offer_Line_Item__c WHERE Id IN :offerLineItemIDs])
                serviceIds.add(oli.Service__c);
            query = 'SELECT ' +
	                'Offer_Package_And_Fee__r.Package_Fee__c, Offer_Package_And_Fee__r.Overusage_Price__c, ' +
	                'Offer_Package_And_Fee__r.Offer_Template__c, Offer_Package_And_Fee__r.CurrencyIsoCode, ' +
	                'Offer_Package_And_Fee__r.Name, Offer_Package_And_Fee__r.Default_Price__c, Offer_Package_And_Fee__r.Flag_Sorting__c ' +
	            'FROM Offer_Package_And_Fee_Line_Item__c ' + 
	            'WHERE ' +
	                'Offer_Package_And_Fee__r.Offer_Template__c = :offerTemplateId ' +
                    'AND Service__c in :serviceIds';
        }
        
        System.Debug('### CreateOpportunityPackageFees: query: ' + query);
        System.Debug('### CreateOpportunityPackageFees: offerTemplateId: ' + offerTemplateId);
        System.Debug('### CreateOpportunityPackageFees: offerLineItemIDs: ' + offerLineItemIDs);
        
        List<Offer_Package_And_Fee_Line_Item__c> offerPackageFeeLineItems = new List<Offer_Package_And_Fee_Line_Item__c>();
        List<Offer_Package_And_Fee__c> offerPackageFees = new List<Offer_Package_And_Fee__c>();
		// we need separate handling, since these are different objects
        if(offerLineItemIDs == null)
        {
        	offerPackageFees = Database.query(query);
        	System.Debug('## CreateOpportunityPackageFees: query returned: ' + offerPackageFees.size());
        }
        else
        {
        	offerPackageFeeLineItems = Database.query(query);
        	System.Debug('## CreateOpportunityPackageFees: query returned: ' + offerPackageFeeLineItems.size());
        	for(Offer_Package_And_Fee_Line_Item__c pfli : offerPackageFeeLineItems)
	        {
	            Offer_Package_And_Fee__c opf = pfli.Offer_Package_And_Fee__r;
	            offerPackageFees.add(opf);
	        }
        }
        //System.Debug('## Opportunity PF');
        
        if (offerPackageFeeLineItems.size() > 0 || offerPackageFees.size() > 0)
        {
            //oppPackageFees.clear();
            for (Offer_Package_And_Fee__c OffPF : offerPackageFees)
            {
                /*Opp_Package_And_Fee__c OppPF = this.CreateSingleOppPackFee(
                    opptyId, OffPF.Id, OffPF.Name, OffPF.CurrencyIsoCode, 
                    OffPF.Default_Price__c, OffPF.Overusage_Price__c, false);*/
                Opp_Package_And_Fee__c OppPF   = new Opp_Package_And_Fee__c();
                OppPF.Opportunity__c           = opptyId;
                OppPF.Offer_Package_And_Fee__c = OffPF.Id;
                OppPF.Name                     = OffPF.Name;
                OppPF.CurrencyIsoCode          = OffPF.CurrencyIsoCode;
                OppPF.Sales_Price__c           = OffPF.Default_Price__c;
                OppPF.Overusage_Price__c       = OffPF.Overusage_Price__c;
                OppPF.Flag_Sorting__c          = OffPF.Flag_Sorting__c;
                oppPackageFees.add(OppPF);
            }
            
            if (oppPackageFees.size() > 0)
            {
                insert oppPackageFees;
                for (Opp_Package_And_Fee__c oppPF : oppPackageFees)
                    mapping.put(oppPF.Offer_Package_And_Fee__c, oppPF.Id);
                
                CreateOpportunityPackageFeeLineItems(offerPackageFees);
            }
        }
    }
    
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2013 September 3
    * @description  create single Opportunity Package and Fee.
    **/
    public Opp_Package_And_Fee__c CreateSingleOppPackFee(Id opptyId, Id offerPackFeeId, 
            string oppPackFeeName, string currencyIsoCode, double defaultPrice, double overusagePrice, boolean insertNow)
    {
        Opp_Package_And_Fee__c OppPF   = new Opp_Package_And_Fee__c();
        OppPF.Opportunity__c           = opptyId;
        OppPF.Offer_Package_And_Fee__c = offerPackFeeId;
        OppPF.Name                     = oppPackFeeName;
        OppPF.CurrencyIsoCode          = currencyIsoCode;
        OppPF.Sales_Price__c           = defaultPrice;
        OppPF.Overusage_Price__c       = overusagePrice;
        
        if(insertNow)
            insert OppPF;
        return OppPF;
    }
    
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2013 July 19
    * @description  create Opportunity Package and Fee Line Items
    * @param        offerPackageFees to find subitems
    *
    * Offer_Package_And_Fee__c must exist in mapping
    **/
    public void CreateOpportunityPackageFeeLineItems(List<Offer_Package_And_Fee__c> offerPackageFees)
    {
        Opp_Package_And_Fee_Line_Item__c[] /*lstOppPFLI*/ oppPackageFeeLineItems = new Opp_Package_And_Fee_Line_Item__c[]{};
        List<Offer_Package_And_Fee_Line_Item__c> offerPackageFeeLineItems = [
            SELECT 
                o.Weight__c, o.Service__c, o.RecordTypeId, o.PackFee__c, 
                o.PackFee_Line_Item__c, o.Offer_Package_And_Fee__c, o.Name, o.Id, o.CurrencyIsoCode
            FROM Offer_Package_And_Fee_Line_Item__c o 
            WHERE Offer_Package_And_Fee__c IN :offerPackageFees
        ];
        
        System.Debug('## Opportunity PF LI');
        
        if (offerPackageFeeLineItems.size() > 0)
        {
            oppPackageFeeLineItems.clear();
            for (Offer_Package_And_Fee_Line_Item__c opfli : offerPackageFeeLineItems)
            {
                if(!mapping.containsKey(opfli.Offer_Package_And_Fee__c))
                    throw new Generic.StandardException('CreateOpportunityPackageFees() must be called before CreateOpportunityPackageFeeLineItems()');
                    
                Opp_Package_And_Fee_Line_Item__c OppPFLI   = new Opp_Package_And_Fee_Line_Item__c ();
                OppPFLI.Opp_Package_And_Fee__c             = mapping.get(opfli.Offer_Package_And_Fee__c);
                OppPFLI.Offer_Package_And_Fee_Line_Item__c = opfli.Id;
                OppPFLI.Service__c                         = opfli.Service__c;
                OppPFLI.CurrencyIsoCode                    = opfli.CurrencyIsoCode;
                oppPackageFeeLineItems.add(OppPFLI);
            }
            
            if (oppPackageFeeLineItems.size() > 0)
                insert oppPackageFeeLineItems;
        }
    }
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2013 September 9
    * @description  create single Opportunity Package and Fee Line Item.
    **/
    public Opp_Package_And_Fee_Line_Item__c CreateSingleOpportunityPackageFeeLineItem(Id oppPackFeeId, 
            Id offerPackFeeLineItemId, Id serviceId, string currencyIsoCode, boolean insertNow)
    {
        Opp_Package_And_Fee_Line_Item__c item = new Opp_Package_And_Fee_Line_Item__c();
        item.Opp_Package_And_Fee__c = oppPackFeeId;
        item.Offer_Package_And_Fee_Line_Item__c = offerPackFeeLineItemId;
        item.Service__c = serviceId;
        item.CurrencyIsoCode = currencyIsoCode;
        
        if(insertNow)
            insert item;
        return item;
    }
}