/**
* @author       Aleh Tsilko (aleh_tsilko@epam.com)
* @date         2016 April
* @description  Controller for mass creation Subscription Current Fees
* @jira task    https://issues.wkts.eu/browse/WKTSCRM-2392
**/
public with sharing class TLR_MassCreationSubscCurrentFees
{
    
    private List<Subs_Package_And_Fee__c> subPackAndFees {get;set;}
    private List<Subscription_Line_Item__c> subLineItems {get;set;}
    private List<Subs_Current_Fee__c> existSubsCurrentFeesPacAndkFee {get;set;}
    private List<Subs_Current_Fee__c> existSubsCurrentFeesLineItems {get;set;}
    
    private static String ERROR_MESSAGE_START_END_DATES = 'End date should be greater or equal than start date';
    private static String ERROR_MESSAGE_TERM_WRONG = 'This items can\'t be assigned in one time';
    private static String ERROR_MESSAGE_NULL_WRONG = 'Assign End Date for prevision Package & Fee';
    private static String ERROR_MESSAGE_STARTDATE_ABSENT = 'You must Enter Value To a Start Date';
    private static String ERROR_MESSAGE_DOUBLE_CURRFEE = 'you must add only one Current Fee this type';
    
    @TestVisible
    public class TabRow
    {
        public Subs_Current_Fee__c subCurrFee {get;set;}
        public boolean isSelected {get;set;} 
        public boolean isExist {get;set;}         
    }
    
    public Subscription__c sub {get;set;}
    public List<TabRow> viewPack {get;set;}
    public List<TabRow> viewLine {get;set;}
    public String commonStartDate {get;set;}
    private Account account {get;set;}
    public boolean isNotErrors {get;set;}
    public boolean isPackVisible {get;set;}
    public boolean isLineVisible {get;set;}
    
/*************************************************************************************************************************************************************************************/    
    public TLR_MassCreationSubscCurrentFees(ApexPages.StandardController controller) 
    {
    }
    public TLR_MassCreationSubscCurrentFees(ApexPages.StandardSetController controller) 
    {
        Id subId = ApexPages.CurrentPage().getParameters().get('id');
        if(subId != null)
        {
            sub = [Select Id, Name, Account__c, Contract__r.Invoice_Level__c From Subscription__c Where Id =: subId];
        }
        InitPage();
    }
    
    public void InitPage()
    {        
        subPackAndFees = [Select Id, Name, Sales_Price__c From Subs_Package_And_Fee__c Where Subscription__c =: sub.Id];
        subLineItems = [Select Id, Name, Sales_Price__c From Subscription_Line_Item__c  Where Subscription__c =: sub.Id];
        existSubsCurrentFeesPacAndkFee = [SELECT Id, 
                                                 Name, 
                                                 Price__c, 
                                                 Account__c,
                                                 Case__c,
                                                 Start_Date__c, 
                                                 End_Date__c,
                                                 Notes__c
                                            FROM Subs_Current_Fee__c 
                                           WHERE Subs_Package_And_Fee__c != NULL 
                                             AND Account__c =: sub.Account__c
                                        ORDER BY End_Date__c DESC NULLS FIRST];        
        existSubsCurrentFeesLineItems = [SELECT Id, 
                                                Name, 
                                                Price__c, 
                                                Account__c,
                                                Case__c,
                                                Start_Date__c, 
                                                End_Date__c,
                                                Notes__c 
                                           FROM Subs_Current_Fee__c 
                                          WHERE Subscription_Line_Item__c != NULL 
                                            AND Account__c =: sub.Account__c
                                       ORDER BY End_Date__c DESC NULLS FIRST];
        viewPack = new List<TabRow>();
        viewLine = new List<TabRow>();
        isPackVisible = false;
        isLineVisible = false;
        List<TabRow> orderBlockedItems = new List<TabRow>();
        if(subLineItems.size() > 0 || subPackAndFees.size() > 0 )
        {
            for(Subs_Package_And_Fee__c pf:subPackAndFees)
            {
                isPackVisible = true;
                if(pf.Name.contains('_blocked'))
                {
                    orderBlockedItems.add(newTabRow(false, false,new Subs_Current_Fee__c(Name = pf.Name, 
                                                                                         Subs_Package_And_Fee__c = pf.ID, 
                                                                                         Price__c = pf.Sales_Price__c, 
                                                                                         Account__c = sub.Account__c, 
                                                                                         Case__c = null,
                                                                                         Start_Date__c=null, 
                                                                                         End_Date__c=null,
                                                                                         Notes__c = '')));
                }
                else
                {
                    viewPack.add(newTabRow(false,false,new Subs_Current_Fee__c(Name = pf.Name, 
                                                                               Subs_Package_And_Fee__c = pf.ID, 
                                                                               Price__c=pf.Sales_Price__c, 
                                                                               Account__c = sub.Account__c,
                                                                               Case__c = null, 
                                                                               Start_Date__c = null, 
                                                                               End_Date__c = null,
                                                                               Notes__c = '')));
                }
            }
       
            List<TabRow> existTR = New List<TabRow>();
            for(Subs_Current_Fee__c currSubsCurrFee : existSubsCurrentFeesPacAndkFee)
            {    
                TabRow newTR = New TabRow ();
                newTR.isExist = true;
                if(currSubsCurrFee.End_Date__c == null)
                {
                    newTR.isSelected = true;
                }
                else
                {
                    newTR.isSelected = false;
                }    
                newTR.subCurrFee = currSubsCurrFee; 
                existTR.Add(newTR);
            }
            
            viewPack = sortListSubsCurrFees(viewPack,existTR); 
            orderBlockedItems = sortListSubsCurrFees(orderBlockedItems,existTR);
            viewPack.addAll(orderBlockedItems);
            
            for(TabRow currSubsCurrFee : viewPack)
            {
                if((currSubsCurrFee.isExist != true) 
                 && currSubsCurrFee.subCurrFee.Name.startsWith('CD_')
                 && getMaxEndDate('CD_',existSubsCurrentFeesPacAndkFee) != null)
                {            
                    currSubsCurrFee.subCurrFee.Start_Date__c = getMaxEndDate('CD_',existSubsCurrentFeesPacAndkFee); 
                }
                
               if((currSubsCurrFee.isExist != true) 
                 && currSubsCurrFee.subCurrFee.Name.startsWith('DMS_')
                 && getMaxEndDate('DMS_',existSubsCurrentFeesPacAndkFee) != null)
                {            
                    currSubsCurrFee.subCurrFee.Start_Date__c = getMaxEndDate('DMS_',existSubsCurrentFeesPacAndkFee); 
                }
                
                if((currSubsCurrFee.isExist != true) 
                 && currSubsCurrFee.subCurrFee.Name.startsWith('TFC')
                 && getMaxEndDate('TFC',existSubsCurrentFeesPacAndkFee) != null)
                {            
                    currSubsCurrFee.subCurrFee.Start_Date__c = getMaxEndDate('TFC',existSubsCurrentFeesPacAndkFee); 
                }
            }
                                    
            for(Subscription_Line_Item__c li:subLineItems)
            {
                isLineVisible = true;
                viewLine.add(newTabRow(false,false,new Subs_Current_Fee__c(Name = li.Name, 
                                                                           Subscription_Line_Item__c = li.ID, 
                                                                           Price__c=0, 
                                                                           Account__c = sub.Account__c,
                                                                           Case__c = null, 
                                                                           Start_Date__c = null, 
                                                                           End_Date__c = null,
                                                                           Notes__c = '')));
            } 
                
            existTR.clear();                      
            for(Subs_Current_Fee__c currSubsCurrFee : existSubsCurrentFeesLineItems)
            {
                TabRow newTR = New TabRow();
                newTR.isExist = true;
                if(currSubsCurrFee.End_Date__c == null)
                {
                    newTR.isSelected = true;
                }
                else
                {
                    newTR.isSelected = false;
                }
                existTR.add(newTR);
            } 
            viewLine = sortListSubsCurrFees(viewLine,existTR);                                
            isNotErrors = true;             
        }
        else
        {
            isNotErrors = false;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Subscription not contains Package and Fees and Subscription Line Item');
            ApexPages.addMessage(myMsg);
        }
    }
   
    public PageReference Save()
    {   
        Integer numErrors = 0;                
        if(validateStartDates()) numErrors++; 
        if(validateStartEndDates()) numErrors++;
        //removed for Mabel request  if(validateTermsPackFees()) numErrors++; 
        if(validateDoublePF()) numErrors++;        
        
        if(numErrors == 0)
        {     
            try
            {
                List<Subs_Current_Fee__c> newSubsCurrFees = new List<Subs_Current_Fee__c>();
                for(TabRow currentLine:viewLine)
                {
                    if(currentLine.isSelected
                    && !currentLine.isExist)
                    {
                        Subs_Current_Fee__c newCur = new Subs_Current_Fee__c(
                        Name = currentLine.subCurrFee.Name, 
                        Start_Date__c = currentLine.subCurrFee.Start_Date__c, 
                        Subscription_Line_Item__c = currentLine.subCurrFee.Subscription_Line_Item__c, 
                        Subscription__c = sub.Id, 
                        Account__c = currentLine.subCurrFee.Account__c,
                        Case__c = currentLine.subCurrFee.Case__c,
                        Price__c = currentLine.subCurrFee.Price__c,
                        Notes__c = currentLine.subCurrFee.Notes__c);
                        if(currentLine.subCurrFee.End_Date__c != null)
                        {
                            newCur.End_Date__c = currentLine.subCurrFee.End_Date__c;
                        }
                        if(currentLine.subCurrFee.Price__c == null)
                        {
                            newCur.Price__c = 0;
                        }
                        newSubsCurrFees.add(newCur);                    
                    }
                }
    
                for(TabRow currentPack:viewPack)
                {
                    if(currentPack.isSelected
                    && !currentPack.isExist)
                    {
                        Subs_Current_Fee__c newCur = new Subs_Current_Fee__c(
                        Name = currentPack.subCurrFee.Name, 
                        Start_Date__c = currentPack.subCurrFee.Start_Date__c,
                        Subs_Package_And_Fee__c= currentPack.subCurrFee.Subs_Package_And_Fee__c, 
                        Subscription__c = sub.Id,
                        Account__c = currentPack.subCurrFee.Account__c,
                        Case__c = currentPack.subCurrFee.Case__c,
                        Price__c = currentPack.subCurrFee.Price__c,
                        Notes__c = currentPack.subCurrFee.Notes__c);
                        if(currentPack.subCurrFee.End_Date__c != null)
                        {
                            newCur.End_Date__c = currentPack.subCurrFee.End_Date__c;
                        }
                        if(currentPack.subCurrFee.Price__c == null)
                        {
                            newCur.Price__c = 0;
                        }
                        newSubsCurrFees.add(newCur);                   
                    }
                }
            
                Map<Id, Subs_Current_Fee__c> existPfOldDates = new Map<Id, Subs_Current_Fee__c>(existSubsCurrentFeesPacAndkFee);        
                List<Subs_Current_Fee__c> updatedExistPFs = New List<Subs_Current_Fee__c>();
                for(TabRow currentPack:viewPack)
                {
                    if(currentPack.isExist)   
                    {
                        updatedExistPFs.add(currentPack.subCurrFee);
                    }
                }                         
                if(newSubsCurrFees.size()>0)
                {             
                    insert newSubsCurrFees;
                }        
                if(updatedExistPFs.Size() > 0)
                {
                    upsert updatedExistPFs;
                } 
            }
            catch(Exception ex)
            {      
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Mass create error:'+ex));
                return null;
            }
            return (Utilities.Redirect(sub.Id));
        }
        else
        {
            return null;
        } 
    }
    
    public PageReference Cancel()
    {   
        return (Utilities.Redirect(sub.Id));
    }
    
    
    public PageReference ChangeDatePattern()
    {
        if(!String.isBlank(commonStartDate))
        {
            for(TabRow currTabLine: viewPack)
            {
            
                if((!currTabLine.isExist) && (currTabLine.isSelected))
                {
                    currTabLine.subCurrFee.Start_Date__c = Date.parse(commonStartDate);
                }
            }
        
            for(TabRow currTabLine: viewLine)
            {
                if(!currTabLine.isExist && (currTabLine.isSelected))
                {
                    currTabLine.subCurrFee.Start_Date__c = Date.parse(commonStartDate);
                }
            } 
        }      
        return null;
    }
/**********************************************************************************************************************************/    
    private List<TabRow> sortListSubsCurrFees (List<TabRow> newList, List<TabRow> existList)
    {
        List<TabRow> sortedList = New List<TabRow>();
        for(TabRow currNewSubsCurrFee : newList)
        {
            sortedList.add(currNewSubsCurrFee);
            for(TabRow currExistPF :existList)
            {
                if(currExistPF.subCurrFee.Name == currNewSubsCurrFee.subCurrFee.Name)
                {
                    sortedList.add(currExistPF);
                }
            }
        }      
        return sortedList;
    }
    
    @TestVisible
    private Date getMaxEndDate(String pfName, List<Subs_Current_Fee__c> inPfList)
    {
        Date resDate;
        Boolean isEmptyEndDate = false;
        List<Subs_Current_Fee__c> selectedPfList = New List <Subs_Current_Fee__c>();
        for(Subs_Current_Fee__c currInSub : inPfList)
        {
          if(currInSub.Name.startsWith(pfName))
          {
              selectedPfList.add(currInSub);
          }
        }
        
        if(selectedPfList.Size() > 0)
        { 
            for(Subs_Current_Fee__c currInSub : selectedPfList)
            {
                if(currInSub.End_Date__c == null)
                {
                    isEmptyEndDate = true;
                } 
            }
            if(!isEmptyEndDate)
            {
                resDate = selectedPfList.get(0).End_Date__c;            
                for(Subs_Current_Fee__c currInSub : selectedPfList)
                {
                    if(currInSub.End_Date__c > resDate)
                    {
                        resDate = currInSub.End_Date__c;
                    }                  
                }
            }
        }       
        return resDate;
    }
    

    private boolean validateStartDates()
    {
        boolean result = false;
        for(TabRow currentLine:viewLine)
        {
            if(currentLine.isSelected 
            &&(currentLine.subCurrFee.Start_Date__c == null))
            {
                result = true;
                currentLine.subCurrFee.Start_Date__c.addError(ERROR_MESSAGE_STARTDATE_ABSENT);
            }
        } 
        for(TabRow currentLine:viewPack)
        {
            if(currentLine.isSelected 
            &&(currentLine.subCurrFee.Start_Date__c == null))
            {
                result = true;
                currentLine.subCurrFee.Start_Date__c.addError(ERROR_MESSAGE_STARTDATE_ABSENT);
            }
        } 
        return result; 
    }
    
    private boolean validateStartEndDates()
    {      
        boolean result = false;
        for(TabRow currentLine:viewLine)
        {
            if(currentLine.isSelected 
            &&(currentLine.subCurrFee.Start_Date__c > currentLine.subCurrFee.End_Date__c))
            {
                result = true;
                currentLine.subCurrFee.End_Date__c.addError(ERROR_MESSAGE_START_END_DATES);
            }
        } 
        for(TabRow currentLine:viewPack)
        {
            if(currentLine.isSelected 
            &&(currentLine.subCurrFee.Start_Date__c > currentLine.subCurrFee.End_Date__c))
            {
                result = true;
                currentLine.subCurrFee.End_Date__c.addError(ERROR_MESSAGE_START_END_DATES);
            }
        } 
        return result;
    }
    
    
    private boolean checkExistPFNames(String newPFName)
    {
        boolean result = false;
        Set<String> existNames = New Set<String>();
        if(existSubsCurrentFeesPacAndkFee.Size() > 0)
        {
            for(Subs_Current_Fee__c existPF:existSubsCurrentFeesPacAndkFee)
            {
                existNames.add(existPF.Name);
            }
            for(String existName:existNames)
            {
                if(existName.startsWith(newPFName))
                {
                    result = true;
                }
            }
        }
        return result;   
    }
    
    private boolean validateDoublePF()
    {
        Boolean result = false;
        Integer numberNewCD = 0;
        Integer numberNewDMS = 0;
        Integer numberNewTFC = 0;
        for(TabRow currentPack:viewPack)
        {
            if(currentPack.isSelected 
            && !currentPack.isExist)
            {
                if(currentPack.subCurrFee.Name.startsWith('CD_')) numberNewCD++; 
                if(currentPack.subCurrFee.Name.startsWith('DMS_')) numberNewDMS++;
                if(currentPack.subCurrFee.Name.startsWith('TFC')) numberNewTFC++;                        
            }
        }     
        
        for(TabRow currentPack:viewPack)
        {
            if(currentPack.isSelected 
            && !currentPack.isExist)
            {
                if(currentPack.subCurrFee.Name.startsWith('CD_') && (numberNewCD > 1))
                {
                    result = true;
                    currentPack.subCurrFee.Start_Date__c.addError('CD:'+ERROR_MESSAGE_DOUBLE_CURRFEE);
                }
                if(currentPack.subCurrFee.Name.startsWith('DMS_') && (numberNewCD > 1))
                {
                    result = true;
                    currentPack.subCurrFee.Start_Date__c.addError('DMS:'+ERROR_MESSAGE_DOUBLE_CURRFEE);
                }
                if(currentPack.subCurrFee.Name.startsWith('TFC') && (numberNewCD > 1))
                {
                    result = true;
                    currentPack.subCurrFee.Start_Date__c.addError('TFC:'+ERROR_MESSAGE_DOUBLE_CURRFEE);
                }
            }
        } 
        return result;
    }
    
    private TabRow newTabRow(boolean inIsExist, boolean inIsSelect, Subs_Current_Fee__c inCurrFee)
    {
        TabRow result = New TabRow();
        result.subCurrFee = inCurrFee;
        result.isSelected = inIsSelect;
        result.isExist = inIsExist;
        return result;
    }
    
/**********************************************************************************************************************************/        
}