/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class PADTest {

    public static testMethod void testSendEmail()
	{
	    PAD.MyLog('START PAD.testSendEmail');
	    //sendEmail(new String[]{'test@test.com'}, 'noreply@test.com', 'senderDisplayName', 'subject', 'plainTextBody', 'htmlBody',true, true,true, null,null,null );
	    PAD.MyLog('END PAD.testSendEmail');
	
	}
	
	static testMethod void PAD_Main_TestMethod()
	{
	    PAD.log('','');
	    PAD.log('',1);
	    PAD.log(1,'');
	    PAD.log(1,1);
	    PAD.log(1);
	    PAD.log('');
	    PAD.startTimer();
	    PAD.stopTimer();
	    PAD.limits();
	    PAD.myColor(0,0);
	    PAD.myColor(0,3);
	    PAD.myColor(2,3);
	    PAD.myColor(3,3);
	    PAD myPAD=new PAD();
	    myPAD.getPAD_logs();
	    PAD.canTrigger('');
	}
	public static testMethod void testDataBaseUpdateLstSobjectsAndBatchApexFinishReport()
	{
	    PAD.MyLog('START PAD.testDataBaseUpdateLstSobjects');
	    Account a = new Account(Name = 'name1');
	    Account a2 = new Account(Name = 'name2');
	
	    List<PAD.ErrorLogItem> lstErrorLogItem = new List<PAD.ErrorLogItem>();
	    Map<String,Integer> mapSuccessDML = new Map<String,Integer>();
	    Map<String,Integer> mapErrorDML = new Map<String,Integer>();
	    PAD.myLog('Start Test');
	    Test.startTest();
	        PAD.dataBaseUpdateLstSobjects(new List<Account>{a,a2}, lstErrorLogItem, mapSuccessDML, mapErrorDML);
	        System.assertEquals(2,lstErrorLogItem.size());
	    Test.stopTest();
	    PAD.myLog('Stop Test');
	    PAD.MyLog('END PAD.testDataBaseUpdateLstSobjects');
	}
	
	public static testMethod void testGetSIRENfromSIRET()
	{
	    PAD.MyLog('START PAD.testGetSIRENfromSIRET');
	    String siret = '12345678912345';
	    System.AssertEquals('123456789', PAD.getSIRENfromSIRET(siret));
	    PAD.MyLog('END PAD.testGetSIRENfromSIRET');
	}
	
	public static testMethod void testGetSoqlListIdFromSet()
	{
	    PAD.MyLog('START PAD.testGetSoqlListIdFromSet');
	    Account a = new Account(Name = 'name1');
	    Account a2 = new Account(Name = 'name2');
	    PAD.getSoqlListIdFromSet(new Set<Id>{a.Id,a2.Id});
	    PAD.MyLog('END PAD.testGetSoqlListIdFromSet');
	}
	
	//TEST METHOD
	public static testMethod void testgetSetFromFieldName()
	{
		//Data Preparation
		TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
		Account myAccount1 = TST_AccountTestHelper.createDummyAccount('France',true);
		Account myAccount2 = TST_AccountTestHelper.createDummyAccount('France',true);
		
		//Define Set(s) to be asserted with getSetFromFieldName() function result
		Set<String> setAccsId = new Set<String>();
		setAccsId.add(myAccount1.Id);
		setAccsId.add(myAccount2.Id);
		Set<String> setAccsName = new Set<String>();
		setAccsName.add(myAccount1.Name);
		setAccsName.add(myAccount2.Name);
		//Define List in Parameter of getSetFromFieldName() function
		List<Account> lstAccs = new List<Account>();
		lstAccs.add(myAccount1);
		lstAccs.add(myAccount2);
		//ASSERT Set Account Name
		PAD.myLog('Début du StartTest');
		Test.startTest();
		Set<String> mySetFieldNameAccNames = PAD.getSetFromFieldName(lstAccs,'Name');
		Test.stopTest();
		PAD.myLog('Fin du StartTest');
		System.assertEquals(setAccsName,mySetFieldNameAccNames);
		//ASSERT Set Account Id
		Set<String> mySetFieldNameAccIds = PAD.getSetFromFieldName(lstAccs,'Id');
		System.assertEquals(setAccsId,mySetFieldNameAccIds);
		//ASSERT Set Type -> Null
		Set<String> mySetFieldNameAccTypes = PAD.getSetFromFieldName(lstAccs,'Type');
		System.assertEquals(new Set<String>{'Customer'},mySetFieldNameAccTypes);
	}
	
	public static testMethod void testMyLog(){
		PAD.myLog('Début du StartTest');
		Test.startTest();
		PAD.myLog('my Log information');
		Test.stopTest();
		PAD.myLog('Fin du StartTest');
	}
	
	public static testMethod void testLogLimits(){
		PAD.myLog('Début du StartTest');
		Test.startTest();
		PAD.logLimits();
		Test.stopTest();
		PAD.myLog('Fin du StartTest');
	}
	
	
	static testMethod void testErrorLogItem()
	{
	    PAD.myLog('START ErrorLogItem.testErrorLogItem');
	    TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
	    Account a = TST_AccountTestHelper.createDummyAccount('France',false);
	    PAD.ErrorLogItem erLi = new PAD.ErrorLogItem();
	    erLi.Id = a.Id;
	    erLi.objectTypeItem = 'Account';
	    erLi.ErrorMsg = 'Error Message';
	    PAD.myLog('END ErrorLogItem.testErrorLogItem');
	}
}