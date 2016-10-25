/**
* @author       HCL, then Anton Solovyev (anton_soloveyv@epam.com)
* @date         who knows, then 2014 Feb 21
* @description  Controller class for TLR_SendAnEmail page
**/
public without sharing class TLR_SendAnEmail
{
	public String newAttachmentIds{ get; set; } //ids of new attachments added by user
	public List<AttachmentWrapper> attachmentWrapperList{ get; set; }
	//public String sObjectName;
	private String emailAttachmentsName;
	////////////////////////
	public Id objectId { get; set; }
	public string objectType { get; set; }
	public string objectName { get; set; }
	public string objectFullName { get { return (objectType + ' : ' + objectName); } set; }
	
	public string returnUrl { get; set; }
	
	public string selectedEmailTemplateId { get; set; }
	
	public string selectedFromAddress { get; set; }
	public string selectedType { get; set; }
	public string selectedSubjectGroup { get; set; }
	public string selectedSubject { get; set; }
	public string selectedSubjectSubgroup { get; set; }
    public string selectedProductLine { get; set; }
	
	public string emailTo { get; set; }
	public string emailAdditionalTo { get; set; }
	public string emailCC { get; set; }
	public string emailBCC { get; set; }
	
	public string emailSubject { get; set; }
	public string emailBody { get; set; }
    
    public string attachmentsList{ get; set; }
    
    public Task NewTask { get; set; }
	
	public List<SelectOption> availableFromAddresses { get; set; }
	public List<SelectOption> availableTypes { get; set; }
	public List<SelectOption> availableSubjectGroups { get; set; }
	public List<SelectOption> availableSubjects { get; set; }
	public List<SelectOption> availableSubgroups { get; set; }
    public List<SelectOption> availableProductLines { get; set; }
	/////////////////////
	
	public void initSendAnEmail()
	{
        attachmentsList = '';
		attachmentWrapperList = new List<AttachmentWrapper>();
		emailAttachmentsName = '';
		selectedType = '13 E-mail out';
		NewTask = new Task();
		try
		{
			availableFromAddresses = new List<SelectOption>();
			List<OrgWideEmailAddress> lstOrgWideEmailAddress = [Select Id, DisplayName, Address From OrgWideEmailAddress order by DisplayName];		
			if(lstOrgWideEmailAddress != null && lstOrgWideEmailAddress.size() > 0)
			{
				availableFromAddresses.add(new SelectOption(Userinfo.getUserEmail(), '"' + Userinfo.getName() + '" <' + Userinfo.getUserEmail() + '>'));
				for(OrgWideEmailAddress objEmail : lstOrgWideEmailAddress)
				{
					availableFromAddresses.add(new SelectOption(objEmail.Id, '"' + objEmail.DisplayName + '" <' + objEmail.Address + '>'));
				}
			}
			// availableTypes
			availableTypes = new List<SelectOption>();
			for(string s : Utilities.getPicklistValues('Task', 'Type'))
				availableTypes.add(new SelectOption(s, s));
			// availableSubjectGroups
			availableSubjectGroups = new List<SelectOption>();
			for(string s : Utilities.getPicklistValues('Task', 'Subject_Group__c'))
				availableSubjectGroups.add(new SelectOption(s, s));			
			// availableSubjects
			availableSubjects = new List<SelectOption>();
			for(string s : Utilities.getPicklistValues('Task', 'Subject'))
				availableSubjects.add(new SelectOption(s, s));			
			//availableSubgroups
			availableSubgroups = new List<SelectOption>();
			for(string s : Utilities.getPicklistValues('Task', 'Subject1__c'))
				availableSubgroups.add(new SelectOption(s, s));	
            //availableProductLines
            availableProductLines = new List<SelectOption>();
            for(string s : Utilities.getPicklistValues('Task','Product__c'))
                availableProductLines.add(new SelectOption(s, s));
			string referer = ApexPages.currentPage().getHeaders().get('Referer');
			PageReference pageReferer = new PageReference(referer);			
			if(pageReferer == null)
				throw new Generic.StandardException('Incorreft REFERER HTTP header. Please check your browser settings.');			
			objectId = pageReferer.getParameters().get('eid');
			returnUrl = pageReferer.getParameters().get('retURL');
			Schema.SObjectType objType = objectId.getSObjectType();
			objectType = objType.getDescribe().getName();
            if(objectType == 'Case')
            {
                objectName = string.valueOf(getSObject(objectId, objectType).get('CaseNumber'));
            }
            else
            {
                objectName = string.valueOf(getSObject(objectId, objectType).get('Name'));
            }	
            if(objectType == 'Contact')
            {
                string contactEmail=[select Id, Email from Contact where Id =: objectId].Email;
                emailTo=contactEmail+';';
            }
		}
		catch(Exception ex)
		{
			ApexPages.addMessages(ex);
		}
	} // initSendAnEmail
	
	/**
	* @author       Anton Solovyev (anton_soloveyv@epam.com)
	* @date         2014 Feb 21
	* @description  returns sObject for given type and Id, with basic fields filled
	**/
	private sObject getSObject(Id objId, string objType)
	{
        string soql;
        if(objType == 'Case')
        {
            soql = 'SELECT Id, CaseNumber  FROM ' + objType + ' WHERE Id = \'' + objId + '\'';
        }
        else
        {
            soql = 'SELECT Id, Name FROM ' + objType + ' WHERE Id = \'' + objId + '\'';
        }		
		return Database.query(soql);
	} //getSObject
	
	/**
	* @author       HCL, Anton Solovyev (anton_soloveyv@epam.com)
	* @date         2014 Feb 21
	* @description  sends an email
	**/
	public PageReference sendEmail()
	{
		try
		{		
			String[] toAddresses = new String[]{};
			String[] ccAddresses = new String[]{};
			String[] bccAddresses = new String[]{};
			
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			
			if(!string.isEmpty(emailTo))
            {
				toAddresses.addAll(emailTo.split(';',0));
            }
			if(!string.isEmpty(emailAdditionalTo))
            {
				toAddresses.addAll(emailAdditionalTo.split(';',0));	
        	}
			if(!string.isEmpty(emailCC))
            {
				mail.setCcAddresses(emailCC.split(';',0));
            }
			if(!string.isEmpty(emailBCC))
            {
				mail.setBccAddresses(emailBCC.split(';',0));
            }
            
			mail.setToAddresses(toAddresses);
			mail.setSubject(emailSubject);
			mail.setPlainTextBody(emailBody);
			List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
            List<String> attachmentIds = new List<String>();
            if(String.isNotEmpty(newAttachmentIds))
            {
				attachmentIds = newAttachmentIds.Split(';');
            }
            if(attachmentIds.size() > 0)
            {
                for (Attachment a : [select Name, Body, BodyLength from Attachment where Id =: attachmentIds])
                {
                   Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                   efa.setFileName(a.Name);
                   efa.setBody(a.Body);
                   fileAttachments.add(efa);
                    if(a.Name  != null)
                    {  
                        attachmentsList = attachmentsList + a.Name + '; ';
                    }
                 
                }
                mail.setFileAttachments(fileAttachments);		
            }
			if(!string.isEmpty(selectedFromAddress) && selectedFromAddress != Userinfo.getUserEmail())
            {
				mail.setOrgWideEmailAddressId(selectedFromAddress);		
            }
			Messaging.SendEmailResult[] mailResult = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
			addActivity();
		}
		catch(Exception ex)
		{
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
			return null;
		}
		return Utilities.Redirect(objectId);
	} //sendEmail
	
	/**
	* @author       Anton Solovyev (anton_soloveyv@epam.com)
	* @date         2014 Feb 21
	* @description  returns user to previous page
	**/
	public PageReference cancel()
	{
		return (new PageReference(returnUrl));
	}
	
	/**
	* @author       HCL, Anton Solovyev (anton_soloveyv@epam.com)
	* @date         2014 Feb 21
	* @description  fills emailBody using chosen email template
	**/
	public void FillEmailBodyUsingTemplate()
	{
		EmailTemplate objEmailTemplate = new EmailTemplate();
		try
		{
			objEmailTemplate = [
				SELECT 
					Id, Name, Subject, Body, TemplateType, Description
				FROM EmailTemplate
				WHERE  Id = :selectedEmailTemplateId];			
			emailBody = parseMergedFieldContent(objEmailTemplate.Body, objectType, objectId);
			emailSubject = parseMergedFieldContent(objEmailTemplate.Subject, objectType, objectId);
		}
		catch(Exception ex)
		{
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'An unexpected error has occurred. Please contact your System Admin'));
		}
	} //FillEmailBodyUsingTemplate
	
	/**
	* @author       HCL, Anton Solovyev (anton_soloveyv@epam.com)
	* @date         2014 Feb 21
	* @description  
	**/
	private string parseMergedFieldContent(string templateBody, String sObjectType, String referenceRecordId)
	{
		SObject sObj;
		string retVal = '';	
		try
		{
			Map<string, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get(sObjectType).getDescribe().fields.getMap().clone();
			// get list of merged fields from email template
			Set<String> mergedFields = extractMergedFieldsList(templateBody);			
			// now we need to get object's fields list to pass it to SOQL query
			List<string> fieldsToQuery = new List<string>();
			for(string fld : mergedFields)
			{
				if(fld.contains(sObjectType))
				{
					string objectField = fld.substring(2 + sObjectType.length());
					objectField = objectField.substring(1, objectField.length() - 1);
					// we need to select other fields for some fields
					string field = getQueryFieldOrValue(objectField, null, Schema.DisplayType.anytype);
					fieldsToQuery.add(field);
				}
			}
			
			// query object from SF
			if(!fieldsToQuery.isEmpty())
			{
				string query = 'SELECT ' + Utilities.ListToString(fieldsToQuery, ',') + ' FROM ' + sObjectType + ' WHERE Id = :referenceRecordId';
				sObj = Database.query(query);
			}
			retVal = templateBody;
            for(String mergeField : mergedFields)
			{
				String regEx = mergeField.replace('{', '\\{').replace('}','\\}');				
				if(mergeField.contains(sObjectType))
				{
					string fieldName = mergeField.substring(mergeField.indexOf('.')+1, mergeField.length()-1);
					string fieldValue = fieldsMap.containsKey(fieldName) ? 
						getQueryFieldOrValue(fieldName, sObj, fieldsMap.get(fieldName).getDescribe().type) : 
						getQueryFieldOrValue(fieldName, sObj, Schema.DisplayType.anytype);
					retVal = retVal.replaceAll(regEx, (fieldValue != NULL ? fieldValue : ''));
				} // if field contains object name, means it belongs to object
			} // for each mergeField
		}
		catch(Exception ex)
		{
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
		}
		return retVal;
	} //parseMergedFieldContent
	
	/**
	* @author       Anton Solovyev (anton_soloveyv@epam.com)
	* @date         2014 Feb 24
	* @description  performs processinf for all fields, including special fields, missing from sObject
					if sObj is null - then it returns field to extract, 
					if sObj is not null - it returns field value
	**/
	private string getQueryFieldOrValue(string fieldName, sObject sObj, Schema.DisplayType fieldType)
	{
		string retVal = '';
		try
		{
			// Link field
			if(fieldName.equalsIgnoreCase('link'))
            {
				retVal = sObj == null ? 'Id' : string.format('{0}/{1}', new String[] { Url.getSalesforceBaseUrl().toExternalForm(), string.valueOf(sObj.get('Id')) });
            }
			// createdBy
			if(fieldName.equalsIgnoreCase('createdBy'))
            {
				retVal = sObj == null ? 'createdBy.Name' : string.valueOf(sObj.getSObject('CreatedBy').get('Name'));
            }
			
			// if field is simple
			if(string.isEmpty(retVal))
			{	//retVal = sObj == null ? fieldName : string.valueOf(sObj.get(fieldName));
				if(sObj == null)
					retVal = fieldName;
				else
					retVal = sObj.get(fieldName) == null ? 'null' : string.valueOf(sObj.get(fieldName));
			}
			// if our value is not null
			if(!retVal.equalsIgnoreCase('null'))
			{
				// parse date field (skip time part)
				if(fieldType == Schema.DisplayType.Date && sObj != null)
                {
					retVal = ((datetime)sObj.get(fieldName)).date().format();
                }	
				// parse dateTime field (object's adtetime is stored as GMT, and string.valueOf does not know about it. So we need custom processing as below)
				if(fieldType == Schema.DisplayType.DateTime && sObj != null)
                {
					retVal = ((datetime)sObj.get(fieldName)).format();
                }
			}
		}
		catch (exception ex)
		{
			retVal = 'Error';
		}
		return retVal;
	} //getQueryFieldOrValue
	
	/**
	* @author       HCL, Anton Solovyev (anton_soloveyv@epam.com)
	* @date         2014 Feb 21
	* @description  extracts set of strings, contains all merged fields in inputString
	**/
	private Set<String> extractMergedFieldsList(String inputString)
	{
		Matcher m = Pattern.compile('(\\{![A-Za-z_]+.[A-Za-z_]+\\})').matcher(inputString);
		Set<String> retVal = new Set<String>();
		try
		{
			while(m.find())
			{
				String mergeField = m.group(0);
				retVal.add(mergeField);
			}
		}
		catch(Exception ex)
		{
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'An unexpected error has occurred. Please contact your System Admin'));
		}
		return retVal;
	} //extractMergedFieldsList
	
	/**
	* @author       Anton Solovyev (anton_soloveyv@epam.com)
	* @date         2014 Mar 6
	* @description  add activity record to related object.
	**/
	private void addActivity()
	{
		//Task t = new Task();
		Task t = newTask;
		t.Status = 'Completed';
		t.Description = string.format('Additional To: {0}\nCC: {1}\nBCC: {2}\nAttachment: {3}\nSubject: {4}\nBody:\n{5}', 
			new string [] {emailAdditionalTo, emailCC, emailBCC, attachmentsList, emailSubject, emailBody});
        if(String.valueOf(objectid).startsWith('003') || String.valueOf(objectid).startsWith('00Q'))
        {
            t.WhoId = objectId;
            
        }
        else
        {
			t.WhatId = objectId;
        }
		t.Priority = 'Normal';
		t.ActivityDate = date.today();
	//	t.Subject1__c = selectedSubjectSubgroup;
	//	t.Subject = selectedSubject;
	//	t.Subject_Group__c = selectedSubjectGroup;	
    //    t.Product__c=selectedProductLine;
    //    t.Type=selectedType;
		insert t;
	} //addActivity
    
    
     /**
      * Method Name : queryAttachmentDetails
      * Description : This method is used to query attachment details for
      *               new attachments uploaded by user during send email
      * Arguments   : none
      * Returns     : void
      **/
    public void queryAttachmentDetails()
    {
        List<String> attachmentIdList = new List<String>();
        List<Attachment> attachmentList = new List<Attachment>();
        if(newAttachmentIds != null)
        {
            attachmentIdList = newAttachmentIds.split(';');
        }
        if(!attachmentIdList.isEmpty())
        {
            attachmentList = [Select Id, Name, BodyLength, Description, ContentType
                              From   Attachment
                              Where  Id in :attachmentIdList];
        }
        if(!attachmentList.isEmpty())
        {
            createAttachmentWrapper(attachmentList, true);
        }
    }
    
    /**
      * Method Name : createAttachmentWrapper
      * Description : This method is used to create wrapper list of attachments list passed as parameter
      * Arguments   : List<Attachment> attachmentList, Boolean setSelected
      * Returns     : void
      **/
    private void createAttachmentWrapper(List<Attachment> attachmentList, Boolean setSelected)
    {
        if(!attachmentList.isEmpty())
        {
            for(Attachment attachmentRec : attachmentList)
            {
                attachmentWrapperList.add(new AttachmentWrapper(attachmentRec, setSelected));
            }
        }
    }
    
     /**
    *  Name            : AttachmentWrapper
    *  Description     : This class is used to create wrapper for attachment records
    **/
    public class AttachmentWrapper
    {
        public Attachment attachmentRec{get;set;}
        public Boolean isSelected{get;set;}

        public AttachmentWrapper(Attachment attachmentRec, Boolean isSelected)
        {
            this.attachmentRec = new Attachment();
            this.attachmentRec = attachmentRec;
            this.isSelected = isSelected;
        }
    }
}