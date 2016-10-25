public class PAD{

private static final Set<String> requiredOnce=new Set<String>{'AP123','AP432'};//List of Apex codes that should run only once. Add any code to the list
private static Set<String>hasRun=new Set<String>();//List of Apex code that has already been run. Keep this list empty.
public static final String PAD_BypassTrigger;//List of triggers that can be bypassed
public static final Boolean PAD_DebugMode {get;set;}
public static final String userRoleName;  //User Role Name
public static final String userProfileName;//User Profile Name
static{
    System.Debug('## >>> PAD constructor :BEGIN <<< run by ' + UserInfo.getName());
    User user=[SELECT UserRole.Name,Profile.Name,UserPreferencesApexPagesDeveloperMode,ByPassTrigger__c FROM User WHERE Id =:UserInfo.getUserId() LIMIT 1];
    PAD_BypassTrigger=';'+user.ByPassTrigger__c+';';
    PAD_DebugMode=user.UserPreferencesApexPagesDeveloperMode;
    userRoleName= user.UserRole.Name;
    userProfileName = user.Profile.Name;
    System.Debug('## >>> PAD constructor : END <<<');
}
public static boolean canTrigger(String ApexName){//If no bypass
    if(requiredOnce.contains(ApexName)){//If it should run Once
        if(hasRun.contains(ApexName))return false;//Already run, should not run
        hasRun.add(ApexName);//Never run, can run only if not bypassed
    }
    return(PAD_BypassTrigger.indexOf(';'+ApexName+';')==-1);
}
/*Uncomment if you have activated multiple currency
    public static Double convertToCorporateCurrency(String currencyIsoCode, Double amount){
    if(!currencyRate.containsKey(currencyIsoCode))
        for(CurrencyType curType: [SELECT IsoCode, ConversionRate FROM CurrencyType WHERE IsActive=true])
        currencyRate.put(curType.IsoCode, curType.ConversionRate);
    return amount/currencyRate.get(currencyIsoCode);
}*/
/**********************
Visual Force part below
***********************/
public class PAD_log{//One log entry
    public String timer{get;set;}
    public String reason{get;set;}
    public String message{get;set;}
    public String rowCSS{get;set;}
    public PAD_log(String message,String reason){
        this.timer=DateTime.now().format('HH:mm:ss , SS\'ms\'');
        this.reason=reason;
        this.message=message;
    }
    public PAD_log(String message,String reason,String rowCSS){
        this.timer=DateTime.now().format('HH:mm:ss , SS\'ms\'');
        this.reason=reason;
        this.message=message;
        this.rowCSS=rowCSS;
    }
}
public static Long starter;
public static List<PAD_log>PAD_logs=new List<PAD_log>();
public static void startTimer(){
    starter=DateTime.now().getTime();
    log('<img src="/img/icon/custom51_100/stopwatch16.gif" width="16px" height="16px"');
}
public static void stopTimer(){if(starter!=null)log('<img src="/img/icon/custom51_100/stopwatch16.gif" width="16px" height="16px" /><i> '+String.ValueOf(DateTime.now().getTime()-starter)+' ms</i>');}
public static void log(String message,String reason,String rowColor){if(PAD_logs.size()<1000)PAD_logs.add(new PAD_log(message,reason,rowColor));}
public static void log(String message,String reason){if(PAD_logs.size()<1000)PAD_logs.add(new PAD_log(message,reason));}
public static void log(String message){if(PAD_logs.size()<1000)PAD_logs.add(new PAD_log(message,''));}
public static void log(Integer message){if(PAD_logs.size()<1000)PAD_logs.add(new PAD_log(String.valueOf(message),''));}
public static void log(Integer message,String reason){if(PAD_logs.size()<1000)PAD_logs.add(new PAD_log(String.valueOf(message),reason));}
public static void log(Integer message,Integer reason){if(PAD_logs.size()<1000)PAD_logs.add(new PAD_log(String.valueOf(message),String.valueOf(reason)));}
public static void log(String message,Integer reason){if(PAD_logs.size()<1000)PAD_logs.add(new PAD_log(message,String.valueOf(reason)));}
public static String myColor(Integer myFrom,Integer myTo){
    Decimal myPercent;
    if(myTo!=0)myPercent=(myFrom+0.0)/(myTo+0.0);
    else myPercent=0;
    if(myPercent>=0.8)return 'background-color:#B22222;color:white;font-weight:bold;';
    else if(myPercent>=0.5)return 'background-color:#FF7F00;color:white;font-weight:bold;';
    else return 'font-weight:bold;';
}
public static void limits(){
    log(Limits.getAggregateQueries()+' / '+Limits.getLimitAggregateQueries(),'AggregateQueries',myColor(Limits.getAggregateQueries(),Limits.getLimitAggregateQueries()));
    log(Limits.getCallouts()+' / '+Limits.getLimitCallouts(),'Callouts',myColor(Limits.getCallouts(),Limits.getLimitCallouts()));
    log(Limits.getDMLRows()+' / '+Limits.getLimitDMLRows(),'DMLRows',myColor(Limits.getDMLRows(),Limits.getLimitDMLRows()));
    log(Limits.getDMLStatements()+' / '+Limits.getLimitDMLStatements(),'DMLStatements',myColor(Limits.getDMLStatements(),Limits.getLimitDMLStatements()));
    log(Limits.getEmailInvocations()+' / '+Limits.getLimitEmailInvocations(),'EmailInvocations',myColor(Limits.getEmailInvocations(),Limits.getLimitEmailInvocations()));
    
    log(Limits.getFindSimilarCalls()+' / '+Limits.getLimitFindSimilarCalls(),'FindSimilarCalls',myColor(Limits.getFindSimilarCalls(),Limits.getLimitFindSimilarCalls()));
    log(Limits.getFutureCalls()+' / '+Limits.getLimitFutureCalls(),'FutureCalls',myColor(Limits.getFutureCalls(),Limits.getLimitFutureCalls()));
    log(Limits.getHeapSize()+' / '+Limits.getLimitHeapSize(),'HeapSize',myColor(Limits.getHeapSize(),Limits.getLimitHeapSize()));
    log(Limits.getQueries()+' / '+Limits.getLimitQueries(),'Queries',myColor(Limits.getQueries(),Limits.getLimitQueries()));
   
    log(Limits.getQueryRows()+' / '+Limits.getLimitQueryRows(),'QueryRows',myColor(Limits.getQueryRows(),Limits.getLimitQueryRows()));
    log(Limits.getSavepointRollbacks()+' / '+Limits.getLimitSavepointRollbacks(),'SavepointRollbacks',myColor(Limits.getSavepointRollbacks(),Limits.getLimitSavepointRollbacks()));
    log(Limits.getSavepoints()+' / '+Limits.getLimitSavepoints(),'Savepoints',myColor(Limits.getSavepoints(),Limits.getLimitSavepoints()));
   
    log(Limits.getSoslQueries()+' / '+Limits.getLimitSoslQueries(),'SoslQueries',myColor(Limits.getSoslQueries(),Limits.getLimitSoslQueries()));
}
public List<PAD_log>getPAD_logs(){return PAD_logs;}


//////////////////////////////////////////////////////////////////////////////////////////////////
//                                  KERENSEN ADDED
//////////////////////////////////////////////////////////////////////////////////////////////////
/* Methode spécifique pour vérifier si le champ est null ou pas
 @param String variable à tester
 @return boolean
*/
public static boolean IsEmpty(String Input)
{
    if (Input ==''||Input == Null)
        return true;
    else
        return False ;

}



//Number of script statements: 10 out of 200000
public static Set<String> getSetFromFieldName(List<sObject> lstObject, string fieldName) {
System.Debug('## >>> Starting - getSetFromFieldName()');
Set<String> stringSet = new Set<String>();
for(sObject obj:lstObject) {
if(obj.get(fieldName) != null) stringSet.add((String)obj.get(fieldName));
System.debug('## '+ fieldName + ' IdSet:'+(String)obj.get(fieldName));
}
System.debug('## ' + fieldName + ' IdSet Size:'+stringSet.size());
System.Debug('## >>> Ending - getSetFromFieldName()');
return stringSet;
}


//Number of script statements: 2 out of 200000
public static void myLog(String myString){system.debug('###### >>> '+myString+' <<< ######');}

//Number of script statements: 6 out of 200000
public static void logLimits()
{
    myLog('getDMLRows/Limit:'+Limits.getDMLRows() + '/' + Limits.getLimitDMLRows());
    myLog('getDMLStatements/Limit:'+Limits.getDMLStatements() + '/' + Limits.getLimitDMLStatements());
    myLog('getHeapSize/Limit:'+Limits.getHeapSize() + '/' + Limits.getLimitHeapSize());
    myLog('getQueries/Limit:'+Limits.getQueries() + '/' + Limits.getLimitQueries());
    myLog('getQueryRows/Limit:'+Limits.getQueryRows() + '/' + Limits.getLimitQueryRows());
    myLog('getSoslQueries/Limit:'+Limits.getSoslQueries() + '/' + Limits.getLimitSoslQueries());
}


/*=============================================================================================
  UPDATE RECORDS - TRACK ERRORS/SUCCESS
===============================================================================================*/
public static void dataBaseUpdateLstSobjects(List<SObject> lstSobj,List<ErrorLogItem > lstErrorLogItem,Map<String,Integer> mapObjectNbSuccessDML,Map<String,Integer> mapObjectNbErrorDML )
{
    System.debug('### START dataBaseUpdateLstSobjects()');

    Database.SaveResult[] lsr = Database.update(lstSobj,false);
    Integer cpt = 0;  //index of listObj, see NOTE Below
    String SObjectName = lstSobj.get(0).getSObjectType().getDescribe().getName();
    // Process the save results
    for(Database.SaveResult sr : lsr)
    {
        if(!sr.isSuccess())
        {
            //mapIdItemProcessedErrorMsg.put(lstSobj.get(cpt).Id,sr.getErrors()[0].getStatusCode() + ':'+ sr.getErrors()[0].getMessage());
            ErrorLogItem errItem = new ErrorLogItem();
            errItem.Id = lstSobj.get(cpt).Id;
            errItem.objectTypeItem = SObjectName;
            errItem.ErrorMsg = sr.getErrors()[0].getStatusCode() + ':'+ sr.getErrors()[0].getMessage();
            lstErrorLogItem.add(errItem);
            //NOTE : sr.getId() does not work when an error occurs
            PAD.myLog('Id Item Error:'+ lstSobj.get(cpt) +', Error message:' + sr.getErrors()[0]);
            //COMPTEUR ERROR
            if(mapObjectNbErrorDML.get(SObjectName) == null)
                mapObjectNbErrorDML.put(SObjectName,1);
            else
                mapObjectNbErrorDML.put(SObjectName,mapObjectNbErrorDML.get(SObjectName)+1);
        }
        else
        {   PAD.myLog('Id Item Success:'+ sr.getId());
            //COMPTEUR SUCCESS
            if(mapObjectNbSuccessDML.get(SObjectName) == null)
                mapObjectNbSuccessDML.put(SObjectName,1);
            else
                mapObjectNbSuccessDML.put(SObjectName,mapObjectNbSuccessDML.get(SObjectName)+1);
        }
        cpt++;
    }
    System.debug('### END dataBaseUpdateLstSobjects()');
}


//utiliser par le dynamic SOQL : cf method sortData()
 public static String getSoqlListIdFromSet(Set<Id> idSet)
 {
    System.Debug('### START - getSoqlListIdFromSet()');
    String strList ='';
    Integer cpt = 1;
    for(Id id : idSet)
    {
        if(idSet.size() == cpt)  //pas de virgule pour dernier item
            strList+= '\''+ id + '\'';
        else
         strList+= '\''+ id + '\',';

        cpt++;
    }
    System.debug('### Result List:'+strList);
    System.debug('### END - getSoqlListIdFromSet()');
    return strList;
 }

public static void batchApexFinishReport(Database.BatchableContext BC,String batchEmailSubject,String batchObjectName,Set<String> setObjectsTreated,List<ErrorLogItem > lstErrorLogItem,Map<String,Integer> mapObjectNbSuccessDML,Map<String,Integer> mapObjectNbErrorDML)
{
     System.Debug('### START - PAD.batchApexFinishReport()');
     AsyncApexJob a = [SELECT id, ApexClassId, Status,CreatedDate, CompletedDate,
                          JobItemsProcessed,
                          TotalJobItems,
                          NumberOfErrors,
                          CreatedBy.Email
                          FROM AsyncApexJob
                          WHERE id = :BC.getJobId()];

         Integer sumErrors =  0;
         for(String obj : setObjectsTreated) sumErrors += mapObjectNbErrorDML.get(obj);
         String subject = batchEmailSubject+' Report ['+ batchObjectName +'] - Nb Erreurs :'+sumErrors;

         String emailMessage = subject;
         emailMessage += '<br /> Task started:' + a.CreatedDate;
         emailMessage += '<br /> Task ended:' + a.CompletedDate;
         emailMessage += '<br /> Result : \n' + a.totalJobItems  + ' / ' + a.TotalJobItems + ' Jobs de 200 éléments traités (batchSize = 200)';
         emailMessage += '<br /> '+ a.NumberOfErrors +' Job(s) en Erreur';
         for(String obj : setObjectsTreated)
         {
             emailMessage += '<br /> Nbr '+obj+'s Mis à jour:' + mapObjectNbSuccessDML.get(obj);
             emailMessage += '<br /> Nbr '+obj+'(s) en Erreurs:' + mapObjectNbErrorDML.get(obj);
             emailMessage +=' <br />';
         }
         emailMessage += 'Liste des erreurs : <hr />';
         emailMessage += 'Id,Objet,Error <br />';
         //Log Errors
         for(ErrorLogItem item : lstErrorLogItem)
            emailMessage += item.Id +','+ item.objectTypeItem + ','+ item.ErrorMsg +'<br />';
         //for(Id sObjId : mapIdItemProcessedErrorMsg.keySet())
        //  emailMessage += sObjId +','+ mapIdItemProcessedErrorMsg.get(sObjId) + '<br />';
         Messaging.SingleEmailMessage mail =
                  new Messaging.SingleEmailMessage();
         String[] toAddresses = new String[]
                  {a.createdBy.email};
         mail.setToAddresses(toAddresses);
         mail.setReplyTo('noreply@salesforce.com');
         mail.setSenderDisplayName('Batch Job Summary');
         mail.setSubject(subject);
         mail.setPlainTextBody(emailMessage);
         mail.setHtmlBody(emailMessage.replace('\\n', '<br />'));
         Messaging.sendEmail(new
              Messaging.SingleEmailMessage[] { mail });
       System.Debug('### END - PAD.batchApexFinishReport()');
}
/*
public static void sendEmail(String[] toAddresses, String replyTo, String senderDisplayName, String subject, String plainTextBody, String htmlBody, boolean bccSender, boolean useSignature, boolean saveAsActivity, Id templateID, Id whatId, Id targetObjectId )
{
     PAD.MyLog('### START - PAD.sendEmail()');
     Messaging.SingleEmailMessage mail =
                  new Messaging.SingleEmailMessage();
         mail.setToAddresses(toAddresses);
         mail.setReplyTo(replyTo);
         mail.setSenderDisplayName(senderDisplayName);
         mail.setBccSender(bccSender);
         if(templateID == null)
         {
             mail.setSubject(subject);
             mail.setPlainTextBody(plainTextBody);
             mail.setHtmlBody(htmlBody);
             mail.setSaveAsActivity(saveAsActivity);
         }
         else
         {
            mail.setTemplateID(templateID);
            mail.setSaveAsActivity(false);
            mail.setWhatId(whatId);
            mail.setTargetObjectId(targetObjectId);
         }
         mail.setUseSignature(useSignature);
         PAD.MyLog('mail:'+mail);
         Messaging.sendEmail(new
              Messaging.SingleEmailMessage[] { mail });
         PAD.MyLog('### END - PAD.sendEmail()');
}*/

public static String getSIRENfromSIRET(String siret)
{
    PAD.MyLog('START PAD.getSIRENfromSIRET');
    String siren = '';
    if(! PAD.IsEmpty(siret))
        if(siret.length() >= 9)
             SIREN = siret.substring(0,9);
     PAD.MyLog('SIREN:'+siren);
     PAD.MyLog('START PAD.getSIRENfromSIRET');
     return siren;
}

public Class ErrorLogItem
	
{
  public Id id {get; set;}
  public String objectTypeItem {get; set;}
  public String ErrorMsg {get; set;}
}
}
////////////////////////////////////////////////////////////////////////////////
//////////////////////// TEST METHODS /////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////