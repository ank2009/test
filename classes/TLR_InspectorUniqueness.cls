global class TLR_InspectorUniqueness implements Schedulable
{
	global void execute(SchedulableContext sc) 
	{
		this.SentErrorEmail();		
	}
	
	private List<Account> InspectSepa()
	{
		List<AggregateResult> results = [Select SEPA_MNDID__c From Account Where SEPA_MNDID__c!=null Group By Sepa_MNDID__c Having Count(Id)>1]; 
		Set<String> sepaIds = new Set<String>();
		List<Account> accounts = new List<Account>();
		for(AggregateResult res: results)
		{
			sepaIds.add(String.valueOf(res.get('SEPA_MNDID__c')));
		}
		if(sepaIds.size()>0)
		{
			accounts = [Select ID, SEPA_MNDID__c From Account Where SEPA_MNDID__c=: sepaIds Order By SEPA_MNDID__c DESC];
		}
		return accounts;
	}
	
	private List<Account> InspectDebtorNumber()
	{
		List<AggregateResult> results = [Select Debtor_Number__c From Account Where Debtor_Number__c!=null Group By Debtor_Number__c Having Count(Id)>1]; 
		Set<String> debtorNumbers = new Set<String>();
		List<Account> accounts = new List<Account>();
		for(AggregateResult res: results)
		{
			debtorNumbers.add(String.valueOf(res.get('Debtor_Number__c')));
		}
		if(debtorNumbers.size()>0)
		{
			accounts = [Select ID, Debtor_Number__c From Account Where Debtor_Number__c=: debtorNumbers Order By Debtor_Number__c DESC];
		}
		return accounts;
	}
	
	private List<Account> InspectAccountNumber()
	{
		List<AggregateResult> results = [Select AccountNumber From Account Where AccountNumber!=null Group By AccountNumber Having Count(Id)>1]; 
		Set<String> accNumbers = new Set<String>();
		List<Account> accounts = new List<Account>();
		for(AggregateResult res: results)
		{
			accNumbers.add(String.valueOf(res.get('AccountNumber')));
		}
		if(accNumbers.size()>0)
		{
			accounts = [Select ID, AccountNumber From Account Where AccountNumber=: accNumbers Order By AccountNumber DESC];
		}
		return accounts;
	}
	
	private void SentErrorEmail()
	{
		String emailMessage = '';
		List<Account> sepaErrors = this.InspectSepa();
		List<Account> debtorErrors = this.InspectDebtorNumber();
		List<Account> accountErrors = this.InspectAccountNumber();
		String salesFroceLink ='https://eu1.salesforce.com/';
		if(sepaErrors.size()>0||debtorErrors.size()>0||accountErrors.size()>0)
		{
			emailMessage = '<h3>We have a duplicated values for next account: </h3>';
			if(sepaErrors.size()>0)
			{
				emailMessage +='<div style="margin-bottom:10px;"><table width="600px" bordercolor="black" border = "1"><tr><td colspan="2" align="center">Sepa Mandate ID duplicates</td></tr><tr><td width="500px">Link to Account</td><td>Sepa Mandate ID</td></tr>';
				for(Account acc: sepaErrors)
				{
					emailMessage+='<tr><td>'+salesFroceLink+acc.Id+'</td><td>'+acc.SEPA_MNDID__c+'</td></tr>';
				}
				emailMessage +='</table></div>';
			}
			if(debtorErrors.size()>0)
			{
				emailMessage +='<div style="margin-bottom:10px;"><table width="600px" bordercolor="black" border = "1"><tr><td colspan="2" align="center">Debtor Number duplicates</td></tr><tr><td width="500px">Link to Account</td><td>Sepa Mandate ID</td></tr>';
				for(Account acc: debtorErrors)
				{
					emailMessage+='<tr><td>'+salesFroceLink+acc.Id+'</td><td>'+acc.Debtor_Number__c+'</td></tr>';
				}
				emailMessage +='</table></div>';
			}
			if(accountErrors.size()>0)
			{
				emailMessage +='<div style="margin-bottom:10px;"><table width="600px" bordercolor="black" border = "1"><tr><td colspan="2" align="center">Account Number duplicates</td></tr><tr><td width="500px">Link to Account</td><td>Sepa Mandate ID</td></tr>';
				for(Account acc: accountErrors)
				{
					emailMessage+='<tr><td>'+salesFroceLink+acc.Id+'</td><td>'+acc.AccountNumber+'</td></tr>';
				}
				emailMessage +='</table></div>';
			}
			Map<String,General_Settings__c> settings = General_Settings__c.getAll();
			List<String> addresses = new List<String>();
			for(General_Settings__c s :settings.values())
			{
				addresses.add(s.Email__c);
			}
			TLR_SendEmailHelper.SendEmailWithHtmlBodyNoReply(emailMessage, 'Automatic System', 'Duplicates', addresses);
		}
	}
}