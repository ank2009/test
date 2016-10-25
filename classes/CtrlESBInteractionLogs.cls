/** 
* @author       Andrei Lobkis (andrei_lobkis@epam.com)
* @date         2016 march 23
* @description  Extension controller for ESBInteractionLogs page.
				Test coverage is provided by ESB_ProxyTest
*/
global class CtrlESBInteractionLogs 
{
    private static ESB_Interaction_Logs__c log;
    private  Id recordId;
    private static string messageBody;
    global class ESB_Parameter
    {
        public string ParName{get;set;}
        public string ParValue{get;set;}
        public List<ESB_Parameter> InnerPars{get;set;}
    }
    
    global static string responseKey{get;set;}
    
    global static string responseContent{get;set;}
    
    global static string dataType{get;set;}
    
    global static List<ESB_Parameter> ESB_Parameters{get;set;}   
    
    private boolean error = false;
    
    public CtrlESBInteractionLogs(ApexPages.StandardController controller)
    {   
        try
        {  
            recordId = controller.getId();
            log=[select Id, Message_direction__c, Message_type__c, Body__c, Remote_response__c, ESB_response_status__c from ESB_Interaction_Logs__c where Id =:  recordId];
            ESB_Parameters = new List<ESB_Parameter>();
            ParseRemoteResponse();
            GetDataType(log.Message_type__c);
        }
        catch(Exception e)
        {
            error = true;
        }
        
    }
        
    public   PageReference checkForRedirect()
    {
        if(log == null || log.Message_direction__c != 'Outgoing' || error == true)
        {            
			return redir();           
        }
        if(log.ESB_response_status__c != 200 && ApexPages.currentPage().getParameters().get('show') != '1')
        {
            return redir();
        }
        return null;
    }
    
    public   PageReference redir()
    {     
        PageReference newPage = new PageReference('/'+recordId+'?nooverride=1');
        return newPage.setRedirect(true);  
    }
    
    public   PageReference resend()
    {     
        PageReference newPage = new PageReference('/apex/ESB_Interaction_Log?id='+recordId);
        return newPage.setRedirect(true);  
    }
    
    
    
    private static void init(Id LogId)
    {
        log=[select Id, Message_type__c, Body__c from ESB_Interaction_Logs__c where Id =:  LogId];
        ESB_Parameters = new List<ESB_Parameter>();
        messageBody = log.Body__c;
        GetDataType(log.Message_type__c);
        ESB_Parameters = ParseOutgoing(ESB_Parameters);
    }
    
    
   
    
    private static List<ESB_Parameter> ParseOutgoing(List<ESB_Parameter> data)
    {		
        messageBody = messageBody.remove(']]>');
        messageBody = messageBody.remove('<![CDATA[');
        Dom.Document doc = new Dom.Document();
        
        doc.load(messageBody);
        Dom.XmlNode rootNode = doc.getRootElement();
        Dom.XmlNode body1 = GetChildNodeByName(rootNode, 'Body');
        Dom.XmlNode message = GetChildNodeByName(body1, 'message');
        Dom.XmlNode body2 = GetChildNodeByName(message, 'Body');
        Dom.XmlNode usercompany = GetChildNodeByName(body2, 'user');
        if(usercompany == null)
        {
            usercompany = GetChildNodeByName(body2, 'company');
        }
        dataType = usercompany.getName();  
        
        data = parseValuableNodes(data, usercompany, dataType);        
        return data;
    }
    
    private static List<ESB_Parameter> parseValuableNodes(List<ESB_Parameter> data, Dom.XmlNode parentNode, string localDataType)
    {
        Dom.XmlNode[] childrenNodes = parentNode.getChildren();
        for(integer i=0; i<childrenNodes.size(); i++)
        {
            if(childrenNodes[i].getName() == 'businessId')
            {
                TakeValueFromChild(childrenNodes[i],'Id', data);
                continue;
            }
            if(childrenNodes[i].getName() == 'phone')
            {
                TakeValueAndChildren(childrenNodes[i], data);
                continue;
            }
            if(childrenNodes[i].getName() == 'fax')
            {
                TakeValueAndChildren(childrenNodes[i], data);
                continue;
            }
            if(localDataType == 'company')
            {
                if(childrenNodes[i].getName() == 'operationalParentCompanyBusinessAccount')
                {
                    TakeValueFromChild(childrenNodes[i],'Id', data);
                    continue;
                }
                if(childrenNodes[i].getName() == 'parentCompanyBusinessAccount')
                {
                    TakeValueFromChild(childrenNodes[i],'Id', data);
                    continue;
                }
                if(childrenNodes[i].getName() == 'productsAccesses')
                {
                    TakeValueAndChildren(childrenNodes[i], data);
                    continue;
                }
                if(childrenNodes[i].getName() == 'users')
                {
                    addParameterToList(childrenNodes[i].getName(), childrenNodes[i].getText(), data);
                    ESB_Parameter lastvalue = data[data.size()-1];
                    lastvalue.InnerPars = new List<ESB_Parameter>();
                    Dom.XmlNode[] userschildren = childrenNodes[i].getChildren();
                    for(integer j=0; j<userschildren.size(); j++)
                    {
                       if(userschildren[j].getName() == 'user')
                        {
                            Dom.XmlNode[] userchildren = userschildren[j].getChildren();
                            lastvalue.InnerPars = parseValuableNodes(lastvalue.InnerPars, userschildren[j], 'user');
                        }
                    }
                    continue;
                }
                if(childrenNodes[i].getName() == 'addresses')
                {
                    addParameterToList(childrenNodes[i].getName(), childrenNodes[i].getText(), data);
                    ESB_Parameter lastvalue = data[data.size()-1];
                    lastvalue.InnerPars = new List<ESB_Parameter>();
                    
                    Dom.XmlNode[] addressesChildren = childrenNodes[i].getChildren();
                    if(addressesChildren.size() != 0)
                    {
                        List<ESB_Parameter> Address_Parameter = new List<ESB_Parameter>();
                        for(integer j=0; j<addressesChildren.size(); j++)
                        {
                            if(addressesChildren[j].getName() == 'address')
                            {
                                addParameterToList(addressesChildren[j].getName(), addressesChildren[j].getText(), lastvalue.InnerPars);
                                ESB_Parameter lastaddress = lastvalue.InnerPars[lastvalue.InnerPars.size()-1];
                                lastaddress.InnerPars = new List<ESB_Parameter>();
                                Dom.XmlNode[] addressChildren = addressesChildren[j].getChildren();
                                for(integer k=0; k<addressChildren.size(); k++)
                                {
                                    if(addressChildren[k].getName() == 'locationTypes')
                                    {
                                        TakeValueFromChild(addressChildren[k],'addressLocationType', lastaddress.InnerPars);
                                    }
                                    else if(addressChildren[k].getName() == 'businessId')
                                    {
                                        TakeValueFromChild(addressChildren[k],'Id', lastaddress.InnerPars);
                                    }
                                    else
                                        addParameterToList(addressChildren[k].getName(), addressChildren[k].getText(), lastaddress.InnerPars);    
                                }
                            }
                        }
                    }
                    continue;
                } 
            }
            else if(localDataType == 'user')
            {
                if(childrenNodes[i].getName() == 'companyBusinessAccount')
                {
                    TakeValueFromChild(childrenNodes[i],'Id', data);
                    continue;
                }
                if(childrenNodes[i].getName() == 'mobile')
                {
                    TakeValueAndChildren(childrenNodes[i], data);
                    continue;
                }
                if(childrenNodes[i].getName() == 'userTitle')
                {
                    TakeValueFromChild(childrenNodes[i],'value', data);
                    continue;
                }
            }
            addParameterToList(childrenNodes[i].getName(), childrenNodes[i].getText(), data);
        }
        return data;
    }
    
    private static Dom.XmlNode GetChildNodeByName(Dom.XmlNode node, string childName)
    {
        Dom.XmlNode[] rootNodeChildren = node.getChildren();
        Dom.XmlNode childNode;
        for(integer i=0; i<rootNodeChildren.size(); i++)
        {
            if(rootNodeChildren[i].getName() == childName)
            {
                childNode = rootNodeChildren[i];
            }
        }
        return childNode;
    }
    
    private static void TakeValueFromChild(Dom.XmlNode node, string childName, List<ESB_Parameter>  parList)
    {
        Dom.XmlNode[] children = node.getChildren();
        for(integer j=0; j<children.size(); j++)
        {
            if(children[j].getName() == childName)
                addParameterToList(node.getName(), children[j].getText(),parList);  
            continue;
        }
    }
    
    private static void TakeValueAndChildren(Dom.XmlNode node, List<ESB_Parameter> parList)
    {
        addParameterToList(node.getName(), node.getText(), parList);
        ESB_Parameter lastvalue = parList[parList.size()-1];
        lastvalue.InnerPars = new List<ESB_Parameter>();
        Dom.XmlNode[] children = node.getChildren();
        for(integer j=0; j<children.size(); j++)
        {
            addParameterToList(children[j].getName(), children[j].getText(),lastvalue.InnerPars);         
        }
    }
    
    private static void ParseRemoteResponse()
    {
        string response = log.Remote_response__c;
        if(response == null)
        {
            responseContent = null;
            responseKey = null;
        }
        else
        {
            responseContent = response.substringAfter('[content=').substringBefore(', key=');
            responseKey = response.substringAfter(', key=').substringBefore(']');
        }
    }
    
    @RemoteAction
    global static List<ESB_Parameter> GetBodyParameters(string LogId)
    {
        init(LogId);
        return ESB_Parameters;
    }
    
    private static void addParameterToList(string parName, string parValue, List<ESB_Parameter>  parList)
    {
        ESB_Parameter par = new ESB_Parameter();
        par.ParName = parName;
        par.ParValue = parValue;
        parList.add(par);
    }
    
    public static void GetDataType(string messageType)
    {
        if(messageType.contains('user'))
        {
            dataType = 'user';
        }
        else if(messageType.contains('company'))
        {
            dataType = 'company';
        }
    }
    
    public static string getLogId()
    {
        return log.Id;
    }
}