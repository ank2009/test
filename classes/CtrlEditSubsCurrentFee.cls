public with sharing class CtrlEditSubsCurrentFee 
{ 
    public Subs_Current_Fee__c scf {get; set;}
    public Boolean error {get; set;}
    public String ContractErrorMsg = 'Invoice Level must always be greater than or equal with Account Level!';
    public CtrlEditSubsCurrentFee(ApexPages.StandardController controller){
        
        ID scfId = System.currentPagereference().getParameters().get('id');
        this.scf = [SELECT  Id, Name, Account__c, Case__c, End_Date__c, Notes__c, Price__c, 
                           Start_Date__c, Subs_Package_And_Fee__c, Subscription_Line_Item__c, 
                           Subscription__c, User_Profile__c,Account_Number_Formula__c, Account_Level_Formula__c, Invoice_Level_Formula__c, Quantity__c
                           FROM Subs_Current_Fee__c
                           WHERE Id =: scfId ];
        error = false;
    }    

    public PageReference init(){   
        Subscription__c sub = [SELECT Start_Date__c, CurrencyIsoCode FROM Subscription__c WHERE Id = :this.scf.Subscription__c];
        try{
            update sub;
        }catch (DMLException e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Insufficient Privileges!')); 
            error = true;
        }
        this.scf.CurrencyIsoCode = sub.CurrencyIsoCode;
        return null;
    }        
    /*
    * @ Author      :   HCL Technology
    * @ Description :   save current fee
    * @ date        :   25/10/2012
    * refactored by Anton Solovyev at 9/23/2013. Leaved old code in comments. Terrible exceptions handling.
    */    
	public PageReference Save()
	{
		try
		{
			if (this.scf.Subscription_Line_Item__c != null && this.scf.Subs_Package_And_Fee__c == null)
			{
				Subscription_Line_Item__c  subsLineItem = [SELECT Id, Name FROM Subscription_Line_Item__c WHERE Id =: this.scf.Subscription_Line_Item__c ];
				this.scf.Name = subsLineItem.Name;
				if(invoiceLevelValidation(this.scf))
				{
					/*try
					{*/
						update this.scf;
					/*}
					catch(Exception ex)
					{ 
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage())); 
						return null;
					}*/
				}
				else
				{
					throw new Generic.StandardException(ContractErrorMsg);
					//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ContractErrorMsg));
					//return null;
				}
			}
			else if ((this.scf.Subscription_Line_Item__c == null && this.scf.Subs_Package_And_Fee__c != null)||
				(this.scf.Subscription_Line_Item__c != null && this.scf.Subs_Package_And_Fee__c != null)) 
			{
				system.debug('subscription package and fees not null--------------'+this.scf.Subs_Package_And_Fee__c);
				Subs_Package_And_Fee__c subsPackAndFee = [SELECT Name,isUser__c FROM Subs_Package_And_Fee__c WHERE Id =: this.scf.Subs_Package_And_Fee__c ];
				this.scf.Name = subsPackAndFee.Name;
				List<User_Profile__c> userProfileLst;
				if (this.scf.User_Profile__c!=null)
				{
					userProfileLst = [
						Select Contact__r.Username__c, Contact__c 
						From User_Profile__c 
						WHERE Id =: this.scf.User_Profile__c 
						limit 1
					];
					system.debug('scf.Subs_Package_And_Fee__r.isUser__c---------------'+userProfileLst[0].Contact__r.Username__c);
					system.debug('this.scf.Username__c--###############'+subsPackAndFee.isUser__c);
					if (!userProfileLst.isEmpty())
					{
						if (subsPackAndFee.isUser__c=='true' && (userProfileLst[0].Contact__r.Username__c==null ||userProfileLst[0].Contact__r.Username__c==''))
						{// Added for CR 
							//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'User Name is Mandatory.Please select user profile to Populate user name.'));
							//return null;
							throw new Generic.StandardException('User Name is Mandatory.Please select user profile to Populate user name.');
						} 
						else 
						{
							system.debug('Insert scf--------------');
							if(invoiceLevelValidation(this.scf))
								update this.scf;
							else
							{
								throw new Generic.StandardException(ContractErrorMsg);
								//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ContractErrorMsg));
								//return null;
							}
						}
					}
				}
				else if (subsPackAndFee.isUser__c=='true')
				{
					system.debug('inside else if profile is null and isUser is true-------->');
					//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'User Name is Mandatory.Please select user profile to Populate user name.'));
					//return null;
					throw new Generic.StandardException('User Name is Mandatory.Please select user profile to Populate user name.');                                        
				}
				else if (subsPackAndFee.isUser__c=='false')
				{
					system.debug('inside else when profile is null and isUser is false------>');
					if(invoiceLevelValidation(this.scf))
						update this.scf;
					else
					{
						throw new Generic.StandardException(ContractErrorMsg);
						//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ContractErrorMsg));
						//return null;
					}
				}
			}
			else if (this.scf.Subscription_Line_Item__c == null && this.scf.Subs_Package_And_Fee__c == null)
			{
				system.debug('Sub line item and sub package both are blank !!!!!!');
				throw new Generic.StandardException('At least one of the two fields Subscription Line Item or Subs Package And Fee must be filled');
				//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'At least one of the two fields Subscription Line Item or Subs Package And Fee must be filled'));
				//return null;
			}
		}
		catch (DmlException e) // to handle validation and trigger errors
		{
			integer errorsCount = e.getNumDml();
			for(integer i = 0; i< errorsCount;i++)
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getDmlMessage(i)));
			return null;
		}
		catch (Exception e)
		{
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'At least one of the two fields Subscription Line Item or Subs Package And Fee must be filled'));
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage()));
			error = true;
			return null;
		}
		return (Utilities.Redirect(this.scf.Subscription__c));
	}
	
	public Boolean invoiceLevelValidation(Subs_Current_Fee__c objSubsCurrentFee){
      Boolean returnFlag = true;     
	  String invoiceLevel = objSubsCurrentFee.Invoice_Level_Formula__c;
	  String accountLevel = objSubsCurrentFee.Account_Level_Formula__c;
		if(objSubsCurrentFee != null && objSubsCurrentFee.User_Profile__c == null && invoiceLevel != null && accountLevel != null){ 

			if( accountLevel == 'International' && (invoiceLevel == 'National' || invoiceLevel == 'Company' || invoiceLevel == 'Site') ||
				accountLevel == 'National' && (invoiceLevel == 'Company' || invoiceLevel == 'Site') ||
				accountLevel == 'Company' && invoiceLevel == 'Site'){
				System.debug('Contract Level will be higher than Account Level!--->');
				returnFlag = false;				
			} 
		}		
    return returnFlag;  
   } 

    public PageReference Cancel() 
    {
        return (Utilities.Redirect(this.scf.Id));
    }

}