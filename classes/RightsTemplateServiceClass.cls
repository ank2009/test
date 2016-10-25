/**
 * Name : RightsTemplateServiceClass
 * Created By : Thomas Penne <thomas.penne@atos.net>
 * Date : 2011-09-13
**/
public class RightsTemplateServiceClass
{
    /**
     * Called by Trigger before deletion
     * Here we check if user can delete a rights template service
     * If not add an error to current record
    **/
    public static void BeforeDelete(Rights_Template_Service__c[] services)
    {
        Id[] ids = new Id[]{};
        for (Rights_Template_Service__c service : services) 
            ids.add(service.Id);
        
        for (Rights_Template_Service__c service : [SELECT Rights_Template__r.Status__c FROM Rights_Template_Service__c WHERE Id IN :ids]) 
            if (service.Rights_Template__r.Status__c != 'Pending')
                throw new Generic.StandardException();
    }
}