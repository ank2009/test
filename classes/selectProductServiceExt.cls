public class selectProductServiceExt 
{
    private final Product__c prod;
    public List<String> valChk { get; set; }
    public List<SelectOption> options;
    public Map<ID, String> mapServices;
    public Boolean dataToDisplay { get; set; }
    public String title { get; set; }
    
    public selectProductServiceExt(ApexPages.StandardController controller) 
    {
        ID prodId = System.currentPagereference().getParameters().get('id');
        this.prod = [SELECT Id, RecordTypeId, Start_Date__c, End_Date__c, Status__c FROM Product__c WHERE Id = :prodId];
    }
    
    public PageReference init()
    {
        if (this.prod.Status__c != 'Pending')
        {
            dataToDisplay = false;
            title = 'Error';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Service(s) can be linked to Product only when Product is under Pending status.'));
            return null;
        }
        
        if (options == null)
            options = new SelectOption[0];
        if (valChk == null)
            valChk = new String[0];
        if (mapServices == null)
            mapServices = new Map<ID, String>();
            
            
        List<Product_Line_Item__c> existingProductLineItems = [
        	SELECT
        		Id, Service__c
        	FROM Product_Line_Item__c
        	WHERE Parent__c = :prod.id
        ];
        List<Id> existingServices = new List<Id>();
        for(Product_Line_Item__c pli : existingProductLineItems)
        	existingServices.add(pli.Service__c);
        	
        List<Service__c> services = [
			SELECT 
				Name, Id 
			FROM Service__c 
			WHERE  Status__c = 'Active' 
				AND Id NOT IN :existingServices
				AND Start_Date__c <= :this.prod.Start_Date__c 
				AND (End_Date__c = null OR (End_Date__c >= :this.prod.End_Date__c))
			ORDER BY Name ASC
		];
		for (Service__c service : services)
		{
			options.add(new SelectOption(service.Id, service.Name));
			mapServices.put(service.Id, service.Name);
		}
        
        if (options.size() == 0)
        {
            dataToDisplay = false;
            title = 'Error';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'No Service available. Either no Service is existing or all existing Services have already been added.'));
        }
        else
        {
            dataToDisplay = true;
            title = 'Select Service(s)';
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
    	return TLR_ProductPageLineItemHelper.Save(valChk, prod);  
   /*
        for (String s : valChk)
        {
            Integer cpt = [SELECT count() FROM Product_Line_Item__c WHERE Parent__c = :prod.id AND Service__c = :s];
            
            if (cpt == 0)
            {
                Product_Line_Item__c serv = new Product_Line_Item__c();
                serv.Parent__c = prod.id;
                serv.Service__c = s;
                insert serv;
            }
        }
        
        return (Utilities.Redirect(this.prod.id));
    */
    }
    
    public PageReference Cancel() 
    {
        return (Utilities.Redirect(this.prod.id));
    }
}