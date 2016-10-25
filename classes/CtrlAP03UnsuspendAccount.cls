public class CtrlAP03UnsuspendAccount 
{
    public class userProfileWrapper
    {
        public User_Profile__c up {get; set;}
        public Boolean selected {get; set;}
        
        public userProfileWrapper(User_Profile__c u)
        {
            up = u;
            selected = false;
        }
    }
    
    public class serviceWrapper
    {
        public Provisioning_Service__c service {get; set;}
        public String servName {get; set;}
        public Provisioning_Service_Attribute__c attr {get; set;}
        public String attrName {get; set;}
        public Boolean selected {get; set;}
        
        public serviceWrapper(Provisioning_Service__c s)
        {
            service = s;
            servName = s.Service__r.Name;
            attrName = '';
            selected = false;
        }
        
        public serviceWrapper(Provisioning_Service_Attribute__c a)
        {
            attr = a;
            servName = '';
            attrName = a.Service_Attribute__r.Name;
            selected = false;
        }
    }
    
    private final Provisioning__c prov;
    public User_Profile__c user;
    public String suspendOption {get; set;}
    public String selectedOption {get; set;}
    public List<SelectOption> optionsFilter;
    public List<userProfileWrapper> availableContacts;
    public List<userProfileWrapper> contacts;
    public List<serviceWrapper> services;
    public Boolean selAll {get; set;}
    public Boolean selAllSusp {get; set;}
    public Boolean isImmediateUnsuspension{get; set;}

        
    public CtrlAP03UnsuspendAccount(ApexPages.StandardController controller) 
    {
        this.prov = [select Id,Subscription__c from Provisioning__c where Id=:((Provisioning__c)controller.getRecord()).Id];
    }
    
       
    public PageReference init()
    {
        createSets();
    
        //selAll     = false;
        //selAllSusp = false;
        
        if (user == null)
        {
            user = new User_Profile__c();
            user.RecordTypeId = Schema.getGlobalDescribe().get('User_Profile__c').getDescribe().getRecordTypeInfosByName().get('TLR User Profile').getRecordTypeId();
        }
        
        suspendOption = 'Subscription';
        
        if (services == null)
        {
            services = new List<serviceWrapper>();
            List<Provisioning_Service__c> provServices = [SELECT Id, Service__r.Name, 
                                                         (SELECT Id, Service_Attribute__r.Name
                                                          FROM Provisioning_Service_Attributes__r ORDER BY Service_Attribute__r.Name ASC)
                                                          FROM Provisioning_Service__c 
                                                          WHERE Provisioning__c = :this.prov.Id ORDER BY Service__r.Name ASC];
                                                          
            for (Provisioning_Service__c provService : provServices)
            {
                services.add(new serviceWrapper(provService));
                
                for (Provisioning_Service_Attribute__c attribute : provService.Provisioning_Service_Attributes__r)
                    services.add(new serviceWrapper(attribute));
            }
        }       
        
        List<String> accs = new List<String>();
        
        if (availableContacts == null)
        {
            availableContacts = new List<userProfileWrapper>();
            contacts          = new List<userProfileWrapper>();
            List<User_Profile__c>  userPros = [SELECT Id, Status__c, Contact__r.Name, Contact__r.Account.Name,Contact__r.Account.Account_Level__c,
                                                     Contact__r.Account.AccountNumber, Contact__r.Account.Teleroute_Number__c,
                                                     Contact__r.Account.Debtor_Number__c, Contact__r.Account.BillingCountry,
                                                     Contact__r.Account.BillingCity, Contact__r.Account.Suspension_Start_Date__c,
                                                     Suspension_End_Date__c, Suspension_Reason__c, Immediate_unsuspension__c
                                                FROM User_Profile__c
                                                WHERE Status__c ='Suspended' AND Provisioning__c = :this.prov.Id];
             
            //            Set<String> accountNames = new Set<String>();
            for (User_Profile__c u : userPros)
            {
                u.Immediate_unsuspension__c=false;
                availableContacts.add(new userProfileWrapper(u));
                    contacts.add(availableContacts[availableContacts.size() - 1]);
//                if (!accountNames.contains(u.Contact__r.Account.Name))
//                    accountNames.add(u.Contact__r.Account.Name);
                accountNames.add(u.Contact__r.Account.Name);
                if(u.Contact__r.Account.AccountNumber != null && u.Contact__r.Account.AccountNumber != '')
                    accountNumbers.add(u.Contact__r.Account.AccountNumber);
                if(u.Contact__r.Account.Teleroute_Number__c != null && u.Contact__r.Account.Teleroute_Number__c != '')
                    tlrNumbers.add(u.Contact__r.Account.Teleroute_Number__c);
                if(u.Contact__r.Account.Debtor_Number__c != null && u.Contact__r.Account.Debtor_Number__c != '')
                    debtorNumbers.add(u.Contact__r.Account.Debtor_Number__c);
                if(u.Contact__r.Account.BillingCountry != null && u.Contact__r.Account.BillingCountry != '')
                    billingCountries.add(u.Contact__r.Account.BillingCountry);
                if(u.Contact__r.Account.BillingCity != null && u.Contact__r.Account.BillingCity != '')
                    cities.add(u.Contact__r.Account.BillingCity);         
            }
//            accs.addAll(accountNames);
//            accs.sort();

            fillOptions();
        
            // Create the filtering utility component
            fu = new FilteringUtilsAP03Unsuspend(this);
        }
            
        if (optionsFilter == null)
        {
            optionsFilter = new List<Selectoption>();
            optionsFilter.add(new Selectoption('View All', 'View All'));
            for (String acc : accs)
                optionsFilter.add(new Selectoption(acc, acc));
        }
            
        return null;
    }
    
    public PageReference RefreshList()
    {

       contacts.clear();
       availableContacts.clear();

       
               List<User_Profile__c>  userPros = [SELECT Id, Status__c, Contact__r.Name, Contact__r.Account.Name,Contact__r.Account.Account_Level__c,
                                                             Contact__r.Account.AccountNumber, Contact__r.Account.Teleroute_Number__c,
                                                             Contact__r.Account.Debtor_Number__c, Contact__r.Account.BillingCountry,
                                                             Contact__r.Account.BillingCity, Contact__r.Account.Suspension_Start_Date__c,
                                                             Suspension_End_Date__c, Suspension_Reason__c, Immediate_unsuspension__c
                                                        FROM User_Profile__c
                                                        WHERE Provisioning__c = :this.prov.Id]; 

                for (User_Profile__c u : userPros)                 
                { 
                                        
                   if (suspendOption =='Subscription' && u.Status__c =='Suspended')
                   {
                        //(selectedOption == 'View All')  || (u.Contact__r.Account.Name == selectedOption) &&            
                        u.Immediate_unsuspension__c=false;
                        availableContacts.add(new userProfileWrapper(u));   
                        contacts.add(availableContacts[availableContacts.size() - 1]);
                        //contacts.add(u);
                        accountNames.add(u.Contact__r.Account.Name);
                        if(u.Contact__r.Account.AccountNumber != null && u.Contact__r.Account.AccountNumber != '')
                             accountNumbers.add(u.Contact__r.Account.AccountNumber);
                        if(u.Contact__r.Account.Teleroute_Number__c != null && u.Contact__r.Account.Teleroute_Number__c != '')
                             tlrNumbers.add(u.Contact__r.Account.Teleroute_Number__c);
                        if(u.Contact__r.Account.Debtor_Number__c != null && u.Contact__r.Account.Debtor_Number__c != '')
                             debtorNumbers.add(u.Contact__r.Account.Debtor_Number__c);
                        if(u.Contact__r.Account.BillingCountry != null && u.Contact__r.Account.BillingCountry != '')
                             billingCountries.add(u.Contact__r.Account.BillingCountry);
                        if(u.Contact__r.Account.BillingCity != null && u.Contact__r.Account.BillingCity != '')
                             cities.add(u.Contact__r.Account.BillingCity);
                   }
                   else if (suspendOption !='Subscription')
                   {
                        u.Immediate_unsuspension__c=false;  
                        availableContacts.add(new userProfileWrapper(u));   
                        contacts.add(availableContacts[availableContacts.size() - 1]);
                        //contacts.add(u);
                        accountNames.add(u.Contact__r.Account.Name);
                        if(u.Contact__r.Account.AccountNumber != null && u.Contact__r.Account.AccountNumber != '')
                             accountNumbers.add(u.Contact__r.Account.AccountNumber);
                        if(u.Contact__r.Account.Teleroute_Number__c != null && u.Contact__r.Account.Teleroute_Number__c != '')
                             tlrNumbers.add(u.Contact__r.Account.Teleroute_Number__c);
                        if(u.Contact__r.Account.Debtor_Number__c != null && u.Contact__r.Account.Debtor_Number__c != '')
                             debtorNumbers.add(u.Contact__r.Account.Debtor_Number__c);
                        if(u.Contact__r.Account.BillingCountry != null && u.Contact__r.Account.BillingCountry != '')
                             billingCountries.add(u.Contact__r.Account.BillingCountry);
                        if(u.Contact__r.Account.BillingCity != null && u.Contact__r.Account.BillingCity != '')
                             cities.add(u.Contact__r.Account.BillingCity);                         
                   }
                }
                
            return null;
    }

    public User_Profile__c getUser()
    {
           return user;
    }
    
    public List<Selectoption> getOptionsFilter()
    {
        return optionsFilter;
    }
    
    public List<userProfileWrapper> getContacts()
    {
        return contacts;
    }
    
    public List<serviceWrapper> getServices()
    {
        return services;
    }
    
    public void selectAll()
    {
        for (userProfileWrapper u : contacts)
            u.selected = selAll; 
    }
    
    public void selectAllSusp()
    {
        for (serviceWrapper s : services)
            s.selected = selAllSusp;
    }
    
    boolean test;
    public PageReference Unsuspend()
    {
        if (user.Immediate_unsuspension__c==false && user.Suspension_End_Date__c == null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'For non-immediate unsuspension, please indicate the suspension end date.'));
            return null;
        }
        else if (user.Immediate_unsuspension__c== false && user.Suspension_End_Date__c != null && user.Suspension_Start_Date__c != null & user.Suspension_End_Date__c < user.Suspension_Start_Date__c)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'End Date must be greater or equal to Start Date!'));
            return null;
        }
        else if (user.Immediate_unsuspension__c== false && user.Suspension_End_Date__c != null && user.Suspension_End_Date__c < Date.Today())
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'End Date must be greater or equal to today!'));
            return null;
        }
        else
        {
            Boolean oneServSelected = false;
            for (serviceWrapper s : services)
            {
                if (s.selected)
                {
                    oneServSelected = true;
                    break;
                }
            }
            
            if (suspendOption == 'Subscription' || oneServSelected)
            {
                Boolean oneUserSelected = false;
                for (userProfileWrapper u : contacts)
                {
                    if (u.selected)
                    {
                        oneUserSelected = true;
                        break;
                    }
                }
                
                if (oneUserSelected)
                {
                   List<Id> upToSuspend = new List<Id>();
                    
                
                    List<User_Profile__c> upToUpdate                     = new List<User_Profile__c>();
                    List<User_Profile_Service__c> upsToUpdate            = new List<User_Profile_Service__c>();
                    List<User_Profile_Service_Attribute__c> upsaToUpdate = new List<User_Profile_Service_Attribute__c>();
                    
                    if (suspendOption == 'Subscription')
                    {
                        Set<ID> upIds = new Set<ID>();
                    
                        for (userProfileWrapper u : contacts)
                            upIds.add(u.up.Id);
                            
                        Map<ID, User_Profile__c> mapIdUp = new Map<ID, User_Profile__c>([SELECT Id, Suspension_Start_Date__c, 
                                                                                         Suspension_End_Date__c, Suspension_Reason__c
                                                                                         FROM User_Profile__c WHERE Id IN :upIds]);
                        
                        for (userProfileWrapper u : contacts)
                        {
                            if (u.selected)
                            {
                                User_Profile__c userProfile = mapIdUp.get(u.up.Id);
                                
                                if (user.Immediate_unsuspension__c==false && user.Suspension_End_Date__c != null)
                                {
                                    upToSuspend.add(userProfile.Id);                                   
                                    userProfile.Suspension_End_Date__c = user.Suspension_End_Date__c;      
                                }
                                
                                if (user.Immediate_unsuspension__c== true)
                                {
                                    upToSuspend.add(userProfile.Id);
                                    userProfile.Suspension_End_Date__c = Date.Today() - 1;
                                }
                                
                                upToUpdate.add(userProfile);
                            }
                        }
                        
                        System.debug('## Users to suspend: ' + upToSuspend);
                        
                        if (upToSuspend.size() > 0)
                            ProvisioningMessages.UnsuspendUsersInSubscription(new Map<ID, List<ID>>{prov.Subscription__c => upToSuspend});
                        
                    }
                    else
                    {
                        Set<ID> upIds = new Set<ID>();
                    
                        for (userProfileWrapper u : contacts)
                            upIds.add(u.up.Id);
                            
                        Map<ID, User_Profile__c> mapIdUp = new Map<ID, User_Profile__c>([SELECT Id, Suspension_Start_Date__c, 
                                                                                         Suspension_End_Date__c, Suspension_Reason__c
                                                                                         FROM User_Profile__c 
                                                                                         WHERE Id IN :upIds]);
                                                                                         
                        for (userProfileWrapper u : contacts)
                        {
                            if (u.selected)
                            {
                                Set<ID> selectedProvServ = new Set<ID>();
                                Set<ID> selectedProvServAttr = new Set<ID>();
                                
                                for (serviceWrapper s : services)
                                {
                                    if (s.selected)
                                    {
                                        if (s.service != null)
                                            selectedProvServ.add(s.service.Id);
                                        else
                                            selectedProvServAttr.add(s.attr.Id);
                                    }
                                }
                                
                                Map<Id, User_Profile_Service__c> uproserv = new Map<Id, User_Profile_Service__c>([SELECT Id, Suspension_Start_Date__c, Suspension_End_Date__c, Suspension_Reason__c
                                                                                                                  FROM User_Profile_Service__c 
                                                                                                                  WHERE User_Profile__c = :u.up.Id 
                                                                                                                  AND Provisioning_Status__c ='Suspended' AND Provisioning_Service__c IN :selectedProvServ]);
                                                                                                                  
                                Map<Id, User_Profile_Service_Attribute__c> uproservattr = new Map<Id, User_Profile_Service_Attribute__c>([SELECT Id, Suspension_Start_Date__c, Suspension_End_Date__c, Suspension_Reason__c
                                                                                                                                          FROM User_Profile_Service_Attribute__c
                                                                                                                                          WHERE User_Profile_Service__r.User_Profile__c = :u.up.Id
                                                                                                                                          AND Provisioning_Status__c ='Suspended' AND Provisioning_Service_Attribute__c IN :selectedProvServAttr]);     
                                
                                for (User_Profile_Service__c uproS : uproserv.values())
                                {
                                        // Immediate Suspension:
                                    if (user.Immediate_unsuspension__c == false && user.Suspension_End_Date__c != null)
                                    {
                                        upToSuspend.add(u.up.Id);
                                        uproS.Suspension_End_Date__c = user.Suspension_End_Date__c;
                                    }
                                    else if (user.Immediate_unsuspension__c == true)
                                    {
                                        upToSuspend.add(u.up.Id);
                                        uproS.Suspension_End_Date__c = Date.Today() - 1;
                                    }
                                    
                                    upsToUpdate.add(uproS); 
                                }
                                
                                for (User_Profile_Service_Attribute__c uproSA : uproservattr.values())
                                {
                                    // Immediate Suspension:
                                    if (user.Immediate_unsuspension__c == false || user.Suspension_End_Date__c != null)
                                    {
                                        upToSuspend.add(u.up.Id);
                                        uproSA.Suspension_End_Date__c = user.Suspension_End_Date__c;
                                    }
                                    else if (user.Immediate_unsuspension__c == true)
                                    {
                                        upToSuspend.add(u.up.Id);
                                        uproSA.Suspension_End_Date__c = Date.Today() - 1;
                                    }
                                upsaToUpdate.add(uproSA);   
                                }
                            }
                        }
                        
                        System.debug('## Users to suspend: ' + upToSuspend);
                        
                      // if (upToSuspend.size() > 0)
                        //     ProvisioningMessages.SuspendUsersInSubscription(new Map<ID, List<ID>>{prov.Subscription__c => upToSuspend}, 'Standard');
                         //   ProvisioningMessages.UnsuspendUsersInSubscription(new Map<ID, List<ID>>{prov.Subscription__c => upToSuspend});
                        if (upToSuspend.size() > 0)
                        {
                          Map<ID,User_Profile__c>  UPtoUnsupend= new Map<ID,User_Profile__c>([SELECT Id FROM User_Profile__c WHERE Id in: upToSuspend]);
                          List<Id> upuns= new List<ID>();
                          for (User_Profile__c uptosus: UPtoUnsupend.values())
                          {
                              upuns.add(uptosus.Id);
                          }
                               ProvisioningMessages.UnsuspendUsersInSubscription(new Map<ID, List<ID>>{prov.Subscription__c => upuns});
                        }
                    }
                    
                    if (upToUpdate.size() > 0)
                        update upToUpdate;
                    if (upsToUpdate.size() > 0)
                        update upsToUpdate;
                    if (upsaToUpdate.size() > 0)
                        update upsaToUpdate;
                        
                    return (Utilities.Redirect(this.prov.Id));
                }
                else
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Select at least one contact to suspend!'));
                    return null;
                }
            }
            else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Select at least one service / service attribute or put level to Subscription!'));
                return null;
            }
        }
    }
    
    public PageReference Cancel()
    {
        return (Utilities.Redirect(this.prov.Id));
    }

    //////////////////////////////////////////////////////
    //             Filtering considerations             //
    //////////////////////////////////////////////////////
    
    private FilteringUtilsAP03Unsuspend fu;
    
    /**
     * All components for the filter
     */
    public String accountOp                    {get; set;}
    public List<SelectOption> accountOptions   {get; set;}
    public String accountNbOp                  {get; set;}
    public List<SelectOption> accountNbOptions {get; set;}
    public String tlrNbOp                      {get; set;}
    public List<SelectOption> tlrNbOptions     {get; set;}
    public String debtorNumberOp               {get; set;}
    public List<SelectOption> dnOptions        {get; set;}
    public String billingCountriesOp           {get; set;}
    public List<SelectOption> bilCtrOptions    {get; set;}
    public String cityOp                       {get; set;}
    public List<SelectOption> cityOptions      {get; set;}
    
    
    /**
     * All filter picklists' values
     */
    private Set<String> accountNames;
    private Set<String> accountNumbers;
    private Set<String> debtorNumbers;
    private Set<String> tlrNumbers;
    private Set<String> billingCountries;
    private Set<String> cities;
    
    /**
     * @author Nicolas Dolet
     * @date 03/12/2011
     * @description Create all sets that contains picklist items
     */
    private void createSets() {
        accountNames = new Set<String>();
        accountNumbers = new Set<String>();
        tlrNumbers = new Set<String>();
        debtorNumbers = new Set<String>();
        billingCountries = new Set<String>();
        cities = new Set<String>();
    }

    /**
     * @author Nicolas Dolet
     * @date 03/12/2011
     * @description Fill in the select options components
     */
    private void fillOptions() {
        fillAccountNames(this.accountNames);
        fillAccountNumbers(this.accountNumbers);
        fillTelerouteNumbers(this.tlrNumbers);
        fillDebtorNumbers(this.debtorNumbers);
        fillBillingCountries(this.billingCountries);
        fillBillingCities(this.cities);
    }
    
    /**
     * @author Nicolas Dolet
     * @date 03/12/2011
     * @description Fill in the Account Name picklist
     */
    private void fillAccountNames(Set<String> s) {
        accountOptions = new List<SelectOption>();
        accountOptions.add(new Selectoption('None', '- View all -'));
        List<String> sorted = new List<String>();
        sorted.addAll(s);
        sorted.sort();
        for(String currAccName : sorted) {
            accountOptions.add(new Selectoption(currAccName, currAccName));
        }
    }

    /**
     * @author Nicolas Dolet
     * @date 03/12/2011
     * @description Fill in the Account Number picklist
     */
    private void fillAccountNumbers(Set<String> s) {
        accountNbOptions = new List<SelectOption>();
        accountNbOptions.add(new Selectoption('None', '- View all -'));
        List<String> sorted = new List<String>();
        sorted.addAll(s);
        sorted.sort();
        for(String currAccNb : sorted) {
          accountNbOptions.add(new Selectoption(currAccNb, currAccNb));
        }
    }

    /**
     * @author Nicolas Dolet
     * @date 03/12/2011
     * @description Fill in the Teleroute Number picklist
     */
    private void fillTelerouteNumbers(Set<String> s) {
        tlrNbOptions = new List<SelectOption>();
        tlrNbOptions.add(new Selectoption('None', '- View all -'));
        List<String> sorted = new List<String>();
        sorted.addAll(s);
        sorted.sort();
        for(String currTlrNb : sorted) {
          tlrNbOptions.add(new Selectoption(currTlrNb, currTlrNb));
        }
    }

    /**
     * @author Nicolas Dolet
     * @date 03/12/2011
     * @description Fill in the Debtor Number picklist
     */
    private void fillDebtorNumbers(Set<String> s) {
        dnOptions = new List<SelectOption>();
        dnOptions.add(new Selectoption('None', '- View all -'));
        List<String> sorted = new List<String>();
        sorted.addAll(s);
        sorted.sort();
        for(String currDN : sorted) {
          dnOptions.add(new Selectoption(currDN, currDN));
        }
    }

    /**
     * @author Nicolas Dolet
     * @date 03/12/2011
     * @description Fill in the Billing Country picklist
     */
    private void fillBillingCountries(Set<String> s) {
        bilCtrOptions = new List<SelectOption>();
        bilCtrOptions.add(new Selectoption('None', '- View all -'));
        List<String> sorted = new List<String>();
        sorted.addAll(s);
        sorted.sort();
        for(String currCtr : sorted) {
          bilCtrOptions.add(new Selectoption(currCtr, currCtr));
        }
    }

    /**
     * @author Nicolas Dolet
     * @date 03/12/2011
     * @description Fill in the Billing City picklist
     */
    private void fillBillingCities(Set<String> s) {
        cityOptions = new List<SelectOption>();
        cityOptions.add(new Selectoption('None', '- View all -'));
        List<String> sorted = new List<String>();
        sorted.addAll(s);
        sorted.sort();
        for(String currCity : sorted) {
          cityOptions.add(new Selectoption(currCity, currCity));
        }
    }
    
    /**
     * @author Nicolas Dolet
     * @date 03/12/2011
     * @description @see FilteringUtils.applyFilterAccName()
     */
    public void applyFilterAccName() {
        fu.applyFilterAccName();
    }

    /**
     * @author Nicolas Dolet
     * @date 03/12/2011
     * @description @see FilteringUtils.applyFilterAccNumber()
     */
    public void applyFilterAccNumber() {
        fu.applyFilterAccNumber();
    }

    /**
     * @author Nicolas Dolet
     * @date 03/12/2011
     * @description @see FilteringUtils.applyFilterTlrNumber()
     */
    public void applyFilterTlrNumber() {
        fu.applyFilterTlrNumber();
    }

    /**
     * @author Nicolas Dolet
     * @date 03/12/2011
     * @description @see FilteringUtils.applyFilterDebtorNumber()
     */
    public void applyFilterDebtorNumber() {
        fu.applyFilterDebtorNumber();
    }

    /**
     * @author Nicolas Dolet
     * @date 03/12/2011
     * @description @see FilteringUtils.applyFilterCountry()
     */
    public void applyFilterCountry() {
        fu.applyFilterCountry();
    }

    /**
     * @author Nicolas Dolet
     * @date 03/12/2011
     * @description @see FilteringUtils.applyFilterCity()
     */
    public void applyFilterCity() {
        fu.applyFilterCity();
    }

}