/** 
* @author       Anton Solovyev (anton_soloveyv@epam.com)
* @date         2015 September 24
* @description  class containing HTTPMockup
**/
@isTest
public class TST_GenericHttpCalloutMock implements HttpCalloutMock 
{
    private integer responseCode;
    
    public boolean callWasPerformed;
    
    public TST_GenericHttpCalloutMock() 
    { 
        this(200);
    }
    
    public TST_GenericHttpCalloutMock(integer desiredResponseCode)
    {
        callWasPerformed = false;
        responseCode = desiredResponseCode;
    }
    
    public HTTPResponse respond(HTTPRequest req) 
    {
        Httpresponse resp = new Httpresponse();
        resp.SetStatusCode(responseCode);
        callWasPerformed = true;
        return resp;
    }
}