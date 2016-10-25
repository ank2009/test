global public with sharing class EWelcomePagesCampaignManagement {
    /* =============================================================================================
    // Input object definition    
    ============================================================================================= */
    global public class OpenedCampaignByCountryInput
    {       
        webservice public String AppliCode;
        webservice public String CountryCode;
    }
    
    global public class OpenedCampaignByUserInput
    {
        webservice public String Login;
    }
    /* =============================================================================================
    // Output object definition    
    ============================================================================================= */
    global public class OpenedCampaignByCountryOutput
    {       
        webservice public String Error = '';
        webservice public Integer ReturnCode = 0;
        webservice public List<String> campaignIds = new List<string>();
    }
    
    global public class OpenedCampaignByUserOutput
    {
        webservice public String Error = '';
        webservice public Integer ReturnCode = 0;
        webservice public List<String> campaignIds = new List<string>();
    }
    /* =============================================================================================
    // Internals methods    
    ============================================================================================= */


    /* =============================================================================================
    // Webservices methods    
    ============================================================================================= */
    
    webservice static OpenedCampaignByCountryOutput GetOpenedCampaignByCountry(OpenedCampaignByCountryInput input)
    {
        //Return a set of WLP active campaigns for a country 
        OpenedCampaignByCountryOutput output = new OpenedCampaignByCountryOutput();
        Savepoint sp = Database.setSavepoint();
        System.debug(input);
        try{
        		List<CampaignMember> cpMembers;
            	//Application__c cpAppliCode;
            	pw_cc__CountryObject__c cpOrganization;
                /*try
                {
                	//cpAppliCode=[select Value__c from Configuration_Parameter__c where Configuration_Parameter__c.Key__c=:input.AppliCode and Configuration_Parameter__c.Type__c='Application'];
                	cpAppliCode = [select Access_Kind__c from Application__c where Access_Kind__c =:input.AppliCode];
                	system.debug('## >>> AppliCode : '+cpAppliCode);
                }
                catch(Exception ex)
                {
                    Generic.StandardException stex = new Generic.StandardException();
                    stex.ReturnCode=4;
                    stex.setMessage('getOpenedCampaignByUser : Error in Application loading : '+ex.getMessage());
                    stex.Error='getOpenedCampaignByUser : Error in Application parameters loading : '+ex.getMessage();
                    throw stex;  
                }*/
                
				try
                {
					//cpOrganization=[select Value__c from Configuration_Parameter__c where Configuration_Parameter__c.Key__c=:input.CountryCode and Configuration_Parameter__c.Type__c='Country Code'];
					cpOrganization = [Select p.Name,p.Primary_Org_2_Area_c__c,p.Primary_Org_3_TLR_Region_c__c,p.Primary_Org_4_Country_c__c From pw_cc__CountryObject__c p where p.pw_cc__IsoCode_2__c=:input.CountryCode];
					system.debug('## >>> Organization : '+cpOrganization);
                }
                catch(Exception ex)
                {
                    Generic.StandardException stex = new Generic.StandardException();
                    stex.ReturnCode=2;
                    stex.setMessage('OpenedCampaignByCountryOutput : Error in organization parameters loading : '+ex.getMessage());
                    stex.Error='OpenedCampaignByCountryOutput : Error in organization parameters loading : '+ex.getMessage();
                    throw stex;  
                }  
                
				try
                {
            		List<Campaign> cps=[
            		select c.Id,c.Name from Campaign c
            		where 
            			c.Application__c=:input.AppliCode and
            			//c.Organization__c =:cpOrganization.Name and 
            			c.Organization__c in(:cpOrganization.Name,:cpOrganization.Primary_Org_2_Area_c__c,:cpOrganization.Primary_Org_3_TLR_Region_c__c,:cpOrganization.Primary_Org_4_Country_c__c) and 
            			(c.EndDate=null or c.EndDate>=:Date.today()) and 
            			c.Type='Web - eWelcome Pages' and 
            			c.Status='Active'
            		];
            		for(Campaign cp:cps)
            		{            			
            			output.campaignIds.Add(cp.Id+';'+cp.Name);
                	}
                }
                catch(Exception ex)
                {
                    Generic.StandardException stex = new Generic.StandardException();
                    stex.ReturnCode=3;
                    stex.setMessage('OpenedCampaignByCountryOutput : Error in Campaign loading : '+ex.getMessage());
                    stex.Error='OpenedCampaignByCountryOutput : Error in Campaign loading : '+ex.getMessage();
                    throw stex;  
                }  
                
        }catch(Generic.StandardException sex)
        {
            output.returnCode = sex.ReturnCode;
            output.error = sex.Error;
            System.debug('## '+sex.getMessage());
            Database.rollback(sp);
        }catch(Exception ex){
            output.returnCode = 1;
            output.error = ex.getMessage();
            System.debug('## '+ex.getMessage());
            Database.rollback(sp);
        }
        return output;
    }   

    webservice static OpenedCampaignByUserOutput GetOpenedCampaignByUser(OpenedCampaignByUserInput input)
    {
        //Return a set of WLP active campaigns for an country
        OpenedCampaignByUserOutput output = new OpenedCampaignByUserOutput();
        Savepoint sp = Database.setSavepoint();
        try{
        		Contact currentContact;
        		List<CampaignMember> cpMembers;
        		
                try
                {
                    currentContact = [select Id from Contact where Username__c=:input.Login];
                }
                catch(Exception ex)
                {
                    Generic.StandardException stex = new Generic.StandardException();
                    stex.ReturnCode=2;
                    stex.setMessage('getOpenedCampaignByUser : Error in Contact loading : '+ex.getMessage());
                    stex.Error='getOpenedCampaignByUser : Error in Contact loading : '+ex.getMessage();
                    throw stex;  
                }
                
                try
                {
                    cpMembers = [select Id,CampaignId from CampaignMember where ContactId=:currentContact.Id];
                }
                catch(Exception ex)
                {
                    Generic.StandardException stex = new Generic.StandardException();
                    stex.ReturnCode=3;
                    stex.setMessage('getOpenedCampaignByUser : Error in Contact Members loading : '+ex.getMessage());
                    stex.Error='getOpenedCampaignByUser : Error in Contact Members loading : '+ex.getMessage();
                    throw stex;  
                }
                
                try
                {
                	if(cpMembers.size()>0)
                	{
	                	for(CampaignMember cpMember:cpMembers)
	                	{
	                		System.debug('>>> Campaign Id : '+cpMember.CampaignId);
	                		List<Campaign> cp=[select Id,Name from Campaign where Id=:cpMember.CampaignId and Campaign.EndDate>=:Date.today() and Campaign.Type='Web - eWelcome Pages' and Campaign.Status='Active'];
	                		if(cp.size()>0)
	                		{
	                			System.debug('>>> Add Campaign : '+cp[0].Id);
	                			output.campaignIds.Add(cp[0].Id+';'+cp[0].Name);
	                		}
	                	}
                	}
                }
                catch(Exception ex)
                {
                    Generic.StandardException stex = new Generic.StandardException();
                    stex.ReturnCode=4;
                    stex.setMessage('getOpenedCampaignByUser : Error in Campaign loading : '+ex.getMessage());
                    stex.Error='getOpenedCampaignByUser : Error in Campaign loading : '+ex.getMessage();
                    throw stex;  
                }           
        }catch(Generic.StandardException sex)
        {
            output.returnCode = sex.ReturnCode;
            output.error = sex.Error;
            System.debug('## '+sex.getMessage());
            Database.rollback(sp);
        }catch(Exception ex){
            output.returnCode = 1;
            output.error = ex.getMessage();
            System.debug('## '+ex.getMessage());
            Database.rollback(sp);
        }
        return output;
    }  
}