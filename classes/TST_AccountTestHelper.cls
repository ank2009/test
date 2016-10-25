/**
* @author       Brian Kessler (Brian_Kessler@epam.com)
* @date         2013 June 26
* @description  This class is intended to facilitate creating and populating dummy Accounts for unit testing.*
*/
@isTest
public class TST_AccountTestHelper
{
    // Methods for creating one Account -----------------------------------------------------------------------

    /**
    * @author       Brian Kessler (Brian_Kessler@epam.com)
    * @date         2013 June 26
    * @description  Method to create dummy Account for testing.
    * @param        Id recordTypeId : Which Account Record Type to Create
    * @param        Boolean insertNow : Whether to insert into SFDC DB now, or wait for latter processing.
    * @return       Account
    **/
    public static Account createDummyAccount( String country, Boolean insertNow)
    {
        Integer unique     = (Integer) (Math.random() * 2147483647);
        String  uniqueName = 'Dummy Account ' + unique;

        Account dummyAccount = new Account();
        //dummyAccount.ParentId                 = '';
        dummyAccount.Name                       = uniqueName;
        dummyAccount.Type                       = 'Customer';
        
        dummyAccount.NumberOfEmployees          = (Integer) (Math.random() * 9999);
        dummyAccount.Number_of_trucks_owned__c  = (Integer) (Math.random() * 2147483647);
        dummyAccount.ShippingCountry            = country;
        dummyAccount.ShippingState              = 'tst shipping state';
        dummyAccount.ShippingCity               = 'shpCity';
        dummyAccount.ShippingStreet             = 'shpStreet 13';
        dummyAccount.ShippingPostalCode         = '1930';
        dummyAccount.BillingCountry             = country;
        dummyAccount.BillingState               = 'billing state';
        dummyAccount.BillingCity                = 'bilCity';
        dummyAccount.BillingStreet              = 'bilStreet 13';
        dummyAccount.BillingPostalCode          = '1930';
        dummyAccount.Phone                      = '+32 025551212';
        dummyAccount.Fax                        = '+32 025551313';
        
        dummyAccount.Direct_Debit__c            = FALSE;
        dummyAccount.BIC_Code__c                = 'CESCESBBXXX';
        dummyAccount.Iban_Number__c             = createRandomIBAN();//'ES7420130122910201400224';
        
        //dummyAccount.Currency__c              = 'EUR - Euro';
        dummyAccount.Legal_Status__c            = 'A/S (Aktieselskab) - DEN';
        dummyAccount.SIRET__c                   = 'BE' + ((Integer) (Math.random() * 9999999));
        dummyAccount.VAT__c                     = '' + (Integer) (Math.random() * 99999);
        dummyAccount.Account_Level__c           = 'International';
        dummyAccount.Bank_Number__c             = '' + (Integer) (Math.random() * 9999999);
        dummyAccount.BIC_Code__c                = 'AAAAAA12123';
        dummyAccount.Payment_Terms__c           = 30;
        //dummyAccount.Organization_Country__c  = orgCountry;
        
        // external keys
        dummyAccount.Siebel_account_id__c       = '' + (Integer) (Math.random() * 99999);
        // dummyAccount.Teleroute_Number__c - will be set by trigger
        dummyAccount.Company_id__c              = '' + (Integer) (Math.random() * 999999);
        
        /*
        dummyAccount.APE_code_France_only__c    = '' + (Integer) (Math.random() * 9999999);
        dummyAccount.Bank_Code_FR__c            = '' + (Integer) (Math.random() * 9999999);
        dummyAccount.RIB_Key_FR__c              = '';
        dummyAccount.Cashier_Code_FR__c         = '' + (Integer) (Math.random() * 9999999);
        */
        
        if (insertNow) { insert dummyAccount; }
        return dummyAccount;
    }
    public static Account createDummyAccount(Boolean insertNow)
    { return createDummyAccount('Belgium', insertNow); }
    /**
    * @author       Brian Kessler (Brian_Kessler@epam.com)
    * @date         2013 June 26
    * @description  Method to create dummy Account for testing; won't be inserted into SFDC DB at create time.
    * @param        Id recordTypeId : Which Account Record Type to Create
    * @return       Account
    **/
    public static Account createDummyAccount()
    {
        return createDummyAccount('Belgium');
    }
    
    public static Account createDummyAccount(String orgCountry)
    {
        return createDummyAccount(orgCountry, false);
    }

    // Methods for creating multiple Accounts -----------------------------------------------------------------------

    /**
    * @author       Brian Kessler (Brian_Kessler@epam.com)
    * @date         2013 June 26
    * @description  Method to create dummy Account list for testing.
    * @param        Integer numberOfAccounts : How many Accounts to create
    * @param        Id recordTypeId : Which Account Record Type to Create
    * @param        Boolean insertNow : Whether to insert into SFDC DB now, or wait for latter processing.
    * @return       List<Account>
    **/
    public static List<Account> createDummyAccountList(Integer numberOfAccounts, String orgCountry, Boolean insertNow)
    {
        List<Account> dummyAccountList = new List<Account>();
        for (Integer i=1; i<=numberOfAccounts; i++)
        {
            dummyAccountList.add(createDummyAccount(orgCountry));
        }
        if (insertNow) { insert dummyAccountList; }
        return dummyAccountList;
    }
    public static List<Account> createDummyAccountList(Integer numberOfAccounts, Boolean insertNow)
    { return createDummyAccountList(numberOfAccounts, 'Belgium', insertNow); }
    /**
    * @author       Brian Kessler (Brian_Kessler@epam.com)
    * @date         2013 June 26
    * @description  Method to create dummy Account list for testing; won't be inserted into SFDC DB at create time.
    * @param        Integer numberOfAccounts : How many Accounts to create
    * @param        Id recordTypeId : Which Account Record Type to Create
    * @return       List<Account>
    **/
    public static List<Account> createDummyAccountList(Integer numberOfAccounts)
    {
        return createDummyAccountList(numberOfAccounts, false);
    }
    
    /**
    * @author       Anton Soloveyv (anton_soloveyv@epam.com)
    * @date         2015 April 1
    * @description  Generate valid IBAN Number
    * 				http://en.wikipedia.org/wiki/International_Bank_Account_Number
    * 				http://www.ibancalculator.com/calculation.html
    * 				used to check: http://www.ibancalculator.com/iban_validieren.html
    */
    public static string createRandomIBAN()
    {
        // let it be 16 characters long
        // format is following:
        // CCccNNNNNNNNNNNNNNNNNNNN
        // CC - Country ISO Code
        // cc - checksum
        // N - numeric character, BBAN - basic bank account number
        // can be up to 4 alphabet characters, but we will use numeric only
        string retVal;
        
        // characters map for IBAN purposes
        Map<string, integer> charmap = new Map<string, integer>{
            'A' => 10, 'B' => 11, 'C' => 12, 'D' => 13, 'E' => 14, 'F' => 15,
            'G' => 16, 'H' => 17, 'I' => 18, 'J' => 19, 'K' => 20, 'L' => 21,
            'M' => 22, 'N' => 23, 'O' => 24, 'P' => 25, 'Q' => 26, 'R' => 27,
            'S' => 28, 'T' => 29, 'U' => 30, 'V' => 31, 'W' => 32, 'X' => 33,
            'Y' => 34, 'Z' => 35
                };
        
        string bban = Utilities.getRandomString(Utilities.randomStringAlphabets.numbers, 18);
        string countryCode = 'YY';//Utilities.getRandomString(Utilities.randomStringAlphabets.alphaCaps, 2);
        
        string countryCodeN = ''; // numeric country code
        for(integer i = 0; i < countryCode.length(); i++)
            countryCodeN += string.valueOf(charmap.get(countryCode.substring(i, i + 1)));
        
        string fullstring = bban + countryCodeN + '00';
        decimal fullNumber = decimal.valueOf(fullString);
        
        decimal modulo = fullNumber - (97.0 * Math.floor(fullNumber / 97.0));
        integer crcN = 98 - (integer)modulo;
        string crc = string.valueOf(crcN).leftPad(2).replace(' ', '0');
        
        retVal = countryCode + crc + bban;
        
        //system.debug('---------- generated bban: ' + bban);
        //system.debug('---------- generated countryCode: ' + countryCode);
        //system.debug('---------- generated countryCodeN: ' + countryCodeN);
        //system.debug('---------- generated modulo: ' + modulo);
        //system.debug('---------- generated crc: ' + crc);
        system.debug('---------- generated IBAN: ' + retVal);
        
        return retVal;
    }
}