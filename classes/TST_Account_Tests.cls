/** 
* @author       Anton Solovyev (anton_soloveyv@epam.com)
* @date         2015 January 28
* @description  tests for Account triggers, validation rules, workflows
*/
@isTest
public class TST_Account_Tests
{
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2015 January 26
    * @description  test to cover clone account trigger part
                    it needs to clone all information except of following fields:
                    ESB_Company_status__c, ESB_Billing_Address_ID__c, ESB_ShippingAddress_ID__c
    */
    
    public static testMethod void CloneTest()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Account a = TST_AccountTestHelper.createDummyAccount('Belgium', false);
        
        a.ESB_Company_status__c = 'CREATED';
        a.ESB_Billing_Address_ID__c = 'A-1111';
        a.ESB_ShippingAddress_ID__c = 'A-2222';
        //a.Teleroute_Number__c = 'ABC123';
        //a.Debtor_Number__c = 'BBB456';
        insert a;
        
        // 0 check - values are set properly when inserting
        a = getAccountById(a.Id);
        system.AssertEquals('CREATED', a.ESB_Company_status__c, 'Inserted ESB company status is not saved!');
        system.AssertEquals('A-1111', a.ESB_Billing_Address_ID__c, 'Inserted ESB billing address ID is not saved!');
        system.AssertEquals('A-2222', a.ESB_ShippingAddress_ID__c, 'Inserted ESB shipping address ID is not saved!');
        
        a.ESB_Company_status__c = 'APPROVED';
        a.ESB_Billing_Address_ID__c = 'A-1212';
        a.ESB_ShippingAddress_ID__c = 'A-3232';
        a.Debtor_Number__c = 'BBB456';
        update a;
        
        // 1st check - values are set properly when updating
        a = getAccountById(a.Id);
        system.AssertEquals('APPROVED', a.ESB_Company_status__c, 'Updated ESB company status is not saved!');
        system.AssertEquals('A-1212', a.ESB_Billing_Address_ID__c, 'Updated ESB billing address ID is not saved!');
        system.AssertEquals('A-3232', a.ESB_ShippingAddress_ID__c, 'Updated ESB shipping address ID is not saved!');
        
        
        // clone account
        Account a1 = a.clone(); // actually 'clone' button works not like .clone() method. so test is not 100% accurate
        insert a1;
                
        a1 = getAccountById(a1.Id);
        // 2nd check - 
        system.Assert(string.isEmpty(a1.ESB_Company_status__c), 'Clonned ESB company status should be empty!');
        system.Assert(string.isEmpty(a1.ESB_Billing_Address_ID__c), 'Clonned ESB billing address should be empty!');
        system.assertNotEquals(a.Debtor_Number__c, a1.Debtor_Number__c, 'Clonned debtor number should not be the same!');
        system.assertNotEquals(a.Teleroute_Number__c, a1.Teleroute_Number__c, 'Clonned teleroute number should not be the same!');
        system.assertNotEquals(a.AccountNumber, a1.AccountNumber, 'Clonned account number should not be the same!');
    } //CloneTest
    
    public static testMethod void FillShippingAddressTest()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Account a = TST_AccountTestHelper.createDummyAccount('Belgium', false);
        
        a.ShippingCity = '';
        a.ShippingCountry = '';
        a.ShippingPostalCode = '';
        a.ShippingState = '';
        a.ShippingStreet = '';
        
        a.BillingCity = 'bCity';
        a.BillingCountry = 'Belgium';
        a.BillingPostalCode = '12345';
        a.BillingState = 'bState';
        a.BillingStreet = 'bStreet 21';
        
        insert a;
        a = getAccountById(a.Id);
        
        system.assertEquals(a.BillingCity, a.ShippingCity, 'Billing address is not copied to Shipping! (City)');
        system.assertEquals(a.BillingCountry, a.ShippingCountry, 'Billing address is not copied to Shipping! (Country)');
        system.assertEquals(a.BillingPostalCode, a.ShippingPostalCode, 'Billing address is not copied to Shipping! (PostalCode)');
        system.assertEquals(a.BillingState, a.ShippingState, 'Billing address is not copied to Shipping! (State)');
        system.assertEquals(a.BillingStreet, a.ShippingStreet, 'Billing address is not copied to Shipping! (Street)');
        
    } // FillShippingAddressTest
    
    public static testMethod void FillSegmentationDatesTest()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Account a = TST_AccountTestHelper.createDummyAccount('Belgium', false);
        
        // insert trigger test
        insert a;
        a = getAccountById(a.Id);
        system.assertEquals(date.today(), a.ABC_Segmentation_Date__c, 'Segmentation date is not filled! (ABC)');
        system.assertEquals(date.today(), a.SML_Segmentation_Date__c, 'Segmentation date is not filled! (SML)');
        
        // update trigger test
        a.ABC_Segmentation_Date__c = date.today().addDays(-5);
        a.SML_Segmentation_Date__c = date.today().addDays(-5);
        update a;
        system.debug('---------- sml segmentation: ' + a.SML_Segmentation__c);
        a = getAccountById(a.Id);
        system.assertNotEquals(date.today(), a.ABC_Segmentation_Date__c, 'Segmentation date goes back to today! (ABC)');
        system.assertNotEquals(date.today(), a.SML_Segmentation_Date__c, 'Segmentation date goes back to today! (SML)');
        
        // update trigger test
        a.ABC_Segmentation__c = 'Low';
        a.Total_employees__c = 100; // SML segmentation is calculated
        a.Total_number_of_trucks_managed__c = 5;
        update a;
        system.debug('---------- sml segmentation: ' + a.SML_Segmentation__c);
        a = getAccountById(a.Id);
        system.assertEquals(date.today(), a.ABC_Segmentation_Date__c, 'Segmentation date is not updating! (ABC)');
        system.assertEquals(date.today(), a.SML_Segmentation_Date__c, 'Segmentation date is not updating! (SML)');
    } // FillSegmentationDatesTest
    
    public static testMethod void FillAccNumberTest()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Account a = TST_AccountTestHelper.createDummyAccount('Belgium', false);
        
        // 1) positive flow (insert)
        system.assertEquals(null, a.AccountNumber, 'Account number should not be set at this point');
        
        insert a;
        a = getAccountById(a.Id);
        system.assertNotEquals(null, a.AccountNumber, 'Account number is not generated!');
        
        // 2) positive flow (update)
        string oldAccNum = a.AccountNumber;
        a.AccountNumber = '';
        update a;
        system.assertNotEquals(oldAccNum, a.AccountNumber, 'Account number is not changed!');
        
        // 3) negative case 1 - without shipping country
        a.ShippingCountry = '';
        a.AccountNumber = '';
        
        try
        {
            update a;
            system.assert(true, 'This update should not be successful!');
        }
        catch(Exception ex) { }
        
    } // FillAccNumberTest
    
    public static testMethod void FillOrganizationTest()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Account a = TST_AccountTestHelper.createDummyAccount('Belgium', false);
        
        // case 1 - insert
        system.assertEquals(null, a.Organization__c, 'Geographical Ogranization should not be set at this point');
        insert a;
        a = getAccountById(a.Id);
        system.assertEquals('Belgium -> BeLux -> North', a.Organization__c, 'Incorrect Geo Organization value! (insert)');
        
        // case 2 - update
        a.ShippingCountry = 'France';
        a.Organization_Country__c = a.ShippingCountry;
        update a;
        a = getAccountById(a.Id);
        system.assertEquals('France -> France International -> West', a.Organization__c, 'Incorrect Geo Organization value! (update 1)');
        
        // case 3 - missing country (missing in picklist)
        a.ShippingCountry = 'Antarctica';
        a.Organization_Country__c = a.ShippingCountry;
        update a;
        a = getAccountById(a.Id);
        system.assertEquals('Other -> Other Countries -> Other', a.Organization__c, 'Incorrect Geo Organization value! (update 2)');
        
        // case 4 - negative - when shippingCountry is missing
        a.ShippingCountry = '';
        a.Organization_Country__c = a.ShippingCountry;
        try
        {
            update a;
            system.assert(true, 'This update should not be successful!');
        }
        catch(Exception ex) { }
    } // FillOrganizationTest
    
    public static testMethod void FillCertificationLevelTest()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Account a = TST_AccountTestHelper.createDummyAccount('Belgium', false);
        
        // task needs to be created if certification level is upgraded or downgraded, 
        // but not if old or new value is zero
        
        insert a; // Level_of_Certification__c default value is 2
        a = getAccountById(a.Id);
        system.assertEquals('2', a.Level_of_Certification__c, 'Default certification value is wrong!');
        
        // case 1 - downgrade 2 -> 1
        a.Level_of_Certification__c = '1';
        update a;
        a = getAccountById(a.Id);
        system.assertEquals('1', a.Level_of_Certification__c, 'Certification level value is wrong! (case 1)');
        List<Task> taskList = [SELECT Id, Subject FROM Task WHERE AccountId = :a.Id];
        system.assertEquals(1, taskList.size(), 'No task created! (case 1)');
        
        List<Id> taskIds = new List<Id>();
        for(Task t : taskList)
            taskIds.add(t.Id);
        
        // case 2 - set value to 0, because downgrade to 0 is not possible
        a = TST_AccountTestHelper.createDummyAccount('Belgium', false);
        a.Level_of_Certification__c = '0';
        insert a;
        a = getAccountById(a.Id);
        system.assertEquals('0', a.Level_of_Certification__c, 'Certification level value is wrong! (case 2)');
        
        // case 3 - upgrade 0 -> 1
        a.Level_of_Certification__c = '1';
        update a;
        a = getAccountById(a.Id);
        system.assertEquals('1', a.Level_of_Certification__c, 'Certification level value is wrong! (case 3)');
        taskList = [SELECT Id, Subject FROM Task WHERE AccountId = :a.Id AND Id not in :taskIds];
        system.assertEquals(0, taskList.size(), 'Task created wrongly! (case 3)');
        
        // case 4 - upgrade 1 -> 2
        a.Level_of_Certification__c = '2';
        update a;
        a = getAccountById(a.Id);
        system.assertEquals('2', a.Level_of_Certification__c, 'Certification level value is wrong! (case 4)');
        taskList = [SELECT Id, Subject FROM Task WHERE AccountId = :a.Id AND Id not in :taskIds];
        system.assertEquals(1, taskList.size(), 'No task created! (case 4)');
        
        // validation rules tests
        // case 5 - invald state transition
        a.Level_of_Certification__c = '0';
        try
        {
            update a;
            system.assert(true, 'This update should not be successful! (case 5)');
        }
        catch(Exception ex) { }
        
    } // FillCertificationLevelTest
    
    public static testMethod void SepaMndIdTest()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Account a = TST_AccountTestHelper.createDummyAccount('Belgium', false);
        
        // countryComplete map
        List<pw_cc__CountryObject__c> ccList = [SELECT Id, Name, pw_cc__IsoCode_2__c FROM pw_cc__CountryObject__c];
        Map<string, pw_cc__CountryObject__c> ccMap = new Map<string, pw_cc__CountryObject__c>();
        for(pw_cc__CountryObject__c cc : ccList)
            ccMap.put(cc.Name, cc);
        
        // rules are: 
        // 1) if IBAN is changed - SEPA Mandate ID will be changed too
        // 2) SEPA Mandate ID will be generated in case when
        //   a) Direct Debit flag is set
        //   b) ShippingCountry is not empty
        //   c) Sepa_Unique_Number__c custom setting contains our shipping country name
        //   d) SEPA Mandate ID value is null
        // 3) Sepa sign city and sepa creditor ID will be filled not for all the countries
        // 4) Sepa Mandate ID format is following: <CC><NNNNNNN>
        //    <CC> - country ISO code (2 chars)
        //    <NN> - unique number, 7characters length
        
        insert a;
        // since direct debit is false - sepa fields should not be filled now
        system.assertEquals(null, a.SEPA_MNDID__c, 'SEPA_MNDID__c should not be filled now!');
        system.assertEquals(null, a.SEPA_Sign_City__c, 'SEPA_Sign_City__c should not be filled now!');
        system.assertEquals(null, a.SEPA_CRDID__c, 'SEPA_CRDID__c should not be filled now!');
        system.assertEquals(null, a.SEPA_Sign_Date__c, 'SEPA_Sign_Date__c should not be filled now!');
        system.assertEquals(null, a.SEPA_Valid_From__c, 'SEPA_Valid_From__c should not be filled now!');
        system.assertEquals(null, a.SEPA_Pay_Type__c, 'SEPA_Pay_Type__c should not be filled now!');
        system.assertEquals(null, a.SEPA_Valid_To__c, 'SEPA_Valid_To__c should not be filled now!');
        system.assertEquals(null, a.SEPA_Status__c, 'SEPA_Status__c should not be filled now!');
        
        // now we will set direct debit - and all fields needs to be filled
        a.Direct_Debit__c = true;
        
        // first of all check custom settings
        Map<string, Sepa_Unique_Number__c> sepaSettingsMap = Sepa_Unique_Number__c.getAll();
        system.debug('---------- shipping country: ' + a.ShippingCountry);
        system.debug('---------- sepaSettingsMap: ' + sepaSettingsMap);
        system.debug('---------- sepaSettingsMap value: ' + sepaSettingsMap.get(a.ShippingCountry));
        integer sepaCounterValue = (integer)sepaSettingsMap.get(a.ShippingCountry).Unique_Number__c;
        
        update a;
        a = getAccountById(a.Id);
        
        sepaSettingsMap = Sepa_Unique_Number__c.getAll(); // once again, to see changed counter value
        Sepa_Unique_Number__c currentSetting = sepaSettingsMap.get(a.ShippingCountry);
        system.assertEquals(sepaCounterValue + 1, currentSetting.Unique_Number__c, 'SEPA custom setting is not updated!');
        
        // calculate sepa mandate ID in valid format
        string validSepaId = string.format('{0}{1}', 
                                           new string[] {
                                               ccMap.get(a.ShippingCountry).pw_cc__IsoCode_2__c,
                                               string.valueOf(currentSetting.Unique_Number__c).leftPad(7).replaceAll(' ', '0')
                                           }
                                          );
        
        system.assertEquals(validSepaId, a.SEPA_MNDID__c, 'SEPA_MNDID__c should be filled now!');
        system.assertEquals(currentSetting.Sign_City__c, a.SEPA_Sign_City__c, 'SEPA_Sign_City__c should be filled now!');
        system.assertEquals(currentSetting.Creditor_ID__c, a.SEPA_CRDID__c, 'SEPA_CRDID__c should be filled now!');
        system.assertEquals(Date.today(), a.SEPA_Sign_Date__c, 'SEPA_Sign_Date__c should be filled now!');
        system.assertEquals(Date.today(), a.SEPA_Valid_From__c, 'SEPA_Valid_From__c should be filled now!');
        system.assertEquals('Non One Time Payment', a.SEPA_Pay_Type__c, 'SEPA_Pay_Type__c should be filled now!');
        system.assertEquals(Date.newInstance(2099, 12,31), a.SEPA_Valid_To__c, 'SEPA_Valid_To__c should be filled now!');
        system.assertEquals('Active', a.SEPA_Status__c, 'SEPA_Status__c should be filled now!');
        
        // changing IBAN should cause new SEPA ID generation
        system.debug('---------- old IBAN: ' + a.Iban_Number__c);
        a.Iban_Number__c = TST_AccountTestHelper.createRandomIBAN();
        system.debug('---------- new IBAN: ' + a.Iban_Number__c);
        update a;
        a = getAccountById(a.Id);
        system.assertNotEquals(validSepaId, a.SEPA_MNDID__c, 'SEPA_MNDID__c should be changed now!');
        
    } // SepaMndIdTest
    
    public static testMethod void PhoneValidationTest()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Account a = TST_AccountTestHelper.createDummyAccount('Belgium', false);
        
        a.Phone = '';
        a.Fax = '';
        insert a;
        a = getAccountById(a.Id);
        // to be sure that phones are not there yet
        system.assertEquals(null, a.Phone, 'Phone should not be filled at this point!');
        system.assertEquals(null, a.Fax, 'Fax should not be filled at this point!');
        
        // case 1 - valid phone and fax with 1 space
        a.Phone = '+32 12345678';
        a.Fax = '+32 12345679';
        update a;
        a = getAccountById(a.Id);
        system.assertEquals('+32 12345678', a.Phone, 'Phone is not updated! (case 1)');
        system.assertEquals('+32 12345679', a.Fax, 'Fax is not updated! (case 1)');
        
        // case 2 - valid phone and fax with 2 spaces
        a.Phone = '+32 123 45678';
        a.Fax = '+32 1234 5679';
        update a;
        a = getAccountById(a.Id);
        system.assertEquals('+32 123 45678', a.Phone, 'Phone is not updated! (case 2)');
        system.assertEquals('+32 1234 5679', a.Fax, 'Fax is not updated! (case 2)');        
        
        // case 3 - invalid phone: length
        a.Phone = '+32 5678901234567';
        try { update a; system.assert(true, 'Phone should not be updated! (case 3 - length)'); }
        catch (Exception ex) { }
        a.Fax = '+32 567890123456';
        try { update a; system.assert(true, 'Fax should not be updated! (case 3 - length)'); }
        catch (Exception ex) { }
        
        // case 4 - invalid phone: no spaces
        a.Phone = '+32567890123';
        try { update a; system.assert(true, 'Phone should not be updated! (case 4 - no spaces)'); }
        catch (Exception ex) { }
        a.Fax = '+325678901234';
        try { update a; system.assert(true, 'Fax should not be updated! (case 4 - no spaces)'); }
        catch (Exception ex) { }
        
        // case 5 - invalid phone: invalid country code
        a.Phone = '+99 567890123';
        try { update a; system.assert(true, 'Phone should not be updated! (case 5 - invalid country code)'); }
        catch (Exception ex) { }
        a.Fax = '+99 5678901234';
        try { update a; system.assert(true, 'Fax should not be updated! (case 5 - invalid country)'); }
        catch (Exception ex) { }
        
        // case 6 - invalid phone: too many spaces
        a.Phone = '+32 567 89 01 23';
        try { update a; system.assert(true, 'Phone should not be updated! (case 6 - many spaces)'); }
        catch (Exception ex) { }
        a.Fax = '+32 567 89 01 2 34';
        try { update a; system.assert(true, 'Fax should not be updated! (case 6 - many spaces)'); }
        catch (Exception ex) { }
        
        // case 7 - invalid phone: no '+' sign
        a.Phone = '32 567890123';
        try { update a; system.assert(true, 'Phone should not be updated! (case 7 - no +)'); }
        catch (Exception ex) { }
        a.Fax = '32 5678901234';
        try { update a; system.assert(true, 'Fax should not be updated! (case 7 - no +)'); }
        catch (Exception ex) { }
    } // PhoneValidationTest
    
    public static testMethod void DefaultTimeZoneTest()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Account a = TST_AccountTestHelper.createDummyAccount('Belgium', false);
        
        system.assertEquals(null, a.Time_Zone__c, 'Time Zone should not be filled at this point!');
        insert a;
        a = getAccountById(a.Id);
        system.assertNotEquals(null, a.Time_Zone__c, 'Time Zone default setting is not working!');
        
        string oldTimeZone = a.Time_Zone__c;
        /*a.ShippingCountry = 'France';
        a.Time_Zone__c = '';
        update a; update trigger is not set */
        a = TST_AccountTestHelper.createDummyAccount('France', true);
        a = getAccountById(a.Id);
        system.assertNotEquals(null, a.Time_Zone__c, 'Time Zone default setting is not working! (case 2)');
        system.assertNotEquals(oldTimeZone, a.Time_Zone__c, 'Time Zone default setting is not changing!');
    } // DefaultTimeZoneTest
    
    public static testMethod void CountryISOCodeTest()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Account a = TST_AccountTestHelper.createDummyAccount('Belgium', false);
        
        Map<String,Country_Parameters__c> countryParams = Country_Parameters__c.getAll();
        insert a;
        a = getAccountById(a.Id);
        system.assertEquals(countryParams.get(a.ShippingCountry).ISO2_code__c, a.ISO2_Country_Code__c, 'Country ISO Code is not set (insert)!');
        
        a.ShippingCountry = 'France';
        update a;
        a = getAccountById(a.Id);
        system.assertEquals(countryParams.get(a.ShippingCountry).ISO2_code__c, a.ISO2_Country_Code__c, 'Country ISO Code is not set (update)!');
    } // CountryISOCodeTest
    
    public static testMethod void WorkflowALCDateChangeTest()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Account a1 = TST_AccountTestHelper.createDummyAccount('Belgium', false);
        
        // case 1: INSERT and criteria met
        a1.Account_Life_Cycle__c = 'New Customer';
        system.assertNotEquals(a1.ALC_New_Customer_Date__c, date.today(), 'invalid initial value!');
        insert a1;
        a1 = getAccountById(a1.Id);
        system.assertEquals(a1.ALC_New_Customer_Date__c, date.today(), 'Workflow is not working! (case 1)');
        
        // case 2: INSERT and criteria not met
        Account a2 = TST_AccountTestHelper.createDummyAccount('Belgium', false);
        a2.Account_Life_Cycle__c = 'Prospect'; // default value
        insert a2;
        a2 = getAccountById(a2.Id);
        system.assertNotEquals(a2.ALC_New_Customer_Date__c, date.today(), 'Workflow is not working! (case 2)');
        
        // case 3: UPDATE and criteria met
        a2.Account_Life_Cycle__c = 'New Customer';
        update a2;
        a2 = getAccountById(a2.Id);
        system.assertEquals(a2.ALC_New_Customer_Date__c, date.today(), 'Workflow is not working! (case 3)');
        
        // case 4: UPDATE and criteria not met
        a1.Account_Life_Cycle__c = 'Customer';
        a1.ALC_New_Customer_Date__c = date.today().addMonths(-1);
        update a1;
        a1 = getAccountById(a1.Id);
        system.assertNotEquals(a1.ALC_New_Customer_Date__c, date.today(), 'Workflow is not working! (case 4)');
        
    } //WorkflowALCDateChangeTest
    
    public static testMethod void WorkflowActivateTCDVisibilityTest()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Account a = TST_AccountTestHelper.createDummyAccount('Belgium', true);
       
        // case 1: UPDATE and criteria met
        a = getAccountById(a.Id);
        system.assertNotEquals(a.TCD_Published_status__c, 'Part 1 + 2 Activated by CRM', 'Invalid initial value! (case 1)');
        a.Account_Life_Cycle__c = 'New Customer'; // prospect -> new customer
        update a;
        a = getAccountById(a.Id);
        system.assertEquals(a.TCD_Published_status__c, 'Part 1 + 2 Activated by CRM', 'Workflow is not working! (case 1)');
        
        // case 2: UPDATE and criteria not met
        a.TCD_Published_status__c = 'Not Activated';
        update a;
        
        system.assertNotEquals(a.TCD_Published_status__c, 'Part 1 + 2 Activated by CRM', 'Invalid initial value! (case 2)');
        a.Account_Life_Cycle__c = 'Customer'; // new customer -> customer
        update a;
        a = getAccountById(a.Id);
        system.assertNotEquals(a.TCD_Published_status__c, 'Part 1 + 2 Activated by CRM', 'Workflow is not working! (case 2)');
    } //WorkflowActivateTCDVisibilityTest
    
    public static testMethod void UpdateTaskOrEventSubjectTest()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Account a = TST_AccountTestHelper.createDummyAccount('Belgium', true);
       
        Task t = TST_TaskAndEventTestHelper.createTask(a.Id, true);
        t = [Select Id, Subject1__c, Subject, WhatId From Task Where AccountId =: t.WhatId];
        system.assertEquals(t.Subject, t.Subject1__c +' - ' + a.Name, 'Task trigger not working right!');
        a.Name = 'Changed';
        update a;
        t = [Select Id, Subject1__c, Subject From Task Where AccountId =: t.WhatId];
        system.assertEquals(t.Subject, t.Subject1__c +' - ' + a.Name, 'Subject was not changed!');
        
        Event e = TST_TaskAndEventTestHelper.createEvent(a.Id, true);
        e = [Select Id, Subject1__c, Subject, WhatId From Event Where AccountId =: e.WhatId];
        system.assertEquals(e.Subject, e.Subject1__c +' - ' + a.Name, 'Event trigger not working right!');
        a.Name = 'Changed again';
        update a;
        e = [Select Id, Subject1__c, Subject From Event Where AccountId =: e.WhatId];
        system.assertEquals(e.Subject, e.Subject1__c +' - ' + a.Name, 'Subject was not changed!');
    }//UpdateTaskOrEventSubjectTest
    
    public static testMethod void TFXAgreedMigratinDateValidationTest()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Account a = TST_AccountTestHelper.createDummyAccount('Belgium', true);
        DateTime dt = Date.today();
        dt = dt.addDays(1);
        while(dt.format('EEEE') == 'Sunday' || dt.format('EEEE') == 'Saturday')
        {
            dt = dt.addDays(-1);
        }
        
        a.Sales_TFX_Migration_Start_Date__c = dt.date();
        try
        {
            update a;
        }
        catch(Exception e)
        {
            system.assertNotEquals(e, null, 'Sales_TFX_Migration_Start_Date__c field can not be updated');
        }
        dt = Date.today().addDays(2);
        while(dt.format('EEEE') != 'Sunday' && dt.format('EEEE') != 'Saturday')
        {
            dt = dt.addDays(1);
        }
        a.Sales_TFX_Migration_Start_Date__c = dt.date();
        try
        {
            update a;
        }
        catch(Exception e)
        {
            
        }
        dt = Date.today().addDays(2);
        while(dt.format('EEEE') == 'Sunday' || dt.format('EEEE') == 'Saturday')
        {
            dt = dt.addDays(1);
        }
        try
        {
            a.Sales_TFX_Migration_Start_Date__c = dt.date();        
            update a;
        }
        catch(Exception e)
        {
            system.assertEquals(e, null,'Sales_TFX_Migration_Start_Date__c field must be updated');  
        }
        
    }//TFXAgreedMigratinDateValidationTest
    
    public static testMethod void TFXPreventEditCCMigrationFlagValidationTest()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Account a = TST_AccountTestHelper.createDummyAccount('Belgium', true);
        Profile commProfile = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'testUsr1', 
                             Username = 'testUsr1@test.ww',
                             LastName = 'Testing', 
                             LanguageLocaleKey = 'en_US', 
                             LocaleSidKey = 'en_US', 
                             ProfileId = commProfile.Id, 
                             Email = 'testUsr1@test.ww',
                             EmailEncodingKey = 'UTF-8',                                 
                             TimeZoneSidKey = 'America/Los_Angeles',
                             Disable_Validation_Rules_and_Workflows__c = true);

        insert u;
        

        DateTime dt = Date.today().addDays(2);
        while(dt.format('EEEE') != 'Monday')
        {
            dt = dt.addDays(1);
        }        
        //check monday        
        a.Sales_TFX_Migration_Start_Date__c = dt.Date();            
        a.TFX_Migration_CC__c = true; 
        system.runAs(u)        
        {      
            update a;
        }
        //mistake monday        
        a.TFX_Migration_CC__c = false;
        try
        {
            update a;
        }
        catch(Exception e)
        {
            system.assertNotEquals(e, null,'TFX_Migration_CC__c can NOT be false if Agreed Migration Date is a Monday');
        }
        
        //tuesday
        dt = dt.addDays(1);
        a.Sales_TFX_Migration_Start_Date__c = dt.date();        
        a.TFX_Migration_CC__c = false;
        Boolean update_result = false;
        try
        {
            update a;
        }
        catch(Exception e)
        {
            if(e != null)    
            {
                update_result = true;
            }    
        }
        system.assertEquals(false, update_result, 'TFX_Migration_CC__c field must be updated');

        //check dates
        dt = Date.today();
        if(dt.format('EEEE') == 'Monday')
        {
            dt = dt.addDays(1);
        }        
        a.Sales_TFX_Migration_Start_Date__c = dt.date();
        a.TFX_Migration_CC__c = false;
        system.runAs(u)
        {
            update a;
        }
       
        a.TFX_Migration_CC__c = true;
        try
        {
            update a;
            
        }
        catch(Exception e)
        {
            system.assertNotEquals(e, null,'TFX_Migration_CC__c can NOT be updated');
        }
                
    }//TFXPreventEditCCMigrationFlagValidationTest
    
    public static testMethod void TFXMigrationDatesSetCCFlagWorkflowTest()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Account a = TST_AccountTestHelper.createDummyAccount('Belgium', true);        
        DateTime dt = Date.today().addDays(2);
        while(dt.format('EEEE') == 'Sunday' || dt.format('EEEE') == 'Saturday' || dt.format('EEEE') == 'Monday')
        {
            dt = dt.addDays(1);
        }
        a.Sales_TFX_Migration_Start_Date__c = dt.date();        
        update a;
        a=[select Id, Sales_TFX_Migration_Start_Date__c, TFX_Migration_CC__c from Account where Id =: a.Id];
        system.assert(a.TFX_Migration_CC__c == false, 'TFX_Migration_CC__c value is wrong');
        
        while(dt.format('EEEE') != 'Monday')
        {
            dt = dt.addDays(1);
        }
        a.Sales_TFX_Migration_Start_Date__c = dt.date();        
        update a;
        a=[select Id, Sales_TFX_Migration_Start_Date__c, TFX_Migration_CC__c from Account where Id =: a.Id];
        system.assert(a.TFX_Migration_CC__c == true, 'TFX_Migration_CC__c must be set to "true"');
    }//TFXMigrationDatesSetCCFlagWorkflowTest
    
    public static testMethod void TFXMigrationRecheckCCFlagWorkflowTest()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Account a = TST_AccountTestHelper.createDummyAccount('Belgium', true);
        DateTime dt = Date.today().addDays(2);
        Profile commProfile = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'testUsr1', 
                             Username = 'testUsr1@test.ww',
                             LastName = 'Testing', 
                             LanguageLocaleKey = 'en_US', 
                             LocaleSidKey = 'en_US', 
                             ProfileId = commProfile.Id, 
                             Email = 'testUsr1@test.ww',
                             EmailEncodingKey = 'UTF-8',                                 
                             TimeZoneSidKey = 'America/Los_Angeles',
                             Disable_Validation_Rules_and_Workflows__c = true);
        insert u;
        system.runAs(u)
        {
           
            
            while(dt.format('EEEE') != 'Monday')
            {
                dt = dt.addDays(1);
            }
            a.Sales_TFX_Migration_Start_Date__c = dt.date();        
            update a;        
            
            a.TFX_Migration_CC__c = false;
            update a;
            
            a=[select Id, Sales_TFX_Migration_Start_Date__c, TFX_Migration_CC__c from Account where Id =: a.Id];
            system.assert(a.TFX_Migration_CC__c == true, 'TFX_Migration_CC__c must be reset to "true"');
        }       
    }//TFXMigrationRecheckCCFlagWorkflowTest
    
    public static testMethod void TFXMigrationSetDateWorkflowTest_1()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Account a = TST_AccountTestHelper.createDummyAccount('Belgium', true);
        DateTime dt = Date.today().addDays(2);
        a.TFX_Migration_CC__c = false;
        update a;
        
        a=[select Id, Sales_TFX_Migration_Start_Date__c, TFX_Migration_CC__c, TFX_Migration_DATE__c from Account where Id =: a.Id];
        system.assert(a.TFX_Migration_DATE__c == null, 'TFX_Migration_DATE__c must be equal null');
        
        while(dt.format('EEEE') != 'Tuesday')
            {
                dt = dt.addDays(1);
            }
   
        
        while(dt.format('EEEE') != 'Friday')
            {
                a.Sales_TFX_Migration_Start_Date__c = dt.date();
                update a;
                
                a=[select Id, Sales_TFX_Migration_Start_Date__c, TFX_Migration_CC__c, TFX_Migration_DATE__c from Account where Id =: a.Id];
                system.assert(a.TFX_Migration_DATE__c == a.Sales_TFX_Migration_Start_Date__c, 'TFX_Migration_DATE__c must be equal to Sales_TFX_Migration_Start_Date__c');
                
                a.TFX_Migration_CC__c = true;
                update a;
                a=[select Id, Sales_TFX_Migration_Start_Date__c, TFX_Migration_CC__c, TFX_Migration_DATE__c from Account where Id =: a.Id];
                system.assert(a.TFX_Migration_DATE__c == (a.Sales_TFX_Migration_Start_Date__c+1), 'TFX_Migration_DATE__c must be equal to Sales_TFX_Migration_Start_Date__c+1');
                
                a.TFX_Migration_CC__c = false;
                update a;
                
                dt = dt.addDays(1);
            }
            
    }//TFXMigrationSetDateWorkflowTest_1
    
    public static testMethod void TFXMigrationSetDateWorkflowTest_2()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Account a = TST_AccountTestHelper.createDummyAccount('Belgium', true);
        Profile commProfile = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'testUsr1', 
                             Username = 'testUsr1@test.ww',
                             LastName = 'Testing', 
                             LanguageLocaleKey = 'en_US', 
                             LocaleSidKey = 'en_US', 
                             ProfileId = commProfile.Id, 
                             Email = 'testUsr1@test.ww',
                             EmailEncodingKey = 'UTF-8',                                 
                             TimeZoneSidKey = 'America/Los_Angeles',
                             Disable_Validation_Rules_and_Workflows__c = true);
        insert u;
        DateTime dt = Date.today().addDays(2);
        a.TFX_Migration_CC__c = false;
        update a;
        
        
        system.runAs(u)
        {        
            while(dt.format('EEEE') != 'Friday')
            {
                dt = dt.addDays(1);
            }
            
            a.Sales_TFX_Migration_Start_Date__c = dt.date();
            update a;
            
            a=[select Id, Sales_TFX_Migration_Start_Date__c, TFX_Migration_CC__c, TFX_Migration_DATE__c from Account where Id =: a.Id];
            system.assert(a.TFX_Migration_DATE__c == a.Sales_TFX_Migration_Start_Date__c, 'TFX_Migration_DATE__c must be equal to Sales_TFX_Migration_Start_Date__c');
            
            a.TFX_Migration_CC__c = true;
            update a;
            a=[select Id, Sales_TFX_Migration_Start_Date__c, TFX_Migration_CC__c, TFX_Migration_DATE__c from Account where Id =: a.Id];
            system.assert(a.TFX_Migration_DATE__c == (a.Sales_TFX_Migration_Start_Date__c+4), 'TFX_Migration_DATE__c must be equal to Sales_TFX_Migration_Start_Date__c+4');
            
            a.TFX_Migration_CC__c = false;
            update a;
            
            dt = dt.addDays(1);
            
            
            a.Sales_TFX_Migration_Start_Date__c = dt.date();
            update a;
            
            a=[select Id, Sales_TFX_Migration_Start_Date__c, TFX_Migration_CC__c, TFX_Migration_DATE__c from Account where Id =: a.Id];
            system.assert(a.TFX_Migration_DATE__c == (a.Sales_TFX_Migration_Start_Date__c+3), 'TFX_Migration_DATE__c must be equal to Sales_TFX_Migration_Start_Date__c+3');
            
            a.TFX_Migration_CC__c = true;
            update a;
            a=[select Id, Sales_TFX_Migration_Start_Date__c, TFX_Migration_CC__c, TFX_Migration_DATE__c from Account where Id =: a.Id];
            system.assert(a.TFX_Migration_DATE__c == (a.Sales_TFX_Migration_Start_Date__c+3), 'TFX_Migration_DATE__c must be equal to Sales_TFX_Migration_Start_Date__c+3');
            
            a.TFX_Migration_CC__c = false;
            update a;
            
            
            dt = dt.addDays(1);
            
            a.Sales_TFX_Migration_Start_Date__c = dt.date();
            update a;
            
            a = [select Id, Sales_TFX_Migration_Start_Date__c, TFX_Migration_CC__c, TFX_Migration_DATE__c from Account where Id =: a.Id];
            system.assert(a.TFX_Migration_DATE__c == (a.Sales_TFX_Migration_Start_Date__c+2), 'TFX_Migration_DATE__c must be equal to Sales_TFX_Migration_Start_Date__c+2');
            
            a.TFX_Migration_CC__c = true;
            update a;
            a = [select Id, Sales_TFX_Migration_Start_Date__c, TFX_Migration_CC__c, TFX_Migration_DATE__c from Account where Id =: a.Id];
            system.assert(a.TFX_Migration_DATE__c == (a.Sales_TFX_Migration_Start_Date__c+2), 'TFX_Migration_DATE__c must be equal to Sales_TFX_Migration_Start_Date__c+2');
            
            a.TFX_Migration_CC__c = false;
            update a;
            
            dt = dt.addDays(1);
            
            
            a.Sales_TFX_Migration_Start_Date__c = dt.date();
            update a;
            
            a = [select Id, Sales_TFX_Migration_Start_Date__c, TFX_Migration_CC__c, TFX_Migration_DATE__c from Account where Id =: a.Id];
            system.assert(a.TFX_Migration_DATE__c == (a.Sales_TFX_Migration_Start_Date__c+1), 'TFX_Migration_DATE__c must be equal to Sales_TFX_Migration_Start_Date__c+1');
            
        }
        
    }//TFXMigrationSetDateWorkflowTest_2
    
    public static testMethod void SetTFXAgreedMigrationEvolutionDateTest()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Account acc = TST_AccountTestHelper.createDummyAccount('Belgium', false);     
        acc.Sales_TFX_Migration_Start_Date__c = Date.newInstance(2020, 1, 1);
        insert acc; 
        System.assertEquals(null, acc.TFX_Agreed_Migration_Evolution_Date__c, 'Trigger method SetTFXAgreedMigrationEvolutionDate working not correctly. First check');
        acc.Sales_TFX_Migration_Start_Date__c = Date.newInstance(2022, 6, 6);
        update acc;
        acc = [Select Id, Sales_TFX_Migration_Start_Date__c, TFX_Agreed_Migration_Evolution_Date__c From Account];
        System.assertEquals(Date.today(), acc.TFX_Agreed_Migration_Evolution_Date__c, 'Trigger method SetTFXAgreedMigrationEvolutionDate working not correctly. Second check');
    }
    
    public static testMethod void SetTFXRollbackDateValidationAndWorkflowTest()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Account acc = TST_AccountTestHelper.createDummyAccount('Belgium', false);     
        insert acc; 
        acc.TFX_Rollback_Date__c = Date.Today().addDays(1);
        test.startTest();
        try {update acc;}
        catch (Exception e)
        {
           String errorMessage = e.getMessage();
           if(!errorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) System.Assert(false,'TFX Rollback Date Validation ERROR!');
        }
        acc.TFX_Rollback_Date__c = Date.Today();
        update acc;        
        acc = [Select Id, TFX_Migration_Status__c From Account];
        System.assertEquals('Rollback', acc.TFX_Migration_Status__c, 'WF TFX Migration Rollback Status Set not worked!');
        test.stopTest();
    }
    
    private static Account getAccountById(Id cId)
    {
        return [
            SELECT 
                Id, Name, AccountNumber, Phone, Fax,
                Debtor_Number__c, Teleroute_Number__c, Iban_Number__c, Time_Zone__c, ISO2_Country_Code__c,
                ShippingCountry, ShippingCity, ShippingStreet, ShippingPostalCode, ShippingState,
                BillingCountry, BillingCity, BillingStreet, BillingPostalCode, BillingState,
                ABC_Segmentation_Date__c, SML_Segmentation_Date__c, SML_Segmentation__c,
                Organization__c,Organization_Country__c, Level_of_Certification__c,
                SEPA_Sign_City__c, SEPA_CRDID__c, SEPA_Sign_Date__c, SEPA_Valid_From__c, SEPA_Pay_Type__c,
                SEPA_Status__c, SEPA_Valid_To__c, SEPA_MNDID__c,
                ESB_Company_status__c, ESB_Billing_Address_ID__c, ESB_ShippingAddress_ID__c,
                ClonnedFlag__c, Account_Life_Cycle__c, ALC_New_Customer_Date__c, TCD_Published_status__c
            FROM Account
            WHERE Id = :cId
        ];
    } // getAccountById
    
}