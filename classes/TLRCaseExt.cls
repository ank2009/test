/**
* @author       Anton Solovyev (anton_soloveyv@epam.com)
* @date         2013 June 28
* @description  This is controller extension class for Case object. Main purpose - add ability to delete document from external system.
*/
public class TLRCaseExt
{
    public final Case internalCase;
    private final string smpWatchListUrl;
    private final string smpWatchListDocumentName;
    public Boolean isDocDelButtonVislble { get { return !(string.isEmpty(documentNumber) || isDocumentDeleted); } }
    /**
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2013 June 28
    * @description  constructor
    * @param        ApexPages.StandardController stdController : controller to extend
    **/
    public TLRCaseExt(ApexPages.StandardController stdController)
    {
        Case myCase = (Case)stdController.getRecord();
        this.internalCase = [SELECT id, description, isDocumentDeleted__c,Teleroute_Number_Defaulter__c,Teleroute_Number_Complainer__c FROM Case WHERE id = :myCase.id];

        // in case of empty description
        if(internalCase.Description == null)
            documentNumber = '';
        else
            documentNumber = internalCase.Description.substringBetween('?id=', '&');
		
        // i don't want to get null values
        if(documentNumber == null) documentNumber='';
		system.debug('-----TLRCaseExt ctor: documentNumber: ' + documentNumber + ', isDocumentDeleted__c: ' + internalcase.isDocumentDeleted__c);
        // here are static URLs, maybe it makes sence to put them to custom settings later.
        smpWatchListUrl = 'https://dwh.teleroute.com/businessobjects/enterprise115/desktoplaunch/opendoc/openDocument.jsp';
        smpWatchListDocumentName = 'SMP_WatchList_CCM_V2_SFDC_2';
    }

    /**
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2013 June 28
    * @description  property to provide read-only access for Case.isDocumentDeleted__c to page
    * @returns      boolean
    **/
    public boolean isDocumentDeleted
    {
        get
        {
            return internalCase.isDocumentDeleted__c;
        }
    }

    /**
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2013 June 28
    * @description  property to provide read-only access for document number. Filled in constructor
    * @returns      document number in external system
    **/
    public string documentNumber { get; private set; }

    /**
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2013 June 28
    * @description  Function tries to delete document from TCD
    * @returns      document number in external system
    **/
    public PageReference deleteDoc()
    {
        if (documentNumber!=null && documentNumber!='')
        {
            // call to webservice
            Dom.XmlNode response = TcdStub.deleteDocumentFromTCD(Long.valueOf(documentNumber));
            // here we need extract our resounse
            string result = response.getText();
            system.debug('result is ------------'+result);
            // then we need update Case object to mark it's document as deleted
            internalCase.isDocumentDeleted__c = true;
            update internalCase;
            // adding chatter message to case
            FeedItem post = new FeedItem();
            post.ParentId = internalCase.Id;
            post.Body = 'Document number ' + documentNumber + ' was removed.';
            insert post;
        }
        // stay on the same page
        return null;
    }

    /**
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2013 June 28
    * @description  methods to display defaulter
    * @returns      PageReference points to external system
    **/
    public PageReference watchDefaulter()
    {
        string url = string.format('{0}?sDocName={1}&sRefresh=Y&lsSTelerouteNumber:={2}&sOutputFormat=P',
             new string[] {
                 smpWatchListUrl,
                 smpWatchListDocumentName,
                 internalCase.Teleroute_Number_Defaulter__c
             }
        );
        return new PageReference(url);
    }

    /**
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2013 June 28
    * @description  methods to display complainer
    * @returns      PageReference points to external system
    **/
    public PageReference watchComplainer()
    {
        string url = string.format('{0}?sDocName={1}&sRefresh=Y&lsSTelerouteNumber:={2}&sOutputFormat=P',
             new string[] {
                 smpWatchListUrl,
                 smpWatchListDocumentName,
                 internalCase.Teleroute_Number_Complainer__c
            }
        );
        return new PageReference(url);
    }

    /**
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2013 June 28
    * @description  class to throw exception fron within this class.
    *               I can't simple throw Exception, to i have to inherit this class
    **/
    public class docDelExtException extends Exception {}
}