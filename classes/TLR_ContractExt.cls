/*
	controller extension class for Contract
*/
public with sharing class TLR_ContractExt 
{
	public Contract contract { get; set; }
	
	public TLR_ContractExt(ApexPages.StandardController stdController)
	{
		contract = (Contract)stdController.getRecord();
	}
	
	
}