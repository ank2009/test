public class DWHReportsExt {

    public Account account;
    public String accountNumber { get; set; }
    public String selectedValue { get; set; }
    public List<SelectOption> options;
    
    public DWHReportsExt(ApexPages.StandardController controller) 
    {
        this.account = (Account)controller.getRecord();
    }
    
    public PageReference init()
    {
        if (options == null)
            options = new List<SelectOption>();
            
        String txt1 = '<b>Report 1: Usage Overview by Account</b></br>' 
        + '<dd>This report gives you a detailed overview per Account, containing '
        + 'information regarding Account details, Addresses, Contact details, Usernames, Categories, Usage, '
        + 'Activities, Contracts, Subscriptions, Current Fees, Invoices, Service Requests and Revenues</br></br>';
            
        SelectOption so1 = new SelectOption('Report1', txt1);
        so1.setEscapeItem(false);         
            
        String txt2 = '<b>Report 2: Invoice</b></br>'
        + '<dd>This report is used when a customer complaints about his invoice; it is based on revenue data, '
        + 'it shows the detail of the invoice of the customer, thus the customer care can answer and advise the customer.</br></br>'; 
                
        SelectOption so2 = new SelectOption('Report2', txt2);
        so2.setEscapeItem(false);

	String txt3 = '<b>OBI reports and dashboards</b></br>'
        + '<dd>This page is a menu where you can find link on OBI reports and dashboards available.</br></br>';        

        SelectOption so3 = new SelectOption('Report3', txt3);
        so3.setEscapeItem(false);
        
              
        options.add(so1);
	options.add(so2);
        options.add(so3);
       

        selectedValue = options[0].getValue();
        
        String acNumber = [SELECT AccountNumber FROM Account WHERE Id = :account.Id].AccountNumber;
        
        if(acNumber == null)
          accountNumber = 'Not available';
        else
          accountNumber = acNumber ;
                   
        return null;
    }

    public List<SelectOption> getOptions()
    {
        return options;
    }
    
    public PageReference Cancel() {
        PageReference thePage = new PageReference('/' + this.account.id);
        thePage.setRedirect(true);
        return thePage;
    }
}