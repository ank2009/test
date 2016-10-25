/*
* @author		Andrey Gordienko (andrey_gordienko@epam.com)
* @date			2014 Jule 11
* @description	trigger handler Subs CurrentFees
**/
public without sharing class TRIG_SubsCurrentFeeTriggerHandler extends TRIG_TriggerHandlerAbstract
{
 
	public boolean IsTriggerContext { get { return isTriggerExecuting;} }
	public TRIG_SubsCurrentFeeTriggerHandler (boolean isTriggerExecuting){ super(isTriggerExecuting); }
    
	public override void OnBeforeInsert(List<sObject> newTriggerValues)
	{
		this.SetPriceForLineItem(newTriggerValues);
	}
	public override void OnAfterInsert(List<sObject> newTriggerValues, Map<ID, sObject> newTriggerValuesMap)
	{
		this.UpdateCompanyAfterInsertCurFees(newTriggerValues);
		this.UpdateAccountPLC(newTriggerValues);
	}

	public override void OnBeforeUpdate (List<sObject> oldTriggerValues, List<sObject> newTriggerValues, Map<ID, sObject> oldTriggerValuesMap, Map<ID, sObject> newTriggerValuesMap){}
	public override void OnAfterUpdate  (List<sObject> oldTriggerValues, List<sObject> newTriggerValues, Map<ID, sObject> oldTriggerValuesMap, Map<ID, sObject> newTriggerValuesMap)
	{
		UpdateCompanyAfterInsertCurFees(newTriggerValues);
		this.UpdateTotalMaintenance(newTriggerValues);
		this.UpdateAccountPLC(newTriggerValues);
	}

	public override void OnBeforeDelete (List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap) {}
	public override void OnAfterDelete  (List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap)
	{
		UpdateCompanyAfterInsertCurFees(oldTriggerValues);
		this.UpdateAccountPLC(oldTriggerValues);
	}

	public override void OnAfterUndelete(List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap) {}
	
	/*
	* @author		Andrey Gordienko (andrey_gordienko@epam.com)
	* @date			2014 Jule 11
	* @description	Method for update information for WKTSA
	**/
	private void UpdateCompanyAfterInsertCurFees(List<sObject> newTriggerValues)
	{
		// if we need to do automatic updates
		User u = [SELECT Id, Disable_ESB_calls__c, Disable_ESB_automatic_updates__c FROM User WHERE Id=:UserInfo.getUserId()];
		if(u.Disable_ESB_calls__c || u.Disable_ESB_automatic_updates__c)
			return;
			
		Set<ID> subsIds = new Set<ID>();
		for(sObject s:newTriggerValues)
		{
			Subs_Current_Fee__c curFee = (Subs_Current_Fee__c)s;
			if(Trigger.isInsert)
			{
				if(curFee.Start_Date__c <= Date.today() && ((curFee.End_Date__c == null ? true : curFee.End_Date__c > Date.today() )))
					subsIds.add(curFee.Subscription__c);
			}
			else
			{
				subsIds.add(curFee.Subscription__c);
			}
		}
		// we will choose only active subscription with approved accounts
		List<Subscription__c> subs = [Select Account__c, Status__c, Contact__c, ID, Account__r.ESB_Company_status__c 
									From Subscription__c Where ID =: subsIds 
									and Contact__c != null 
									and Status__c in ('Active', 'On Notice', 'Cancelled') 
									and (Account__r.ESB_Company_status__c = 'APPROVED' OR Account__r.ESB_Company_status__c = 'PUBLISHED' OR Account__r.ESB_Company_status__c = 'UNPUBLISHED')];
		Set<Id> accIds = new Set<Id>();
        for(Subscription__c sub : subs)
        {
            accIds.add(sub.Account__c);
        }
        for(Id accId : accIds)
        {
            ESB_Proxy.UpdateCompany(accId, true);
        }
	} //UpdateCompanyAfterInsertCurFees

	/*
	* @author		Andrey Gordienko (andrey_gordienko@epam.com)
	* @date			2014 Jule 11
	* @description	Update TotalMaintenance for subscription After Update Curr Fee
	**/	
	private void UpdateTotalMaintenance(List<SObject> newTriggerValues)
	{		
		// here we need to update 'total maintenance' subsCurrentFee
		Id subscriptionId = ((Subs_Current_Fee__c)newTriggerValues[0]).Subscription__c;

		double totalMaintenanceAmount = 0.0;
		// se need here get all the currentFees to do full recalculation
		List<Subs_Current_Fee__c> allCurrentFees = [SELECT Id, Name, Price__c, Start_Date__c, End_Date__c FROM Subs_Current_Fee__c WHERE Subscription__c = :subscriptionId];

		// and our total maintenance line
		Subs_Current_Fee__c totalSubsCurrentFee = null;
		try
		{
			totalSubsCurrentFee = [
				SELECT Id, Name, Price__c
				FROM Subs_Current_Fee__c
				WHERE Subscription__c = :subscriptionId AND Name = 'Total Maintenance'
			];
		}
		catch(Exception ex)
		{
			// if there are no rows - just skip this subscription
			system.debug('Subscription skipped. subscriptionId: ' + subscriptionId);
			return;
		}
		for(Subs_Current_Fee__c cf : allCurrentFees)
		{
			// skip from calculation
			if(cf.Name == 'Total Maintenance')
				continue;
			// if it is maintenance and start date is set - add price to total
			if(cf.Name.indexOf(TLR_SubscriptionHelper.maintenancePrefix) == 0 && cf.Start_Date__c != null)
			{
				if(cf.Start_Date__c <= date.today() && (cf.End_Date__c == null || cf.End_Date__c >= date.today()))
					totalMaintenanceAmount += cf.Price__c;
			}
		}
		system.debug('Subscription processed. subscriptionId: ' + subscriptionId);
		if(totalMaintenanceAmount != totalSubsCurrentFee.Price__c) // && totalMaintenanceAmount != 0)
		{
			totalSubsCurrentFee.Price__c = totalMaintenanceAmount;
			update totalSubsCurrentFee;
			system.debug('Subscription currentFees are updated. subscriptionId: ' + subscriptionId);
		}
	
	}

	/*
	* @author		Andrey Gordienko (andrey_gordienko@epam.com)
	* @date			2014 Jule 11
	* @description	Canculate Price for SubscCurFee 
	**/		
	private void SetPriceForLineItem(List<SObject> newTriggerValues)
	{
		Set<ID> setIdSubsLI = new Set<ID>();
		Set<ID> setIdSubsPF = new Set<ID>();
		
		for (sObject sObj : newTriggerValues)
		{
			Subs_Current_Fee__c scf = (Subs_Current_Fee__c)sObj;
            if(scf.Price__c != null)
				continue;
			if (scf.Subscription_Line_Item__c != null)
				setIdSubsLI.add(scf.Subscription_Line_Item__c);
			else if (scf.Subs_Package_And_Fee__c != null)
				setIdSubsPF.add(scf.Subs_Package_And_Fee__c);
		}

		Map<Id, Subscription_Line_Item__c> mapSubsLI = new Map<Id, Subscription_Line_Item__c>([SELECT Sales_Price__c FROM Subscription_Line_Item__c WHERE Id IN :setIdSubsLI]);
		Map<Id, Subs_Package_And_Fee__c> mapSubsPF = new Map<Id, Subs_Package_And_Fee__c>([SELECT Sales_Price__c FROM Subs_Package_And_Fee__c WHERE Id  IN :setIdSubsPF]);

		for (sObject sObj : newTriggerValues)
		{
            Subs_Current_Fee__c scf = (Subs_Current_Fee__c)sObj;
            
            if (scf.Subscription_Line_Item__c != null && mapSubsLI.containsKey(scf.Subscription_Line_Item__c))
				scf.Price__c = mapSubsLI.get(scf.Subscription_Line_Item__c).Sales_Price__c;
			else if (scf.Subs_Package_And_Fee__c != null && mapSubsPF.containsKey(scf.Subs_Package_And_Fee__c))
				scf.Price__c = mapSubsPF.get(scf.Subs_Package_And_Fee__c).Sales_Price__c;
		}
	}
	
	private void UpdateAccountPLC(List<Subs_Current_Fee__c> newTriggerValues)
	{
		Set<ID> accIds = new Set<ID>();
		for(Subs_Current_Fee__c subCur:newTriggerValues)
		{
			if(subCur.Account__c != null)
			{
				accIds.add(subCur.Account__c);
			}
		}
		for(ID i:accIds)
		{
			System.Debug('-----------Account ID' + i);
			String UserName = UserInfo.getName();
    		if(!UserName.contains('ESB') && !Test.isRunningTest())
    		{
				TLR_AccountMembershipLifeCycleController con = new TLR_AccountMembershipLifeCycleController(i);
    		}
		}
	}
}