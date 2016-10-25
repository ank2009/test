/*
* @ Description :- This wizard class is using for provisioning.
                 Step 1) This visual force page displays the number of contact to be present.
                 Step 2) This visual force page used for creating contact.
                 Step 3) This visual force page used to display service, service attribute matrix
* @ Author      :- Atos
* @ Date        :- 16/06/2011
**/

public with sharing class ProvisioningUserMgt
{
    // ------------- //
    // Inner Classes //
    // ------------- //
    public class WrapperSelectedContact
    {
        public Contact con      {get; set;}
        public Boolean selected {get; set;}

        public WrapperSelectedContact(Contact c)
        {
            con      = c;
            selected = false;
        }
    }

    public class WrapperField
    {
        public String apiName {get; set;}
        public String title   {get; set;}
        public String value   {get; set;}

        public List<SelectOption> selectOpt;

        private Schema.DisplayType dspType;

        public WrapperField(WrapperField f)
        {
            apiName   = f.apiName;
            title     = f.title;
            dspType   = f.dspType;
            value     = f.value;

            if (f.selectOpt == null)
                selectOpt = null;
            else
            {
                selectOpt = new List<SelectOption>();
                selectOpt.addAll(f.selectOpt);
            }
        }

        public WrapperField(Schema.DescribeFieldResult f)
        {
            apiName  = f.getName();
            title    = f.getLabel();
            dspType  = f.getType();
            value    = '';

            if (getPicklist())
            {
                selectOpt = new List<SelectOption>();
                for (Schema.PicklistEntry entry : f.getPicklistValues())
                    selectOpt.add(new SelectOption(entry.getValue(), entry.getLabel()));
            }
        }

        public List<SelectOption> getSelectOpt()
        {
            return selectOpt;
        }

        public Boolean getString()
        {
            return ((dspType == Schema.DisplayType.String) ||
                    (dspType == Schema.DisplayType.Email) ||
                    (dspType == Schema.DisplayType.Phone));
        }

        public Boolean getPicklist()
        {
            return (dspType == Schema.DisplayType.PickList);
        }
    }

    public class WrapperCreatedContact
    {
        public Contact con {get; set;}
        List<WrapperField> fields;

        public WrapperCreatedContact(List<WrapperField> fieldsList)
        {
            con    = new Contact();
            fields = new List<WrapperField>();
            for (WrapperField field : fieldsList)
                fields.add(new WrapperField(field));
        }

        public List<WrapperField> getFields()
        {
            return fields;
        }
    }

    public class WrapperService
    {
        public ID      id      {get; set;}
        public String  title   {get; set;}
        public Boolean checked {get; set;}
        public List<WrapperServiceAttr> serviceAttr {get; set;}

        public WrapperService(String t, ID idServ)
        {
            id          = idServ;
            title       = t;
            checked     = false;
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
        public ID             id      {get; set;}
        public String         title   {get; set;}
        public Boolean        checked {get; set;}
        public WrapperService parent;

        public WrapperServiceAttr(String t, ID idServAttr, WrapperService p)
        {
            id      = idServAttr;
            title   = t;
            checked = false;
            parent  = p;
        }

        public void apply()
        {
            if (checked)
                parent.checked = true;
        }
    }

    public class WrapperPackage
    {
        public ID                   id      {get; set;}
        public String               title   {get; set;}
        public Boolean              checked {get; set;}
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
            // CUG / PUGs / PIA / WKTS Profiles
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

            if (headersPack.size() > 0)
                packages[0].checked = true;
        }
    }

    public class WrapperUser
    {
        public Contact con          {get; set;}

        public String  chosenRT     {get; set;}
        public Boolean userSelected {get; set;}
        public Boolean testUser     {get; set;}

        public WrapperPermissions currentSelection;

        private ProvisioningUserMgt parent;

        public WrapperUser(Contact c, String cug, String pugs, String pia,String profiles, ProvisioningUserMgt p)
        {
            con = c;

            List<String> lstPUGs = ((pugs == null) || (pugs == '')) ? null : pugs.split(';');

            List<String> lstProfiles = ((profiles == null) || (profiles == '')) ? null : profiles.split(';');

            currentSelection  = new WrapperPermissions(cug, lstPUGs, pia,lstProfiles, p.serviceHeaders, p.packageHeaders);

            userSelected = false;
            testUser     = false;
            parent       = p;

            // Apply default rights template + first package if available
            // Rights Template
            applyDefaultRT();

            // Package
            if (p.packageHeaders.size() > 0)
                currentSelection.packages[0].checked = true;
        }

        public WrapperPermissions getCurrentSelection()
        {
            return currentSelection;
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
                currentSelection.services[i].checked = template.services[i].checked;

                for (Integer j = 0; j < template.services[i].serviceAttr.size(); j++)
                    currentSelection.services[i].serviceAttr[j].checked = template.services[i].serviceAttr[j].checked;
            }
        }

        public void applyDefaultRT()
        {
            chosenRT = parent.rightsTemplates[0].getValue();
            applyRT();
        }
    }


    //********************//
    //------ Common ------//
    //********************//
    private final String regExpEmail = '[a-z0-9!#$%&\'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&\'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?';
    private final String regExpPhone = '^\\+[1-9][0-9]{0,2} [0-9]{6,14}';
    private Integer nbCreations = 0;
    List<WrapperService> serviceHeaders;
    List<WrapperPackage> packageHeaders;
    public Integer heightHeaders {get; set;}
    public Boolean noPackages {get; set;}
    public List<ID> userProfileIds;

    private final Provisioning__c prov;



    public ProvisioningUserMgt(ApexPages.StandardController controller)
    {
        Id provId = System.currentPagereference().getParameters().get('id');
        this.prov = [SELECT Id, Subscription__c, Subscription__r.Offer_Template__c, Subscription__r.Product__c, Subscription__r.CUG_allowed__c, Account__c, RecordTypeId, Account__r.BillingStreet, Account__r.BillingState, Account__r.BillingPostalCode, Account__r.BillingCountry, Account__r.BillingCity FROM Provisioning__c WHERE id = :provId];
    }

    public ProvisioningUserMgt(Id provId)
    {
        this.prov = [SELECT Id, Subscription__c, Subscription__r.Offer_Template__c, Subscription__r.Product__c, Subscription__r.CUG_allowed__c, Account__c, RecordTypeId, Account__r.BillingStreet, Account__r.BillingState, Account__r.BillingPostalCode, Account__r.BillingCountry, Account__r.BillingCity FROM Provisioning__c WHERE id = :provId];
    }

    public PageReference Cancel()
    {
        return (Utilities.Redirect(prov.id));
    }

    //********************//
    //------ Page 0 ------//
    //********************//
    public Boolean usersToFilter {get; set;}
    public Integer nbUsersMax;

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


    /* @Description : This method is called from step 1 page. Displays the number of contact.
    */
    public PageReference init0()
    {
        nbUsersMax = 500;

        if (lstAccountForPreFiltering == null)
        {
            // Account Ids list
            List<ID> accnts   = new ID[]{[SELECT Account__c FROM Provisioning__c WHERE Id = :this.prov.Id].Account__c};
            List<ID> parentId = new ID[]{accnts[0]};
            Integer nbAccnts  = 1;

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

            lstAccountForPreFiltering = [SELECT Id, Name, Debtor_Number__c, AccountNumber, Teleroute_Number__c, BillingCountry, BillingCity
                                         FROM Account WHERE Id IN :accnts LIMIT 1000];
        }

        List<ID> filteredLstIds   = new List<ID>();
        for (Account a : lstAccountForPreFiltering)
            filteredLstIds.add(a.Id);

        Integer count = countContacts(filteredLstIds, '', '');

        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, 'Account List: ' + filteredLstIds));
        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, 'count: ' + count));

        if (count > nbUsersMax)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,
                                'Too many contacts (' + count + ') have been found in this account hierarchy using the following filtering criteria. ' +
                                'The maximum number of users that can be displayed in a single page is ' + nbUsersMax + '. ' +
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

    /* @Description : This method used for filtering purpose on teleroute number, Account name, country etc
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

        Integer count = countContacts(filteredLstIds, nameFilteringMin, nameFilteringMax);

        if (count > nbUsersMax)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,
                            'Too many contacts (' + count + ') have been found in this account hierarchy using the following filtering criteria. ' +
                            'The maximum number of users that can be displayed in a single page is ' + nbUsersMax + '. ' +
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
                            'No user have been found in this account hierarchy using the following filtering criteria. ' +
                            'Please unfilter list before it can be displayed.'));

                usersToFilter = true;

                return null;
            }
        }
    }

    /* @Description : This method used for counting the contacts.
    */
    private Integer countContacts(List<ID> lst, String contactNameMin, String contactNameMax)
    {
        String query = 'SELECT Id FROM Contact ' +
                       'WHERE AccountId IN (';

        for (ID id : lst)
            query += '\'' + id + '\',';

        query = query.substring(0, query.length() - 1) + ') ' +
                'AND Id NOT IN (SELECT Contact__c FROM Subscription_User__c WHERE Subscription__c = \'' + prov.Subscription__c + '\') ' +
                'AND Id NOT IN (SELECT Contact__c FROM User_Profile__c WHERE Provisioning__c = \'' + this.prov.Id + '\')';

        if (contactNameMin != null && contactNameMin != '')
            query += ' AND Name >= \'' + contactNameMin + '\'';
        if (contactNameMax != null && contactNameMax != '')
            query += ' AND Name < \'' + contactNameMax + '\'';

        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, 'Query: ' + query));

        List<Contact> queryResult = Database.query(query);

        return queryResult.size();
    }

    //********************//
    //------ Page 1 ------//
    //********************//
    /* @Description : This method used for step1 page and populate the contact present in account hirarchy.
    */
    public PageReference Step1()
    {
        return Page.ProvisioningWizardS1;
    }

    List<ID> listAccountToScan;
    String contactNameMinToScan;
    String contactNameMaxToScan;

    List<WrapperSelectedContact> contactPreList;
    public List<WrapperSelectedContact> contactList;
    public List<WrapperSelectedContact> displayedList;
    public  Boolean preDataToDisplay {get; set;}
    public  Boolean dataToDisplay    {get; set;}
    public  Boolean selAll           {get; set;}
    public  Boolean selAllPre        {get; set;}
    public  String  filterFld        {get; set;}
    public  String  filterOp         {get; set;}
    public  String  filterVal        {get; set;}
    public  Boolean filterLookup     {get; set;}
    public List<SelectOption> filterFldOpt;
    public List<SelectOption> filterOpOpt;

    /* @Description : This method initialize the value of contacts.
    */
    public PageReference init()
    {
        createSets();

        //Filters
        if (filterFldOpt == null)
        {
            filterFldOpt = new List<SelectOption>();
            filterFldOpt.add(new SelectOption('Account.Name', 'Account Name'));
            filterFld    = filterFldOpt[0].getValue();
        }

        if (filterOpOpt == null)
        {
            filterOpOpt  = new List<SelectOption>();
            filterOpOpt.add(new SelectOption('eq', 'equals'));
            filterOpOpt.add(new SelectOption('neq', 'not equal to'));
            filterOpOpt.add(new SelectOption('str', 'starts with'));
            filterOpOpt.add(new SelectOption('end', 'ends with'));
            filterOp     = filterOpOpt[0].getValue();
            filterLookup = false;
        }

        //Contacts
        preDataToDisplay = true;
        dataToDisplay    = true;

        if (contactPreList == null)
        {
            contactPreList = new List<WrapperSelectedContact>();

            List<Subscription_User__c> subsUsers = [SELECT Id, Contact__c FROM Subscription_User__c
                                                    WHERE Subscription__c = :prov.Subscription__c
                                                    AND Contact__c NOT IN
                                                   (SELECT Contact__c FROM User_Profile__c
                                                    WHERE Provisioning__c = :this.prov.Id)
                                                    ORDER BY Contact__r.Name ASC LIMIT 1000];

            System.Debug('### subsUsers: ' + subsUsers);

            Set<ID> idContacts = new Set<ID>();
            for (Subscription_User__c subsUser : subsUsers)
                idContacts.add(subsUser.Contact__c);

            System.Debug('### idContacts: ' + idContacts);

            for (Contact c : [SELECT Id, Account.Name, Name, FirstName, LastName,Gender__c,Fax,MobilePhone,Phone, Email, Username__c, Product__c, Contact_Status__c, Key_contact_or_decision_maker__c, Cisco_Dial_Phone__c, Administrative_contact__c, Language__c
                              FROM Contact WHERE Id IN :idContacts])
            {
                contactPreList.add(new WrapperSelectedContact(c));
            }

            System.Debug('### contactPreList: ' + contactPreList);

            if (contactPreList.size() == 0)
                preDataToDisplay = false;
        }

        if (contactList == null)
        {
            contactList   = new List<WrapperSelectedContact>();
            displayedList = new List<WrapperSelectedContact>();

            /*// Account Ids list
            List<ID> accnts   = new ID[]{[SELECT Account__c FROM Provisioning__c WHERE Id = :this.prov.Id].Account__c};
            List<ID> parentId = new ID[]{accnts[0]};
            Integer nbAccnts  = 1;

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
            }*/

            // List of Contacts from listAccountToScan
            String query = 'SELECT  Id, Account.Name, Account.Debtor_Number__c, Account.AccountNumber, ' +
                                   'Account.Teleroute_Number__c, Account.BillingCountry, Account.BillingCity, ' +
                                   'Name, FirstName, LastName,Gender__c,Fax,MobilePhone, Phone, Email, Username__c, Product__c, Contact_Status__c, Key_contact_or_decision_maker__c, Cisco_Dial_Phone__c, Administrative_contact__c, Language__c ' +
                           'FROM Contact ' +
                           'WHERE AccountId IN (';

            for (ID id : listAccountToScan)
                query += '\'' + id + '\',';

            query = query.substring(0, query.length() - 1) + ') ' +
                    'AND Id NOT IN (SELECT Contact__c FROM Subscription_User__c WHERE Subscription__c = \'' + prov.Subscription__c + '\') ' +
                    'AND Id NOT IN (SELECT Contact__c FROM User_Profile__c WHERE Provisioning__c = \'' + this.prov.Id + '\')';

            if (contactNameMinToScan != null && contactNameMinToScan != '')
                query += ' AND Name >= \'' + contactNameMinToScan + '\'';
            if (contactNameMaxToScan != null && contactNameMaxToScan != '')
                query += ' AND Name < \'' + contactNameMaxToScan + '\'';

            query += 'ORDER BY Name ASC';

            List<Contact> lstContactFound = Database.query(query);

            for (Contact c : lstContactFound)
            {
                contactList.add(new WrapperSelectedContact(c));
                displayedList.add(contactList[contactList.size() - 1]);
                accountNames.add(c.Account.Name);
                if(c.Account.AccountNumber != null && c.Account.AccountNumber != '')
                    accountNumbers.add(c.Account.AccountNumber);
                if(c.Account.Teleroute_Number__c != null && c.Account.Teleroute_Number__c != '')
                    tlrNumbers.add(c.Account.Teleroute_Number__c);
                if(c.Account.Debtor_Number__c != null && c.Account.Debtor_Number__c != '')
                    debtorNumbers.add(c.Account.Debtor_Number__c);
                if(c.Account.BillingCountry != null && c.Account.BillingCountry != '')
                    billingCountries.add(c.Account.BillingCountry);
                if(c.Account.BillingCity != null && c.Account.BillingCity != '')
                    cities.add(c.Account.BillingCity);
            }

            dataToDisplay = (displayedList.size() > 0);
        }

        fillOptions();

        // Create the filtering utility component
        fu = new FilteringUtils(this);

        return null;
    }

    public List<WrapperSelectedContact> getDisplayedList()
    {
        return displayedList;
    }

    public List<WrapperSelectedContact> getContactList()
    {
        return contactList;
    }

    public List<WrapperSelectedContact> getContactPreList()
    {
        return contactPreList;
    }

    public void selectAll()
    {
        for (WrapperSelectedContact c : displayedList)
            c.selected = selAll;
    }

    public void selectAllPre()
    {
        for (WrapperSelectedContact c : contactPreList)
            c.selected = selAllPre;
    }

    public List<SelectOption> getFilterFldOpt()
    {
        return filterFldOpt;
    }

    public List<SelectOption> getFilterOpOpt()
    {
        return filterOpOpt;
    }

    /* @Description : This method used for filter purpose.
    */
    public void applyFilter()
    {
        List<String> parts = filterFld.split('\\.');

        displayedList.clear();
        for (WrapperSelectedContact c : contactList)
        {
            Object input;
            if (parts.size() > 1)
            {
                SObject a = c.con.getSObject(parts[0]);
                input     = a.get(parts[1]);
            }
            else
                input     = c.con.get(parts[0]);

            if (compare((String)input, filterOp, filterVal))
                displayedList.add(c);
        }

        dataToDisplay = (displayedList.size() > 0);
        filterFld = filterFldOpt[0].getValue();
        filterOp  = filterOpOpt[0].getValue();
        filterVal = '';
    }

    public Boolean compare(String input, String op, String val)
    {
        if (op == 'eq')
            return (input == val);
        else if (op == 'neq')
            return (input != val);
        else if (op == 'str')
            return input.startsWith(val);
        else if (op == 'end')
            return input.endsWith(val);
        else
            return false;
    }


    //********************//
    //------ Page 2 ------//
    //********************//

    /* @Description : This method used for step2 page and creates the contact.
    */
    public PageReference Step2()
    {
        return Page.ProvisioningWizardS2;
    }

    public List<WrapperField> fieldsContact;
    List<WrapperCreatedContact> newContacts;
    WrapperCreatedContact firstCon;
    public Integer indexContact {get; set;}
    public Integer nbCreated    {get; set;}

    /* @Description : This method initialize the value of contacts fields such as FirstName, lastname, gender etc.
    */
    public PageReference init2()
    {
        if (fieldsContact == null)
        {
            fieldsContact = new List<WrapperField>();
            Map<String, Schema.SObjectField> mapFlds = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap();

            fieldsContact.add(new WrapperField(mapFlds.get('FirstName').getDescribe()));
            fieldsContact.add(new WrapperField(mapFlds.get('LastName').getDescribe()));
            fieldsContact.add(new WrapperField(mapFlds.get('Gender__c').getDescribe()));
            fieldsContact.add(new WrapperField(mapFlds.get('Language__c').getDescribe()));
            fieldsContact.add(new WrapperField(mapFlds.get('Phone').getDescribe()));
            fieldsContact.add(new WrapperField(mapFlds.get('Email').getDescribe()));
        }

        if (newContacts == null)
        {
            newContacts = new WrapperCreatedContact[]{new WrapperCreatedContact(fieldsContact)};
            firstCon    = newContacts[0];
            nbCreated   = 1;
        }

        return null;
    }

    public List<WrapperCreatedContact> getNewContacts()
    {
        return newContacts;
    }

    public WrapperCreatedContact getFirstCon()
    {
        return firstCon;
    }

    public List<WrapperField> getFieldsContact()
    {
        return fieldsContact;
    }

    /* @Description : This method validates the business rules.
    */
    public void addNewContact()
    {
        // Check if the fields are all filled and in correct format
        Boolean checkResult = true;

        for (WrapperField field : newContacts[nbCreated - 1].fields)
        {
            if (field.value == '')
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, 'Missing Field: ' + field.title));
                checkResult = false;
                break;
            }
            else if (field.dspType == Schema.DisplayType.Email)
            {
                if (!Pattern.matches(regExpEmail, field.value))
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, 'Invalid Email Address'));
                    checkResult = false;
                    break;
                }
            }
            else if (field.dspType == Schema.DisplayType.Phone)
            {
                // remove trailing spaces in phone number
                while(field.value.endsWith(' '))
                    field.value = field.value.substring(0, field.value.length() - 1);

                if (!Pattern.matches(regExpPhone, field.value))
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, 'Phone must be International format, e.g: +99 12345678'));
                    checkResult = false;
                    break;
                }
            }
        }

        if (checkResult)
        {
            for (WrapperField field : newContacts[nbCreated - 1].fields)
                newContacts[nbCreated - 1].con.put(field.apiName, field.value);
            newContacts.add(new WrapperCreatedContact(fieldsContact));
            nbCreated++;
        }
    }

    public void rmvContact()
    {
        newContacts.remove(indexContact - 1);
        nbCreated--;
    }

    //********************//
    //------ Page 3 ------//
    //********************//

    /* @Description : This method used for step3 page and populates the service, service attribute matrix.
    */
    public PageReference Step3()
    {
        return (checkAndRedirect(false));
    }

    /* @Description : This method used to redirect and enable service, service attribute matrix.
    */
    public PageReference Step4()
    {
        return (checkAndRedirect(true));
    }

    Boolean checkResultFilled;

    /* @Description : This method used to redirect and enable service, service attribute matrix.
    */
    public PageReference checkAndRedirect(Boolean rdonly)
    {
        // Check if the fields are all filled or all empty
        checkResultFilled        = true;
        Boolean checkResultEmpty = true;
        Boolean emailCheck       = true;
        Boolean phoneCheck       = true;

        for (WrapperField field : newContacts[nbCreated - 1].fields)
        {
            if (field.dspType != Schema.DisplayType.PickList)
            {
                checkResultFilled = checkResultFilled && (field.value != '');
                checkResultEmpty  = checkResultEmpty  && (field.value == '');

                if (!checkResultFilled && !checkResultEmpty)
                    break;
                else if (field.dspType == Schema.DisplayType.Email)
                {
                    if (!Pattern.matches(regExpEmail, field.value))
                    {
                        emailCheck = false;
                        break;
                    }
                }
                else if (field.dspType == Schema.DisplayType.Phone)
                {
                    if (!Pattern.matches(regExpPhone, field.value))
                    {
                        phoneCheck = false;
                        break;
                    }
                }
            }
        }

        // Check if some contacts have been selected/created
        Integer nbContacts = 0;
        for (WrapperSelectedContact cw : contactPreList)
        {
            if (cw.selected) nbContacts++;
        }
        for (WrapperSelectedContact cw : contactList)
        {
            if (cw.selected) nbContacts++;
        }
        nbContacts += (nbCreated - 1);
        nbContacts += (checkResultFilled ? 1 : 0);

        if (!checkResultFilled && !checkResultEmpty)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Some fields are missing to crete a new Contact.'));
            return null;
        }
        else if (!checkResultEmpty && !emailCheck)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Invalid Email Address.'));
            return null;
        }
        else if (!checkResultEmpty && !phoneCheck)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Phone must be International format, e.g: +99 12345678'));
            return null;
        }
        else if (nbContacts == 0)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'No contact have been selected in the previous steps and no contact have been created in this step.'));
            return null;
        }
        else if (nbContacts > 50)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'You have exceeded the maximum number of contacts selected/created for a single provisioning request. Please reduce this number (max. 50).'));
            return null;
        }
        else
        {
            readonly = rdonly;
            return Page.ProvisioningWizardS3;
        }
    }

    List<WrapperUser> users;
    public Boolean readonly         {get; set;}

    List<SelectOption> rightsTemplates;
    public String  rightsTemplate {get; set;}
    public Boolean selAllUsers    {get; set;}

    public Boolean isHQProfile    {get; set;}
    public Boolean isAdminProfile {get; set;}

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
    public List<String> selectedBridgeProfiles{get;set;}

    String idCUGOpen    = '';
    String idPIADefault = '';

    /* @Description : This method initialise the value of PUG, CUG, PIA, WKTS profile and right template.
    */
    public PageReference init3()
    {
        TLRHQProfileSettings__c profileCS = TLRHQProfileSettings__c.getValues('TLR HQ');
        AdminProfileSettings__c adminCS   = AdminProfileSettings__c.getValues('SysAdmin');

        isHQProfile     = (UserInfo.getProfileId() == profileCS.Profile_ID__c);
        isAdminProfile  = (UserInfo.getProfileId() == adminCS.Profile_ID__c);

        heightHeaders = (isHQProfile || isAdminProfile) ? 54 : 36;

        if (availableBridgeProfiles == null){
            availableBridgeProfiles = new List<SelectOption>();

            availableBridgeProfiles.add(new SelectOption('--NONE--','--NONE--'));
            List <Schema.PicklistEntry> vals = Schema.getGlobalDescribe().get('User_Profile__c').getDescribe().fields.getMap().get('WKTS_Profiles__c').getDescribe().getPicklistValues();
            for (Schema.PicklistEntry val : vals){
                if(val.getValue() != null && val.getValue() != '')
                   availableBridgeProfiles.add(new SelectOption(val.getValue(), val.getLabel()));
            }
        }

        if (availableCUGs == null)
        {
            availableCUGs = new List<SelectOption>();

            // List creation
            if (this.prov.Subscription__r.CUG_allowed__c)
            {
                List <Schema.PicklistEntry> vals = Schema.getGlobalDescribe().get('User_Profile__c').getDescribe().fields.getMap().get('Private_Exchange_ID__c').getDescribe().getPicklistValues();
                for (Schema.PicklistEntry val : vals)
                    availableCUGs.add(new SelectOption(val.getValue(), val.getLabel()));
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

        if (serviceHeaders == null)
        {
            serviceHeaders = new List<WrapperService>();

            List<Provisioning_Service__c> provServices = [SELECT Id, Service__c, Service__r.Name,
                                                         (SELECT Id, Service_Attribute__c, Service_Attribute__r.Name
                                                          FROM Provisioning_Service_Attributes__r)
                                                          FROM Provisioning_Service__c
                                                          WHERE Provisioning__c = :prov.Id];
            for (Provisioning_Service__c provService : provServices)
            {
                serviceHeaders.add(new WrapperService(provService.Service__r.Name, provService.Id));

                if (provService.Provisioning_Service_Attributes__r.size() > 0)
                {
                    Integer lastIndex = serviceHeaders.size() - 1;

                    for (Provisioning_Service_Attribute__c servattr : provService.Provisioning_Service_Attributes__r)
                        serviceHeaders[lastIndex].serviceAttr.add(new WrapperServiceAttr(servattr.Service_Attribute__r.Name, servattr.id, serviceHeaders[lastIndex]));
                }
            }
        }

        for (WrapperService servH : serviceHeaders)
        {
            heightHeaders = Math.max(heightHeaders, (servH.title != null ? servH.title.length() : 0) * 6);

            for (WrapperServiceAttr servAttrH : servH.serviceAttr)
                heightHeaders = Math.max(heightHeaders, (servAttrH.title != null ? (servAttrH.title.length() + 10) : 10) * 6);
        }

        if (packageHeaders == null)
        {
            packageHeaders = new List<WrapperPackage>();

            List<Subs_Package_And_Fee__c> packages = [SELECT Id, Name, Type__c FROM Subs_Package_And_Fee__c WHERE Subscription__c = :this.prov.Subscription__c AND Type__c = 'Package'];

            for (Subs_Package_And_Fee__c pack : packages)
                packageHeaders.add(new WrapperPackage(pack.Name, pack.id, packageHeaders));

            noPackages = (packageHeaders.size() == 0);
        }

        for (WrapperPackage packH : packageHeaders)
            heightHeaders = Math.max(heightHeaders, (packH.title != null ? packH.title.length() : 0) * 6);

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

                System.debug('**lstProfiles=RT=>'+lstProfiles);
                defRightsTemplate.put(rightsTpl.Id, new WrapperPermissions(rightsTpl.Private_Exchange_ID__c, lstPUGs, rightsTpl.PIA_Interface__c,lstProfiles, serviceHeaders, packageHeaders));

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

            for (WrapperSelectedContact cw : contactPreList)
            {
                if (cw.selected) users.add(new WrapperUser(cw.con, idCUGOpen, null, idPIADefault,null, this));
            }

            for (WrapperSelectedContact cw : contactList)
            {
                if (cw.selected) users.add(new WrapperUser(cw.con, idCUGOpen, null, idPIADefault,null, this));
            }

            nbCreations = checkResultFilled ? nbCreated : nbCreated - 1;

            if (checkResultFilled)
            {
                for (WrapperField field : newContacts[nbCreated - 1].fields)
                    newContacts[nbCreated - 1].con.put(field.apiName, field.value);
            }
            for (Integer i = 0; i < nbCreations; i++)
                users.add(new WrapperUser(newContacts[i].con, idCUGOpen, null, idPIADefault,null, this));
        }

        if (userProfileIds == null)
            userProfileIds = new List<ID>();

        heightHeaders += 30;

        // code is to show available Bridge Profiles
        //selectedBridgeProfiles = new List <String>();
      /*  availableBridgeProfiles = new List<SelectOption>();

        availableBridgeProfiles.add(new SelectOption('---NONE---','---NONE---'));
        availableBridgeProfiles.add(new SelectOption('Profile 1','Profile 1'));
        availableBridgeProfiles.add(new SelectOption('Profile 2','Profile 2'));
        availableBridgeProfiles.add(new SelectOption('Profile 3','Profile 3'));
        */

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

     public List<SelectOption> getAvailableBridgeProfiles()
    {
        return availableBridgeProfiles;
    }

    public void selectAllContacts()
    {
        for (WrapperUser u : users)
            u.userSelected = selAllUsers;
    }

    /* @Description : This method used to apply right template.
    */
    public void applyRT()
    {
        Integer nbUpdate = 0;

        for (WrapperUser u : users)
        {
           // if (u.userSelected)
           // {
                u.chosenRT = rightsTemplate;
                u.applyRT();
                nbUpdate++;
           // }
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
            u.currentSelection.cug = selectedCUG;
    }

    public void applyPUGs()
    {
        for (WrapperUser u : users)
            u.currentSelection.pugs = selectedPUGs;
    }

    public void applyPIA()
    {
        for (WrapperUser u : users)
            u.currentSelection.pia = selectedPIA;
    }

    public void applyService()
    {
        if (!serviceHeaders[serviceToApply].checked)
        {
            for (WrapperServiceAttr servat : serviceHeaders[serviceToApply].serviceAttr)
                servat.checked = false;
        }

        for (WrapperUser u : users)
        {
            if (!serviceHeaders[serviceToApply].checked)
            {
                for (WrapperServiceAttr servat : u.currentSelection.services[serviceToApply].serviceAttr)
                    servat.checked = false;
            }
            u.currentSelection.services[serviceToApply].checked = serviceHeaders[serviceToApply].checked;
        }
    }

    public void applyServiceAttribute()
    {
        if (serviceHeaders[serviceToApply].serviceAttr[serviceAttrToApply].checked)
            serviceHeaders[serviceToApply].checked = true;

        for (WrapperUser u : users)
        {
            if (serviceHeaders[serviceToApply].serviceAttr[serviceAttrToApply].checked)
                u.currentSelection.services[serviceToApply].checked = serviceHeaders[serviceToApply].checked;
            u.currentSelection.services[serviceToApply].serviceAttr[serviceAttrToApply].checked = serviceHeaders[serviceToApply].serviceAttr[serviceAttrToApply].checked;
        }
    }

    /* @Description : This method insert UP, UPS, UPSA and update the contact as well as provisioning.
                      Calls the ESB webservice method.
    */
    public PageReference Finish()
    {
         userProfileIds.clear();

        // Create new contacts
        try
        {
            List<Contact> conToInsert = new List<Contact>();
             System.Debug('## nbCreations:' + nbCreations);
            for (Integer i = 0; i < nbCreations; i++)
            {
                newContacts[i].con.AccountId         = this.prov.Account__c;
                newContacts[i].con.MailingStreet     = this.prov.Account__r.BillingStreet;
                newContacts[i].con.MailingState      = this.prov.Account__r.BillingState;
                newContacts[i].con.MailingPostalCode = this.prov.Account__r.BillingPostalCode;
                newContacts[i].con.MailingCountry    = this.prov.Account__r.BillingCountry;
                newContacts[i].con.MailingCity       = this.prov.Account__r.BillingCity;
                conToInsert.add(newContacts[i].con);
            }
            System.Debug('## conToInsert:' + conToInsert);
            if (conToInsert.size() > 0)
                insert conToInsert;
        }
        catch (Exception e)
        {
            Generic.StandardException ex = new Generic.StandardException();
            ex.SetMessage('Error: Contacts creation: ' + e.getMessage());
            throw ex;
        }

        System.Debug('## Start User profile creation');

        // User profiles creation
        List<User_Profile__c> upToInsert = new List<User_Profile__c>();

        try
        {
            List<String> recordTypeWords = Schema.getGlobalDescribe().get('Provisioning__c').getDescribe().getRecordTypeInfosById().get(this.prov.RecordTypeId).getName().split(' ');
            ID recordTypeUP              = Schema.getGlobalDescribe().get('User_Profile__c').getDescribe().getRecordTypeInfosByName().get(recordTypeWords[0] + ' User Profile').getRecordTypeId();

            System.Debug('## recordTypeUP:' + recordTypeWords[0] + ' User Profile');

            for (WrapperUser u : users)
            {
                // Package
                Integer indexPack = -1;

                for (Integer pack = 0; pack < packageHeaders.size(); pack++)
                {
                    if (u.currentSelection.packages[pack].checked) indexPack = pack;
                }

                User_Profile__c upro         = new User_Profile__c();
                upro.RecordTypeId            = recordTypeUP;
                upro.Contact__c              = u.con.Id;
                upro.Offer_Template__c       = this.prov.Subscription__r.Offer_Template__c;
                upro.Product__c              = this.prov.Subscription__r.Product__c;
                upro.Provisioning__c         = this.prov.Id;
                upro.Status__c               = 'Waiting for provisioning';
                upro.Test_login__c           = u.testUser;
                upro.Package_And_Fee__c      = ((indexPack >= 0) ? packageHeaders[indexPack].id : null);
                upro.Private_Exchange_ID__c  = u.currentSelection.cug;
                upro.PIA_Interface__c        = u.currentSelection.pia;
                upro.User_PUG_Name__c        = '';
                //upro.WKTS_Profiles__c      = u.currentSelection.WktsProfileName;
               if(u.currentSelection.profiles != null){
                    for (String profileName : u.currentSelection.profiles){
                        System.debug('**profileName=>'+profileName);
                        if (profileName != null && profileName != ''){
                            if(upro.WKTS_Profiles__c != null && upro.WKTS_Profiles__c != '')
                                upro.WKTS_Profiles__c = upro.WKTS_Profiles__c+';'+profileName;
                            else
                                upro.WKTS_Profiles__c = profileName;
                            System.debug('**upro.WKTS_Profiles__c=>'+upro.WKTS_Profiles__c);
                        }
                    }
               }
                for (String s : u.currentSelection.pugs)

                        upro.User_PUG_Name__c += s + ';';

                System.Debug('## upToInsert:' + upro);

                upToInsert.add(upro);
            }
            System.Debug('********upToInsert:' + upToInsert);
            if (upToInsert.size() > 0)
                insert upToInsert;
        }
        catch (Exception e)
        {
            Generic.StandardException ex = new Generic.StandardException();
            ex.SetMessage('Error: User Profiles insert: ' + e.getMessage());
            throw ex;
        }

        for (User_Profile__c up : upToInsert)
            userProfileIds.add(up.Id);


        // Services
        try
        {
            List<User_Profile_Service__c> upsToInsert = new List<User_Profile_Service__c>();

            for (Integer i = 0; i < users.size(); i++)
            {
                WrapperUser u = users[i];

                for (Integer serv = 0; serv < serviceHeaders.size(); serv++)
                {
                    System.Debug('#### Service:' + serviceHeaders[serv].id + '/' + serviceHeaders[serv].title);
                    System.Debug('#### Current:' + u.currentSelection.services[serv].checked);

                    if (u.currentSelection.services[serv].checked)
                    {
                        // Add new permission (service)
                        User_Profile_Service__c ups = new User_Profile_Service__c();
                        ups.Name                    = serviceHeaders[serv].title;
                        ups.Provisioning_Service__c = serviceHeaders[serv].id;
                        ups.User_Profile__c         = upToInsert[i].Id;
                        upsToInsert.add(ups);
                    }
                }
            }

            if (upsToInsert.size() > 0)
                insert upsToInsert;
        }
        catch (Exception e)
        {
            Generic.StandardException ex = new Generic.StandardException();
            ex.SetMessage('Error: User Profile Services insert: ' + e.getMessage());
            throw ex;
        }


        // Service attributes
        List<User_Profile_Service__c> lstUserProfileServ = [SELECT Id, Provisioning_Service__c, User_Profile__c
                                                            FROM User_Profile_Service__c
                                                            WHERE User_Profile__c IN :upToInsert];

        Map<ID, Map<ID, ID>> mapUpProvServUpServ = new Map<ID, Map<ID, ID>>();

        for (User_Profile_Service__c ups : lstUserProfileServ)
        {
            if (mapUpProvServUpServ.get(ups.User_Profile__c) == null)
                mapUpProvServUpServ.put(ups.User_Profile__c, new Map<ID, ID>());

            mapUpProvServUpServ.get(ups.User_Profile__c).put(ups.Provisioning_Service__c, ups.Id);
        }

        try
        {
            List<User_Profile_Service_Attribute__c> upsaToInsert = new List<User_Profile_Service_Attribute__c>();

            for (Integer i = 0; i < users.size(); i++)
            {
                WrapperUser u = users[i];

                for (Integer serv = 0; serv < serviceHeaders.size(); serv++)
                {
                    System.Debug('##### Service:' + serviceHeaders[serv].id + '/' + serviceHeaders[serv].title);

                    for (Integer servat = 0; servat < serviceHeaders[serv].serviceAttr.size(); servat++)
                    {
                        System.Debug('##### Service attribute:' + serviceHeaders[serv].serviceAttr[servat].id + '/' + serviceHeaders[serv].serviceAttr[servat].title);
                        System.Debug('##### Current:' + u.currentSelection.services[serv].serviceAttr[servat].checked);

                        if (u.currentSelection.services[serv].serviceAttr[servat].checked)
                        {
                            // Add new permission (service attribute)
                            User_Profile_Service_Attribute__c upsa = new User_Profile_Service_Attribute__c();
                            upsa.Name                              = serviceHeaders[serv].serviceAttr[servat].title;
                            upsa.Provisioning_Service_Attribute__c = serviceHeaders[serv].serviceAttr[servat].id;
                            upsa.User_Profile_Service__c           = mapUpProvServUpServ.get(upToInsert[i].Id).get(serviceHeaders[serv].id);
                            upsaToInsert.add(upsa);
                        }
                    }
                }
            }

            if (upsaToInsert.size() > 0)
                insert upsaToInsert;
        }
        catch (Exception e)
        {
            Generic.StandardException ex = new Generic.StandardException();
            ex.SetMessage('Error: User Profile Service Attributes insert: ' + e.getMessage());
            throw ex;
        }

        System.Debug('## End User profile creation');

        return null;
    }

    public PageReference Step5()
    {
        return Page.ProvisioningWizardS4;
    }

    /* @Description : This method used to send the record to ESB after some time delay.
    */
    public PageReference Provision()
    {
        System.Debug('## Start Provision function');
        System.Debug('## userProfileIds:' + userProfileIds);

        if (userProfileIds.size() > 0)
            ProvisioningMessages.SendInitialProvisioningRequests(userProfileIds);

        System.Debug('## End Provision function');

        return (Utilities.Redirect(this.prov.Id));
    }

    /* @Description : This method used to insert user profile.
    */
    public Id CreateUserProfile(Id contactId)
    {
        User_Profile__c upro        = new User_Profile__c();

        try
        {
            upro.Contact__c             = contactId;
            upro.Offer_Template__c      = this.prov.Subscription__r.Offer_Template__c;
            upro.Product__c             = this.prov.Subscription__r.Product__c;
            upro.Provisioning__c        = this.prov.Id;
            upro.Status__c              = 'Waiting for provisioning';
            upro.Test_login__c          = false;
            upro.Package_And_Fee__c     = null;
            upro.Private_Exchange_ID__c = 'OPEN';
            upro.User_PUG_Name__c       = '';
            upro.PIA_Interface__c       = '-1';
            insert upro;
        }
        catch (Exception e)
        {
            Generic.StandardException ex = new Generic.StandardException();
            ex.SetMessage('Error: CreateUserProfile: ' + e.getMessage());
            throw ex;
        }

        return upro.Id;
    }

    /* @Description : This method used to insert UP, UPS, UPSA
    */
    public void AddProductRights(Id uprofileId)
    {
        Map<ID, ID> mapIdProv = new Map<ID, ID>();

        List<Provisioning_Service__c> provServices = [SELECT Id, Service__c, Service__r.Name,
                                                     (SELECT Id, Service_Attribute__c, Service_Attribute__r.Name
                                                      FROM Provisioning_Service_Attributes__r)
                                                      FROM Provisioning_Service__c
                                                      WHERE Provisioning__c = :this.prov.Id];

        for (Provisioning_Service__c provService : provServices)
        {
            mapIdProv.put(provService.Service__c, provService.Id);
            for (Provisioning_Service_Attribute__c serviceAttribute : provService.Provisioning_Service_Attributes__r)
                    mapIdProv.put(serviceAttribute.Service_Attribute__c, serviceAttribute.Id);
        }

        ID idRT = [SELECT Id FROM Rights_Template__c WHERE Provisioning__c = :this.prov.Id AND Default__c = true LIMIT 1].Id;
        List<Rights_Template_Service__c> rtServices = [SELECT Id, Service__c, Service__r.Name,
                                                      (SELECT Id, Service_Attribute__c, Service_Attribute__r.Name
                                                       FROM Rights_Template_Service_Attributes__r)
                                                       FROM Rights_Template_Service__c
                                                       WHERE Rights_Template__c = :idRT];

        try
        {
            Map<ID, ID> mapRTServIdUPSId = new Map<ID, ID>();

            List<User_Profile_Service__c> upsToInsert = new List<User_Profile_Service__c>();

            for (Rights_Template_Service__c rtService : rtServices)
            {
                User_Profile_Service__c ups = new User_Profile_Service__c();
                ups.Name                    = rtService.Service__r.Name;
                ups.Provisioning_Service__c = mapIdProv.get(rtService.Service__c);
                ups.User_Profile__c         = uprofileId;

                upsToInsert.add(ups);
            }

            if (upsToInsert.size() > 0)
                insert upsToInsert;

            for (Integer i = 0; i < rtServices.size(); i++)
                mapRTServIdUPSId.put(rtServices[i].Id, upsToInsert[i].Id);


            List<User_Profile_Service_Attribute__c> upsaToInsert = new List<User_Profile_Service_Attribute__c>();

            for (Rights_Template_Service__c rtService : rtServices)
            {
                for (Rights_Template_Service_Attribute__c serviceAttribute : rtService.Rights_Template_Service_Attributes__r)
                {
                    User_Profile_Service_Attribute__c upsa = new User_Profile_Service_Attribute__c();
                    upsa.Name                              = serviceAttribute.Service_Attribute__r.Name;
                    upsa.Provisioning_Service_Attribute__c = mapIdProv.get(serviceAttribute.Service_Attribute__c);
                    upsa.User_Profile_Service__c           = mapRTServIdUPSId.get(rtService.Id);
                    upsaToInsert.add(upsa);
                }
            }

            if (upsaToInsert.size() > 0)
                insert upsaToInsert;
        }
        catch (Exception e)
        {
            Generic.StandardException ex = new Generic.StandardException();
            ex.SetMessage('Error: AddProductRights: ' + e.getMessage());
            throw ex;
        }
    }

    public void AddFlashRights(Id uprofileId, String typeAbo, String frequency)
    {
        Map<ID, ID> mapIdProv          = new Map<ID, ID>();
        Map<String, ID> mapIdServFlash = new Map<String, ID>();

        List<Provisioning_Service__c> provServices = [SELECT Id, Service__c, Service__r.Name,
                                                     (SELECT Id, Service_Attribute__c, Service_Attribute__r.Name
                                                      FROM Provisioning_Service_Attributes__r)
                                                      FROM Provisioning_Service__c
                                                      WHERE Provisioning__c = :this.prov.Id];

        for (Provisioning_Service__c provService : provServices)
        {
            mapIdProv.put(provService.Service__c, provService.Id);
            for (Provisioning_Service_Attribute__c serviceAttribute : provService.Provisioning_Service_Attributes__r)
                mapIdProv.put(serviceAttribute.Service_Attribute__c, serviceAttribute.Id);

            if ((provService.Service__r.Name == 'Flash Subscription Monthly') ||
                (provService.Service__r.Name == 'Flash Subscription Yearly') ||
                (provService.Service__r.Name == 'Flash Act'))
                mapIdServFlash.put(provService.Service__r.Name, provService.Id);
        }

        ID idRT = [SELECT Id FROM Rights_Template__c WHERE Provisioning__c = :this.prov.Id AND Default__c = true LIMIT 1].Id;
        List<Rights_Template_Service__c> rtServices = [SELECT Id, Service__c, Service__r.Name,
                                                      (SELECT Id, Service_Attribute__c, Service_Attribute__r.Name
                                                       FROM Rights_Template_Service_Attributes__r)
                                                       FROM Rights_Template_Service__c
                                                       WHERE Rights_Template__c = :idRT];

        try
        {
            for (Rights_Template_Service__c rtService : rtServices)
            {
                if (rtService.Service__r.Name != 'Flash Free' || (typeAbo != 'Flash_subscription' && typeAbo != 'Flash_volume'))
                {
                    User_Profile_Service__c ups = new User_Profile_Service__c();
                    ups.Name = rtService.Service__r.Name;
                    ups.Provisioning_Service__c = mapIdProv.get(rtService.Service__c);
                    ups.User_Profile__c = uprofileId;
                    insert ups;

                    for (Rights_Template_Service_Attribute__c serviceAttribute : rtService.Rights_Template_Service_Attributes__r)
                    {
                        User_Profile_Service_Attribute__c upsa = new User_Profile_Service_Attribute__c();
                        upsa.Name = serviceAttribute.Service_Attribute__r.Name;
                        upsa.Provisioning_Service_Attribute__c = mapIdProv.get(serviceAttribute.Service_Attribute__c);
                        upsa.User_Profile_Service__c = ups.Id;
                        insert upsa;
                    }
                }
            }

            if (typeAbo == 'Flash_subscription' || typeAbo == 'Flash_volume')
            {
                User_Profile_Service__c ups = new User_Profile_Service__c();
                if (typeAbo == 'Flash_subscription' && frequency == '1 Month')
                {
                    ups.Name = 'Flash Subscription Monthly';
                    ups.Provisioning_Service__c = mapIdServFlash.get(ups.Name);
                }
                else if (typeAbo == 'Flash_subscription' && frequency == '12 Months')
                {
                    ups.Name = 'Flash Subscription Yearly';
                    ups.Provisioning_Service__c = mapIdServFlash.get(ups.Name);
                }
                else if (typeAbo == 'Flash_volume')
                {
                    ups.Name = 'Flash Act';
                    ups.Provisioning_Service__c = mapIdServFlash.get(ups.Name);
                }
                ups.User_Profile__c = uprofileId;

                insert ups;
            }
        }
        catch (Exception e)
        {
            Generic.StandardException ex = new Generic.StandardException();
            ex.SetMessage('Error: AddFlashRights: ' + e.getMessage());
            throw ex;
        }
    }

    //////////////////////////////////////////////////////
    //             Filtering considerations             //
    //////////////////////////////////////////////////////

    private FilteringUtils fu;

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

    /////////////////////////////////////////////////////////
    //             Prefiltering considerations             //
    /////////////////////////////////////////////////////////

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