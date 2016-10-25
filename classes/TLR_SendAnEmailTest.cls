/**
* @author       Andrei Lobkis (andrei_lobkis@epam.com)
* @date         6 october 2015
* @description  Tests for TLR_SendAnEmail controller
**/

@isTest
private class TLR_SendAnEmailTest
{
    private static Case testcase;
    private static Account testaccount;
    private static PageReference casepage;
    private static PageReference page;
    private static TLR_SendAnEmail sendAnEmail;
    
        
	static testMethod void initSendAnEmailTest()
	{
        createTestObjects();
          
        system.assert(sendAnEmail.objectName==testcase.CaseNumber,'controller hasn\'t returned the correct object name');        
        page=new PageReference('apex/TLR_SendAnEmail');
        page.getParameters().put('eid',testaccount.id);
        apexpages.currentPage().getHeaders().put('Referer',page.getUrl());
        sendAnEmail = new TLR_SendAnEmail();		
		sendAnEmail.initSendAnEmail();        
        system.assert(sendAnEmail.objectName==testaccount.Name,'controller hasn\'t returned the correct object name');
	}
    
    static testMethod void sendEmailTest()
	{
        createTestObjects();
        
        sendAnEmail.sendEmail();        
        List<Task> tasks=[select Id from Task];
        system.assert(tasks.size()==0,'The must not be any tasks');           
        sendAnEmail.emailTo='emailTo_1@test.ok';
        sendAnEmail.emailAdditionalTo='emailAdditionalTo_1@test.ok';
        sendAnEmail.emailCC='emailCC_1@test.ok';
        sendAnEmail.emailBCC='emailBCC_1@test.ok';
        sendAnEmail.emailSubject='subject';
        sendAnEmail.emailBody='body';
        List<OrgWideEmailAddress> lstOrgWideEmailAddress =[Select Id, DisplayName, Address From OrgWideEmailAddress where Address !=: Userinfo.getUserEmail()];
        sendAnEmail.selectedFromAddress=lstOrgWideEmailAddress[0].Id;
        
        sendAnEmail.sendEmail();
        tasks=[select Id from Task];
        system.assert(tasks.size()==1,'The task hasn\'t been created');
    }
    
    static testMethod void cancelTest()
    {
        createTestObjects(); 
        PageReference pageref=sendAnEmail.cancel();
        system.assert(casepage.getUrl()==casepage.getUrl(),'Returned URL is not right');
    }
    
   
    
    private static void createTestObjects()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        testcase=new Case();
        insert testcase;
        testcase=[select Id, CaseNumber from Case];        
        testaccount=TST_AccountTestHelper.createDummyAccount(true);
        testaccount=[select Id, Name from Account];        
        casepage=new ApexPages.StandardController(testcase).view();
        page=new PageReference('apex/TLR_SendAnEmail');
        page.getParameters().put('eid',testcase.id);
        page.getParameters().put('retURL',casepage.getUrl());
        apexpages.currentPage().getHeaders().put('Referer',page.getUrl());
        sendAnEmail = new TLR_SendAnEmail();
        sendAnEmail.initSendAnEmail();
    }
}