@isTest
private class CampaignMemberFollowUpTest 
{
    static testMethod void myUnitTest() 
    {
		//Test cases
		//call test data creation class
		CampaignMemberFollowUpTestData.createTestData();
		
		//get test_Campaign
		Campaign testCampaign = [select id, name, status, ownerId from campaign where name ='test_campaign' order by name desc limit 1];
		System.debug('+++++Campaign Id :'+testCampaign.id);
		
		test.startTest();
		//init page controller
		CampaignMemberFollowUpController myController = new CampaignMemberFollowUpController();
		
		//select campaign section
		myController.getItemsCampaignStatus();
		myController.getSelectCampaignStatus();
		myController.setSelectCampaignStatus('Planned');
		myController.getCMemberListNext();
		myController.getCMemberList_size();
		myController.getCampaigns();
		myController.getCampaign();
		myController.setCampaign(testCampaign.id);
		myController.renderFollowUpTrue();
		
		//follow up task section
		myController.loadCampaignMemberList();
		myController.renderFollowUpTrue();
		myController.getOwnerTodo();
		
				
		//CMresults section
		myController.getCMemberList_size();
		myController.getSelectedCM();
		myController.getshowprev();
		myController.getshownext();
		myController.getCMemberListNext();
		myController.getallCheckboxes();
		myController.setallCheckboxes(true);
		myController.setallCheckboxes(false);
		myController.selectAllCMembers();
		myController.selectAllCMembers();
		
		//select one CM
		myController.changeSingleCheckbox();
		
		//select all in page CMs
		myController.changeCheckbox();
		
		//celect all in list CMs
		myController.selectAllCMembers();
		
		//paging
		myController.Next();
		myController.Prev();
		
		//V1.1
		myController.selectedFilterStatus = 'Sent';
		myController.Zip='80';
		myController.EmployeesFrom=10;
		myController.EmployeesTo=200;
		// Both case
		myController.selectedFilterType = 'Both';
		myController.gofilter();
		// Lead case
		myController.selectedFilterType = 'Lead';
		myController.gofilter();
		// Contact case
		myController.selectedFilterType = 'Contact';
		myController.gofilter();
		
		//variants of Employees search
		myController.EmployeesFrom=null;
		myController.EmployeesTo=200;
		// Both case
		myController.selectedFilterType = 'Both';
		myController.gofilter();
		// Lead case
		myController.selectedFilterType = 'Lead';
		myController.gofilter();
		// Contact case
		myController.selectedFilterType = 'Contact';
		myController.gofilter();
		
		//variants of Employees search
		myController.EmployeesFrom=10;
		myController.EmployeesTo=null;
		// Both case
		myController.selectedFilterType = 'Both';
		myController.gofilter();
		// Lead case
		myController.selectedFilterType = 'Lead';
		myController.gofilter();
		// Contact case
		myController.selectedFilterType = 'Contact';
		myController.gofilter();
		
		//variants of Employees & zip searchsearch
		myController.EmployeesFrom=null;
		myController.EmployeesTo=null;
		myController.Zip=null;
		// Both case
		myController.Title='Chef';
		myController.selectedFilterType = 'Both';
		myController.gofilter();
		// Lead case
		myController.selectedFilterType = 'Lead';
		myController.gofilter();
		// Contact case
		myController.selectedFilterType = 'Contact';
		myController.gofilter();		
		
		//create task(s)
		myController.generateTodos();
		myController.getBadCMemberList();
		myController.showList();
		test.stopTest();

    }
    
    static testMethod void MyUnitTestwithQuery(){
		//Test cases
		//call test data creation class
		CampaignMemberFollowUpTestData.createTestData();
		
		//get test_Campaign
		Campaign testCampaign = [select id, name, status, ownerId from campaign where name = 'test_campaign' order by name desc limit 1];
		
		test.startTest();

    	//check page with query parameter
		PageReference pageRef = Page.CampaignMemberFollowUp;
		test.setCurrentPage(pageRef);
		apexpages.currentPage().getParameters().put('id', testCampaign.Id);

		//init page controller
		CampaignMemberFollowUpController myController = new CampaignMemberFollowUpController();
    
		test.stopTest();
    }
    
}