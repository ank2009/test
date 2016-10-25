/** 
* @author       Anton Soloviev (anton_soloveyv@epam.com)
* @date         2014 Feb 17
* @description  Trigger handler for Service_Order__c events
**/
public with sharing class TRIG_ServiceOrderTriggerHandler extends TRIG_TriggerHandlerAbstract
{
	private Id pmtServiceOrder;
	//private Id csServiceOrder;
	
	public boolean IsTriggerContext
	{ get { return isTriggerExecuting; } }
	
	public TRIG_ServiceOrderTriggerHandler (boolean isTriggerExecuting)
	{
		super(isTriggerExecuting);
		pmtServiceOrder = TLR_RecordTypeHelper.getId('Service_Order__c', 'PMT ServiceOrder');
		//csServiceOrder = TLR_RecordTypeHelper.getId('Service_Order__c', 'Cust ServiceOrder');
	}
	public override void OnBeforeInsert(List<sObject> newTriggerValues)
	{
	
	}
	public override void OnAfterInsert(List<sObject> newTriggerValues, Map<ID, sObject> newTriggerValuesMap)
	{
	
	}
	
	public override void OnBeforeUpdate (List<sObject> oldTriggerValues, List<sObject> newTriggerValues, Map<ID, sObject> oldTriggerValuesMap, Map<ID, sObject> newTriggerValuesMap)
	{

	}
	public override void OnAfterUpdate  (List<sObject> oldTriggerValues, List<sObject> newTriggerValues, Map<ID, sObject> oldTriggerValuesMap, Map<ID, sObject> newTriggerValuesMap)
	{
		List<Subs_Current_Fee__c> newSCFList = new List<Subs_Current_Fee__c>();
		
		// i need additional parameters like account and subs P&F
		List<Id> subsIds = new List<Id>();
		for(sObject newVal : newTriggerValues)
			subsIds.add(((Service_Order__c)newVal).Subscription__c);
		
		List<Subs_Package_And_Fee__c> travelPFs = [
			SELECT
				Id, Name, Subscription__c, 
				Min_Price__c, Sales_Price__c, Opp_Package_And_Fee__r.Sales_List_Price__c,
				Subscription__r.Account__r.Id, Subscription__r.Account__r.AccountNumber, Subscription__r.Account__r.Account_Level__c
			FROM Subs_Package_And_Fee__c
			WHERE Subscription__c IN :subsIds
			AND Name = 'Travel'
		];
		
		List<Subs_Package_And_Fee__c> pmPFs = [
			SELECT
				Id, Name, Subscription__c, 
				Min_Price__c, Sales_Price__c, Opp_Package_And_Fee__r.Sales_List_Price__c,
				Subscription__r.Account__r.Id, Subscription__r.Account__r.AccountNumber, Subscription__r.Account__r.Account_Level__c
			FROM Subs_Package_And_Fee__c
			WHERE Subscription__c IN :subsIds
			AND Name = 'Project Management'
		];
		
		System.debug('---------- TRIG_ServiceOrderTriggerHandler: OnAfterUpdate: travelPFs: ' + travelPFs);
		System.debug('---------- TRIG_ServiceOrderTriggerHandler: OnAfterUpdate: pmPFs: ' + pmPFs);
		
		// maps with lists above, linked to subscriptions
		Map<Id, Subs_Package_And_Fee__c> travelSPFMap = new Map<Id, Subs_Package_And_Fee__c>();
		Map<Id, Subs_Package_And_Fee__c> pmSPFMap = new Map<Id, Subs_Package_And_Fee__c>();
		
		for(Subs_Package_And_Fee__c spf : travelPFs)
			travelSPFMap.put(spf.Subscription__c, spf);
		for(Subs_Package_And_Fee__c spf : pmPFs)
			pmSPFMap.put(spf.Subscription__c, spf);
		
		// now we are ready to process out trigger values
		// trick to allow updates on our records
		List<Id> soIds = new List<Id>();
		for(sObject newVal : newTriggerValues)
			soIds.add(newVal.Id);
		List<sObject> newTriggerValuesQueried = [
			SELECT 
				Id, Name, Status__c, RecordTypeId, Start_of_service__c, 
				Comments__c, Service_Hours__c, Subscription__c, Travel__c,
				Meeting_Subs_Current_Fee__c, Travel_Subs_Current_Fee__c
			FROM Service_Order__c
			WHERE Id IN :soIds
		];
		
		Map<Service_Order__c, Subs_Current_Fee__c> pmSOMap = new Map<Service_Order__c, Subs_Current_Fee__c>();
		Map<Service_Order__c, Subs_Current_Fee__c> trSOMap = new Map<Service_Order__c, Subs_Current_Fee__c>();
		for(sObject newVal : newTriggerValuesQueried)
		{
			Service_Order__c newOrder = (Service_Order__c)newVal;
			Service_Order__c oldOrder = (Service_Order__c)oldTriggerValuesMap.get(newVal.Id);
			
			System.debug('---------- TRIG_ServiceOrderTriggerHandler: OnAfterUpdate: oldOrder: ' + oldOrder);
			System.debug('---------- TRIG_ServiceOrderTriggerHandler: OnAfterUpdate: newOrder: ' + newOrder);
			
			if((newOrder.Status__c != oldOrder.Status__c) && newOrder.Status__c == 'Approved' && newOrder.RecordTypeId == pmtServiceOrder)
			{
				Subs_Package_And_Fee__c travelPF = travelSPFMap.get(newOrder.Subscription__c);
				Subs_Package_And_Fee__c pmPF = pmSPFMap.get(newOrder.Subscription__c);
				
				if(pmPF == null)
					throw new Generic.StandardException('Subscription does not contain \'Project management\' PackFee!');
				
				System.debug('---------- TRIG_ServiceOrderTriggerHandler: OnAfterUpdate: pmPF: ' + pmPF);
				System.debug('---------- TRIG_ServiceOrderTriggerHandler: OnAfterUpdate: travelPF: ' + travelPF);
				
				Subs_Current_Fee__c scf = TLR_SubscriptionHelper.CreateSingleSubscriptionCurrentFee(
					pmPF.Name,
					newOrder.Start_of_service__c.date(),
					pmPF.Subscription__r.Account__c,
					pmPF.Subscription__r.Account__r.AccountNumber,
					pmPF.Subscription__r.Account__r.Account_Level__c,
					newOrder.Subscription__c,
					pmPF.Id,
					string.format(/*'{0} for service order'*/'{1}. Comments: {2}', new string[] {pmPF.Name, newOrder.Name, newOrder.Comments__c}),
					false);
				scf.Price__c = pmPF.Sales_Price__c * newOrder.Service_Hours__c;
				newSCFList.add(scf);
				
				pmSOMap.put(newOrder, scf);
				System.debug('---------- TRIG_ServiceOrderTriggerHandler: OnAfterUpdate: PM scf: ' + scf);
				
				if(newOrder.Travel__c)
				{
					if(travelPF == null)
						throw new Generic.StandardException('Subscription does not contain \'Travel\' PackFee!');
					
					Subs_Current_Fee__c tscf = TLR_SubscriptionHelper.CreateSingleSubscriptionCurrentFee(
						travelPF.Name, 
						newOrder.Start_of_service__c.date(),
						travelPF.Subscription__r.Account__c,
						travelPF.Subscription__r.Account__r.AccountNumber,
						travelPF.Subscription__r.Account__r.Account_Level__c,
						newOrder.Subscription__c,
						travelPF.Id,
						string.format(/*'{0} for service order'*/'{1}. Comments: {2}', new string[] {travelPF.Name, newOrder.Name, newOrder.Comments__c}), 
						false);
					tscf.Price__c = travelPF.Sales_Price__c;
					newSCFList.add(tscf);
					
					System.debug('---------- TRIG_ServiceOrderTriggerHandler: OnAfterUpdate: Travel scf: ' + tscf);
					trSOMap.put(newOrder, tscf);
				} // if travel
			} // if service order status is changed
		} // for loop
		if(newSCFList.size() > 0)
			insert newSCFList;
		
		System.debug('---------- TRIG_ServiceOrderTriggerHandler: OnAfterUpdate: pmSOMap: ' + pmSOMap);
		System.debug('---------- TRIG_ServiceOrderTriggerHandler: OnAfterUpdate: trSOMap: ' + trSOMap);
		// now we have scf ids and we can update service orders
		List<Service_Order__c> soToUpdate = new List<Service_Order__c>();
		for(Service_Order__c so : pmSOMap.keySet())
		{
			System.debug('---------- TRIG_ServiceOrderTriggerHandler: OnAfterUpdate: pmSOMap.get(so): ' + pmSOMap.get(so));
			System.debug('---------- TRIG_ServiceOrderTriggerHandler: OnAfterUpdate: trSOMap.get(so): ' + trSOMap.get(so));
			Subs_Current_Fee__c trSCF = trSOMap.get(so);
			so.Meeting_Subs_Current_Fee__c = pmSOMap.get(so).Id;
			if(so.Travel__c)
				so.Travel_Subs_Current_Fee__c = trSCF.Id;
			soToUpdate.add(so);
		}
		if(soToUpdate.size() > 0)
			update soToUpdate;
	}
	
	public override void OnBeforeDelete (List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap)
	{
	
	}
	public override void OnAfterDelete(List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap)
	{

	}
	
	public override void OnAfterUndelete(List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap)
	{
	
	}
}