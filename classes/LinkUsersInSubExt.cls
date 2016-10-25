public class LinkUsersInSubExt 
{
    private final Subscription__c sub;
    public List<wrapperContact> availableContacts;
    public List<wrapperContact> contactList;
    public List<Contact> cons;
    public String sortVal { get; set; }
    public String headerName { get; set; }
    public String headerAccnt { get; set; }
    public String headerEMail { get; set; }
    public String headerPhone { get; set; }
    public Boolean selAll { get; set; }
    public Boolean activeFilter { get; set; }
    public String titleFilter { get; set; }
    
    public LinkUsersInSubExt(ApexPages.StandardController controller) 
    {
        ID subsId = System.currentPagereference().getParameters().get('id');
        this.sub  = [SELECT Id, CurrencyIsoCode FROM Subscription__c WHERE Id = :subsId];
    }

    public PageReference init()
    {
        createSets();
        if (availableContacts == null)
            availableContacts = new List<wrapperContact>();

        if (contactList == null)
            contactList = new List<wrapperContact>();
        
        selAll = false;
        activeFilter = false;
        titleFilter = 'Activate Filter';
        
        getAndSortContacts();
            
        return null;
    }
    
    public void getAndSortContacts()
    {
        availableContacts.clear();
        
        // Account Ids list
        Id contract = [SELECT Contract__c FROM Subscription__c WHERE Id = :sub.Id].Contract__c;
        List<ID> accnts = new ID[]{[SELECT AccountId FROM Contract WHERE Id = :contract].AccountId};
        List<ID> parentId = new ID[]{accnts[0]};
        Integer nbAccnts = 1;
        
        while (nbAccnts != 0)
        {
            List<Account> children = [SELECT Id FROM Account WHERE ParentId IN :parentId];
            nbAccnts = children.size();
            if (nbAccnts > 0)
            {
                parentId.clear();
                for (Account child : children)
                {
                    parentId.add(child.Id);
                    accnts.add(child.Id);
                }
            }
        }
/*                 
        if (sortVal == 'phone')
        {
            cons = [SELECT Id, Name, Email, Phone, Account.Name FROM Contact WHERE AccountId IN :accnts ORDER BY Phone ASC];
            headerName  = 'Contact Name';
            headerAccnt = 'Account';
            headerEMail = 'Email';
            headerPhone = 'Phone ↑';
        }
        else if (sortVal == 'accnt')
        {
            cons = [SELECT Id, Name, Email, Phone, Account.Name FROM Contact WHERE AccountId IN :accnts ORDER BY Account.Name ASC];
            headerName  = 'Contact Name';
            headerAccnt = 'Account ↑';
            headerEMail = 'Email';
            headerPhone = 'Phone';
        }
        else if (sortVal == 'email')
        {
            cons = [SELECT Id, Name, Email, Phone, Account.Name FROM Contact WHERE AccountId IN :accnts ORDER BY Email ASC];
            headerName  = 'Contact Name';
            headerAccnt = 'Account';
            headerEMail = 'Email ↑';
            headerPhone = 'Phone';
        }
        else
        {
            cons = [SELECT Id, Name, Email, Phone, Account.Name FROM Contact WHERE AccountId IN :accnts ORDER BY Name ASC];
            headerName  = 'Contact Name ↑';
            headerAccnt = 'Account';
            headerEMail = 'Email';
            headerPhone = 'Phone';
        }
*/

        cons = [SELECT Id, Name, Email, Phone, Account.Name,
                       Account.AccountNumber, Account.Teleroute_Number__c,
                       Account.Debtor_Number__c, Account.BillingCity,
                       Account.BillingCountry
                  FROM Contact
                 WHERE AccountId
                    IN :accnts
                 ORDER BY Name ASC];

        headerName  = 'Contact Name ↑';
        headerAccnt = 'Account';
        headerEMail = 'Email';
        headerPhone = 'Phone';

         
        for (Contact con : cons) {
            availableContacts.add(new WrapperContact(con));
            contactList.add(availableContacts[availableContacts.size() - 1]);
            
            accountNames.add(con.Account.Name);
            if(con.Account.AccountNumber != null && con.Account.AccountNumber != '')
                accountNumbers.add(con.Account.AccountNumber);
            if(con.Account.Teleroute_Number__c != null && con.Account.Teleroute_Number__c != '')
                tlrNumbers.add(con.Account.Teleroute_Number__c);
            if(con.Account.Debtor_Number__c != null && con.Account.Debtor_Number__c != '')
                debtorNumbers.add(con.Account.Debtor_Number__c);
            if(con.Account.BillingCountry != null && con.Account.BillingCountry != '')
                billingCountries.add(con.Account.BillingCountry);
            if(con.Account.BillingCity != null && con.Account.BillingCity != '')
                cities.add(con.Account.BillingCity); 
        }
        
        fillOptions();
        
        // Create the filtering utility component
        fu = new FilteringUtilsLinkUsers(this);
    }
    
    public List<wrapperContact> getContacts()
    {
        return availableContacts;
    }
    
    public void selectAll()
    {
        for (wrapperContact con : availableContacts)
            con.selected = selAll;
    }
    
    public void activateFilter()
    {
        activeFilter = !activeFilter;
        titleFilter = (activeFilter == true) ? 'DeactivateFilter' : 'Activate Filter';
    }
    
    public class wrapperContact
    {
        public Contact con {get; set;}
        public Boolean selected {get; set;}
        public wrapperContact(Contact c)
        {
            con = c;
            selected = false;
        }
    }
    
    public PageReference Save()
    {
        List<Subscription_User__c> toInsert = new List<Subscription_User__c>();
        
        for (wrapperContact con : availableContacts)
        {
            if (con.selected == true)
            {
                Subscription_User__c subUser = new Subscription_User__c();
                subUser.Subscription__c = this.sub.Id;
                subUser.CurrencyIsoCode = this.sub.CurrencyIsoCode;
                subUser.Contact__c = con.con.Id;
                toInsert.add(subUser);
            }
        }
        
        insert toInsert;
        
        return (Utilities.Redirect(this.sub.Id));
    }
    
    public PageReference Cancel()
    {
        return (Utilities.Redirect(this.sub.Id));
    }

    //////////////////////////////////////////////////////
    //             Filtering considerations             //
    //////////////////////////////////////////////////////
    
    private FilteringUtilsLinkUsers fu;
    
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
     * @date 01/12/2011
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
     * @date 01/12/2011
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
     * @date 01/12/2011
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
     * @date 01/12/2011
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
     * @date 01/12/2011
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
     * @date 01/12/2011
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
     * @date 01/12/2011
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
     * @date 01/12/2011
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
     * @date 01/12/2011
     * @description @see FilteringUtils.applyFilterAccName()
     */
    public void applyFilterAccName() {
        fu.applyFilterAccName();
    }

    /**
     * @author Nicolas Dolet
     * @date 01/12/2011
     * @description @see FilteringUtils.applyFilterAccNumber()
     */
    public void applyFilterAccNumber() {
        fu.applyFilterAccNumber();
    }

    /**
     * @author Nicolas Dolet
     * @date 01/12/2011
     * @description @see FilteringUtils.applyFilterTlrNumber()
     */
    public void applyFilterTlrNumber() {
        fu.applyFilterTlrNumber();
    }

    /**
     * @author Nicolas Dolet
     * @date 01/12/2011
     * @description @see FilteringUtils.applyFilterDebtorNumber()
     */
    public void applyFilterDebtorNumber() {
        fu.applyFilterDebtorNumber();
    }

    /**
     * @author Nicolas Dolet
     * @date 01/12/2011
     * @description @see FilteringUtils.applyFilterCountry()
     */
    public void applyFilterCountry() {
        fu.applyFilterCountry();
    }

    /**
     * @author Nicolas Dolet
     * @date 01/12/2011
     * @description @see FilteringUtils.applyFilterCity()
     */
    public void applyFilterCity() {
        fu.applyFilterCity();
    }

}