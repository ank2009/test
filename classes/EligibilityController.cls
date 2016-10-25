public class EligibilityController 
{
    // inner class
    class Criterion
    {
        public String obj { get; set; }
        public String fld { get; set; }
        public List<SelectOption> fieldOpt;
        public String op  { get; set; }
        public List<SelectOption> opOpt;
        public String val { get; set; }
        public Boolean lookup { get; set; }
        public Schema.DisplayType fieldType { get; set; }
        public String idInput { get; set; }
     
        public Criterion(String ob, String f, String o, String v) 
        {
            this.obj = ob;
            this.fld = f;
            this.op  = o;
            this.val = v;
            
            fieldOpt = new SelectOption[0];
            opOpt    = new SelectOption[0];
            
            updateFieldOpt();
            updateOpOpt();
        }
        
        public void updateFieldOpt()
        {
            fieldOpt.clear();
            
            Map<String, Schema.SObjectType> temp = Schema.getGlobalDescribe();
            Schema.SObjectType temp3 = temp.get(this.obj);
            Schema.DescribeSObjectResult temp2 = temp3.getDescribe();
            Map<String, Schema.SObjectField> fd = temp2.fields.getMap();

            List<String> keys = new List<String>(fd.keySet());
            
            Map<String, String> labelsAndKeys = new Map<String,String>();
            
            for(String s : keys)
                labelsAndKeys.put(fd.get(s).getDescribe().getLabel(),s);

            List<String> labels = new List<String>(labelsAndKeys.keySet());
            labels.sort();
            
            if (fd.get(this.fld)     == null)
                this.fld = keys[0];
            
            for(String s : labels)
                fieldOpt.add(new SelectOption(labelsAndKeys.get(s), s));

        }
        
        public void updateOpOpt()
        {
            opOpt.clear();
            this.lookup = false;
            
            Schema.DisplayType fldType = Schema.getGlobalDescribe().get(this.obj).getDescribe().fields.getMap().get(this.fld).getDescribe().getType();
            this.fieldType = fldType;
            
            List<String> vals = new List<String>();
            Set<String> setVals = new Set<String>();
            List<String> labs = new List<String>();
                      
            if ((fldType == Schema.DisplayType.String) || 
                (fldType == Schema.DisplayType.PickList) || 
                (fldType == Schema.DisplayType.Email) || 
                (fldType == Schema.DisplayType.Phone) || 
                (fldType == Schema.DisplayType.TextArea) || 
                (fldType == Schema.DisplayType.URL))
            {
                vals.add('eq');    setVals.add('eq');    labs.add('equals');            
                vals.add('neq');   setVals.add('neq');   labs.add('not equal to');
                vals.add('lt');    setVals.add('lt');    labs.add('less than');
                vals.add('gt');    setVals.add('gt');    labs.add('greater than');
                vals.add('leq');   setVals.add('leq');   labs.add('less or equal');
                vals.add('geq');   setVals.add('geq');   labs.add('greater or equal');
                vals.add('cont');  setVals.add('cont');  labs.add('contains');
                vals.add('ncont'); setVals.add('ncont'); labs.add('does not contain');
                vals.add('str');   setVals.add('str');   labs.add('start with');
            }
            else if ((fldType == Schema.DisplayType.Integer) || 
                (fldType == Schema.DisplayType.Double) || 
                (fldType == Schema.DisplayType.Currency) || 
                (fldType == Schema.DisplayType.Date) || 
                (fldType == Schema.DisplayType.DateTime) || 
                (fldType == Schema.DisplayType.Percent))
            {
                vals.add('eq');    setVals.add('eq');    labs.add('equals');
                vals.add('neq');   setVals.add('neq');   labs.add('not equal to');
                vals.add('lt');    setVals.add('lt');    labs.add('less than');
                vals.add('gt');    setVals.add('gt');    labs.add('greater than');
                vals.add('leq');   setVals.add('leq');   labs.add('less or equal');
                vals.add('geq');   setVals.add('geq');   labs.add('greater or equal');
            }
            else if (fldType == Schema.DisplayType.ID)
            {
                vals.add('eq');    setVals.add('eq');    labs.add('equals');
                vals.add('neq');   setVals.add('neq');   labs.add('not equal to');
                vals.add('str');   setVals.add('str');   labs.add('start with');
            }
            else if (fldType == Schema.DisplayType.MultiPicklist)
            {
                vals.add('eq');    setVals.add('eq');    labs.add('equals');
                vals.add('neq');   setVals.add('neq');   labs.add('not equal to');
                vals.add('incl');   setVals.add('incl');   labs.add('includes');
                vals.add('excl');   setVals.add('excl');   labs.add('excludes');
            }
            else
            {
                vals.add('eq');    setVals.add('eq');    labs.add('equals');
                vals.add('neq');   setVals.add('neq');   labs.add('not equal to');
            }
            
            if (setVals.contains(this.op) == null)
                this.op = vals[0];
                
            for (Integer i = 0; i < vals.size(); i++)
                opOpt.add(new SelectOption(vals[i], labs[i]));
            
            if ((fldType == Schema.DisplayType.PickList) ||
                (fldType == Schema.DisplayType.MultiPicklist) ||
                (fldType == Schema.DisplayType.Boolean))
                this.lookup = true;
        }
        
        public List<SelectOption> getFieldOpt()
        {
            return fieldOpt;
        }
        
        public List<SelectOption> getOpOpt()
        {
            return opOpt;
        }
        
        public PageReference onChangeObj()
        {
            updateFieldOpt();
            updateOpOpt();
            
            return null;
        }
        
        public void onChangeFld()
        {
            updateOpOpt();
        }
    }
    
    public Boolean check { get; set; }
    public String valRad { get; set; }
    public List<String> valChk { get; set; }
    public List<SelectOption> options;
    public boolean displayPopup {get; set;}     
    public String filterLogic = '';
    public list<Criterion> criteria = new Criterion[0];
    public ID idOffer;
    public Schema.DisplayType currentType { get; set; }
    public String valDebug { get; set; }
    private Map<String, String> keyval = new Map<String, String>();
    public Boolean error {get; set;}
    public Integer index
    {
        get;
        // *** setter is NOT being called ***
        set 
        {
            index = value;
        }
    }
    
    public PageReference init()
    {
        error = false;
        idOffer = System.currentPageReference().getParameters().get('id');
        
        Integer nOffer = [SELECT COUNT() FROM Offer_Template__c WHERE Id=:idOffer];
        
        if (nOffer != 0)
        {
            String eligibility_criteria = [SELECT Eligibility_Criteria_Int__c FROM Offer_Template__c WHERE Id=:idOffer].Eligibility_Criteria_Int__c;
            String eligibility_criteria_form = [SELECT Eligibility_Criteria__c FROM Offer_Template__c WHERE Id=:idOffer].Eligibility_Criteria__c;
            String otStatus = [SELECT Status__c FROM Offer_Template__c WHERE Id=:idOffer].Status__c;
            
            if (eligibility_criteria != null)
            {
                System.Debug(eligibility_criteria_form);
                list<String> tokens = eligibility_criteria.split('<br>', 100);
                filterLogic = tokens[0];
                for (Integer i = 1; i < tokens.size(); i++)
                {
                    if (tokens[i].length() > 4)
                    {
                        list<String> param = tokens[i].split(';',4);
                        criteria.add(new Criterion(param[0], param[1], param[2], param[3]));
                    }
                }
            }
            if (otStatus != 'Pending')
            {
                error = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Eligibility criteria can be edited only if Offer Template is under Pending status!'));
            }
        }
        
        options = new SelectOption[0];
        if (valChk == null)
            valChk = new String[0];
                    
        return null;
    }
    
    public String getOfferName() 
    {
        Integer nOffer = [SELECT COUNT() FROM Offer_Template__c WHERE Id=:idOffer];
        
        if (nOffer == 0)
            return 'Offer Not Selected';
        else 
            return [SELECT Name FROM Offer_Template__c WHERE Id=:idOffer].Name;
    }
    
    public String getFilterLogic() 
    {
        return filterLogic;
    }
    
    public void setFilterLogic(String filterL)
    {
        this.filterLogic = filterL;
    }
    
    public list<Criterion> getCriteria()
    {
        return criteria;
    }
    
    public PageReference addFilter() 
    {
        criteria.add(new Criterion('account', 'name', 'eq', ''));        
        return null;
    }
    
    public PageReference lookupWnd() 
    {
        return null;
    }
    
    public PageReference rmvCriterion() 
    {
        criteria.remove(index - 1);
        filterLogic = '';
        return null;
    }
    
    public void saveAndExit()
    {
        if (check)
        {
            criteria[index - 1].val = '';
            if (valChk.size() > 0)
            {
                for (String s : valChk)
                    criteria[index - 1].val += s + ',';
                criteria[index - 1].val = criteria[index - 1].val.substring(0, criteria[index - 1].val.length() - 1);
            }
        }
        else
            criteria[index - 1].val = valRad;
            
        closePopup();
    }
    
    public void closePopup() 
    {        
        displayPopup = false;    
    }
    
    public void showPopup() 
    {
        String currentObj = criteria[index - 1].obj;
        String currentFld = criteria[index - 1].fld;
        Schema.DescribeFieldResult fldDesc = Schema.getGlobalDescribe().get(currentObj).getDescribe().fields.getMap().get(currentFld).getDescribe();
        currentType = fldDesc.getType();
        
        options.clear();
        
        if (currentType == Schema.DisplayType.BOOLEAN)
        {
            check = false;
            valRad = criteria[index - 1].val;
            options.add(new SelectOption('true', 'true'));
            options.add(new SelectOption('false', 'false'));
        }
        else
        {
            check = true;
            List<String> param = criteria[index - 1].val.split(',',100);
            
            valChk.clear();
            valChk.addAll(param);
            
            for (Schema.PicklistEntry v : fldDesc.getPicklistValues())
            {
                options.add(new SelectOption(v.getValue(), v.getLabel()));
            }
        }  
        
        displayPopup = true;
    }
    
    public void selectAll()
    {
        valChk.clear();
        for (SelectOption s : options)
            valChk.add(s.getValue());
    }
    
    public void deselectAll()
    {
        valChk.clear();
    }
    
    public List<SelectOption> getOptions()
    {
        return options;
    }
    
    public List<SelectOption> getObjectItems() 
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('account','Account'));
        options.add(new SelectOption('user','User'));
        
        keyval.put('account','Account');
        keyval.put('user','User');
        keyval.put('eq', 'equals');
        keyval.put('neq', 'not equal to');
        keyval.put('lt', 'less than');
        keyval.put('gt', 'greater than');
        keyval.put('leq', 'less or equal');
        keyval.put('geq', 'greater or equal');
        keyval.put('cont', 'contains');
        keyval.put('ncont', 'does not contain');
        keyval.put('str', 'start with');
        keyval.put('incl', 'includes');
        keyval.put('excl', 'excludes');  
            
        return options;
    }

    public PageReference Save() 
    {
        if (criteria.size() > 0 && filterLogic == '')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Filter logic is required!'));
            return null;
        }
        
        String eligibility_criteria = filterLogic + '<br>';
        for (Criterion c : criteria)
            eligibility_criteria += c.obj + ';' + c.fld + ';' + c.op + ';' + c.val + '<br>';
            
        String eligibility_criteria_forme = '<span>Filter Logic: <strong>' + filterLogic + '</strong></span><br>';
        for (Integer i = 0; i < criteria.size(); i++)
        {
            String label = Schema.getGlobalDescribe().get(criteria[i].obj).getDescribe().fields.getMap().get(criteria[i].fld).getDescribe().getLabel();
            eligibility_criteria_forme += '<span> ' + (i + 1) + '. ' + '<strong>' + keyval.get(criteria[i].obj) + ': ' + label + '</strong> ' + keyval.get(criteria[i].op) + ' <strong>&quot;' + criteria[i].val + '&quot;</strong></span><br>' ; 
        }
        
        Offer_Template__c offer = [SELECT Eligibility_Criteria_Int__c, Eligibility_Criteria__c FROM Offer_Template__c WHERE Id=:idOffer];
        if (filterLogic != '')
        {
            offer.Eligibility_Criteria_Int__c = eligibility_criteria;
            offer.Eligibility_Criteria__c     = eligibility_criteria_forme;
        }
        else
        {
            offer.Eligibility_Criteria_Int__c = null;
            offer.Eligibility_Criteria__c     = null;
        }
        update offer;
        
        return (Utilities.Redirect(idOffer));
    }
    
    public PageReference Cancel() 
    {
        return (Utilities.Redirect(idOffer));
    }
}