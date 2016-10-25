/**
* @author       Anton Solovyev (anton_soloveyv@epam.com)
* @date         2013 August, sonewhere there
* @description  Helper class for Subscription__c
**/
public with sharing class TLR_SubscriptionHelper
{
	public static final string maintenancePrefix = 'Maintenance for ';

	private Map<Id, Id> mappingSubscription = new Map<Id, Id>();
    
    private Id WktsOpportunity = TLR_RecordTypeHelper.getId('Opportunity','WKTS Opportunity');

	/**
	* @author       refactored by Anton Solovyev (anton_soloveyv@epam.com)
	* @date         2013 August, somewhere there
	* @description  Modify existing subscription (with related lists), using existing Oppty and offer tmplate
	**/
	public void ModifyExistingSubscription(Id subsId, Opportunity opp, Offer_Template__c offerTemplate)
	{
		DeleteSubscriptionSubItems(subsId);

		Subscription__c subs = [
			SELECT
				Id, Opportunity__c, Offer_Template__c, Product__c, Start_Date__c, End_Date__c, Access_Kind__c,
				Maximum_Subscription_Amount__c, Start_Usage_Payment__c, CUG_allowed__c, CurrencyIsoCode
			FROM Subscription__c
			WHERE Id = :subsId
		];

		try
		{
			subs.Opportunity__c = opp.Id;
			subs.Offer_Template__c = offerTemplate.Id;
			subs.Access_Kind__c = offerTemplate.Access_Kind__c;
			subs.Product__c = offerTemplate.Base_Product__c;
			subs.Start_Date__c = Date.today();

			if (offerTemplate.Contract_Term__c > 0)
			    subs.End_Date__c = subs.Start_Date__c.addMonths(offerTemplate.Contract_Term__c.intValue());
			else
			    subs.End_Date__c = null;
			subs.Start_Usage_Payment__c         = opp.Start_Usage_Payment_Date__c;
			subs.CUG_allowed__c                 = opp.CUG_allowed__c;
			subs.Maximum_Subscription_Amount__c = opp.Maximum_Invoice_Amount__c;
			subs.CurrencyIsoCode                = opp.CurrencyIsoCode;

			update subs;
		}
		catch (Exception e)
		{
			Generic.StandardException ex = new Generic.StandardException();
			ex.SetMessage('Error: Update existing Subscription! ' + e.getMessage());
			throw ex;
		}

		CreateSubscriptionHierarchy(subs, opp, null);
	} // ModifyExistingSubscription

	public ID CreateNewSubscription(ID contractId, Id opptyId)
	{
		Opportunity oppty = [
			SELECT
				Id, Start_Usage_Payment_Date__c, CurrencyIsoCode, AccountId, CUG_allowed__c,
				Maximum_Invoice_Amount__c, RecordTypeId,
				Offer_Template__r.Access_Kind__c, Offer_Template__r.Base_Product__c, Offer_Template__r.Contract_Term__c,
				Offer_Template__r.Default_Invoice_Level__c, Offer_Template__r.Default_Invoice_Media__c
			FROM Opportunity
			WHERE Id=:opptyId
		];
		return CreateNewSubscription(contractId, oppty, oppty.Offer_Template__r);
	}

	/**
	* @author       refactored by Anton Solovyev (anton_soloveyv@epam.com)
	* @date         2013 August, somewhere there
	* @description  Create new subscription (with related lists), using existing Oppty and offer tmplate
	**/
	public ID CreateNewSubscription(ID contractId, Opportunity opp, Offer_Template__c offerTemplate)
	{
		Contract contract = [
			SELECT
				Id, EndDate,
				(SELECT Id FROM Subscriptions__r)
			FROM Contract
			WHERE Id = :contractId
		];

		Subscription__c subs = new Subscription__c();

		try
		{
			/*subs.Name                         = 'Subscription ' + contract.Subscriptions__r.size().format();*/
			subs.Name                           = 'Subscription - ' + opp.Name;
			subs.Contract__c                    = contract.Id;
			subs.Account__c                     = opp.AccountId;
			subs.Opportunity__c                 = opp.Id;
			subs.Offer_Template__c              = offerTemplate.Id;
			subs.Access_Kind__c                 = offerTemplate.Access_Kind__c;
			subs.Product__c                     = offerTemplate.Base_Product__c;
			subs.Start_Date__c                  = Date.today();
			if (offerTemplate.Contract_Term__c > 0)
				subs.End_Date__c = subs.Start_Date__c.addMonths(offerTemplate.Contract_Term__c.intValue());
			subs.Start_Usage_Payment__c         = opp.Start_Usage_Payment_Date__c;
			subs.Status__c                      = 'Sent';
			subs.CUG_allowed__c                 = opp.CUG_allowed__c;
			subs.Maximum_Subscription_Amount__c = opp.Maximum_Invoice_Amount__c;
			subs.CurrencyIsoCode                = opp.CurrencyIsoCode;
			// to handle TAS Oppty
			if(opp.Product_Interest__c == 'TAS')
			{
				subs.RecordTypeId = TLR_RecordTypeHelper.getId('Subscription__c', 'TAS Subscription');
				subs.Status__c = 'Draft';
			}
            

			insert subs;
            		
			// if we have here TWD oppty - we need to activate subscription
			if(opp.Product_Interest__c == 'CD' || opp.Product_Interest__c == 'SB' || opp.Product_Interest__c == 'TWD' )
			{
				subs.Flag_IntegrityChecks__c = true;
				//subs.Status__c = 'Sent';
				//update subs;
				//subs.Status__c = 'Waiting For Verification';
				//update subs;
				if(subs.Waiting_For_Payment__c)
                {
					subs.Status__c = 'Waiting For Payment';
                }
                else
                {
                    subs.Status__c = 'Waiting For Provisioning';
                }
				update subs;
			}
		}
		catch (Exception e)
		{
			Generic.StandardException ex = new Generic.StandardException();
			ex.SetMessage('Error: Subscription creation failed! ' + e.getMessage());
			throw ex;
		}

		CreateSubscriptionHierarchy(subs, opp, offerTemplate.Name);

		return subs.Id;
	} // CreateNewSubscription

	/**
	* @author       refactored by Anton Solovyev (anton_soloveyv@epam.com)
	* @date         2013 August, somewhere there
	* @description  Populate subscription related lists, using corresponding related lists from Oppty
	**/
	private void CreateSubscriptionHierarchy(Subscription__c subs, Opportunity opp, String offerTemplName)
	{
		/**
	    * put Opportunity_Line_Item__c => Subscription_Line_Item__c in mapping
	    *****
	    * dependent function requirements
	    * Opportunity_Line_Item__c must exist in mapping
	    * Opp_Item_Subservice__c must exist in mapping (put there by dependent function)
	    **/
		CreateSubscriptionLineItems(opp.Id, subs);

		/**
	    * put Opp_Package_And_Fee__c => Subs_Package_And_Fee__c in mapping
	    *****
	    * dependent function requirements
	    * PackFee__c must exist in mapping
	    * Opp_Package_And_Fee__c must exist in mapping
	    **/
		CreateSubscriptionPackFees(opp.Id, subs, offerTemplName);
	}

	/**
	* @author       refactored by Anton Solovyev (anton_soloveyv@epam.com)
	* @date         2013 August, somewhere there
	* @description  Delete all subscription related lists
	**/
	private void DeleteSubscriptionSubItems(Id subsId)
	{
		// element to delete
		Subscription_Line_Item__c[] lstsubli = [
			SELECT
				Id
			FROM Subscription_Line_Item__c
			WHERE Subscription__c = :subsId
		];
		if (lstsubli.size() > 0) delete lstsubli;

		Subs_Promotion__c[] lstsubp = [
			SELECT
				Id
			FROM Subs_Promotion__c
			WHERE Subscription__c = :subsId
		];
		if (lstsubp.size()  > 0) delete lstsubp;

		Subs_Package_And_Fee__c[] lstsubpf = [
			SELECT
				Id
			FROM Subs_Package_And_Fee__c
			WHERE Subscription__c = :subsId
		];
		if (lstsubpf.size() > 0) delete lstsubpf;
	}

	/**
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2013 August 15
    * @description  create Subscription Line items
    *
    * put Opportunity_Line_Item__c => Subscription_Line_Item__c in mapping
    *****
    * dependent function requirements
    * Opportunity_Line_Item__c must exist in mapping
    * Opp_Item_Subservice__c must exist in mapping (put there by dependent function)
    **/
	private void CreateSubscriptionLineItems(Id oppId, Subscription__c currentCreatedSubscription)
	{
		List<Opportunity_Line_Item__c> oppLineItems = [
			SELECT
				o.Unit_Type_pl__c, o.Service__c, o.Service_Attribute_Template__c,
				o.Sales_Price__c, o.Offer_Line_Item__c, o.Consolidation_Level__c, o.Name, o.Id,
				o.Frequency_pl__c, o.Billing_Base_pl__c, o.Applied_To__c, o.CurrencyIsoCode
			FROM Opportunity_Line_Item__c o
			WHERE Opportunity__c = :oppId
		];

		if (oppLineItems.size() > 0)
		{
			List<Subscription_Line_Item__c> subsLineItemsToInsert = new List<Subscription_Line_Item__c>();//sliToInsert = new List<Subscription_Line_Item__c>();

			for (Opportunity_Line_Item__c opli : oppLineItems)
			{
				Subscription_Line_Item__c sli = new Subscription_Line_Item__c();
				sli.Name                            = opli.Name;
				sli.CurrencyIsoCode                 = opli.CurrencyIsoCode;
				sli.Applied_To__c                   = opli.Applied_To__c;
				sli.Billing_Base__c                 = opli.Billing_Base_pl__c;
				sli.Consolidation_Level__c          = opli.Consolidation_Level__c;
				sli.Frequency__c                    = opli.Frequency_pl__c;
				sli.Opportunity_Line_Item__c        = opli.Id;
				//sli.Sales_Price__c                  = opli.Sales_Price__c;
				sli.Service__c                      = opli.Service__c;
				sli.Service_Attribute_Template__c   = opli.Service_Attribute_Template__c;
				sli.Subscription__c                 = currentCreatedSubscription.Id;
				sli.Unit_Type__c                    = opli.Unit_Type_pl__c;

				subsLineItemsToInsert.add(sli);
			}

			if (subsLineItemsToInsert.size() > 0)
			{
				insert subsLineItemsToInsert;

				for (Subscription_Line_Item__c sli : subsLineItemsToInsert)
					mappingSubscription.put(sli.Opportunity_Line_Item__c, sli.Id);
			}
		} // if oppLineItems.size > 0
		CreateSubscriptionLineItemSubservices(oppLineItems);
	} // CreateSubscriptionLineItems

	/**
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2013 August 15
    * @description  create Subscription Line items subservices
    *
    * Opportunity_Line_Item__c must exist in mapping
    * put Opp_Item_Subservice__c => Subs_Item_Subservice__c in mapping
    *****
    * dependent function requirements
    * Opp_Item_Subservice__c must exist in mapping
    **/
	private void CreateSubscriptionLineItemSubservices(List<Opportunity_Line_Item__c> oppLineItems)
	{
		// Subscription Item Subservice
		List<Opp_Item_Subservice__c> oppItemSubservices = [ // opisubs
			SELECT
				o.Volume_Discount_cb__c, o.Unit_Type__c,
				o.Subservice__c, o.Subservice_Volume_Discount__c, o.Sales_Price__c, o.RecordTypeId,
				o.Opportunity_Line_Item__c, o.Offer_Item_Subservice__c, o.Name, o.Min_Price__c, o.Max_Price__c,
				o.Id, o.Frequency__c, o.Estimated_Quantity__c, o.Billing_Base__c, o.Applied_To__c, o.CurrencyIsoCode
			FROM Opp_Item_Subservice__c o
			WHERE Opportunity_Line_Item__c IN :oppLineItems
		];

		if (oppItemSubservices.size() > 0)
		{
			List<Subs_Item_Subservice__c> subsItemSubservicesToInsert = new List<Subs_Item_Subservice__c>(); // sisToInsert

			for (Opp_Item_Subservice__c opisub : oppItemSubservices)
			{
				Subs_Item_Subservice__c sisub       = new Subs_Item_Subservice__c();
				sisub.Name                          = opisub.Name;
				sisub.CurrencyIsoCode               = opisub.CurrencyIsoCode;
				sisub.Applied_To__c                 = opisub.Applied_To__c;
				sisub.Billing_Base__c               = opisub.Billing_Base__c;
				sisub.Frequency__c                  = opisub.Frequency__c;
				sisub.Opp_Item_Subservice__c        = opisub.Id;
				sisub.Sales_Price__c                = opisub.Sales_Price__c;
				sisub.Subscription_Line_Item__c     = mappingSubscription.get(opisub.Opportunity_Line_Item__c);
				sisub.Subservice__c                 = opisub.Subservice__c;
				sisub.Subservice_Volume_Discount__c = opisub.Subservice_Volume_Discount__c;
				sisub.Unit_Type__c                  = opisub.Unit_Type__c;
				sisub.Volume_Discount_cb__c         = opisub.Volume_Discount_cb__c;

				subsItemSubservicesToInsert.add(sisub);
			}

			if (subsItemSubservicesToInsert.size() > 0)
			{
				insert subsItemSubservicesToInsert;

				for (Subs_Item_Subservice__c sisub : subsItemSubservicesToInsert)
					mappingSubscription.put(sisub.Opp_Item_Subservice__c, sisub.Id);
			}
		} // if oppItemSubservices.size() > 0
		CreateSubscriptionItemSubVDLineItems(oppItemSubservices);
		CreateSubscriptionConditions(oppItemSubservices);
	} // CreateSubscriptionLineItemSubservice

	/**
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2013 August 15
    * @description  create Subscription Line items subservices VD Line items
    *
    * Opp_Item_Subservice__c must exist in mapping
    **/
	private void CreateSubscriptionItemSubVDLineItems(List<Opp_Item_Subservice__c> oppItemSubservices)
	{
		List<Opp_Item_Sub_VD_Line_Item__c> lstvditem = [
			SELECT
				o.Volume_Discount_Bracket__c, o.Sales_Price__c,
				o.Opp_Item_Subservice__c, o.Offer_Item_Sub_VD_Line_Item__c, o.Name,
				o.Min_Price__c, o.Max_Price__c, o.Id, o.CurrencyIsoCode
			FROM Opp_Item_Sub_VD_Line_Item__c o
			WHERE Opp_Item_Subservice__c IN :oppItemSubservices
		];

		if (lstvditem.size() > 0)
		{
			List<Subs_Item_Sub_VD_Line_Item__c> sisvdliToInsert = new List<Subs_Item_Sub_VD_Line_Item__c>();

			for (Opp_Item_Sub_VD_Line_Item__c oisvli : lstvditem)
			{
				Subs_Item_Sub_VD_Line_Item__c svd = new Subs_Item_Sub_VD_Line_Item__c();
				svd.Name                            = oisvli.Name;
				svd.CurrencyIsoCode                 = oisvli.CurrencyIsoCode;
				svd.Opp_Item_Sub_VD_Line_Item__c    = oisvli.Id;
				svd.Sales_Price__c                  = oisvli.Sales_Price__c;
				svd.Subs_Item_Subservice__c         = mappingSubscription.get(oisvli.Opp_Item_Subservice__c);
				svd.Volume_Discount_Bracket__c      = oisvli.Volume_Discount_Bracket__c;

				sisvdliToInsert.add(svd);
			}

			if (sisvdliToInsert.size() > 0)
				insert sisvdliToInsert;
		} // if (lstvditem.size() > 0)
	} // CreateSubscriptionItemSubVDLineItems

	/**
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2013 August 15
    * @description  create Subscription Line items conditions
    *
    * Opp_Item_Subservice__c must exist in mapping
    **/
	private void CreateSubscriptionConditions(List<Opp_Item_Subservice__c> oppItemSubservices)
	{
		List<Opp_Item_Sub_Condition__c> oppiscs = [
			SELECT
				Id, Opp_Item_Subservice__c, CurrencyIsoCode
			FROM Opp_Item_Sub_Condition__c
			WHERE Opp_Item_Subservice__c IN :oppItemSubservices
		];

		if (oppiscs.size() > 0)
		{
			List<Subs_Item_Sub_Condition__c> siscToInsert = new List<Subs_Item_Sub_Condition__c>();

			for (Opp_Item_Sub_Condition__c oppisc : oppiscs)
			{
				Subs_Item_Sub_Condition__c sisc = new Subs_Item_Sub_Condition__c();
				sisc.Opp_Item_Sub_Condition__c  = oppisc.Id;
				sisc.CurrencyIsoCode            = oppisc.CurrencyIsoCode;
				sisc.Subs_Item_Subservice__c    = mappingSubscription.get(oppisc.Opp_Item_Subservice__c);

				siscToInsert.add(sisc);
			}

			if (siscToInsert.size() > 0)
				insert siscToInsert;
		} // if (oppiscs.size() > 0)
	} // CreateSubscriptionConditions

	/**
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2013 August 15
    * @description  create Subscription Packages and Fees
    *
    * put Opp_Package_And_Fee__c => Subs_Package_And_Fee__c in mapping
    *****
    * dependent function requirements
    * PackFee__c must exist in mapping
    * Opp_Package_And_Fee__c must exist in mapping
    **/
	private void CreateSubscriptionPackFees(Id oppId, Subscription__c currentCreatedSubscription, String offerTemplateName)
	{
		List<Opp_Package_And_Fee__c> oppPackFees = [
			SELECT
				o.Sales_Price__c, o.Overusage_Price__c, o.Offer_Package_And_Fee__r.Package_Fee__c,
				o.Name, o.Id, o.CurrencyIsoCode, Comment__c
			FROM Opp_Package_And_Fee__c o
			WHERE Opportunity__c =:oppId
		];
		List<Subs_Package_And_Fee__c> spfToInsert = new List<Subs_Package_And_Fee__c>();
		if (oppPackFees.size() > 0)
		{
			for (Opp_Package_And_Fee__c oppPF : oppPackFees)
			{
				Subs_Package_And_Fee__c spf = CreateSingleSubscriptionPackFee(oppPF.Name, oppPF.CurrencyIsoCode,
					currentCreatedSubscription.Id, oppPF.Id, oppPF.Offer_Package_And_Fee__r.Package_Fee__c,
					oppPF.Sales_Price__c, oppPF.Overusage_Price__c, oppPF.Comment__c, false);
				spfToInsert.add(spf);
			}

			if (spfToInsert.size() > 0)
			{
				insert spfToInsert;

				for (Subs_Package_And_Fee__c spf : spfToInsert)
					mappingSubscription.put(spf.Opp_Package_And_Fee__c, spf.Id);
			}
		} // if oppPackFees.size() > 0
		CreateSubscriptionPackFeeLineItems(oppPackFees);
        
		//addon for automatic creation Subs_Current_Fee__c according WKTSCRM-2569 JIRA Task
		if(offerTemplateName != null
		&& offerTemplateName.startsWith('TFX'))
		{
            boolean createDMS = true;
            boolean createCD = true;
            List<Subs_Current_Fee__c> existingCDApproved = [select Id, Name from Subs_Current_Fee__c where (Name = 'CD_approved' or Name = 'DMS_approved') 
                                                            and  Subscription__r.Account__c =: currentCreatedSubscription.Account__c
                                                            and Subscription__r.Status__c = 'Active' and Start_Date__c <= today
                                                            and (End_Date__c = null or End_Date__c > today)];
            if(existingCDApproved.size() > 0)
            {
                for(Subs_Current_Fee__c scf : existingCDApproved)
                {
                    if(!createCD && !createDMS)
                        break;
                    if(scf.Name == 'CD_approved')
                    {
                        createCD = false;
                    }
                    else
                    {
                        createDMS = false;
                    }
                }
            }
            
			List<Subs_Current_Fee__c> currFee2insert = New List <Subs_Current_Fee__c>(); 
			for(Subs_Package_And_Fee__c currPF:spfToInsert)
			{
				if((currPF.Name == 'CD_approved' && createCD)
				|| (currPF.Name == 'DMS_approved' && createDMS))
				{
					Subs_Current_Fee__c newCurrentFee = New Subs_Current_Fee__c(Name = currPF.Name,
			                                                                    Account__c = currentCreatedSubscription.Account__c, 
			                                                                    Subscription__c = currentCreatedSubscription.Id,
			                                                                    Subs_Package_And_Fee__c = currPF.Id, 
			                                                                    Price__c = 0, 
			                                                                    Start_Date__c = currentCreatedSubscription.Start_Date__c, 
			                                                                    End_Date__c = null);
					currFee2insert.add(newCurrentFee);
				}
			} 
            if(currFee2insert.Size() > 0)
            {
                insert currFee2insert;	
            }
		     		
		} //end addon        
        
	} // CreateSubscriptionPackFees

	/**
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2013 August 15
    * @description  create Subscription PackagesAndFees line items
    *
    * PackFee__c must exist in mapping  - will be null, since it never init
    * Opp_Package_And_Fee__c must exist in mapping
    **/
	private void CreateSubscriptionPackFeeLineItems(List<Opp_Package_And_Fee__c> oppPackFees)
	{
		List<Opp_Package_And_Fee_Line_Item__c> lstOPFLI = [
			SELECT
				o.Weight__c,  o.Service__c, o.RecordTypeId,
				o.PackFee__c, o.Opp_Package_And_Fee__c, o.Offer_Package_And_Fee_Line_Item__r.PackFee_Line_Item__c,
				o.Name, o.Id, o.CurrencyIsoCode
			FROM Opp_Package_And_Fee_Line_Item__c o
			WHERE Opp_Package_And_Fee__c IN :oppPackFees
		];

		if (lstOPFLI.size() > 0)
		{
			List<Subs_Package_And_Fee_Line_Item__c> spfliToInsert = new List<Subs_Package_And_Fee_Line_Item__c>();

			for (Opp_Package_And_Fee_Line_Item__c opfli : lstOPFLI)
			{
				Subs_Package_And_Fee_Line_Item__c spfli = new Subs_Package_And_Fee_Line_Item__c();
				spfli.Opp_Package_And_Fee_Line_Item__c  = opfli.Id;
				spfli.CurrencyIsoCode                   = opfli.CurrencyIsoCode;
				spfli.PackFee__c                        = mappingSubscription.get(opfli.PackFee__c); // null here
				spfli.Package_and_Fee_Line_Item__c      = opfli.Offer_Package_And_Fee_Line_Item__r.PackFee_Line_Item__c;
				spfli.Service__c                        = opfli.Service__c;
				spfli.Subs_Package_And_Fee__c           = mappingSubscription.get(opfli.Opp_Package_And_Fee__c);

				spfliToInsert.add(spfli);
			}

			if (spfliToInsert.size() > 0)
				insert spfliToInsert;
		}
	} // CreateSubscriptionPackFeeLineItems

	
	/**
	* @author       refactored by Anton Solovyev (anton_soloveyv@epam.com)
	* @date         2013 August, somewhere there
	* @description  Copy subs PackFees to CurrentFees, with given start date
	**/
	public static void CreateSubscriptionCurrentFeesFromPF(Id subsId, Date startDate)
	{
		Subscription__c subs = [
			SELECT
				Id, Contract__r.AccountId, Contract__r.Id, Contract__r.Invoice_Level__c
			FROM Subscription__c
			WHERE Id = :subsId
		];

		List<Subs_Package_And_Fee__c> subsPackFees = [
			SELECT
				Id, Name, isUser__c, Comments__c, Real_Quantity__c, Sales_Price__c,
				Opp_Package_And_Fee__r.Min_Price__c
			FROM Subs_Package_And_Fee__c
			WHERE Subscription__c = :subs.Id
			AND Name <> 'Travel'
			AND Name <> 'Project Management'
		];

		Account acc = [
			SELECT
				Id, Name, AccountNumber, Account_Level__c
			FROM Account
			WHERE Id= :subs.Contract__r.AccountId
		];

		List<Subs_Current_Fee__c> subsCurrentFees = new List<Subs_Current_Fee__c>();

		for(Subs_Package_And_Fee__c subsPF : subsPackFees)
		{
			// skip maintenance indifidual lines
			//if(subsPF.Name.indexOf(maintenancePrefix) == 0)
			//	continue;
			Subs_Current_Fee__c subsCurrentFee = CreateSingleSubscriptionCurrentFee(subsPF.Name, startDate,
					acc.Id, acc.AccountNumber, acc.Account_Level__c,
					subs.Id, subsPF.Id,
					subsPF.Comments__c, false);
				subsCurrentFees.add(subsCurrentFee);
		} // for each subs packFee

		if(subsCurrentFees.size() > 0)
			insert subsCurrentFees;
	} // CreateSubscriptionCurrentFeesFromPF

	/**
	* @author       Anton Solovyev (anton_soloveyv@epam.com)
	* @date         2013 September 10
	* @description  Create individual Subs PackFee item.
	**/
	public static Subs_Package_And_Fee__c CreateSingleSubscriptionPackFee(string spfName, string currencyIsoCode,
		Id subsId, Id oppPFId, Id packFeeId,
		decimal salesPrice, decimal overusagePrice, string comment,
		boolean insertNow)
	{
		Subs_Package_And_Fee__c retVal = new Subs_Package_And_Fee__c();

		retVal.Name                    = spfName;
		retVal.CurrencyIsoCode         = currencyIsoCode;
		retVal.Opp_Package_And_Fee__c  = oppPFId;
		retVal.Overusage_Price__c      = overusagePrice;
		retVal.Package_and_Fee__c      = packFeeId;
		retVal.Sales_Price__c          = salesPrice;
		retVal.Subscription__c         = subsId;
		retVal.Comments__c             = comment;

		if(insertNow)
			insert retVal;

		return retVal;
	} // CreateSubscriptionPackFee

	/**
	* @author       Anton Solovyev (anton_soloveyv@epam.com)
	* @date         2013 September 10
	* @description  Create individual Subs CurrentFee item.
	**/
	public static Subs_Current_Fee__c CreateSingleSubscriptionCurrentFee(string currentFeeName, Date startDate,
		Id accountId, string accountNumber, string accountLevel,
		Id subscriptionId, Id subsPackFeeId,
		string notes, boolean insertNow)
	{
		string logStr = string.format('------------- TLR_SubscriptionHelper: CreateSingleSubscriptionCurrentFee: params: currentFeeName: {0}, startDate: {1}, accountId: {2}, accountNumber: {3}', 
			new string[] {currentFeeName, string.valueOf(startDate), string.valueOf(accountId), accountNumber});
		logStr = string.format('{0}, accountLevel: {1}, subscriptionId: {2}, subsPackFeeId: {3}, notes: {4}, insertNow: {5}',
			new string[] {logStr, accountLevel, string.valueOf(subscriptionId), string.valueOf(subsPackFeeId), notes, string.valueOf(insertNow)});
		system.debug(logStr);
		
		Subs_Current_Fee__c retVal = new Subs_Current_Fee__c();

		retVal.Account__c = accountId;
		retVal.Account_Number__c = accountNumber;
		retVal.Account_Level__c = accountLevel;
		retVal.Name = currentFeeName;
		retVal.Start_Date__c = startDate;
		retVal.Subs_Package_And_Fee__c = subsPackFeeId;
		retVal.Subscription__c = subscriptionId;
		retVal.Notes__c = notes;

		if(insertNow)
			insert retVal;
		return retVal;
	} //CreateSingleSubscriptionCurrentFee
    
  
		
	/**
	* @author       Anton Solovyev (anton_soloveyv@epam.com)
	* @date         2015 March 30
	* @description  Cancel subscription
	**/
	public static void CancelSubscription(Subscription__c subs)
	{
		if (subs.End_Date__c < subs.Start_Date__c)
            throw new Generic.StandardException('End date must be greater or equal to Start date!');
        
        if(subs.Offer_Template__r.Use_new_Provisioning__c)
        {
        	// actually nothing to do here, subscription trigger will update subsCurrentFee end dates
        	// and subsCurrentFee trigger will send updates to CM ESB
        }
        else
        	if (!Test.isRunningTest())
            	ProvisioningMessages.CancelSubscription(subs.Id, subs.End_Date__c); // Call Provisioning module
        
        subs.Status__c = 'On Notice';
        update subs;
	} //CancelSubscription
	
	public static void CancelSubscription(Id subsId)
	{
		List<Subscription__c> subsList = [SELECT Start_Date__c, End_Date__c, Status__c, Offer_Template__r.Name FROM Subscription__c WHERE Id = :subsId];
		if(subsList.size() < 1)
			throw new Generic.StandardException('No subscription with given Id: ' + subsId);
		CancelSubscription(subsList.get(0));
	} //CancelSubscription
}