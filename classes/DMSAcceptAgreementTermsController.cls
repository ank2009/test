public class DMSAcceptAgreementTermsController {

    private final static String DMS_CASE_TYPE_NAME = 'TLR_DMS_Case';
    private static Id TLR_DMS_Case_ID;
    private final static Map<Id, String> reacodTypeDevNameById = new Map<Id, String>();
    private static Boolean IS_TLR_DMS_Case_RT_DEFAULT = false;
    
    static{
        for(RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = :Schema.SObjectType.Case.Name]){
            reacodTypeDevNameById.put(rt.Id, rt.DeveloperName);
            if(rt.DeveloperName == DMS_CASE_TYPE_NAME){
                TLR_DMS_Case_ID = rt.Id;
            }
        }
        IS_TLR_DMS_Case_RT_DEFAULT = Schema.SObjectType.Case.getRecordTypeInfosById().get(TLR_DMS_Case_ID).isDefaultRecordTypeMapping();
    }
    
    public Case theCase             {get;private set;}
    public User currentUser         {get;private set;}
    private final String DefaultLanguage    = 'EN';
    private final String DocumentName = 'DEBT_MEDIATION_{0}';
    //private final String DocumentNamePattern = 'DEBT_MEDIATION';
    private Id currentAccount;
    public String ResourceURL       {get;set;}
    public String userLanguage  {get {return (String.IsNotBlank(currentUser.Contact.DMS_Agreement_Terms_Language__c) ) ? currentUser.Contact.DMS_Agreement_Terms_Language__c : DefaultLanguage;}}
    public Boolean acceptAgreement      {get;set;}
    public String ValidationMessage     {get;private set;}
    public String DocumentLoadingMessage        {get;private set;}
    public String CommunityName                 {get;private set;}

    public DMSAcceptAgreementTermsController(ApexPages.StandardController stdController) {
        if(!Test.isRunningTest()){
            stdController.addFields(new List<String>{'RecordTypeId'});
        }
        theCase = (Case)stdController.getRecord();
        if(isDMScaseType()){
            System.Debug('----------Constructor theCase=' + theCase);
            currentUser = getUserDetails(UserInfo.getUserId());  
            currentAccount = getUserAccount(currentUser.ContactId);   
            System.Debug('----------Constructor currentUser=' + currentUser);
 System.Debug('***** Constructor AccountId=' + currentAccount);
            CommunityName = getCommunityName();
            System.Debug('----------Constructor CommunityName =' + CommunityName );        
            ResourceURL = GetResourceURL(String.format(DocumentName, new List<String>{userLanguage}));
            System.Debug('----------Constructor ResourceURL=' + ResourceURL);
        }
    }

    private Boolean isDMScaseType(){
        return theCase.RecordTypeId != null ?
                reacodTypeDevNameById.get(theCase.RecordTypeId) == DMS_CASE_TYPE_NAME :
                IS_TLR_DMS_Case_RT_DEFAULT;
    }
    
    public PageReference checkRTandRedirect(){
        if(!isDMScaseType()){
            return getNewCasePR();
        }
        return null;
    }
    
    private PageReference getNewCasePR(){
        String resUrl = '/'+Case.sObjectType.getDescribe().getKeyPrefix()+'/e?nooverride=1&retURL=%2Fapex%2FCases_Tab'+(theCase.RecordTypeId != null ? '&RecordType='+theCase.RecordTypeId : '');
        if(!isDMScaseType())
        {
            resUrl = resUrl + (theCase.AccountId!=null ? '&def_account_id='+theCase.AccountId : '');
        }
        else
        {
            resUrl = resUrl + +'&def_account_id='+currentAccount;
        }
        return new PageReference(resUrl);
    }
    
    private String getCommunityName() {
        Network theNetwork = [SELECT id, name,UrlPathPrefix FROM Network Where Name = 'DMS'];
        System.Debug('----' + theNetwork);
        if (theNetwork != null) return theNetwork.UrlPathPrefix;
        else return '';
    }
    
    private User getUserDetails(Id userId) {
        User theUser = [SELECT Id, username, ContactId, Contact.DMS_Agreement_Terms_Language__c  FROM User WHERE Id = :userId LIMIT 1];
        return theUser;
    }
    
    private Id getUserAccount(Id userId) {
        id currId = [SELECT accountId FROM Contact WHERE Id = :userId LIMIT 1].AccountId;
        return currId;
    }
    
    private String GetResourceURL(String resourceName)  
    {  
        //Fetching the resource  
        List<StaticResource> resourceList = [SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name = :resourceName];  
                              
        //Checking if the result is returned or not  
        if(resourceList.size() == 1)  
        {  
           //Getting namespace  
           String namespace = resourceList[0].NamespacePrefix;  
           //Resource URL  
           return '/resource/' + resourceList[0].SystemModStamp.getTime() + '/' + (namespace != null && namespace != '' ? namespace + '__' : '') + resourceName;   
        }  
        else {
            DocumentLoadingMessage = Label.CNC_DocumentLoadingMessage;
            return null;  
        } 
    }  
    
    public PageReference Next() {
        if (acceptAgreement) {
            return getNewCasePR();
        }
        else {
            ValidationMessage = Label.CNC_ValidationMessage;
            return null;
        }
    }

    public PageReference Cancel() {
            PageReference pg = new PageReference('/apex/Cases_Tab');
            pg.setRedirect(true);
            return pg;      
    }

}