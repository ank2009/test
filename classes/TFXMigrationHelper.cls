public without sharing class TFXMigrationHelper
{     /**
    * @author       Aleh Tsilko (aleh_tsilko@epam.com)
    * @date         2015 April 23
    * @description  Helper for TFX Migration Job
    * @CM-440 JIRA TASK              
    */
    public static final Id AUTHOR_MIGR_SUBS_ID; 
    public static final Id RECORD_TYPE_MIGR_ID;
    public static final List<Id> TFX_PRODUCTNAME_IDS;
    public static final String TFXSUBSNAME = 'Subscription - TFX Migration - 2015';
    
    private static final String TFX_RECTYPE_NAME = 'TLR Subscription Active';
    private static final List<String> TFX_PRODUCT_NAMES = New List<String> {'T-PRO','T-Active'};
    
    static 
    {
     // Query and cache static ids for tfx migration
        
        RECORD_TYPE_MIGR_ID = Schema.SObjectType.Subscription__c.getRecordTypeInfosByName().get(TFX_RECTYPE_NAME).getRecordTypeId();
        
        TFX_PRODUCTNAME_IDS = New List<String>();
        for(Product__c currProduct:[SELECT Id FROM Product__c WHERE Name IN :TFX_PRODUCT_NAMES])
        {
            TFX_PRODUCTNAME_IDS.add(currProduct.Id);
        }                
    }//static
    
    //make statusMigrationMessage from DML errors
    public static String getDMLErrors(DmlException iEx)
    {
        String groupResult='';
        for(Integer i = 0; i < iEx.getNumDml(); i++)
        {
            groupResult = groupResult + String.ValueOf(iEx.getDmlMessage(i)) + ', ';
        }        
        return groupResult;
    }
    
    //write log string for status of TFX migration for current Account
    public static void addTFXMigrationLog (Account currAcc, String statusString)
    {
        String logName = date.today().format();
        List<TFX_Migration_Daily_Log__c> qLogList = [SELECT Name, Status_migration__c 
                                                       FROM TFX_Migration_Daily_Log__c 
                                                      WHERE Name =: logName];
        TFX_Migration_Daily_Log__c currTFXMigrationLog = New TFX_Migration_Daily_Log__c (); 
        DateTime d = datetime.now();                                                     
        if(!qLogList.isEmpty())
        {                                              
            currTFXMigrationLog = qLogList[0];
        } 
        else
        {
            currTFXMigrationLog.Name = logName;
            currTFXMigrationLog.Status_migration__c = 'Start Migration Time = ' + d.format('hh:mm:ss a');
        }
        String logRecord =  '\r\n' + d.format('hh:mm:ss a') + ' ,  AccountID:' + currAcc.Id + ' ,  Name:' + currAcc.Name + ' , TFX Migration Status:' + statusString;
        currTFXMigrationLog.Status_migration__c = currTFXMigrationLog.Status_migration__c + logRecord;       
        upsert currTFXMigrationLog;                 
    }
    
    //write log string for check pack name errors
    public static void addTFXCheckLog (String statusString)
    {
        String logName = date.today().format();
        List<TFX_Migration_Daily_Log__c> qLogList = [SELECT Name, Status_migration__c 
                                                       FROM TFX_Migration_Daily_Log__c 
                                                      WHERE Name =: logName];
        TFX_Migration_Daily_Log__c currTFXMigrationLog = New TFX_Migration_Daily_Log__c (); 
        DateTime d = datetime.now();                                                     
        if(!qLogList.isEmpty())
        {                                              
            currTFXMigrationLog = qLogList[0];
        } 
        else
        {
            currTFXMigrationLog.Name = logName;
            currTFXMigrationLog.Status_migration__c = 'Start Check Time = ' + d.format('hh:mm:ss a');
        }
        String logRecord =  '\r\n' + d.format('hh:mm:ss a') + ' ,  result:' + statusString;
        currTFXMigrationLog.Status_migration__c = currTFXMigrationLog.Status_migration__c + logRecord;       
        upsert currTFXMigrationLog;                 
    }
}