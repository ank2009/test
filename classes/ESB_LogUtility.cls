/** 
* @author       Anton Solovyev (anton_soloveyv@epam.com)
* @date         2015 January 20
* @description  Provides methods to interact with ESB_Interaction_Log object
*/
public without sharing class ESB_LogUtility 
{
    public enum MessageDirection { Incoming, Outgoing }
    
 
    
/*************************************************************************************************************************************************/        
   /** 
    * @author       Aleh Tsilko (aleh_tsilko@epam.com)
    * @date         2016 March
    * @description  Writes log: object ESB_Interaction_Log__c - main of main of function, with Id of parent objects
    */
    
    public static void WriteLog(MessageDirection dir, string msgType, string msgBody, string response, string correlationId, integer esbResponseCode, string errorMessage, Id accountId, Id contactId)
    {
        ESB_Interaction_Logs__c logRecord = CreateLog(dir, msgType, msgBody, response, correlationId, esbResponseCode, errorMessage);
        if(accountId != NULL)
        {
            logRecord.Account__c = accountId;
        }
        if(contactId != NULL)
        {
            logRecord.Contact__c = contactId;
        }
        insert logRecord;
    } // WrietLog   
    
    
    public static void WriteLog(MessageDirection dir, string msgType, string msgBody, string response, string correlationId, string errorMessage, Id accountId, Id contactId)
    {
        WriteLog(dir, msgType, msgBody, response, correlationId, -999, errorMessage, accountId, contactId);
    } // WrietLog 
    
    
    public static void WriteLog(string msgType, ESB_DataClasses.company company, ESB_DataClasses.response response, string correlationId, string errorMessage, Id accountId, Id contactId)
    {
        string msgBody = string.valueOf(company);
        string resp = string.ValueOf(response);
        WriteLog(MessageDirection.Incoming, msgType, msgBody, resp, correlationId, errorMessage, accountId, contactId);
    } // WrietLog(string, company, response, correlationId)
    
        
    public static void WriteLog(string msgType, ESB_DataClasses.user user, ESB_DataClasses.response response, string correlationId, string errorMessage, Id accountId, Id contactId)
    {
        string msgBody = string.valueOf(user);
        string resp = string.ValueOf(response);
        WriteLog(MessageDirection.Incoming, msgType, msgBody, resp, correlationId, errorMessage, accountId, contactId);
    } // WrietLog(string, user, response, correlationId, contactId)
    
    
    public static void WriteLog(string msgType, ESB_DataClasses.company company, ESB_DataClasses.response response, string correlationId, string errorMessage, Id accountId)
    {
        string msgBody = string.valueOf(company);
        string resp = string.ValueOf(response);
        WriteLog(MessageDirection.Incoming, msgType, msgBody, resp, correlationId, errorMessage, accountId, NULL);
    } // WrietLog(string, company, response, correlationId)
    
    
    public static void WriteLog(string msgType, ESB_DataClasses.user user, ESB_DataClasses.response response, string correlationId, string errorMessage, Id contactId)
    {
        string msgBody = string.valueOf(user);
        string resp = string.ValueOf(response);
        WriteLog(MessageDirection.Incoming, msgType, msgBody, resp, correlationId, errorMessage, contactId, NULL);
    } // WrietL
    
/*************************************************************************************************************************************************/            
    
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2015 July 21
    * @description  Creates log record. To use in methods not allowed to execute DML statements
    */
    public static ESB_Interaction_Logs__c CreateLog(MessageDirection dir, string msgType, string msgBody, string response, string correlationId, integer esbResponseCode, string errorMessage)
    {
        ESB_Interaction_Logs__c logRecord = new ESB_Interaction_Logs__c();
        logRecord.Message_direction__c = string.valueOf(dir);
        logRecord.Body__c = msgBody;
        logRecord.ESB_response__c = response;
        logRecord.Message_type__c = msgType;
        
        logRecord.Message__c = errorMessage;
        
        if(string.isNotEmpty(correlationId))
            logRecord.Message_correlationId__c = correlationId;
        
        if(esbResponseCode != -999)
            logRecord.ESB_response_status__c = esbResponseCode;
        
        return logRecord;
    }
}