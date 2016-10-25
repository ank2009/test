/** 
* @author       Anton Solovyev (anton_soloveyv@epam.com)
* @date         2013 September 2
* @description  Controller extension for Opportunity
**/
public with sharing class TLR_OpportunityExt 
{
    //------------------------------------------------------------------------------------------------------
    // Inner class - wrapper for TAS service
    // used to build dataTable on ChooseTASOfferTemplate VF Page
    //------------------------------------------------------------------------------------------------------
    public class tasServiceWrapper implements Comparable
    {
        public Id id { get; set; }
        public boolean checked { get; set; }
        public boolean alreadySold { get; set; }
        public string name { get; set; }
        
        public Boolean hasQuantity { get; set; }
        public integer quantity { get; set; }
        public double price { get; set; }
        
        public double discountPrecent { get; set; }
        public double discountValue { get; set; }
        public double modulePriceWithDiscount { get; set; }
        
        public double maintenancePrecent { get; set; }
        public double maintenanceValue { get; set; }
        public double maintenanceDiscountPrecent { get; set; }
        public double maintenancePriceWithDiscount { get; set; }
        
        public double totalPrice { get; set; }
        
        public string comment { get; set; }
        
        // Comparable implementation
        public integer compareTo(Object obj)
        {
            return name.compareTo(((tasServiceWrapper)obj).name);
        }
    } //tasServiceWrapper
    //------------------------------------------------------------------------------------------------------
    // Inner class END
    //------------------------------------------------------------------------------------------------------
    public Opportunity opp { get; set; }
    //------------------------------------------------------------------------------------------------------
    // Cerate contract page fields and propertes
    //------------------------------------------------------------------------------------------------------
    public Boolean error { get; set; }
    public List<SelectOption> contractList { get; set; }
    public String selectedContractOption {get; set;}
    //------------------------------------------------------------------------------------------------------
    // Choose TAS Offer template properties
    //------------------------------------------------------------------------------------------------------
    public List<tasServiceWrapper> tasServices { get; set; }
    public List<tasServiceWrapper> tasConsulting { get; set; }
    private ID WKTSOpportunityRecordTypeID = TLR_RecordTypeHelper.getId('Opportunity','WKTS Opportunity');
    private Id TASOfferTemplateRecordTypeId = TLR_RecordTypeHelper.getId('Offer_Template__c','TAS Offer template');
    private Id TASModuleRecordTypeId = TLR_RecordTypeHelper.getId('Offer_Line_Item__c','TAS Module');
    private Id TASManitenanceRecordTypeId = TLR_RecordTypeHelper.getId('Offer_Line_Item__c','TAS Maintenance');
    private Id TASConsultingRecordTypeId = TLR_RecordTypeHelper.getId('Offer_Line_Item__c','TAS Consulting');
    
    private Id offerTemplateId;
    private boolean isNewOpportunity;
    //------------------------------------------------------------------------------------------------------
    // constructors
    //------------------------------------------------------------------------------------------------------
    public TLR_OpportunityExt(ApexPages.StandardController stdController)
    {
        Id opptyId = stdController.getId();
        
        if(opptyId == null)
        {
            opp = (Opportunity)stdController.getRecord();
        }
        else
        {
            InitOppty(opptyId);
        }
    }
    public TLR_OpportunityExt(Id opptyId)
    {
        InitOppty(opptyId);
    }
    
    public void InitOppty(Id opportunityId)
    {
        this.opp = [SELECT Id, Name, AccountId, Maximum_Invoice_Amount__c, Start_Usage_Payment_Date__c, CloseDate,
                            StageName, RecordTypeId, Offer_Template__c, Offer_Template__r.Name, Offer_Template__r.Access_Kind__c,
                            Offer_Template__r.Base_Product__c, Offer_Template__r.Contract_Term__c, Offer_Template__r.Default_Invoice_Level__c,
                            Offer_Template__r.Default_Invoice_Media__c, Offer_Template__r.Default_Payment_Method__c,
                            Offer_Template__r.Skip_Bank_information_validation__c, Offer_Template__r.Waiting_For_Payment_status__c,
                            CUG_allowed__c, CurrencyIsoCode, 
                            Type, Product_Interest__c, Reason_Lost__c, Reason_Won__c, Competitors__c, Probability,
                            CampaignId, Additonal_comments__c,Offer_Accepted_By__c,
                            Expected_revenue__c,
                            Contact__c, Development_Taylor_Made__c, Expected_Revenue_Date__c, License_Fee__c, Maintenance__c,
                            Professional_Services__c, Rental_Monthly_Fee__c, isClosed, isWon
                    FROM Opportunity 
                    WHERE Id = :opportunityId];
        
    }
    //------------------------------------------------------------------------------------------------------
    // Cerate contract page methods
    //------------------------------------------------------------------------------------------------------
    public PageReference InitCreateContractPage()
    {
        TLR_SubscriptionHelper subsHelper = new TLR_SubscriptionHelper();
        error = false;
        
        Savepoint sp = Database.setSavepoint();
        try
        {
            if (this.opp.Offer_Template__c == null)
            {
                throw new Generic.StandardException('Opportunities can be accepted only after an offer template has been attached!'); 
            }           
                
            if (this.opp.RecordTypeId == WKTSOpportunityRecordTypeID && !(this.opp.isWon && this.opp.isClosed))
            {
                if(!(this.opp.Offer_Template__r.Waiting_For_Payment_status__c && this.opp.StageName =='05 Offer Sent'))
                {
                	throw new Generic.StandardException('You can only accept closed won opportunities or in case of prepaid product - opportunities with Stage = 05 Offer Sent');
                }
            }          
            else if (this.opp.CloseDate < Date.Today())
            {
                throw new Generic.StandardException('You cannot accept an Opportunity whose Close Date is in the past! Please change Close Date first and then re-attempt.');
            }
            
            Subscription__c[] lstSubscription = [SELECT Id, Opportunity__c 
                                                 FROM Subscription__c 
                                                 WHERE Opportunity__c = :this.opp.Id];
            List<Contract> lstcontract = new List<Contract>();
            
			lstcontract= [SELECT Id, AccountId, ContractNumber, Invoice_Status__c, RecordTypeId
						  FROM Contract 
						  WHERE AccountId = :this.opp.AccountId
							AND RecordTypeId = :TLR_RecordTypeHelper.getId('Contract', 'TAS Contract')];

            if (lstSubscription.size() > 0)
            {      
				if(this.opp.Offer_Template__r.Waiting_For_Payment_status__c)
                {
					return Utilities.Redirect(lstSubscription[0].Id);
                }
                if(String.isEmpty(opp.Offer_Accepted_By__c))
				{
					opp.Offer_Accepted_By__c =  Userinfo.getName() + ', ' + Datetime.now().format('MM/dd/yyyy hh:mm a');
                    update this.opp;
				}
             //   subsHelper.ModifyExistingSubscription(lstSubscription[0].Id, opp, opp.Offer_Template__r);
                return Utilities.Redirect(lstSubscription[0].Id);
            }
            else
            {
                if (lstcontract.size() == 0)
                {
                    selectedContractOption = 'new';                   
                    return CreateContract();
                }
                else
                {
                    if (contractList == null)
                    {
                        contractList = new List<SelectOption>();
                    }                    
                    contractList.add(new SelectOption('new', 'New contract'));                
                    selectedContractOption = contractList[0].getValue();
                    
                    for (Contract c : lstcontract)
                    {
                        contractList.add(new SelectOption(c.Id, 'Existing contract: ' + c.ContractNumber));
                    }
                }
            } // if we have no subscription
        } // try
        catch(Exception ex)
        {
            Database.rollback(sp);
            error = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, ex.getMessage())); 
            return null;
        }
        return null;
    } // InitCreateContractPage
    
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2013 September 2
    * @description  Actual contract creation
    **/
    public PageReference CreateContract() 
    {
        ID subsId;
        TLR_SubscriptionHelper subsHelper = new TLR_SubscriptionHelper();
        
        Savepoint sp = database.setSavepoint();
        try
        {         
            update this.opp;
            if (selectedContractOption == 'new')
            {
                ID contractId = TLR_ContractHelper.CreateNewContract(opp, opp.Offer_Template__r);
                subsId = subsHelper.CreateNewSubscription(contractId, opp, opp.Offer_Template__r);
            }
            else
            {
                subsId = subsHelper.CreateNewSubscription(selectedContractOption, opp, opp.Offer_Template__r);
            }
            
            // special handling for TAS contracts
            if(opp.Product_Interest__c == 'TAS')
            {
                // we need to add individual maintenance lines to subscription
                List<Opp_Package_And_Fee_Line_Item__c> existingOppPackFeeLI = [SELECT Id, Service__c, Opp_Package_And_Fee__r.Id, Opp_Package_And_Fee__r.Comment__c,
                                                                                    Opp_Package_And_Fee__r.Real_quantity__c, Opp_Package_And_Fee__r.Sales_Price__c,
                                                                                    Opp_Package_And_Fee__r.Overusage_Price__c, PackFee__c, Opp_Package_And_Fee__r.Name,
                                                                                    Opp_Package_And_Fee__r.Maintenance_precent__c, Opp_Package_And_Fee__r.Discount__c
                                                                                FROM Opp_Package_And_Fee_Line_Item__c
                                                                                WHERE Opp_Package_And_Fee__r.Opportunity__c = : opp.Id
                                                                                    AND Service__r.RecordTypeId = :TLR_RecordTypeHelper.getId('Service__c', 'TAS Module')];

                List<Offer_Package_And_Fee__c> maintOffPFList = [SELECT Id, Name, Package_Fee__c 
                                                                FROM Offer_Package_And_Fee__c 
                                                                WHERE 
                                                                    Offer_Template__c = :opp.Offer_Template__c
                                                                    AND name='Total Maintenance'
                                                                LIMIT 1];

                Id maintPackFeeId = maintOffPFList.size() > 0 ? maintOffPFList.get(0).Package_Fee__c : null;

                List<Subs_Package_And_Fee__c> subsPFList = new List<Subs_Package_And_Fee__c>();
                for(Opp_Package_And_Fee_Line_Item__c oppPFLI : existingOppPackFeeLI)
                {
                    Opp_Package_And_Fee__c oppPF = oppPFLI.Opp_Package_And_Fee__r;
                    string subsPFName = TLR_SubscriptionHelper.maintenancePrefix + oppPF.Name;
                    decimal salesPrice = (oppPF.Sales_Price__c + oppPF.Discount__c) * oppPF.Maintenance_precent__c / 100.0;
                    Subs_Package_And_Fee__c subsPF = TLR_SubscriptionHelper.CreateSingleSubscriptionPackFee(subsPFName, OppPF.CurrencyIsoCode, 
                        subsId, oppPF.Id, maintPackFeeId, salesPrice, oppPF.Overusage_Price__c, oppPF.Comment__c, false);
                    subsPFList.add(subsPF);
                }
                if(subsPFList.size() > 0)
                {
                    insert subsPFList;
                }
            }
        }
        catch (Exception e)
        {
            database.rollback(sp);
            error = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Test:' + e.getMessage())); 
            return null;
        }
        opp.Offer_Accepted_By__c =  Userinfo.getName() + ', ' + Datetime.now().format('MM/dd/yyyy hh:mm a');
        update this.opp;
        return (Utilities.Redirect(subsId));
    } // CreateContract
    
    //------------------------------------------------------------------------------------------------------
    // Choose TAS Offer template methods
    //------------------------------------------------------------------------------------------------------
    public PageReference InitChooseTasOfferTemplate()
    {
        try
        {
            if(this.opp.RecordTypeId != WKTSOpportunityRecordTypeID && this.opp.StageName =='Closed Won')
                throw new Generic.StandardException('You cannot attach an offer template to an opportunity that is already closed won.');
            if(this.opp.CloseDate < Date.Today())
                throw new Generic.StandardException('You cannot attach an offer template to an opportunity whose close date is in the past.');
            
            List<Offer_Template__c> offerTemplates = retrieveAllOfferTemplates();
            
            if(offerTemplates.size() < 1)
                throw new Generic.StandardException('There is no active TAS Offer templates!');
            if(offerTemplates.size() > 1)
                throw new Generic.StandardException('Too many active TAS Offer templates!');
            
            offerTemplateId = offerTemplates[0].Id;
            wrapOfferTemplateModules();
        }
        catch(Exception ex)
        {
            error = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
        }
        return null;
    } //InitChooseTasOfferTemplate
    
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2013 September 2
    * @description  returns list of valid TAS offer templates
    **/
    private List<Offer_Template__c> retrieveAllOfferTemplates()
    {
        return [SELECT Id, Name,Status__c, Start_Date__c,End_Date__c, Eligibility_Criteria_Int__c 
            	FROM Offer_Template__c 
            	WHERE 
                    Status__c = 'Active'
                    AND Start_Date__c <= :Date.today()
                    AND (End_Date__c = null OR End_Date__c>= :Date.today()) 
                    AND RecordTypeId = :TASOfferTemplateRecordTypeId];
    } // retrieveAllOfferTemplates
    
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2013 September 2
    * @description  get list of wrapper classes from TAS Modules
    **/
    private void wrapOfferTemplateModules()
    {
        tasServices = new List<tasServiceWrapper>();
        tasConsulting = new List<tasServiceWrapper>();
        
        List<Offer_Line_Item__c> allTASServicesInOT = [SELECT Id, Name, Service_mandatory__c, RecordTypeId, 
                                                            Offer_Template__c, Service__c, Dependent_Services__c,
                                                            Min_Price__c,Max_Price__c, Module_has_Value__c,
                                                            Consulting_Type__c, Enabled_Maintenance__c,
                                                            value1title__c, value2title__c, value3title__c
                                                        FROM Offer_Line_Item__c 
                                                        WHERE Offer_Template__c = :offerTemplateId 
                                                       			AND Billable_Service__c = true
                                                                AND (RecordTypeId = :TASModuleRecordTypeId OR RecordTypeId = :TASConsultingRecordTypeId)];
        
        List<Offer_Package_And_Fee_Line_Item__c> offerPackFeeLineItems = [SELECT Service__c, Offer_Package_And_Fee__r.Min_Price__c,
                                                                          		Offer_Package_And_Fee__r.Name,
                																Offer_Package_And_Fee__r.hasValue__c, 
                                                                          		Offer_Package_And_Fee__r.Maintenance_precent__c
                                                                            FROM Offer_Package_And_Fee_Line_Item__c
                                                                            WHERE Offer_Package_And_Fee__r.Offer_Template__c = :offerTemplateId];
        Map<Id, Offer_Package_And_Fee__c> offerPackFeeMap = new Map<Id, Offer_Package_And_Fee__c>();
        for(Offer_Package_And_Fee_Line_Item__c opfLI : offerPackFeeLineItems)
        {
            offerPackFeeMap.put(opfLI.Service__c, opfLI.Offer_Package_And_Fee__r);
        }
        
        // i want to use services IDs in query
        List<Id> serviceIds = new List<Id>();
        for(Offer_Line_Item__c oli : allTASServicesInOT)
        {
            serviceIds.add(oli.Service__c);
        }
        
        List<Subscription_Line_Item__c> existingSubsLineItems = [SELECT Id,Name,Service__r.Id, Service__r.Name
                                                                FROM Subscription_Line_Item__c
                                                                WHERE Service__c IN :serviceIds 
                                                                 		AND Subscription__r.Account__c = :opp.AccountId];
        
        // list of already sold services
        List<Id> soldServicesId = new List<Id>();
        for(Subscription_Line_Item__c sli : existingSubsLineItems)
        {
            soldServicesId.add(sli.Service__r.Id);
        }
        
        isNewOpportunity = existingSubsLineItems.size() == 0;
        
        
        // get existing in oppty services
        List<Opportunity_Line_Item__c> existingOppLineItems = [SELECT Id, Service__c, Consulting_price__c, Consulting_quantity__c, Module_quantity__c
                                                                FROM Opportunity_Line_Item__c
                                                                WHERE Opportunity__c = : opp.Id];
        // create map of them for simple use
        Map<Id, Opportunity_Line_Item__c> existingServices = new Map<Id, Opportunity_Line_Item__c>();
        for(Opportunity_Line_Item__c opli:existingOppLineItems)
        {
            existingServices.put(opli.Service__c, opli);
        }
        
        // get existing in oppty packages and fees
        List<Opp_Package_And_Fee_Line_Item__c> existingOppPackFeeLI = [SELECT Id, Service__c, Opp_Package_And_Fee__r.Id, Opp_Package_And_Fee__r.Comment__c,
                                                                            Opp_Package_And_Fee__r.Real_quantity__c, Opp_Package_And_Fee__r.Discount__c,
                                                                       		Opp_Package_And_Fee__r.Sales_List_Price__c, Opp_Package_And_Fee__r.Discount_precent__c,
                                                                       		Opp_Package_And_Fee__r.Maintenance_precent__c,Opp_Package_And_Fee__r.Discount_on_maintenance__c
                                                                        FROM Opp_Package_And_Fee_Line_Item__c
                                                                        WHERE Opp_Package_And_Fee__r.Opportunity__c = : opp.Id]; 
        Map<Id, Opp_Package_And_Fee__c> existingPackFees = new Map<Id, Opp_Package_And_Fee__c>();
        for(Opp_Package_And_Fee_Line_Item__c oppfli:existingOppPackFeeLI)
        {
            existingPackFees.put(oppfli.Service__c, oppfli.Opp_Package_And_Fee__r);
        }
        Account acc = [Select Id, Sales_Price_Customized_Software__c, Sales_Price_Project_Management__c, Sales_Price_Travel__c 
                       From Account 
                       Where Id =: opp.AccountId];
        // finally we have what we need to create list of wrappers
        for (Offer_Line_Item__c offerService : allTASServicesInOT)
        {
            tasServiceWrapper wrapper = new tasServiceWrapper();
            wrapper.Id = offerService.Id;
            wrapper.name = offerService.Name;           
            wrapper.quantity = 1; // default value
            wrapper.hasQuantity = offerPackFeeMap.get(offerService.Service__c).hasValue__c;
            wrapper.maintenancePrecent = offerPackFeeMap.get(offerService.Service__c).Maintenance_precent__c;
            wrapper.price = offerPackFeeMap.get(offerService.Service__c).Min_Price__c;
            if(wrapper.name == 'Customized software' && acc.Sales_Price_Customized_Software__c != null)
            {
                wrapper.price = acc.Sales_Price_Customized_Software__c;
            }
            if(wrapper.name == 'Project Management' && acc.Sales_Price_Project_Management__c != null)
            {
                wrapper.price = acc.Sales_Price_Project_Management__c;
            }
            if(wrapper.name == 'Travel' && acc.Sales_Price_Travel__c != null)
            {
                wrapper.price = acc.Sales_Price_Travel__c;
            }
            wrapper.alreadySold = false;
            
            for(Id existingId : soldServicesId)
            {
                if(offerService.Service__c == existingId && 
                   offerService.Name != 'Customized software' &&
                   offerService.Name != 'License per workstation' && 
                   !offerService.Name.startsWithIgnoreCase('Integrated'))
                {
                    wrapper.alreadySold = true;
                }
            }
            
            boolean isExistInOppty = existingServices.containsKey(offerService.Service__c);
            
            if(isExistInOppty)
            {
                wrapper.checked = true;
                wrapper.quantity = integer.valueOf(existingPackFees.get(offerService.Service__c).Real_quantity__c);
                wrapper.discountPrecent = existingPackFees.get(offerService.Service__c).Discount_precent__c;
                wrapper.maintenancePrecent = existingPackFees.get(offerService.Service__c).Maintenance_precent__c;
                wrapper.maintenanceDiscountPrecent = existingPackFees.get(offerService.Service__c).Discount_on_maintenance__c;
                wrapper.price = existingPackFees.get(offerService.Service__c).Sales_List_Price__c;
                wrapper.comment = existingPackFees.get(offerService.Service__c).Comment__c;
            }
            
            if(offerService.RecordTypeId == TASModuleRecordTypeId)
            {
                tasServices.add(wrapper);
            }
            else
            {
                tasConsulting.add(wrapper);
            }
        } // for each service on offer template
        tasServices.sort();
        tasConsulting.sort();
    } // wrapOfferTemplate
    
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2013 September 2
    * @description  save our items to oppty
    **/
    public PageReference AttachTASOfferTemplate() 
    {
        List<Id> selectedIds = new List<Id>();
        double maintenancesSum = 0;
        for(tasServiceWrapper item : tasServices)
        {
            if(item.alreadySold == false)
            {
                if(item.checked)
                {
                    selectedIds.add(item.Id);
                    maintenancesSum += item.maintenancePriceWithDiscount;
                }
            }
        }
        for(tasServiceWrapper item : tasConsulting)
        {
            if(item.checked)
            {
                selectedIds.add(item.Id);
            }
        }
        
        if(selectedIds.size() == 0)
        {
            return null;
        }
        
        Savepoint sp = Database.SetSavepoint(); 
        try
        {
            AttachTASServices(selectedIds);
            // add one single maintenance line to oppty with total amount of maintenance
            Offer_Package_And_Fee__c offerPF = [SELECT Id, Name 
                                                FROM Offer_Package_And_Fee__c 
                                                WHERE Offer_Template__c = :opp.Offer_Template__c AND Name = 'Total Maintenance'][0];
            Opp_Package_And_Fee__c maintPackFee = (new TR006Opportunity()).CreateSingleOppPackFee(opp.Id, offerPF.Id, 'Total Maintenance', opp.CurrencyIsoCode, 0, null, false);
            maintPackFee.Sales_Price__c = maintenancesSum;
            insert maintPackFee;
            (new TR006Opportunity()).CreateSingleOpportunityPackageFeeLineItem(maintPackFee.Id, 
                    null, null, opp.CurrencyIsoCode, true);            
            // quotes
            addQuoteForTAS();
        }
        catch(Exception ex)
        {
            //error = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
            database.rollback(sp);
            return null;
        }
        return (Utilities.Redirect(this.opp.id));
    } //AttachTASOfferTemplate
    
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2013 September 2
    * @description  fill all the related lists for opportunity
    **/
    private void AttachTASServices(List<Id> offerServiceIds)
    {
        Offer_Template__c selectedOfferTemplate = [SELECT Id, Default_Value__c, CUG_allowed__c, CurrencyIsoCode 
                                                    FROM Offer_Template__c 
                                                    WHERE Id= :offerTemplateId];
        opp.Offer_Template__c = selectedOfferTemplate.Id ;
        opp.Maximum_Invoice_Amount__c =selectedOfferTemplate.Default_Value__c;
        opp.CUG_allowed__c = selectedOfferTemplate.CUG_allowed__c;
        opp.CurrencyIsoCode = selectedOfferTemplate.CurrencyIsoCode;
        update opp;
        
        TR006Opportunity opptyHelper = new TR006Opportunity();
        // 10 SELECT statements and 10 DML operations
        opptyHelper.AddOpportunityElement(opp, offerServiceIds);

        // ------------------------------------------
        // update non-standard values for oppty
        List<Offer_Line_Item__c> selectedOfferTemplateLineItems = [SELECT o.Service__c, o.Service__r.Name, o.RecordTypeId, o.Offer_Template__c, 
                                                                   o.CurrencyIsoCode, o.Id, o.Frequency_pl__c,o.Billing_Base_pl__c, o.Billable_Service__c, 
                                                                   o.Service_Attribute_Template__c, o.Module_has_Value__c, Min_Price__c
                                                                    FROM Offer_Line_Item__c o 
                                                                    WHERE Id IN :offerServiceIds];

        List<Opp_Package_And_Fee_Line_Item__c>  oppPackFeeLineItems = [SELECT Id, Service__c, Opp_Package_And_Fee__r.Id, Opp_Package_And_Fee__r.Sales_Price__c,
                                                                            Opp_Package_And_Fee__r.Min_Price__c, Opp_Package_And_Fee__r.Max_Price__c,
                                                                            Opp_Package_And_Fee__r.Discount__c, Opp_Package_And_Fee__r.Real_Quantity__c
                                                                        FROM Opp_Package_And_Fee_Line_Item__c
                                                                        WHERE Opp_Package_And_Fee__r.Opportunity__c = :opp.Id];
        
        Map<Id, Opp_Package_And_Fee__c> oppPackFeeByServiceMap = new Map<Id, Opp_Package_And_Fee__c>();
        for(Opp_Package_And_Fee_Line_Item__c opfli : oppPackFeeLineItems)
        {
            oppPackFeeByServiceMap.put(opfli.Service__c, opfli.Opp_Package_And_Fee__r);
        }
        
        for(Offer_Line_Item__c offerLineItem : selectedOfferTemplateLineItems)
        {
            // search our wrapper item to extract values
            tasServiceWrapper wrapperItem = new tasServiceWrapper();
            for(tasServiceWrapper item : tasServices)
            {
                if(item.Id == offerLineItem.Id)
            	{
                    wrapperItem = item;
            	}
            }
            for(tasServiceWrapper item : tasConsulting)
            {
                if(item.Id == offerLineItem.Id)
                {
                    wrapperItem = item;
                }
            }

            // set price for quote
            //oppItemSubservicesMap.get(offerLineItem.Service__c).Sales_Price__c = wrapperItem.price;
            // set opp packFee items values
            
            oppPackFeeByServiceMap.get(offerLineItem.Service__c).Sales_List_Price__c = wrapperItem.price;
            oppPackFeeByServiceMap.get(offerLineItem.Service__c).Sales_Price__c = wrapperItem.modulePriceWithDiscount;
            oppPackFeeByServiceMap.get(offerLineItem.Service__c).Real_Quantity__c = wrapperItem.quantity;
            oppPackFeeByServiceMap.get(offerLineItem.Service__c).Discount__c = wrapperItem.discountValue;
            oppPackFeeByServiceMap.get(offerLineItem.Service__c).Discount_precent__c = wrapperItem.discountPrecent;
            oppPackFeeByServiceMap.get(offerLineItem.Service__c).Maintenance_precent__c = wrapperItem.maintenancePrecent;
            oppPackFeeByServiceMap.get(offerLineItem.Service__c).Discount_on_maintenance__c = wrapperItem.maintenanceDiscountPrecent;
        } // for each passed ID
        
        update oppPackFeeByServiceMap.values();

    } // AttachTASServices
    
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2013 September 2
    * @description  create Quote with related lists for TAS oppty.
    **/
    private void addQuoteForTAS()
    {
        Opportunity oppForQuote = [
            SELECT
                Id, Name, CloseDate, Offer_Template__c, Maximum_Invoice_Amount__c, CUG_allowed__c, AccountId, Product_Interest__c
            FROM Opportunity
            WHERE Id = :opp.Id
        ];
        // removing old quotes
        List<Quote> quotes = [SELECT Id, Name FROM Quote WHERE OpportunityId = :opp.Id];
        delete quotes;

        date validTill = date.today().addMonths(1);
        Id recordTypeId = isNewOpportunity ?
            TLR_RecordTypeHelper.getId('Quote', 'TAS New quote') : 
            TLR_RecordTypeHelper.getId('Quote', 'TAS Existing quote');
        (new TR007Quote()).CreateQuote(new List<Opportunity>{oppForQuote}, validTill, recordTypeId);
        if(isNewOpportunity)
        {
            // we need to add all services in Quote for new quotes.
            // i will add them as PackFees
            Quote quote = [SELECT Id, Name FROM Quote WHERE OpportunityId = :opp.Id][0];
            List<Quote_Package_And_Fee__c> existingPackFees = [
                SELECT
                    Id, Name,
                    Opp_Package_And_Fee__r.Offer_Package_And_Fee__c
                FROM Quote_Package_And_Fee__c
                WHERE Quote__c = :quote.Id
            ];

            Set<Id> existingOfferPackFees = new Set<Id>();
            for(Quote_Package_And_Fee__c qpf : existingPackFees)
                existingOfferPackFees.add(qpf.Opp_Package_And_Fee__r.Offer_Package_And_Fee__c);
            
            List<Offer_Package_And_Fee_Line_Item__c> offerPackFeeLineItems = [
                SELECT
                    Id, Service__r.RecordTypeId,
                    Offer_Package_And_Fee__r.Id, Offer_Package_And_Fee__r.Name, 
                    Offer_Package_And_Fee__r.Overusage_Price__c, Offer_Package_And_Fee__r.CurrencyIsoCode,Offer_Package_And_Fee__r.Flag_Sorting__c
                FROM Offer_Package_And_Fee_Line_Item__c
                WHERE Offer_Package_And_Fee__r.Offer_Template__c = :opp.Offer_Template__c];

            List<Quote_Package_And_Fee__c> quotePackFees = new List<Quote_Package_And_Fee__c>();
            
            Id TASSrvModuleRecordTypeId = TLR_RecordTypeHelper.getId('Service__c', 'TAS Module');
            Id TASSrvConsultingRecordTypeId = TLR_RecordTypeHelper.getId('Service__c', 'TAS Consulting');
            
            for(Offer_Package_And_Fee_Line_Item__c opfli : offerPackFeeLineItems)
            {
                if(existingOfferPackFees.contains(opfli.Offer_Package_And_Fee__r.Id))
                    continue;
                
                Quote_Package_And_Fee__c qpf = new Quote_Package_And_Fee__c();
                qpf.Name                     = opfli.Offer_Package_And_Fee__r.Name;
                qpf.CurrencyIsoCode          = opfli.Offer_Package_And_Fee__r.CurrencyIsoCode;
                qpf.Quote__c                 = quote.Id;
                qpf.Sales_Price__c           = 0;
                qpf.Overusage_Price__c       = opfli.Offer_Package_And_Fee__r.Overusage_Price__c;
                qpf.Offer_Package_And_Fee__c = opfli.Offer_Package_And_Fee__r.Id;
                qpf.Flag_Sorting__c          = opfli.Offer_Package_And_Fee__r.Flag_Sorting__c;
                if(opfli.Service__r.RecordTypeId == TASSrvModuleRecordTypeId)
                    qpf.TAS_service_kind__c = 'Module';
                if(opfli.Service__r.RecordTypeId == TASSrvConsultingRecordTypeId)
                    qpf.TAS_service_kind__c = 'Consulting';
                
                quotePackFees.add(qpf);
            } // for all offer pack fees
                       
            insert quotePackFees;
        } // if new oppty
    } //addQuoteForTAS
    
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2013 September 2
    * @description  redirect to our opportunity
    **/
    public PageReference RedirectToOpportunity() 
    {
        return (Utilities.Redirect(this.opp.id));
    }
    
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2013 September 11
    * @description  redirect to opportunities list
    **/
    public PageReference RedirectToOpportunitiesList() 
    {
        return Utilities.RedirectToStandardList('Opportunity');
    }
}