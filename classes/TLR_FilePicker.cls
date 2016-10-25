public with sharing class TLR_FilePicker
{ 
	public Attachment attachment{get;set;}
    public String parentId{get;set;}
	public List<Attachment> lstAttachment{get;set;}
	public Boolean showError{get;set;} //show error flag if file is not specified
	public String newAttachmentIds{get;set;} //string of ids of newly added attachments
	public static final Decimal MAX_FILE_SIZE = 5200000; //max attachment size constant(5MB)
	
	public TLR_FilePicker()
	{
		showError = false;
        newAttachmentIds = '';
        parentId = ApexPages.currentPage().getParameters().get('parentId');
        attachment = new Attachment();
      	lstAttachment = new List<Attachment>();
    }
    
     /**
      * Method Name : attachToEmail
      * Description : This method is used to insert file selected by user as an attachment for
  	  *        		  Case or Account.
      * Arguments   : none
      * Returns     : void
      **/
    public void attachToEmail()
    {
    	try
    	{
			if(attachment.name != null && attachment.body != null)
			{
	        	if(attachment.BodyLength != null && Decimal.valueOf(attachment.BodyLength) > MAX_FILE_SIZE)
	        	{
	          		//if attachment size is greater than 5MB show error message
	          		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'The file cannot be larger than 5MB. Please check.'));
	        	}
	        	else
	        	{
					attachment.isPrivate = false;
	              	attachment.ownerId = UserInfo.getUserId();
	              	attachment.parentId = parentId;
	          		Database.insert(attachment);
	          		attachment.body = null;
	          		lstAttachment.add(attachment);
	          		newAttachmentIds = newAttachmentIds + attachment.Id + ';';
					showError = false;
	        	}
      		}
      		else
      		{
		        //if file is not selected while upload show error message
		        showError = true;
      		}
    	}
    	catch(Exception ex)
    	{
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'An unexpected error has occurred. Please contact your System Admin'));
            System.debug('Exception: '+ex.getMessage()+', Class: TLR_FilePicker, Method: attachToEmail()');
        }
        finally
        {
            attachment = new Attachment();
        }
    }
}