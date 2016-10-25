global class UpdateESBInteractionLogsBatch implements Database.batchable<Sobject> 
{

    private class batchException extends Exception {}
    global final string query = 'Select ID, Account__c, Contact__c, Message_type__c, Body__c, Message_direction__c from ESB_Interaction_Logs__c where Account__c = null and Contact__c = null';
    
    private List<ESB_Interaction_Logs__c> companiesToUpdate = new List<ESB_Interaction_Logs__c>();
    private List<ESB_Interaction_Logs__c> usersToUpdate = new List<ESB_Interaction_Logs__c>();
    
    
    global Enum LogType
    {
        user,
        company
	}
    
    global UpdateESBInteractionLogsBatch()
    {
    
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
       	return DataBase.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<ESB_Interaction_Logs__c> scope) 
    { 
        List<string> businessIds = new List<string>();
        List<string> incomingBusinessIds;
        
        List<string> logins = new List<string>();
        Id accountId;
        Id contactId;
        for(integer i=0;i< scope.size();i++)
        {
            if(FindLogType(scope[i]) == LogType.user)
            {
                
                if(scope[i].Message_direction__c == 'Outgoing')
                {
                    string login =findLogin(scope[i]);
                    businessIds.add(findBusinessIdForOutgoing(scope[i]));
                    
                    if(string.isNotEmpty(login))
                    logins.add(login);
                }
                else if(scope[i].Message_direction__c == 'Incoming')
                {
                    businessIds = findBusinessIdsForIncoming(scope[i]);
                }
                
                if(businessIds.size() != 0)
                {
                    scope[i].Contact__c = getContactIdByBusinessId(businessIds);
                    if(scope[i].Contact__c == null)
                        scope[i].Contact__c = getContactIdByLogin(logins);
                    usersToUpdate.add(scope[i]);
                    businessIds = new List<string>();
                    logins = new List<string>();
                }
                    

            }
            else
                if(FindLogType(scope[i]) == LogType.company)
            {
                if(scope[i].Message_direction__c == 'Outgoing')
                {
                    businessIds.add(findBusinessIdForOutgoing(scope[i]));
                }
                else
                if(scope[i].Message_direction__c == 'Incoming')
                {
                    businessIds = findBusinessIdsForIncoming(scope[i]);
                }
                if(businessIds.size() != 0)
                {
                    scope[i].Account__c = getAccountId(businessIds);
                    companiesToUpdate.add(scope[i]);
                    businessIds = new List<string>();
                    logins = new List<string>();
                }
            }
        }
        if(companiesToUpdate.size()>0)
        update companiesToUpdate;
        if(usersToUpdate.size()>0)
        update usersToUpdate;
    }

    private Id getAccountId(List<string> businessIds)
    {
        List<Account> acc = [select Id from Account where AccountNumber =: businessIds];
        if(acc.size() > 0)
        {
            return acc[0].Id;
        }
        return null;
    }

    private Id getContactIdByLogin(List<string> logins)
    {
        
        List<Contact> c = [select Id from Contact where Username__c =: logins];
        if(c.size() > 0)
        {
            return c[0].Id;
        }
        return null;
    }
    
    private Id getContactIdByBusinessId(List<string> businessId)
    {
        List<Contact> c = [select Id from Contact where ESB_BuisnessID__c =: businessId];
        if(c.size() > 0)
        {
            return c[0].Id;
        }
        return null;
    }
    
    
    
   	private List<string> findBusinessIdsForIncoming(ESB_Interaction_Logs__c log)
    {
        string body = log.Body__c;
        List<string> businessIds = new List<string>();
        while(body.contains('businessId=businessIdentifier:[id='))
        {
            body = body.substringAfter('businessId=businessIdentifier:[id=');
            businessIds.add(body.substringBefore(']'));
        }
        
        return businessIds;
    }
    
    
    
    private Dom.XmlNode getValuableXMLNode(ESB_Interaction_Logs__c log)
    {
        string messageBody = log.Body__c;
        string businessId;
        
        messageBody = messageBody.remove(']]>');
        messageBody = messageBody.remove('<![CDATA[');
        Dom.Document doc = new Dom.Document();
        
        doc.load(messageBody);
        Dom.XmlNode rootNode = doc.getRootElement();
        Dom.XmlNode[] rootNodeChildren = rootNode.getChildren();
        Dom.XmlNode body1;
        for(integer i=0; i<rootNodeChildren.size(); i++)
        {
            if(rootNodeChildren[i].getName() == 'Body')
            {
                body1 = rootNodeChildren[i];
            }
        }
        Dom.XmlNode[] body1Children = body1.getChildren();
        Dom.XmlNode message;
        for(integer i=0; i<body1Children.size(); i++)
        {
            if(body1Children[i].getName() == 'message')
            {
                message = body1Children[i];
            }
        }
        Dom.XmlNode[] messageChildren = message.getChildren();
        Dom.XmlNode body2;
        for(integer i=0; i<messageChildren.size(); i++)
        {
            if(messageChildren[i].getName() == 'Body')
            {
                body2 = messageChildren[i];
            }
        }
        Dom.XmlNode[] body2Children = body2.getChildren();
        Dom.XmlNode usercompany;
        for(integer i=0; i<body2Children.size(); i++)
        {
            if(body2Children[i].getName() == 'user' || body2Children[i].getName() == 'company')
            {
                usercompany = body2Children[i];
            }
        }
        
        return usercompany;
    }
    
    
    private string findBusinessIdForOutgoing(ESB_Interaction_Logs__c log)
    {
        string businessId;
        Dom.XmlNode[] childrenNodes = getValuableXMLNode(log).getChildren();
        for(integer i=0; i<childrenNodes.size(); i++)
        {
            if(childrenNodes[i].getName() == 'businessId')
            {
                Dom.XmlNode[] children = childrenNodes[i].getChildren();
                for(integer j=0; j<children.size(); j++)
                {
                    if(children[j].getName() == 'Id')
                          businessId = children[j].getText();
                }
                continue;
            }
            
        }
        return businessId;
    }
    
    private string findLogin(ESB_Interaction_Logs__c log)
    {
        string login;
        Dom.XmlNode[] childrenNodes = getValuableXMLNode(log).getChildren();
        
        
        for(integer i=0; i<childrenNodes.size(); i++)
        {
            if(childrenNodes[i].getName() == 'login')
            {
                login = childrenNodes[i].getText();
            }
            
        }
        
        
        return login;
    }
    
    
    
    private LogType FindLogType(ESB_Interaction_Logs__c log)
    {
        if(log.Message_type__c.containsIgnoreCase('user'))
        {
            return LogType.user;
        }
        else
            if(log.Message_type__c.containsIgnoreCase('company'))
        {
            return LogType.company;
        }
        return null;
    }
    
   /* private void UpdateAccounts(ESB_Interaction_Logs__c log, Id accounyId)
    {
        
        log.Account__c = accounyId;
        update log;
    }
    private void UpdateContacts(ESB_Interaction_Logs__c log, Id contactId)
    {
        
        log.Contact__c = contactId;
        update log;
    }*/
    
    
    
    
    global void finish(Database.BatchableContext BC)
    {
        
    }
    
    
    
}