public class QueryReportExt
{
    public class UserProfileInfo
    {
        public ID id                 {get; set;}
        public String name           {get; set;}
        public ID idContact          {get; set;}
        public ID idAccountSub       {get; set;}
        public String accKnd         {get; set;}
        public String status		 {get; set;}
        public List<String> accRoles;
        
        public UserProfileInfo(User_Profile__c u, List<User_Profile_Service__c> upServices)
        {
            id           = u.Id;
            name		 = u.Name;
            idContact    = u.Contact__c;
            idAccountSub = u.Provisioning__r.Subscription__r.Contract__r.AccountId;
            accKnd       = u.Provisioning__r.Subscription__r.Access_Kind__c;
            status		 = u.Status__c;
            
            accRoles = new List<String>();
            if (upServices != null)
            {
	            for (User_Profile_Service__c ups : upServices)
	            {
	            	if (ups.Provisioning_Service__r.Service__r.Access_Roles__c != null)
	                	accRoles.add(ups.Provisioning_Service__r.Service__r.Access_Roles__c.replace('$AK$', accKnd));
	                
	                if (ups.User_Profile_Service_Attributes__r != null)
	                {
	                	for (User_Profile_Service_Attribute__c upsa : ups.User_Profile_Service_Attributes__r)
	                	{
	                		if (upsa.Provisioning_Service_Attribute__r.Service_Attribute__r.Access_Role__c != null)
	                    		accRoles.add(upsa.Provisioning_Service_Attribute__r.Service_Attribute__r.Access_Role__c.replace('$AK$', accKnd));
	                	}
	                }
	            }
            }
        }
        
        public List<String> getAccRoles()
        {
        	return accRoles;
        }
    }
    
    
    public List<UserProfileInfo> infos;
    public Boolean data {get; set;}
    public String rows {get; set;}
    public String minId {get; set;}
    public String maxId {get; set;}
    
    public QueryReportExt() 
    {
    	data = false;
    }
    
    public void Generate()
    {
    	ID recordTypeIdUp = Schema.getGlobalDescribe().get('User_Profile__c').getDescribe().getRecordTypeInfosByName().get('TLR User Profile').getRecordTypeId();
    	
    	Map<ID, User_Profile__c> userProfiles = new Map<ID, User_Profile__c>([SELECT Id, Private_Exchange_ID__c, PIA_Interface__c, Name,
							        										 	     Contact__c, User_PUG_Name__c, Status__c,
							        										 		 Provisioning__r.Subscription__r.Access_Kind__c,
							        										 		 Provisioning__r.Subscription__r.Contract__r.AccountId
							        								  		  FROM User_Profile__c
							        								  		  WHERE Name >= :minId AND Name <= :maxId
							        								  		  AND RecordTypeId = :recordTypeIdUp
							        								  		  ORDER BY Name ASC]);
		
		List<ID> idUps = new List<ID>();
		idUps.addAll(userProfiles.keySet());
		idUps.sort();					        								  		  
        								  
        List<User_Profile_Service__c> upServices = [SELECT Provisioning_Service__r.Service__r.Access_Roles__c, User_Profile__c, Suspension_Start_Date__c, Suspension_End_Date__c,
                                                   		   (SELECT Provisioning_Service_Attribute__r.Service_Attribute__r.Access_Role__c, Suspension_Start_Date__c, Suspension_End_Date__c
                                                    		FROM User_Profile_Service_Attributes__r
                                                    		WHERE Suspension_Start_Date__c = null 
                                                    			  OR Suspension_Start_Date__c > :Date.Today() 
                                                    			  OR Suspension_End_Date__c < :Date.Today())
                                                    FROM User_Profile_Service__c
                                                    WHERE User_Profile__c IN :userProfiles.keySet()
                                                    AND (Suspension_Start_Date__c = null 
                                                    	 OR Suspension_Start_Date__c > :Date.Today() 
                                                    	 OR Suspension_End_Date__c < :Date.Today())];
                                                    
        Map<ID, List<User_Profile_Service__c>> mappingUp = new Map<ID, List<User_Profile_Service__c>>();
        
        for (User_Profile_Service__c ups : upServices)
        {
        	if (mappingUp.get(ups.User_Profile__c) == null)
	        	mappingUp.put(ups.User_Profile__c, new List<User_Profile_Service__c>());
	            
	            mappingUp.get(ups.User_Profile__c).add(ups);
        }
        
        infos = new List<UserProfileInfo>();
        
        for (ID up : idUps)
        	infos.add(new UserProfileInfo(userProfiles.get(up), mappingUp.get(up)));
        	
        data = (infos.size() > 0);
        rows = '' + userProfiles.keySet() + '-' + (mappingUp.Values() ==  null ? '0' : mappingUp.Values().size().format());
    }
    
    public List<UserProfileInfo> getInfos()
    {
    	return infos;
    }
}