public class EligibilityLookUpController 
{
    public Boolean check { get; set; }
    public List<SelectOption> options;
    public String valRad { get; set; }
    public List<String> valChk { get; set; }
    
    public PageReference init()
    {
        String fldType = System.currentPageReference().getParameters().get('fldType');
        String obj = System.currentPageReference().getParameters().get('obj');
        String fld = System.currentPageReference().getParameters().get('fld');
        
        options = new SelectOption[0];
        
        if (fldType == 'BOOLEAN')
        {
            check = false;
            options.add(new SelectOption('true', 'true'));
            options.add(new SelectOption('false', 'false'));
        }
        else
        {
            check = true;
            List <Schema.PicklistEntry> values = Schema.getGlobalDescribe().get(obj).getDescribe().fields.getMap().get(fld).getDescribe().getPicklistValues();

            for (Schema.PicklistEntry v : values)
            {
                options.add(new SelectOption(v.getValue(), v.getLabel()));
            }
        }

        return null;
    }
    
    public List<SelectOption> getOptions()
    {
        return options;
    }
}