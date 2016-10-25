/** 
* @author       Anton Solovyev (anton_soloveyv@epam.com)
* @date         2015 September 22
* @description  Class server as proxy for outgoing calls to Jira
**/
public class JIRA_Proxy 
{
	/** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2015 September 22
    * @description  Performs HTTP get call to notify about changes.
    **/
    @future(callout = true)
    public static void NotifyCaseUpdated(Id caseID)
    {
        List<Case> cases = [SELECT Id, Subject, JIRA_Ticket__c FROM Case WHERE Id = :caseId];
        system.debug('---------- JIRA_Proxy: NotifyCaseUpdated: cases found: ' + cases);
        if(cases.size() < 1) return;					// we will not process wrong case IDs
        Case c = cases[0];
        if(string.isEmpty(c.JIRA_Ticket__c)) return;	// we will not process cases with no link to Jira

        string url = FXSettings__c.getValues('FXSettings').Jira_Servlet_URL__c + string.valueOf(caseID);
        system.debug('---------- JIRA_Proxy: NotifyCaseUpdated: endpoint url: ' + url);
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        
        Http h = new Http();
        h.send(req);
    }
}