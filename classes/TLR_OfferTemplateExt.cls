/*
	used for VF pages:
		NewOfferTemplate.page
		SelectTemplateSub.page
*/
public with sharing class TLR_OfferTemplateExt 
{
	/*
		class used for SelectTemplateSub page. REFACTOR IT!!! it uses 2 SOQL queries inside constructor
		used for SelectTemplateSub page
	*/
	public class SubServiceTemplateWrapper
	{
		public ID serviceId { get; set; }
		public String serviceName { get; set; }
		public String templateId { get; set; }
		public List<SelectOption> options { get; set; }
		public Boolean isOneOption {get; set;}
		
		public SubServiceTemplateWrapper(Id svcId, List<Subservice_Template__c> templates)
		{
			serviceId = svcId;
			/*serviceName = [
				SELECT Name 
				FROM Service__c 
				WHERE Id = :serviceId
			].Name;*/
			
			options = new SelectOption[0];
			//templOpt.add(new SelectOption('null', 'No Subservice'));
			/*
			List<Subservice_Template__c> templates = [
				SELECT 
					Id, Name 
				FROM Subservice_Template__c 
				WHERE Parent_Service__c = :serviceId 
					AND Start_Date__c <= :Date.Today() 
				ORDER BY Default__c DESC
			];*/
			
			for (Subservice_Template__c template : templates)
				options.add(new SelectOption(template.Id, template.Name));
			
			templateId = templates[0].Id;
			
			isOneOption = (templates.size() == 1);
		}
	}
	//------------------------------------------------------------------------------------------------
	// 
	//------------------------------------------------------------------------------------------------
	public Offer_Template__c offerTemplate { get; set; }
	private Product__c product { get; set; }
	private final Id TASOfferTemplateRecordTypeId = TLR_RecordTypeHelper.getId('Offer_template__c','TAS Offer template');
	//------------------------------------------------------------------------------------------------
	// properties for SelectTemplateSub page
	//------------------------------------------------------------------------------------------------
	public boolean renderAccessKind { get; set; }
	public boolean renderSubServiceTempaltes { get; set; }
	public List<SelectOption> AccessKinds { get; set; }
	public List<SubServiceTemplateWrapper> subsTemplates { get; set; }
	private List<Product_Line_Item__c> productServices { get; set; }
	//------------------------------------------------------------------------------------------------
	// constructor
	//------------------------------------------------------------------------------------------------
	public TLR_OfferTemplateExt(ApexPages.StandardController controller) 
	{
		offerTemplate = (Offer_Template__c)controller.getRecord();
		
		// i need separate handling for new offer template 
		boolean isNewOfferTemplate = string.isEmpty(offerTemplate.Name);
		if(isNewOfferTemplate)
		{
			offerTemplate.OwnerId = UserInfo.getUserId();
			offerTemplate.Status__c = 'Pending';
			offerTemplate.Start_Date__c = Date.today();
		}
	} // .ctor
	
	//------------------------------------------------------------------------------------------------
	// methods for NewOfferTemplate page
	//------------------------------------------------------------------------------------------------
	public PageReference NextToSelectTemplate()
	{
		try
		{
			if(offerTemplate.Start_Date__c < Date.Today())
				throw new Generic.StandardException('Start date should be today or in the future');
			
			if(offerTemplate.End_Date__c != null && offerTemplate.End_Date__c < offerTemplate.Start_Date__c)
				throw new Generic.StandardException('End date should be greater or equal to start date');
			
			product = [
				SELECT 
					Id, Status__c, Start_Date__c, End_Date__c, Access_Kind__c 
				FROM Product__c 
				WHERE Id = :offerTemplate.Base_Product__c
			];
			
			if(product.Status__c != 'Active')
				throw new Generic.StandardException('Only active products can be selected');
			
			if(product.Start_Date__c > offerTemplate.Start_Date__c || (product.End_Date__c != null && product.End_Date__c < offerTemplate.End_Date__c))
				throw new Generic.StandardException('Product validity dates do not match Offer Template validity dates');
			
			if((product.Access_Kind__c == null || product.Access_Kind__c == '') && offerTemplate.RecordTypeId != TASOfferTemplateRecordTypeId)
				throw new Generic.StandardException('Product access kind cannot be empty');
			
			
			
			// get list of not started services, not active yet
			List<Subservice_Template__c> notStartedSubserviceTemplates = [
				SELECT
					Id, Parent_Service__c, Start_Date__c
				FROM Subservice_Template__c
				WHERE Start_Date__c > :Date.today()
			];
			List<Id> notStartedServices = new List<Id>();
			for(Subservice_Template__c st : notStartedSubserviceTemplates)
				notStartedServices.add(st.Parent_Service__c);
			
			// get list of product services, active only
			productServices = [
				SELECT 
					Id, Name, Service__c, Service__r.Name, Service__r.Billable_Service__c, RecordTypeId 
				FROM Product_Line_Item__c
				WHERE Parent__c = :offerTemplate.Base_Product__c
					AND Service__c NOT IN :notStartedServices
			];
			
			// now we will collect all add-on product services
			List<Add_on_Parent__c> addOnParents = [
				SELECT 
					Add_on__c 
				FROM Add_on_Parent__c
				WHERE Product__c = :offerTemplate.Base_Product__c 
					AND Product__r.Status__c = 'Active' 
					AND Product__r.Start_Date__c <= :offerTemplate.Start_Date__c
			];
			Set<ID> addOnIds = new Set<ID>();
			for (Add_on_Parent__c addOnParent : addOnParents)
				addOnIds.add(addOnParent.Add_on__c);
			
			List<Product_Line_Item__c> servicesAddOn = [
				SELECT 
					Id, Name, Service__c, 
					Service__r.Name, Service__r.RecordTypeId, Service__r.Billable_Service__c 
				FROM Product_Line_Item__c 
				WHERE Parent__c IN :addOnIds
					AND Service__c NOT IN :notStartedServices
			];
			
			productServices.AddAll(servicesAddOn);
			subsTemplates = new List<SubServiceTemplateWrapper>();
			
			// first SOQL query from warpper constructor
			List<Id> serviceIds = new List<Id>();
			for (Product_Line_Item__c service : productServices)
				serviceIds.add(service.Service__c);
			Map<Id, Service__c> servicesMap = new Map<Id, Service__c>([
				SELECT Id, Name 
				FROM Service__c 
				WHERE Id IN :serviceIds
			]);
			
			// second query from wrapper constructor
			List<Subservice_Template__c> templates = [
				SELECT 
					Id, Name, Parent_Service__c
				FROM Subservice_Template__c 
				WHERE Parent_Service__c IN :serviceIds
					AND Start_Date__c <= :Date.Today() 
				ORDER BY Parent_Service__c, Default__c DESC
			];
			Map<Id, List<Subservice_Template__c>> subservicesByServiceMap = new Map<Id, List<Subservice_Template__c>>();
			for(Subservice_Template__c tpl : templates)
			{
				if(!subservicesByServiceMap.containsKey(tpl.Parent_Service__c))
					subservicesByServiceMap.put(tpl.Parent_Service__c, new List<Subservice_Template__c>());
				subservicesByServiceMap.get(tpl.Parent_Service__c).add(tpl);
			}
			
			for (Product_Line_Item__c service : productServices)
			{
				SubServiceTemplateWrapper wrapper = new SubServiceTemplateWrapper(service.Service__c, subservicesByServiceMap.get(service.Service__c));
				wrapper.serviceName = servicesMap.get(service.Service__c).Name;
				subsTemplates.add(wrapper);
			}
		}
		catch(Exception ex)
		{
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
			return null;
		}
		return Page.SelectTemplateSub;
	} // SaveNewOfferTemplate
	
	//------------------------------------------------------------------------------------------------
	// methods for SelectTemplateSub page
	//------------------------------------------------------------------------------------------------
	public PageReference initSelectTemplateSub() // init2
	{
		renderSubServiceTempaltes  = (subsTemplates.size() > 0);
		renderAccessKind = true;
		
		
		if(offerTemplate.RecordTypeId != TASOfferTemplateRecordTypeId)
		{
			if(AccessKinds == null)
				AccessKinds = new List<SelectOption>();
			
			List<String> lstAKnds = product.Access_Kind__c.split(';');
			
			for(String aknds : lstAKnds)
				AccessKinds.add(new Selectoption(aknds, aknds));
			
			offerTemplate.Access_Kind__c = AccessKinds[0].getValue();
			
			renderAccessKind = (AccessKinds.size() > 1);
		}
		else
		{
			offerTemplate.Access_Kind__c = 'TAS';
			renderAccessKind = false;
			renderSubServiceTempaltes = false;
		}
		if(!renderSubServiceTempaltes && !renderAccessKind)
			return SaveOfferTemplate();
		
		return null;
	}
	
	public PageReference SaveOfferTemplate() // save2
	{
		Savepoint sp = Database.SetSavepoint();
		
		// subservices are not created!!!
		try
		{
			createRecords();
			if (subsTemplates.size() > 0)
				createSubservices();
		}
		catch(Exception ex)
		{
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
			return null;
		}
		return Utilities.Redirect(offerTemplate.Id);
	}
	
	private static Map<Id, Id> FillRecordTypesMap()
	{ 
		Map <Id, Id> RTMap = new Map <Id, Id>();
		
		RTMap.put(
			TLR_RecordTypeHelper.getId('Product_Line_Item__c','TAS Module'), 
			TLR_RecordTypeHelper.getId('Offer_Line_Item__c','TAS Module'));
		
		RTMap.put(
			TLR_RecordTypeHelper.getId('Product_Line_Item__c','TAS Maintenance'), 
			TLR_RecordTypeHelper.getId('Offer_Line_Item__c','TAS Maintenance'));
		
		RTMap.put(
			TLR_RecordTypeHelper.getId('Product_Line_Item__c','TAS Consulting'), 
			TLR_RecordTypeHelper.getId('Offer_Line_Item__c','TAS Consulting'));
		
		return RTMap;
	}
	
	private void createRecords() 
	{
		if(offerTemplate == null)
			return;
		try
		{
			insert offerTemplate;
		}
		catch(Exception e)
		{
			throw new Generic.StandardException('Cannot save offer template');
		}
		
		// Get service attribute templates
		Map<ID, ID> attributeTemplatesMap = new Map<ID, ID>(); //mapServSAT
		
		List<Service_Attribute_Template__c> serviceAttrTemplates = [
			SELECT 
				Id, Parent__c 
			FROM Service_Attribute_Template__c 
			WHERE Default__c = true
		];
		
		for (Service_Attribute_Template__c sat : serviceAttrTemplates)
			attributeTemplatesMap.put(sat.Parent__c, sat.Id);
		
		Id recordTypeSub = TLR_RecordTypeHelper.getId('Offer_Line_Item__c','Simple Subservice Service');
		Id TASOfferTemplateRecordType = TLR_RecordTypeHelper.getId('Offer_Template__c','TAS Offer template');
		
		Map <Id, Id> RTMap = FillRecordTypesMap();

		Offer_Line_Item__c[] allServices = new Offer_Line_Item__c[]{};
		if(!productServices.isEmpty())
		{ 
			for (Product_Line_Item__c service : productServices)
			{
				Offer_Line_Item__c oli              = new Offer_Line_Item__c();
				oli.Name                            = service.Service__r.Name;
				oli.CurrencyIsoCode                 = offerTemplate.CurrencyIsoCode;
				oli.Billable_Service__c             = service.Service__r.Billable_Service__c;
				oli.Offer_Template__c               = offerTemplate.Id;
				oli.Service__c                      = service.Service__c;
				oli.Service_Attribute_Template__c   = attributeTemplatesMap.get(service.Service__c);
				
				System.Debug('## TAS offer record type: '+ offerTemplate.RecordTypeId);
				if(offerTemplate.RecordTypeId == TASOfferTemplateRecordType)
					oli.RecordTypeId = RTMap.get(service.RecordTypeId);
				else
					oli.RecordTypeId = recordTypeSub;
				System.Debug('## RecordTypeId: '+ oli.RecordTypeId);
				allServices.add(oli);
			} // for each service
			try
			{
				System.Debug('## allServices: '+ allServices);
				insert allServices;
				for (Offer_Line_Item__c oli : allServices)
					System.Debug('## OLI:' + oli.Id + '-' + oli.Service__c + '-' + oli.Service__r.Name);
			}
			catch (DmlException e)
			{
				System.Debug('## DmlException: ' + e);
				//ApexPages.addMessages(e);
				throw e;
			}
		} // if services not empty
	}
	private void createSubservices() 
	{
		System.Debug('## Start Create Subs');
		
		Id recordSub = TLR_RecordTypeHelper.getId('Offer_Item_Subservice__c', 'TLR Offer Item Subservice');
		Id withoutSub = TLR_RecordTypeHelper.getId('Offer_Line_Item__c', 'Simple Service');
		Id withSub = TLR_RecordTypeHelper.getId('Offer_Line_Item__c', 'Simple Subservice Service');
		
		Set<ID> templatesIds = new Set<ID>();
		for (SubServiceTemplateWrapper template : subsTemplates)
			templatesIds.add(template.templateId);

		Map<ID, Subservice_Template__c> mapSubserviceTemplates = new Map<ID, Subservice_Template__c>(
			[SELECT 
				Id, 
				(SELECT Id, Name, Subservice__c, Subservice__r.Name FROM Subservice_Links__r) 
			 FROM Subservice_Template__c 
			 WHERE Id IN :templatesIds]);

		Set<ID> servicesId = new Set<ID>();
		for (SubServiceTemplateWrapper template : subsTemplates)
		    servicesId.add(template.serviceId);
		System.Debug('## servicesId: ' + servicesId);
		
		List<Offer_Line_Item__c> offerlineIetms = new List<Offer_Line_Item__c>();

		if(offerTemplate.RecordTypeId == TASOfferTemplateRecordTypeId)
			offerlineIetms = [
				SELECT 
					Id, RecordTypeId, Service__c 
				FROM Offer_Line_Item__c 
				WHERE Offer_Template__c = :offerTemplate.Id
			];
		 else
 			offerlineIetms = [
 				SELECT 
					Id, RecordTypeId, Service__c 
				FROM Offer_Line_Item__c 
				WHERE Offer_Template__c = :offerTemplate.Id 
					AND Service__c IN :servicesId
			];
		System.Debug('## offerlineIetms: ' + offerlineIetms);
		Map<ID, Offer_Line_Item__c> mapOfferLineItems = new Map<ID, Offer_Line_Item__c>();
		List<Offer_Line_Item__c> offerLineItemsToUpdate = new List<Offer_Line_Item__c>();
		List<Offer_Item_Subservice__c> offerItemSubservicesToUpdate = new List<Offer_Item_Subservice__c>();
		
		for(Offer_Line_Item__c oli : offerlineIetms)
			mapOfferLineItems.put(oli.Service__c, oli);

		for (SubServiceTemplateWrapper template : subsTemplates)
		{
		
			Offer_Line_Item__c oli = mapOfferLineItems.get(template.serviceId);
			
			System.Debug('## Sub: OK');
			if (template.templateId == 'null')
			{
				oli.RecordTypeId = withoutSub;
				//update oli;
				offerLineItemsToUpdate.add(oli);
			}
			else
			{
				System.Debug('## oli: ' + oli);
				if(offerTemplate.RecordTypeId != TASOfferTemplateRecordTypeId)
				{
					System.Debug('## withSub: ' + withSub);
					oli.RecordTypeId = withSub;
				}
				//update oli;
				offerLineItemsToUpdate.add(oli);
				
				List<Subservice_Template_Line_Item__c> subs = mapSubserviceTemplates.get(template.templateId).Subservice_Links__r;//[SELECT Id, Name, Subservice__c, Subservice__r.Name  FROM Subservice_Template_Line_Item__c WHERE Template__c = :template.templ];
				for (Subservice_Template_Line_Item__c sub : subs)
				{
					Offer_Item_Subservice__c ois = new Offer_Item_Subservice__c();
					ois.Subservice__c      = sub.Subservice__c;
					ois.CurrencyIsoCode    = offerTemplate.CurrencyIsoCode;
					ois.RecordTypeId       = recordSub;
					ois.Offer_Line_Item__c = oli.Id;
					ois.Name               = sub.Subservice__r.Name;
					ois.Min_Price__c       = 0;
					ois.Max_Price__c       = 0;                    
					// insert ois;
					offerItemSubservicesToUpdate.add(ois);
				}
			}
		} // for each wrapper
		if(!offerLineItemsToUpdate.isEmpty())
		{
			try
			{
				update offerLineItemsToUpdate;
			}
			catch(Exception e)
			{
				//System.debug('Offer Line Item Update Failed==>'+e.getMessage());
				throw new Generic.StandardException('Offer Line Item Update Failed: ' + e.getMessage());
			}
		}
		if(!offerItemSubservicesToUpdate.isEmpty())
		{
			try
			{
				insert offerItemSubservicesToUpdate;
			}
			catch(Exception e)
			{
				//System.debug('Offer Item Subervice Update Failed==>'+e.getMessage());
				throw new Generic.StandardException('Offer Item Subervice Update Failed: ' + e.getMessage());
			}
		}
		System.Debug('## End Create Subs');
	}
	
	
	public PageReference RedirectToList() 
	{
		String prefix = Schema.getGlobalDescribe().get('Offer_Template__c').getDescribe().getKeyPrefix();
		return Utilities.Redirect(prefix + '/o');
	}
	
}