public with sharing class CtiRedirectController {
    public List<Contact> cons {
        get {
            if(cons==null) {
                cons = new List<Contact>();
            }
            return cons;
        }
        set;
    }
    public PageReference redirectMe() {
        PageReference returnTo = null;
        String phoneSearchText = ApexPages.currentPage().getParameters().get('phone');
        System.Debug('phoneSearchText'+phoneSearchText);
        if(phoneSearchText ==null || phoneSearchText.trim() =='') {
            System.Debug('phoneSearchText'+phoneSearchText);
            ApexPages.Message m = new ApexPages.Message(ApexPages.Severity.FATAL,'Nothing to search for!');
            ApexPages.addMessage(m);
        } else {
            String searchText = EncodingUtil.urlDecode(phoneSearchText,'UTF-8');
            //
            // Normalize searchstring to exclude all non-digits
            Pattern unwantedStuff = Pattern.compile('\\D+');                       
            String strippedSearchText = unwantedStuff.matcher(searchText).replaceAll('');
             
            //
            // Query with the stripped text, in the formula field containing a stripped Phone number
            Contact[] contacts = [SELECT Id, Name, FirstName, LastName, Account.Name, Email, Phone FROM Contact WHERE Stripped_Phone_Number__c = :strippedSearchText limit 100];
            System.Debug ('contacts'+contacts);
            if(contacts == null || contacts.size()==0) {
                contacts = Database.query('SELECT Id, Name, FirstName, LastName, Account.Name, Email, Phone FROM Contact WHERE Stripped_Phone_Number__c LIKE \'%'+strippedSearchText+'%\' OR Stripped_Phone_Number__c LIKE \''+strippedSearchText+'%\' OR Stripped_Phone_Number__c LIKE \'%'+strippedSearchText+'\'');
                if(contacts == null || contacts.size()==0) {
                    
                    //returnTo = new PageReference('/003/e');
                    //returnTo = new PageReference('/003/o');
                     ApexPages.Message am= new ApexPages.Message(ApexPages.severity.WARNING, 'No contact found with this phone number: '+strippedSearchText);
                     ApexPages.addMessage(am); 
                } else if(contacts.size() > 1) {
                    this.cons = contacts;
                } else {
                    returnTo = new PageReference('/'+contacts[0].Id);
                }

            } else if(contacts.size() > 1) {
                this.cons = contacts;
            } else {
                returnTo = new PageReference('/'+contacts[0].Id);
            }
        }

        return returnTo;
    }

}