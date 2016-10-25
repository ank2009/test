/**
 * Name : RightsTemplateServiceAttributeClass
 * Created By : Thomas Penne <thomas.penne@atos.net>
 * Date : 2011-09-23
**/
public class RightsTemplateServiceAttributeClass
{
    /**
     * Called by Trigger before deletion
     * Here we check if user can delete a rights template service attribute
     * If not add an error to current record
    **/
    public static void BeforeDelete(Rights_Template_Service_Attribute__c[] attributes)
    {
        Id[] ids = new Id[]{};
        for (Rights_Template_Service_Attribute__c attribute : attributes) 
            ids.add(attribute.Id);
        
        for (Rights_Template_Service_Attribute__c attribute : [SELECT Rights_Template_Service__r.Rights_Template__r.Status__c FROM Rights_Template_Service_Attribute__c WHERE Id IN :ids]) 
            if (attribute.Rights_Template_Service__r.Rights_Template__r.Status__c != 'Pending')
                throw new Generic.StandardException();
    }
}