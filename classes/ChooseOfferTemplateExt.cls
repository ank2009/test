public class ChooseOfferTemplateExt 
{   
    public class wrapper
    {
        String cond;
        ID id;
        
        public wrapper(ID i, String s)
        {
            cond = s;
            id = i;
        }
    }
    
    private final Opportunity opp;
    
    public String accId {get; set;}
    public String lstOT {get; set;}
    public Boolean evalDone {get; set;}
    public String selectedOT { get; set; }
    public List<SelectOption> optionsOT;
    public Boolean error {get; set;}
    
    public ChooseOfferTemplateExt(ApexPages.StandardController controller) 
    {
        evalDone   = false;
        ID oppId   = System.currentPagereference().getParameters().get('id');
        this.opp   = [SELECT Id, Offer_Accepted_By__c, AccountId, StageName, CloseDate, Offer_Template__c, Maximum_Invoice_Amount__c, CurrencyIsoCode, Product_Interest__c FROM Opportunity WHERE ID = :oppId];
        this.accId = this.opp.AccountId;
    }
    
    public ChooseOfferTemplateExt(Id opportunityId) 
    {
        this.opp   = [SELECT Id, Offer_Accepted_By__c, AccountId, StageName, CloseDate, Offer_Template__c, Maximum_Invoice_Amount__c, CurrencyIsoCode, Product_Interest__c FROM Opportunity WHERE ID = :opportunityId]; 
        this.accId = this.opp.AccountId;       
    }
    
    public PageReference init()
    {
        if (this.opp.StageName =='Closed Won')
        {
            error = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'You cannot attach an offer template to an opportunity that is already closed won.'));
        }
        if (this.opp.CloseDate <Date.Today())
        {
            error = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'You cannot attach an offer template to an opportunity whose close date is in the past.'));
        }
        if(this.opp.Offer_Accepted_By__c != null)
        {
            error = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'You cannot attach an offer template to an opportunity that has already been accepted.'));
        }
        if(opp.Product_Interest__c == 'TAS')
        {
            return Utilities.Redirect('apex/ChooseTASOfferTemplate?id=' + opp.Id);
        }
        return null;
    }
    
    
    
    @RemoteAction
    public static List<wrapper> algo(String accId)
    {
        Account acc;
        User u;
        Set<String> accountFields = new Set<String>();
        Set<String> userFields    = new Set<String>();
        
        // retrieve all offer templates
        List<Offer_Template__c> otList = retrieveAllOfferTemplates(); // 1st SOQL query
        
        // for each offer template
        for(Offer_Template__c currentOT: otList)
        {
            // get its conditions
            List<OTCondition> conditions = getConditions(currentOT.Eligibility_Criteria_Int__c);
            
            if (conditions != null)
            {
                // update accountFields & userFields sets
                for(OTCondition currentOTC : conditions)
                {
                    String otcType = currentOTC.objectType;
                    if(otcType.equals('account'))
                    {
                        accountFields.add(currentOTC.objectFieldName);
                    }
                    else if(otcType.equals('user'))
                    {
                        userFields.add(currentOTC.objectFieldName);
                    }
                }
            }
        }
        
        if (accountFields.size() > 0)
            acc = queryAccount(accountFields, accId); // 2nd SOQL query
        if (userFields.size() > 0)
            u = queryUser(userFields); // 3rd SOQL query
        
        List<wrapper> wrappers = new List<wrapper>();
        
        for(Offer_Template__c currentOT: otList)
        {   
            // get filter logic
            String filter = getFilterLogic(currentOT.Eligibility_Criteria_Int__c);
            
            // get conditions
            List<OTCondition> conditions = getConditions(currentOT.Eligibility_Criteria_Int__c);
            
            if (filter != null)
            {
                // apply filter to conditions
                applyFilterLogic(filter, conditions, acc, u);
                
                String cond = filter;
                for (Integer i = conditions.size(); i >= 1; i--)
                    cond = cond.replace(i.format(), conditions[i-1].isTrue ? 'true ' : 'false ');
                
                wrappers.add(new wrapper(currentOT.id, cond));
            }
            else
                wrappers.add(new wrapper(currentOT.id, 'true'));
        }
        
        System.Debug('## wrappers: ' + wrappers);
        
        return wrappers;
    }
    
    private static void applyFilterLogic(String filter, List<OTCondition> conditions, Account acc, User u)
    {
        // Test each condition and store the results
        List<Boolean> condResults = new List<Boolean>();
        for(OTCondition currentCondition: conditions)
        {
            // switch on operator
            if(currentCondition.operator == 'eq') // equals
            {
                // switch on format
                if(   currentCondition.fieldType == Schema.DisplayType.String
                   || currentCondition.fieldType == Schema.DisplayType.PickList
                   || currentCondition.fieldType == Schema.DisplayType.MultiPicklist
                   || currentCondition.fieldType == Schema.DisplayType.Email
                   || currentCondition.fieldType == Schema.DisplayType.Phone
                   || currentCondition.fieldType == Schema.DisplayType.TextArea
                   || currentCondition.fieldType == Schema.DisplayType.URL)
                {
                    String fieldName = currentCondition.objectFieldName;
                    String fieldValue;
                    List<String> values = currentCondition.getValues();
                    
                    if(currentCondition.objectType == 'account')
                    {
                        fieldValue = (String) acc.get(fieldName);
                    }
                    if(currentCondition.objectType == 'user')
                    {
                        fieldValue = (String) u.get(fieldName);
                    }
                    if(values != null)
                    {
                        for(String currVal : values) // Apply OR between values (-> stop at first occurence of TRUE)
                        {
                            if(fieldValue == currVal)
                            {
                                currentCondition.isTrue = true;
                                break;
                            }
                        }
                    }
                    else
                    {
                        currentCondition.isTrue = (fieldValue == null);
                    }
                }
                if(currentCondition.fieldType == Schema.DisplayType.Integer)
                {
                    String fieldName = currentCondition.objectFieldName;
                    Integer fieldValue;
                    List<String> values = currentCondition.getValues();
                    
                    if(currentCondition.objectType == 'account')
                    {
                        fieldValue = (Integer) acc.get(fieldName);
                    }
                    if(currentCondition.objectType == 'user')
                    {
                        fieldValue = (Integer) u.get(fieldName);
                    }
                    
                    if(values != null)
                    {
                        for(String currVal : values) // Apply OR between values (-> stop at first occurence of TRUE)
                        {
                            if(fieldValue == Integer.valueOf(currVal))
                            {
                                currentCondition.isTrue = true;
                                break;
                            }
                        }
                    }
                    else
                    {
                        currentCondition.isTrue = (fieldValue == null);
                    }
                }
                if(   currentCondition.fieldType == Schema.DisplayType.Double
                   || currentCondition.fieldType == Schema.DisplayType.Currency
                   || currentCondition.fieldType == Schema.DisplayType.Percent)
                {
                    String fieldName = currentCondition.objectFieldName;
                    Double fieldValue;
                    List<String> values = currentCondition.getValues();
                    
                    if(currentCondition.objectType == 'account')
                    {
                        fieldValue = (Double) acc.get(fieldName);
                    }
                    if(currentCondition.objectType == 'user')
                    {
                        fieldValue = (Double) u.get(fieldName);
                    }
                    
                    if(values != null)
                    {
                        for(String currVal : values) // Apply OR between values (-> stop at first occurence of TRUE)
                        {
                            if(fieldValue == Double.valueOf(currVal))
                            {
                                currentCondition.isTrue = true;
                                break;
                            }
                        }
                    }
                    else
                    {
                        currentCondition.isTrue = (fieldValue == null);
                    }
                }
                if(currentCondition.fieldType == Schema.DisplayType.Date)
                {
                    String fieldName = currentCondition.objectFieldName;
                    Date fieldValue;
                    List<String> values = currentCondition.getValues();
                    
                    if(currentCondition.objectType == 'account')
                    {
                        fieldValue = (Date) acc.get(fieldName);
                    }
                    if(currentCondition.objectType == 'user')
                    {
                        fieldValue = (Date) u.get(fieldName);
                    }
                    if(values != null)
                    {
                        for(String currVal : values) // Apply OR between values (-> stop at first occurence of TRUE)
                        {
                            if(fieldValue != null)
                            {
                                if(fieldValue.isSameDay(Date.valueOf(currVal)))
                                {
                                    currentCondition.isTrue = true;
                                    break;
                                }
                            }
                        }
                    }
                    else
                    {
                        currentCondition.isTrue = (fieldValue == null);
                    }
                }
                if(currentCondition.fieldType == Schema.DisplayType.DateTime)
                {
                    String fieldName = currentCondition.objectFieldName;
                    DateTime fieldValue;
                    List<String> values = currentCondition.getValues();
                    
                    if(currentCondition.objectType == 'account')
                    {
                        fieldValue = (DateTime) acc.get(fieldName);
                    }
                    if(currentCondition.objectType == 'user')
                    {
                        fieldValue = (DateTime) u.get(fieldName);
                    }
                    
                    if(values != null)
                    {
                        for(String currVal : values) // Apply OR between values (-> stop at first occurence of TRUE)
                        {
                            if(fieldValue != null)
                            {
                                if(fieldValue.isSameDay(DateTime.valueOf(currVal)))
                                {
                                    currentCondition.isTrue = true;
                                    break;
                                }
                            }
                        }
                    }
                    else
                    {
                        currentCondition.isTrue = (fieldValue == null);
                    }
                }
                if(currentCondition.fieldType == Schema.DisplayType.Boolean)
                {
                    String fieldName = currentCondition.objectFieldName;
                    Boolean fieldValue;
                    List<String> values = currentCondition.getValues();
                    
                    if(currentCondition.objectType == 'account')
                    {
                        fieldValue = (Boolean) acc.get(fieldName);
                    }
                    if(currentCondition.objectType == 'user')
                    {
                        fieldValue = (Boolean) u.get(fieldName);
                    }
                    
                    if(values != null)
                    {
                        for(String currVal : values) // Apply OR between values (-> stop at first occurence of TRUE)
                        {
                            if(fieldValue == Boolean.valueOf(currVal))
                            {
                                currentCondition.isTrue = true;
                                break;
                            }
                        }
                    }
                    else
                    {
                        currentCondition.isTrue = (fieldValue == null);
                    }
                }
            }
            if(currentCondition.operator == 'neq') // not equals to
            {
                // switch on format
                if(   currentCondition.fieldType == Schema.DisplayType.String
                   || currentCondition.fieldType == Schema.DisplayType.PickList
                   || currentCondition.fieldType == Schema.DisplayType.MultiPicklist
                   || currentCondition.fieldType == Schema.DisplayType.Email
                   || currentCondition.fieldType == Schema.DisplayType.Phone
                   || currentCondition.fieldType == Schema.DisplayType.TextArea
                   || currentCondition.fieldType == Schema.DisplayType.URL)
                {
                    String fieldName = currentCondition.objectFieldName;
                    String fieldValue;
                    List<String> values = currentCondition.getValues();
                    
                    if(currentCondition.objectType == 'account')
                    {
                        fieldValue = (String) acc.get(fieldName);
                    }
                    if(currentCondition.objectType == 'user')
                    {
                        fieldValue = (String) u.get(fieldName);
                    }
                    
                    if(values != null)
                    {
                        for(String currVal : values) // Apply OR between values (-> stop at first occurence of TRUE)
                        {
                            if(fieldValue != currVal)
                            {
                                currentCondition.isTrue = true;
                                break;
                            }
                        }
                    }
                    else
                    {
                        currentCondition.isTrue = (fieldValue == null);
                    }
                }
                if(currentCondition.fieldType == Schema.DisplayType.Integer)
                {
                    String fieldName = currentCondition.objectFieldName;
                    Integer fieldValue;
                    List<String> values = currentCondition.getValues();
                    
                    if(currentCondition.objectType == 'account')
                    {
                        fieldValue = (Integer) acc.get(fieldName);
                    }
                    if(currentCondition.objectType == 'user')
                    {
                        fieldValue = (Integer) u.get(fieldName);
                    }
                    
                    if(values != null)
                    {
                        for(String currVal : values) // Apply OR between values (-> stop at first occurence of TRUE)
                        {
                            if(fieldValue != Integer.valueOf(currVal))
                            {
                                currentCondition.isTrue = true;
                                break;
                            }
                        }
                    }
                    else
                    {
                        currentCondition.isTrue = (fieldValue == null);
                    }
                }
                if(   currentCondition.fieldType == Schema.DisplayType.Double
                   || currentCondition.fieldType == Schema.DisplayType.Currency
                   || currentCondition.fieldType == Schema.DisplayType.Percent)
                {
                    String fieldName = currentCondition.objectFieldName;
                    Double fieldValue;
                    List<String> values = currentCondition.getValues();
                    
                    if(currentCondition.objectType == 'account')
                    {
                        fieldValue = (Double) acc.get(fieldName);
                    }
                    if(currentCondition.objectType == 'user')
                    {
                        fieldValue = (Double) u.get(fieldName);
                    }
                    
                    if(values != null)
                    {
                        for(String currVal : values) // Apply OR between values (-> stop at first occurence of TRUE)
                        {
                            if(fieldValue != Double.valueOf(currVal))
                            {
                                currentCondition.isTrue = true;
                                break;
                            }
                        }
                    }
                    else
                    {
                        currentCondition.isTrue = (fieldValue == null);
                    }
                }
                if(currentCondition.fieldType == Schema.DisplayType.Date)
                {
                    String fieldName = currentCondition.objectFieldName;
                    Date fieldValue;
                    List<String> values = currentCondition.getValues();
                    
                    if(currentCondition.objectType == 'account')
                    {
                        fieldValue = (Date) acc.get(fieldName);
                    }
                    if(currentCondition.objectType == 'user')
                    {
                        fieldValue = (Date) u.get(fieldName);
                    }
                    
                    if(values != null)
                    {
                        for(String currVal : values) // Apply OR between values (-> stop at first occurence of TRUE)
                        {
                            if(fieldValue != null)
                            {
                                if(!fieldValue.isSameDay(Date.valueOf(currVal)))
                                {
                                    currentCondition.isTrue = true;
                                    break;
                                }
                            }
                        }
                    }
                    else
                    {
                        currentCondition.isTrue = (fieldValue == null);
                    }
                }
                if(currentCondition.fieldType == Schema.DisplayType.DateTime)
                {
                    String fieldName = currentCondition.objectFieldName;
                    DateTime fieldValue;
                    List<String> values = currentCondition.getValues();
                    
                    if(currentCondition.objectType == 'account')
                    {
                        fieldValue = (DateTime) acc.get(fieldName);
                    }
                    if(currentCondition.objectType == 'user')
                    {
                        fieldValue = (DateTime) u.get(fieldName);
                    }
                    
                    if(values != null)
                    {
                        for(String currVal : values) // Apply OR between values (-> stop at first occurence of TRUE)
                        {
                            if(fieldValue != null)
                            {
                                if(!fieldValue.isSameDay(DateTime.valueOf(currVal)))
                                {
                                    currentCondition.isTrue = true;
                                    break;
                                }
                            }
                        }
                    }
                    else
                    {
                        currentCondition.isTrue = (fieldValue == null);
                    }
                }
                if(currentCondition.fieldType == Schema.DisplayType.Boolean)
                {
                    String fieldName = currentCondition.objectFieldName;
                    Boolean fieldValue;
                    List<String> values = currentCondition.getValues();
                    
                    if(currentCondition.objectType == 'account')
                    {
                        fieldValue = (Boolean) acc.get(fieldName);
                    }
                    if(currentCondition.objectType == 'user')
                    {
                        fieldValue = (Boolean) u.get(fieldName);
                    }
                    
                    if(values != null)
                    {
                        for(String currVal : values) // Apply OR between values (-> stop at first occurence of TRUE)
                        {
                            if(fieldValue != Boolean.valueOf(currVal))
                            {
                                currentCondition.isTrue = true;
                                break;
                            }
                        }
                    }
                    else
                    {
                        currentCondition.isTrue = (fieldValue == null);
                    }
                }
            }
            if(currentCondition.operator == 'lt') // less than
            {
                // switch on format
                if(   currentCondition.fieldType == Schema.DisplayType.String
                   || currentCondition.fieldType == Schema.DisplayType.PickList
                   || currentCondition.fieldType == Schema.DisplayType.MultiPicklist
                   || currentCondition.fieldType == Schema.DisplayType.Email
                   || currentCondition.fieldType == Schema.DisplayType.Phone
                   || currentCondition.fieldType == Schema.DisplayType.TextArea
                   || currentCondition.fieldType == Schema.DisplayType.URL)
                {
                    String fieldName = currentCondition.objectFieldName;
                    String fieldValue;
                    List<String> values = currentCondition.getValues();
                    
                    if(currentCondition.objectType == 'account')
                    {
                        fieldValue = (String) acc.get(fieldName);
                    }
                    if(currentCondition.objectType == 'user')
                    {
                        fieldValue = (String) u.get(fieldName);
                    }
                    
                    if(values != null)
                    {
                        for(String currVal : values) // Apply OR between values (-> stop at first occurence of TRUE)
                        {
                            if(fieldValue < currVal)
                            {
                                currentCondition.isTrue = true;
                                break;
                            }
                        }
                    }
                    else
                    {
                        currentCondition.isTrue = (fieldValue == null);
                    }
                }
                if(currentCondition.fieldType == Schema.DisplayType.Integer)
                {
                    String fieldName = currentCondition.objectFieldName;
                    Integer fieldValue;
                    List<String> values = currentCondition.getValues();
                    
                    if(currentCondition.objectType == 'account')
                    {
                        fieldValue = (Integer) acc.get(fieldName);
                    }
                    if(currentCondition.objectType == 'user')
                    {
                        fieldValue = (Integer) u.get(fieldName);
                    }
                    
                    if(values != null)
                    {
                        for(String currVal : values) // Apply OR between values (-> stop at first occurence of TRUE)
                        {
                            if(fieldValue < Integer.valueOf(currVal))
                            {
                                currentCondition.isTrue = true;
                                break;
                            }
                        }
                    }
                    else
                    {
                        currentCondition.isTrue = (fieldValue == null);
                    }
                }
                if(   currentCondition.fieldType == Schema.DisplayType.Double
                   || currentCondition.fieldType == Schema.DisplayType.Currency
                   || currentCondition.fieldType == Schema.DisplayType.Percent)
                {
                    String fieldName = currentCondition.objectFieldName;
                    Double fieldValue;
                    List<String> values = currentCondition.getValues();
                    
                    if(currentCondition.objectType == 'account')
                    {
                        fieldValue = (Double) acc.get(fieldName);
                    }
                    if(currentCondition.objectType == 'user')
                    {
                        fieldValue = (Double) u.get(fieldName);
                    }
                    
                    if(values != null)
                    {
                        for(String currVal : values) // Apply OR between values (-> stop at first occurence of TRUE)
                        {
                            if(fieldValue < Double.valueOf(currVal))
                            {
                                currentCondition.isTrue = true;
                                break;
                            }
                        }
                    }
                    else
                    {
                        currentCondition.isTrue = (fieldValue == null);
                    }
                }
                if(currentCondition.fieldType == Schema.DisplayType.Date)
                {
                    String fieldName = currentCondition.objectFieldName;
                    Date fieldValue;
                    List<String> values = currentCondition.getValues();
                    
                    if(currentCondition.objectType == 'account')
                    {
                        fieldValue = (Date) acc.get(fieldName);
                    }
                    if(currentCondition.objectType == 'user')
                    {
                        fieldValue = (Date) u.get(fieldName);
                    }
                    
                    if(values != null)
                    {
                        for(String currVal : values) // Apply OR between values (-> stop at first occurence of TRUE)
                        {
                            if(fieldValue != null)
                            {
                                // If the Date that calls the method occurs after the compDate, the return value is negative.
                                if(fieldValue.daysBetween(Date.valueOf(currVal)) < 0)
                                {
                                    currentCondition.isTrue = true;
                                    break;
                                }
                            }
                        }
                    }
                    else
                    {
                        currentCondition.isTrue = (fieldValue == null);
                    }
                }
                if(currentCondition.fieldType == Schema.DisplayType.DateTime)
                {
                    String fieldName = currentCondition.objectFieldName;
                    DateTime fieldValue;
                    List<String> values = currentCondition.getValues();
                    
                    if(currentCondition.objectType == 'account')
                    {
                        fieldValue = (DateTime) acc.get(fieldName);
                    }
                    if(currentCondition.objectType == 'user')
                    {
                        fieldValue = (DateTime) u.get(fieldName);
                    }
                    
                    if(values != null)
                    {
                        for(String currVal : values) // Apply OR between values (-> stop at first occurence of TRUE)
                        {
                            if(fieldValue != null)
                            {
                                if(fieldValue.getTime() > DateTime.parse(currVal).getTime())
                                {
                                    currentCondition.isTrue = true;
                                    break;
                                }
                            }
                        }
                    }
                    else
                    {
                        currentCondition.isTrue = (fieldValue == null);
                    }
                }
            }
            if(currentCondition.operator == 'gt') // greater than
            {
                // switch on format
                if(   currentCondition.fieldType == Schema.DisplayType.String
                   || currentCondition.fieldType == Schema.DisplayType.PickList
                   || currentCondition.fieldType == Schema.DisplayType.MultiPicklist
                   || currentCondition.fieldType == Schema.DisplayType.Email
                   || currentCondition.fieldType == Schema.DisplayType.Phone
                   || currentCondition.fieldType == Schema.DisplayType.TextArea
                   || currentCondition.fieldType == Schema.DisplayType.URL)
                {
                    String fieldName = currentCondition.objectFieldName;
                    String fieldValue;
                    List<String> values = currentCondition.getValues();
                    
                    if(currentCondition.objectType == 'account')
                    {
                        fieldValue = (String) acc.get(fieldName);
                    }
                    if(currentCondition.objectType == 'user')
                    {
                        fieldValue = (String) u.get(fieldName);
                    }
                    
                    if(values != null)
                    {
                        for(String currVal : values) // Apply OR between values (-> stop at first occurence of TRUE)
                        {
                            if(fieldValue > currVal)
                            {
                                currentCondition.isTrue = true;
                                break;
                            }
                        }
                    }
                    else
                    {
                        currentCondition.isTrue = (fieldValue == null);
                    }
                }
                if(currentCondition.fieldType == Schema.DisplayType.Integer)
                {
                    String fieldName = currentCondition.objectFieldName;
                    Integer fieldValue;
                    List<String> values = currentCondition.getValues();
                    
                    if(currentCondition.objectType == 'account')
                    {
                        fieldValue = (Integer) acc.get(fieldName);
                    }
                    if(currentCondition.objectType == 'user')
                    {
                        fieldValue = (Integer) u.get(fieldName);
                    }
                    
                    if(values != null)
                    {
                        for(String currVal : values) // Apply OR between values (-> stop at first occurence of TRUE)
                        {
                            if(fieldValue != null)
                            {
                                if(fieldValue > Integer.valueOf(currVal))
                                {
                                    currentCondition.isTrue = true;
                                    break;
                                }
                            }
                        }
                    }
                    else
                    {
                        currentCondition.isTrue = (fieldValue == null);
                    }
                }
                if(   currentCondition.fieldType == Schema.DisplayType.Double
                   || currentCondition.fieldType == Schema.DisplayType.Currency
                   || currentCondition.fieldType == Schema.DisplayType.Percent)
                {
                    String fieldName = currentCondition.objectFieldName;
                    Double fieldValue;
                    List<String> values = currentCondition.getValues();
                    
                    if(currentCondition.objectType == 'account')
                    {
                        fieldValue = (Double) acc.get(fieldName);
                    }
                    if(currentCondition.objectType == 'user')
                    {
                        fieldValue = (Double) u.get(fieldName);
                    }
                    
                    if(values != null)
                    {
                        for(String currVal : values) // Apply OR between values (-> stop at first occurence of TRUE)
                        {
                            if(fieldValue != null)
                            {
                                if(fieldValue > Double.valueOf(currVal))
                                {
                                    currentCondition.isTrue = true;
                                    break;
                                }
                            }
                        }
                    }
                    else
                    {
                        currentCondition.isTrue = (fieldValue == null);
                    }
                }
                if(currentCondition.fieldType == Schema.DisplayType.Date)
                {
                    String fieldName = currentCondition.objectFieldName;
                    Date fieldValue;
                    List<String> values = currentCondition.getValues();
                    
                    if(currentCondition.objectType == 'account')
                    {
                        fieldValue = (Date) acc.get(fieldName);
                    }
                    if(currentCondition.objectType == 'user')
                    {
                        fieldValue = (Date) u.get(fieldName);
                    }
                    
                    if(values != null)
                    {
                        for(String currVal : values) // Apply OR between values (-> stop at first occurence of TRUE)
                        {
                            if(fieldValue != null)
                            {
                                // If the Date that calls the method occurs after the compDate, the return value is negative.
                                if(fieldValue.daysBetween(Date.valueOf(currVal)) > 0)
                                {
                                    currentCondition.isTrue = true;
                                    break;
                                }
                            }
                        }
                    }
                    else
                    {
                        currentCondition.isTrue = (fieldValue == null);
                    }
                }
                if(currentCondition.fieldType == Schema.DisplayType.DateTime)
                {
                    String fieldName = currentCondition.objectFieldName;
                    DateTime fieldValue;
                    List<String> values = currentCondition.getValues();
                    
                    if(currentCondition.objectType == 'account')
                    {
                        fieldValue = (DateTime) acc.get(fieldName);
                    }
                    if(currentCondition.objectType == 'user')
                    {
                        fieldValue = (DateTime) u.get(fieldName);
                    }
                    if(values != null)
                    {
                        for(String currVal : values) // Apply OR between values (-> stop at first occurence of TRUE)
                        {
                            if(fieldValue != null)
                            {
                                if(fieldValue.getTime() < DateTime.parse(currVal).getTime())
                                {
                                    currentCondition.isTrue = true;
                                    break;
                                }
                            }
                        }
                    }
                    else
                    {
                        currentCondition.isTrue = (fieldValue == null);
                    }
                }
            }
            if(currentCondition.operator == 'leq') // less or equal
            {
                // switch on format
                if(   currentCondition.fieldType == Schema.DisplayType.String
                   || currentCondition.fieldType == Schema.DisplayType.PickList
                   || currentCondition.fieldType == Schema.DisplayType.MultiPicklist
                   || currentCondition.fieldType == Schema.DisplayType.Email
                   || currentCondition.fieldType == Schema.DisplayType.Phone
                   || currentCondition.fieldType == Schema.DisplayType.TextArea
                   || currentCondition.fieldType == Schema.DisplayType.URL)
                {
                    String fieldName = currentCondition.objectFieldName;
                    String fieldValue;
                    List<String> values = currentCondition.getValues();
                    
                    if(currentCondition.objectType == 'account')
                    {
                        fieldValue = (String) acc.get(fieldName);
                    }
                    if(currentCondition.objectType == 'user')
                    {
                        fieldValue = (String) u.get(fieldName);
                    }
                    
                    if(values != null)
                    {
                        for(String currVal : values) // Apply OR between values (-> stop at first occurence of TRUE)
                        {
                            if(fieldValue <= currVal)
                            {
                                currentCondition.isTrue = true;
                                break;
                            }
                        }
                    }
                    else
                    {
                        currentCondition.isTrue = (fieldValue == null);
                    }
                }
                if(currentCondition.fieldType == Schema.DisplayType.Integer)
                {
                    String fieldName = currentCondition.objectFieldName;
                    Integer fieldValue;
                    List<String> values = currentCondition.getValues();
                    
                    if(currentCondition.objectType == 'account')
                    {
                        fieldValue = (Integer) acc.get(fieldName);
                    }
                    if(currentCondition.objectType == 'user')
                    {
                        fieldValue = (Integer) u.get(fieldName);
                    }
                    
                    if(values != null)
                    {
                        for(String currVal : values) // Apply OR between values (-> stop at first occurence of TRUE)
                        {
                            if(fieldValue <= Integer.valueOf(currVal))
                            {
                                currentCondition.isTrue = true;
                                break;
                            }
                        }
                    }
                    else
                    {
                        currentCondition.isTrue = (fieldValue == null);
                    }
                }
                if(   currentCondition.fieldType == Schema.DisplayType.Double
                   || currentCondition.fieldType == Schema.DisplayType.Currency
                   || currentCondition.fieldType == Schema.DisplayType.Percent)
                {
                    String fieldName = currentCondition.objectFieldName;
                    Double fieldValue;
                    List<String> values = currentCondition.getValues();
                    
                    if(currentCondition.objectType == 'account')
                    {
                        fieldValue = (Double) acc.get(fieldName);
                    }
                    if(currentCondition.objectType == 'user')
                    {
                        fieldValue = (Double) u.get(fieldName);
                    }
                    
                    if(values != null)
                    {
                        for(String currVal : values) // Apply OR between values (-> stop at first occurence of TRUE)
                        {
                            if(fieldValue <= Double.valueOf(currVal))
                            {
                                currentCondition.isTrue = true;
                                break;
                            }
                        }
                    }
                    else
                    {
                        currentCondition.isTrue = (fieldValue == null);
                    }
                }
                if(currentCondition.fieldType == Schema.DisplayType.Date)
                {
                    String fieldName = currentCondition.objectFieldName;
                    Date fieldValue;
                    List<String> values = currentCondition.getValues();
                    
                    if(currentCondition.objectType == 'account')
                    {
                        fieldValue = (Date) acc.get(fieldName);
                    }
                    if(currentCondition.objectType == 'user')
                    {
                        fieldValue = (Date) u.get(fieldName);
                    }
                    
                    if(values != null)
                    {
                        for(String currVal : values) // Apply OR between values (-> stop at first occurence of TRUE)
                        {
                            if(fieldValue != null)
                            {
                                // If the Date that calls the method occurs after the compDate, the return value is negative.
                                if(fieldValue.daysBetween(Date.valueOf(currVal)) <= 0)
                                {
                                    currentCondition.isTrue = true;
                                    break;
                                }
                            }
                        }
                    }
                    else
                    {
                        currentCondition.isTrue = (fieldValue == null);
                    }
                }
                if(currentCondition.fieldType == Schema.DisplayType.DateTime)
                {
                    String fieldName = currentCondition.objectFieldName;
                    DateTime fieldValue;
                    List<String> values = currentCondition.getValues();
                    
                    if(currentCondition.objectType == 'account')
                    {
                        fieldValue = (DateTime) acc.get(fieldName);
                    }
                    if(currentCondition.objectType == 'user')
                    {
                        fieldValue = (DateTime) u.get(fieldName);
                    }
                    
                    if(values != null)
                    {
                        for(String currVal : values) // Apply OR between values (-> stop at first occurence of TRUE)
                        {
                            if(fieldValue != null)
                            {
                                if(fieldValue.getTime() <=  DateTime.parse(currVal).getTime())
                                {
                                    currentCondition.isTrue = true;
                                    break;
                                }
                            }
                        }
                    }
                    else
                    {
                        currentCondition.isTrue = (fieldValue == null);
                    }
                }
            }
            if(currentCondition.operator == 'geq') // greater or equal
            {
                // switch on format
                if(   currentCondition.fieldType == Schema.DisplayType.String
                   || currentCondition.fieldType == Schema.DisplayType.PickList
                   || currentCondition.fieldType == Schema.DisplayType.MultiPicklist
                   || currentCondition.fieldType == Schema.DisplayType.Email
                   || currentCondition.fieldType == Schema.DisplayType.Phone
                   || currentCondition.fieldType == Schema.DisplayType.TextArea
                   || currentCondition.fieldType == Schema.DisplayType.URL)
                {
                    String fieldName = currentCondition.objectFieldName;
                    String fieldValue;
                    List<String> values = currentCondition.getValues();
                    
                    if(currentCondition.objectType == 'account')
                    {
                        fieldValue = (String) acc.get(fieldName);
                    }
                    if(currentCondition.objectType == 'user')
                    {
                        fieldValue = (String) u.get(fieldName);
                    }
                    
                    if(values != null)
                    {
                        for(String currVal : values) // Apply OR between values (-> stop at first occurence of TRUE)
                        {
                            if(fieldValue >= currVal)
                            {
                                currentCondition.isTrue = true;
                                break;
                            }
                        }
                    }
                    else
                    {
                        currentCondition.isTrue = (fieldValue == null);
                    }
                }
                if(currentCondition.fieldType == Schema.DisplayType.Integer)
                {
                    String fieldName = currentCondition.objectFieldName;
                    Integer fieldValue;
                    List<String> values = currentCondition.getValues();
                    
                    if(currentCondition.objectType == 'account')
                    {
                        fieldValue = (Integer) acc.get(fieldName);
                    }
                    if(currentCondition.objectType == 'user')
                    {
                        fieldValue = (Integer) u.get(fieldName);
                    }
                    
                    if(values != null)
                    {
                        for(String currVal : values) // Apply OR between values (-> stop at first occurence of TRUE)
                        {
                            if(fieldValue >= Integer.valueOf(currVal))
                            {
                                currentCondition.isTrue = true;
                                break;
                            }
                        }
                    }
                    else
                    {
                        currentCondition.isTrue = (fieldValue == null);
                    }
                }
                if(   currentCondition.fieldType == Schema.DisplayType.Double
                   || currentCondition.fieldType == Schema.DisplayType.Currency
                   || currentCondition.fieldType == Schema.DisplayType.Percent)
                {
                    String fieldName = currentCondition.objectFieldName;
                    Double fieldValue;
                    List<String> values = currentCondition.getValues();
                    
                    if(currentCondition.objectType == 'account')
                    {
                        fieldValue = (Double) acc.get(fieldName);
                    }
                    if(currentCondition.objectType == 'user')
                    {
                        fieldValue = (Double) u.get(fieldName);
                    }
                    
                    if(values != null)
                    {
                        for(String currVal : values) // Apply OR between values (-> stop at first occurence of TRUE)
                        {
                            if(fieldValue >= Double.valueOf(currVal))
                            {
                                currentCondition.isTrue = true;
                                break;
                            }
                        }
                    }
                    else
                    {
                        currentCondition.isTrue = (fieldValue == null);
                    }
                }
                if(currentCondition.fieldType == Schema.DisplayType.Date)
                {
                    String fieldName = currentCondition.objectFieldName;
                    Date fieldValue;
                    List<String> values = currentCondition.getValues();
                    
                    if(currentCondition.objectType == 'account')
                    {
                        fieldValue = (Date) acc.get(fieldName);
                    }
                    if(currentCondition.objectType == 'user')
                    {
                        fieldValue = (Date) u.get(fieldName);
                    }
                    
                    if(values != null)
                    {
                        for(String currVal : values) // Apply OR between values (-> stop at first occurence of TRUE)
                        {
                            if(fieldValue != null)
                            {
                                // If the Date that calls the method occurs after the compDate, the return value is negative.
                                if(fieldValue.daysBetween(Date.valueOf(currVal)) >= 0)
                                {
                                    currentCondition.isTrue = true;
                                    break;
                                }
                            }
                        }
                    }
                    else
                    {
                        currentCondition.isTrue = (fieldValue == null);
                    }
                }
                if(currentCondition.fieldType == Schema.DisplayType.DateTime)
                {
                    String fieldName = currentCondition.objectFieldName;
                    DateTime fieldValue;
                    List<String> values = currentCondition.getValues();
                    
                    if(currentCondition.objectType == 'account')
                    {
                        fieldValue = (DateTime) acc.get(fieldName);
                    }
                    if(currentCondition.objectType == 'user')
                    {
                        fieldValue = (DateTime) u.get(fieldName);
                    }
                    
                    if(values != null)
                    {
                        for(String currVal : values) // Apply OR between values (-> stop at first occurence of TRUE)
                        {
                            if(fieldValue != null)
                            {
                                if(fieldValue.getTime() >= DateTime.parse(currVal).getTime())
                                {
                                    currentCondition.isTrue = true;
                                    break;
                                }
                            }
                        }
                    }
                    else
                    {
                        currentCondition.isTrue = (fieldValue == null);
                    }
                }
            }
            if(currentCondition.operator == 'cont') // contains
            {
                // switch on format
                if(   currentCondition.fieldType == Schema.DisplayType.String
                   || currentCondition.fieldType == Schema.DisplayType.PickList
                   || currentCondition.fieldType == Schema.DisplayType.MultiPicklist
                   || currentCondition.fieldType == Schema.DisplayType.Email
                   || currentCondition.fieldType == Schema.DisplayType.Phone
                   || currentCondition.fieldType == Schema.DisplayType.TextArea
                   || currentCondition.fieldType == Schema.DisplayType.URL)
                {
                    String fieldName = currentCondition.objectFieldName;
                    String fieldValue;
                    List<String> values = currentCondition.getValues();
                    
                    if(currentCondition.objectType == 'account')
                    {
                        fieldValue = (String) acc.get(fieldName);
                    }
                    if(currentCondition.objectType == 'user')
                    {
                        fieldValue = (String) u.get(fieldName);
                    }
                    
                    if(values != null)
                    {
                        for(String currVal : values) // Apply OR between values (-> stop at first occurence of TRUE)
                        {
                            if(fieldValue != null)
                            {
                                if(fieldValue.contains(currVal))
                                {
                                    currentCondition.isTrue = true;
                                    break;
                                }
                            }
                        }
                    }
                    else
                    {
                        currentCondition.isTrue = (fieldValue == null);
                    }
                }
            }
            if(currentCondition.operator == 'ncont') // does not contain
            {
                // switch on format
                if(   currentCondition.fieldType == Schema.DisplayType.String
                   || currentCondition.fieldType == Schema.DisplayType.PickList
                   || currentCondition.fieldType == Schema.DisplayType.MultiPicklist
                   || currentCondition.fieldType == Schema.DisplayType.Email
                   || currentCondition.fieldType == Schema.DisplayType.Phone
                   || currentCondition.fieldType == Schema.DisplayType.TextArea
                   || currentCondition.fieldType == Schema.DisplayType.URL)
                {
                    String fieldName = currentCondition.objectFieldName;
                    String fieldValue;
                    List<String> values = currentCondition.getValues();
                    
                    if(currentCondition.objectType == 'account')
                    {
                        fieldValue = (String) acc.get(fieldName);
                    }
                    if(currentCondition.objectType == 'user')
                    {
                        fieldValue = (String) u.get(fieldName);
                    }
                    
                    for(String currVal : values) // Apply OR between values (-> stop at first occurence of TRUE)
                    {
                        if(!fieldValue.contains(currVal))
                        {
                            currentCondition.isTrue = true;
                            break;
                        }
                    }
                }
            }
            if(currentCondition.operator == 'str') // starts with
            {
                // switch on format
                if(   currentCondition.fieldType == Schema.DisplayType.String
                   || currentCondition.fieldType == Schema.DisplayType.PickList
                   || currentCondition.fieldType == Schema.DisplayType.MultiPicklist
                   || currentCondition.fieldType == Schema.DisplayType.Email
                   || currentCondition.fieldType == Schema.DisplayType.Phone
                   || currentCondition.fieldType == Schema.DisplayType.TextArea
                   || currentCondition.fieldType == Schema.DisplayType.URL)
                {
                    String fieldName = currentCondition.objectFieldName;
                    String fieldValue;
                    List<String> values = currentCondition.getValues();
                    
                    if(currentCondition.objectType == 'account')
                    {
                        fieldValue = (String) acc.get(fieldName);
                    }
                    if(currentCondition.objectType == 'user')
                    {
                        fieldValue = (String) u.get(fieldName);
                    }
                    
                    for(String currVal : values) // Apply OR between values (-> stop at first occurence of TRUE)
                    {
                        if(fieldValue.startsWith(currVal))
                        {
                            currentCondition.isTrue = true;
                            break;
                        }
                    }
                }
            }
        }
    }
    
    private static String getFilterLogic(String criteria)
    {
        if (criteria != null & criteria != '')
            return criteria.split('<br>')[0];
        else
            return null;
    }
    
    private static Map<String,List<OTCondition>> conditionsMap;
    
    private static List<OTCondition> getConditions(String criteria)
    {
        if(conditionsMap == null)
            conditionsMap = new Map<String,List<OTCondition>>();
        
        if (criteria != null & criteria != '')
        {
            List<OTCondition> result = conditionsMap.get(criteria);
            if(result != null)
                return result;
            
            List<String> strConditions = criteria.split('<br>');
            // Remove the first element (filter logic)
            strConditions.remove(0);
    
            // Build the result             
            List<OTCondition> conditions = new List<OTCondition>();
            for(String currentCondition: strConditions)
            {
                OTCondition otc = new OTCondition(currentCondition);
                conditions.add(otc);
            }
            conditionsMap.put(criteria, conditions);
            
            return conditions;
        }
        else
            return null;
    }
    
    private static Account queryAccount(Set<String> accountFields, ID accId)
    {
        // Build the query
        String query = 'SELECT ';
        for(String currentField: accountFields)
            query += currentField + ', ';
        // Remove last comma
        query = query.substring(0,query.length()-2);
        query += ' FROM Account WHERE Id=\'' + accId + '\' LIMIT 1';
        System.Debug('## Query = ' + query);
        System.Debug('## Result = ' + Database.query(query));
        return Database.query(query);
    }
    
    private static User queryUser(Set<String> userFields)
    {
        // Build the query
        String query = 'SELECT ';
        for(String currentField: userFields)
            query += currentField + ', ';
        // Remove last comma
        query = query.substring(0,query.length()-2);
        query += ' FROM User WHERE Id=\'' + UserInfo.getUserId() + '\' LIMIT 1';
        System.Debug('## Query = ' + query);
        System.Debug('## Result = ' + Database.query(query));
        return Database.query(query);
    }
    
    private static List<Offer_Template__c> retrieveAllOfferTemplates()
    {   
        return [SELECT Id, Name,Status__c, Start_Date__c,End_Date__c, Eligibility_Criteria_Int__c 
                FROM Offer_Template__c WHERE Status__c='Active'
                                       AND Start_Date__c<= :Date.today()
                                       AND (End_Date__c = null OR End_Date__c>= :Date.today()) ];
    }
    
    // Inner class
    private class OTCondition
    {
        public String objectType {get; set;}
        public String objectFieldName {get; set;}
        public Schema.DisplayType fieldType;
        public String operator {get; set;}
        private List<String> values {get; set;}
        public Boolean isTrue {get; set;}

        public OTCondition(String cond)
        {
            List<String> condElements = cond.split(';');
            this.objectType = condElements[0];
            this.objectFieldName = condElements[1];
            this.fieldType = Schema.getGlobalDescribe().get(this.objectType).getDescribe().fields.getMap().get(this.objectFieldName).getDescribe().getType();
            this.operator = condElements[2];
            this.values = condElements[3].split(',');
            this.isTrue = false;
        }
        
        public List<String> getValues()
        {
            return this.values;
        }
    }
    
    public List<SelectOption> getOptionsOT()
    {
        return optionsOT;
    }
    
    public PageReference handleReturn()
    {
        String returnedList = Apexpages.currentPage().getParameters().get('returnedList');  
        evalDone = true;
        System.Debug('## Begin handleReturn');
        System.Debug('## returnedList :' + returnedList);
        System.Debug('## End handleReturn');
        
        if (optionsOT == null)
            optionsOT = new SelectOption[0];
            
        if (returnedList.length() > 0)
        {
            String formated = returnedList.substring(0, returnedList.length() - 1);
            List<String> ids = formated.split(';');
            
            List<Offer_Template__c> listOTs = [SELECT Id, Name,Status__c, Start_Date__c,End_Date__c, Eligibility_Criteria_Int__c 
                                           FROM Offer_Template__c where Status__c='Active' and Start_Date__c<= :Date.today()
                                           AND Id IN :ids];
                                           
            for (Offer_Template__c ot : listOTs)
                optionsOT.add(new SelectOption(ot.Id, ot.Name));
            
            if (optionsOT.size() >= 1)
                selectedOT = optionsOT[0].getValue();
        }
        
        return null;
    }
    
    public PageReference Save() 
    {
        try
        {
            LinkOfferTemplate();        
            return (Utilities.Redirect(this.opp.id));
        }
        catch (DmlException e)
        {
            if (e.getDmlMessage(0) == 'Close Date can\'t be in the past.')
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'You cannot attach an offer template to an opportunity whose close date is in the past.'));
            else
                ApexPages.addMessages(e);
            
            return null;
        }
        
    }
    
    public PageReference Cancel() 
    {
        return (Utilities.Redirect(this.opp.id));
    }
    
    public void LinkOfferTemplate()
    {
        opp.Offer_Template__c = selectedOT;
        opp.Maximum_Invoice_Amount__c = [SELECT Default_Value__c FROM Offer_Template__c WHERE Id = :selectedOT].Default_Value__c;
        opp.CUG_allowed__c = [SELECT CUG_allowed__c FROM Offer_Template__c WHERE Id = :selectedOT].CUG_allowed__c;
        opp.CurrencyIsoCode = [SELECT CurrencyIsoCode FROM Offer_Template__c WHERE Id = :selectedOT].CurrencyIsoCode;
        update opp;
    }
}