/**
* @author       Aleh Tsilko (aleh_tsilko@epam.com)
* @date         2016 April
* @description  Controller for mass creation Subscription Current Fees
* @jira task    https://issues.wkts.eu/browse/WKTSCRM-2392
**/
public with sharing class TLR_MassCreationSubscCurrentFees2
{
    
    private List<Subs_Package_And_Fee__c> subPackAndFees {get;set;}
    private List<Subscription_Line_Item__c> subLineItems {get;set;}
    private List<Subs_Current_Fee__c> existSubsCurrentFeesPacAndkFee {get;set;}
    private List<Subs_Current_Fee__c> existSubsCurrentFeesLineItems {get;set;}
    
    private static String ERROR_MESSAGE_START_END_DATES = 'End date should be greater than start date';
    private static String ERROR_MESSAGE_TERM_WRONG = 'This items can\'t be assigned in one time';
    private static String ERROR_MESSAGE_NULL_WRONG = 'Assign End Date for prevision Package & Fee';
    private static String ERROR_MESSAGE_STARTDATE_ABSENT = 'You must Enter Value To a Start Date';
    private static String ERROR_MESSAGE_DOUBLE_CURRFEE = 'you must add only one Current Fee this type';
    
    public Subscription__c sub {get;set;}
    public List<Subs_Current_Fee__c> viewPack {get;set;}
    public List<Subs_Current_Fee__c> viewLine {get;set;}
    public String commonStartDate {get;set;}
    private Account account {get;set;}
    public boolean isNotErrors {get;set;}
    public boolean isPackVisible {get;set;}
    public boolean isLineVisible {get;set;}
     
    public Subs_Current_Fee__c ccf {get;set;}
    
    public TLR_MassCreationSubscCurrentFees2(ApexPages.StandardController controller) 
    {
    }
    public TLR_MassCreationSubscCurrentFees2(ApexPages.StandardSetController controller) 
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
                                                 Start_Date__c, 
                                                 End_Date__c 
                                            FROM Subs_Current_Fee__c 
                                           WHERE Subs_Package_And_Fee__c != NULL 
                                             AND Account__c =: sub.Account__c
                                        ORDER BY End_Date__c DESC NULLS FIRST];        
        existSubsCurrentFeesLineItems = [SELECT Id, 
                                                Name, 
                                                Price__c, 
                                                Start_Date__c, 
                                                End_Date__c 
                                           FROM Subs_Current_Fee__c 
                                          WHERE Subscription_Line_Item__c != NULL 
                                            AND Account__c =: sub.Account__c
                                       ORDER BY End_Date__c DESC NULLS FIRST];
        viewPack = new List<Subs_Current_Fee__c>();
        viewLine = new List<Subs_Current_Fee__c>();
        isPackVisible = false;
        isLineVisible = false;
        List<Subs_Current_Fee__c> orderBlockedItems = new List<Subs_Current_Fee__c>();
        if(subLineItems.size() > 0 || subPackAndFees.size() > 0 )
        {
            for(Subs_Package_And_Fee__c pf:subPackAndFees)
            {
                isPackVisible = true;
                if(pf.Name.contains('_blocked'))
                {
                    orderBlockedItems.add(new Subs_Current_Fee__c(Name = pf.Name, Subs_Package_And_Fee__c = pf.ID, Price__c=pf.Sales_Price__c, isSelected__c=false, isExist__c=false, Start_Date__c=null, End_Date__c=null));
                }
                else
                {
                    viewPack.add(new Subs_Current_Fee__c(Name = pf.Name, Subs_Package_And_Fee__c = pf.ID, Price__c=pf.Sales_Price__c, isSelected__c=false, isExist__c=false, Start_Date__c=null, End_Date__c=null));
                }
            }
       
            for(Subs_Current_Fee__c currSubsCurrFee : existSubsCurrentFeesPacAndkFee)
            {
                currSubsCurrFee.isExist__c = true;
                if(currSubsCurrFee.End_Date__c == null)
                {
                    currSubsCurrFee.isSelected__c = true;
                }
            }
            viewPack = sortListSubsCurrFees(viewPack,existSubsCurrentFeesPacAndkFee); 
            orderBlockedItems = sortListSubsCurrFees(orderBlockedItems,existSubsCurrentFeesPacAndkFee);           
            viewPack.addAll(orderBlockedItems);
              
            
            for(Subs_Current_Fee__c currSubsCurrFee : viewPack)
            {
                if((currSubsCurrFee.isExist__c != true) 
                 && currSubsCurrFee.Name.startsWith('CD_')
                 && getMaxEndDate('CD_',existSubsCurrentFeesPacAndkFee) != null)
                {            
                    currSubsCurrFee.Start_Date__c = getMaxEndDate('CD_',existSubsCurrentFeesPacAndkFee); 
                }
                
               if((currSubsCurrFee.isExist__c != true) 
                 && currSubsCurrFee.Name.startsWith('DMS_')
                 && getMaxEndDate('DMS_',existSubsCurrentFeesPacAndkFee) != null)
                {            
                    currSubsCurrFee.Start_Date__c = getMaxEndDate('DMS_',existSubsCurrentFeesPacAndkFee); 
                }
                
                if((currSubsCurrFee.isExist__c != true) 
                 && currSubsCurrFee.Name.startsWith('TFC')
                 && getMaxEndDate('TFC',existSubsCurrentFeesPacAndkFee) != null)
                {            
                    currSubsCurrFee.Start_Date__c = getMaxEndDate('TFC',existSubsCurrentFeesPacAndkFee); 
                }
            }
                                    
            for(Subscription_Line_Item__c li:subLineItems)
            {
                isLineVisible = true;
                viewLine.add(new Subs_Current_Fee__c(Name = li.Name, Subscription_Line_Item__c = li.ID, Price__c=0, isSelected__c=false, isExist__c=false, Start_Date__c=null, End_Date__c=null));
            } 
                                  
            for(Subs_Current_Fee__c currSubsCurrFee : existSubsCurrentFeesLineItems)
            {
                currSubsCurrFee.isExist__c = true;
                if(currSubsCurrFee.End_Date__c == null)
                {
                    currSubsCurrFee.isSelected__c = true;
                }
            }
            viewLine = sortListSubsCurrFees(viewLine,existSubsCurrentFeesLineItems);                                
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
        if(validateTermsPackFees()) numErrors++;
        if(validateDoublePF()) numErrors++;
        
        if(numErrors == 0)
        {     
            try
            {
                List<Subs_Current_Fee__c> newSubsCurrFees = new List<Subs_Current_Fee__c>();
                for(Subs_Current_Fee__c currentLine:viewLine)
                {
                    if(currentLine.isSelected__c
                    && !currentLine.isExist__c)
                    {
                        Subs_Current_Fee__c newCur = new Subs_Current_Fee__c(
                        Name = currentLine.Name, 
                        Start_Date__c = currentLine.Start_Date__c, 
                        Subscription_Line_Item__c = currentLine.Subscription_Line_Item__c, 
                        Subscription__c = sub.Id, 
                        Account__c = sub.Account__c,
                        Price__c = currentLine.Price__c);
                        if(currentLine.End_Date__c != null)
                        {
                            newCur.End_Date__c = currentLine.End_Date__c;
                        }
                        if(currentLine.Price__c == null)
                        {
                            newCur.Price__c = 0;
                        }
                        newSubsCurrFees.add(newCur);                    
                    }
                }
    
                for(Subs_Current_Fee__c currentPack:viewPack)
                {
                    if(currentPack.isSelected__c
                    && !currentPack.isExist__c)
                    {
                        Subs_Current_Fee__c newCur = new Subs_Current_Fee__c(
                        Name = currentPack.Name, 
                        Start_Date__c = currentPack.Start_Date__c,
                        Subs_Package_And_Fee__c= currentPack.Subs_Package_And_Fee__c, 
                        Subscription__c = sub.Id,
                        Account__c = sub.Account__c,
                        Price__c = currentPack.Price__c);
                        if(currentPack.End_Date__c != null)
                        {
                            newCur.End_Date__c = currentPack.End_Date__c;
                        }
                        if(currentPack.Price__c == null)
                        {
                            newCur.Price__c = 0;
                        }
                        newSubsCurrFees.add(newCur);                   
                    }
                }
            
                Map<Id, Subs_Current_Fee__c> existPfOldDates = new Map<Id, Subs_Current_Fee__c>(existSubsCurrentFeesPacAndkFee);        
                List<Subs_Current_Fee__c> updatedExistPFs = New List<Subs_Current_Fee__c>();
                for(Subs_Current_Fee__c currentPack:viewPack)
                {
                if((currentPack.isExist__c)   
                &&(currentPack.isSelected__c) 
                && (currentPack.End_Date__c != null))
                {
                    if(currentPack.Price__c == null)
                        {
                            currentPack.Price__c = 0;
                        }
                    updatedExistPFs.add(currentPack);
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
            for(Subs_Current_Fee__c currTabLine: viewPack)
            {
            
                if((!currTabLine.isExist__c) && (currTabLine.isSelected__c))
                {
                    currTabLine.Start_Date__c = Date.parse(commonStartDate);
                }
            }
        
            for(Subs_Current_Fee__c currTabLine: viewLine)
            {
                if(!currTabLine.isExist__c && (currTabLine.isSelected__c))
                {
                    currTabLine.Start_Date__c = Date.parse(commonStartDate);
                }
            } 
        }      
        return null;
    }
/**********************************************************************************************************************************/    
    private List<Subs_Current_Fee__c> sortListSubsCurrFees (List<Subs_Current_Fee__c> newList, List<Subs_Current_Fee__c> existList)
    {
        List<Subs_Current_Fee__c> sortedList = New List<Subs_Current_Fee__c>();
        for(Subs_Current_Fee__c currNewSubsCurrFee : newList)
        {
            sortedList.add(currNewSubsCurrFee);
            for(Subs_Current_Fee__c currExistPF :existList)
            {
                if(currExistPF.Name == currNewSubsCurrFee.Name)
                {
                    sortedList.add(currExistPF);
                }
            }
        }      
        return sortedList;
    }
    
    
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
        for(Subs_Current_Fee__c currentLine:viewLine)
        {
            if(currentLine.isSelected__c 
            &&(currentLine.Start_Date__c == null))
            {
                result = true;
                currentLine.Start_Date__c.addError(ERROR_MESSAGE_STARTDATE_ABSENT);
            }
        } 
        for(Subs_Current_Fee__c currentLine:viewPack)
        {
            if(currentLine.isSelected__c 
            &&(currentLine.Start_Date__c == null))
            {
                result = true;
                currentLine.Start_Date__c.addError(ERROR_MESSAGE_STARTDATE_ABSENT);
            }
        } 
        return result; 
    }
    
    private boolean validateStartEndDates()
    {      
        boolean result = false;
        for(Subs_Current_Fee__c currentLine:viewLine)
        {
            if(currentLine.isSelected__c 
            &&(currentLine.Start_Date__c >= currentLine.End_Date__c))
            {
                result = true;
                currentLine.End_Date__c.addError(ERROR_MESSAGE_START_END_DATES);
            }
        } 
        for(Subs_Current_Fee__c currentLine:viewPack)
        {
            if(currentLine.isSelected__c 
            &&(currentLine.Start_Date__c >= currentLine.End_Date__c))
            {
                result = true;
                currentLine.End_Date__c.addError(ERROR_MESSAGE_START_END_DATES);
            }
        } 
        return result;
    }

    
    private boolean validateTermsPackFees()
    {
        boolean result = false;
        for(Subs_Current_Fee__c currentPack:viewPack)
        {
            if(currentPack.isSelected__c 
            && !currentPack.isExist__c
            &&(currentPack.Name.startsWith('CD_')
            || currentPack.Name.startsWith('DMS_')
            || currentPack.Name.startsWith('TFC')))
            {
                Date lastPackDate;
                if(currentPack.Name.startsWith('CD_') && checkExistPFNames('CD_'))
                {
                    lastPackDate = getMaxEndDate('CD_',existSubsCurrentFeesPacAndkFee);
                    if(lastPackDate == null)
                    {
                        result = true;
                        currentPack.Start_Date__c.addError(ERROR_MESSAGE_NULL_WRONG);
                    }
                    else if(currentPack.Start_Date__c < lastPackDate)
                    {
                        result = true;
                        currentPack.Start_Date__c.addError(ERROR_MESSAGE_TERM_WRONG);
                    }      
                }
                if(currentPack.Name.startsWith('DMS_') && checkExistPFNames('DMS_'))
                {
                    lastPackDate = getMaxEndDate('DMS_',existSubsCurrentFeesPacAndkFee);
                    if(lastPackDate == null)
                    {
                        result = true;
                        currentPack.Start_Date__c.addError(ERROR_MESSAGE_NULL_WRONG);
                    }
                    else if(currentPack.Start_Date__c < lastPackDate)
                    {
                        result = true;
                        currentPack.Start_Date__c.addError(ERROR_MESSAGE_TERM_WRONG);
                    }                    
                }
                if(currentPack.Name.startsWith('TFC') && checkExistPFNames('TFC'))
                {
                    lastPackDate = getMaxEndDate('TFC',existSubsCurrentFeesPacAndkFee);
                    if(lastPackDate == null)
                    {
                        result = true;
                        currentPack.Start_Date__c.addError(ERROR_MESSAGE_NULL_WRONG);
                    }
                    else if(currentPack.Start_Date__c < lastPackDate)
                    {
                        result = true;
                        currentPack.Start_Date__c.addError(ERROR_MESSAGE_TERM_WRONG);
                    }                    
                }        
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
        for(Subs_Current_Fee__c currentPack:viewPack)
        {
            if(currentPack.isSelected__c 
            && !currentPack.isExist__c)
            {
                if(currentPack.Name.startsWith('CD_')) numberNewCD++; 
                if(currentPack.Name.startsWith('DMS_')) numberNewDMS++;
                if(currentPack.Name.startsWith('TFC')) numberNewTFC++;                        
            }
        } 

system.debug('***** numberNewCD='+numberNewCD+' ,numberNewDMS='+numberNewDMS+' ,numberNewTFC='+numberNewTFC);        
        
        for(Subs_Current_Fee__c currentPack:viewPack)
        {
            if(currentPack.isSelected__c 
            && !currentPack.isExist__c)
            {
                if(currentPack.Name.startsWith('CD_') && (numberNewCD > 1))
                {
                    result = true;
                    currentPack.Start_Date__c.addError('CD:'+ERROR_MESSAGE_DOUBLE_CURRFEE);
                }
                if(currentPack.Name.startsWith('DMS_') && (numberNewCD > 1))
                {
                    result = true;
                    currentPack.Start_Date__c.addError('DMS:'+ERROR_MESSAGE_DOUBLE_CURRFEE);
                }
                if(currentPack.Name.startsWith('TFC') && (numberNewCD > 1))
                {
                    result = true;
                    currentPack.Start_Date__c.addError('TFC:'+ERROR_MESSAGE_DOUBLE_CURRFEE);
                }
            }
        } 
        return result;
    }
/**********************************************************************************************************************************/        
}