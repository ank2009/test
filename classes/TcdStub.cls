/**
    TcdStub Class
    Written by: Ronald Klaassen <r.klaassen@vivens.com>
	Corrected and updated by: François Dubois
    Date: 2011-09-15
    Company: Vivens CRM

    This class assembles the soap xml string and returns the response xml
*/
public class TcdStub 
{
	//=========================================================================================
	// Code of conduct
	//=========================================================================================
	public static Dom.XmlNode getCodeOfConductXml(String companyId)
	{
		String XML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tel="http://teleroute.com/telerouteCompanyDirectory">';
		XML += '<soapenv:Header/>';
		XML += '<soapenv:Body>';
		XML +=   '<tel:getTCDCodeOfConduct>';
		XML +=     '<tel:getCodeOfConduct>';
		XML +=       '<companyId>' + companyId + '</companyId>';
		XML +=     '</tel:getCodeOfConduct>';
		XML +=   '</tel:getTCDCodeOfConduct>';
		XML += '</soapenv:Body>';
		XML += '</soapenv:Envelope>';
		Dom.Document document = doCallout(XML);
		Dom.XMLNode response = document.getRootElement();
		return response;
	} //getCodeOfConductXml

	public static Dom.XmlNode updateCodeOfConductXml(TcdCoC codeOfConduct)
	{
		String XML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tel="http://teleroute.com/telerouteCompanyDirectory">';
		XML += '<soapenv:Header/>';
		XML += '<soapenv:Body>';
		XML +=   '<tel:updateTCDCoc>';
		XML +=     '<tel:updateCoc>';
		XML +=       '<companyId>' + codeOfConduct.CompanyId + '</companyId>';
		XML +=       '<updaterName>' + Userinfo.getName() + '</updaterName>';
		XML +=     '</tel:updateCoc>';
		XML +=   '</tel:updateTCDCoc>';
		XML += '</soapenv:Body>';
		XML += '</soapenv:Envelope>';
		Dom.Document document = doCallout(XML);
		Dom.XMLNode response = document.getRootElement();
		return response;
	} //updateCodeOfConductXml
	
	//=========================================================================================
	// Activities
	//=========================================================================================
	public static Dom.XmlNode getActivitiesXml(String companyId) 
	{
		String XML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tel="http://teleroute.com/telerouteCompanyDirectory">';
		XML += '<soapenv:Header/>';
		XML += '<soapenv:Body>';
		XML +=   '<tel:getTCDActivity>';
		XML +=     '<getActivity>';
		XML +=       '<companyId>' + companyId + '</companyId>';
		XML +=     '</getActivity>';
		XML +=   '</tel:getTCDActivity>';
		XML += '</soapenv:Body>';
		XML += '</soapenv:Envelope>';
		Dom.Document document = doCallout(XML);
		Dom.XMLNode response = document.getRootElement();
		return response;
	}
	public static Dom.XmlNode updateActivitiesXml(TcdActivity activity)
	{
		system.debug('## >>> updateActivitiesXml : ' + activity);
		String XML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tel="http://teleroute.com/telerouteCompanyDirectory">';
		XML += '<soapenv:Header/>';
		XML += '<soapenv:Body>';
		XML += '<tel:updateTCDActivity>';
		XML += '<tel:updateActivity>';
		XML += '<companyId>' + activity.companyIdentifier.companyId + '</companyId>';
		XML += '<activity>';
		XML += '<numberOfTruck>' + activity.numberOfTruck + '</numberOfTruck>';
		//specializationCodes
		//List<Specialization_Code__c> specCodes=[select Label__c from Specialization_Code__c where Name in :activity.specializationCodes];
		if(activity.specializationCodes.size()>0)
		{
			XML += '<specializationCodes>';
			for(String specialization : activity.specializationCodes)
			{
				XML += '<specializationCode>'+specialization+'</specializationCode>';
			}
			XML += '</specializationCodes>';
		}
		XML += '<specializationComments>' + activity.specializationComments + '</specializationComments>';
		//regularRoutes
		if(activity.regularRoutes.size() > 0)
		{
			XML += '<regularRoutes>';
			for(TcdActivity.RegularRoute regRoute : activity.regularRoutes.values())
			{
				XML += '<regularRoute>';
				XML += '<departure>';
				if(Generic.StringNotEmpty(regRoute.departure.countryCode))
					XML += '<country>' + regRoute.departure.countryCode + '</country>';
				if(Generic.StringNotEmpty(regRoute.departure.region))
					XML += '<region>' + regRoute.departure.region + '</region>';
				if(Generic.StringNotEmpty(regRoute.departure.city))
					XML += '<city>' + regRoute.departure.city + '</city>';
				if(Generic.StringNotEmpty(regRoute.departure.coordX))
					XML += '<coordX>' + regRoute.departure.coordX + '</coordX>';
				else
					XML += '<coordX>0</coordX>';
				if(Generic.StringNotEmpty(regRoute.departure.coordY))
					XML += '<coordY>' + regRoute.departure.coordY + '</coordY>';
				else
					XML += '<coordY>0</coordY>';
				//XML += '<cityId>'+regRoute.departure.+'</cityId>';
				XML += '</departure>';
				XML += '<arrival>';
				if(Generic.StringNotEmpty(regRoute.arrival.countryCode))
					XML += '<country>' + regRoute.arrival.countryCode + '</country>';
				if(Generic.StringNotEmpty(regRoute.arrival.region))
					XML += '<region>' + regRoute.arrival.region + '</region>';
				if(Generic.StringNotEmpty(regRoute.arrival.city))
					XML += '<city>' + regRoute.arrival.city + '</city>';
				if(Generic.StringNotEmpty(regRoute.arrival.coordX))
					XML += '<coordX>' + regRoute.arrival.coordX + '</coordX>';
				else
					XML += '<coordX>0</coordX>';
				if(Generic.StringNotEmpty(regRoute.arrival.coordY))
					XML += '<coordY>' + regRoute.arrival.coordY + '</coordY>';
				else
					XML += '<coordY>0</coordY>';
				//XML += '<cityId>'++'</cityId>';
				XML += '</arrival>';
				XML += '<!--Zero or more repetitions:-->';
				for(string day : regRoute.days)
				{
					XML += '<days>' + day + '</days>';
				}
				XML += '</regularRoute>';
			} // for all regular routes
			XML += '</regularRoutes>';
		} // if reular routes
		if(activity.countryMap.size()>0)
		{
			XML += '<countries>';
			for(TcdActivity.Country country : activity.countryMap.values())
			{
				XML += '<country>';
				XML += '<countryCode>' + country.countryCode + '</countryCode>';
				/*if(country.regions.size()>0)
				{
					XML += '<regions>'+country.regions+'</regions>';
				} */
				system.debug('## >>> Regions : '+country.regions);
				if(country.regions.size()>0)
				{
					for(string region : country.regions)
					{
						XML += '<regions>' + region + '</regions>';
					}
				}
				XML += '</country>';
			} // for all countries
			XML += '</countries>';
		} // if countrymap not empty
		XML += '<nbWarehouse>' + activity.nbWarehouse + '</nbWarehouse>';
		XML += '</activity>';
		XML += '<updaterName>' + Userinfo.getName() + '</updaterName>';
		XML += '</tel:updateActivity>';
		XML += '</tel:updateTCDActivity>';
		XML += '</soapenv:Body>';
		XML += '</soapenv:Envelope>';
		Dom.Document document = doCallout(XML);
		Dom.XMLNode response = document.getRootElement();
		return response;
	} //updateActivitiesXml
	
	public static Dom.XmlNode updateRegularRoutesXml(TcdActivity activity)
	{
		system.debug('## >>> updateActivitiesXml : '+activity);
		String XML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tel="http://teleroute.com/telerouteCompanyDirectory">';
		XML += '<soapenv:Header/>';
		XML += '<soapenv:Body>';
		XML += '<tel:updateTCDActivity>';
		XML += '<tel:updateActivity>';
		XML += '<companyId>' + activity.companyIdentifier.companyId + '</companyId>';
		XML += '<activity>';
		//regularRoutes
		if(activity.regularRoutes.size()>0)
		{
			XML += '<regularRoutes>';
			for(TcdActivity.RegularRoute regRoute : activity.regularRoutes.values())
			{
				XML += '<regularRoute>';
				XML += '<departure>';
				XML += '<country>' + regRoute.departure.country + '</country>';
				XML += '<region>' + regRoute.departure.region + '</region>';
				XML += '<city>' + regRoute.departure.city + '</city>';
				if(Generic.StringNotEmpty(regRoute.departure.coordX))
					XML += '<coordX>' + regRoute.departure.coordX + '</coordX>';
				else
					XML += '<coordX>0</coordX>';
				if(Generic.StringNotEmpty(regRoute.departure.coordY))
					XML += '<coordY>' + regRoute.departure.coordY + '</coordY>';
				else
					XML += '<coordY>0</coordY>';
				//XML += '<cityId>'+regRoute.departure.+'</cityId>';
				XML += '</departure>';
				XML += '<arrival>';
				XML += '<country>' + regRoute.arrival.country + '</country>';
				XML += '<region>' + regRoute.arrival.region + '</region>';
				XML += '<city>' + regRoute.arrival.city + '</city>';
				if(Generic.StringNotEmpty(regRoute.arrival.coordX))
					XML += '<coordX>' + regRoute.arrival.coordX + '</coordX>';
				else
					XML += '<coordX>0</coordX>';
				if(Generic.StringNotEmpty(regRoute.arrival.coordY))
					XML += '<coordY>' + regRoute.arrival.coordY + '</coordY>';
				else
					XML += '<coordY>0</coordY>';
				//XML += '<cityId>'++'</cityId>';
				XML += '</arrival>';
				for(String day : regRoute.days)
					XML += '<days>' + day + '</days>';
				XML += '</regularRoute>';
			} // for all regularRoutes
			XML += '</regularRoutes>';
		} // if regularRoutes size > 0
		XML += '</activity>';
		XML += '<updaterName>'+Userinfo.getName()+'</updaterName>';
		XML += '</tel:updateActivity>';
		XML += '</tel:updateTCDActivity>';
		XML += '</soapenv:Body>';
		XML += '</soapenv:Envelope>';
		Dom.Document document = doCallout(XML);
		Dom.XMLNode response = document.getRootElement();
		return response;
	} //updateRegularRoutesXml
	//=========================================================================================
	// Contacts
	//=========================================================================================
	public static Dom.XmlNode getContactsXml(String companyId,Boolean visible)
	{
		String XML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tel="http://teleroute.com/telerouteCompanyDirectory">';
		XML += '<soapenv:Header/>';
		XML += '<soapenv:Body>';
		XML += '<tel:getTCDContacts>';
		XML += '<getContacts>';
		XML += '<companyId>'+companyId+'</companyId>';
		XML += '<visible>'+visible+'</visible>';
		XML += '</getContacts>';
		XML += '</tel:getTCDContacts>';
		XML += '</soapenv:Body>';
		XML += '</soapenv:Envelope>';
		Dom.Document document = doCallout(XML);
		Dom.XMLNode response = document.getRootElement();
		return response;
	} //getContactsXml
	//=========================================================================================
	// Certificates
	//=========================================================================================
	public static Dom.XmlNode getCertificatesXml(String companyId)
	{
		String XML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tel="http://teleroute.com/telerouteCompanyDirectory">';
		XML += '<soapenv:Header/>';
		XML += '<soapenv:Body>';
		XML +=   '<tel:getTCDCertificates>';
		XML +=     '<tel:getCertificates>';
		XML +=       '<companyId>' + companyId + '</companyId>';
		XML +=     '</tel:getCertificates>';
		XML +=   '</tel:getTCDCertificates>';
		XML += '</soapenv:Body>';
		XML += '</soapenv:Envelope>';
		Dom.Document document = doCallout(XML);
		Dom.XMLNode response = document.getRootElement();
		return response;
	} //getCertificatesXml
	
	public static Dom.XmlNode updateCertificateXml(TcdCertificate certificate)
	{
		system.debug('## >>> updateCertificateXml: The certification expiration date '+certificate.Index+' is equal to : '+certificate.certif.Expiration_Date__c);
		String XML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tel="http://teleroute.com/telerouteCompanyDirectory">';
		XML += '<soapenv:Header/>';
		XML += '<soapenv:Body>';
		XML += '<tel:updateTCDCertificate>';
		XML += '<tel:updateCertificate>';
		XML += '<companyId>' + certificate.CompanyId + '</companyId>';
		XML += '<certificate>';
		if(Generic.StringNotEmpty(certificate.certif.PredefinedType__c))
		{
			XML += '<type>' + certificate.certif.PredefinedType__c + '</type>';
		}
		else
		{
			XML += '<type>' + certificate.certif.Type__c + '</type>';
		}
		//Required format 'YYYY-MM-DD'
		//XML += '<expirationDate>'+certificate.certif.Expiration_Date__c.date().year()+'-'+certificate.certif.Expiration_Date__c.date().month()+'-'+certificate.certif.Expiration_Date__c.date().day()+'</expirationDate>';
		XML += '<expirationDate>' + certificate.certif.Expiration_Date__c + '</expirationDate>';
		XML += '<href>' + certificate.certif.Url__c + '</href>';
		XML += '<salesForceId>' + certificate.SalesforceId + '</salesForceId>';
		XML += '<status>' + certificate.certif.Status__c + '</status>';
		XML += '</certificate>';
		XML += '</tel:updateCertificate>';
		XML += '</tel:updateTCDCertificate>';
		XML += '</soapenv:Body>';
		XML += '</soapenv:Envelope>';
		Dom.Document document = doCallout(XML);
		Dom.XMLNode response = document.getRootElement();
		return response;
	} //updateCertificateXml
	
	public static Dom.XmlNode deleteCertificateXml(TcdCertificate certificate)
	{
		String XML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tel="http://teleroute.com/telerouteCompanyDirectory">';
		XML += '<soapenv:Header/>';
		XML += '<soapenv:Body>';
		XML += '<tel:deleteTCDCertificate>';
		XML += '<tel:deleteCertificate>';
		XML += '<companyId>' + certificate.CompanyId + '</companyId>';
		XML += '<salesForceId>' + certificate.SalesforceId + '</salesForceId>';
		XML += '</tel:deleteCertificate>';
		XML += '</tel:deleteTCDCertificate>';
		XML += '</soapenv:Body>';
		XML += '</soapenv:Envelope>';
		Dom.Document document = doCallout(XML);
		Dom.XMLNode response = document.getRootElement();
		return response;
	} //deleteCertificateXml
	//=========================================================================================
	// Languages
	//=========================================================================================
	public static Dom.XmlNode getLanguagesXml(String companyId)
	{
		String XML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tel="http://teleroute.com/telerouteCompanyDirectory">';
		XML += '<soapenv:Header/>';
		XML += '<soapenv:Body>';
		XML += '<tel:getTCDLanguages>';
		XML += '<getLanguages>';
		XML += '<companyId>' + companyId + '</companyId>';
		XML += '</getLanguages>';
		XML += '</tel:getTCDLanguages>';
		XML += '</soapenv:Body>';
		XML += '</soapenv:Envelope>';
		Dom.Document document = doCallout(XML);
		Dom.XMLNode response = document.getRootElement();
		return response;
	} //getLanguagesXml
	
	public static Dom.XmlNode updateLanguagesXml(String companyId, String[] languages)
	{
		system.debug('## >>> updateLanguagesXml Begin: '+languages);
		String XML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tel="http://teleroute.com/telerouteCompanyDirectory">';
		XML += '<soapenv:Header/>';
		XML += '<soapenv:Body>';
		XML += '<tel:updateTCDLanguages>';
		XML += '<tel:updateLanguages>';
		XML += '<companyId>' + companyId + '</companyId>';
		XML += '<languages>';
		for (String lan : languages)
			XML += '<language>' + lan + '</language>';
		XML += '</languages>';
		XML += '<updaterName>' + Userinfo.getName() + '</updaterName>';
		XML += '</tel:updateLanguages>';
		XML += '</tel:updateTCDLanguages>';
		XML += '</soapenv:Body>';
		XML += '</soapenv:Envelope>';
		Dom.Document document = doCallout(XML);
		Dom.XMLNode response = document.getRootElement();
		return response;
	} //updateLanguagesXml
	//=========================================================================================
	// Warehouse
	//=========================================================================================
	public static Dom.XmlNode getWarehousesXml(String companyId)
	{
		String XML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tel="http://teleroute.com/telerouteCompanyDirectory">';
		XML += '<soapenv:Header/>';
		XML += '<soapenv:Body>';
		XML += '<tel:getTCDWarehouse>';
		XML += '<getWareHousing>';
		XML += '<companyId>' + companyId + '</companyId>';
		XML += '</getWareHousing>';
		XML += '</tel:getTCDWarehouse>';
		XML += '</soapenv:Body>';
		XML += '</soapenv:Envelope>';
		Dom.Document document = doCallout(XML);
		Dom.XMLNode response = document.getRootElement();
		return response;
	} //getWarehousesXml
	
	public static Dom.XmlNode updateWarehousesXml(TcdWarehouse warehouse)
	{
		String XML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tel="http://teleroute.com/telerouteCompanyDirectory">';
		XML += '<soapenv:Header/>';
		XML += '<soapenv:Body>';
		XML += '<tel:updateTCDWarehouse>';
		XML += '<tel:updateWarehouse>';
		XML += '<!--Optional:-->';
		XML += '<warehouseName>'+warehouse.warehouseName+'</warehouseName>';
		XML += '<!--Optional:-->';
		XML += '<storageIndoor>'+warehouse.storageIndoor+'</storageIndoor>';
		XML += '<!--Optional:-->';
		XML += '<storageOutdoor>'+warehouse.storageOutdoor+'</storageOutdoor>';
		XML += '<!--Optional:-->';
		if(Generic.StringNotEmpty(warehouse.storageSuperficie))
			XML += '<storageSuperficie>'+warehouse.storageSuperficie+'</storageSuperficie>';
		XML += '<!--Optional:-->';
		if(Generic.StringNotEmpty(warehouse.loadCode))
			XML += '<loadCode>'+warehouse.loadCode+'</loadCode>';
		XML += '<!--Optional:-->';
		XML += '<accessibilityRoad>'+warehouse.accessibilityRoad+'</accessibilityRoad>';
		XML += '<!--Optional:-->';
		XML += '<accessibilityTrain>'+warehouse.accessibilityTrain+'</accessibilityTrain>';
		XML += '<!--Optional:-->';
		XML += '<accessibilityWater>'+warehouse.accessibilityWater+'</accessibilityWater>';
		XML += '<!--Optional:-->';
		XML += '<accessibilityAir>'+warehouse.accessibilityAir+'</accessibilityAir>';
		XML += '<!--Optional:-->';
		XML += '<distributionRegional>'+warehouse.distributionRegional+'</distributionRegional>';
		XML += '<!--Optional:-->';
		XML += '<distributionNational>'+warehouse.distributionNational+'</distributionNational>';
		XML += '<!--Optional:-->';
		XML += '<distributionInternational>'+warehouse.distributionInternational+'</distributionInternational>';
		XML += '<!--Optional:-->';
		if(Generic.StringNotEmpty(warehouse.facilities))
			XML += '<facilities>'+warehouse.facilities+'</facilities>';
		XML += '<!--Optional:-->';
		if(Generic.StringNotEmpty(warehouse.services))
			XML += '<services>'+warehouse.services+'</services>';
		XML += '<!--Optional:-->';
		if(Generic.StringNotEmpty(warehouse.contact))
			XML += '<contact>'+warehouse.contact+'</contact>';
		XML += '<!--Optional:-->';
		XML += '<address>';
		if(Generic.StringNotEmpty(warehouse.address.street))
			XML += '<street>'+warehouse.address.street+'</street>';
		if(Generic.StringNotEmpty(warehouse.address.address1))
			XML += '<address1>'+warehouse.address.address1+'</address1>';
		if(Generic.StringNotEmpty(warehouse.address.address2))
			XML += '<address2>'+warehouse.address.address2+'</address2>';
		if(Generic.StringNotEmpty(warehouse.address.address3))
			XML += '<address3>'+warehouse.address.address3+'</address3>';
		if(Generic.StringNotEmpty(warehouse.address.zipCode))
			XML += '<zipCode>'+warehouse.address.zipCode+'</zipCode>';
		if(Generic.StringNotEmpty(warehouse.address.province))
			XML += '<province>'+warehouse.address.province+'</province>';
		XML += '</address>';
		if(Generic.StringNotEmpty(warehouse.email))
			XML += '<email>'+warehouse.email+'</email>';
		if(Generic.StringNotEmpty(warehouse.phone))
			XML += '<phone>'+warehouse.phone+'</phone>';
		XML += '<location>';
		if(Generic.StringNotEmpty(warehouse.location.countryCode))
			XML += '<country>'+warehouse.location.countryCode+'</country>';
		if(Generic.StringNotEmpty(warehouse.location.region))
			XML += '<region>'+warehouse.location.region+'</region>';
		if(Generic.StringNotEmpty(warehouse.location.city))
			XML += '<city>'+warehouse.location.city+'</city>';
		if(Generic.StringNotEmpty(warehouse.location.coordX))
			XML += '<coordX>'+warehouse.location.coordX+'</coordX>';
		else
			XML += '<coordX>0</coordX>';
		if(Generic.StringNotEmpty(warehouse.location.coordY))
			XML += '<coordY>'+warehouse.location.coordY+'</coordY>';
		else
			XML += '<coordY>0</coordY>';
//		XML += '<cityId>'++'</cityId>';
		XML += '</location>';
		XML += '<!--Optional:-->';
		XML += '<index>'+warehouse.Index+'</index>';
		XML += '<!--Optional:-->';
//		XML += '<active>'++'</active>';
		XML += '<companyId>'+warehouse.companyId+'</companyId>';
		XML += '<updater_name>'+Userinfo.getName()+'</updater_name>';
		XML += '</tel:updateWarehouse>';
		XML += '</tel:updateTCDWarehouse>';
		XML += '</soapenv:Body>';
		XML += '</soapenv:Envelope>';
		Dom.Document document = doCallout(XML);
		Dom.XMLNode response = document.getRootElement();
		return response;
	} //updateWarehousesXml
	//=========================================================================================
	// Other stuff
	//=========================================================================================
    /*
    * Author        : HCL Technology LTD
    * Date          : 07-02-2013
    * Description   : Delete unwanted document from TCD
    * Midified by Anton Solovyev. I've refactored this method.
    **/
    public static Dom.XmlNode deleteDocumentFromTCD (long documentId){

        String XML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:wsdl="http://documents.teleroute.com/management/wsdl">';
        XML += '<soapenv:Header/>';
        XML += '<soapenv:Body>';
        XML += '<wsdl:removeDocument>';
        XML += '<documentId>'+documentId+'</documentId>';
        XML += '</wsdl:removeDocument>';
        XML += '</soapenv:Body>';
        XML += '</soapenv:Envelope>';
        Dom.Document document = doCallout(XML, FXSettings__c.getValues('FXSettings').Delete_Doc_ESB_WSDL__c);
        system.debug('document ######### '+document);

        Dom.XMLNode response = document.getRootElement();

        return response;

    }

	/*@future(callout=true)
	* Author        : HCL Technology LTD, Anton Soloview remix (08-oct-2013)
	* Date          : 16-05-2013
	* Description   : Following is the WKTS bridge service use to assign WKTS bridge profile
	**/
	public static boolean assignWKTSBridgeProfile(String AccountNumber, String userName, String profileID, boolean throwException)
	{
		System.debug('---- TcdStub.assignWKTSBridgeProfile: parameters: accountNumber: ' + AccountNumber + ', userName: ' + userName + ', profileId: ' + profileID);

		String XML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.proxy.bridge.teleroute.wkts.com/">';
		XML += '<soapenv:Header/>';
		XML += '<soapenv:Body>';
		XML += '<ws:assignToProfile>';
		XML += '<profileId>' + profileID + '</profileId>';
		XML += '<site>' + AccountNumber + '</site>';
		XML += '<logins>';
		XML += 		'<item>' + userName + '</item>';
		XML += '</logins>';
		XML += '</ws:assignToProfile>';
		XML += '</soapenv:Body>';
		XML += '</soapenv:Envelope>';

		System.debug('---- TcdStub.assignWKTSBridgeProfile: doCallout call.');
		Dom.Document document = doCallout(XML, FXSettings__c.getValues('FXSettings').WKTS_Bridge_Profile__c, FXSettings__c.getValues('FXSettings').Bridge_certificate_name__c);

		try
		{
			Dom.XMLNode respNode = document.getRootElement();
			System.debug('------ TcdStub.assignWKTSBridgeProfile: respNode: ' + respNode);
			// here we need full namespace name, not the prefix
			Dom.Xmlnode bodyNode = respNode.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
			System.debug('---- TcdStub.assignWKTSBridgeProfile: bodyNode: ' + bodyNode);
			Dom.Xmlnode node = bodyNode.getChildElements()[0];
			System.debug('---- TcdStub.assignWKTSBridgeProfile: node: ' + node);
			string nodeName = node.getName();
			string nodeValue = '';
			if(nodeName.equalsIgnoreCase('assignToProfileResponse'))
			{
				nodeValue = node.getChildElements()[0].getText();
				if(nodeValue.equals('1'))
					return true;
			}
			else
			{
				Dom.XmlNode faultStr = node.getChildElement('faultstring', null);
				System.debug('---- TcdStub.assignWKTSBridgeProfile: faultStr: ' + faultStr);
				nodeValue = faultStr.getText();
				throw new Generic.StandardException(nodeValue);
			}
		}
		catch(Exception ex)
		{
			System.debug('---- TcdStub.assignWKTSBridgeProfile: exception thrown during response parse: ' + ex.getMessage());
			if(throwException)
				throw ex;
		}
		return false;
	} // assignWKTSBridgeProfile

    /*
    * Author		: HCL Technology LTD, Anton Soloveyv remix
    * Date			: 16-05-2013, 12-02-2014
    * Description	: Following is the WKTS bridge service use to Get All available WKTS bridge profiles
    *				anton: I've added response parsing and parameter to get active profiles only, plus i've removed @future annotation, 
    *				so method is now sinchronous
    **/
	public static Map<string, integer> getAllWKTSBridgeProfiles(boolean activeOnly)
	{
		Map<string, integer> retVal = new Map<string, integer>();
		String  XML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.proxy.bridge.teleroute.wkts.com/">';
				XML += '<soapenv:Header/>';
				XML += '<soapenv:Body>';
				XML += '<ws:getAllProfiles/>';
				XML += '</soapenv:Body>';
				XML += '</soapenv:Envelope>';
		
		Dom.Document document = doCallout(XML, FXSettings__c.getValues('FXSettings').WKTS_Bridge_Profile__c, FXSettings__c.getValues('FXSettings').Bridge_certificate_name__c);
		
		// response parsing
		Dom.XMLNode respNode = document.getRootElement();
		Dom.Xmlnode bodyNode = respNode.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
		Dom.Xmlnode getAllProfilesResponse = bodyNode.getChildElement('getAllProfilesResponse', 'http://ws.proxy.bridge.teleroute.wkts.com/');
		
		Dom.Xmlnode[] allProfiles = getAllProfilesResponse.getChildElement('allProfilesResult', null).getChildElements();
		system.debug('========== TcdStub: getAllWKTSBridgeProfiles: allProfiles: ' + allProfiles);
		
		for(Dom.Xmlnode node : allProfiles)
		{
			string sActive = node.getChildElement('active', null).getText();
			string name = node.getChildElement('name', null).getText();
			string sId = node.getChildElement('id', null).getText();
			system.debug('========== TcdStub: getAllWKTSBridgeProfiles: node: active: ' + sActive + ', name: ' + name + ', id: ' + sId);
			
			Boolean bActive = Boolean.valueOf(sActive);
			integer iId = Integer.valueOf(sId);
			
			if(activeOnly && !bActive) // skip inactive profiles, if parameter is set to true
				continue;
			retVal.put(name, iId);
		}
		return retVal;
	} //getAllWKTSBridgeProfiles

    /*
    * Author        : HCL Technology LTD
    * Date          : 16-05-2013
    * Description   : Following is the WKTS bridge service use to Get All available WKTS bridge profiles
    **/
    @future(callout=true)
    public static void getOptOutWKTSBridgeProfile (String AccountID, String profileID){

	 	String  XML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.proxy.bridge.teleroute.wkts.com/">';
	        	XML += '<soapenv:Header/>';
	        	XML += '<soapenv:Body>';
	        	XML += '<ws:getOptOut>';
	        	XML += 		'<siteId>'+AccountID+'</siteId>';
         		XML += 		'<profileId>'+profileID+'</profileId>';
	        	XML += '</ws:getOptOut>';
	       		XML += '</soapenv:Body>';
	        	XML += '</soapenv:Envelope>';

        system.debug('getOptOutWKTSBridgeProfile XML is #### '+XML);
        Dom.Document document = doCallout(XML, FXSettings__c.getValues('FXSettings').WKTS_Bridge_Profile__c, FXSettings__c.getValues('FXSettings').Bridge_certificate_name__c);
        system.debug('document ######### '+document);

        Dom.XMLNode response = document.getRootElement();

        //return response;

    }

	/*@future(callout=true)
	* Author        : HCL Technology LTD
	* Date          : 16-05-2013
	* Description   : Following is the WKTS bridge service use to Suppress existing assignation of user to selected WKTS bridge profiles
	**/
	public static boolean suppressAssignationOfWKTSBridgeProfile(String userID, String profileID, boolean throwException)
	{
		String XML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.proxy.bridge.teleroute.wkts.com/">';
		XML += '<soapenv:Header/>';
		XML += '<soapenv:Body>';
		XML += '<ws:suppressAssignation>';
		XML += 		'<listOfIds>';
		XML += 			'<item>'+userID+'</item>';
		XML += 		'</listOfIds>';
		XML += 		'<profileId>'+profileID+'</profileId>';
		XML += '</ws:suppressAssignation>';
		XML += '</soapenv:Body>';
		XML += '</soapenv:Envelope>';

		System.debug('---- TcdStub.suppressAssignationOfWKTSBridgeProfile: doCallout call.');
		Dom.Document document = doCallout(XML, FXSettings__c.getValues('FXSettings').WKTS_Bridge_Profile__c, FXSettings__c.getValues('FXSettings').Bridge_certificate_name__c);

		Dom.XMLNode response = document.getRootElement();

		try
		{
			Dom.XMLNode respNode = document.getRootElement();
			System.debug('------ TcdStub.suppressAssignationOfWKTSBridgeProfile: respNode: ' + respNode);
			// here we need full namespace name, not the prefix
			Dom.Xmlnode bodyNode = respNode.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
			System.debug('---- TcdStub.suppressAssignationOfWKTSBridgeProfile: bodyNode: ' + bodyNode);
			Dom.Xmlnode node = bodyNode.getChildElements()[0];
			System.debug('---- TcdStub.suppressAssignationOfWKTSBridgeProfile: node: ' + node);
			string nodeName = node.getName();
			string nodeValue = '';
			if(nodeName.equalsIgnoreCase('suppressAssignationResponse'))
			{
				nodeValue = node.getChildElements()[0].getText();
				if(nodeValue.equals('1'))
					return true;
			}
			else
			{
				Dom.XmlNode faultStr = node.getChildElement('faultstring', null);
				System.debug('---- TcdStub.suppressAssignationOfWKTSBridgeProfile: faultStr: ' + faultStr);
				nodeValue = faultStr.getText();
				throw new Generic.StandardException(nodeValue);
			}
		}
		catch(Exception ex)
		{
			System.debug('---- TcdStub.suppressAssignationOfWKTSBridgeProfile: exception thrown during response parse: ' + ex.getMessage());
			if(throwException)
				throw ex;
		}
		return false;
	} // suppressAssignationOfWKTSBridgeProfile

	// remain for compatibility
	private static Dom.Document doCallout(string XML)
	{
		return doCallout(XML, FXSettings__c.getValues('FXSettings').Company_Directory_ESB_WSDL__c);
	}
	
	// remain for compatibility
	private static Dom.Document doCallout(string XML, string webServiceURL)
	{
		return doCallout(XML, webServiceURL, FXSettings__c.getValues('FXSettings').Proxy_ESB_Certificate__c);
	}
	/**
		This method does the actual webservice callout
		refactored to accept WS url by Anton Solovyev at 2013-06-19
	**/
	private static Dom.Document doCallout(string XML, string webServiceURL, string certificateName)
	{
		try
		{
			system.debug('---- TcdStub.doCallout: SoapHttp.sendSOAPRequest call.');
			HttpResponse resp = SoapHttp.sendSOAPRequest(XML, webServiceURL, 10000, certificateName);

			if(resp.getStatusCode() == 200)
			{
				Dom.Document outDom = resp.getBodyDocument();
				return outDom;
			}
			else
			{
				throw new Generic.StandardException('HTTP Error received. code: ' + resp.getStatusCode() );
			}
		}
		catch(Exception e)
		{
			throw new Generic.StandardException('Webservice call exception occured: ' + e.getMessage());
		}
		return null;
	} //doCallout

}