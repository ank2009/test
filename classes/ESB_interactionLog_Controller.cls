/**
* @author       Aleh Tsilko (aleh_tsilko@epam.com)
* @date         2015 January 05
* @description  Controller for ESB Interaction Logs page in AdminApp custom application
**/
public with sharing class ESB_interactionLog_Controller{

    private ESB_Interaction_Logs__c esb_log;

    public ESB_interactionLog_Controller(ApexPages.StandardController controller) {
        ID logId = System.currentPagereference().getParameters().get('id');
        this.esb_log = [SELECT Id,
                               Body__c,
                               Message_direction__c,
                               Remote_response__c 
                         FROM ESB_Interaction_Logs__c 
                        WHERE Id = :logId][0];
    }

    public void reSendESBLog()
    {
        if(esb_log.Message_direction__c == 'Outgoing')
        {
            FXSettings__c settings = FXSettings__c.getValues('FXSettings');
            HttpResponse response;
            try
            {
                response = SoapHttp.sendSOAPRequest(esb_log.Body__c, settings.ESB_Url__c, 10000, settings.ESB_Certificate_name__c);
                esb_log.ESB_response_status__c = response.getStatusCode();
                esb_log.ESB_response__c = response.getBody();
                esb_log.Remote_response__c  = '';
            }
            catch(System.CalloutException ex)
            {
                esb_log.ESB_response_status__c = -1;               
                esb_log.ESB_response__c = ex.getMessage();               
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'ESB Log is NOT resend, Error:'+esb_log.ESB_response__c));
            }
            if(esb_log.ESB_response_status__c != -1)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'ESB Log re-send complete'));
                upsert esb_log;
			}
		}
        else
        {
        	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Sorry, You can do Re-Send only for Outgoing Messages!'));
		}
    }
                              
                              
    public PageReference Exit()
    {
        return Utilities.Redirect(this.esb_log.Id);
    }                              
}