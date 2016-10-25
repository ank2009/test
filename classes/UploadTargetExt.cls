public class UploadTargetExt 
{
    private final String regExp = '(([a-zA-Z0-9]{15}|[a-zA-Z0-9]{18})\\r\\n)*(([a-zA-Z0-9]{15}|[a-zA-Z0-9]{18})(\\r\\n)?)';
    private final Campaign_Promotion__c  cp;
    public Document mydoc;
       
    public UploadTargetExt(ApexPages.StandardController controller) 
    {
        ID cpId = System.currentPagereference().getParameters().get('id');
        this.cp = [SELECT Id, CurrencyIsoCode FROM Campaign_Promotion__c WHERE Id = :cpId];
    }

    Public Document getMyDocument()
    {
        mydoc = new Document();
        return mydoc;
    }
   
    Public Pagereference Savedoc()
    {
        string filename = mydoc.Name;
        if (!filename.endsWith('csv') && !filename.endsWith('txt'))
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'File must be a csv or txt file'));
            return null;
        }
        else
        {
            String body = (mydoc.Body).toString();
            if (!Pattern.matches(regExp, body))
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Invalid file format! Format must be one line = one subscription id'));
                return null;
            }
            else
            {
                String[] lines = body.split('\r\n');
                
                Map<ID, Subscription__c> mapSub = new Map<ID, Subscription__c>([SELECT Id, Contract__c, Contract__r.AccountId, (SELECT Id FROM Campaign_Promotion_Subscription_LIs__r WHERE Campaign_Promotion__c = :this.cp.Id) FROM Subscription__c WHERE Id IN :lines]);
                
                String lstError = '';
                for (String line : lines)
                {
                    try
                    {
                        if (mapSub.get(line) == null)
                            lstError += line + ', ';
                    }
                    catch (Exception e)
                    {
                        lstError += line + ', ';
                    }
                }
                
                if (lstError != '')
                {
                    lstError = lstError.substring(0, lstError.length() - 2);
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Invalid subscription id(s): ' + lstError));
                    return null;
                }
                else
                {
                    List<Campaign_Promotion_Subscription_LI__c> lstSubToInsert = new List<Campaign_Promotion_Subscription_LI__c>();
                    for (ID idSub : mapSub.keySet())
                    {
                        if (mapSub.get(idSub).Campaign_Promotion_Subscription_LIs__r.size() == 0)
                        {
                            Campaign_Promotion_Subscription_LI__c cps = new Campaign_Promotion_Subscription_LI__c();
                            cps.Campaign_Promotion__c = this.cp.Id;
                            cps.Subscription__c       = idSub;
                            cps.Contract__c           = mapSub.get(idSub).Contract__c;
                            cps.Account__c            = mapSub.get(idSub).Contract__r.AccountId;
                            cps.CurrencyIsoCode       = this.cp.CurrencyIsoCode;
                            lstSubToInsert.add(cps);
                        }
                    }
                    
                    if (lstSubToInsert.size() > 0)
                        insert lstSubToInsert;
                }
            }
        }
        
        return (Utilities.Redirect(this.cp.Id));
    }  
    
    Public Pagereference Cancel()
    {
        return (Utilities.Redirect(this.cp.Id));
    }
}