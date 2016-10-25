/**
* @author       Andrei Lobkis (andrei_lobkis@epam.com)
* @date         2016 April 12
* @description  Schedulable Batch process for checking National_Key_Account__c and International_Key_Account__c in hierarchy
**/
global class CheckKeyAccountsForHierarchyBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful
{
    global final string query = 'select Id, Name, Top_Parent_ID__c, AccountNumber, Parent.Id, Parent.Name, National_Key_Account__c, International_Key_Account__c from Account where Parent.Id != null or (International_Key_Account__c = true or National_Key_Account__c = true) ';  
    private static List<string> addresses = new List<string>{'luca.filippetto@wolterskluwer.com', 'mabel.pareja@wolterskluwer.com', 'anna.laska@wolterskluwer.com','loubna.zouiten@wolterskluwer.com'};
    global  Map<Id,AccHierarchy> accHierMap = new Map<Id, AccHierarchy>();
    global  Set<Account> AllAccountsSet = new Set<Account>();
    @TestVisible static Map<Id,AccHierarchy> accHierMapForTest;
    
    public class AccHierarchy
    {
        public AccHierarchy()
        {
            children = new Set<Account>();
        }
        public AccHierarchy(Account topParent)
        {
            this.topParent = topParent;
            children = new Set<Account>();
        }
        public Account topParent{ get; set; }
        public Set<Account> children{ get; set; }
    }
    
    public CheckKeyAccountsForHierarchyBatch()
    {
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return DataBase.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope)
    {   
        AllAccountsSet.addAll(scope);   
    }
    
    global void finish(Database.BatchableContext BC)
    {
        boolean nkaIncorrect;
        boolean ikaIncorrect;       
        Map<Id,Account> accMap = new Map<Id, Account>();
        Set<Id> hasChildren = new Set<Id>();
		
        for(Account acc : AllAccountsSet)
        {
            hasChildren.add(acc.ParentId);
        }
        for(Account accForCheck : AllAccountsSet)
        {
            if(!hasChildren.contains(accForCheck.Id) && accForCheck.ParentId == null)
            {
                AllAccountsSet.remove(accForCheck);
            }
        }
        
        for(Account acc : AllAccountsSet)
        {
            if(acc.ParentId == null)
            {
                accHierMap.put(acc.Id, new AccHierarchy(acc));
                AllAccountsSet.remove(acc);
            }
        }
        for(Account acc : AllAccountsSet)
        {
            AccHierarchy CurrHier = accHierMap.get(acc.Top_Parent_ID__c);
            if(CurrHier != null && ((CurrHier.topParent.International_Key_Account__c && !acc.International_Key_Account__c)
                                ||(CurrHier.topParent.National_Key_Account__c && !acc.National_Key_Account__c)))
            CurrHier.children.add(acc);
        }
        
        for(AccHierarchy hier : accHierMap.values())
        {
            if(hier.children.size() == 0)
            {
                accHierMap.remove(hier.topParent.Id);
            }
        }
        
        if(accHierMap.size() > 0)
        {
            TLR_SendEmailHelper.SendEmailWithHtmlBodyNoReply(BuildHTMLBody(accHierMap.values()), null, 'NKA/IKA check for Account hierarchies', addresses);
            accHierMapForTest = accHierMap;
        }
    }
    
    global void execute(SchedulableContext sc)
    {
        CheckKeyAccountsForHierarchyBatch batch = new CheckKeyAccountsForHierarchyBatch();
        Database.executeBatch(batch);
    } 
    
    private static string BuildHTMLBody(List<AccHierarchy> hierarchies)
    {
        string htmlbody;
        Account acc;
        integer topParentsNumber = hierarchies.size();
        string styles = 'body{font-family: calibri;}table{border-collapse: collapse; width: 100%;}td,th{border: 1px solid black; text-align: center;}.tableWrapper{margin-bottom: 50px;}';
        htmlbody = '<html><style type="text/css">' + styles + '</style><body>';
        htmlBody += '<div style = "margin-bottom:30px; font: 15px;"><span style = "background-color: palegoldenrod">Top parent Accounts are colored</span></div>';
        htmlbody += '<table>';
        htmlbody += '<tr><th width=25%>Account</th><th width=25%>Account Number</th><th width=25%>International Key Account</th><th width=25%>National Key Account</th></tr>';
        integer hierNum = 0;
        for(AccHierarchy hierarchy : hierarchies)
        {
            hierNum++;
            acc = hierarchy.topParent;
            
            htmlbody += '<tr bgcolor="palegoldenrod"><td><a href=' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + acc.Id + '>' + acc.Name + '</a></td><td>' + acc.AccountNumber+'</td><td>' + acc.International_Key_Account__c + '</td><td>' + acc.National_Key_Account__c + '</td></tr>';
            
            for(Account child : hierarchy.children)
            {
                htmlbody += '<tr><td><a href=' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + child.Id+'>' + child.Name+'</a></td><td>' + child.AccountNumber+'</td><td>' + child.International_Key_Account__c + '</td><td>' + child.National_Key_Account__c + '</td></tr>';
            }
            if(hierNum != topParentsNumber)
                htmlbody += '<tr><td></td><td></td><td></td><td></td></tr>';
        }
        htmlbody += '</table>';
        htmlbody += ('</body></html>');     
        return htmlbody;
    }
}