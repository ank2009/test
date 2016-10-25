/**
* @author		Anton Solovyev (anton_soloveyv@epam.com)
* @date			2013 June 27
* @description	Test class for TLRCaseExt controller extension.
*/
@isTest
private class TLRCaseExtTest {
	// static values, that are known
	private static final string tstWatchListUrl = 'https://dwh.teleroute.com/businessobjects/enterprise115/desktoplaunch/opendoc/openDocument.jsp';
	private static final string tstWatchListDocumentName = 'SMP_WatchList_CCM_V2_SFDC_2';

	// test for DeleteDocument method, which calls WebService to remove document
    static testMethod void DeleteDocumentTest()
    {
    	/*TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
    	
    	// attaching Mock object to our test
        Test.setMock(HttpCalloutMock.class, new TLRCaseExtTestWSMock());
        TLRCaseExt caseExt = CreateCaseExt();

        // startTest is workaround
        // see http://boards.developerforce.com/t5/Apex-Code-Development/Testing-Webservice-Callouts-with-Winter-13-Test-setMock-fails/m-p/573481#M105244
        Test.StartTest();
        system.assert(caseExt.isDocumentDeleted == false);
        caseExt.deleteDoc();
        system.assert(caseExt.isDocumentDeleted == true);
        Test.StopTest();*/
        
        // test commented because of bug in SF
    }

    // test for method, which retorns PageReference
    static testMethod void watchDefaulterTest()
    {
    	TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
    	
    	TLRCaseExt caseExt = CreateCaseExt();
    	//System.assert(caseExt.internalCase.Teleroute_Number_Defaulter__c != null);
    	PageReference pr = caseExt.watchDefaulter();
    	string correctUrl = string.format('{0}?sDocName={1}&sRefresh=Y&lsSTelerouteNumber:={2}&sOutputFormat=P',
             new string[] {
                 tstWatchListUrl,
                 tstWatchListDocumentName,
                 caseExt.internalCase.Teleroute_Number_Defaulter__c
            }
        );
        PageReference correctPR = new PageReference(correctUrl);
        System.assertEquals(pr.getUrl(), correctPR.getUrl());
    }

    // test for method, which retorns PageReference
    static testMethod void watchComplainerTest()
    {
    	TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
    	
    	TLRCaseExt caseExt = CreateCaseExt();
    	//System.assert(caseExt.internalCase.Teleroute_Number_Complainer__c != null);
    	PageReference pr = caseExt.watchComplainer();
    	string correctUrl = string.format('{0}?sDocName={1}&sRefresh=Y&lsSTelerouteNumber:={2}&sOutputFormat=P',
             new string[] {
                 tstWatchListUrl,
                 tstWatchListDocumentName,
                 caseExt.internalCase.Teleroute_Number_Complainer__c
            }
        );
        PageReference correctPR = new PageReference(correctUrl);
        System.assertEquals(pr.getUrl(), correctPR.getUrl());
    }

    // this method tests part of constructor and documentnumber property
    static testMethod void documentNumberTest()
    {
    	TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
    	
    	TLRCaseExt caseExt = CreateCaseExt(null);
    	system.assertEquals(caseExt.documentNumber , '');
    }
    static testMethod void documentNumberTest2()
    {
    	TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
    	TLRCaseExt caseExt2 = CreateCaseExt('123');
    	system.assertEquals(caseExt2.documentNumber , '');
    }
    static testMethod void documentNumberTest3()
    {
    	TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
    	TLRCaseExt caseExt3 = CreateCaseExt('http://google.google/documentRepository/get.aspx?id=54321&odir=somesome');
    	system.assertEquals(caseExt3.documentNumber , '54321');
    }

    /**
	* @author		Anton Solovyev (anton_soloveyv@epam.com)
	* @date			2013 June 27
	* @description	Create uot object to test.
	*/
    static TLRCaseExt CreateCaseExt()
    {
    	return CreateCaseExt('somesomesome http://google.google/documentRepository/get.aspx?id=12345&odir=somesome');
    }

    /**
	* @author		Anton Solovyev (anton_soloveyv@epam.com)
	* @date			2013 June 27
	* @description	Create uot object to test.
	*/
    static TLRCaseExt CreateCaseExt(string description)
    {
    	// our test object
    	Case testCase = CreateComplaintCase(description);

    	// create standard controller
    	ApexPages.StandardController controller = new ApexPages.StandardController(testCase);

    	// ant now finally create our controller extension
    	TLRCaseExt ext = new TLRCaseExt(controller);

    	return ext;
    }

    /**
	* @author		Anton Solovyev (anton_soloveyv@epam.com)
	* @date			2013 June 27
	* @description	Create Case with our conditions
	*/
    static Case CreateComplaintCase(string description)
    {
    	Id recTypeId = TLR_RecordTypeHelper.getid('Case', 'TLR Complaint Case');

    	Case ret = TST_CaseTestHelper.createDummyCase(recTypeId, null, false);

    	ret.Description=description;
    	ret.isDocumentDeleted__c = false;
    	// TODO: fill Defaulter and Complainer
    	Account defAccount = TST_AccountTestHelper.createDummyAccount('Belgium', true);
    	ret.Defaulter_Account_Name__c = defAccount.Id;
    	//ret.Defaulter_Account__c = TST_AccountTestHelper.createDummyAccount(tlrAccRTId).Id;

    	insert ret;
    	return ret;
    }
}