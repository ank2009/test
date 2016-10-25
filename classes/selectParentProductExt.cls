public class selectParentProductExt 
{
    private final Product__c prod;
    public List<String> valChk { get; set; }
    public List<SelectOption> options;
    public Map<ID, String> mapParents;
    public Boolean dataToDisplay { get; set; }
    public String title { get; set; }
    
    public selectParentProductExt(ApexPages.StandardController controller) 
    {
        ID prodId = System.currentPagereference().getParameters().get('id');
        this.prod = [SELECT Id, Start_Date__c, Add_on__c, Status__c FROM Product__c WHERE Id = :prodId];
    }
    
    public PageReference init()
    {
        if (options == null)
            options = new SelectOption[0];
        if (valChk == null)
            valChk = new String[0];
        if (mapParents == null)
            mapParents = new Map<ID, String>();

        if(!this.prod.Add_on__c) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This product is not an Add-on. You cannot add a parent product.'));
            return null;
        }
        
        if(this.prod.Status__c != 'Pending') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The status of this Add-on is not Pending. You cannot add a parent product.'));
            return null;
        }
            
        List<Product__c> products = [SELECT Name, Id FROM Product__c WHERE  Status__c = 'Active' AND Add_on__c = false AND Start_Date__c <= :this.prod.Start_Date__c ORDER BY Name ASC];
        for (Product__c currentProd : products)
        {
            Integer cpt = [SELECT count() FROM Add_on_Parent__c WHERE Add_on__c = :prod.id AND Product__c = :currentProd.Id];
            
            if (cpt == 0)
            {
                options.add(new SelectOption(currentProd.Id, currentProd.Name));
                mapParents.put(currentProd.Id, currentProd.Name);
            }
        }
        
        if (options.size() == 0)
        {
            dataToDisplay = false;
            title = 'Error';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'No Product available. Either no Product is existing or all existing Products have already been added.'));
        }
        else
        {
            dataToDisplay = true;
            title = 'Select Parent Product(s) for Add-on';
        }
        
        return null;
    }
    
    public List<SelectOption> getOptions()
    {
        return options;
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
    
    public PageReference Save() 
    {
        for (String s : valChk)
        {
            Integer cpt = [SELECT count() FROM Add_on_Parent__c WHERE Add_on__c = :prod.id AND  Product__c = :s];
            
            if (cpt == 0)
            {
                Add_on_Parent__c aop = new Add_on_Parent__c();
                aop.Add_on__c = prod.id;
                aop.Product__c = s;
                insert aop;
            }
        }
        
        return (Utilities.Redirect(this.prod.id));
    }
    
    public PageReference Cancel() 
    {
        return (Utilities.Redirect(this.prod.id));
    }
}