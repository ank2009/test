/**
* @author		Anton Solovyev (anton_soloveyv@epam.com)
* @date			2013 June 27
* @description	This class to test TLRCaseExt controller extension.
*				it implements WebService mock objectm used during deleteDocument call		
*/
@isTest
public class TLRCaseExtTestWSMock implements HttpCalloutMock {
	public HTTPResponse respond(HTTPRequest req)
	{
		// Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml');
        string body='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:wsdl="http://documents.teleroute.com/management/wsdl"';
        body += '><soapenv:Header/><soapenv:Body><wsdl:removeDocumentResponse/></soapenv:Body></soapenv:Envelope>';
        res.setBody(body);
        res.setStatusCode(200);
        return res;
	}
    
}