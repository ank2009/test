public with sharing class CtrlNewSubsCurrentFee 
{
	public Subs_Current_Fee__c scf { get; set; }
	public Boolean error { get; set; }
	public String ContractErrorMsg = 'Invoice Level must always be greater than or equal with Account Level!';
	private Account acc { get;set; }
	private Subscription__c subs { get; set; }

	public CtrlNewSubsCurrentFee(ApexPages.StandardController controller) 
	{
		this.scf = (Subs_Current_Fee__c)controller.getRecord();
		system.debug('scf in constructor---------###########' + scf);
		
		subs = [
			SELECT
				Contract__r.AccountId, Contract__r.Id, Contract__r.Invoice_Level__c
			FROM Subscription__c 
			WHERE Id = :this.scf.Subscription__c
		];
		
		acc = [
			SELECT 
				Id, Name, AccountNumber, Account_Level__c 
			FROM Account 
			WHERE Id= :subs.Contract__r.AccountId
		];
		
		this.scf.Account__c = acc.Id;
		this.scf.Name = '';
		error = false;
	}

	public void changeAccount()
	{
		Account acc = [
			SELECT 
				Id, Name, AccountNumber, Account_Level__c 
			FROM Account 
			WHERE Id = :this.scf.Account__c
		];
		this.scf.Account_Number__c = acc.AccountNumber;
		this.scf.Account_Level__c = acc.Account_Level__c;
	}

	public PageReference init()
	{
		//Subscription__c sub = [SELECT Start_Date__c, CurrencyIsoCode FROM Subscription__c WHERE Id = :this.scf.Subscription__c];
		// Modified by HCL Technology
		List<Subscription__c> sub = [
			SELECT 
				Start_Date__c, CurrencyIsoCode 
			FROM Subscription__c 
			WHERE Id = :this.scf.Subscription__c limit 1
		];
		try
		{
			system.debug('subscription details### Inside Init### sub list is' + sub);
			if(!sub.isEmpty())
			{
				update sub;
			}
		}
		catch(DMLException e)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Insufficient Privileges!')); 
			error = true;
		}
		this.scf.CurrencyIsoCode = sub[0].CurrencyIsoCode;
		return null;
	}

	public PageReference Save()
	{ 
		System.debug('this.scf=>' + this.scf);    
		try
		{
			// Subscription_Line_Item__c exist only
			if(this.scf.Subscription_Line_Item__c != null && this.scf.Subs_Package_And_Fee__c == null)
			{
				Subscription_Line_Item__c  subsLineItem = [
					SELECT 
						Id, Name 
					FROM Subscription_Line_Item__c 
					WHERE Id = :this.scf.Subscription_Line_Item__c 
				];
				this.scf.Name = subsLineItem.Name;
				if(this.scf.User_Profile__c == null && TLR_SubsCurrentFeeHelper.invoiceLevelValidation(subs.Contract__r.Invoice_Level__c, acc.Account_Level__c))
				{
					try
					{
						insert this.scf;
					}
					catch(Exception ex)
					{
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage())); 
						return null;
					}
				}
				else
				{
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ContractErrorMsg));
					return null;
				}
			} // if Subscription_Line_Item__c exist only
			// only Subs_Package_And_Fee__c exist, or Subscription_Line_Item__c and Subs_Package_And_Fee__c exist
			else if((this.scf.Subscription_Line_Item__c == null && this.scf.Subs_Package_And_Fee__c != null) ||
					(this.scf.Subscription_Line_Item__c != null && this.scf.Subs_Package_And_Fee__c != null))
			{
				system.debug('subscription package and fees not null--------------' + this.scf.Subs_Package_And_Fee__c); 
				Subs_Package_And_Fee__c subsPackAndFee = [
					SELECT 
						Name, isUser__c 
					FROM Subs_Package_And_Fee__c 
					WHERE Id = :this.scf.Subs_Package_And_Fee__c 
				];
				this.scf.Name = subsPackAndFee.Name;
				
				List<User_Profile__c> userProfileLst;
				if(this.scf.User_Profile__c != null)
				{
					userProfileLst = [
						SELECT 
							Contact__r.Username__c, Contact__c 
						FROM User_Profile__c 
						WHERE Id = :this.scf.User_Profile__c LIMIT 1
					];
					system.debug('scf.Subs_Package_And_Fee__r.isUser__c---------------' + userProfileLst[0].Contact__r.Username__c);
					system.debug('this.scf.Username__c--###############' + subsPackAndFee.isUser__c);
					if(!userProfileLst.isEmpty())
					{
						if(subsPackAndFee.isUser__c == 'true' && (userProfileLst[0].Contact__r.Username__c == null || userProfileLst[0].Contact__r.Username__c == ''))
						{// Added for CR 
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'User Name is Mandatory.Please select user profile to Populate user name.'));
							return null;
						} 
						else 
						{
							system.debug('Insert scf--------------');
							if(this.scf.User_Profile__c == null && TLR_SubsCurrentFeeHelper.invoiceLevelValidation(subs.Contract__r.Invoice_Level__c, acc.Account_Level__c))
							{
								insert this.scf;
							}
							else
							{
								ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ContractErrorMsg));
								return null;
							}
						}
					}
				}  // if User_Profile__c is not empty
				else if(subsPackAndFee.isUser__c == 'true')
				{
					system.debug('inside else if profile is null and isUser is true-------->');
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'User Name is Mandatory.Please select user profile to Populate user name.'));
					return null;
				}
				else if(subsPackAndFee.isUser__c=='false')
				{
					system.debug('inside else when profile is null and isUser is false------>');
					if(this.scf.User_Profile__c == null && TLR_SubsCurrentFeeHelper.invoiceLevelValidation(subs.Contract__r.Invoice_Level__c, acc.Account_Level__c))
					{
						insert this.scf;
					}
					else
					{
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ContractErrorMsg));
						return null;
					}
				}
			} // if only Subs_Package_And_Fee__c exist, or Subscription_Line_Item__c and Subs_Package_And_Fee__c exist
			// Subscription_Line_Item__c is empty and Subs_Package_And_Fee__c is empty
			else if(this.scf.Subscription_Line_Item__c == null && this.scf.Subs_Package_And_Fee__c == null)
			{
				system.debug('Sub line item and sub package both are blank !!!!!!');
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'At least one of the two fields Subscription Line Item or Subs Package And Fee must be filled'));
				return null;
			}
		} // try
		catch(DMLException e)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'At least one of the two fields Subscription Line Item or Subs Package And Fee must be filled'));
			error = true;
		} 
		return (Utilities.Redirect(this.scf.Subscription__c));
	}

	

	public PageReference Cancel()
	{
		return (Utilities.Redirect(this.scf.Subscription__c));
	}
}