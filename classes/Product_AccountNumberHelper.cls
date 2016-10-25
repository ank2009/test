public with sharing class Product_AccountNumberHelper
{
    public static void getAccountNumbers(Account[] TWA_accounts, Account[] TAS_accounts){
        Boolean updateOk; 
        //prepare list accounts for update        
        List<Account> TWA_acc2update = New List<Account>();       
        List<Account> TAS_acc2update = New List<Account>();
                    
        if (TWA_accounts.size() > 0){
            for(Account curracc: TWA_accounts)
            {
                if(String.isEmpty(curracc.Debtor_Number_TWD__c)) {TWA_acc2update.add(curracc);}
            }   
        }

        if (TAS_accounts.size() > 0){        
            for(Account curracc: TAS_accounts)
            {
                if(String.isEmpty(curracc.Debtor_Number_TAS__c)) {TAS_acc2update.add(curracc);}
            }          
        } 
               
        //update noDebtorNumber accounts 
        do {
            try {
                updateOK = true;
                List<Debtor_Number_Products__c> prodNums = New List<Debtor_Number_Products__c>([SELECT Name, 
                                                                                                       Current_Number__c 
                                                                                                  FROM Debtor_Number_Products__c 
                                                                                                   FOR UPDATE]);                
                for(Debtor_Number_Products__c currSet :prodNums){
                    if(currSet.Name == 'TWD'){               
                        for(Account currAcc: TWA_acc2update){
                            currSet.Current_Number__c ++;
                            currAcc.Debtor_Number_TWD__c = 'TR5' + num2label(currSet.Current_Number__c);                              
                        }
                    }
                    if(currSet.Name == 'TAS'){                
                        for(Account currAcc: TAS_acc2update){
                            currSet.Current_Number__c ++;
                            currAcc.Debtor_Number_TAS__c = 'TA' + num2labelTAS(currSet.Current_Number__c); 
                        }
                    }
                         
                }
                TWA_acc2update.addAll(TAS_acc2update);
                update prodNums;
           } catch (QueryException e) {
               updateOK = false;
           }
        } while (!updateOK);         
        update TWA_acc2update;                
    }
    
    private static String num2label(Decimal inNum){    
        String labelStr = String.valueOf(inNum);
        while(labelStr.length() < 6){labelStr = '0' + labelStr;}
        return labelStr; 
    } 
    
    private static String num2labelTAS(Decimal inNum){    
        String labelStr = String.valueOf(inNum);
        while(labelStr.length() < 8){labelStr = '0' + labelStr;}
        return labelStr; 
    } 

}//end class