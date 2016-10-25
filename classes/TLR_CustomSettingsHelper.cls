public class TLR_CustomSettingsHelper 
{
    public static Map<String,Integer> GetSepaNumber(Map<String,Integer> accountCountryMap)
    {
        Map<string,Sepa_Unique_Number__c> sepaUniqCountryMap = Sepa_Unique_Number__c.getAll();
        List<Sepa_Unique_Number__c> sepaListToUpdate = new List<Sepa_Unique_Number__c>();
        for(String country: accountCountryMap.keySet())
        {
        	Sepa_Unique_Number__c temp = sepaUniqCountryMap.get(country);
            temp.Unique_Number__c += accountCountryMap.get(country);
            sepaListToUpdate.add(temp);
            accountCountryMap.put(country, Integer.valueOf(temp.Unique_Number__c - accountCountryMap.get(country)+1));
        }
        try
        {
            update sepaListToUpdate;
        }
        catch(Exception ex)
        {
            System.Debug('----TLR_CustomSettingsHelper----------Sepa--------'+ex.getMessage());
            throw ex;
        }
        return accountCountryMap;
    }
    
    public static Map<String,Integer> GetDebtorNumber(Map<String,Integer> mapDebtorNumber)
    {
        Map<String, Debtor_Number_Organization__c>    mapDebtorUniqNumber  = Debtor_Number_Organization__c.getAll();
        List<Debtor_Number_Organization__c> debtorListToUpdate = new List<Debtor_Number_Organization__c>();
        for(String country: mapDebtorNumber.keySet())
        {
        	Debtor_Number_Organization__c temp = mapDebtorUniqNumber.get(country);
            temp.Next_Value__c += mapDebtorNumber.get(country);
            debtorListToUpdate.add(temp);
            mapDebtorNumber.put(country, Integer.valueOf(temp.Next_Value__c - mapDebtorNumber.get(country)+1));
        }
        try
        {
            update debtorListToUpdate;
        }
        catch(Exception ex)
        {
            System.Debug('----TLR_CustomSettingsHelper----------Debtor--------'+ex.getMessage());
            throw ex;
        }
        return mapDebtorNumber;
    }
    
    public static Map<String,Integer> GetTelerouteNumber(Map<String,Integer> mapTelNumber)
    {
        Map<String, Teleroute_Number_Organization__c>    mapTelUniqNumber  = Teleroute_Number_Organization__c.getAll();
         List<Teleroute_Number_Organization__c> telListToUpdate = new List<Teleroute_Number_Organization__c>();
        for(String country: mapTelNumber.keySet())
        {
        	Teleroute_Number_Organization__c temp = mapTelUniqNumber.get(country);
            temp.Next_Value__c += mapTelNumber.get(country);
            telListToUpdate.add(temp);
            mapTelNumber.put(country, Integer.valueOf(temp.Next_Value__c - mapTelNumber.get(country)+1));
        }
        try
        {
            update telListToUpdate;
        }
        catch(Exception ex)
        {
            System.Debug('----TLR_CustomSettingsHelper----------Teleroute--------'+ex.getMessage());
            throw ex;
        }
        return mapTelNumber;
    }
    
    public static List<String> GetSubscriptionNumber(Integer countSubs)
    {
        Subscription_Number__c SubsExist = Subscription_Number__c.getValues('TLR Subscription');
        if(SubsExist != null)
        {
            String s        = SubsExist.Subscription_Number__c;
            String prefix   = s.substring(0, s.indexOf('-') + 1);
            String index    = s.substring(s.indexOf('-') + 1, s.length());
            Integer subsNum = Integer.valueOf(index.replaceAll('[^0-9]', '')) + countSubs + 1;
            SubsExist.Subscription_Number__c = prefix + (SubsNum-1);
            try
            {
                update SubsExist;
                List<String> result = new List<String>();
                for(Integer i = Integer.valueOf(index) + 1; i < subsNum; i++)
                {
                    result.add(String.valueOf(prefix + i));
                }
                return result;
            }
            catch(Exception ex)
            {
                System.Debug('----TLR_CustomSettingsHelper----------Subscription--------'+ex.getMessage());
                throw ex;
            }
        } 
        return null;
    }
    
    public static List<String> GetTWAOppProjectNumber(Integer countOpps)
    {
    	General_Settings__c exist = General_Settings__c.getValues('Default');
        List<String> result = new List<String>();
        if(exist != null)
        {
            String currentYear = String.valueOf(System.Today().year());
            String csYear = exist.TWA_Opp_Project_Number__c.split('/')[0];
            Integer currNumber = Integer.valueOf(exist.TWA_Opp_Project_Number__c.split('/')[1]) + 1;
            if(csYear != currentYear)
            {
                currNumber = 1;
            }
            exist.TWA_Opp_Project_Number__c = currentYear + '/' + String.valueOf(currNumber + countOpps-1);
            try
            {
                update exist;
                for(Integer i = currNumber; i < currNumber + countOpps; i++)
                {
                    String magic = String.valueOf(100000 + i);
                    result.add(currentYear + '/' + magic.substring(1));
                }
            }
            catch(Exception ex)
            {
                System.Debug('----TLR_CustomSettingsHelper----------GetTWAOppProjectNumber--------'+ex.getMessage());
                throw ex;
            }
            
        }
        return result;
    }
}