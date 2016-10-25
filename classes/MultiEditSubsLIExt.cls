public class MultiEditSubsLIExt 
{
    public Boolean error { get; set; }
    public String title { get; set; }
    
    public MultiEditSubsLIExt(ApexPages.StandardSetController controller) 
    {
        if (controller.getSelected().size() == 0)
        {
            error = true;
            title = 'Error';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Please, select at least one item before clicking the button'));
        }
        else
            title = 'Multi-Edit';
    }
}