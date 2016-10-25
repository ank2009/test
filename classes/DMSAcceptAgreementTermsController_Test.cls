@isTest
public class DMSAcceptAgreementTermsController_Test
{
    static Account theAccount;
    static Contact theContact;
    static User theUser;
    static Case theCase;
    
    static final String DefaultLanguage = 'EN';
    static final String DocumentName = 'DEBT_MEDIATION_{0}.PDF';
    static final String DocumentNamePattern = 'DEBT_MEDIATION';
    static final String FORM_HTML_START = '<HTML><BODY>';
    static final String FORM_HTML_END = '</BODY></HTML>';
    
    static void CreateUser(Contact con) {
        
        Profile p = [select id from profile where name = 'DMS Community User'];
            theUser = new User(alias = 'ali',
                                           email = 'user@testorg.com',
                                           emailencodingkey = 'UTF-8',
                                           lastname = 'TestWKTSuser',
                                           companyname = 'test',
                                           languagelocalekey = 'en_US',
                                           localesidkey = 'en_US',
                                           profileId = p.Id,
                                           contactId = con.Id,
                                           timezonesidkey = 'America/Los_Angeles',
                                           username = 'user@testorg.com');
        
        insert theUser;
    }       
    
    /*
    static void generateAndAttachPDF(Community_Document_Holder__c theCDH, String language) { 
        String pdfContent = '' + FORM_HTML_START;       
        pdfContent = pdfContent + '<H2>Test PDF</H2>';        
        pdfContent = pdfContent + '<P>test test</P>';
        pdfContent = pdfContent + FORM_HTML_END;

        attachPDF(theCDH, language, pdfContent);
    }
    
    static void attachPDF(Community_Document_Holder__c theCDH, String language, String pdfContent)
    {
        Attachment attachmentPDF = new Attachment();
        attachmentPDF.parentId = theCDH.Id;
        attachmentPDF.Name = String.format(DocumentName, new List<String>{language});
        attachmentPDF.body = Blob.toPDF(pdfContent); //This creates the PDF content
        insert attachmentPDF;
    } 
*/

    static void Init() {
        /*
        RecordType AcctRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'TLR_Account'];
        RecordType ConRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'TLR_Contact'];
        
        
        //Create Account & Contact for the User     
        theAccount = new Account(Name = 'TestWKTSAccount', BillingStreet ='TEST', BillingPostalCode ='99999', BillingCity ='TEST', BillingCountry='Germany', RecordTypeId = AcctRecordType.Id);
        insert theAccount;
        
        theContact = new Contact(LastName = 'TestWKTSUser', AccountId =  theAccount.Id, RecordTypeId = ConRecordType.Id);
        insert theContact;
        
        //Create Community User
        CreateUser(theContact);*/
    }

    static void CreatePDFDocuments() {
        
        //Community_Document_Holder__c cdh = new Community_Document_Holder__c(Name = DocumentNamePattern);      
        //insert cdh;
        
        //generateAndAttachPDF(cdh, DefaultLanguage);
        //generateAndAttachPDF(cdh, 'PL');

    }

    static testMethod void newCaseWithFoundApproppriateDocument() {

/*
        Init();
        CreatePDFDocuments();

        theContact.Language__c = 'Polish';
        update theContact;
        
        System.Test.startTest();

            System.runAs(theUser) {        
        
                theCase = new Case();
            
                ApexPages.StandardController  caseStdController = new ApexPages.StandardController(theCase);
                DMSAcceptAgreementTermsController pageCTRL = new DMSAcceptAgreementTermsController(caseStdController);  
                
                System.assertNotEquals(null, pageCTRL);
                System.assertEquals('PL', pageCTRL.userLanguage);
                               
                System.assertNotEquals(null, pageCTRL.currentUser);
                System.assertNotEquals(null, pageCTRL.ResourceURL);
                
                //System.assertEquals(String.format(DocumentName, new List<String>{'PL'}), [SELECT Name FROM Attachment WHERE Id =: pageCTRL.DocumentId].Name);
                
                pageCTRL.acceptAgreement = false;
                pageCTRL.Next();
                
                System.assertNotEquals(null, pageCTRL.ValidationMessage);
            }
            
        System.Test.stopTest();
        */
    }
    
    static testMethod void newCaseWithDefaultDocument() {
/*
        Init();
        CreatePDFDocuments();
                        
        System.Test.startTest();

            System.runAs(theUser) {        
        
                theCase = new Case();
            
                ApexPages.StandardController  caseStdController = new ApexPages.StandardController(theCase);
                DMSAcceptAgreementTermsController pageCTRL = new DMSAcceptAgreementTermsController(caseStdController);  
                
                System.assertNotEquals(null, pageCTRL);
                System.assertEquals('EN', pageCTRL.userLanguage);
                               
                System.assertNotEquals(null, pageCTRL.currentUser);
                System.assertNotEquals(null, pageCTRL.ResourceURL);
                
                //System.assertEquals(String.format(DocumentName, new List<String>{DefaultLanguage}), [SELECT Name FROM Attachment WHERE Id =: pageCTRL.DocumentId].Name);
                
                pageCTRL.acceptAgreement = true;
                pageCTRL.Next();
                
                System.assertEquals(null, pageCTRL.ValidationMessage);
            }
            
        System.Test.stopTest();*/
    }

    static testMethod void newCaseWithNoDocumentFound() {
/*
        Init();
        CreatePDFDocuments();

        theContact.Language__c = 'German';
        update theContact;

  
        System.Test.startTest();

            System.runAs(theUser) {        
        
                theCase = new Case();
            
                ApexPages.StandardController  caseStdController = new ApexPages.StandardController(theCase);
                DMSAcceptAgreementTermsController pageCTRL = new DMSAcceptAgreementTermsController(caseStdController);  
                
                System.assertNotEquals(null, pageCTRL);
                System.assertEquals('DE', pageCTRL.userLanguage);
                               
                System.assertNotEquals(null, pageCTRL.currentUser);
                System.assertEquals(null, pageCTRL.ResourceURL);

                System.assertNotEquals(null, pageCTRL.DocumentLoadingMessage);
                
                
                pageCTRL.Cancel();
                
            }
            
        System.Test.stopTest();
*/
    }
    

}