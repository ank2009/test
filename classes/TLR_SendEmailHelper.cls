public class TLR_SendEmailHelper 
{
	public static void SendEmailWithHtmlBodyNoReply(String emailBody, String senderName,String subject,List<String> adresses)
	{
		SendEmail(true, emailBody, senderName, subject, adresses, null, null, 'noreply@salesforce.com');
	}
	
	/**
	* @author       Anton Solovyev (anton_soloveyv@epam.com)
	* @date         2014 Feb 24
	* @description  sends an email, with additional parameters
	**/
	public static void SendEmail(boolean isBodyHTML, String emailBody, String senderName, String subject, 
				List<String> toAddresses, List<String> ccAddresses, List<String> bccAddresses,
				string relpyAddress)
	{
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		
		mail.setToAddresses(toAddresses);
		
		if(ccAddresses != null)
			mail.setCcAddresses(ccAddresses);
		if(bccAddresses != null)
			mail.setCcAddresses(bccAddresses);
		
		if(!string.isEmpty(relpyAddress))
			mail.setReplyTo(relpyAddress);
        if(!string.isEmpty(senderName))
			mail.setSenderDisplayName(senderName);
		mail.setSubject(subject);
		
		if(isBodyHTML)
			mail.setHtmlBody(emailBody);
		else
			mail.setPlainTextBody(emailBody);
		
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	} //SendEmail
}