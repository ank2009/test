@isTest
public class TestData
{
    public static ID serviceRT    = null;
    public static ID subserviceRT = null;
    public static ID subsTplRT    = null;
    public static ID subsTplLIRT  = null;
    public static ID servAttrRT   = null;
    public static ID productRT    = null;
    public static ID productLIRT  = null;
    public static ID addonRT      = null;
    public static ID contractRT   = null;
    public static ID subsRT       = null;
    public static ID provServRT   = null;
    public static ID provSART     = null;
    public static ID contactRT    = null;
    public static ID upServRT     = null;
    public static ID upSART       = null;
    public static ID vdliRT       = null;
    public static ID pfliRT       = null;
    public static ID oliRT        = null;
    public static ID oisRT        = null;
    public static ID oppliRT      = null;
    public static ID oppisRT      = null;
    public static ID opppfRT      = null;
    public static ID subsliRT     = null;
    public static ID subsisRT     = null;
    public static ID subspfRT     = null;
    public static ID rtServRT     = null;
    public static ID rtSART       = null;
    public static ID servAttrTplRT   = null;
    public static ID servAttrTplLIRT = null;

    public static ID getServiceRecordType()
    {
        if (serviceRT == null)
            serviceRT = Schema.getGlobalDescribe().get('Service__c').getDescribe().getRecordTypeInfosByName().get('TLR Service').getRecordTypeId();

        return serviceRT;
    }

    public static ID getSubserviceRecordType()
    {
        if (subserviceRT == null)
            subserviceRT = Schema.getGlobalDescribe().get('Subservice__c').getDescribe().getRecordTypeInfosByName().get('TLR Subservice').getRecordTypeId();

        return subserviceRT;
    }

    public static ID getSubsTplRecordType()
    {
        if (subsTplRT == null)
            subsTplRT = Schema.getGlobalDescribe().get('Subservice_Template__c').getDescribe().getRecordTypeInfosByName().get('TLR Subservice Template').getRecordTypeId();

        return subsTplRT;
    }

    public static ID getSubsTplLIRecordType()
    {
        if (subsTplLIRT == null)
            subsTplLIRT = Schema.getGlobalDescribe().get('Subservice_Template_Line_Item__c').getDescribe().getRecordTypeInfosByName().get('TLR Sub-service Template LI').getRecordTypeId();

        return subsTplLIRT;
    }

    public static ID getServAttrRecordType()
    {
        if (servAttrRT == null)
            servAttrRT = Schema.getGlobalDescribe().get('Service_Attribute__c').getDescribe().getRecordTypeInfosByName().get('TLR Service Attribute').getRecordTypeId();

        return servAttrRT;
    }

    public static ID getProductRecordType()
    {
        if (productRT == null)
            productRT = Schema.getGlobalDescribe().get('Product__c').getDescribe().getRecordTypeInfosByName().get('TLR Product').getRecordTypeId();

        return productRT;
    }

    public static ID getProductLIRecordType()
    {
        if (productLIRT == null)
            productLIRT = Schema.getGlobalDescribe().get('Product_Line_Item__c').getDescribe().getRecordTypeInfosByName().get('TLR Product Line Item').getRecordTypeId();

        return productLIRT;
    }

    public static ID getAddOnRecordType()
    {
        if (addonRT == null)
            addonRT = Schema.getGlobalDescribe().get('Add_on_Parent__c').getDescribe().getRecordTypeInfosByName().get('TLR Add-on Parent').getRecordTypeId();

        return addonRT;
    }

    public static ID getContractRecordType()
    {
        if (contractRT == null)
            contractRT = Schema.getGlobalDescribe().get('Contract').getDescribe().getRecordTypeInfosByName().get('TLR Contract').getRecordTypeId();

        return contractRT;
    }

    public static ID getSubsRecordType()
    {
        if (subsRT == null)
            subsRT = Schema.getGlobalDescribe().get('Subscription__c').getDescribe().getRecordTypeInfosByName().get('TLR Subscription').getRecordTypeId();

        return subsRT;
    }

    public static ID getProvServRecordType()
    {
        if (provServRT == null)
            provServRT = Schema.getGlobalDescribe().get('Provisioning_Service__c').getDescribe().getRecordTypeInfosByName().get('TLR Provisioning Service').getRecordTypeId();

        return provServRT;
    }

    public static ID getProvSARecordType()
    {
        if (provSART == null)
            provSART = Schema.getGlobalDescribe().get('Provisioning_Service_Attribute__c').getDescribe().getRecordTypeInfosByName().get('TLR Provisioning Service Attribute').getRecordTypeId();

        return provSART;
    }

    public static ID getContactRecordType()
    {
        if (contactRT == null)
            contactRT = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByName().get('TLR Contact').getRecordTypeId();

        return contactRT;
    }

    public static ID getUpServRecordType()
    {
        if (upServRT == null)
            upServRT = Schema.getGlobalDescribe().get('User_Profile_Service__c').getDescribe().getRecordTypeInfosByName().get('TLR User Profile Service').getRecordTypeId();

        return upServRT;
    }

    public static ID getUpSARecordType()
    {
        if (upSART == null)
            upSART = Schema.getGlobalDescribe().get('User_Profile_Service_Attribute__c').getDescribe().getRecordTypeInfosByName().get('TLR User Profile Service Attribute').getRecordTypeId();

        return upSART;
    }

    public static ID getVdLIRecordType()
    {
        if (vdliRT == null)
            vdliRT = Schema.getGlobalDescribe().get('Volume_Discount_Bracket__c').getDescribe().getRecordTypeInfosByName().get('TLR VD Bracket').getRecordTypeId();

        return vdliRT;
    }

    public static ID getPfLIRecordType()
    {
        if (pfliRT == null)
            pfliRT = Schema.getGlobalDescribe().get('Package_and_Fee_Line_Item__c').getDescribe().getRecordTypeInfosByName().get('TLR P&F Line Item').getRecordTypeId();

        return pfliRT;
    }

    public static ID getOLIRecordType()
    {
        if (oliRT == null)
            oliRT = Schema.getGlobalDescribe().get('Offer_Line_Item__c').getDescribe().getRecordTypeInfosByName().get('Simple Subservice Service').getRecordTypeId();

        return oliRT;
    }

    public static ID getOISRecordType()
    {
        if (oisRT == null)
            oisRT = Schema.getGlobalDescribe().get('Offer_Item_Subservice__c').getDescribe().getRecordTypeInfosByName().get('TLR Offer Item Subservice').getRecordTypeId();

        return oisRT;
    }

    public static ID getOppLIRecordType()
    {
        if (oppliRT == null)
            oppliRT = Schema.getGlobalDescribe().get('Opportunity_Line_Item__c').getDescribe().getRecordTypeInfosByName().get('Opp Simple Subservice Service').getRecordTypeId();

        return oppliRT;
    }

    public static ID getOppISRecordType()
    {
        if (oppisRT == null)
            oppisRT = Schema.getGlobalDescribe().get('Opp_Item_Subservice__c').getDescribe().getRecordTypeInfosByName().get('Opp Simple Subservice').getRecordTypeId();

        return oppisRT;
    }

    public static ID getOppPfRecordType()
    {
        if (opppfRT == null)
            opppfRT = Schema.getGlobalDescribe().get('Opp_Package_And_Fee_Line_Item__c').getDescribe().getRecordTypeInfosByName().get('TLR Opp P&F Line Item').getRecordTypeId();

        return opppfRT;
    }

    public static ID getSubsLIRecordType()
    {
        if (subsliRT == null)
            subsliRT = Schema.getGlobalDescribe().get('Subscription_Line_Item__c').getDescribe().getRecordTypeInfosByName().get('Subs Simple Subservice Service').getRecordTypeId();

        return subsliRT;
    }

    public static ID getSubsISRecordType()
    {
        if (subsisRT == null)
            subsisRT = Schema.getGlobalDescribe().get('Subs_Item_Subservice__c').getDescribe().getRecordTypeInfosByName().get('Subs Simple Subservice').getRecordTypeId();

        return subsisRT;
    }

    public static ID getSubsPfRecordType()
    {
        if (subspfRT == null)
            subspfRT = Schema.getGlobalDescribe().get('Subs_Package_And_Fee_Line_Item__c').getDescribe().getRecordTypeInfosByName().get('TLR Sub P&F Line Item').getRecordTypeId();

        return subspfRT;
    }

    public static ID getRtServRecordType()
    {
        if (rtServRT == null)
            rtServRT = Schema.getGlobalDescribe().get('Rights_Template_Service__c').getDescribe().getRecordTypeInfosByName().get('TLR Rights Template Service').getRecordTypeId();

        return rtServRT;
    }

    public static ID getRtSARecordType()
    {
        if (rtSART == null)
            rtSART = Schema.getGlobalDescribe().get('Rights_Template_Service_Attribute__c').getDescribe().getRecordTypeInfosByName().get('TLR Rights Template Service Attribute').getRecordTypeId();

        return rtSART;
    }

    public static ID getServAttrTplRecordType()
    {
        if (servAttrTplRT == null)
            servAttrTplRT = Schema.getGlobalDescribe().get('Service_Attribute_Template__c').getDescribe().getRecordTypeInfosByName().get('TLR Service Attribute Template').getRecordTypeId();

        return servAttrTplRT;
    }

    public static ID getServAttrTplLIRecordType()
    {
        if (servAttrTplLIRT == null)
            servAttrTplLIRT = Schema.getGlobalDescribe().get('Service_Attribute_Template_Line_Item__c').getDescribe().getRecordTypeInfosByName().get('TLR Service Attribute Template LI').getRecordTypeId();

        return servAttrTplLIRT;
    }






    /**
     * Method createTestService()
     * Creates a single service
     *
     * @author Thomas Penne / Nicolas Dolet
     * @input /
     *
     * @output Created Service
    */
    public static Service__c createTestService()
    {
        Service__c serv      = new Service__c();
        serv.RecordTypeId    = getServiceRecordType();
        serv.Name            = 'Test Service';
        serv.Status__c       = 'Pending';
        serv.Start_Date__c   = Date.Today();
        serv.Access_Roles__c = 'AddressBookConfirm';

        insert serv;

        Subservice__c subservice     = new Subservice__c();
        subservice.RecordTypeId      = getSubserviceRecordType();
        subservice.Name              = 'Test Subservice';
        subservice.Start_Date__c     = Date.Today();
        subservice.Status__c         = 'Pending';
        subservice.Type__c           = 'Standard';
        subservice.Parent_Service__c = serv.Id;

        insert subservice;

        subservice.Status__c = 'Active';
        update subservice;

        Subservice_Template__c subsTpl = new Subservice_Template__c();
        subsTpl.RecordTypeId           = getSubsTplRecordType();
        subsTpl.Name                   = 'Test Subservice Template';
        subsTpl.Parent_Service__c      = serv.Id;
        subsTpl.Start_Date__c          = Date.Today();

        insert subsTpl;

        Subservice_Template_Line_Item__c subsTplLI = new Subservice_Template_Line_Item__c();
        subsTplLI.RecordTypeId                     = getSubsTplLIRecordType();
        subsTplLI.Subservice__c                    = subservice.Id;
        subsTplLI.Template__c                      = subsTpl.Id;

        insert subsTplLI;

        serv.Status__c = 'Active';
        update serv;

        return serv;
    }

    /**
     * Method createTestServices(Integer nbServices)
     * Creates multiple services
     *
     * @author Thomas Penne
     * @input nbServices    Number of services to create
     *
     * @output List of created Services Id
    */
    public static List<ID> createTestServices(Integer nbServices)
    {
        // Pending services
        List<Service__c> servicesToInsert = new List<Service__c>();

        for (Integer s = 0; s < nbServices; s++)
        {
            Service__c serv      = new Service__c();
            serv.RecordTypeId    = getServiceRecordType();
            serv.Name            = 'Test Service';
            serv.Status__c       = 'Pending';
            serv.Start_Date__c   = Date.Today();
            serv.Access_Roles__c = 'AddressBookConfirm';

            servicesToInsert.add(serv);
        }

        if (servicesToInsert.size() > 0)
            insert servicesToInsert;

        // Subservice for each service
        List<Subservice__c> subservicesToInsert = new List<Subservice__c>();

        for (Integer s = 0; s < nbServices; s++)
        {
            Subservice__c subservice = new Subservice__c();
            subservice.RecordTypeId  = getSubserviceRecordType();
            subservice.Name          = 'Test Subservice';
            subservice.Start_Date__c = Date.Today();
            subservice.Status__c     = 'Pending';
            subservice.Type__c       = 'Standard';

            subservicesToInsert.add(subservice);
        }

        if (subservicesToInsert.size() > 0)
            insert subservicesToInsert;

        // Activate all subservices
        for (Subservice__c sub : subservicesToInsert)
            sub.Status__c = 'Active';
        if (subservicesToInsert.size() > 0)
            update subservicesToInsert;

        // Add one subservice template to each service
        List<Subservice_Template__c> subserviceTplsToInsert = new List<Subservice_Template__c>();

        for (Integer s = 0; s < nbServices; s++)
        {
            Subservice_Template__c subsTpl = new Subservice_Template__c();
            subsTpl.RecordTypeId           = getSubsTplRecordType();
            subsTpl.Name                   = 'Test Subservice Template';
            subsTpl.Parent_Service__c      = servicesToInsert[s].Id;
            subsTpl.Start_Date__c          = Date.Today();

            subserviceTplsToInsert.add(subsTpl);
        }

        if (subserviceTplsToInsert.size() > 0)
            insert subserviceTplsToInsert;

        // Add one subservice to each subservice template
        List<Subservice_Template_Line_Item__c> subserviceTplLIsToInsert = new List<Subservice_Template_Line_Item__c>();

        for (Integer s = 0; s < nbServices; s++)
        {
            Subservice_Template_Line_Item__c subsTplLI = new Subservice_Template_Line_Item__c();
            subsTplLI.RecordTypeId                     = getSubsTplLIRecordType();
            subsTplLI.Subservice__c                    = subservicesToInsert[s].Id;
            subsTplLI.Template__c                      = subserviceTplsToInsert[s].Id;

            subserviceTplLIsToInsert.add(subsTplLI);
        }

        if (subserviceTplLIsToInsert.size() > 0)
            insert subserviceTplLIsToInsert;

        // Activate all services
        for (Service__c serv : servicesToInsert)
            serv.Status__c = 'Active';
        if (servicesToInsert.size() > 0)
            update servicesToInsert;

        List<ID> ids = new List<ID>();
        for (Service__c serv : servicesToInsert)
            ids.add(serv.Id);

        return ids;
    }

    /**
     * Method createTestServiceAttribute(ID serviceId)
     * Creates a single service attribute
     *
     * @author Thomas Penne
     * @input  serviceId    Service Id. Service the service attribute must be linked to
     *
     * @output Created Service Attribute
    */
    public static Service_Attribute__c createTestServiceAttribute(ID serviceId)
    {
        Service_Attribute__c servAttr = new Service_Attribute__c();
        servAttr.RecordTypeId         = getServAttrRecordType();
        servAttr.Name                 = 'Test Service Attribute';
        servAttr.Status__c            = 'Pending';
        servAttr.Start_Date__c        = Date.Today();
        servAttr.Parent__c            = serviceId;
        servAttr.Access_Role__c       = 'AddressBookConfirm';

        insert servAttr;

        servAttr.Status__c = 'Active';
        update servAttr;

        return servAttr;
    }

    /**
     * Method createTestServiceAttributes(Map<ID, Integer> services)
     * Creates multiple service attributes
     *
     * @author Thomas Penne
     * @input  services    Map Service Id, Number of Service Attribute(s) for the current service
     *
     * @output Map Service, List of Created Service Attributes Id
    */
    public static Map<ID, List<ID>> createTestServiceAttributes(Map<ID, Integer> services)
    {
        Map<ID, List<ID>> result = new Map<ID, List<ID>>();

        List<Service_Attribute__c> servAttrToInsert = new List<Service_Attribute__c>();

        for (ID id : services.keySet())
        {
            for (Integer s = 0; s < services.get(id); s++)
            {
                Service_Attribute__c servAttr = new Service_Attribute__c();
                servAttr.RecordTypeId         = getServAttrRecordType();
                servAttr.Name                 = 'Test Service Attribute';
                servAttr.Status__c            = 'Pending';
                servAttr.Start_Date__c        = Date.Today();
                servAttr.Parent__c            = id;
                servAttr.Access_Role__c       = 'AddressBookConfirm';

                servAttrToInsert.add(servAttr);
            }

            result.put(id, new List<ID>());
        }

        if (servAttrToInsert.size() > 0)
            insert servAttrToInsert;

        // Activate service atributes
        for (Service_Attribute__c servAttr : servAttrToInsert)
            servAttr.Status__c = 'Active';
        if (servAttrToInsert.size() > 0)
            update servAttrToInsert;

        for (Service_Attribute__c servAttr : servAttrToInsert)
            result.get(servAttr.Parent__c).add(servAttr.Id);

        return result;
    }

    /**
     * Method createTestProductAndLineItems(List<ID> services)
     * Creates a product and multiple product line items
     *
     * @author Thomas Penne
     * @input  services    List of services Id. Services to be included in the product
     * @input  addon       Indicates if Product must be an add-on
     * @input  active      Indicates if Product must be active
     *
     * @output Created Product
    */
    public static Product__c createTestProductAndLineItems(List<ID> services, Boolean addon, Boolean active)
    {
        Product__c prod      = new Product__c();
        prod.RecordTypeId    = getProductRecordType();
        prod.Name            = 'Test Product';
        prod.Access_Kind__c  = 'WEB3N';
        prod.Access_Roles__c = 'T_ACTIVE';
        prod.Start_Date__c   = Date.Today();
        prod.Status__c       = 'Pending';
        prod.Add_on__c       = addon;

        insert prod;

        List<Product_Line_Item__c> pliToInsert = new List<Product_Line_Item__c>();

        for (ID id : services)
        {
            Product_Line_Item__c prodLI = new Product_Line_Item__c();
            prodLI.RecordTypeId         = getProductLIRecordType();
            prodLI.Parent__c            = prod.Id;
            prodLI.Service__c           = id;

            pliToInsert.add(prodLI);
        }

        if (pliToInsert.size() > 0)
            insert pliToInsert;

        if (active)
        {
            prod.Status__c = 'Pending Activation Approval';
            update prod;
            prod.Status__c = 'Active';
            update prod;
        }

        return prod;
    }

    /**
     * Method createTestAddOnParent(ID addOnId, ID productId)
     * Creates a single Add-On Parent
     *
     * @author Thomas Penne
     * @input  addOnId      Product Id. Addon to be linked
     * @input  productId    Product Id. Product Addon must be linked to
     *
     * @output Created Add-On Parent
    */
    public static Add_on_Parent__c createTestAddOnParent(ID addOnId, ID productId)
    {
        Add_on_Parent__c aoParent = new Add_on_Parent__c();
        aoParent.RecordTypeId     = getAddOnRecordType();
        aoParent.Add_on__c        = addOnId;
        aoParent.Product__c       = productId;

        insert aoParent;

        return aoParent;
    }

    /**
     * Method createTestContract(ID accountId)
     * Creates a single contract
     *
     * @author Thomas Penne
     * @input  accountId    Account Id. Account contract must be linked to
     *
     * @output Created Contract
    */
    public static Contract createTestContract(ID accountId)
    {
        Contract con     = new Contract();
        con.RecordTypeId = getContractRecordType();
        con.Name         = 'Test Contract';
        con.AccountId    = accountId;

        insert con;

        return con;
    }

    /**
     * Method createTestSubscription(ID prodId, ID contractId)
     * Creates a single subscription
     *
     * @author Thomas Penne
     * @input  prodId        Product Id.  Product subscription must be linked to
     * @input  contractId    Contract Id. Contract subscription must be linked to
     *
     * @output Created Subscription
    */
    public static Subscription__c createTestSubscription(ID prodId, ID contractId)
    {
        Subscription__c sub = new Subscription__c();
        sub.RecordTypeId    = getSubsRecordType();
        sub.Start_Date__c   = Date.Today();
        sub.End_Date__c     = Date.Today().addMonths(2);
        sub.Access_Kind__c  = 'WEB3N';
        sub.Product__c      = prodId;
        sub.Name            = 'Test Subscription';
        sub.Contract__c     = contractId;
        sub.Price_List_Code__c ='Offer Template Test';
        sub.CUG_allowed__c  = true;

        insert sub;

        return sub;
    }

    /**
     * Method createTestSubscriptionUsers(ID subsId, List<ID> contacts)
     * Creates multiple subscription users
     *
     * @author Thomas Penne
     * @input  subsId        Subscription Id.  Subscription subscription users must be linked to
     * @input  contacts      List of Contacts Id. Contacts subscription users must be linked to
     *
     * @output List of created Subscription Users Id
    */
    public static List<ID> createTestSubscriptionUsers(ID subsId, List<ID> contacts)
    {
        List<Subscription_User__c> usersToInsert = new List<Subscription_User__c>();

        for (ID id : contacts)
        {
            Subscription_User__c subUser = new Subscription_User__c();
            subUser.Contact__c           = id;
            subUser.Subscription__c      = subsId;

            usersToInsert.add(subUser);
        }

        if (usersToInsert.size() > 0)
            insert usersToInsert;

        List<ID> result = new List<ID>();
        for (Subscription_User__c u : usersToInsert)
            result.add(u.Id);

        return result;
    }

    /**
     * Method createTestProvisioningAndServices(ID subsId, Id contractId, ID accountId)
     * Creates a single provisioning
     *
     * @author Thomas Penne
     * @input  subsId        Subscription Id.  Subscription provisioning must be linked to
     * @input  contractId    Contract Id.      Parent Contract of subsId subscription
     * @input  accountId     Account Id.       Parent Account of contractId contract
     *
     * @output Created Provisioning
    */
    public static Provisioning__c createTestProvisioningAndServices(ID subsId, Id contractId, ID accountId)
    {
        Provisioning__c prov = new Provisioning__c();
        prov.RecordTypeId    = Schema.getGlobalDescribe().get('Provisioning__c').getDescribe().getRecordTypeInfosByName().get('TLR Provisioning').getRecordTypeId();
        prov.Name            = 'Test Provisioning';
        prov.Account__c      = accountId;
        prov.Contract__c     = contractId;
        prov.Subscription__c = subsId;
        prov.Provisioning_Error__c = '';

        insert prov;

        return prov;
    }

    /**
     * Method createTestProvisioningHierarchy(ID provId, Map<ID, List<ID>> services)
     * Creates multiple provisioning services/provisioning service attributes under a given provisioning
     *
     * @author Thomas Penne
     * @input  provId        Provisioning Id.  Provisioning children must be linked to
     * @input  services      Map services Id, List of service attributes Id. Services and service attributes provisioning must contain
     *
     * @output Map Created Provisioning Services Id, List of created Provisioning Service Attributes Id
    */
    public static Map<ID, List<Id>> createTestProvisioningHierarchy(ID provId, Map<ID, List<ID>> services)
    {
        Map<ID, List<ID>> result = new Map<ID, List<ID>>();

        Map<ID, ID> mappingMap = new Map<ID, ID>();
        List<Provisioning_Service__c>           provServToInsert     = new List<Provisioning_Service__c>();
        List<Provisioning_Service_Attribute__c> provServAttrToInsert = new List<Provisioning_Service_Attribute__c>();

        for (ID id : services.KeySet())
        {
            Provisioning_Service__c provServ = new Provisioning_Service__c();
            provServ.RecordTypeId            = getProvServRecordType();
            provServ.Provisioning__c         = provId;
            provServ.Service__c              = id;

            provServToInsert.add(provServ);
        }

        if (provServToInsert.size() > 0)
            insert provServToInsert;

        for (Provisioning_Service__c ps : provServToInsert)
        {
            mappingMap.put(ps.Service__c, ps.Id);
            result.put(ps.Id, new List<ID>());
        }

        for (ID id : services.KeySet())
        {
            for (ID idsa : services.get(id))
            {
                Provisioning_Service_Attribute__c provServAttr = new Provisioning_Service_Attribute__c();
                provServAttr.RecordTypeId                      = getProvSARecordType();
                provServAttr.Provisioning_Service__c           = mappingMap.get(id);
                provServAttr.Service_Attribute__c              = idsa;

                provServAttrToInsert.add(provServAttr);
            }
        }

        if (provServAttrToInsert.size() > 0)
            insert provServAttrToInsert;

        for (Provisioning_Service_Attribute__c psa : provServAttrToInsert)
            result.get(psa.Provisioning_Service__c).add(psa.Id);

        return result;
    }

    /**
     * Method createTestAccounts()
     * Creates a single account
     *
     * @author Thomas Penne
     * @input  /
     *
     * @output Created Account
    */
    public static Account createTestAccounts()
    {
    	Account accnt = new Account();
        accnt.Phone                     = '+99 12345678';
        accnt.ParentId                  = null;
        accnt.Name                      = 'Test Account';
        accnt.Fax                       = '+99 12345678';
        accnt.Activation_Date__c        = Datetime.now();
        accnt.Deactivation_Date__c      = null;
        accnt.BillingStreet             = 'Rue de la pointe';
        accnt.BillingState              = 'Nord';
        accnt.BillingCountry            = 'Belgium';
        accnt.Organization_Country__c   = accnt.BillingCountry;
        accnt.BillingPostalCode         = '59113';
        accnt.BillingCity               = 'Seclin';
        accnt.Account_Level__c          = 'Site';
        accnt.Level_of_Certification__c = '2';
        accnt.Bank_Code_FR__c			= '16807';
        
        accnt.Payment_Terms__c			= 45;
        accnt.Cashier_Code_FR__c	    = '00026';
        accnt.Bank_Number__c		    = '31421756218';
        accnt.RIB_Key_FR__c				= '76';
        accnt.BIC_Code__c				= 'AAAAAA12123';
        accnt.AccountNumber 			= '1231123';
        accnt.Teleroute_Number__c 		= '1231231123';
        insert accnt;

        return accnt;
    }

    /**
     * Method createTestContact(ID accountId)
     * Creates a single contact
     *
     * @author Thomas Penne
     * @input  accountId     Account Id. Account contact must be linked to
     *
     * @output Created Contact
    */
    public static Contact createTestContact(ID accountId)
    {
        Contact con            = new Contact();
        con.RecordTypeId       = getContactRecordType();
        con.Gender__c          = 'Male';
        con.Salutation         = 'Mr.';
        con.Phone              = '+99 12345678';
        con.MobilePhone        = '+99 12345678';
        con.MailingStreet      = 'Rue d\'Arras';
        con.MailingState       = 'Nord';
        con.MailingPostalCode  = '59000';
        con.AccountId          = accountId;
        con.MailingCountry     = 'France';
        con.MailingCity        = 'Lille';
        con.LastName           = 'Contact';
        con.Language__c        = 'French';
        con.FirstName          = 'Test';
        con.Fax                = '+99 12345678';
        con.Email              = 'test@test.com';
        con.Job_Profile__c     = 'Architect';

        insert con;

        return con;
    }

    /**
     * Method createTestContacts(ID accountId, Integer nbContacts)
     * Creates multiple contacts
     *
     * @author Thomas Penne
     * @input  accountId     Account Id. Account contact must be linked to
     * @input  nbContacts    Number of contacts to be created
     *
     * @output List of created Contacts Id
    */
    public static List<ID> createTestContacts(ID accountId, Integer nbContacts)
    {
        List<Contact> contactsToInsert = new List<Contact>();

        for (Integer c = 0; c < nbContacts; c++)
        {
            Contact con            = new Contact();
            con.RecordTypeId       = getContactRecordType();
            con.Gender__c          = 'Male';
            con.Salutation         = 'Mr.';
            con.Phone              = '+99 12345678';
            con.MobilePhone        = '+99 12345678';
            con.MailingStreet      = 'Rue d\'Arras';
            con.MailingState       = 'Nord';
            con.MailingPostalCode  = '59000';
            con.AccountId          = accountId;
            con.MailingCountry     = 'France';
            con.MailingCity        = 'Lille';
            con.LastName           = 'Contact';
            con.Language__c        = 'French';
            con.FirstName          = 'Test';
            con.Fax                = '+99 12345678';
            con.Email              = 'test@test.com';
            con.Job_Profile__c     = 'Architect';

            contactsToInsert.add(con);
        }

        if (contactsToInsert.size() > 0)
            insert contactsToInsert;

        List<ID> result = new List<ID>();
        for (Contact con : contactsToInsert)
            result.add(con.Id);

        return result;
    }

    /**
     * Method createTestUserProfile(ID contactId, ID provId, Map<ID, List<ID>> provServices)
     * Creates a single user profile and multiple user profile services/user profile service attributes
     *
     * @author Thomas Penne
     * @input  contactId        Contact Id. Contact user profile must be linked to
     * @input  provId           Provisioning Id. Provisioning user profile must be linked to
     * @input  provServices     Map provisioning services Id, List of provisioning service attributes Id. Services and service attributes user profile must contain
     *
     * @output Created User Profile
    */
    public static User_Profile__c createTestUserProfile(ID contactId, ID provId, Map<ID, List<ID>> provServices)
    {
        User_Profile__c up = new User_Profile__c();
        up.RecordTypeId    = Schema.getGlobalDescribe().get('User_Profile__c').getDescribe().getRecordTypeInfosByName().get('TLR User Profile').getRecordTypeId();
        up.Private_Exchange_ID__c = 'OPEN';
        up.Contact__c             = contactId;
        up.Test_login__c          = false;
        up.User_PUG_Name__c       = 'FCUGABPSTD';
        up.Provisioning__c        = provId;
        up.Status__c              = 'Activated';

        insert up;

        Map<ID, ID> mappingMap = new Map<ID, ID>();
        List<User_Profile_Service__c>           upServToInsert     = new List<User_Profile_Service__c>();
        List<User_Profile_Service_Attribute__c> upServAttrToInsert = new List<User_Profile_Service_Attribute__c>();

        for (ID id : provServices.KeySet())
        {
            User_Profile_Service__c upServ = new User_Profile_Service__c();
            upServ.RecordTypeId            = getUpServRecordType();
            upServ.Provisioning_Service__c = id;
            upServ.User_Profile__c         = up.id;

            upServToInsert.add(upServ);
        }

        if (upServToInsert.size() > 0)
            insert upServToInsert;

        for (User_Profile_Service__c ups : upServToInsert)
            mappingMap.put(ups.Provisioning_Service__c, ups.Id);

        for (ID id : provServices.KeySet())
        {
            for (ID idpsa : provServices.get(id))
            {
                User_Profile_Service_Attribute__c upServAttr = new User_Profile_Service_Attribute__c();
                upServAttr.RecordTypeId                      = getUpSARecordType();
                upServAttr.Provisioning_Service_Attribute__c = idpsa;
                upServAttr.User_Profile_Service__c           = mappingMap.get(id);

                upServAttrToInsert.add(upServAttr);
            }
        }

        if (upServAttrToInsert.size() > 0)
            insert upServAttrToInsert;

        return up;
    }

    /**
     * Method createTestUserProfiles(List<ID> contacts, ID provId, Map<ID, List<ID>> provServices)
     * Creates mutiple user profiles and multiple user profile services/user profile service attributes
     *
     * @author Thomas Penne
     * @input  contacts         List of Contacts Id. Contacts user profiles must be linked to
     * @input  provId           Provisioning Id. Provisioning user profiles must be linked to
     * @input  provServices     Map provisioning services Id, List of provisioning service attributes Id. Services and service attributes user profiles must contain
     *
     * @output List of Created User Profiles Id
    */
    public static List<ID> createTestUserProfiles(List<ID> contacts, ID provId, Map<ID, List<ID>> provServices)
    {
        List<User_Profile__c> upToInsert = new List<User_Profile__c>();

        for (ID id : contacts)
        {
            User_Profile__c up = new User_Profile__c();
            up.RecordTypeId    = Schema.getGlobalDescribe().get('User_Profile__c').getDescribe().getRecordTypeInfosByName().get('TLR User Profile').getRecordTypeId();
            up.Private_Exchange_ID__c = 'OPEN';
            up.Contact__c             = id;
            up.Test_login__c          = false;
            up.User_PUG_Name__c       = 'FCUGABPSTD';
            up.Provisioning__c        = provId;
            up.Status__c              = 'Activated';

            upToInsert.add(up);
        }

        if (upToInsert.size() > 0)
            insert upToInsert;

        Map<String, ID> mappingMap = new Map<String, ID>();
        List<User_Profile_Service__c>           upServToInsert     = new List<User_Profile_Service__c>();
        List<User_Profile_Service_Attribute__c> upServAttrToInsert = new List<User_Profile_Service_Attribute__c>();

        for (User_Profile__c up : upToInsert)
        {
            for (ID id : provServices.KeySet())
            {
                User_Profile_Service__c upServ = new User_Profile_Service__c();
                upServ.RecordTypeId            = getUpServRecordType();
                upServ.Provisioning_Service__c = id;
                upServ.User_Profile__c         = up.Id;
                upServ.Provisioning_Status__c  = 'Activated';

                upServToInsert.add(upServ);
            }
        }

        if (upServToInsert.size() > 0)
            insert upServToInsert;

        for (User_Profile_Service__c ups : upServToInsert)
            mappingMap.put(ups.User_Profile__c + '-' + ups.Provisioning_Service__c, ups.Id);

        for (User_Profile__c up : upToInsert)
        {
            for (ID id : provServices.KeySet())
            {
                for (ID idpsa : provServices.get(id))
                {
                    User_Profile_Service_Attribute__c upServAttr = new User_Profile_Service_Attribute__c();
                    upServAttr.RecordTypeId                      = getUpSARecordType();
                    upServAttr.Provisioning_Service_Attribute__c = idpsa;
                    upServAttr.User_Profile_Service__c           = mappingMap.get(up.Id + '-' + id);
                    upServAttr.Provisioning_Status__c            = 'Activated';

                    upServAttrToInsert.add(upServAttr);
                }
            }
        }

        if (upServAttrToInsert.size() > 0)
            insert upServAttrToInsert;

        List<ID> result = new List<ID>();
        for (User_Profile__c up : upToInsert)
            result.add(up.Id);

        return result;
    }

    /**
     * Method createVolumeDiscountWithBrackets(Integer nbBrackets)
     * Creates a single volume discount with nbBrackets brackets
     *
     * @author Thomas Penne
     * @input  nbBrackets    Number of brackets to create
     * @input  active        Indicates if volume discount must be activated
     *
     * @output Created Volume Discount
    */
    public static Volume_Discount__c createVolumeDiscountWithBrackets(Integer nbBrackets, Boolean active)
    {
        Volume_Discount__c result = new Volume_Discount__c();
        result.RecordTypeId       = Schema.getGlobalDescribe().get('Volume_Discount__c').getDescribe().getRecordTypeInfosByName().get('TLR Volume Discount').getRecordTypeId();
        result.Name               = 'Test Volume Discount';
        result.Discount_Type__c   = 'Simple';
        result.Start_Date__c      = Date.today();

        insert result;

        List<Volume_Discount_Bracket__c> vdbToInsert = new List<Volume_Discount_Bracket__c>();

        for (Integer i = 0; i < nbBrackets; i++)
        {
            Volume_Discount_Bracket__c vdb = new Volume_Discount_Bracket__c();
            vdb.RecordTypeId               = getVdLIRecordType();
            vdb.Name                       = 'Bracket ' + i.format();
            vdb.Volume_Discount__c         = result.Id;
            vdb.Min_Value__c               = 1 + 10 * i;
            vdb.Max_Value__c               = vdb.Min_Value__c + 10;

            vdbToInsert.add(vdb);
        }

        if (vdbToInsert.size() > 0)
            insert vdbToInsert;

        if (active)
        {
            result.Status__c = 'Active';
            update result;
        }

        return result;
    }

    /**
     * Method createPackageAndFeeWithLineItems(List<ID> services, Boolean active)
     * Creates a single package and fee with line items linked to all services in services list
     *
     * @author Thomas Penne
     * @input  services    Services to add as line items
     * @input  active      Indicates if package and fee must be activated
     *
     * @output Created Package and fee
    */
    public static PackFee__c createPackageAndFeeWithLineItems(List<ID> services, Boolean active)
    {
        PackFee__c result                 = new PackFee__c();
        result.RecordTypeId               = Schema.getGlobalDescribe().get('PackFee__c').getDescribe().getRecordTypeInfosByName().get('TLR PackFee').getRecordTypeId();
        result.Name                       = 'Test Package And Fee';
        result.Default_Overusage_Price__c = 0;
        result.Default_Price__c           = 0;
        result.Level__c                   = 'Service(s)';
        result.Start_Date__c              = Date.Today();

        insert result;

        List<Package_and_Fee_Line_Item__c> pfliToInsert = new List<Package_and_Fee_Line_Item__c>();

        for (ID id : services)
        {
            Package_and_Fee_Line_Item__c pfli = new Package_and_Fee_Line_Item__c();
            pfli.RecordTypeId                 = getPfLIRecordType();
            pfli.Parent__c                    = result.Id;
            pfli.Service__c                   = id;
            pfli.Weight__c                    = 1;

            pfliToInsert.add(pfli);
        }

        if (pfliToInsert.size() > 0)
            insert pfliToInsert;

        if (active)
        {
            result.Status__c = 'Active';
            update result;
        }

        return result;
    }

    /**
     * Method createPromotionWithLineItems(Integer nbLI)
     * Creates a single promotion with nbLI line Items
     *
     * @author Thomas Penne
     * @input  nbLI     Number of line items to create
     * @input  active   Indicates if promotion must be activated
     *
     * @output Created Promotion
    */
    public static Promotion__c createPromotionWithLineItems(Integer nbLI, Boolean active)
    {
        Promotion__c result  = new Promotion__c();
        result.RecordTypeId  = Schema.getGlobalDescribe().get('Promotion__c').getDescribe().getRecordTypeInfosByName().get('TLR Promotion').getRecordTypeId();
        result.Name          = 'Test Promotion';
        result.Start_Date__c = Date.today();

        insert result;

        List<Promotion_Line_Item__c> pliToInsert = new List<Promotion_Line_Item__c>();

        for (Integer i = 0; i < nbLI; i++)
        {
            Promotion_Line_Item__c pli = new Promotion_Line_Item__c();
            pli.Name                   = 'Line Item ' + i.format();
            pli.Promotion__c           = result.Id;
            pli.Min_Duration__c        = i;
            pli.Max_Duration__c        = i + 1;
            pli.Sort_Order__c          = i + 1;

            pliToInsert.add(pli);
        }

        if (pliToInsert.size() > 0)
            insert pliToInsert;

        if (active)
        {
            result.Status__c = 'Active';
            update result;
        }

        return result;
    }

    /**
     * Method createTestOfferTemplateHierarchy(ID otId, List<ID> services)
     * Creates multiple offer line items/offer item subservices under a given offer template
     *
     * @author Thomas Penne
     * @input  otId         Offer Template Id.  Offer Template children must be linked to
     * @input  services     List of services Id. Services offer template must contain
     *
     * @output List of created Offer Line Items Id
    */
    public static List<Offer_Line_Item__c> createTestOfferTemplateHierarchy(ID otId, List<ID> services)
    {
        Map<ID, Service__c> mapServices = new Map<ID, Service__c>([SELECT Id, Name, Billable_Service__c,
                                                                  (SELECT Id, Name
                                                                   FROM Subservices__r)
                                                                   FROM Service__c
                                                                   WHERE Id IN :services]);

        Map<ID, ID> mappingMap = new Map<ID, ID>();
        List<Offer_Line_Item__c>       oLIToInsert = new List<Offer_Line_Item__c>();
        List<Offer_Item_Subservice__c> oISToInsert = new List<Offer_Item_Subservice__c>();

        for (Service__c s : mapServices.Values())
        {
            Offer_Line_Item__c oLI  = new Offer_Line_Item__c();
            oLI.RecordTypeId        = getOLIRecordType();
            oLI.Name                = s.Name;
            oLI.Billable_Service__c = true;
            oLI.Offer_Template__c   = otId;
            oLI.Service__c          = s.Id;

            oLIToInsert.add(oLI);
        }

        if (oLIToInsert.size() > 0)
            insert oLIToInsert;

        for (Offer_Line_Item__c oLI : oLIToInsert)
            mappingMap.put(oLI.Service__c, oLI.Id);

        for (Service__c s : mapServices.Values())
        {
            for (Subservice__c sub : s.Subservices__r)
            {
                Offer_Item_Subservice__c oIS = new Offer_Item_Subservice__c();
                oIS.RecordTypeId             = getOISRecordType();
                oIS.Name                     = sub.Name;
                oIS.Min_Price__c             = 0;
                oIS.Max_Price__c             = 0;
                oIS.Offer_Line_Item__c       = mappingMap.get(s.Id);
                oIS.Subservice__c            = sub.Id;

                oISToInsert.add(oIS);
            }
        }

        if (oISToInsert.size() > 0)
            insert oISToInsert;

        return oLIToInsert;
    }

    /**
     * Method createTestOfferItemSubVDLineItems(ID oISId, ID vdId)
     * Add a volume discount to an offer item subservice (creates multiple offer item sub vd line items)
     *
     * @author Thomas Penne
     * @input  oIS      Offer Item Subservice. Offer Item Subservice volume discount must be added to
     * @input  vdId     Volume Discount Id. Volume discount to be added
     *
     * @output List of created Offer Item Sub VD Line Items Id
    */
    public static List<Offer_Item_Sub_VD_Line_Item__c> createOfferItemSubVDLI(Offer_Item_Subservice__c oIS, ID vdId)
    {
        oIS.Subservice_Volume_Discount__c = vdId;
        update oIS;

        List<Offer_Item_Sub_VD_Line_Item__c> result = [SELECT Id, Name, Min_Price__c, Max_Price__c,
                                                              Volume_Discount_Bracket__c
                                                       FROM Offer_Item_Sub_VD_Line_Item__c
                                                       WHERE Offer_Item_Subservice__c = :oIS.Id];

        return result;
    }

    /**
     * Method createOfferPackageAndFeeAndLineItems(ID otId, ID packFeeId)
     * Creates an offer package and fee (+ children) based on a package and fee
     *
     * @author Thomas Penne
     * @input  otId         Offer Template Id. Offer Template offer package and fee must be linked to
     * @input  packFeeId    Package and Fee Id. Package and Fee offer package and fee must be linked to
     *
     * @output Created Offer Package and Fee
    */
    public static Offer_Package_And_Fee__c createOfferPackageAndFeeAndLineItems(ID otId, ID packFeeId)
    {
        System.Debug('## createOfferPackageAndFeeAndLineItems begin');

        PackFee__c packFee = [SELECT Id, Name, Default_Overusage_Price__c, Default_Price__c,
                             (SELECT Id, Service__c, Weight__c
                              FROM Package_and_Fee_Line_Items__r)
                              FROM PackFee__c
                              WHERE Id = :packFeeId
                              LIMIT 1];

        Offer_Package_And_Fee__c result = new Offer_Package_And_Fee__c();
        result.RecordTypeId             = Schema.getGlobalDescribe().get('Offer_Package_And_Fee__c').getDescribe().getRecordTypeInfosByName().get('TLR Offer PackFee').getRecordTypeId();
        result.Name                     = packFee.Name;
        result.Offer_Template__c        = otId;
        result.Overusage_Price__c       = packFee.Default_Overusage_Price__c;
        result.Default_Price__c         = packFee.Default_Price__c;
        result.Max_Overusage_Price__c   = packFee.Default_Overusage_Price__c;
        result.Min_Overusage_Price__c   = packFee.Default_Overusage_Price__c;
        result.Max_Price__c             = packFee.Default_Price__c;
        result.Min_Price__c             = packFee.Default_Price__c;
        result.Package_Fee__c           = packFee.Id;

        insert result;

        /*System.Debug('## packFee.Package_and_Fee_Line_Items__r :' + packFee.Package_and_Fee_Line_Items__r.size());

        List<Offer_Package_And_Fee_Line_Item__c> opfliToInsert = new List<Offer_Package_And_Fee_Line_Item__c>();

        for (Package_and_Fee_Line_Item__c pfli : packFee.Package_and_Fee_Line_Items__r)
        {
            Offer_Package_And_Fee_Line_Item__c opfli = new Offer_Package_And_Fee_Line_Item__c();
            opfli.Offer_Package_And_Fee__c           = result.Id;
            opfli.PackFee__c                         = result.Id;
            opfli.PackFee_Line_Item__c               = pfli.Id;
            opfli.Weight__c                          = pfli.Weight__c;
            opfli.Service__c                         = pfli.Service__c;

            opfliToInsert.add(opfli);
        }

        if (opfliToInsert.size() > 0)
            insert opfliToInsert;*/

        System.Debug('## createOfferPackageAndFeeAndLineItems end');

        return result;
    }

    /**
     * Method createOfferPromoWithLineItemsAndLinks(ID otId, ID promoId, List<ID> offerPackFeeIds)
     * Creates an offer promotion (+ children) based on a promotion
     *
     * @author Thomas Penne
     * @input  otId             Offer Template Id. Offer Template offer promotion must be linked to
     * @input  promoId          Promotion Id. Promotion offer promotion must be linked to
     * @input  offerPackFeeIds  List of offer package and fee ids to link offer promotion to
     *
     * @output Created Offer Promotion
    */
    public static Offer_Promo__c createOfferPromoWithLineItemsAndLinks(ID otId, ID promoId, List<ID> offerPackFeeIds)
    {
        Promotion__c promo = [SELECT Id, Name,
                             (SELECT Id, Duration_Type__c, Max_Duration__c, Min_Duration__c
                              FROM Promotion_Line_Items__r)
                              FROM Promotion__c
                              WHERE Id = :promoId
                              LIMIT 1];

        Offer_Promo__c result    = new Offer_Promo__c();
        result.Name              = promo.Name;
        result.Level__c          = 'Package(s)/Fee(s)';
        result.Offer_Template__c = otId;
        result.Promotion__c      = promo.Id;

        insert result;

        /*List<Offer_Promo_Line_Item__c> opliToInsert = new List<Offer_Promo_Line_Item__c>();

        for (Promotion_Line_Item__c pli : promo.Promotion_Line_Items__r)
        {
            Offer_Promo_Line_Item__c opli = new Offer_Promo_Line_Item__c();
            opli.Max_Duration__c          = pli.Max_Duration__c;
            opli.Min_Duration__c          = pli.Min_Duration__c;
            opli.Max_Price__c             = 0;
            opli.Min_Price__c             = 0;
            opli.Offer_Promotion__c       = result.Id;
            opli.Promotion_Line_Item__c   = pli.Id;

            opliToInsert.add(opli);
        }

        if (opliToInsert.size() > 0)
            insert opliToInsert;*/

        List<Offer_Promo_Link__c> oplToInsert = new List<Offer_Promo_Link__c>();

        for (ID id : offerPackFeeIds)
        {
            Offer_Promo_Link__c opl      = new Offer_Promo_Link__c();
            opl.Offer_Package_And_Fee__c = id;
            opl.Offer_Promotion__c       = result.Id;

            oplToInsert.add(opl);
        }

        if (oplToInsert.size() > 0)
            insert oplToInsert;

        return result;
    }

    /**
     * Method createTestOpportunityHierarchy(ID oppId, List<ID> offerLineItems)
     * Creates multiple opportunity line items/opportunity item subservices under a given opportunity
     *
     * @author Thomas Penne
     * @input  oppId            Opportunity Id.  Opportunity children must be linked to
     * @input  offerLineItems   List of offer line items Id. Offer Line Items opportunity line items must be linked to
     *
     * @output List of created Opportunity Line Items
    */
    public static List<Opportunity_Line_Item__c> createTestOpportunityHierarchy(ID oppId, List<ID> offerLineItems)
    {
        Map<ID, Offer_Line_Item__c> mapOfferLIs = new Map<ID, Offer_Line_Item__c>([SELECT Id, Name, Service__c,
                                                                                          Service_Attribute_Template__c,
                                                                                  (SELECT Id, Name, Subservice__c,
                                                                                          Subservice_Volume_Discount__c
                                                                                   FROM Offer_Item_Subservices__r)
                                                                                   FROM Offer_Line_Item__c
                                                                                   WHERE Id IN :offerLineItems]);

        Map<ID, ID> mappingMap = new Map<ID, ID>();
        List<Opportunity_Line_Item__c> oppLIToInsert = new List<Opportunity_Line_Item__c>();
        List<Opp_Item_Subservice__c>   oppISToInsert = new List<Opp_Item_Subservice__c>();

        for (Offer_Line_Item__c oli : mapOfferLIs.Values())
        {
            Opportunity_Line_Item__c oppLI      = new Opportunity_Line_Item__c();
            oppLI.RecordTypeId                  = getOppLIRecordType();
            oppLI.Name                          = oli.Name;
            oppLI.Offer_Line_Item__c            = oli.Id;
            oppLI.Opportunity__c                = oppId;
            oppLI.Service__c                    = oli.Service__c;
            oppLI.Service_Attribute_Template__c = oli.Service_Attribute_Template__c;

            oppLIToInsert.add(oppLI);
        }

        if (oppLIToInsert.size() > 0)
            insert oppLIToInsert;

        for (Opportunity_Line_Item__c oppLI : oppLIToInsert)
            mappingMap.put(oppLI.Offer_Line_Item__c, oppLI.Id);

        for (Offer_Line_Item__c oli : mapOfferLIs.Values())
        {
            for (Offer_Item_Subservice__c ois : oli.Offer_Item_Subservices__r)
            {
                Opp_Item_Subservice__c oppIS        = new Opp_Item_Subservice__c();
                oppIS.RecordTypeId                  = getOppISRecordType();
                oppIS.Name                          = ois.Name;
                oppIS.Offer_Item_Subservice__c      = ois.Id;
                oppIS.Opportunity_Line_Item__c      = mappingMap.get(oli.Id);
                oppIS.Subservice__c                 = ois.Subservice__c;
                oppIS.Estimated_Quantity__c         = 0;
                oppIS.Sales_Price__c                = 0;
                oppIS.Subservice_Volume_Discount__c = ois.Subservice_Volume_Discount__c;

                oppISToInsert.add(oppIS);
            }
        }

        if (oppISToInsert.size() > 0)
            insert oppISToInsert;

        return oppLIToInsert;
    }

    /**
     * Method createOppItemSubVDLI(ID oisId, List<ID> oisvdliIds)
     * Creates multiple opportunity item sub vd line items under a given opportunity item subservice
     *
     * @author Thomas Penne
     * @input  oisId        Opportunity Item Subservice Id.  Opportunity item subservice children must be linked to
     * @input  oisvdliIds   List of offer item sub vd line items Id. Offer item sub vd line items opportunity item sub vd line items must be linked to
     *
     * @output List of created Opportunity Item Sub vd line items
    */
    public static List<Opp_Item_Sub_VD_Line_Item__c> createOppItemSubVDLI(ID oisId, List<ID> oisvdliIds)
    {
        List<Offer_Item_Sub_VD_Line_Item__c> oisvdlis = [SELECT Id, Name, Max_Price__c, Volume_Discount_Bracket__c
                                                         FROM Offer_Item_Sub_VD_Line_Item__c
                                                         WHERE Id IN :oisvdliIds];

        List<Opp_Item_Sub_VD_Line_Item__c> result = new List<Opp_Item_Sub_VD_Line_Item__c>();

        for (Offer_Item_Sub_VD_Line_Item__c oisvdli : oisvdlis)
        {
            Opp_Item_Sub_VD_Line_Item__c oppisvdli   = new Opp_Item_Sub_VD_Line_Item__c();
            oppisvdli.Name                           = oisvdli.Name;
            oppisvdli.Offer_Item_Sub_VD_Line_Item__c = oisvdli.Id;
            oppisvdli.Opp_Item_Subservice__c         = oisId;
            oppisvdli.Sales_Price__c                 = oisvdli.Max_Price__c;
            oppisvdli.Volume_Discount_Bracket__c     = oisvdli.Volume_Discount_Bracket__c;

            result.add(oppisvdli);
        }

        insert result;

        return result;
    }

    /**
     * Method createOppPackageAndFeeWithLineItems(ID oppId, ID opfId)
     * Creates a single opp package and fee (+children) under a given opportunity based on an offer package and fee
     *
     * @author Thomas Penne
     * @input  oppId   Opportunity Id.  Opportunity children must be linked to
     * @input  opfId   Offer Package and Fee Id. Offer Package and Fee Opportunity Package and Fee must be linked to
     *
     * @output List of created Opportunity Package and Fee
    */
    public static Opp_Package_And_Fee__c createOppPackageAndFeeWithLineItems(ID oppId, ID opfId)
    {
        Offer_Package_And_Fee__c opf = [SELECT Id, Name, Overusage_Price__c, Default_Price__c,
                                       (SELECT Id, Service__c
                                        FROM Offer_Package_And_Fee_Line_Items__r)
                                        FROM Offer_Package_And_Fee__c
                                        WHERE Id = :opfId
                                        LIMIT 1];

        Opp_Package_And_Fee__c result   = new Opp_Package_And_Fee__c();
        result.RecordTypeId             = Schema.getGlobalDescribe().get('Opp_Package_And_Fee__c').getDescribe().getRecordTypeInfosByName().get('TLR Opp PackFee').getRecordTypeId();
        result.Name                     = opf.Name;
        result.Offer_Package_And_Fee__c = opf.Id;
        result.Opportunity__c           = oppId;
        result.Overusage_Price__c       = opf.Overusage_Price__c;
        result.Sales_Price__c           = opf.Default_Price__c;

        insert result;

        List<Opp_Package_And_Fee_Line_Item__c> opfliToInsert = new List<Opp_Package_And_Fee_Line_Item__c>();

        for (Offer_Package_And_Fee_Line_Item__c opfli : opf.Offer_Package_And_Fee_Line_Items__r)
        {
            Opp_Package_And_Fee_Line_Item__c opppfli   = new Opp_Package_And_Fee_Line_Item__c();
            opppfli.RecordTypeId                       = getOppPfRecordType();
            opppfli.Offer_Package_And_Fee_Line_Item__c = opfli.Id;
            opppfli.Opp_Package_And_Fee__c             = result.Id;
            opppfli.PackFee__c                         = result.Id;
            opppfli.Service__c                         = opfli.Service__c;

            opfliToInsert.add(opppfli);
        }

        if (opfliToInsert.size() > 0)
            insert opfliToInsert;

        return result;
    }

    /**
     * Method createOppPromoWithLineItemsAndLinks(ID oppId, ID offerPromoId)
     * Creates an Opportunity promotion (+ children) based on an offer promotion
     *
     * @author Thomas Penne
     * @input  oppId            Opportunity Id. Opportunity opp promotion must be linked to
     * @input  offerPromoId     Offer Promotion Id. Offer Promotion opp promotion must be linked to
     *
     * @output Created Opportunity Promotion
    */
    public static Opp_Promotion__c createOppPromoWithLineItemsAndLinks(ID oppId, ID offerPromoId)
    {
        Offer_Promo__c offerPromo = [SELECT Id, Name, Promotion__c,
                                    (SELECT Id, Max_Duration__c, Max_Price__c
                                     FROM Offer_Promo_Line_Items__r),
                                    (SELECT Id
                                     FROM Offer_Promotion_Links__r)
                                     FROM Offer_Promo__c
                                     WHERE Id = :offerPromoId
                                     LIMIT 1];

        Opp_Promotion__c result   = new Opp_Promotion__c();
        result.Name               = offerPromo.Name;
        result.Offer_Promotion__c = offerPromo.Id;
        result.Opportunity__c     = oppId;
        result.Promotion__c       = offerPromo.Promotion__c;

        insert result;

        List<Opportunity_Promo_Line_Item__c> opppliToInsert = new List<Opportunity_Promo_Line_Item__c>();

        for (Offer_Promo_Line_Item__c opli : offerPromo.Offer_Promo_Line_Items__r)
        {
            Opportunity_Promo_Line_Item__c opppli = new Opportunity_Promo_Line_Item__c();
            opppli.Duration_Value__c              = opli.Max_Duration__c;
            opppli.Offer_Promo_Line_Item__c       = opli.Id;
            opppli.Sales_Price__c                 = opli.Max_Price__c;
            opppli.Opp_Promotion__c               = result.Id;

            opppliToInsert.add(opppli);
        }

        if (opppliToInsert.size() > 0)
            insert opppliToInsert;

        List<Opp_Promo_Link__c> oppplToInsert = new List<Opp_Promo_Link__c>();

        for (Offer_Promo_Link__c opl : offerPromo.Offer_Promotion_Links__r)
        {
            Opp_Promo_Link__c opppl        = new Opp_Promo_Link__c();
            opppl.Opp_Promotion__c       = result.Id;

            oppplToInsert.add(opppl);
        }

        if (oppplToInsert.size() > 0)
            insert oppplToInsert;

        return result;
    }

    /**
     * Method createTestSubscriptionHierarchy(ID subsId, List<ID> oppLineItems)
     * Creates multiple subscription line items/subscription item subservices under a given subscription
     *
     * @author Thomas Penne
     * @input  subsId           Subscription Id.  Subscription children must be linked to
     * @input  oppLineItems     List of opportunity line items Id. Opp Line Items subscription line items must be linked to
     *
     * @output List of created Subscription Line Items
    */
    public static List<Subscription_Line_Item__c> createTestSubscriptionHierarchy(ID subsId, List<ID> oppLineItems)
    {
        Map<ID, Opportunity_Line_Item__c> mapOppLIs = new Map<ID, Opportunity_Line_Item__c>([SELECT Id, Name, Service__c,
                                                                                                    Service_Attribute_Template__c,
                                                                                                    Applied_To__c, Billing_Base_pl__c,
                                                                                                    Consolidation_Level__c, Unit_Type_pl__c,
                                                                                                    Frequency_pl__c, Sales_Price__c,
                                                                                            (SELECT Id, Name, Subservice__c,
                                                                                                    Subservice_Volume_Discount__c,
                                                                                                    Applied_To__c, Billing_Base__c,
                                                                                                    Frequency__c, Sales_Price__c,
                                                                                                    Unit_Type__c
                                                                                             FROM Opp_Item_Subservices__r)
                                                                                             FROM Opportunity_Line_Item__c
                                                                                             WHERE Id IN :oppLineItems]);

        Map<ID, ID> mappingMap = new Map<ID, ID>();
        List<Subscription_Line_Item__c> subsLIToInsert = new List<Subscription_Line_Item__c>();
        List<Subs_Item_Subservice__c>   subsISToInsert = new List<Subs_Item_Subservice__c>();

        for (Opportunity_Line_Item__c oppli : mapOppLIs.Values())
        {
            Subscription_Line_Item__c subsLI     = new Subscription_Line_Item__c();
            subsLI.RecordTypeId                  = getSubsLIRecordType();
            subsLI.Name                          = oppli.Name;
            subsLI.Applied_To__c                 = oppli.Applied_To__c;
            subsLI.Billing_Base__c               = oppli.Billing_Base_pl__c;
            subsLI.Consolidation_Level__c        = oppli.Consolidation_Level__c;
            subsLI.Frequency__c                  = oppli.Frequency_pl__c;
            subsLI.Opportunity_Line_Item__c      = oppli.Id;
            //subsLI.Sales_Price__c                = oppli.Sales_Price__c;
            subsLI.Service__c                    = oppli.Service__c;
            subsLI.Service_Attribute_Template__c = oppli.Service_Attribute_Template__c;
            subsLI.Subscription__c               = subsId;
            subsLI.Unit_Type__c                  = oppli.Unit_Type_pl__c;

            subsLIToInsert.add(subsLI);
        }

        if (subsLIToInsert.size() > 0)
            insert subsLIToInsert;

        for (Subscription_Line_Item__c subsLI : subsLIToInsert)
            mappingMap.put(subsLI.Opportunity_Line_Item__c, subsLI.Id);

        for (Opportunity_Line_Item__c oppli : mapOppLIs.Values())
        {
            for (Opp_Item_Subservice__c oppis : oppli.Opp_Item_Subservices__r)
            {
                Subs_Item_Subservice__c subsIS       = new Subs_Item_Subservice__c();
                subsIS.RecordTypeId                  = getSubsISRecordType();
                subsIS.Name                          = oppis.Name;
                subsIS.Applied_To__c                 = oppis.Applied_To__c;
                subsIS.Billing_Base__c               = oppis.Billing_Base__c;
                subsIS.Frequency__c                  = oppis.Frequency__c;
                subsIS.Opp_Item_Subservice__c        = oppis.Id;
                subsIS.Subscription_Line_Item__c     = mappingMap.get(oppli.Id);
                subsIS.Subservice__c                 = oppis.Subservice__c;
                subsIS.Sales_Price__c                = oppis.Sales_Price__c;
                subsIS.Subservice_Volume_Discount__c = oppis.Subservice_Volume_Discount__c;
                subsIS.Unit_Type__c                  = oppis.Unit_Type__c;

                subsISToInsert.add(subsIS);
            }
        }

        if (subsISToInsert.size() > 0)
            insert subsISToInsert;

        return subsLIToInsert;
    }

    /**
     * Method createSubsItemSubVDLI(ID subsisId, List<ID> oppisvdliIds)
     * Creates multiple subscription item sub vd line items under a given subs item subservice
     *
     * @author Thomas Penne
     * @input  subsisId       Subs Item Subservice Id.  Subs item subservice children must be linked to
     * @input  oppisvdliIds   List of opp item sub vd line items Id. Opp item sub vd line items subs item sub vd line items must be linked to
     *
     * @output List of created Subs Item Sub vd line items
    */
    public static List<Subs_Item_Sub_VD_Line_Item__c> createSubsItemSubVDLI(ID subsisId, List<ID> oppisvdliIds)
    {
        List<Opp_Item_Sub_VD_Line_Item__c> oppisvdlis = [SELECT Id, Name, Sales_Price__c, Volume_Discount_Bracket__c
                                                         FROM Opp_Item_Sub_VD_Line_Item__c
                                                         WHERE Id IN :oppisvdliIds];

        List<Subs_Item_Sub_VD_Line_Item__c> result = new List<Subs_Item_Sub_VD_Line_Item__c>();

        for (Opp_Item_Sub_VD_Line_Item__c oppisvdli : oppisvdlis)
        {
            Subs_Item_Sub_VD_Line_Item__c subsisvdli   = new Subs_Item_Sub_VD_Line_Item__c();
            subsisvdli.Name                            = oppisvdli.Name;
            subsisvdli.Opp_Item_Sub_VD_Line_Item__c    = oppisvdli.Id;
            subsisvdli.Subs_Item_Subservice__c         = subsisId;
            subsisvdli.Sales_Price__c                  = oppisvdli.Sales_Price__c;
            subsisvdli.Volume_Discount_Bracket__c      = oppisvdli.Volume_Discount_Bracket__c;

            result.add(subsisvdli);
        }

        insert result;

        return result;
    }

    /**
     * Method createSubsPackageAndFeeWithLineItems(ID subsId, ID opppfId)
     * Creates a single subs package and fee (+children) under a given subscription based on an opp package and fee
     *
     * @author Thomas Penne
     * @input  subsId    Subscription Id.  Subscription children must be linked to
     * @input  opppfId   Opp Package and Fee Id. Opp Package and Fee Subscription Package and Fee must be linked to
     *
     * @output List of created Subscription Package and Fee
    */
    public static Subs_Package_And_Fee__c createSubsPackageAndFeeWithLineItems(ID subsId, ID opppfId)
    {
        Opp_Package_And_Fee__c opppf = [SELECT Id, Name, Overusage_Price__c, Sales_Price__c,
                                       (SELECT Id, Service__c
                                        FROM Opp_Package_And_Fee_Line_Items__r)
                                        FROM Opp_Package_And_Fee__c
                                        WHERE Id = :opppfId
                                        LIMIT 1];

        Subs_Package_And_Fee__c result  = new Subs_Package_And_Fee__c();
        result.RecordTypeId             = Schema.getGlobalDescribe().get('Subs_Package_And_Fee__c').getDescribe().getRecordTypeInfosByName().get('TLR Sub PackFee').getRecordTypeId();
        result.Name                     = opppf.Name;
        result.Opp_Package_And_Fee__c   = opppf.Id;
        result.Overusage_Price__c       = opppf.Overusage_Price__c;
        result.Sales_Price__c           = opppf.Sales_Price__c;
        result.Subscription__c          = subsId;

        insert result;

        List<Subs_Package_And_Fee_Line_Item__c> subspfliToInsert = new List<Subs_Package_And_Fee_Line_Item__c>();

        for (Opp_Package_And_Fee_Line_Item__c opppfli : opppf.Opp_Package_And_Fee_Line_Items__r)
        {
            Subs_Package_And_Fee_Line_Item__c subspfli = new Subs_Package_And_Fee_Line_Item__c();
            subspfli.RecordTypeId                      = getSubsPfRecordType();
            subspfli.Opp_Package_And_Fee_Line_Item__c  = opppfli.Id;
            subspfli.Subs_Package_And_Fee__c           = result.Id;
            subspfli.PackFee__c                        = result.Id;
            subspfli.Service__c                        = opppfli.Service__c;

            subspfliToInsert.add(subspfli);
        }

        if (subspfliToInsert.size() > 0)
            insert subspfliToInsert;

        return result;
    }

    /**
     * Method createSubsPromoWithLineItemsAndLinks(ID subsId, ID oppPromoId)
     * Creates a Subscription promotion (+ children) based on an opportunity promotion
     *
     * @author Thomas Penne
     * @input  subsId           Subscription Id. Subscription subs promotion must be linked to
     * @input  oppPromoId       Opp Promotion Id. Opp Promotion subs promotion must be linked to
     *
     * @output Created Subscription Promotion
    */
    public static Subs_Promotion__c createSubsPromoWithLineItemsAndLinks(ID subsId, ID oppPromoId)
    {
        Opp_Promotion__c oppPromo = [SELECT Id, Name, Promotion__c,
                                    (SELECT Id, Duration_Value__c, Sales_Price__c
                                     FROM Opp_Promo_Line_Items__r),
                                    (SELECT Id
                                     FROM Opp_Promo_Links__r)
                                     FROM Opp_Promotion__c
                                     WHERE Id = :oppPromoId
                                     LIMIT 1];

        Subs_Promotion__c result  = new Subs_Promotion__c();
        result.Name               = oppPromo.Name;
        result.Subscription__c    = subsId;
        result.Promotion__c       = oppPromo.Promotion__c;

        insert result;

        List<Subscription_Promo_Line_Item__c> subspliToInsert = new List<Subscription_Promo_Line_Item__c>();

        for (Opportunity_Promo_Line_Item__c opppli : oppPromo.Opp_Promo_Line_Items__r)
        {
            Subscription_Promo_Line_Item__c subspli = new Subscription_Promo_Line_Item__c();
            subspli.Duration_Value__c               = opppli.Duration_Value__c;
            subspli.Opportunity_Promo_Line_Item__c  = opppli.Id;
            subspli.Sales_Price__c                  = opppli.Sales_Price__c;
            subspli.Subscription__c                 = subsId;
            subspli.Subs_Promotion__c               = result.Id;
            subspli.Start_Date__c                   = Date.Today();
            subspli.End_Date__c                 = Date.Today();

            subspliToInsert.add(subspli);
        }

        if (subspliToInsert.size() > 0)
            insert subspliToInsert;

        List<Subs_Promo_Link__c> subsplToInsert = new List<Subs_Promo_Link__c>();

        for (Opp_Promo_Link__c opppl : oppPromo.Opp_Promo_Links__r)
        {
            Subs_Promo_Link__c subspl = new Subs_Promo_Link__c();
            subspl.Subs_Promotion__c  = result.Id;

            subsplToInsert.add(subspl);
        }

        if (subsplToInsert.size() > 0)
            insert subsplToInsert;

        return result;
    }

    /**
     * Method createTestRightsTemplateHierarchy(ID rtId, Map<ID, List<ID>> services)
     * Creates multiple rights template services/rights template service attributes under a given rights template
     *
     * @author Thomas Penne
     * @input  rtId          Rights template Id.  Rights template children must be linked to
     * @input  services      Map services Id, List of service attributes Id. Services and service attributes rights template must contain
     *
     * @output Map Created Rights template Services Id, List of created Rights template Service Attributes Id
    */
    public static Map<ID, List<Id>> createTestRightsTemplateHierarchy(ID rtId, Map<ID, List<ID>> services)
    {
        Map<ID, List<ID>> result = new Map<ID, List<ID>>();

        Map<ID, ID> mappingMap = new Map<ID, ID>();
        List<Rights_Template_Service__c>           rtServToInsert     = new List<Rights_Template_Service__c>();
        List<Rights_Template_Service_Attribute__c> rtServAttrToInsert = new List<Rights_Template_Service_Attribute__c>();

        for (ID id : services.KeySet())
        {
            Rights_Template_Service__c rtServ = new Rights_Template_Service__c();
            rtServ.RecordTypeId               = getRtServRecordType();
            rtServ.Rights_Template__c         = rtId;
            rtServ.Service__c                 = id;

            rtServToInsert.add(rtServ);
        }

        if (rtServToInsert.size() > 0)
            insert rtServToInsert;

        for (Rights_Template_Service__c rts : rtServToInsert)
        {
            mappingMap.put(rts.Service__c, rts.Id);
            result.put(rts.Id, new List<ID>());
        }

        for (ID id : services.KeySet())
        {
            for (ID idsa : services.get(id))
            {
                Rights_Template_Service_Attribute__c rtServAttr = new Rights_Template_Service_Attribute__c();
                rtServAttr.RecordTypeId                         = getRtSARecordType();
                rtServAttr.Rights_Template_Service__c           = mappingMap.get(id);
                rtServAttr.Service_Attribute__c                 = idsa;

                rtServAttrToInsert.add(rtServAttr);
            }
        }

        if (rtServAttrToInsert.size() > 0)
            insert rtServAttrToInsert;

        for (Rights_Template_Service_Attribute__c rtsa : rtServAttrToInsert)
            result.get(rtsa.Rights_Template_Service__c).add(rtsa.Id);

        return result;
    }

    /**
     * @author Nicolas Dolet
     * @date 22/12/2011
     * @description Create a new Service Attribute Template
     * @param parent The parent service of data to create
     * @return Service_Attribute_Template__c The created Service Attribute Template
     */
    public static Service_Attribute_Template__c createServiceAttributeTemplate(Service__c s) {
        Service_Attribute_Template__c result = new Service_Attribute_Template__c();
        result.RecordTypeId                  = getServAttrTplRecordType();
        result.Name = 'Test Service Attribute Template';
        result.Parent__c = s.Id;
        insert result;
        return result;
    }

    /**
     * @author Nicolas Dolet
     * @date 22/12/2011
     * @description Create a new Service Attribute Template Line Item
     * @param sa The parent Service Attribute
     * @param sat The parent Service Attribute Template
     * @return Service_Attribute_Template_Line_Item__c The created Service Attribute Template Line Item
     */
    public static Service_Attribute_Template_Line_Item__c createServiceAttributeTemplateLineItem(Service_Attribute__c sa, Service_Attribute_Template__c sat) {
        Service_Attribute_Template_Line_Item__c result = new Service_Attribute_Template_Line_Item__c();
        result.RecordTypeId                            = getServAttrTplLIRecordType();
        result.Service_Attribute__c = sa.Id;
        result.Service_Attribute_Template__c = sat.Id;
        insert result;
        return result;
    }

    /**
     * @author Nicolas Dolet
     * @date 19/12/2011
     * @description Create a new Opportunity
     * @return Opportunity The created opportunity
     */
    public static Opportunity createTestOpportunity()
    {
        Account acc         = createTestAccounts();

        Opportunity result  = new Opportunity();
        result.RecordTypeId = TLR_RecordTypeHelper.getId('Opportunity', 'WKTS Opportunity');
        result.Name         = 'Test Opp';
        result.AccountId    = acc.Id;
        result.StageName    = 'Acquisition';
        result.CloseDate    = Date.today();

        insert result;

        return result;
    }
    
    public static Opportunity createTestOpportunity(Id AccountId)
    {
        Opportunity result  = new Opportunity();
        result.RecordTypeId = TLR_RecordTypeHelper.getId('Opportunity', 'WKTS Opportunity');
        result.Name         = 'Test Opp';
        result.AccountId    = AccountId;
        result.StageName    = '01 New';
        result.Probability = 0;
        result.CloseDate    = Date.today();
        insert result;
        return result;
    }
    
	public static List<Opportunity_Line_Item__c> createTestOpportunityWithLI(Integer nbLI)
    {
        List<Id> serviceIds = createTestServices(nbLI);

        Opportunity opp = createTestOpportunity();

        List<Opportunity_Line_Item__c> result = new List<Opportunity_Line_Item__c>();

        for (Integer i = 0; i < nbLI; i++)
        {
            Opportunity_Line_Item__c oppLI = new Opportunity_Line_Item__c(Name = 'Test OppLI');
            oppLI.RecordTypeId             = getOppLIRecordType();
            oppLI.opportunity__c           = opp.Id;
            oppLI.Service__c               = serviceIds[i];
            result.add(oppLI);
        }

        if (result.size() > 0)
            insert result;

        return result;
    }
    /**
     * @author Nicolas Dolet
     * @date 19/12/2011
     * @description Create a new Opportunity populated with some line items
     * @param nbLI The number of line items to add to the opportunity
     * @return List<Opportunity_Line_Item__c> The created Opportunity Line Items
     */
    public static List<Opportunity_Line_Item__c> createTestOpportunityWithLI(Id AccountId, Integer nbLI)
    {
        List<Id> serviceIds = createTestServices(nbLI);

        Opportunity opp = createTestOpportunity(AccountId);

        List<Opportunity_Line_Item__c> result = new List<Opportunity_Line_Item__c>();

        for (Integer i = 0; i < nbLI; i++)
        {
            Opportunity_Line_Item__c oppLI = new Opportunity_Line_Item__c(Name = 'Test OppLI');
            oppLI.RecordTypeId             = getOppLIRecordType();
            oppLI.opportunity__c           = opp.Id;
            oppLI.Service__c               = serviceIds[i];
            result.add(oppLI);
        }

        if (result.size() > 0)
            insert result;

        return result;
    }

    /**
     * @author Nicolas Dolet
     * @date 19/12/2011
     * @description Create a new Opp Item Subservice
     * @param oppLI The parent Opportunity Line Item
     * @return Opp_Item_Subservice__c The created Opp Item Subservice
     */
    public static Opp_Item_Subservice__c createOppItemSubservice(Opportunity_Line_Item__c oppLI)
    {
        Opp_Item_Subservice__c result   = new Opp_Item_Subservice__c(Name = 'Test Opp Item Subservice');
        result.RecordTypeId             = getOppISRecordType();
        result.Opportunity_Line_Item__c = oppLI.Id;

        insert result;

        return result;
    }

    /**
     * @author Nicolas Dolet
     * @date 22/12/2011
     * @description Create a new Opp Package And Fee
     * @param oppLI The parent Opportunity Line Item
     * @return Opp_Item_Subservice__c The created Opp Item Subservice
     */
    public static Opp_Package_And_Fee__c createOppPackageAndFee(Opportunity opp, Offer_Package_And_Fee__c opf) {
        Opp_Package_And_Fee__c result = new Opp_Package_And_Fee__c();
        result.RecordTypeId           = Schema.getGlobalDescribe().get('Opp_Package_And_Fee__c').getDescribe().getRecordTypeInfosByName().get('TLR Opp PackFee').getRecordTypeId();
        result.Name = 'Test Opp Package And Fee';
        result.Opportunity__c = opp.Id;
        result.Offer_Package_And_Fee__c = opf.Id;
        insert result;
        return result;
    }

    /**
     * @author Nicolas Dolet
     * @date 19/12/2011
     * @description Create a new Promotion
     * @return Promotion__c The created Promotion
     */
    public static Promotion__c createPromotion() {
        Promotion__c result = new Promotion__c(Name = 'Test Promotion', Start_Date__c = Date.today());
        result.RecordTypeId = Schema.getGlobalDescribe().get('Promotion__c').getDescribe().getRecordTypeInfosByName().get('TLR Promotion').getRecordTypeId();
        insert result;
        return result;
    }

    /**
     * @author Nicolas Dolet
     * @date 19/12/2011
     * @description Create Promotion line items
     * @param promo The parent promotion
     * @param nbLI Number of Line Items to add to promo
     * @return List<Promotion_Line_Item__c> The created Promotion Line Items
     */
    public static List<Promotion_Line_Item__c> createPromotionLineItems(Promotion__c promo, Integer nbLI) {
        List<Promotion_Line_Item__c> result = new List<Promotion_Line_Item__c>();
        for (Integer i = 0; i < nbLI; i++) {
            Promotion_Line_Item__c pli = new Promotion_Line_Item__c(Name = 'Test Promo Line Item');
            pli.Promotion__c = promo.Id;
            pli.Sort_Order__c = i + 1;
            pli.Duration_Type__c = 'Months';
            pli.Min_Duration__c = 0;
            pli.Max_Duration__c = 12;
            result.add(pli);
        }
        insert result;
        return result;
    }

    /**
     * @author Nicolas Dolet
     * @date 19/12/2011
     * @description Create a Volume Discount
     * @return Volume_Discount__c The created Volume Discount
     */
    public static Volume_Discount__c createVolumeDiscount()
    {
        Volume_Discount__c result = new Volume_Discount__c();
        result.RecordTypeId       = Schema.getGlobalDescribe().get('Volume_Discount__c').getDescribe().getRecordTypeInfosByName().get('TLR Volume Discount').getRecordTypeId();
        result.Name               = 'Test Volume Discount';
        result.Discount_Type__c   = 'Simple';
        result.Start_Date__c      = Date.today();

        insert result;

        return result;
    }

    /**
     * @author Nicolas Dolet
     * @date 19/12/2011
     * @description Create some Volume Discount Brackets for a given Volume Discount
     * @param vd The parent Volume Discount
     * @param nbBrackets The number of Volume Discount Brackets to add
     * @return List<Volume_Discount_Bracket__c> The created Volume Discount Brackets
     */
    public static List<Volume_Discount_Bracket__c> createVolumeDiscountBrackets(Volume_Discount__c vd, Integer nbBrackets) {
        List<Volume_Discount_Bracket__c> result = new List<Volume_Discount_Bracket__c>();
        Integer minValue = 1;
        for (Integer i = 0; i < nbBrackets; i++) {
            Volume_Discount_Bracket__c vdb = new Volume_Discount_Bracket__c(Name = 'Test Volume Discount Bracket');
            vdb.RecordTypeId               = getVdLIRecordType();
            vdb.Volume_Discount__c = vd.Id;
            vdb.Min_Value__c = minValue;
            vdb.Max_Value__c = minValue + 10;
            minValue = minValue + 11;
            result.add(vdb);
        }
        insert result;
        return result;
    }

    /**
     * @author Nicolas Dolet & Thomas Penne
     * @date 20/12/2011
     * @description Create an Offer Template
     * @param prod The Product for the Offer Template to create
     * @param active True if Offer Template has to be active
     * @return Offer_Template__c The created Offer Template
     */
    public static Offer_Template__c createOfferTemplate(Product__c prod, Boolean active)
    {
        Offer_Template__c result = new Offer_Template__c();
        result.RecordTypeId      = Schema.getGlobalDescribe().get('Offer_Template__c').getDescribe().getRecordTypeInfosByName().get('TLR Offer Template').getRecordTypeId();
        result.Name              = 'Test Offer Template';
        result.Base_Product__c   = prod.Id;
        result.Access_Kind__c    = prod.Access_Kind__c.split(';')[0];
        result.CUG_allowed__c    = true;
        result.Start_Date__c     = Date.Today();

        if (active)
            result.Status__c = 'Active';

        insert result;

        return result;
    }

    /**
     * @author Nicolas Dolet
     * @date 22/12/2011
     * @description Create Offer Line Items for a given Offer Template
     * @param ot The parent Offer Template
     * @param services The services related to data to be created
     * @return List<Offer_Line_Item__c> The created Offer Line Items lined to the given services
     */
    public static List<Offer_Line_Item__c> createOfferLineItems(Offer_Template__c ot, List<Service__c> services) {
        List<Offer_Line_Item__c> result = new List<Offer_Line_Item__c>();
        for(Service__c s : services) {
            Offer_Line_Item__c oli = new Offer_Line_Item__c();
            oli.RecordTypeId       = getOLIRecordType();
            oli.Name = 'Test Offer Line Item';
            oli.Offer_Template__c = ot.Id;
            oli.Service__c = s.Id;
            result.add(oli);
        }
        insert result;
        return result;
    }

    /**
     * @author Nicolas Dolet
     * @date 21/12/2011
     * @description Create Package And Fee
     * @return PackFee__c The created Package And Fee
     */
    public static PackFee__c createPackageAndFee() {
        PackFee__c result   = new PackFee__c();
        result.RecordTypeId = Schema.getGlobalDescribe().get('PackFee__c').getDescribe().getRecordTypeInfosByName().get('TLR PackFee').getRecordTypeId();
        result.Name = 'Test Package And Fee';
        insert result;
        return result;
    }

    /**
     * @author Nicolas Dolet
     * @date 22/12/2011
     * @description Create Package And Fee Line Items
     * @param pf The parent Package And Fee
     * @param s The service to link to the data to create
     * @return Package_and_Fee_Line_Item__c The created Package And Fee Line Item
     */
    public static Package_and_Fee_Line_Item__c createPackageAndFeeLineItem(PackFee__c pf, Service__c s) {
        Package_and_Fee_Line_Item__c result = new Package_and_Fee_Line_Item__c();
        result.RecordTypeId                 = getPfLIRecordType();
        result.Parent__c = pf.Id;
        result.Service__c = s.Id;
        insert result;
        return result;
    }

    /**
     * @author Nicolas Dolet
     * @date 21/12/2011
     * @description Create an Offer Package And Fee for a given Offer Template
     * @param ot The parent Offer Template
     * @param pf The Package And Fee of Offer Package And Fee to create
     * @return Offer_Package_And_Fee__c The created Offer Package And Fee
     */
    public static Offer_Package_And_Fee__c createOfferPackageAndFee(Offer_Template__c ot, PackFee__c pf) {
        Offer_Package_And_Fee__c result = new Offer_Package_And_Fee__c();
        result.RecordTypeId             = Schema.getGlobalDescribe().get('Offer_Package_And_Fee__c').getDescribe().getRecordTypeInfosByName().get('TLR Offer PackFee').getRecordTypeId();
        result.Name = 'Test Offer Package And Fee';
        result.Offer_Template__c = ot.Id;
        result.Package_Fee__c = pf.Id;
        result.Min_Price__c = 0;
        result.Max_Price__c = 100;
        insert result;
        return result;
    }

    /**
     * @author AbK
     * @date 20/12/2011
     * @description Create a new Offer template Promotion
     * @return Offer_Promo__c  The created Offer template Promotion
     */
    public static Offer_Promo__c createOfferPromotion(Offer_Template__c OfferTemplate, Promotion__c Promo) {
        Offer_Promo__c result = new Offer_Promo__c (Name = 'Test Offer Promotion',Level__c='Service(s)');
        result.Offer_Template__c=OfferTemplate.Id;
        result.Promotion__c=Promo.Id;
        insert result;
        return result;
    }

    /**
     * @author Nicolas Dolet
     * @date 22/12/2011
     * @description Create Offer Promo Line Items for a given Offer Promotion
     * @param op The parent Offer Promotion
     * @param promoLIs The Promotion Line items related to the data to create
     * @return List<Offer_Promo_Line_Item__c> The created Offer Promotion Line Items
     */
    public static List<Offer_Promo_Line_Item__c> createOfferPromoLIs(Offer_Promo__c op, List<Promotion_Line_Item__c> promoLIs) {
        List<Offer_Promo_Line_Item__c> result = new List<Offer_Promo_Line_Item__c>();
        for(Promotion_Line_Item__c pli : promoLIs) {
            Offer_Promo_Line_Item__c opli = new Offer_Promo_Line_Item__c();
            opli.Offer_Promotion__c = op.Id;
            opli.Promotion_Line_Item__c = pli.Id;
            opli.Min_Price__c = 0;
            opli.Max_Price__c = 100;
            result.add(opli);
        }
        insert result;
        return result;
    }

    /**
     * @author Nicolas Dolet
     * @date 22/12/2011
     * @description Create Offer Item Subservices for a given Offer Line Item
     * @param oli The parent Offer Line Item
     * @param subservices The Subservices related to the data to create
     * @return List<Offer_Item_Subservice__c> The created Offer Item Subservices
     */
    public static List<Offer_Item_Subservice__c> createOfferItemSubservices(Offer_Line_Item__c oli, List<Subservice__c> subservices) {
        List<Offer_Item_Subservice__c> result = new List<Offer_Item_Subservice__c>();
        for(Subservice__c ss : subservices) {
            Offer_Item_Subservice__c ois = new Offer_Item_Subservice__c();
            ois.RecordTypeId             = getOISRecordType();
            ois.Name = 'Test Offer Item Subservice';
            ois.Subservice__c = ss.Id;
            ois.Offer_Line_Item__c = oli.Id;
            result.add(ois);
        }
        insert result;
        return result;
    }

    /**
     * @author Nicolas Dolet
     * @date 22/12/2011
     * @description Create Offer Item Sub VD Line Items for a given Offer Item Subservice
     * @param ois The parent Offer Item Subservice
     * @param quantity The number of data to create
     * @return List<Offer_Item_Sub_VD_Line_Item__c> The created Offer Item Sub VD Line Items
     */
    public static List<Offer_Item_Sub_VD_Line_Item__c> createOfferItemSubservices(Offer_Item_Subservice__c ois, Integer quantity) {
        System.assertEquals(quantity >= 0, true);
        List<Offer_Item_Sub_VD_Line_Item__c> result = new List<Offer_Item_Sub_VD_Line_Item__c>();
        for(Integer i = 0; i < quantity; i++) {
            Offer_Item_Sub_VD_Line_Item__c oisvdli = new Offer_Item_Sub_VD_Line_Item__c();
            oisvdli.Name = 'Offer Item Sub VD Line Item';
            oisvdli.Offer_Item_Subservice__c = ois.Id;
            result.add(oisvdli);
        }
        insert result;
        return result;
    }

    /**
     * @author Nicolas Dolet
     * @date 22/12/2011
     * @description Create an Offer Promo Link for a given Offer Promotion
     * @param op The parent Offer Promotion
     * @param ois The Offer Item Subservice related to the data to create
     * @return Offer_Promo_Link__c The created Offer Promo Link
     */
    public static Offer_Promo_Link__c createOfferPromoLink(Offer_Promo__c op, Offer_Item_Subservice__c ois) {
        Offer_Promo_Link__c result = new Offer_Promo_Link__c();
        result.Offer_Promotion__c = op.Id;
        result.Offer_Item_Subservice__c = ois.Id;
        insert result;
        return result;
    }

    /**
     * @author Nicolas Dolet
     * @date 22/12/2011
     * @description Create an Offer Promo Link for a given Offer Promotion
     * @param op The parent Offer Promotion
     * @param opf The Offer Package And Fee related to the data to create
     * @return Offer_Promo_Link__c The created Offer Promo Link
     */
    public static Offer_Promo_Link__c createOfferPromoLink(Offer_Promo__c op, Offer_Package_And_Fee__c opf) {
        Offer_Promo_Link__c result = new Offer_Promo_Link__c();
        result.Offer_Promotion__c = op.Id;
        result.Offer_Package_And_Fee__c = opf.Id;
        insert result;
        return result;
    }

    /**
     * @author Nicolas Dolet/ Thomas Penne
     * @date 20/12/2011
     *
     * @description Create a Rights Template for a given Provisioning
     *
     * @param  prov     Provisioning rights template must be linked to
     * @param  active   Indicates if Rights Template must be activated
     * @return Created Rights Template
     */
    public static Rights_Template__c createRightsTemplate(Provisioning__c prov, Boolean active)
    {
        Rights_Template__c result = new Rights_Template__c();
        result.RecordTypeId       = Schema.getGlobalDescribe().get('Rights_Template__c').getDescribe().getRecordTypeInfosByName().get('TLR Rights Template').getRecordTypeId();
        result.Name               = 'Test Rights Template';
        result.Provisioning__c    = prov.Id;
        result.Default__c         = true;

        if (active)
            result.Status__c = 'Active';
        else
            result.Status__c = 'Pending';

        insert result;

        return result;
    }

    public static Rights_Template_Default__c createRightsTemplateDefault(Offer_Template__c ot, Boolean active)
    {
        Rights_Template_Default__c result = new Rights_Template_Default__c();
        result.RecordTypeId       = Schema.getGlobalDescribe().get('Rights_Template_Default__c').getDescribe().getRecordTypeInfosByName().get('TLR Rights Template').getRecordTypeId();
        result.Name               = 'Test Rights Template';
        result.Offer_Template__c    = ot.Id;
        result.Default__c         = true;

        if (active)
            result.Status__c = 'Active';
        else
            result.Status__c = 'Pending';

        insert result;

        return result;
    }

//    public static Product__c createTestProductAndLineItemsWEB3S(List<ID> services, Boolean addon, Boolean active)
//    {
//        Product__c prod      = new Product__c();
//        prod.Name            = 'Test Product';
//        prod.Access_Kind__c  = 'WEB3S';
//        prod.Access_Roles__c = 'T_GO';
//        prod.Start_Date__c   = Date.Today();
//        prod.Status__c       = 'Pending';
//        prod.Add_on__c       = addon;
//
//        insert prod;
//
//        List<Product_Line_Item__c> pliToInsert = new List<Product_Line_Item__c>();
//
//        for (ID id : services)
//        {
//            Product_Line_Item__c prodLI = new Product_Line_Item__c();
//           prodLI.Parent__c            = prod.Id;
//            prodLI.Service__c           = id;
//
//            pliToInsert.add(prodLI);
//        }
//
//        if (pliToInsert.size() > 0)
//            insert pliToInsert;
//
//        if (active)
//        {
//            prod.Status__c = 'Pending Activation Approval';
//            update prod;
//            prod.Status__c = 'Active';
//            update prod;
//        }
//
//        return prod;
//    }

    //create Subscription Line Item
    public static  Subscription_Line_Item__c createTestSubsLineItem(ID SubsId, ID ServId)
    {
      Subscription_Line_Item__c serv = new Subscription_Line_Item__c();
      serv.RecordTypeId              = getSubsLIRecordType();
      serv.Name            = 'Test Subs LI';
      serv.Subscription__c = SubsId;
      serv.Service__c   = ServId;
      insert serv;
      return serv;
    }

    /**
     * @author Nicolas Dolet
     * @date 23/12/2011
     * @description Create a Certificate for a given Account
     * @param acc The parent Account
     * @return Certificate__c The created Certificate
     */
    public static Certificate__c createCertificate(Account acc)
    {
        Certificate__c result = new Certificate__c();
        result.RecordTypeId   = Schema.getGlobalDescribe().get('Certificate__c').getDescribe().getRecordTypeInfosByName().get('TLR Certificate').getRecordTypeId();
        result.Name = 'Test Certificate';
        result.Account__c = acc.Id;
        insert result;
        return result;
    }

     //-- Opp_Item_Sub_VD_Line_Item__c
    public static List<Opp_Item_Sub_VD_Line_Item__c> createOppItemSubVDLI(Opp_Item_Subservice__c  opIseb, List<Offer_Item_Sub_VD_Line_Item__c> offsvdli, Integer quantity)
    {
        System.assertEquals(quantity >= 0, true);
        List<Opp_Item_Sub_VD_Line_Item__c> result = new List<Opp_Item_Sub_VD_Line_Item__c>();
        for(Offer_Item_Sub_VD_Line_Item__c curoffsvdli : offsvdli)
         {
            Opp_Item_Sub_VD_Line_Item__c oppsvdli = new Opp_Item_Sub_VD_Line_Item__c ();
            oppsvdli.Name = 'Opp Item Sub VD Line Item';
            oppsvdli.Offer_Item_Sub_VD_Line_Item__c = curoffsvdli.Id;
            oppsvdli.Opp_Item_Subservice__c =opIseb.Id;
            result.add(oppsvdli);
        }
        insert result;

        return result;
    }

    public static Opp_Promotion__c createOppPromotion(Opportunity Opp, Promotion__c Promo)
    {
        Opp_Promotion__c result = new Opp_Promotion__c(Name = 'Test Opp Promotion');
        result.Opportunity__c = Opp.Id;
        result.Promotion__c = Promo.Id;
        insert result;
        return result;
    }

    //-- Opportunity_Promo_Link__c
     public static Opp_Promo_Link__c createOppPromoLink(Opp_Promotion__c op, Opp_Package_And_Fee__c opf) {
        Opp_Promo_Link__c result = new Opp_Promo_Link__c();
        result.Opp_Promotion__c = op.Id;
        result.Opp_Package_And_Fee__c = opf.Id;
        insert result;
        return result;
    }
}