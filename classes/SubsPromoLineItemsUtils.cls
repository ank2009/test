/**
* @author Nicolas Dolet
* @date 11/11/2011
* @description Class with static methods for Subs Promotion data manipulation
*/
public with sharing class SubsPromoLineItemsUtils {

    /**
     * Constructor
     */
    public SubsPromoLineItemsUtils() { }

    /**
     * Constructor
     */
    public SubsPromoLineItemsUtils(ApexPages.StandardController controller) { }
    
    /**
     * @author Nicolas Dolet
     * @date 12/11/2011
     * @description Creates a new SubsPromotion according to a given Opp Promotion and attach it to an existing Subscription
     *              If Subscription end date is not null, promotions items are added until end date is reached
     * @param subscriptionId The Id of the Subscription
     * @param promo The Opp Promotion to apply
     * @return Subs_Promotion__c A new Subs Promotion linked to subsId and matching with promo
     */
    public static Subs_Promotion__c buildSubsPromoLineItems(Subscription__c subs, Opp_Promotion__c promo) {
        
        // Create a new Subs Promotion
        Subs_Promotion__c result = new Subs_Promotion__c();
        
        // Link it to the Subscription
        result.Subscription__c = subs.Id;
        result.CurrencyIsoCode = promo.CurrencyIsoCode;
        result.Name            = promo.Name;
        result.Promotion__c    = promo.Promotion__c;
        insert result;
        
        // Get line items from the Promotion parameter
        List<Opportunity_Promo_Line_Item__c> promoItems = 
            [SELECT Id, Discount__c, Min_Discount__c, Max_Discount__c,
                    Discount_Percentage__c, Min_Discount_Percentage__c,
                    Max_Discount_Percentage__c, Duration_Type__c,
                    Duration_Value__c, Min_Duration__c, Max_Duration__c,
                    Sales_Price__c, Sort_Order__c, CurrencyIsoCode,
                    Offer_Promo_Line_Item__r.Promotion_Line_Item__c
               FROM Opportunity_Promo_Line_Item__c
              WHERE Opp_Promotion__c =: promo.Id
              ORDER BY Sort_Order__c ASC];
             
        System.debug('### Recovered Promo Items: ' + promoItems);

        // Store SPLIs
        List<Subscription_Promo_Line_Item__c> spliList = new List<Subscription_Promo_Line_Item__c>();

        // First start date is today
        Date currentStartDate = Date.today();
        Boolean continueAdding = true;

        // Add line items to the created Subs Promotion
        for(Opportunity_Promo_Line_Item__c currentPLI : promoItems) {
            if(continueAdding) {
                System.debug('### Add current Promo Item: ' + currentPLI);
                Subscription_Promo_Line_Item__c spli = new Subscription_Promo_Line_Item__c();
                spli.Opportunity_Promo_Line_Item__c = currentPLI.Id;
                spli.Promotion_Line_Item__c         = currentPLI.Offer_Promo_Line_Item__r.Promotion_Line_Item__c;
                spli.Subs_Promotion__c = result.Id;
                spli.Subscription__c = subs.Id;
                
                // Copy field values
                spli.Discount__c            = currentPLI.Discount__c;
                spli.Discount_Percentage__c = currentPLI.Discount_Percentage__c;
                spli.Duration_Value__c      = currentPLI.Duration_Value__c;
                spli.Sales_Price__c         = currentPLI.Sales_Price__c;
                spli.CurrencyIsoCode        = currentPLI.CurrencyIsoCode;
                
                // Calculate end date
                spli.Start_Date__c = currentStartDate;
                currentStartDate = calculateEndDate(currentStartDate,
                                                    currentPLI.Duration_Value__c.intValue(),
                                                    currentPLI.Duration_Type__c);
                if(subs.End_Date__c != null && subs.End_Date__c < currentStartDate) {
                    currentStartDate = subs.End_Date__c;
                    continueAdding = false;
                }
                
                spli.End_Date__c = currentStartDate;
                
                spliList.add(spli);
            }
        }
        
        System.debug('### Inserst new Subs Promo Items: ' + spliList);
        try {
            insert spliList;
        } catch (DmlException ex) {
            ApexPages.addMessages(ex);
        }
        
        return result;
    }
    
    /**
     * @author Nicolas Dolet
     * @date 12/11/2011
     * @description Calculates the end date according to a start date, a duration and a duration type
     * @param startDate The start date.
     * @param duration The duration.
     * @param type The duration type (Days, Months or Months prorata)
     * @return Date The end date matching with parameters
     */
    public static Date calculateEndDate(Date startDate, Integer duration, String type) {
        Date result = Date.valueOf(startDate);
        if(type == 'Days') {
            result = result.addDays(duration);
        } else if(type == 'Months') {
            result = result.addMonths(duration);
        } else if(type == 'Months prorata') {
            if(duration > 0) {
                result = result.toStartOfMonth();
                result = result.addMonths(duration);
            }
        } else {
            throw new DurationException('Unknown duration type: "' + type + '"');
        }
        return result;
    }
    
    /**
     * @author Nicolas Dolet
     * @date 12/11/2011
     * @description Updates the end date of all Subs Promo Line Items for each Subs Promotion of a given Subscription
     * @param s The Subscription.
     */
    public static void updatePromoLIEndDates(Subscription__c s) {
        // Recover Subs Promotions attached to s
        List<Subs_Promotion__c> subsPromoList = [SELECT Id FROM Subs_Promotion__c WHERE Subscription__c =: s.Id];
        // Update end date of Subs Promo Line Items for each Subs Promotion
        for(Subs_Promotion__c currentSP : subsPromoList)
            updateLIEndDates(currentSP, s.End_Date__c);
    }
    
    /**
     * @author Nicolas Dolet
     * @date 12/11/2011
     * @description Updates the promo dates for each Subs Promo Line items of a given Subs Promotion
     * @param sp The Subs Promotion.
     * @param d The end date to apply.
     */
    private static void updateLIEndDates(Subs_Promotion__c sp, Date d) {
        // If there is no end date, do nothing
        if(d != null) {
            // Line items to update
            List<Subscription_Promo_Line_Item__c> updatedLI = new List<Subscription_Promo_Line_Item__c>();

            // Recover all Subs Promo Line Items attached to sp
            List<Subscription_Promo_Line_Item__c> items =
                [SELECT Id, Start_Date__c, End_Date__c FROM Subscription_Promo_Line_Item__c
                 WHERE Subs_Promotion__c =: sp.Id ORDER BY Sort_Order__c ASC];
            for(Subscription_Promo_Line_Item__c currentLI : items) {
                if(currentLI.Start_Date__c >= d)
                    currentLI.Start_Date__c = d;
                if(currentLI.End_Date__c > d)
                    currentLI.End_Date__c = d;
                // else, Line Item do not change
                updatedLI.add(currentLI);
            }
            
            try {
                update updatedLI;
            } catch (DmlException ex) {
                ApexPages.addMessages(ex);
            }
        }
    }
    
    /**
     * @author Nicolas Dolet
     * @date 14/11/2011
     * @description Updates the dates of Subs Promo Line Items attached to a Subs Promotion
     * @param sp The Subs Promotion.
     * @param startDate The start date to apply.
     * @param endDate The end date to apply.
     */
    public static void updatePromoLineItemsDates(ID subsId, Date startDate, Date endDate) {
        
        // Get all items of sp
        Map<ID, Subs_Promotion__c> mapSubsPromo =
               new Map<ID, Subs_Promotion__c>([SELECT Id,
                                               (SELECT Id, Opportunity_Promo_Line_Item__c,
                                                       Duration_Value__c
                                                FROM Subs_Promo_Line_Items__r
                                                ORDER BY Sort_Order__c)
                                                FROM Subs_Promotion__c 
                                                WHERE Subscription__c = :subsId
                                                AND Promotion__c != null]);
        
        Set<ID> idOppLIs = new Set<ID>();
        for (Subs_Promotion__c subsPromo : mapSubsPromo.Values())
            for (Subscription_Promo_Line_Item__c subsPromoLI : subsPromo.Subs_Promo_Line_Items__r)
                idOppLIs.add(subsPromoLI.Opportunity_Promo_Line_Item__c);
        
        Map<ID, Opportunity_Promo_Line_Item__c> mapIdOppLI = new Map<ID, Opportunity_Promo_Line_Item__c>([SELECT Duration_Type__c FROM Opportunity_Promo_Line_Item__c WHERE Id IN :idOppLIs]);
        
        List<Subscription_Promo_Line_Item__c> lstSPLIToUpdate = new List<Subscription_Promo_Line_Item__c>();
        
        // For each Subs Promo Line Item linked to sp
        for (Subs_Promotion__c subsPromo : mapSubsPromo.Values())
        {
            System.Debug('## Proceed Subs Promo: ' + subsPromo);
            
            // First start date is equals to the parameter value
            Date currentStart = Date.valueOf(startDate);
            Date currentEnd;
            
            for(Subscription_Promo_Line_Item__c currentSPLI : subsPromo.Subs_Promo_Line_Items__r) 
            {
                System.Debug('## Proceed Subs Promo LI: ' + currentSPLI);
                
                currentSPLI.Start_Date__c = currentStart;
                // Get the duration type from the Opportunity Promo Line Item
                String durType = mapIdOppLI.get(currentSPLI.Opportunity_Promo_Line_Item__c).Duration_Type__c;
                currentEnd = calculateEndDate(currentStart, currentSPLI.Duration_Value__c.intValue(), durType);
                currentSPLI.End_Date__c = currentEnd;
                currentStart = currentEnd;
                lstSPLIToUpdate.add(currentSPLI);
            }
        }
        
        if (lstSPLIToUpdate.size() > 0)
            update lstSPLIToUpdate;
    }
    
    public class DurationException extends Exception { }
}