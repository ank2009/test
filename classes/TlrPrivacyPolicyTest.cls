@isTest
public class TlrPrivacyPolicyTest
{
    public static testMethod void testTlrPrivacyPolicy()
    {
    	TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
     test.startTest();
     // Data creation
     
     Account acct= TST_AccountTestHelper.createDummyAccount(true);
     acct.VAT__c='FR251356463';
     acct.Account_Life_Cycle__c='New Customer';
     update acct;
     Contact cont=TST_ContactTestHelper.createDummyContact(acct, TLR_RecordTypeHelper.getId('Contact', 'TLR Contact'), true); 
     cont.Username__c='DE000001';
     cont.Email='abdelali.karim@atos.net';
     update cont;
     LIST<Account>    InsertAcc=[SELECT Id, Name,Teleroute_Number__c,Account_Life_Cycle__c, SIRET__c, 
                                     ShippingStreet,ShippingCity,ShippingPostalCode,ShippingCountry,AccountNumber
                                      ,ShippingState,VAT__c 
                                 FROM Account
                                 WHERE Id =: acct.Id limit 1];
     LIST<Contact>    InsertCon=[SELECT Id, AccountId, FirstName,Gender__c,Language__c,LastName,Title, Username__c, 
                                 Email, Newsletter_susbcription__c ,DoNotCall,HasOptedOutOfEmail,HasOptedOutOfFax    
                              FROM Contact
                              WHERE Id =: cont.Id limit 1];
     for(Account acc :InsertAcc)
     { 
     for (Contact con : InsertCon)
     {
     TlrPrivacyPolicy.UnSubscribeNewsLetterInput LetterInput= new TlrPrivacyPolicy.UnSubscribeNewsLetterInput();
     LetterInput.UnSubscribeNewsLetter= true;
     LetterInput.Login=con.Username__c;
     TlrPrivacyPolicy.UnSubscribeNewsLetter(LetterInput);
     TlrPrivacyPolicy.UnSubscribeEMailInput EmailInput= new TlrPrivacyPolicy.UnSubscribeEMailInput();
     EmailInput.UnSubscribeEmail=true;
     EmailInput.Login=con.Username__c;
     TlrPrivacyPolicy.UnSubscribeEMail(EmailInput);
     TlrPrivacyPolicy.ChargePrivacyPolicyChangesInput PCInput= new TlrPrivacyPolicy.ChargePrivacyPolicyChangesInput ();
     PCInput.Login = con.Username__c; 
     PCInput.AllowsPhoneCall=true;
     PCInput.AllowsEmailSending= true;
     PCInput.allowsFaxSending = true;
     TlrPrivacyPolicy.ChargePrivacyPolicyChanges(PCInput);
     Contact sContact = [select Id, Newsletter_susbcription__c from Contact where  Username__c =: LetterInput.Login  limit 1];
     delete sContact;
     TlrPrivacyPolicy.UnSubscribeNewsLetter(LetterInput);
     TlrPrivacyPolicy.UnSubscribeEMail(EmailInput);
     TlrPrivacyPolicy.ChargePrivacyPolicyChanges(PCInput);
     }
     InsertCon.clear();
     }
     InsertAcc.clear();
     test.stopTest();
    }
    //----------- 
    public static testMethod void testTlrPrivacyPolicy1()
    {
    	TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
    test.startTest();
    // Data creation
     Account acct1= TST_AccountTestHelper.createDummyAccount(true);
     acct1.VAT__c='FR251356463';
     acct1.Account_Life_Cycle__c='New Customer';
     update acct1;
     Contact cont1=TST_ContactTestHelper.createDummyContact(acct1, TLR_RecordTypeHelper.getId('Contact', 'TLR Contact'), true); 
     cont1.Username__c='DE000001';
     cont1.Email='abdelali.karim@atos.net';
     update cont1;
     LIST<Account>    InsertAcc1=[SELECT Id, Name,Teleroute_Number__c,Account_Life_Cycle__c, SIRET__c, 
                                     ShippingStreet,ShippingCity,ShippingPostalCode,ShippingCountry,AccountNumber
                                      ,ShippingState,VAT__c 
                                 FROM Account
                                 WHERE Id =: acct1.Id limit 1];
     LIST<Contact>    InsertCon1=[SELECT Id, AccountId, FirstName,Gender__c,Language__c,LastName,Title, Username__c, 
                                 Email, Newsletter_susbcription__c ,DoNotCall,HasOptedOutOfEmail,HasOptedOutOfFax    
                              FROM Contact
                              WHERE Id =: cont1.Id limit 1];
     for(Account acc1 :InsertAcc1)
     { 
     for (Contact con1 : InsertCon1)
     {
     TlrPrivacyPolicy.UnSubscribeNewsLetterInput LetterInput= new TlrPrivacyPolicy.UnSubscribeNewsLetterInput();
     LetterInput.UnSubscribeNewsLetter= false;
     LetterInput.Login=con1.Username__c;
     TlrPrivacyPolicy.UnSubscribeNewsLetter(LetterInput);
     TlrPrivacyPolicy.UnSubscribeEMailInput EmailInput= new TlrPrivacyPolicy.UnSubscribeEMailInput();
     EmailInput.UnSubscribeEmail=false;
     EmailInput.Login=con1.Username__c;
     TlrPrivacyPolicy.UnSubscribeEMail(EmailInput);
     TlrPrivacyPolicy.ChargePrivacyPolicyChangesInput PCInput= new TlrPrivacyPolicy.ChargePrivacyPolicyChangesInput ();
     PCInput.Login = con1.Username__c; 
     PCInput.AllowsPhoneCall=false;
     PCInput.AllowsEmailSending= false;
     PCInput.allowsFaxSending = false;
     TlrPrivacyPolicy.ChargePrivacyPolicyChanges(PCInput);
     }InsertCon1.clear();}
     InsertAcc1.clear();
     test.stopTest();
     }
}