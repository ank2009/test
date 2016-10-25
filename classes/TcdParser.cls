/**
    TcdParser Class
    Written by: Ronald Klaassen <r.klaassen@vivens.com>
    Date: 2011-09-15
    Company: Vivens CRM
    
    This class parses the xml content to readable format
*/
public class TcdParser {
    
    public static TcdActivity[] queryActivities(String companyId) {
        Dom.XmlNode response = TcdStub.getActivitiesXml(companyId);
        Dom.XMLNode responseBody = response.getChildElement('Body','http://schemas.xmlsoap.org/soap/envelope/');
        if( responseBody == null ){
          throw new TcdParserException( 'Unable to locate body in response XML' );
        }
        
        Dom.XMLNode responseTCDActivity = responseBody.getChildElement('getTCDActivityResponse','http://teleroute.com/telerouteCompanyDirectory');
        if( responseTCDActivity == null ){
          throw new TcdParserException( 'Unable to locate getTCDActivityResponse in response XML' );  
        }
        
        Dom.XMLNode responseResult = responseTCDActivity.getChildElement('responseGetActivity','http://company.teleroute.com');
        if( responseResult == null ){
          throw new TcdParserException( 'Unable to locate responseGetActivity in response XML' );
        }
        
        List<Dom.XMLNode> nodeList = responseResult.getChildElements();     
        TcdActivity[] activities = new TcdActivity[]{};
        for( Dom.Xmlnode node : nodeList ){
            TcdActivity act = new TcdActivity();
            Integer cptRegularRoute = 0;
            Integer cptActivityCountry = 0;
            for (Dom.Xmlnode child : node.getChildElements()) {
                if (child.getName() == 'nbWarehouse') {
                    act.nbWarehouse = child.getText();
                }
                if (child.getName() == 'numberOfTruck') {
                    act.numberOfTruck = child.getText();
                }
                if (child.getName() == 'specializationComments') {
                    act.specializationComments = child.getText();
                }
                if (child.getName() == 'companyIdentifier') {
                    for (Dom.XmlNode child2 : child.getChildElements()) {
                        if (child2.getName() == 'companyId') {
                            act.companyIdentifier.companyId = child2.getText();
                        }
                        if (child2.getName() == 'lastUpdaterName') {
                            act.companyIdentifier.lastUpdaterName = child2.getText();
                        }
                        if (child2.getName() == 'lastUpdateDate') {
                            act.companyIdentifier.lastUpdateDate = child2.getText();
                        }
                    }
                }
                if (child.getName() == 'specializationCodes') {
//                  act.specializationCodes.add([select Name from Specialization_Code__c where Label__c=:(Specialization_Code__c.getValues(child.getText()).Label__c)].Name);
//                    act.specializationCodes.add(Specialization_Code__c.getValues(child.getText()).Label__c);
                    act.specializationCodes.add(child.getText());
                }
                if (child.getName() == 'regularRoutes') {
                    TcdActivity.RegularRoute route = new TcdActivity.RegularRoute();
                    route.activityParent = act;                    
                    for (Dom.XmlNode child2 : child.getChildElements()) {
                        if (child2.getName() == 'departure') {
                            route.Index = cptRegularRoute;                          
                            route.departure = new TcdActivity.Departure();
                            for (Dom.XmlNode child3 : child2.getChildElements()) {
                                if (child3.getName() == 'country') {
                                    //route.departure.country = Generic.getLanguageLabel(child3.getText());
                                    route.departure.countryCode = child3.getText();
                                }
                                if (child3.getName() == 'region') {
                                    route.departure.region = child3.getText();
                                }
                                if (child3.getName() == 'city') {
                                    route.departure.city = child3.getText();
                                }
                                if (child3.getName() == 'coordX') {
                                    route.departure.coordX = child3.getText();
                                }
                                if (child3.getName() == 'coordY') {
                                    route.departure.coordY = child3.getText();
                                } 
                            }
                        }
                        if (child2.getName() == 'arrival') {
                            route.arrival = new TcdActivity.Arrival();
                            for (Dom.XmlNode child3 : child2.getChildElements()) {
                                if (child3.getName() == 'country') {
                                    //route.arrival.country = Generic.getLanguageLabel(child3.getText());
                                    route.arrival.countryCode = child3.getText();
                                }
                                if (child3.getName() == 'region') {
                                    route.arrival.region = child3.getText();
                                }
                                if (child3.getName() == 'city') {
                                    route.arrival.city = child3.getText();
                                }
                                if (child3.getName() == 'coordX') {
                                    route.arrival.coordX = child3.getText();
                                }
                                if (child3.getName() == 'coordY') {
                                    route.arrival.coordY = child3.getText();
                                } 
                            }
                        }   
                        if(child2.getName()=='days')
                        {
                        	route.days.add(child2.getText());
                        }                  
                    }
                    act.regularRoutes.put(cptRegularRoute,route);
                    cptRegularRoute++;
                }
                if (child.getName() == 'countries') {
                    TcdActivity.Country country = new TcdActivity.Country();
                    country.regions = new List<String>();
                    //country.Index = cptActivityCountry;
                    country.activityParent = act; 
                    for (Dom.XmlNode child2 : child.getChildElements()) {
                        if (child2.getName() == 'countryCode') {
                            country.countryCode = child2.getText();
                        }
                        if (child2.getName() == 'regions') {
                        	country.regions.add(child2.getText());
                        }
                    }
                    act.countries.add(country);
                    if(act.countryMap.containsKey(country.countryCode))
                    {
                    	act.countryMap.get(country.countryCode).regions.addAll(country.regions);
                    }
                    else
                    {
                    	act.countryMap.put(country.countryCode,country);
                    }
                    //cptActivityCountry++;
                }
                
            }
            activities.add(act);
        }
        
        return activities;
    }
    
        
    public static Map<Integer,TcdWarehouse> queryWarehouses(String companyId) {
        Dom.XmlNode response = TcdStub.getWarehousesXml(companyId);
        Dom.XMLNode responseBody = response.getChildElement('Body','http://schemas.xmlsoap.org/soap/envelope/');
        if( responseBody == null ){
          throw new TcdParserException( 'Unable to locate body in response XML' );
        }
        
        Dom.XMLNode responseTCDWarehouse = responseBody.getChildElement('getTCDWarehouseResponse','http://teleroute.com/telerouteCompanyDirectory');
        if( responseTCDWarehouse == null ){
          throw new TcdParserException( 'Unable to locate getTCDWarehouseResponse in response XML' );  
        }
        
        Dom.XMLNode responseResult = responseTCDWarehouse.getChildElement('responseGetWareHousing','http://company.teleroute.com');
        if( responseResult == null ){
          throw new TcdParserException( 'Unable to locate responseGetWareHousing in response XML' );  
        }
        
        List<Dom.XMLNode> nodeList = responseResult.getChildElements();  
        Map<Integer,TcdWarehouse> warehouses = new Map<Integer,TcdWarehouse>();
        //Integer warehouseCpt = 0;
        for( Dom.Xmlnode node : nodeList ){
            TcdWarehouse wh = new TcdWarehouse();
            for (Dom.Xmlnode child : node.getChildElements()) {
            	if(child.getName() == 'index')
                {
                	wh.Index = Integer.valueOf(child.getText());
                }
                if (child.getName() == 'warehouseName') {
                    wh.warehouseName = child.getText();
                }
                if (child.getName() == 'storageIndoor') {
                    wh.storageIndoor = (child.getText() == 'true') ? true : false;
                }
                if (child.getName() == 'storageOutdoor') {
                    wh.storageOutdoor = (child.getText() == 'true') ? true : false;
                }
                if (child.getName() == 'storageSuperficie') {
                    wh.storageSuperficie = child.getText();
                }
                if (child.getName() == 'loadCode') {
                    wh.loadCode = child.getText();
                }
                if (child.getName() == 'accessibilityRoad') {
                    wh.accessibilityRoad = (child.getText() == 'true') ? true : false;
                }
                if (child.getName() == 'accessibilityTrain') {
                    wh.accessibilityTrain = (child.getText() == 'true') ? true : false;
                }
                if (child.getName() == 'accessibilityWater') {
                    wh.accessibilityWater = (child.getText() == 'true') ? true : false;
                }
                if (child.getName() == 'accessibilityAir') {
                    wh.accessibilityAir = (child.getText() == 'true') ? true : false;
                }
                if (child.getName() == 'distributionRegional') {
                    wh.distributionRegional = (child.getText() == 'true') ? true : false;
                }
                if (child.getName() == 'distributionNational') {
                    wh.distributionNational = (child.getText() == 'true') ? true : false;
                }
                if (child.getName() == 'distributionInternational') {
                    wh.distributionInternational = (child.getText() == 'true') ? true : false;
                }
                if (child.getName() == 'contact') {
                    wh.contact = child.getText();
                }
                if (child.getName() == 'email') {
                    wh.email = child.getText();
                }
                if (child.getName() == 'phone') {
                    wh.phone = child.getText();
                }
                if (child.getName() == 'facilities') {
                	wh.facilities = child.getText();
                }
                if (child.getName() == 'services') {
                	wh.services = child.getText();
                }                
                if (child.getName() == 'address') {
                    for (Dom.XmlNode child2 : child.getChildElements()) {
                        if (child2.getName() == 'street') {
                            wh.address.street = child2.getText();
                        }
                        if (child2.getName() == 'address1') {
                            wh.address.address1 = child2.getText();
                        }
                        if (child2.getName() == 'address2') {
                            wh.address.address2 = child2.getText();
                        }
                        if (child2.getName() == 'address3') {
                            wh.address.address3 = child2.getText();
                        }
                        if (child2.getName() == 'zipCode') {
                            wh.address.zipCode = child2.getText();
                        }
                        if (child2.getName() == 'province') {
                            wh.address.province = child2.getText();
                        }
                    }
                }
                if (child.getName() == 'location') {
                    for (Dom.XmlNode child2 : child.getChildElements()) {
                        if (child2.getName() == 'country') {
                            //wh.location.country = Generic.getLanguageLabel(child2.getText());
                            wh.location.countryCode = child2.getText();
                        }
                        if (child2.getName() == 'region') {
                            wh.location.region = child2.getText();
                        }
                        if (child2.getName() == 'city') {
                            wh.location.city = child2.getText();
                        }
                        if (child2.getName() == 'coordX') {
                            wh.location.coordX = child2.getText();
                        }
                        if (child2.getName() == 'coordY') {
                            wh.location.coordY = child2.getText();
                        } 
                    }
                }
            }
            //wh.Index = warehouseCpt;
            warehouses.put(wh.Index,wh);
            //warehouseCpt++;
        }
        return warehouses;
    }
    
     public static Map<String,Contact> queryContacts(String companyId,Boolean visible) {
        Dom.XmlNode response = TcdStub.getContactsXml(companyId,visible);
        Dom.XMLNode responseBody = response.getChildElement('Body','http://schemas.xmlsoap.org/soap/envelope/');
        if( responseBody == null ){
          throw new TcdParserException( 'Unable to locate body in response XML' );
        }
        
        Dom.XMLNode responseTCDContacts = responseBody.getChildElement('getTCDContactsResponse','http://teleroute.com/telerouteCompanyDirectory');
        if( responseTCDContacts == null ){
          throw new TcdParserException( 'Unable to locate getTCDContactsResponse in response XML' );  
        }
        
        Dom.XMLNode responseResult = responseTCDContacts.getChildElement('responseGetFullContacts','http://company.teleroute.com');
        if( responseResult == null ){
          throw new TcdParserException( 'Unable to locate responseGetFullContacts in response XML' );  
        }
        
        List<Dom.XMLNode> nodeList = responseResult.getChildElements();     
        Map<String,Contact> contactList = new   Map<String,Contact>();
        Contact contact;
        for( Dom.Xmlnode node : nodeList ){
            if (node.getName() == 'fullContact') {
                contact = new Contact();
                for (Dom.XmlNode child : node.getChildElements()) {
//                  if(child.getName()=='function')
//                      contact = child.getText();
                    if(child.getName()=='title')
                        contact.Title = child.getText();
                    if(child.getName()=='firstName')
                        contact.FirstName = child.getText();
                    if(child.getName()=='lastName')
                        contact.LastName = child.getText();
                    if(child.getName()=='jobTitle')
                        contact.Job_Title__c = child.getText();
                    if(child.getName()=='email')
                        contact.Email = child.getText();
                    if(child.getName()=='phone')
                        contact.Phone = child.getText();
                    if(child.getName()=='fax')
                        contact.Fax = child.getText();
//                  if(child.getName()=='spokenLanguages')
//                      contact.Language__c = child.getText();
                    if(child.getName()=='mainLanguage')
                        contact.Language__c = child.getText();
                    if(child.getName()=='cmsRowId')
                        contact.Contact_id__c = child.getText();
                    if(child.getName()=='mobile')
                        contact.MobilePhone = child.getText();
//                  if(child.getName()=='prefix')
//                      contact = child.getText();
                    if(child.getName()=='login')
                        contact.Username__c = child.getText();
/*                  if(child.getName()=='address1')
                        contact = child.getText();
                    if(child.getName()=='address2')
                        contact = child.getText();
                    if(child.getName()=='address3')
                        contact = child.getText();
                    if(child.getName()=='zipCode')
                        contact = child.getText();
                    if(child.getName()=='city')
                        contact = child.getText();
                    if(child.getName()=='country')
                        contact = child.getText();*/
                }
                contactList.put(contact.Contact_id__c,contact);
            }
        }
        return contactList;
    }
    
    public static String[] queryLanguages(String companyId) {
        Dom.XmlNode response = TcdStub.getLanguagesXml(companyId);
        Dom.XMLNode responseBody = response.getChildElement('Body','http://schemas.xmlsoap.org/soap/envelope/');
        if( responseBody == null ){
          throw new TcdParserException( 'Unable to locate body in response XML' );
        }
        
        Dom.XMLNode responseTCDLanguages = responseBody.getChildElement('getTCDLanguagesResponse','http://teleroute.com/telerouteCompanyDirectory');
        if( responseTCDLanguages == null ){
          throw new TcdParserException( 'Unable to locate getTCDLanguagesResponse in response XML' );  
        }
        
        Dom.XMLNode responseResult = responseTCDLanguages.getChildElement('responseGetLanguages','http://company.teleroute.com');
        if( responseResult == null ){
          throw new TcdParserException( 'Unable to locate responseGetLanguages in response XML' );  
        }
        
        List<Dom.XMLNode> nodeList = responseResult.getChildElements();     
        String[] languages = new String[]{};
        for( Dom.Xmlnode node : nodeList ){
            if (node.getName() == 'languages') {
                for (Dom.XmlNode child : node.getChildElements()) {
                    languages.add(child.getText());
                }
            }
        }
        return languages;
    }
    
    public static List<TcdCertificate> queryCertificates(String companyId) {
        Dom.XmlNode response = TcdStub.getCertificatesXml(companyId);
    
        Dom.XMLNode responseBody = response.getChildElement('Body','http://schemas.xmlsoap.org/soap/envelope/');
        if( responseBody == null ){
          throw new TcdParserException( 'Unable to locate body in response XML' );
        }
        
        Dom.XMLNode responseTCDCertificates = responseBody.getChildElement('getTCDCertificatesResponse','http://teleroute.com/telerouteCompanyDirectory');
        if( responseTCDCertificates == null ){
          throw new TcdParserException( 'Unable to locate getTCDCertificatesResponse in response XML' );  
        }
        
        Dom.XMLNode responseResult = responseTCDCertificates.getChildElement('responseGetCertificates','http://teleroute.com/telerouteCompanyDirectory');
        if( responseResult == null ){
          throw new TcdParserException( 'Unable to locate responseGetCertificates in response XML' );  
        }
        
        List<Dom.XMLNode> nodeList = responseResult.getChildElements();   
        List<TcdCertificate> certificates = new List<TcdCertificate>();
        TcdCertificate currentCertif;
        Integer cpt=0;
        for( Dom.Xmlnode node : nodeList ){
            if (node.getName() == 'certificate') {
                currentCertif = new TcdCertificate();                
                currentCertif.Index = cpt;   
                cpt++;             
                for (Dom.XmlNode child : node.getChildElements()) {
                    if (child.getName() == 'type') {
                        currentCertif.certif.Type__c = child.getText();
                        currentCertif.certif.PredefinedType__c = child.getText();
                        try
                        {
                        	currentCertif.certif.Url__c = Certificate_Type__c.getInstance(currentCertif.certif.PredefinedType__c).Url__c;
                        }
                        catch(Exception e)
                        {
                        	System.debug('## >>> Error to retrieve the url of the certificate : '+e);
                        }
                    }
                    if (child.getName() == 'expirationDate') {
                        currentCertif.certif.Expiration_Date__c = Date.valueOf(child.getText());
                        system.debug('## >>> The expiration date for the certif '+currentCertif.Index+' is equal to : '+child.getText());
                    }
                    if (child.getName() == 'status') {
                        currentCertif.certif.Status__c = child.getText();
                    }
                    if (child.getName() == 'modificationDate') {
                    	currentCertif.certif.Processed_Date__c = Date.valueOf(child.getText());
                    }
                    if (child.getName() == 'salesForceId') {
                        currentCertif.SalesforceId = child.getText();
                    }
                }
                // We try to retrieve the matching Certificate envelop from stored in salesforce
                /*
                try{
                    certif.Certif = [select Id from Certificate__c where Id=:certif.SalesforceId];
                }catch(Exception e){
                    certif.Certif = new Certificate__c();
                }
                */
                system.debug('## >>> The certif '+currentCertif.Index+' is equal to : '+currentCertif);
                certificates.add(currentCertif);
            }
        }
        return certificates;
    }
    
    public static TcdCoC queryCodeOfConduct(String companyId) {
        Dom.XmlNode response = TcdStub.getCodeOfConductXml(companyId);
    
        Dom.XMLNode responseBody = response.getChildElement('Body','http://schemas.xmlsoap.org/soap/envelope/');
        if( responseBody == null ){
          throw new TcdParserException( 'Unable to locate body in response XML' );
        }
        
        Dom.XMLNode responseTCDCoC = responseBody.getChildElement('getTCDCodeOfConductResponse','http://teleroute.com/telerouteCompanyDirectory');
        if( responseTCDCoC == null ){
          throw new TcdParserException( 'Unable to locate getTCDCodeOfConductResponse in response XML' );  
        }
        
        Dom.XMLNode responseResult = responseTCDCoC.getChildElement('responseGetCodeOfConduct','http://teleroute.com/telerouteCompanyDirectory');
        if( responseResult == null ){
          throw new TcdParserException( 'Unable to locate responseGetCertificates in response XML' );  
        }
        
        List<Dom.XMLNode> nodeList = responseResult.getChildElements();   
        TcdCoC codeOfConduct = new TcdCoC();
        codeOfConduct.CompanyId = companyId;
        for (Dom.XmlNode child : nodeList) {
            if (child.getName() == 'decider') {
                codeOfConduct.DeciderId = child.getText();
                //We are looking for matching contact
                /*  Deprecated
                try
                {
                    Contact decider=[select Name,Contact_id__c from Contact where Id=:child.getText()];
                    codeOfConduct.Decider = decider.Name;
                    //codeOfConduct.DeciderId = decider.Contact_id__c;
                }
                catch(Exception e)
                {
                    codeOfConduct.Decider = child.getText();
                }*/
            }
            if (child.getName() == 'lastUpdate') {
                //codeOfConduct.LastUpdate = Date.valueOf(child.getText());
                codeOfConduct.LastUpdate = child.getText();
            }
            if (child.getName() == 'status') {
                codeOfConduct.StatusId = child.getText();
                
                if(child.getText()=='A'){               
                    codeOfConduct.Status = 'Accepted';
                }else if(child.getText()=='R'){
                    codeOfConduct.Status = 'Refused';
                }
                else if(child.getText()=='U'){
                    codeOfConduct.Status = 'Undecided';
                }
                else if(child.getText()=='S'){
                    codeOfConduct.Status = 'Suspended by Teleroute';
                }
                else{
                    codeOfConduct.Status = 'Warning: The status code retrieved is not a correct code : '+child.getText();
                }
            }
        }
        return codeOfConduct;
    }
    
    /** 
      Custom Exception class
    **/  
    public class TcdParserException extends Exception {
    
    }
    
}