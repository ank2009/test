/** 
* @author       Aleh Tsilko (aleh_tsilko@epam.com)
* @date         2015 April 28
* @WKTSCRM-1913 ESB_PA_to_ProductsMapping__c unit test
* @verify that ESB_PA_to_ProductsMapping__c custom setting contain all the values from ESB_DataClasses.wktsCompanyProductAccess 
*/
@isTest(SeeAllData = TRUE) public class ESB_CustomSettings_ProductsTest
{
    public static testMethod void Compare_Products()
    {
        Set<String> cs_ProductsKeys = New Set<String>();
        Set<String> cls_ProductKeys = new Set<String> { 'Integration', 'Integration_blocked',
		'ShipperTMS', 'ShipperTMS_blocked', 'ShipperTMS_Slot', 'ShipperTMS_Slot_blocked',
		'ShipperTMS_CO', 'ShipperTMS_CO_blocked', 'ShipperTMS_DOC', 'ShipperTMS_DOC_blocked',
		'ShipperTMS_ROUTE', 'ShipperTMS_ROUTE_blocked', 'ShipperTMS_COST', 'ShipperTMS_COST_blocked',
		'ShipperTMS_FMETRICS', 'ShipperTMS_FMETRICS_blocked',
		'CarrierTMS', 'CarrierTMS_blocked',  
		'FX', 'FX_Start_UK', 'FX_Standard_UK', 'FX_Business_UK', 'FX_Business_Plus_UK', 'FX_Premium_UK', 'FX_One_To_One_UK', 'FX_Business',
		'FX_Start_FR_BNL', 'FX_Standard_FR_BNL', 'FX_Business_FR_BNL', 'FX_Business_Plus_FR_BNL', 'FX_Premium_FR_BNL', 'FX_One_To_One_FR_BNL',
		'FX_Start_South', 'FX_Standard_South', 'FX_Business_South', 'FX_Premium_South', 'FX_Start_CE', 'FX_Standard_CE', 'FX_Business_CE', 
		'FX_Premium_CE', 'FX_Standard_East', 'FX_Business_East', 'FX_Premium_East', 'FX_Act_Base', 'FX_One_To_One_CE', 'FX_One_To_One_East',
		'FX_One_To_One_South', 'FX_Standard_East_6M', 'FX_Standard_East_12M', 'FX_Standard_East_24M', 'FX_Business_East_6M', 'FX_Business_East_12M',
		'FX_Business_East_24M', 'FX_Premium_East_6M', 'FX_Premium_East_12M', 'FX_Premium_East_24M', 'FX_One_To_One_East_6M', 'FX_One_To_One_East_12M',
		'FX_One_To_One_East_24M','FX_Start_FR_BNL_3M', 'FX_Start_FR_BNL_6M', 'FX_Start_FR_BNL_12M', 'FX_Start_FR_BNL_24M','FX_Start_CE_3M', 'FX_Start_CE_6M',
		'FX_Start_CE_12M','FX_Start_CE_24M', 'FX_Start_South_3M', 'FX_Start_South_6M', 'FX_Start_South_12M', 'FX_Start_South_24M','FX_Standard_FR_BNL_3M', 
		'FX_Standard_FR_BNL_6M', 'FX_Standard_FR_BNL_12M', 'FX_Standard_FR_BNL_24M', 'FX_Standard_CE_3M', 'FX_Standard_CE_6M', 'FX_Standard_CE_12M', 
		'FX_Standard_CE_24M','FX_Standard_South_3M', 'FX_Standard_South_6M','FX_Standard_South_12M', 'FX_Standard_South_24M','FX_Business_FR_BNL_3M', 
		'FX_Business_FR_BNL_6M','FX_Business_FR_BNL_12M', 'FX_Business_FR_BNL_24M', 'FX_Business_CE_3M', 'FX_Business_CE_6M', 'FX_Business_CE_12M', 
		'FX_Business_CE_24M','FX_Business_South_3M','FX_Business_South_6M', 'FX_Business_South_12M','FX_Business_South_24M', 'FX_Business_Plus_FR_BNL_3M',
		'FX_Business_Plus_FR_BNL_6M', 'FX_Business_Plus_FR_BNL_12M', 'FX_Business_Plus_FR_BNL_24M','FX_Premium_FR_BNL_3M','FX_Premium_FR_BNL_6M', 
		'FX_Premium_FR_BNL_12M', 'FX_Premium_FR_BNL_24M', 'FX_Premium_CE_3M', 'FX_Premium_CE_6M','FX_Premium_CE_12M', 'FX_Premium_CE_24M', 'FX_Premium_South_3M',
		'FX_Premium_South_6M', 'FX_Premium_South_12M', 'FX_Premium_South_24M','FX_One_To_One_CE_3M','FX_One_To_One_CE_6M', 'FX_One_To_One_CE_12M', 'FX_One_To_One_CE_24M',
		'FX_One_To_One_South_3M', 'FX_One_To_One_South_6M', 'FX_One_To_One_South_12M', 'FX_One_To_One_South_24M','FX_One_To_One_FR_BNL_3M', 'FX_One_To_One_FR_BNL_6M', 
		'FX_One_To_One_FR_BNL_12M', 'FX_One_To_One_FR_BNL_24M','FX_Standard_East_3M', 'FX_Business_East_3M', 'FX_Premium_East_3M', 'FX_One_To_One_East_3M', 
		'TFC', 'TFC_blocked',
		'TPO', 'TPO_blocked',
		'TWCost', 'TWCost_blocked',
		'SPOTBIDDING_CREATE_SPOT', 'SPOTBIDDING_REPLY_SPOT',
		'TenderMgnt', 'TenderMgnt_create_tender', 'TenderMgnt_reply_tender',
		'FMETRICS', 'FMETRICS_blocked',
		'CD_guest', 'CD_approved', 
		'DMS_approved', 'DMS_blocked',
		'CredSafe_approved', 'CredSafe_blocked'};
        for(ESB_PA_to_ProductsMapping__c currCSProduct : [SELECT Name FROM ESB_PA_to_ProductsMapping__c])
        {
            cs_ProductsKeys.add(currCSProduct.Name);
        } 
        if(!cs_ProductsKeys.containsAll(cls_ProductKeys))
        {
            String errorKeys = '';
            for(String currKey :cls_ProductKeys)
            {
                if(!cs_ProductsKeys.contains(currKey))
                {
                    errorKeys = errorKeys + currKey+', ';
                }
            }
            system.debug('***** ESB_CustomSettings_ProductsTest, errors:'+errorKeys);
            system.Assert(FALSE, 'Gaps in Custom Settings for Products:'+errorKeys);            
        }
    }
}