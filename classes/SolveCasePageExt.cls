public class SolveCasePageExt 
{
    private final Case myCase;
    
    public SolveCasePageExt(ApexPages.StandardController controller) 
    {
        this.myCase= (Case)controller.getRecord();
    }

    public Case getMyCase()
    {
        return myCase;
    }
    
    public PageReference init()
    {
        myCase.Status = 'Resolved';
        myCase.Handling_Side__c = 'Complainer';               
        return null;
    }
}