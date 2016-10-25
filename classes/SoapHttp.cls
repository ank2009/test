/**
    SoapHttp Class
    Written by: Ronnie Visser <r.visser@vivens.com>
    Date: 2011-08-15
    Company: Vivens CRM
	--------------------------------------------------------------------------------------
		 This class contains methods to call a SOAP service using Http classes.
	--------------------------------------------------------------------------------------
**/
public class SoapHttp
{
	// for compatibility
	public static HttpResponse sendSOAPRequest(String body, String endPoint, Integer timeOut)
	{
		return sendSOAPRequest(body, endPoint, timeOut, FXSettings__c.getValues('FXSettings').Proxy_ESB_Certificate__c);
	}
	
	// Send SOAP request over HTTP
	// this function will attach certificate in case certificateName is not empty or null
	public static HttpResponse sendSOAPRequest(String body, String endPoint, Integer timeOut, String certificateName)
	{
		HTTP http = new HTTP();
		HttpRequest request = new HttpRequest();
		request.setEndpoint(endPoint);
		request.setMethod('POST');
		request.setTimeout(timeOut);
		request.setHeader('Content-Type' , 'text/xml; charset=utf-8');
		
		if(!string.isEmpty(certificateName))
		{
			request.setClientCertificateName(certificateName);
			system.debug('------- SoapHttp.sendSOAPRequest: certificate is nt empty: ' + certificateName);
		}
		else
		{
			system.debug('------- SoapHttp.sendSOAPRequest: certificate is empty: ' + certificateName);
		}
		
		request.setBody(body);
		system.debug('------- SoapHttp.sendSOAPRequest: request body: ' + body);
		HttpResponse response = http.send(request);
		system.debug('------- SoapHttp.sendSOAPRequest: response: ' + response.getBody());
		return response;
	} // sendSOAPRequest
}