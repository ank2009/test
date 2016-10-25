/**
 * Name : OfferTemplateExt
 * Created By : Ronnie Visser <r.visser@vivens.com>
 * Date : 2011-08-26
**/
public class OfferTemplateExt 
{
    /**
     * Will contain the Offer Template given by the stdController
     * 
     * Type : Final
    **/
    public final Offer_template__c offerTemplate {get; set;}
    
    /**
     * Will contain the cloned Offer Template 
     * 
    **/
    public Offer_template__c clonedOfferTemplate {get; set;}
    
    /**
     * Get the complete Offer Template 
     * 
    **/
    public Offer_template__c offerTemplatePage 
    {
        get 
        {
            if (offerTemplatePage == null)
            {
                offerTemplatePage = [SELECT o.Status__c, o.Start_Date__c, o.RecordTypeId, 
                                            o.Payment_Mode__c, o.Name, o.Minimal_Boundary__c, 
                                            o.Maximal_Boundary__c, o.End_Date__c, 
                                            o.Eligibility_Criteria__c, o.Eligibility_Criteria_Int__c, 
                                            o.Default_Value__c, o.Default_Payment_Method__c, 
                                            o.Contract_Term__c, o.Base_Product__c, o.CUG_allowed__c,
                                            o.Default_Invoice_Level__c, o.Default_Invoice_Media__c,
                                            o.Access_Kind__c, o.CurrencyIsoCode,(Select Id From Rights_Templates__r)
                                     FROM Offer_template__c o 
                                     WHERE Id = :this.offerTemplate.Id];
            }
            
            return offerTemplatePage;
        } 
        set;
    }
    
    /**
     * Get all the related Offer Line Items
     *
    **/
    public Offer_Line_Item__c[] offerLineItems 
    {
        get 
        {
            if (offerLineItems == null)
                offerLineItems = [SELECT o.Unit_Type_pl__c, o.Service__c, o.Service_Volume_Discount__c, 
                                         o.RecordTypeId, o.Offer_Template__c, o.Name, o.Id, 
                                         o.Frequency_pl__c, o.Billing_Base_pl__c, o.Billable_Service__c, 
                                         o.Applied_To__c, o.Consolidation_Level__c, 
                                         o.Service_Attribute_Template__c, o.CurrencyIsoCode 
                                  FROM Offer_Line_Item__c o 
                                  WHERE o.Offer_Template__c = :this.offerTemplate.Id];
            
            return offerLineItems;
        } 
        set;
    }
    
    /**
     * Get all the related Right Template
     *
    **/
    public Rights_Template_Default__c[] rightTemplateDefault 
    {
        get 
        {
            if (rightTemplateDefault == null)
                rightTemplateDefault = [Select r.Status__c, r.Private_Exchange_ID__c, r.PUG_Name__c, r.PIA_Interface__c, 
                                               r.Offer_Template__c, r.Name, r.Id 
                                        From Rights_Template_Default__c r
                                        WHERE r.Offer_Template__c = :this.offerTemplate.Id];
            
            return rightTemplateDefault;
        } 
        set;
    }  
    /**
     * Get all the related Right Template Services
     *
    **/
    public Rights_Template_Service_Default__c[] rightTemplateDefaultService
    {
        get 
        {
            if (rightTemplateDefaultService == null)
                rightTemplateDefaultService = [Select r.Service__c, r.Rights_Template__c, r.Name, r.Id 
                                                From Rights_Template_Service_Default__c r
                                                WHERE r.Rights_Template__c IN :this.rightTemplateDefault];
            
            return rightTemplateDefaultService;
        } 
        set;
    } 
    /**
     * Get all the related Right Template Services
     *
    **/
    public Rights_Template_Service_Attribute_Def__c[] rightTemplateDefaultServiceAtt
    {
        get 
        {
            if (rightTemplateDefaultServiceAtt == null)
                rightTemplateDefaultServiceAtt = [Select r.Service_Attribute__c, r.Rights_Template_Service__c, r.Name, r.Id 
                                                  From Rights_Template_Service_Attribute_Def__c r
                                                  WHERE r.Rights_Template_Service__c IN :this.rightTemplateDefaultService];
            
            return rightTemplateDefaultServiceAtt;
        } 
        set;
    }  
    /**
     * Get all the related Offer Packages And Fees
     *
    **/
    public Offer_Package_And_Fee__c[] offerPackagesAndFees 
    {
        get 
        {
            if (offerPackagesAndFees == null)
                offerPackagesAndFees = [SELECT o.RecordTypeId, o.Package_Quantity__c, o.Package_Fee__c,
                                               o.Min_Overusage_Price__c, o.Max_Overusage_Price__c,
                                               o.Overusage_Price__c, o.Offer_Template__c, o.Name, 
                                               o.Min_Price__c, o.Max_Price__c, o.Default_Price__c, o.CurrencyIsoCode
                                        FROM Offer_Package_And_Fee__c o 
                                        WHERE o.Offer_Template__c = :this.offerTemplate.Id];                
            
            return offerPackagesAndFees;
        } 
        set;
    }
    
    /**
     * Get all the related Offer Promotions
     *
    **/
    public Offer_Promo__c[] offerPromotions 
    {
        get 
        {
            if (offerPromotions == null)
                offerPromotions = [SELECT o.Level__c, o.Offer_Template__c, o.Name, o.Promotion__c, o.CurrencyIsoCode 
                                   FROM Offer_Promo__c o 
                                   WHERE o.Offer_Template__c = :this.offerTemplate.Id];
            
            return offerPromotions;
        } 
        set;
    }
    
    /**
     * Get all the related Offer Item Subservice
     *
    **/
    public Offer_Item_Subservice__c[] offerItemSubservices 
    {
        get 
        {
            if (offerItemSubservices == null)
                offerItemSubservices = [SELECT o.Unit_Type__c, o.Subservice__c, o.Subservice_Volume_Discount__c, 
                                               o.RecordTypeId, o.Offer_Line_Item__c, o.Name, o.Id, 
                                               o.Min_Price__c, o.Max_Price__c, o.Volume_Discount_cb__c,
                                               o.Frequency__c, o.Billing_Base__c, o.Applied_To__c, 
                                               o.Billing_Limit__c, o.CurrencyIsoCode
                                        FROM Offer_Item_Subservice__c o
                                        WHERE o.Offer_Line_Item__c IN :this.offerLineItems];
            
            return offerItemSubservices;
        } 
        set;
    }
   
    /**
     * Get all the related Offer Item Sub VD Line Item
     *
    **/
    public Offer_Item_Sub_VD_Line_Item__c[] offerItemSubVDLI 
    {
        get 
        {
            if (offerItemSubVDLI == null)
                offerItemSubVDLI = [SELECT o.Name, o.Max_Price__c, o.Min_Price__c, 
                                           o.Offer_Item_Subservice__c, o.Volume_Discount_Bracket__c, o.CurrencyIsoCode
                                    FROM Offer_Item_Sub_VD_Line_Item__c o 
                                    WHERE o.Offer_Item_Subservice__c IN :this.offerItemSubservices];
            
            return offerItemSubVDLI;
        } 
        set;
    }
    
    /**
     * Get all the related Offer Package And Fee Line Item
     *
    **/
    public Offer_Package_And_Fee_Line_Item__c[] offerPFLI 
    {
        get 
        {
            if (offerPFLI == null)
                offerPFLI = [SELECT o.RecordTypeId, o.Offer_Package_And_Fee__c, o.PackFee__c, 
                                    o.PackFee_Line_Item__c, o.Weight__c, o.Service__c, o.Name, o.CurrencyIsoCode
                             FROM Offer_Package_And_Fee_Line_Item__c o 
                             WHERE o.Offer_Package_And_Fee__c IN :this.offerPackagesAndFees];
            
            return offerPFLI;
        } 
        set;
    }
    
    /**
     * Get all the related Offer Promo Line Item
     *
    **/
    public Offer_Promo_Line_Item__c[] offerPromoLI 
    {
        get 
        {
            if (offerPromoLI == null)
                offerPromoLI = [SELECT o.Max_Discount__c, o.Max_Discount_Percentage__c, o.Max_Duration__c,
                                       o.Max_Price__c, o.Min_Discount__c, o.Min_Discount_Percentage__c,
                                       o.Min_Duration__c, o.Min_Price__c, o.Offer_Promotion__c,
                                       o.Promotion_Line_Item__c, o.Name, o.CurrencyIsoCode
                                FROM Offer_Promo_Line_Item__c o 
                                WHERE o.Offer_Promotion__c IN :this.offerPromotions];
            
            return offerPromoLI;
        } 
        set;
    }
    
    /**
     * Get all the related Offer Promo Link
     *
    **/
    public Offer_Promo_Link__c[] offerPromoLink 
    {
        get 
        {
            if (offerPromoLink == null)
                offerPromoLink = [SELECT o.Offer_Item_Subservice__c, o.Offer_Package_And_Fee__c,
                                         o.Offer_Promotion__c, o.Name, o.CurrencyIsoCode
                                  FROM Offer_Promo_Link__c o 
                                  WHERE o.Offer_Promotion__c IN :this.offerPromotions];
            
            return offerPromoLink;
        } 
        set;
    }
    
    /**
     * Class Constructor with standardController
     *
     * Type : Constructor
    **/ 
    public OfferTemplateExt(ApexPages.StandardController controller) 
    {
        this.offerTemplate = (Offer_template__c)controller.getRecord();
    }
    
    /**
     * Method that saves the cloned Offer Template and all it's related Lists
     *
     * This method uses Database.Rollback() so if an error occurs while inserting Related List items
     * the Offer template is also deleted.
     *
     * Type : PageReference
    **/
    public PageReference SaveClone()
    {
        // Set a Database savepoint so we can rollback if needed
        Savepoint sp = Database.setSavepoint();
        
        // Clone Offer Template
        this.clonedOfferTemplate               = this.offerTemplatePage.clone(false, true);
        this.clonedOfferTemplate.Status__c     = 'Pending';
        this.clonedOfferTemplate.Start_Date__c = Date.Today();
        this.clonedOfferTemplate.End_Date__c   = null;
        
        try {
            // Insert Offer Template
            insert this.clonedOfferTemplate;
            
            //Children 
            Map<ID, ID> mapChildren = new Map<ID, ID>();
           
            // Clone OfferLineItems
            System.Debug('Offer Line Items');
            if (this.offerLineItems.size() > 0)
            {
                Offer_Line_Item__c[] listOfferLineItems = this.offerLineItems.deepClone(false);
                
                for (Offer_Line_Item__c lineItem : listOfferLineItems) 
                    lineItem.Offer_Template__c = this.clonedOfferTemplate.Id;
                
                insert listOfferLineItems;
                    
                for (Integer i = 0; i < listOfferLineItems.size(); i++)
                    mapChildren.put(offerLineItems[i].Id, listOfferLineItems[i].Id);
            }
            
            // Clone OfferItemSubservices
            System.Debug('Offer Item Subservice');
            if (this.offerItemSubservices.size() > 0)
            {
                Offer_Item_Subservice__c[] listOfferItemSubservices = this.offerItemSubservices.deepClone(false);
                
                for (Offer_Item_Subservice__c item : listOfferItemSubservices)
                    item.Offer_Line_Item__c = mapChildren.get(item.Offer_Line_Item__c);
                
                insert listOfferItemSubservices;
                    
                for (Integer i = 0; i < listOfferItemSubservices.size(); i++)
                    mapChildren.put(offerItemSubservices[i].Id, listOfferItemSubservices[i].Id);
            }
            
            // Clone OfferItemSubVDLIs
            System.Debug('Offer Item Sub VD Line Item');
            if (this.offerItemSubVDLI.size() > 0)
            {
                Offer_Item_Sub_VD_Line_Item__c[] listOfferItemSubVDLIs = this.offerItemSubVDLI.deepClone(false);
                
                for (Offer_Item_Sub_VD_Line_Item__c item : listOfferItemSubVDLIs)
                    item.Offer_Item_Subservice__c = mapChildren.get(item.Offer_Item_Subservice__c);
                
                insert listOfferItemSubVDLIs;
                    
                for (Integer i = 0; i < listOfferItemSubVDLIs.size(); i++)
                    mapChildren.put(offerItemSubVDLI[i].Id, listOfferItemSubVDLIs[i].Id);
            }
            
            // Clone OfferPackageAndFee
            System.Debug('Offer Pack and Fee');
            if (this.offerPackagesAndFees.size() > 0) 
            {
                Offer_Package_And_Fee__c[] listOfferPackagesAndFees = this.offerPackagesAndFees.deepClone(false);
                
                for (Offer_Package_And_Fee__c packFee : listOfferPackagesAndFees) 
                    packFee.Offer_Template__c = this.clonedOfferTemplate.Id;    
                
                FollowUpTriggerOfferPackFeeAfterInsert.doNotCallTrigger();
                insert listOfferPackagesAndFees;
                
                for (Integer i = 0; i < listOfferPackagesAndFees.size(); i++)
                    mapChildren.put(offerPackagesAndFees[i].Id, listOfferPackagesAndFees[i].Id);
            }
            
            // Clone OfferPackageAndFeeLI
            System.Debug('Offer Pack and Fee Line Item');
            if (this.offerPFLI.size() > 0)
            {
                Offer_Package_And_Fee_Line_Item__c[] listOfferPFLIs = this.offerPFLI.deepClone(false);
                
                for (Offer_Package_And_Fee_Line_Item__c item : listOfferPFLIs)
                {
                    item.Offer_Package_And_Fee__c = mapChildren.get(item.Offer_Package_And_Fee__c);
                    item.PackFee__c               = mapChildren.get(item.PackFee__c);
                }
                
                insert listOfferPFLIs;
                    
                for (Integer i = 0; i < listOfferPFLIs.size(); i++)
                    mapChildren.put(offerPFLI[i].Id, listOfferPFLIs[i].Id);
            }
            
            // Clone OfferPromotions
            System.Debug('Offer Offer Promotion');
            if (this.offerPromotions.size() > 0) 
            {
                Offer_Promo__c[] listOfferPromotions = this.offerPromotions.deepClone(false);
                
                for (Offer_Promo__c promotion : listOfferPromotions) 
                    promotion.Offer_Template__c = this.clonedOfferTemplate.Id;  
                
                FollowUpTriggerOfferPromotionAfterInsert.doNotCallTrigger();
                insert listOfferPromotions;
                
                for (Integer i = 0; i < listOfferPromotions.size(); i++)
                    mapChildren.put(offerPromotions[i].Id, listOfferPromotions[i].Id);
            }
            
            // Clone OfferPromoLI
            System.Debug('Offer Promo Line Item');
            if (this.offerPromoLI.size() > 0)
            {
                Offer_Promo_Line_Item__c[] listOfferPromoLIs = this.offerPromoLI.deepClone(false);
                
                for (Offer_Promo_Line_Item__c item : listOfferPromoLIs)
                    item.Offer_Promotion__c = mapChildren.get(item.Offer_Promotion__c);
                
                insert listOfferPromoLIs;
                    
                for (Integer i = 0; i < listOfferPromoLIs.size(); i++)
                    mapChildren.put(offerPromoLI[i].Id, listOfferPromoLIs[i].Id);
            }
            
            // Clone OfferPromoLink
            System.Debug('Offer Promo Link');
            if (this.offerPromoLink.size() > 0)
            {
                Offer_Promo_Link__c[] listOfferPromoLinks = this.offerPromoLink.deepClone(false);
                
                for (Offer_Promo_Link__c item : listOfferPromoLinks)
                {
                    item.Offer_Item_Subservice__c = mapChildren.get(item.Offer_Item_Subservice__c);
                    item.Offer_Package_And_Fee__c = mapChildren.get(item.Offer_Package_And_Fee__c);
                    item.Offer_Promotion__c       = mapChildren.get(item.Offer_Promotion__c);
                }
                
                insert listOfferPromoLinks;
                    
                for (Integer i = 0; i < listOfferPromoLinks.size(); i++)
                    mapChildren.put(offerPromoLink[i].Id, listOfferPromoLinks[i].Id);
            }
            
             //start HCL
            // Clone rightTemplateDefault
            System.Debug('Right Template');
            if (this.rightTemplateDefault.size() > 0)
            {
                Rights_Template_Default__c[] listrightTemplateDefault = this.rightTemplateDefault.deepClone(false);
                
                for (Rights_Template_Default__c rightTemplate : listrightTemplateDefault) 
                    rightTemplate.Offer_Template__c = this.clonedOfferTemplate.Id;
                
                insert listrightTemplateDefault;
                    
                for (Integer i = 0; i < listrightTemplateDefault.size(); i++)
                    mapChildren.put(rightTemplateDefault[i].Id, listrightTemplateDefault[i].Id);
            }            
            // Clone rightTemplateDefaultService
            System.Debug('Right Template Subservice');
            if (this.rightTemplateDefaultService.size() > 0)
            {
                Rights_Template_Service_Default__c[] listrightTemplateDefaultService = this.rightTemplateDefaultService.deepClone(false);
                
                for (Rights_Template_Service_Default__c rightTemplateService : listrightTemplateDefaultService)
                    rightTemplateService.Rights_Template__c = mapChildren.get(rightTemplateService.Rights_Template__c);
                
                insert listrightTemplateDefaultService;
                    
                for (Integer i = 0; i < listrightTemplateDefaultService.size(); i++)
                    mapChildren.put(rightTemplateDefaultService[i].Id, listrightTemplateDefaultService[i].Id);
            }            
            // Clone rightTemplateDefaultServiceAtt
            System.Debug('Right Template Subservice Attribute');
            if (this.rightTemplateDefaultServiceAtt.size() > 0)
            {
                Rights_Template_Service_Attribute_Def__c[] listrightTemplateDefaultServiceAtt = this.rightTemplateDefaultServiceAtt.deepClone(false);
                
                for (Rights_Template_Service_Attribute_Def__c rightTemplateServiceAtt : listrightTemplateDefaultServiceAtt) 
                    rightTemplateServiceAtt.Rights_Template_Service__c = mapChildren.get(rightTemplateServiceAtt.Rights_Template_Service__c);
                
                insert listrightTemplateDefaultServiceAtt;
                    
                for (Integer i = 0; i < listrightTemplateDefaultServiceAtt.size(); i++)
                    mapChildren.put(rightTemplateDefaultServiceAtt[i].Id, listrightTemplateDefaultServiceAtt[i].Id);
            }
            //end HCL
            
            // Everything succeeded so we can go to the cloned Offer Template 
            return Utilities.redirect(this.clonedOfferTemplate.Id);
        } 
        catch (DmlException e)
        {
            // Do the rollback transaction
            Database.rollback(sp);
            
            // Add a message with the error in it
            ApexPages.addMessages(e);
            
            return null;            
        }
    }
    
    public PageReference ActivateApproval()
    {
        if( this.offerTemplatePage.Status__c != 'Pending' ){
            
            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'Offer Template Status should be equal to Pending when activating');
            ApexPages.addMessage(errormsg); 
            return null;
            
        }else if( 
            ([Select count() From Rights_Template_Default__c where Offer_Template__c =: this.offerTemplatePage.Id And Status__c =: 'Active'] == 0)
            && offerTemplatePage.RecordTypeId != TLR_RecordTypeHelper.getId('Offer_template__c','TAS Offer template')
        ){
            
            ApexPages.Message errormsgRT = new ApexPages.Message(ApexPages.severity.ERROR,'At least one Active Right Template should be present at the time of activating Offer Template!');
            ApexPages.addMessage(errormsgRT); 
            return null;
        }else{
            this.offerTemplatePage.Status__c = 'Pending Approval for Activation';
            update this.offerTemplatePage;
            
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(this.offerTemplatePage.Id);
                                
            Approval.ProcessResult result = Approval.process(req1);             
            return Utilities.redirect( this.offerTemplatePage.Id );
        }

    }    
   
    public PageReference DeactivateApproval()
    {
        if( this.offerTemplatePage.Status__c != 'Active' )
        {
            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'Offer Template Status should be equal to Active when deactivating');
            ApexPages.addMessage(errormsg); 
            return null;
        } 
        else 
        {
            this.offerTemplatePage.Status__c = 'Pending Approval for Deactivation';
            update this.offerTemplatePage;
            
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(this.offerTemplatePage.Id);
                                
            Approval.ProcessResult result = Approval.process(req1);             
            return Utilities.redirect( this.offerTemplatePage.Id );
        }
    }
    
    public PageReference ReactivateApproval()
    {
        if( this.offerTemplatePage.Status__c != 'Inactive' )
        {
            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'Offer Template Status should be equal to Inactive when reactivating');
            ApexPages.addMessage(errormsg); 
            return null;
        } 
        else 
        {
            //FDU correction 14/07/2011
            this.offerTemplatePage.Status__c = 'Pending';
            update this.offerTemplatePage;
            /*
            this.offerTemplatePage.Status__c = 'Pending Approval for Activation';
            update this.offerTemplatePage;
            
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(this.offerTemplatePage.Id);
                                
            Approval.ProcessResult result = Approval.process(req1);             
            */
            return Utilities.redirect( this.offerTemplatePage.Id );
        }
    }
}