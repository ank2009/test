public with sharing class TLR_CountryCheckComponentController{
/* Used in TLR_CountryCheckComponent 
 * making a differents list for Country Objects & Country Custom Settings
 * 12/12/2014
 * author  aleh_tsilko@epam.com
 */    
    public Map<Integer, Map<Integer,String>> getDifferents(){    
       Map<Integer, Map<Integer,String>> resultDiffList = New Map<Integer, Map<Integer,String>>{};
       Integer I = 0; //Iterator for error strings
	   //prepare data for comparison          
       Map<Id, Country_Parameters__c> countryParam = New Map<Id, Country_Parameters__c>([SELECT Id, Name, ISO2_code__c
                                                                                           FROM Country_Parameters__c]);              

       Map<Id, pw_cc__CountryObject__c> countryComplete = New Map<Id, pw_cc__CountryObject__c>([SELECT Id, Name, pw_cc__IsoCode_2__c
                                                                                                  FROM pw_cc__CountryObject__c]);        
       Map<String, Id> countryName2IdMap = New Map<String, Id>();
       Map<String, Id> countryISO2IdMap = New Map<String, Id>();         
       for(pw_cc__CountryObject__c currCountry : countryComplete.values())
       {
           countryName2IdMap.put(currCountry.Name, currCountry.Id);
           countryISO2IdMap.put(currCountry.pw_cc__IsoCode_2__c, currCountry.Id);
       }       
       
		//1-st check, from Country_Parameters__c to pw_cc__CountryObject__c
       for(Country_Parameters__c currCountry : countryParam.values())
       {
            // if countries has differents - add in diff list        
            if(countryName2IdMap.containsKey(currCountry.Name) 
            && countryISO2IdMap.containsKey(currCountry.ISO2_code__c) 
            && countryName2IdMap.get(currCountry.Name) == countryISO2IdMap.get(currCountry.ISO2_code__c))
            {
            // Country is OK
                countryComplete.remove(countryISO2IdMap.get(currCountry.ISO2_code__c));    
            }
            else if((countryName2IdMap.containsKey(currCountry.Name) && !countryISO2IdMap.containsKey(currCountry.ISO2_code__c)))
            { // Country Country code is Not found
                resultDiffList.put(i,getErrorCountry(currCountry.Id, 
                                                     currCountry.Name, 
                                                     countryName2IdMap.get(currCountry.Name),
                                                     currCountry.Name, 
                                                     'Country Code is Not Found',
                                                     currCountry.ISO2_code__c+' / '+countryComplete.get(countryName2IdMap.get(currCountry.Name)).pw_cc__IsoCode_2__c));
                 i++;
                 countryComplete.remove(countryName2IdMap.get(currCountry.Name));  
             }
            else if(!countryName2IdMap.containsKey(currCountry.Name) && countryISO2IdMap.containsKey(currCountry.ISO2_code__c))
            { //Country Name is Not Found
                resultDiffList.put(i,getErrorCountry(currCountry.Id, 
                                                     currCountry.Name, 
                                                     countryISO2IdMap.get(currCountry.ISO2_code__c),
                                                     countryComplete.get(countryISO2IdMap.get(currCountry.ISO2_code__c)).Name, 
                                                     'Country Name is Not Found',
                                                     currCountry.Name+' / '+ countryComplete.get(countryISO2IdMap.get(currCountry.ISO2_code__c)).Name));                                                                                         
                i++;
                countryComplete.remove(countryName2IdMap.get(currCountry.Name));                                        
            }
            else  if(!(countryName2IdMap.containsKey(currCountry.Name) || countryISO2IdMap.containsKey(currCountry.ISO2_code__c)))//match is not found 
            {
                resultDiffList.put(i,getErrorCountry(currCountry.Id, 
                                                     currCountry.Name, 
                                                     NULL,
                                                     '', 
                                                     'Country Complete is Not Found',
                                                     currCountry.Name+', '+ currCountry.ISO2_code__c+' / Not Found'));       
                i++;
                countryComplete.remove(countryName2IdMap.get(currCountry.Name));  
            }
            else if(countryName2IdMap.containsKey(currCountry.Name) 
	            && countryISO2IdMap.containsKey(currCountry.ISO2_code__c) 
	            && countryName2IdMap.get(currCountry.Name) != countryISO2IdMap.get(currCountry.ISO2_code__c))//Different in ISO Code
	        {
                resultDiffList.put(i,getErrorCountry(currCountry.Id, 
                                                     currCountry.Name, 
                                                     countryName2IdMap.get(currCountry.Name),
                                                     countryComplete.get(countryName2IdMap.get(currCountry.Name)).Name, 
                                                     'Different in ISO Code',
                                                     currCountry.ISO2_code__c+' / '+ countryComplete.get(countryName2IdMap.get(currCountry.Name)).pw_cc__IsoCode_2__c));  
                i++;
                countryComplete.remove(countryName2IdMap.get(currCountry.Name));  
             }
       }//end 1-st check 
           
     
		//2-st.check, add all not founded pw_cc__CountryObject__c
       for(pw_cc__CountryObject__c currCountry : countryComplete.values())
       {
           resultDiffList.put(i,getErrorCountry(NULL,'', currCountry.Id, currCountry.Name, 'Country Parameters is Not Found', 'Not Found / '+ currCountry.Name+', '+currCountry.pw_cc__IsoCode_2__c));    
           i++;            
       } 
       return resultDiffList;
    }
    
    private Map<Integer,String> getErrorCountry(Id countryParam, String paramName, Id countryCompl, String complName,String errLocation,String errorDiff)
    {
        Map<Integer,String> resultLine = New Map<Integer,String>();
        
        if(countryParam != NULL)
        {
            resultLine.put(0,countryParam);
            resultLine.put(1,paramName);
        }
        else
        {
            resultLine.put(0,'');
            resultLine.put(1,'');
        }
        
        if(countryCompl != NULL)
        {
            resultLine.put(2,countryCompl);
            resultLine.put(3,complName);
        }
        else
        {
            resultLine.put(2,'');
            resultLine.put(3,'');
        }        
        resultLine.put(4,errLocation);
        resultLine.put(5,errorDiff);
        return resultLine;
     } 
}