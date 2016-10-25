public with sharing class CtrlEditOfferPackageAndFee 
{
	public Offer_Package_And_Fee__c opf {get; set;}
	public Boolean error {get; set;}

	public CtrlEditOfferPackageAndFee(ApexPages.StandardController controller) 
	{
		ID opfId = System.currentPagereference().getParameters().get('id');
		this.opf = [
			SELECT 
				Name, Offer_Template__c, Package_Fee__c, 
				Min_Price__c, Max_Price__c, Default_Price__c, 
				Min_Overusage_Price__c, Max_Overusage_Price__c,
				Overusage_Price__c, Offer_Template__r.Status__c,
				Maintenance_precent__c, hasValue__c, Offer_Template__r.RecordTypeId, Flag_Sorting__c 
			FROM Offer_Package_And_Fee__c
				WHERE Id =:opfId
		];
		
		error = false;
	}
	
	public PageReference init()
	{
		if(opf.Offer_Template__r.RecordTypeId == TLR_RecordTypeHelper.getId('Offer_Template__c', 'TAS Offer template'))
		{
			return Utilities.RedirectToStandardEdit(opf.Id);
		}
		
		if (this.opf.Offer_Template__r.Status__c != 'Pending')
		{
			error = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Offer Template should be in status Pending to modify this Offer Package and Fee'));
		}
		return null;
	}
	
    public PageReference Save() 
    {
        PackFee__c packFee = [SELECT Name, Default_Price__c, Default_Overusage_Price__c,
                                  (SELECT Service__c FROM Package_and_Fee_Line_Items__r)
                                FROM PackFee__c 
                               WHERE Id =: this.opf.Package_Fee__c];
        
        Set<Id> servicesSet = new Set<Id>();
        for(Package_and_Fee_Line_Item__c currPFLI : packFee.Package_and_Fee_Line_Items__r)
            servicesSet.add(currPFLI.Service__c);
        
        List<Offer_Line_Item__c> oLIs = [SELECT Id
                                           FROM Offer_Line_Item__c
                                          WHERE Offer_Template__c =: this.opf.Offer_Template__c
                                            AND Service__c IN : servicesSet];

        if(oLIs.size() != packFee.Package_and_Fee_Line_Items__r.size())
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'You cannot link this Package and Fee because its Line Items do not match with Line Items of parent Offer Template'));
            return null;
        }

        this.opf.Name = [SELECT Name FROM PackFee__c WHERE Id =: this.opf.Package_Fee__c].Name;
        try 
        {
            update opf;        
            return (Utilities.Redirect(System.currentPagereference().getParameters().get('retURL')));
        }
        catch (DMLException e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getDmlMessage(0))); 
            return null;
        }
    }
}