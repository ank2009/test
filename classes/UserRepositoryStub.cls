public with sharing class UserRepositoryStub {	
	
	public static Dom.XmlNode addRight(String login,String right) {
    	String XML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:user="http://teleroute.com/userRepository">';
		XML += '<soapenv:Header/>';
		XML += '<soapenv:Body>';
		XML += '<user:serviceRequest>';
		XML += '<user:serviceListRequest type="add">';
		XML += '<login>' + login + '</login>';
		XML += '<serviceList>';
        XML += '<service>' + right + '</service>';
        XML += '</serviceList>';
        XML += '</user:serviceListRequest>';
        XML += '</user:serviceRequest>';
   		XML += '</soapenv:Body>';
		XML += '</soapenv:Envelope>';
  		Dom.Document document = doCallout(XML);
  		Dom.XMLNode response = document.getRootElement();
		return response;
  	}
  	
  	public static Dom.XmlNode removeRight(String login,String right) {
    	String XML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:user="http://teleroute.com/userRepository">';
		XML += '<soapenv:Header/>';
		XML += '<soapenv:Body>';
		XML += '<user:serviceRequest>';
		XML += '<user:serviceListRequest type="remove">';
		XML += '<login>' + login + '</login>';
		XML += '<serviceList>';
        XML += '<service>' + right + '</service>';
        XML += '</serviceList>';
        XML += '</user:serviceListRequest>';
        XML += '</user:serviceRequest>';
   		XML += '</soapenv:Body>';
		XML += '</soapenv:Envelope>';
  		Dom.Document document = doCallout(XML);
  		Dom.XMLNode response = document.getRootElement();
		return response;
  	}
	
  	/**
  	This method does the actual webservice callout
  	**/
  	private static Dom.Document doCallout(String XML){
    	try{
      		HttpResponse resp = SoapHttp.sendSOAPRequest(XML, FXSettings__c.getValues('FXSettings').User_Repository_ESB_WSDL__c, 10000);
      		if( resp.getStatusCode() == 200 ) {
        		Dom.Document outDom = resp.getBodyDocument();
        		return outDom;
      		} else {
        		throw new UserRepositoryStubException( 'Invalid response, code:' + resp.getStatusCode() );
      		}
    	} catch( UserRepositoryStubException e ){
      		throw new UserRepositoryStubException( 'Webservice callOutException Occured' + e.getMessage() );  
    	}
    	return null;
  	}
  	
  	/** 
    Custom Exception class
	**/  
	public class UserRepositoryStubException extends Exception {
	}
}