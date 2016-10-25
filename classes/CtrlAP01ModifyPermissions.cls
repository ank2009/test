/*
* @ Description :- This class is used to modify permission of products.
                                 User can select the service and service attributes with respective product.
                                  Sending request to IAM system and update the user name.
* @ Author      :- Atos
* @ Date        :- 11/01/2012
**/
public with sharing class CtrlAP01ModifyPermissions 
{
    // ------------- //
    // Inner Classes //
    // ------------- //
    public class WrapperService
    {
        public ID      id        {get; set;}
        public String  title     {get; set;}
        public Boolean checked   {get; set;}
        public Boolean activated {get; set;}
        public List<WrapperServiceAttr> serviceAttr {get; set;}

        public WrapperService(String t, ID idServ)
        {
            id          = idServ;
            title       = t;
            checked     = false;
            activated   = true;
            serviceAttr = new List<WrapperServiceAttr>();
        }
        
        public void apply()
        {
            if (!checked)
            {
                for (WrapperServiceAttr wsa : serviceAttr)
                    wsa.checked = false;
            }
        }
    }
    
    public class WrapperServiceAttr
    {
        public ID             id        {get; set;}
        public String         title     {get; set;}
        public Boolean        checked   {get; set;}
        public Boolean        activated {get; set;}
        public WrapperService parent;

        public WrapperServiceAttr(String t, ID idServAttr, WrapperService p)
        {
            id          = idServAttr;
            title       = t;
            checked     = false;
            activated   = true;
            parent      = p;
        }
        
        public void apply()
        {
            if (checked)
                parent.checked = true;
        }
    }
    
    public class WrapperPackage
    {
        public ID                   id        {get; set;}
        public String               title     {get; set;}
        public Boolean              checked   {get; set;}
        public List<WrapperPackage> parent;

        public WrapperPackage(String t, ID idPack, List<WrapperPackage> p)
        {
            id      = idPack;
            title   = t;
            checked = false;
            parent  = p;
        }
        
        public void apply()
        {
            if (checked)
            {
                for (WrapperPackage wp : parent)
                    wp.checked = false;
            }
            
            checked = true;
        }
    }
    
    public class WrapperPermissions
    {
        public String               cug      {get; set;}
        public List<String>         pugs     {get; set;}
        public String               pia      {get; set;}
         // Code added for WKTS Bridge functionality
        public List<String>         profiles {get; set;}
        public List<WrapperService> services {get; set;}
        public List<WrapperPackage> packages {get; set;}
        
        public WrapperPermissions(String idCUG, List<String> lstPUGs, String idPIA,List<String> lstProfiles, List<WrapperService> headersServ, List<WrapperPackage> headersPack)
        {
            // CUG / PUGs / PIA  / WKTS Profiles
            cug  = idCUG;
            
            pugs = new List<String>();
            if (lstPUGs != null)
                pugs.addAll(lstPUGs);
             
            profiles = new List<String>();
            if (lstProfiles != null)
                profiles.addAll(lstProfiles);   
                
            pia = idPIA;
            
            // Services / Service Attributes
            services = new List<WrapperService>();
            for (WrapperService header : headersServ)
            {
                services.add(new WrapperService(header.title, header.id));
                
                Integer lastIndex = services.size() - 1;
                for (WrapperServiceAttr child : header.serviceAttr)
                    services[lastIndex].serviceAttr.add(new WrapperServiceAttr(child.title, child.id, services[lastIndex]));
            }
            
            // Package
            packages= new List<WrapperPackage>();
            for (WrapperPackage header : headersPack)
                packages.add(new WrapperPackage(header.title, header.id, packages));
        }
    }
    
    public class WrapperUser
    {
        public String  firstName    {get; set;}
        public String  lastName     {get; set;}
        
        public String  chosenRT     {get; set;}
        public Boolean userSelected {get; set;}
        public Boolean testUser     {get; set;}
        public Boolean activated    {get; set;}
        
        public WrapperPermissions currentSelection;
        public WrapperPermissions previousSelection;
        
        private CtrlAP01ModifyPermissions parent;
        
        public WrapperUser(String fn, String ln, String cug, String pugs, String pia,String profiles, CtrlAP01ModifyPermissions p)
        {
            firstName = fn;
            lastName  = ln;
            
            List<String> lstPUGs = ((pugs == null) || (pugs == '')) ? null : pugs.split(';');
            
            List<String> lstProfiles = ((profiles == null) || (profiles == '')) ? null : profiles.split(';');
            
            currentSelection  = new WrapperPermissions(cug, lstPUGs, pia,lstProfiles, p.serviceHeaders, p.packageHeaders);
            previousSelection = new WrapperPermissions(cug, lstPUGs, pia,lstProfiles, p.serviceHeaders, p.packageHeaders);
            
            userSelected = false;
            testUser     = false;
            activated    = false;
            parent       = p;
        }
        
        public WrapperPermissions getCurrentSelection()
        {
            return currentSelection;
        }
        
        public WrapperPermissions getPreviousSelection()
        {
            return previousSelection;
        }
        
        public void applyRT()
        {
            WrapperPermissions template = parent.defRightsTemplate.get(chosenRT);
            
            currentSelection.cug  = template.cug;
            currentSelection.pugs = template.pugs;
            currentSelection.pia  = template.pia;
            currentSelection.profiles  = template.profiles;
            
            for (Integer i = 0; i < template.services.size(); i++)
            {
                if (currentSelection.services[i].activated)
                    currentSelection.services[i].checked = template.services[i].checked;
                
                for (Integer j = 0; j < template.services[i].serviceAttr.size(); j++)
                {
                    if (currentSelection.services[i].serviceAttr[j].activated)
                        currentSelection.services[i].serviceAttr[j].checked = template.services[i].serviceAttr[j].checked;
                }
            }
        }
    }


    // --------- //
    // Variables //
    // --------- //
    
    ////////////////////
    // Filtering page //
    ////////////////////
    public Boolean usersToFilter {get; set;}
    public Integer nbUsersMax;
    
    List<WrapperService> serviceHeaders;
    List<WrapperPackage> packageHeaders;
    public Boolean noPackages {get; set;}
    public Integer heightHeaders {get; set;}
    
    private final Provisioning__c prov;
    
    public Boolean isHQProfile    {get; set;}
    public Boolean isAdminProfile {get; set;}
    
    /////////////////////////////
    // Modify Permissions page //
    /////////////////////////////
    List<ID> listAccountToScan;
    String contactNameMinToScan;
    String contactNameMaxToScan;
    
    List<User_Profile__c> userProfiles;
    public List<ID> userProfileIds;
    public List<WrapperUser> users;
    Map<ID, List<User_Profile_Service__c>> mapIdUpServ;
    List<SelectOption> rightsTemplates;
    
    public String  rightsTemplate {get; set;}
    public Boolean selAllUsers    {get; set;}
    public Boolean error {get; set;}
    public Boolean error2 {get; set;}
    
    public Map<ID, WrapperPermissions> defRightsTemplate;
    public Integer serviceToApply     {get; set;}
    public Integer serviceAttrToApply {get; set;}

    List<SelectOption> availableCUGs;
    List<SelectOption> availablePUGs;
    List<SelectOption> availablePIAs;
    List<SelectOption> availableBridgeProfiles;
    
    public String       selectedCUG  {get; set;}
    public List<String> selectedPUGs {get; set;}
    public String       selectedPIA  {get; set;}
    public List<String> selectedBridgeProfiles {get;set;}
    String idCUGOpen    = '';
    String idPIADefault = '';
    
    Boolean tooManyUsers = false;
    
    // ------- //
    // Methods //
    // ------- //
    
    //*********************//
    //------ Generic ------//
    //*********************//
    
     public List<SelectOption> getAvailableBridgeProfiles(){
        return availableBridgeProfiles;
    }
    
    public CtrlAP01ModifyPermissions(ApexPages.StandardController controller) 
    {
        Id provId = System.currentPagereference().getParameters().get('id');
        this.prov = [SELECT Id, Subscription__c, Subscription__r.CUG_allowed__c, CurrencyIsoCode FROM Provisioning__c WHERE id = :provId];
    }
    
    public PageReference Cancel() 
    {
        if (System.currentPagereference().getParameters().get('user') == 'all')
            return (Utilities.Redirect(this.prov.Id));
        else 
            return (Utilities.Redirect(System.currentPagereference().getParameters().get('user')));
    }
    
    ////////////////////
    // Filtering page //
    ////////////////////
    
	 /*
	 @ Description: This is the first method which will call from the page
	*/
	public PageReference init0()
	{
		try
		{
			String cur = this.prov.CurrencyIsoCode;
			this.prov.CurrencyIsoCode = cur;
			update this.prov;
		}
		catch (System.DmlException e)
		{
			error = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Insufficient Privileges!'));
			return null;
		}
		catch (System.Exception e)
		{
			error = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Unknowh exception!'));
			return null;
		}
		
		usersToFilter = true;
		
		TLRHQProfileSettings__c profileCS = TLRHQProfileSettings__c.getValues('TLR HQ');
		AdminProfileSettings__c adminCS   = AdminProfileSettings__c.getValues('SysAdmin');
		
		isHQProfile     = (UserInfo.getProfileId() == profileCS.Profile_ID__c);
		isAdminProfile  = (UserInfo.getProfileId() == adminCS.Profile_ID__c);
		
		heightHeaders = (isHQProfile || isAdminProfile) ? 54 : 36;
		
		if(serviceHeaders == null)
		{
			serviceHeaders = new List<WrapperService>();
			List<Provisioning_Service__c> provServices = [
				SELECT
					Id, Service__c, Service__r.Name, 
						(SELECT Id, Service_Attribute__c, Service_Attribute__r.Name FROM Provisioning_Service_Attributes__r)
				FROM Provisioning_Service__c
				WHERE Provisioning__c = :prov.Id
			];
			
			for (Provisioning_Service__c provService : provServices)
			{
				serviceHeaders.add(new WrapperService(provService.Service__r.Name, provService.Id));
				heightHeaders = Math.max(heightHeaders, (provService.Service__r.Name != null ? provService.Service__r.Name.length() : 0) * 6);
				
				if (provService.Provisioning_Service_Attributes__r.size() > 0)
				{
					Integer lastIndex = serviceHeaders.size() - 1;
					
					for (Provisioning_Service_Attribute__c servattr : provService.Provisioning_Service_Attributes__r)
					{
						serviceHeaders[lastIndex].serviceAttr.add(new WrapperServiceAttr(servattr.Service_Attribute__r.Name, servattr.id, serviceHeaders[lastIndex]));
						heightHeaders = Math.max(heightHeaders, (servattr.Service_Attribute__r.Name != null ? (servattr.Service_Attribute__r.Name.length() + 10) : 10) * 6);
					}
				}
			} // for all prov services
		} // if serviceHeaders == null
		
		if (packageHeaders == null)
		{
			packageHeaders = new List<WrapperPackage>();
			
			List<Subs_Package_And_Fee__c> packages = [SELECT Id, Name, Type__c FROM Subs_Package_And_Fee__c WHERE Subscription__c = :this.prov.Subscription__c AND Type__c = 'Package'];
			
			for (Subs_Package_And_Fee__c pack : packages)
			{
				packageHeaders.add(new WrapperPackage(pack.Name, pack.id, packageHeaders));
				heightHeaders = Math.max(heightHeaders, (pack.Name != null ? pack.Name.length() : 0) * 6);
			}
			noPackages = (packageHeaders.size() == 0);
		}
		System.debug('packageHeaders.size() = ' + packageHeaders.size());
		System.debug('serviceHeaders.size() = ' + serviceHeaders.size());
		nbUsersMax = (Integer)(81.45 / (packageHeaders.size() * 0.243 + serviceHeaders.size() * 0.083));
		System.debug('nbUsersMax = ' + nbUsersMax);
		//ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, 'nbUsersMax: ' + nbUsersMax));
		
		String userParam = System.currentPagereference().getParameters().get('user');
		
		if (lstAccountForPreFiltering == null)
		{
			// Account Ids list from User Profiles
			List<User_Profile__c> userProfilesUnfiltered;
			if (userParam == 'all')
				userProfilesUnfiltered = [SELECT Contact__r.AccountId FROM User_Profile__c WHERE Provisioning__c = :this.prov.Id];
			else
				userProfilesUnfiltered = [SELECT Contact__r.AccountId FROM User_Profile__c WHERE Provisioning__c = :this.prov.Id AND Id = :userParam];
			
			Set<ID> accnts = new Set<ID>();
			for (User_Profile__c up : userProfilesUnfiltered)
				accnts.add(up.Contact__r.AccountId);
			
			lstAccountForPreFiltering = [
				SELECT Id, Name, Debtor_Number__c, AccountNumber, Teleroute_Number__c, BillingCountry, BillingCity
				FROM Account 
				WHERE Id IN :accnts 
				LIMIT 1000
			];
		}
        
        if (lstAccountForPreFiltering.size() > 0)
        {
            List<ID> filteredLstIds = new List<ID>();
            for (Account a : lstAccountForPreFiltering)
                filteredLstIds.add(a.Id);
                
            Integer cnt = countUsers(filteredLstIds, '', '');
            
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, 'Account List: ' + filteredLstIds));
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, 'count: ' + count));
            
            if (cnt > nbUsersMax && userParam == 'all')
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,
                                    'Too many users (' + cnt + ') have been found in this provisioning using the following filtering criteria. ' +
                                    'The maximum number of users that can be displayed in a single page for this provisioning is ' + nbUsersMax + '. ' + 
                                    'Please filter list before it can be displayed.'));
                                 
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, 'Account List: ' + lstAccountForPreFiltering));
            
                refreshFilterOptions();
                
                usersToFilter = true;
                
                return null;
            }
            else
            {
                usersToFilter = false;
                
                listAccountToScan = new List<ID>();
                listAccountToScan.addAll(filteredLstIds);
                
                contactNameMinToScan = '';
                contactNameMaxToScan = '';
                
                init();
                
                return null;
            }
        }
        else
        {
            usersToFilter = true;
            error = true;
            
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, 'No user have been found in this provisioning.'));
            
            return null;
        }
        
        
    }
    
     /*
     @ Description: Apply the filter on account name, account number, teleroute number, country, product etc
    */
    public PageReference SaveFiltering()
    {
        if (nameFilteringMin != null && nameFilteringMin != '' && nameFilteringMax != null && nameFilteringMax != '' && nameFilteringMin > nameFilteringMax)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 
                                'Contact Name lowest limit must be lower than or equal to highest limit'));
                                
            return null;
        }
        
        List<Account> filteredLst = refreshFilterOptions();
        List<ID> filteredLstIds   = new List<ID>();
        
        for (Account a : filteredLst)
            filteredLstIds.add(a.Id);
        
        Integer count = countUsers(filteredLstIds, nameFilteringMin, nameFilteringMax);
        
        if (count > nbUsersMax)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 
                            'Too many users (' + count + ') have been found in this provisioning using the following filtering criteria. ' +
                            'The maximum number of users that can be displayed in a single page for this provisioning is ' + nbUsersMax + '. ' + 
                            'Please filter list again before it can be displayed.'));
            
            usersToFilter = true;
            
            return null;
        }
        else
        {
            if (count > 0)
            {
                usersToFilter = false;
                
                listAccountToScan = new List<ID>();
                listAccountToScan.addAll(filteredLstIds);
                
                contactNameMinToScan = nameFilteringMin;
                contactNameMaxToScan = nameFilteringMax;
                
                init();
                
                return null;
            }
            else
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 
                            'No user have been found in this provisioning using the following filtering criteria. ' +
                            'Please unfilter list before it can be displayed.'));
                            
                usersToFilter = true;
                
                return null;
            }
        }
    }
    
    /*
     @ Description: It counts the user which need to populate
    */
    private Integer countUsers(List<ID> lst, String contactNameMin, String contactNameMax)
    {
        String query = 'SELECT Id FROM User_Profile__c ' +
                       'WHERE Provisioning__c = \'' + this.prov.Id + '\' ' +
                       'AND Contact__r.AccountId IN (';
                       
        for (ID id : lst)
            query += '\'' + id + '\',';
            
        query = query.substring(0, query.length() - 1) + ') ';
                       
        if (contactNameMin != null && contactNameMin != '')
            query += ' AND Contact__r.Name >= \'' + contactNameMin + '\'';
        if (contactNameMax != null && contactNameMax != '')
            query += ' AND Contact__r.Name < \'' + contactNameMax + '\'';
        
        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, 'Query: ' + query));
        
        List<User_Profile__c> queryResult = Database.query(query);
        
        return queryResult.size();
    }
    
    /////////////////////////////
    // Modify Permissions page //
    /////////////////////////////
    
    /*
     @ Description: It sets the value on CUG, PUG, PIA, Right template etc
    */
    public PageReference init()
    {
        if (availableCUGs == null)
        {
            availableCUGs = new List<SelectOption>();

            // List creation
            if (this.prov.Subscription__r.CUG_allowed__c)
            {
                ID recordTypeId = Schema.SObjectType.User_Profile__c.getRecordTypeInfosByName().get('TLR User Profile').getRecordTypeId();
                List<String> options = PicklistDescriber.describe('User_Profile__c', recordTypeId, 'Private_Exchange_ID__c');
                for (String val : options)
                {
                    availableCUGs.add(new SelectOption(val, val));
                }
                
                /*List <Schema.PicklistEntry> vals = Schema.getGlobalDescribe().get('User_Profile__c').getDescribe().fields.getMap().get('Private_Exchange_ID__c').getDescribe().getPicklistValues();
                for (Schema.PicklistEntry val : vals)
                {
                    if (val.isActive())
                        availableCUGs.add(new SelectOption(val.getValue(), val.getLabel()));
                }*/
            }
            else
                availableCUGs.add(new SelectOption('OPEN','OPEN'));
            
            // Id Cug OPEN
            for (SelectOption s : availableCUGs)
            {
                if (s.getLabel() == 'OPEN')
                {
                    idCUGOpen = s.getValue();
                    break;
                }   
            }

            selectedCUG = idCUGOpen;
        }
        
        if (availablePUGs == null)
        {
            availablePUGs = new List<SelectOption>();
            
            List <Schema.PicklistEntry> vals = Schema.getGlobalDescribe().get('User_Profile__c').getDescribe().fields.getMap().get('User_PUG_Name__c').getDescribe().getPicklistValues();
            for (Schema.PicklistEntry val : vals)
                availablePUGs.add(new SelectOption(val.getValue(), val.getLabel()));
        }
        
        if (availablePIAs == null)
        {
            availablePIAs = new List<SelectOption>();

            // List creation
            List <Schema.PicklistEntry> vals = Schema.getGlobalDescribe().get('User_Profile__c').getDescribe().fields.getMap().get('PIA_Interface__c').getDescribe().getPicklistValues();
            for (Schema.PicklistEntry val : vals)
                availablePIAs.add(new SelectOption(val.getValue(), val.getLabel()));
            
            // Id Cug OPEN
            for (SelectOption s : availablePIAs)
            {
                if (s.getLabel() == '-1')
                {
                    idPIADefault = s.getValue();
                    break;
                }   
            }

            selectedPIA = idPIADefault;
        }
        
        
     	if (availableBridgeProfiles == null)
     	{
        	availableBridgeProfiles = new List<SelectOption>();
        	availableBridgeProfiles.add(new SelectOption('--NONE--','--NONE--'));
        	List <Schema.PicklistEntry> vals = Schema.getGlobalDescribe().get('User_Profile__c').getDescribe().fields.getMap().get('WKTS_Profiles__c').getDescribe().getPicklistValues();
            for (Schema.PicklistEntry val : vals)
            {
                if(val.getValue() != null && val.getValue() != '')
               	   availableBridgeProfiles.add(new SelectOption(val.getValue(), val.getLabel()));
            }    
        }
        
        if (rightsTemplates == null)
        {
            rightsTemplates   = new List<SelectOption>();
            defRightsTemplate = new Map<ID, WrapperPermissions>();
            
            List<Rights_Template__c> rightsTpls = [SELECT Id, Name,WKTS_Profiles__c, Default__c, Private_Exchange_ID__c,
                                                   PUG_Name__c, PIA_Interface__c FROM Rights_Template__c 
                                                   WHERE Provisioning__c = :prov.Id 
                                                   AND Status__c = 'Active' 
                                                   ORDER BY Default__c DESC];
            for (Rights_Template__c rightsTpl : rightsTpls)
            {
                rightsTemplates.add(new SelectOption(rightsTpl.Id, rightsTpl.Name));
                
                List<String> lstPUGs = ((rightsTpl.PUG_Name__c == null) || (rightsTpl.PUG_Name__c == '')) ? null : rightsTpl.PUG_Name__c.split(';');
                
                List<String> lstProfiles = ((rightsTpl.WKTS_Profiles__c == null) || (rightsTpl.WKTS_Profiles__c == '')) ? null : rightsTpl.WKTS_Profiles__c.split(';');
                
                defRightsTemplate.put(rightsTpl.Id, new WrapperPermissions(rightsTpl.Private_Exchange_ID__c, lstPUGs, rightsTpl.PIA_Interface__c, lstProfiles, serviceHeaders, packageHeaders));
                
                List<Rights_Template_Service__c> rightsTplServs = [SELECT Service__r.Name,
                                                                  (SELECT Service_Attribute__r.Name 
                                                                   FROM Rights_Template_Service_Attributes__r)
                                                                   FROM Rights_Template_Service__c 
                                                                   WHERE Rights_Template__c = :rightsTpl.Id];
                                                                   
                for (Rights_Template_Service__c rightsTplServ : rightsTplServs)
                {
                    for (WrapperService service : defRightsTemplate.get(rightsTpl.Id).services)
                    {
                        if (service.title == rightsTplServ.Service__r.Name)
                        {
                            service.checked = true;
                            
                            for (Rights_Template_Service_Attribute__c rightsTplServAttr : rightsTplServ.Rights_Template_Service_Attributes__r)
                            {
                                for (WrapperServiceAttr serviceAttr : service.serviceAttr)
                                {
                                    if (serviceAttr.title == rightsTplServAttr.Service_Attribute__r.Name)
                                    {
                                        serviceAttr.checked = true;
                                        break;
                                    }
                                }
                            }
                            
                            break;
                        }
                    }
                }
            }
        }
        
        if (users == null)
        {
            users = new List<WrapperUser>();
            
            String userParam = System.currentPagereference().getParameters().get('user');
            
            if (userParam == 'all')
            {
                String query = 'SELECT  Id, Contact__r.FirstName,WKTS_Profiles__c, Contact__r.LastName, Package_And_Fee__c, ' +
                                       'Test_login__c, Status__c, Private_Exchange_ID__c, User_PUG_Name__c, ' +
                                       'PIA_Interface__c ' +
                               'FROM User_Profile__c ' +
                               'WHERE Provisioning__c = \'' + this.prov.Id + '\' ' +
                               'AND Contact__r.AccountId IN (';
                           
                for (ID id : listAccountToScan)
                    query += '\'' + id + '\',';
                    
                query = query.substring(0, query.length() - 1) + ') ';
                               
                if (contactNameMinToScan != null && contactNameMinToScan != '')
                    query += ' AND Contact__r.Name >= \'' + contactNameMinToScan + '\'';
                if (contactNameMaxToScan != null && contactNameMaxToScan != '')
                    query += ' AND Contact__r.Name < \'' + contactNameMaxToScan + '\'';
                
                query += ' ORDER BY Contact__r.LastName ASC';
                
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, 'Query2: ' + query));
                
                userProfiles = Database.query(query);
            }
            else
                userProfiles = [SELECT Id, Contact__r.FirstName,WKTS_Profiles__c, Contact__r.LastName, Package_And_Fee__c,
                                       Test_login__c, Status__c, Private_Exchange_ID__c, User_PUG_Name__c,
                                       PIA_Interface__c
                                  FROM User_Profile__c
                                 WHERE Provisioning__c = :this.prov.Id
                                   AND Id = :userParam]; 
             
            Set<ID> idUps = new Set<ID>();
            for (User_Profile__c u : userProfiles)
                idUps.add(u.Id);
            
            // Map id user profile --> list of services / attributes
            List<User_Profile_Service__c> upServices = [SELECT Provisioning_Service__c, User_Profile__c, Provisioning_Status__c,
                                                               (SELECT Provisioning_Service_Attribute__c, Provisioning_Status__c 
                                                                FROM User_Profile_Service_Attributes__r) 
                                                          FROM User_Profile_Service__c 
                                                         WHERE User_Profile__c IN :idUps];
            
            mapIdUpServ = new Map<ID, List<User_Profile_Service__c>>();
            
            for (User_Profile_Service__c ups : upServices)
            {
                if (mapIdUpServ.get(ups.User_Profile__c) == null)
                    mapIdUpServ.put(ups.User_Profile__c, new List<User_Profile_Service__c>());
                    
                mapIdUpServ.get(ups.User_Profile__c).add(ups);
            }
            
            for (User_Profile__c u : userProfiles)
            {
                users.add(new WrapperUser(u.Contact__r.FirstName, u.Contact__r.LastName, u.Private_Exchange_ID__c, u.User_PUG_Name__c, u.PIA_Interface__c,u.WKTS_Profiles__c, this));
                
                Integer lastUser = users.size() - 1;
                
                List<User_Profile_Service__c> services = mapIdUpServ.get(u.Id);
                
                if (services != null)
                {
                    for (User_Profile_Service__c serv : services)
                    {
                        for (Integer indS = 0; indS < users[lastUser].currentSelection.services.size(); indS++)
                        {
                            if (users[lastUser].currentSelection.services[indS].id == serv.Provisioning_Service__c)
                            {
                                users[lastUser].currentSelection.services[indS].checked  = true;
                                users[lastUser].previousSelection.services[indS].checked = true;
                                
                                if (serv.Provisioning_Status__c != 'Activated')
                                {
                                    users[lastUser].currentSelection.services[indS].activated  = false;
                                    users[lastUser].previousSelection.services[indS].activated = false;
                                }
                                
                                for (User_Profile_Service_Attribute__c serviceAttribute : serv.User_Profile_Service_Attributes__r)
                                {
                                    for (Integer indSA = 0; indSA < users[lastUser].currentSelection.services[indS].serviceAttr.size(); indSA++)
                                    {
                                        if (users[lastUser].currentSelection.services[indS].serviceAttr[indSA].id == serviceAttribute.Provisioning_Service_Attribute__c)
                                        {
                                            users[lastUser].currentSelection.services[indS].serviceAttr[indSA].checked = true;
                                            users[lastUser].previousSelection.services[indS].serviceAttr[indSA].checked = true;
                                            
                                            if (serv.Provisioning_Status__c != 'Activated' || serviceAttribute.Provisioning_Status__c != 'Activated')
                                            {
                                                users[lastUser].currentSelection.services[indS].serviceAttr[indSA].activated  = false;
                                                users[lastUser].previousSelection.services[indS].serviceAttr[indSA].activated = false;
                                            }
                                            break;
                                        }
                                    }
                                }
                                
                                break;
                            }
                        }
                    }
                }
                
                if (u.Package_And_Fee__c != null)
                {
                    for (Integer indP = 0; indP < users[lastUser].currentSelection.packages.size(); indP++)
                    {
                        if (users[lastUser].currentSelection.packages[indP].id == u.Package_And_Fee__c)
                        {
                            users[lastUser].currentSelection.packages[indP].checked = true;
                            users[lastUser].previousSelection.packages[indP].checked = true;
                            
                            break;
                        }
                    }
                }
                
                if (u.Test_login__c)
                    users[lastUser].testUser = true;
                
                if (u.Status__c == 'Activated')
                    users[lastUser].activated = true;
            }
        }
        
        if (userProfileIds == null)
            userProfileIds = new List<ID>();
            
        heightHeaders += 30;
        
        return null;
    }
    
    public List<WrapperUser> getUsers()
    {
        return users;
    }
    
    public List<WrapperService> getServiceHeaders()
    {
        return serviceHeaders;
    }
    
    public List<WrapperPackage> getPackageHeaders()
    {
        return packageHeaders;
    }
    
    public List<SelectOption> getRightsTemplates()
    {
        return rightsTemplates;
    }
    
    public List<SelectOption> getAvailableCUGs()
    {
        return availableCUGs;
    }
    
    public List<SelectOption> getAvailablePUGs()
    {
        return availablePUGs;
    }
    
    public List<SelectOption> getAvailablePIAs()
    {
        return availablePIAs;
    }
    
    public void selectAllContacts()
    {
        System.Debug('## selAllUsers:' + selAllUsers);
        
        for (WrapperUser u : users)
        {
            System.Debug('## user:' + u);
            if (u.activated)
                u.userSelected = selAllUsers;
        }
    }
    
    public void applyRT()
    {
        Integer nbUpdate = 0;
        
        for (WrapperUser u : users)
        {
            if (u.userSelected && u.activated)
            {
                u.chosenRT = rightsTemplate;
                u.applyRT();
                nbUpdate++;
            }
        }
        
        String msg = 'User Rights applied to ' + nbUpdate.format() + ' contact' + ((nbUpdate>1) ? 's' : '') + '.';
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, msg));
    }
    
     public void applyWKTSProfile(){
    	for (WrapperUser u : users)
            u.currentSelection.profiles = selectedBridgeProfiles;
    }
    
    public void applyCUG()
    {
        for (WrapperUser u : users)
        {
            if (u.activated)
                u.currentSelection.cug = selectedCUG;
        }
    }
    
    public void applyPUGs()
    {
        for (WrapperUser u : users)
        {
            if (u.activated)
                u.currentSelection.pugs = selectedPUGs;
        }
    }
    
    public void applyPIA()
    {
        for (WrapperUser u : users)
        {
            if (u.activated)
                u.currentSelection.pia = selectedPIA;
        }
    }
    
    public void applyService()
    {
        for (WrapperUser u : users)
        {
            if (u.activated && u.currentSelection.services[serviceToApply].activated)
                u.currentSelection.services[serviceToApply].checked = serviceHeaders[serviceToApply].checked;
        }
    }
    
    public void applyServiceAttribute()
    {
        for (WrapperUser u : users)
        {
            if (u.activated && u.currentSelection.services[serviceToApply].serviceAttr[serviceAttrToApply].activated)
                u.currentSelection.services[serviceToApply].serviceAttr[serviceAttrToApply].checked = serviceHeaders[serviceToApply].serviceAttr[serviceAttrToApply].checked;
        }       
    }
    
     /*
     @ Description: It inserts the selected service, service attribute and update the user profile.
                                 It deletes the deselected service, service attribute and update the user profile.
    */
    public PageReference Finish()
    {
        System.Savepoint sp = Database.setSavepoint();
        
        // Modify User Profiles
        try
        {
            System.Debug('## Start try');
            
            Map<ID, Boolean>      upModified = new Map<ID, Boolean>();
            List<User_Profile__c> upToUpdate = new List<User_Profile__c>();
            
            // CUG / PUGs / Package
            System.Debug('### Start CUG / PUGs / Package');
            
            for (Integer i = 0; i < users.size(); i++)
            {
                WrapperUser u = users[i];
                
                upModified.put(userProfiles[i].Id, false);
                
                System.Debug('### Current CUG:' + u.currentSelection.cug + ', previous CUG:' + u.previousSelection.cug);
                
                // CUG
                if (u.currentSelection.cug != u.previousSelection.cug)
                {
                    upModified.put(userProfiles[i].Id, true);
                    userProfiles[i].Private_Exchange_ID__c = u.currentSelection.cug;
                }
                
                // PUGs
                Set<String> current  = new Set<String>();
                Set<String> previous = new Set<String>();
                current.addAll(u.currentSelection.pugs);
                previous.addAll(u.previousSelection.pugs);
                
                System.Debug('### Current PUGs:' + current + ', previous PUGs:' + previous);
                
                if ((!current.containsAll(previous)) || (!previous.containsAll(current)))
                {
                    upModified.put(userProfiles[i].Id, true);
                    
                    userProfiles[i].User_PUG_Name__c = '';
                    for (String s : u.currentSelection.pugs)
                        userProfiles[i].User_PUG_Name__c += s + ';';
                }
                
                // PIA
                if (u.currentSelection.pia != u.previousSelection.pia)
                {
                    upModified.put(userProfiles[i].Id, true);
                    userProfiles[i].PIA_Interface__c = u.currentSelection.pia;
                }
                
                // bridge profile
                if(!Utilities.ListsAreTheSame(u.currentSelection.profiles, u.previousSelection.profiles, false))
                {
                	System.Debug('---- CtrlAP01ModifyPermissions.Finish: bridge profiles changed. old value: ' + u.previousSelection.profiles + ', new value: ' + u.currentSelection.profiles);
                	upModified.put(userProfiles[i].Id, true);
                	userProfiles[i].WKTS_Profiles__c = Utilities.ListToString(u.currentSelection.profiles, ';');
                }
                
                // Package
                Integer currentPack  = -1; 
                Integer previousPack = -1;
                
                for (Integer pack = 0; pack < packageHeaders.size(); pack++)
                {
                    if (u.currentSelection.packages[pack].checked)  currentPack = pack;
                    if (u.previousSelection.packages[pack].checked) previousPack = pack;
                }
                
                System.Debug('### Current Pack:' + currentPack + ', previous Pack:' + previousPack);
                
                if (currentPack != previousPack)
                {
                    upModified.put(userProfiles[i].Id, true);
                    userProfiles[i].Package_And_Fee__c = ((currentPack >= 0) ? packageHeaders[currentPack].id : null);
                }
                
                if (upModified.get(userProfiles[i].Id))
                    upToUpdate.add(userProfiles[i]);
            }
            
            System.Debug('### upToUpdate:' + upToUpdate);
            System.Debug('### upModified:' + upModified);
            System.Debug('### End CUG / PUGs / Package');
            
            
            // Services
            System.Debug('#### Start Services');
            
            List<User_Profile_Service__c> upsToDelete = new List<User_Profile_Service__c>();
            List<User_Profile_Service__c> upsToInsert = new List<User_Profile_Service__c>();
            
            for (Integer i = 0; i < users.size(); i++)
            {
                WrapperUser u = users[i];
                
                for (Integer serv = 0; serv < serviceHeaders.size(); serv++)
                {
                    System.Debug('#### Service:' + serviceHeaders[serv].id + '/' + serviceHeaders[serv].title);
                    System.Debug('#### Current:' + u.currentSelection.services[serv].checked);
                    System.Debug('#### Previous:' + u.previousSelection.services[serv].checked);
                    
                    if (u.currentSelection.services[serv].checked != u.previousSelection.services[serv].checked)
                    {
                        upModified.put(userProfiles[i].Id, true);
                        
                        if (u.currentSelection.services[serv].checked)
                        {
                            // Add new permission (service)
                            User_Profile_Service__c ups = new User_Profile_Service__c();
                            ups.Name                    = serviceHeaders[serv].title;
                            ups.Provisioning_Service__c = serviceHeaders[serv].id;
                            ups.User_Profile__c         = userProfiles[i].Id;
                            upsToInsert.add(ups);
                        }
                        else
                        {
                            // Remove old permission (service)
                            List<User_Profile_Service__c> upServices = mapIdUpServ.get(userProfiles[i].Id);
                            
                            for (User_Profile_Service__c ups : upServices)
                            {
                                if (ups.Provisioning_Service__c == serviceHeaders[serv].id)
                                    upsToDelete.add(ups);
                            }
                        }
                    }
                }
            }
            
            if (upsToInsert.size() > 0)
                insert upsToInsert;
            if (upsToDelete.size() > 0)
                delete upsToDelete;    
            
            System.Debug('#### upModified:' + upModified);
            System.Debug('#### End Services');
            
            
            // Service Attributes
            System.Debug('##### Start Service Attributes');
            
            List<User_Profile_Service__c> lstUserProfileServ = [SELECT Id, Provisioning_Service__c, User_Profile__c
                                                                FROM User_Profile_Service__c
                                                                WHERE User_Profile__c IN :userProfiles];
                                                                
            Map<ID, Map<ID, ID>> mapUpProvServUpServ = new Map<ID, Map<ID, ID>>();
            
            for (User_Profile_Service__c ups : lstUserProfileServ)
            {
                if (mapUpProvServUpServ.get(ups.User_Profile__c) == null)
                    mapUpProvServUpServ.put(ups.User_Profile__c, new Map<ID, ID>());
                
                mapUpProvServUpServ.get(ups.User_Profile__c).put(ups.Provisioning_Service__c, ups.Id);
            }
            
            List<User_Profile_Service_Attribute__c> upsaToDelete = new List<User_Profile_Service_Attribute__c>();
            List<User_Profile_Service_Attribute__c> upsaToInsert = new List<User_Profile_Service_Attribute__c>();
            
            for (Integer i = 0; i < users.size(); i++)
            {
                WrapperUser u = users[i];
                
                for (Integer serv = 0; serv < serviceHeaders.size(); serv++)
                {
                    System.Debug('##### Service:' + serviceHeaders[serv].id + '/' + serviceHeaders[serv].title);
                    
                    if (u.currentSelection.services[serv].checked)
                    {
                        for (Integer servat = 0; servat < serviceHeaders[serv].serviceAttr.size(); servat++)
                        {
                            System.Debug('##### Service:' + serviceHeaders[serv].serviceAttr[servat].id + '/' + serviceHeaders[serv].serviceAttr[servat].title);
                            System.Debug('##### Current:' + u.currentSelection.services[serv].serviceAttr[servat].checked);
                            System.Debug('##### Previous:' + u.previousSelection.services[serv].serviceAttr[servat].checked);
                            
                            if (u.currentSelection.services[serv].serviceAttr[servat].checked != u.previousSelection.services[serv].serviceAttr[servat].checked)
                            {
                                upModified.put(userProfiles[i].Id, true);
                                
                                if (u.currentSelection.services[serv].serviceAttr[servat].checked)
                                {
                                    // Add new permission (service attribute)
                                    User_Profile_Service_Attribute__c upsa = new User_Profile_Service_Attribute__c();
                                    upsa.Name                              = serviceHeaders[serv].serviceAttr[servat].title;
                                    upsa.Provisioning_Service_Attribute__c = serviceHeaders[serv].serviceAttr[servat].id;
                                    upsa.User_Profile_Service__c           = mapUpProvServUpServ.get(userProfiles[i].Id).get(serviceHeaders[serv].id);
                                    upsaToInsert.add(upsa);
                                }
                                else
                                {
                                    // Remove old permission (service attribute)
                                    List<User_Profile_Service__c> upServices = mapIdUpServ.get(userProfiles[i].Id);
                                    
                                    for (User_Profile_Service__c ups : upServices)
                                    {
                                        if (ups.Provisioning_Service__c == serviceHeaders[serv].id)
                                        {
                                            List<User_Profile_Service_Attribute__c> upServAttributes = ups.User_Profile_Service_Attributes__r;
                                    
                                            for (User_Profile_Service_Attribute__c upsa : upServAttributes)
                                            {
                                                if (upsa.Provisioning_Service_Attribute__c == serviceHeaders[serv].serviceAttr[servat].id)
                                                    upsaToDelete.add(upsa);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            if (upsaToInsert.size() > 0)
                insert upsaToInsert;
            if (upsaToDelete.size() > 0)
                delete upsaToDelete;
            
            System.Debug('##### upModified:' + upModified);
            System.Debug('##### End Service Attributes');
            
            
            // User Profiles to update
            System.Debug('###### Start users to update');
            System.Debug('###### Users to update:' + upToUpdate);
            
            if (upToUpdate.size() > 0)
                update upToUpdate;
            
            System.Debug('###### End users to update');
            
            
            // User Profile modified (Parent or children)
            System.Debug('####### Start modified up');
            System.Debug('####### Users modified:' + upModified);
            
            userProfileIds.clear();
            for (Integer i = 0; i < users.size(); i++)
            {
                if (upModified.get(userProfiles[i].Id))
                    userProfileIds.add(userProfiles[i].Id);
            }
            
            System.Debug('####### Users to send:' + userProfileIds);
            System.Debug('####### End modified up');
            
            // Test for limitations
            tooManyUsers = (userProfileIds.size() > 50);
            
            if (tooManyUsers)
                Database.rollback(sp);
            
            System.Debug('## End try');
        }
        catch (Exception e)
        {
            Generic.StandardException ex = new Generic.StandardException();
            ex.SetMessage('Error: User Profiles update: ' + e.getMessage());
            throw ex;
        }
        
        return null;
    }
    
     /*
     @ Description: It calls the webservice of ESB / IAM
    */
    public PageReference Provision()
    {
        System.Debug('## Start Provision function');
        
        if (!tooManyUsers)
        {
            System.Debug('## userProfileIds:' + userProfileIds);
            
            if (userProfileIds.size() > 0)
                ProvisioningMessages.SendReProvisioning(userProfileIds);
            
            System.Debug('## End Provision function');
            
            if (System.currentPagereference().getParameters().get('user') == 'all')
                return (Utilities.Redirect(this.prov.Id));
            else 
                return (Utilities.Redirect(System.currentPagereference().getParameters().get('user')));
        }
        else
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'You have exceeded the maximum number of contacts modified for a single provisioning request. Please reduce this number (max. 50).'));
            
            System.Debug('## End Provision function');
            
            return null;
        }
    }
    
    /////////////////////////////////////////////////////////
    //             Prefiltering considerations             //
    /////////////////////////////////////////////////////////
    
    /**
     * All components for the filter
     */
    public String filteringAccountOp                    {get; set;}
    public List<SelectOption> filteringAccountOptions   {get; set;}
    public String filteringAccountNbOp                  {get; set;}
    public List<SelectOption> filteringAccountNbOptions {get; set;}
    public String filteringTlrNbOp                      {get; set;}
    public List<SelectOption> filteringTlrNbOptions     {get; set;}
    public String filteringDebtorNumberOp               {get; set;}
    public List<SelectOption> filteringDnOptions        {get; set;}
    public String filteringBillingCountriesOp           {get; set;}
    public List<SelectOption> filteringBilCtrOptions    {get; set;}
    public String filteringCityOp                       {get; set;}
    public List<SelectOption> filteringCityOptions      {get; set;}
    public String nameFilteringMin                      {get; set;}
    public String nameFilteringMax                      {get; set;}
    
    private List<Account> lstAccountForPreFiltering;
    
    /**
     * @author Thomas Penne
     * @date 04/04/2012
     * @description Create/Refresh all sets that contains picklist items
     */
    public List<Account> refreshFilterOptions()
    {
        if (filteringAccountOptions == null)
            filteringAccountOptions = new List<SelectOption>();
        if (filteringAccountNbOptions == null)
            filteringAccountNbOptions = new List<SelectOption>();
        if (filteringTlrNbOptions == null)
            filteringTlrNbOptions = new List<SelectOption>();
        if (filteringDnOptions == null)
            filteringDnOptions = new List<SelectOption>();
        if (filteringBilCtrOptions == null)
            filteringBilCtrOptions = new List<SelectOption>();
        if (filteringCityOptions == null)
            filteringCityOptions = new List<SelectOption>();
         
        filteringAccountOptions.clear();
        filteringAccountOptions.add(new SelectOption('None', 'All'));
        filteringAccountNbOptions.clear();
        filteringAccountNbOptions.add(new SelectOption('None', 'All'));
        filteringTlrNbOptions.clear();
        filteringTlrNbOptions.add(new SelectOption('None', 'All'));
        filteringDnOptions.clear();
        filteringDnOptions.add(new SelectOption('None', 'All'));
        filteringBilCtrOptions.clear();
        filteringBilCtrOptions.add(new SelectOption('None', 'All'));
        filteringCityOptions.clear();
        filteringCityOptions.add(new SelectOption('None', 'All'));
        
        if (filteringAccountOp == null)          filteringAccountOp          = 'None';
        if (filteringAccountNbOp == null)        filteringAccountNbOp        = 'None';
        if (filteringTlrNbOp == null)            filteringTlrNbOp            = 'None';
        if (filteringDebtorNumberOp == null)     filteringDebtorNumberOp     = 'None';
        if (filteringBillingCountriesOp == null) filteringBillingCountriesOp = 'None';
        if (filteringCityOp == null)             filteringCityOp             = 'None';
        
        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, 'filteringAccountOp: ' + filteringAccountOp));
        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, 'filteringAccountNbOp: ' + filteringAccountNbOp));
        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, 'filteringTlrNbOp: ' + filteringTlrNbOp));
        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, 'filteringDebtorNumberOp: ' + filteringDebtorNumberOp));
        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, 'filteringBillingCountriesOp: ' + filteringBillingCountriesOp));
        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, 'filteringCityOp: ' + filteringCityOp));
        
        List<Account> filteredList   = new List<Account>();
        
        for (Account a : lstAccountForPreFiltering)
        {
            Boolean tested = true;
            
            if (filteringAccountOp != 'None')
                tested = (a.Name == filteringAccountOp);
            if (tested && filteringAccountNbOp != 'None')
                tested = (a.AccountNumber == filteringAccountNbOp);
            if (tested && filteringTlrNbOp != 'None')
                tested = (a.Teleroute_Number__c == filteringTlrNbOp);
            if (tested && filteringDebtorNumberOp != 'None')
                tested = (a.Debtor_Number__c == filteringDebtorNumberOp);
            if (tested && filteringBillingCountriesOp != 'None')
                tested = (a.BillingCountry == filteringBillingCountriesOp);
            if (tested && filteringCityOp != 'None')
                tested = (a.BillingCity == filteringCityOp);

            if (tested)
                filteredList.add(a);
        }
        
        Set<String> accntNames  = new Set<String>();
        Set<String> accntNbrs   = new Set<String>();
        Set<String> tlrNbrs     = new Set<String>();
        Set<String> dbtNbrs     = new Set<String>();
        Set<String> accntCntrys = new Set<String>();
        Set<String> accntCitys  = new Set<String>();
        
        if (filteredList.size() > 0)
        {
            for (Account a : filteredList)
            {
                accntNames.add(a.Name);
                accntNbrs.add(a.AccountNumber);
                tlrNbrs.add(a.Teleroute_Number__c);
                dbtNbrs.add(a.Debtor_Number__c);
                accntCntrys.add(a.BillingCountry);
                accntCitys.add(a.BillingCity);
            }   
        }
        
        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, 'filteredList: ' + filteredList.size()));
        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, 'accntNames: ' + accntNames));
        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, 'accntNbrs: ' + accntNbrs));
        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, 'tlrNbrs: ' + tlrNbrs));
        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, 'dbtNbrs: ' + dbtNbrs));
        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, 'accntCntrys: ' + accntCntrys));
        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, 'accntCitys: ' + accntCitys));
        
        List<String> sorted = new List<String>();
        sorted.addAll(accntNames);
        sorted.sort();
        for (String currAccName : sorted)
        {
            if (currAccName != null)
                filteringAccountOptions.add(new Selectoption(currAccName, currAccName));
            else
                filteringAccountOptions.add(new Selectoption('null', 'null'));
        }
        
        sorted.clear();
        sorted.addAll(accntNbrs);
        sorted.sort();
        for (String currAccNbr : sorted)
        {
            if (currAccNbr != null)
                filteringAccountNbOptions.add(new Selectoption(currAccNbr, currAccNbr)); 
            else
                filteringAccountNbOptions.add(new Selectoption('null', 'null'));
        }
            
        sorted.clear();
        sorted.addAll(tlrNbrs);
        sorted.sort();
        for (String currTlrNbr : sorted)
        {   
            if (currTlrNbr != null)
                filteringTlrNbOptions.add(new Selectoption(currTlrNbr, currTlrNbr)); 
            else
                filteringTlrNbOptions.add(new Selectoption('null', 'null'));
        }
            
        sorted.clear();
        sorted.addAll(dbtNbrs);
        sorted.sort();
        for (String currDbtNbr : sorted)
        {
            if (currDbtNbr != null)
                filteringDnOptions.add(new Selectoption(currDbtNbr, currDbtNbr)); 
            else
                filteringDnOptions.add(new Selectoption('null', 'null'));
        }
            
        sorted.clear();
        sorted.addAll(accntCntrys);
        sorted.sort();
        for (String currCntry : sorted)
        {
            if (currCntry != null)
                filteringBilCtrOptions.add(new Selectoption(currCntry, currCntry)); 
            else
                filteringBilCtrOptions.add(new Selectoption('null', 'null'));
        }
            
        sorted.clear();
        sorted.addAll(accntCitys);
        sorted.sort();
        for (String currCity : sorted)
        {
            if (currCity != null)
                filteringCityOptions.add(new Selectoption(currCity, currCity)); 
            else
                filteringCityOptions.add(new Selectoption('null', 'null'));
        }
            
        return filteredList;
    }
    
    public PageReference refreshFilteringOptions()
    {
        refreshFilterOptions();
        
        return null;
    }
}