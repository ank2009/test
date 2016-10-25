global with sharing class UserRepositoryParser {
	
	global class UserRepositoryStandardResponse
	{
		webservice public string Code = '';
		webservice public string Identifier = '';
		webservice public string Detail = '';
	}
	
	public static UserRepositoryStandardResponse parseStandardResult(Dom.XmlNode response) {
		Dom.XMLNode responseBody = response.getChildElement('Body','http://schemas.xmlsoap.org/soap/envelope/');
	    if( responseBody == null ){
	      throw new UserRepositoryParserException( 'Unable to locate body in response XML' );
	    }
	    
	    Dom.XMLNode serviceRequestResponse = responseBody.getChildElement('serviceRequestResponse','http://teleroute.com/userRepository');
	    if( serviceRequestResponse == null ){
	      throw new UserRepositoryParserException( 'Unable to locate serviceRequestResponse in response XML' );  
	    }
	    
	    Dom.XMLNode responseIdentifier = serviceRequestResponse.getChildElement('responseIdentifier','http://teleroute.com/userRepository');
	    if( responseIdentifier == null ){
	      throw new UserRepositoryParserException( 'Unable to locate responseIdentifier in response XML' );  
	    }
	    
	    List<Dom.XMLNode> nodeList = responseIdentifier.getChildElements();  
	    UserRepositoryStandardResponse ursr = new UserRepositoryStandardResponse();   
	    for( Dom.Xmlnode node : nodeList ){
	    	if (node.getName() == 'code') {
				ursr.Code = node.getText();
	    	}
	    	if (node.getName() == 'detail') {
				ursr.Detail = node.getText();
	    	}
	    	if (node.getName() == 'identifier') {
				ursr.Identifier = node.getText();
	    	}
	    }

		return ursr;
	}
	/** 
      Custom Exception class
	**/  
	public class UserRepositoryParserException extends Exception {
	
	}
}