public with sharing class CtrlNewFollowUpEvent 
{
		/*
   		Create Follow up Event  and Follow up Task from event layout
   		*/
		private final Event event;
		private final Task task;     
		public String name {get; set;}    
		public ID eventID;
        public String Target;
        public String whoId;
        public String whatId; 
         
		public CtrlNewFollowUpEvent(ApexPages.StandardController controller)     
		{   			     
				this.Target = System.currentPagereference().getParameters().get('Target');
				this.eventID  = System.currentPagereference().getParameters().get('id');             
				this.event = [SELECT Id, Subject, WhatId, WhoId, RecordTypeId, Type, Subject1__c, Subject_Group__c  FROM Event WHERE Id = :eventID];        
				this.name = this.event.Subject;
				this.whoId = this.event.WhoId;
				this.whatId = this.event.WhatId;
		}    
			
		public PageReference init()    
		{      
			String redirectUrl;
			String ObjUrl;
			String typeId;		  
			if(this.Target =='Event')
			{
				ObjUrl ='/00U/e?retURL=';
			    typeId = '&evt10=';
			}
			else
			{
				ObjUrl ='/00T/e?retURL=';
			    typeId = '&tsk10=';
			}
			
			String RelatedActivityId = Activity_Field_ID__c.getValues('Current Environment').Related_Activity__c;        
			String SubjectId = Activity_Field_ID__c.getValues('Current Environment').Subject_Id__c;
			String SubjectGroupId= 	Activity_Field_ID__c.getValues('Current Environment').Subject_Group_Id__c;
			
			String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();       
			
			if(this.whoId != null && this.whoId !='' && this.whatId != null && this.whatId != '')
			{
					redirectUrl = baseUrl + ObjUrl + this.eventID + '&who_id=' + this.event.WhoId + '&what_id=' + this.event.WhatId + '&' + SubjectId + '=' + this.event.Subject1__c +'&'+ SubjectGroupId +'='+ this.event.Subject_Group__c+ typeId + this.event.Type + '&' + RelatedActivityId + '=' + baseUrl + '/' + eventID + '&ent='+ this.Target;
			}
			else if(this.whoId != null && this.whoId !='' && this.whatId == null)
			{	
					redirectUrl = baseUrl + ObjUrl + this.eventID + '&who_id=' + this.event.WhoId + '&' + SubjectId + '=' + this.event.Subject1__c +'&'+ SubjectGroupId +'='+ this.event.Subject_Group__c + typeId + this.event.Type + '&' + RelatedActivityId + '=' + baseUrl + '/' + eventID +'&ent='+ this.Target;
			}
			else if (this.whatId != null && this.whatId !='' && this.whatId == null)
			{
					redirectUrl = baseUrl + ObjUrl + this.eventID + '&what_id=' + this.event.WhatId + '&'+ SubjectId+ '=' + this.event.Subject1__c +'&'+ SubjectGroupId +'='+ this.event.Subject_Group__c + typeId + this.event.Type + '&' + RelatedActivityId + '=' + baseUrl + '/' + eventID + '&ent='+ this.Target;
			}
			else
			{
					redirectUrl = baseUrl + ObjUrl + this.eventID + '&' + SubjectId +'='+ this.event.Subject1__c +'&'+ SubjectGroupId +'='+ this.event.Subject_Group__c + typeId + this.event.Type +'&' + RelatedActivityId + '=' + baseUrl + '/' + eventID + '&ent='+ this.Target;
			}
			
			PageReference pageRedirect = new PageReference(redirectUrl);        
			pageRedirect.setRedirect(true);                
			return pageRedirect;    
		}   
				     
		public PageReference Cancel()    
		{    
		    return (Utilities.Redirect(this.event.Id));  		  
		}
}