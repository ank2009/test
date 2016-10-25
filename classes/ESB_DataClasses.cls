/** 
* @author       Anton Solovyev (anton_soloveyv@epam.com)
* @date         2014 April 16
* @description  class to keep all ESB data classes, described in communityManager XSD
*/
global class ESB_DataClasses
{
    //=================================================================
    // enums
    //=================================================================
    global enum companyObjectsTypeEnum
    {
        SHIPPER, CARRIER
    }
    
    global enum addressLocationTypeEnum
    {
        billing, pickup, delivery, postal
    }
    
    global enum userRole
    {
        // FX
        FX_Freight_Post, FX_Freight_Search, FX_Vehicle_Post, FX_Vehicle_Search, FX_Matching, 
        FX_ETC_PostFreight, FX_ETC_SearchFreight, FX_ETC_PostVehicle, FX_ETC_SearchVehicle,
        FX_ETC_GUI, FX_ETC_PushFreight,FX_ETC_PushVehicle, FX_Others_Shared_Offers, FX_Other_Multiaccess,
        FX_Others_Maps, FX_Others_SmartSearch, FX_Others_SeeDetails_WHSMO, FX_Others_User_Group_Scenarious,
        FX_Others_SMS, FX_Others_Mobile, FX_Others_Fax, FX_Others_TransportCost, FX_Others_CD_FX, FX_Isochronous,
        FX_Profit_Checker, FX_Share_Scenarios, FX_Transport_Order_Confirmation,
        
        // ShipperTMS
        ShipperTMS_BETA, ShipperTMS_CO_RO, ShipperTMS_CO_User, ShipperTMS_CO_Manager, ShipperTMS_CO_SuperManager,
        ShipperTMS_CO_CostManager, ShipperTMS_CO_ArchivedDocs, ShipperTMS_Slot_RO, ShipperTMS_Slot_Planner,
        ShipperTMS_Slot_Booker, ShipperTMS_Slot_SuperPlanner, ShipperTMS_Slot_twData,ShipperTMS_Slot_ContentRepository,
        ShipperTMS_DOC_RO, ShipperTMS_DOC_PlantWorker, ShipperTMS_DOC_SuperPlantWorker, ShipperTMS_DOC_LogisticsResponsible,
        ShipperTMS_DOC_LPDispatcher, ShipperTMS_DOC_Trucker, ShipperTMS_DOC_SuperTrucker, ShipperTMS_DOC_Manager,
        ShipperTMS_DOC_SuperManager, ShipperTMS_ROUTE_RO, ShipperTMS_ROUTE_User, ShipperTMS_COST_RO,
        ShipperTMS_COST_User, ShipperTMS_COST_Manager, ShipperTMS_COST_SuperManager, ShipperTMS_COST_Transwide,
        ShipperTMS_FMETRICS_RO, ShipperTMS_FMETRICS_User, 
        
        // WKTSAdmin
        WKTSAdmin_User, WKTSAdmin_SuperUser, WKTSAdmin_Admin, WKTSAdmin_SuperAdmin,
        
        // SpotBidding
        SpotBidding_View, SpotBidding_Full
    }
    
    global enum userStatus
    {
        CREATED, APPROVED, READY, REJECTED, SUSPENDED, BLOCKED, BLOCKED_BY_ADMIN
    }
    
    global enum userType
    {
        SUPERADMIN, ADMIN, USER, SUPERUSER
    }
       
    
    global enum companyState
    {
        CREATED, APPROVED, REJECT, UNPUBLISHED, PUBLISHED, BLACKLISTED
    }
    
    global enum wktsApplicationsEnum
    {
        // business
        WKTSAdmin, ShipperTMS, ShipperTMS_Slot, ShipperTMS_CO, ShipperTMS_DOC, ShipperTMS_ROUTE, ShipperTMS_COST,
        ShipperTMS_FMETRICS, Integration, CarrierTMS, FX, TFC, TPO, TWCost, SpotBidding, TenderMgnt, FMETRICS,
        // internal apps
        OBSS, UARS
    }
    global enum wktsBusinessProductEnum
    {
        WKTSAdmin, ShipperTMS, ShipperTMS_Slot, ShipperTMS_CO, ShipperTMS_MARCO, ShipperTMS_DOC, ShipperTMS_ROUTE, ShipperTMS_COST, ShipperTMS_TWLOAD,
        ShipperTMS_FMETRICS, Integration, CarrierTMS, FX, TFC, TPO, TWCost, SpotBidding, TenderMgnt, FMETRICS
    }
    //=================================================================
    // simple types
    //=================================================================
    global class communicationDetails
    {
        webservice string localNumber { get; set; }
        webservice string prefixNumber { get; set; }
        webservice string countryNumber { get; set; }
    }
    
    global class businessIdentifier
    {
        webservice string id { get; set; }
    }
    
    global class addressLine
    {
        webservice List<string> line { get; set; }
    }
    
    global class dictionary
    {
        webservice List<string> value { get; set; }
        
        global dictionary() { value = new List<string>(); }
    }
    
    global class spokenLanguage
    {
        webservice string language { get; set; }
    }
    
    global class equipment
    {
        webservice dictionary equipment { get; set; }
    }
    
    global class specialization
    {
        webservice dictionary specialization { get; set; }
    }
    
    global class transportMode
    {
        webservice dictionary transportMode { get; set; }
    }
    
    global class address
    {
        // abstractData
        webservice dateTime creationDate { get; set; }
        webservice dateTime modificationDate { get; set; }
        webservice dateTime deletionDate { get; set; }
        // abstractDataEnd
        webservice businessIdentifier businessId { get; set; }
        webservice string homeNumber { get; set; } // number tag
        webservice string streetName { get; set; }
        webservice addressLines addressLines { get; set; }
        webservice string district { get; set; }
        webservice string city { get; set; }
        webservice string state_province { get; set; }
        webservice string postCode { get; set; }
        webservice string country { get; set; }
        webservice locationTypes locationTypes { get; set; }
        webservice string timezone { get; set; }
    } //address
    
    global class socialNetwork
    {
        webservice string userIdentifier { get; set; }
        webservice dictionary networkIdentifier { get; set; }
    }
    
    global class companyDocument
    {
        webservice businessIdentifier businessId { get; set; }
        webservice string name { get; set; }
        webservice string relativeUrl { get; set; }
        webservice dictionary docType { get; set; } // tag name is 'type'
        webservice dateTime expirationDate { get; set; }
    }
    
    global class companyDetails
    {
        webservice integer driversNumber { get; set; }
        webservice integer tractorsNumber { get; set; }
        webservice integer tractorsAverageAge { get; set; }
        webservice integer subcontractTransportPercentNumber { get; set; }
        webservice integer presentCountriesNumber { get; set; }
        webservice integer agenciesNumber { get; set; }
        webservice integer trailersNumber { get; set; }
        webservice integer employeesNumber { get; set; }
        webservice integer trucksEuroNorm { get; set; }
    }
    
    global class tradeLane
    {
        webservice dictionary countryStart { get; set; }
        webservice string cityStart { get; set; }
        webservice string zipCodeStart { get; set; }
        webservice dictionary countryDestination { get; set; }
        webservice string cityDestination { get; set; }
        webservice string zipCodeDestination { get; set; }
        webservice integer days { get; set; }
    }
    
    global class warehouse
    {
        webservice address address { get; set; }
        webservice string contactName { get; set; }
        webservice string email { get; set; }
        webservice facilities facilities { get; set; }
        webservice string name { get; set; }
        webservice communicationDetails phone { get; set; }
        webservice communicationDetails fax { get; set; }
        webservice services services { get; set; }
        webservice storageTypes storageTypes { get; set; }
    }
    
    global class invitedBy
    {
        webservice businessIdentifier byCompany { get; set; }
        webservice wktsBusinessProducts forProducts { get; set; }
    }
    global class facility
    {
        webservice dictionary facility { get; set; }
    }
    global class service
    {
        webservice dictionary service { get; set; }
    }
    global class storageType
    {
        webservice dictionary storageType { get; set; }
    }
    //=================================================================
    // array classes
    //=================================================================
    global class addresses
    {
        webservice List<address> address;
        global addresses() { address = new List<address>(); }
    }
    global class users
    {
        webservice List<ESB_DataClasses.user> user;
        global users() { user = new List<ESB_DataClasses.user>(); }
    }
    global class productsAccesses
    {
        webservice List<String> wktsCompanyProductAccess;
        global productsAccesses() { wktsCompanyProductAccess = new List<String>(); }
    }
    global class companyDocuments
    {
        webservice List<companyDocument> companyDocument;
        global companyDocuments() { companyDocument = new List<companyDocument>(); }
    }
    global class tradeLanes
    {
        webservice List<tradeLane> tradeLane;
        global tradeLanes() { tradeLane = new List<tradeLane>(); }
    }
    global class equipments
    {
        webservice List<equipment> equipment;
        global equipments() { equipment = new List<equipment>(); }
    }
    global class transportModes
    {
        webservice List<transportMode> transportMode;
        global transportModes() { transportMode = new List<transportMode>(); }
    }
    global class specializations
    {
        webservice List<specialization> specialization;
        global specializations() { specialization = new List<specialization>(); }
    }
    global class warehouses
    {
        webservice List<warehouse> warehouse;
        global warehouses() { warehouse = new List<warehouse>(); }
    }
    global class locationTypes
    {
        webservice List<addressLocationTypeEnum> addressLocationType;
        global locationTypes() { addressLocationType = new List<addressLocationTypeEnum>(); }
    }
    global class wktsBusinessProducts
    {
        webservice List<wktsBusinessProductEnum> wktsBusinessProduct;
        global wktsBusinessProducts() { wktsBusinessProduct = new List<wktsBusinessProductEnum>(); }
    }
    global class facilities
    {
        webservice List<facility> facility;
        global facilities() { facility = new List<facility>(); }
    }
    global class services
    {
        webservice List<service> service;
        global services() { service = new List<service>(); }
    }
    global class storageTypes
    {
        webservice List<storageType> storageType;
        global storageTypes() { storageType = new List<storageType>(); }
    }
    global class addressLines
    {
        webservice List<addressLine> addressLine;
        global addressLines() { addressLine = new List<addressLine>(); }
    }
    global class userRoles
    {
        webservice List<string> userRole;
        global userRoles() { userRole = new List<string>(); }
    }
    //=================================================================
    // main instance classes
    //=================================================================
    global class company
    {
        // companyAbstract start 
        // abstractData start
        webservice dateTime creationDate { get; set; }
        webservice dateTime modificationDate { get; set; }
        webservice dateTime deletionDate { get; set; }
        // abstractData End
        webservice businessIdentifier businessId { get; set; }
        webservice addresses addresses { get; set; }
        webservice companyObjectsTypeEnum companyType { get; set; }
        webservice invitedBy invitedBy { get; set; }
        webservice string name { get; set; }
        webservice businessIdentifier parentCompanyBusinessAccount { get; set; }
        webservice string tradeRegistrationNumber { get; set; }
        webservice string transportLicenseNumber { get; set; }
        webservice string vat { get; set; }
        webservice string email { get; set; }
        webservice communicationDetails fax { get; set; }
        webservice communicationDetails phone { get; set; }
        webservice string website { get; set; }
        webservice dateTime customerSince { get; set; }
        webservice businessIdentifier operationalParentCompanyBusinessAccount { get; set; }
        // companyAbstract end
        webservice users users { get; set; }
        webservice productsAccesses productsAccesses { get; set; }
        webservice companyState companyState { get; set; }
        webservice companyDocuments companyDocuments { get; set; }
        webservice companyDetails details { get; set; }
        webservice tradeLanes tradeLanes { get; set; }
        webservice equipments equipments { get; set; }
        webservice specializations specializations { get; set; }
        webservice transportModes transportModes { get; set; }
        webservice warehouses warehouses { get; set; }
    } //company
    
    global class user
    {
        // userShortInfo start
        // abstractData start
        webservice dateTime creationDate { get; set; }
        webservice dateTime modificationDate { get; set; }
        webservice dateTime deletionDate { get; set; }
        // abstractData End
        webservice string firstName { get; set; }
        webservice string lastName { get; set; }
        webservice string login { get; set; }
        webservice userRoles userRoles { get; set; }
        // userShortInfo end
        webservice businessIdentifier businessId { get; set; }
        webservice businessIdentifier companyBusinessAccount { get; set; }
        webservice string email { get; set; }
        webservice communicationDetails mobile { get; set; }
        webservice communicationDetails fax { get; set; }
        webservice communicationDetails phone { get; set; }
        webservice userStatus status { get; set; }
        webservice dictionary userPosition { get; set; }
        webservice userType userType { get; set; }
        webservice dictionary userTitle { get; set; }
        webservice boolean visible { get; set; }
        webservice string preferredLanguage { get; set; }
        webservice string preferredTimezone { get; set; }
        webservice socialNetwork socialNetworks { get; set; }
        webservice List<spokenLanguage> spokenLanguages { get; set; }
    } //user
    
    //=================================================================
    // response classes
    //=================================================================
    global class responseMessage
    {
        webservice string key { get; set; }
        webservice string content { get; set; }
    }
    
    global class responseTracking
    {
        global responseTracking()
        {
            // to avoid null references
            message = new responseMessage();
        }
        
        webservice responseMessage message { get; set; }
        webservice dateTime messageDate { get; set; } // tag name is date
    }
    
    global class responseInfos
    {
        global responseInfos() { info = new List<responseTracking>(); }
        webservice List<responseTracking> info;
    }
    global class responseWarnings
    {
        global responseWarnings() { warning = new List<responseTracking>(); }
        webservice List<responseTracking> warning;
    }
    global class responseErrors
    {
        global responseErrors() { error = new List<responseTracking>(); }
        webservice List<responseTracking> error;
    }
    
    global class response
    {
        global response()
        {
            // to avoid null references
            infos = new responseInfos();
            warnings = new responseWarnings();
            errors = new responseErrors();
        }
        
        webservice responseInfos infos { get; set; }
        webservice responseWarnings warnings { get; set; }
        webservice responseErrors errors { get; set; }
        
        webservice wktsApplicationsEnum applicationId { get; set; }
        webservice string correlationId { get; set; }
    }
    //=================================================================
    // message envelope classes classes
    //=================================================================
    global enum messageType { unknown, document, batch, acknowledgement }
    global enum documentType { unknown, response, request, notification }
    global enum domainType { unknown, cm, freight }
    global enum itemType { unknown, offer, company, user }
    global enum actionType { aCreate, aUpdate, aDelete }
    global enum eventType { eCreate, eUpdate, eDelete, eRegister, eProvision, eUplift }
    
    // main message class
    global class message
    {
        webservice headerType header { get; set; }
        webservice string body { get; set; }
        // below should be attributes, but this is impossible in apex :(
        webservice string id;
        webservice string correlationId;
        webservice string unitOfOrder;
        webservice string ref;
        webservice messageType messageType;
    }
    
    global class headerType
    {
        webservice issuerData issuer;
        webservice exchangeType exchangetype;
        webservice wktsApplicationsEnum origin;
        webservice wktsApplicationsEnum destination;
    }
    global class issuerData
    {
        webservice string issuerType; // tag name 'type'
        webservice string company;
        webservice string user;
        webservice datetime issueTime; // tag name 'time'
    }
    global class exchangeType
    {
        webservice documentType documentType;
        webservice domainType domain;
        webservice itemType item;
        webservice actionType action;
        webservice eventType event;
    }
}