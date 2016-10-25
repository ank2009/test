public with sharing class TLR_SubsCurrentFeeHelper 
{
	public static Boolean invoiceLevelValidation(String invoiceLevel, String accountLevel)
	{ 
		if( String.isNotEmpty(invoiceLevel) && String.isNotEmpty(accountLevel))
		{
			if(	accountLevel == 'International' && (invoiceLevel == 'National' || invoiceLevel == 'Company' || invoiceLevel == 'Site') ||
				accountLevel == 'National' && (invoiceLevel == 'Company' || invoiceLevel == 'Site') ||
				accountLevel == 'Company' && invoiceLevel == 'Site')
			{
				return false;
			}
		}
		return true;
	}
}