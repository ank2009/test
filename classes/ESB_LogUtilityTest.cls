/** 
* @author       Anton Solovyev (anton_soloveyv@epam.com)
* @date         2014 December 4
* @description  unit tests for ESB_LogUtilitys class (ESB Calls logging & decrypt helpers)
*/
@isTest
public class ESB_LogUtilityTest
{
	public class WriteLogParams
	{
		public ESB_LogUtility.MessageDirection dir;
		public string msgType;
		public string msgBody;
		public string response;
		public string correlationId;
		public integer esbResponseCode;
        public string errorMessage;
	}
	
	private static WriteLogParams GetRandomLogParams()
	{
		WriteLogParams retVal = new WriteLogParams();
		
		retVal.dir = (Math.random() > 0.5) ? ESB_LogUtility.MessageDirection.Incoming : ESB_LogUtility.MessageDirection.Outgoing;
		retVal.msgType = Utilities.getRandomString(Utilities.randomStringAlphabets.alphaSmallAndCaps, 10);
		retVal.msgBody = Utilities.getRandomString(Utilities.randomStringAlphabets.alphaSmallAndCaps, 10);
		retVal.response = Utilities.getRandomString(Utilities.randomStringAlphabets.alphaSmallAndCaps, 10);
		retVal.correlationId = Utilities.getRandomString(Utilities.randomStringAlphabets.alphaSmallAndCaps, 10);
        retVal.errorMessage = Utilities.getRandomString(Utilities.randomStringAlphabets.alphaSmallAndCaps, 20);
		retVal.esbResponseCode = Math.round(Math.random() * (999));
		
		return retVal;
	}
	
	public static testMethod void WriteLogTest()
	{
		// 1 - test normal flow
		WriteLogParams params = GetRandomLogParams();
		
        ESB_LogUtility.WriteLog(params.dir, params.msgType, params.msgBody, params.response, params.correlationId, params.esbResponseCode, params.errorMessage, null, null);
		
		ESB_Interaction_Logs__c logRecord = [
			SELECT Message_direction__c, Body__c, ESB_response__c, Message_type__c, Message_correlationId__c, ESB_response_status__c, Message__c
			FROM ESB_Interaction_Logs__c
			WHERE Message_correlationId__c = :params.correlationId
		];
		
		system.AssertEquals(string.ValueOf(params.dir), logRecord.Message_direction__c, 'Message direction is not saved!');
		system.AssertEquals(params.msgType, logRecord.Message_type__c, 'Message type is not saved!');
		system.AssertEquals(params.msgBody, logRecord.Body__c, 'Message body is not saved!');
		system.AssertEquals(params.response, logRecord.ESB_response__c, 'ESB response is not saved!');
		system.AssertEquals(params.correlationId, logRecord.Message_correlationId__c, 'Message Correlation ID is not saved!');
		system.AssertEquals(params.esbResponseCode, logRecord.ESB_response_status__c, 'ESB Resopnse code is not saved!');
        system.AssertEquals(params.errorMessage, logRecord.Message__c, 'ESB Resopnse code is not saved!');
		
		// 2 - company test
		
		// 3 - user test
		
	} //WriteLogTest
}