public class CtrlNewFollowUpTask 
{
   		/*
   		Create Follow up task and follow up event from task 
   		*/
   		
   		private final Task task;    
		public String name {get; set;}    
		public ID taskID;
		public String whoId;
		public String whatId;
		public String Target;
   
		public CtrlNewFollowUpTask(ApexPages.StandardController controller)     
		{   
			this.Target = System.currentPagereference().getParameters().get('Target');
			this.taskID  = System.currentPagereference().getParameters().get('id');
			this.task = [SELECT Id, Subject, WhatId, WhoId, RecordTypeId, Priority, Type, Subject1__c, Subject_Group__c  FROM Task WHERE Id = :taskID];        			
			this.name = this.task.Subject;
			this.WhoId = this.task.whoId;
			this.whatId = this.task.whatId;
			//this.recordTypeId = this.task.RecordTypeId; 
									
		}    
			// '&tsk5='+ this.task.Subject +'&tsk10='+ this.task.Type +
		public PageReference init()    
		{    
			String redirectUrl; 
			String ObjUrl;
			String typeId;
			
			if(this.Target == 'Task')
			{
				ObjUrl ='/00T/e?retURL=';
				typeId ='&tsk10=';
			}	
			else
			{
				ObjUrl ='/00U/e?retURL=';
				typeId ='&evt10=';
			}
			      
			String idField = Activity_Field_ID__c.getValues('Current Environment').Related_Activity__c;
			String SubjectId = Activity_Field_ID__c.getValues('Current Environment').Subject_Id__c;
			String SubjectGroupId= Activity_Field_ID__c.getValues('Current Environment').Subject_Group_Id__c;
			
			String baseUrl = URL.getSalesforceBaseUrl().toExternalForm(); 
			
			if(this.WhoId != null && this.WhoId !='' && this.WhatId !=null && this.WhatId !='') 
			{   					
					redirectUrl = baseUrl + ObjUrl + this.taskID + '&who_id=' + this.task.WhoId + '&what_id=' + this.task.WhatID + typeId + this.task.Type + '&'+ SubjectId + '=' + this.task.Subject1__c + '&' + SubjectGroupId + '=' + this.task.Subject_Group__c + '&' + idField + '=' + baseUrl + '/' + taskID + '&ent=' +this.Target;                				
			} 
			else if(this.WhoId != null && this.WhoId !='' && this.WhatId ==null)
			{		
					redirectUrl = baseUrl + ObjUrl + this.taskID + '&who_id=' + this.task.WhoId + typeId  + this.task.Type  + '&'+ SubjectId + '=' + this.task.Subject1__c + '&' + SubjectGroupId + '=' + this.task.Subject_Group__c + '&' + idField + '=' + baseUrl + '/' + taskID + '&ent=' + this.Target;
			}
			else if(this.WhatId != null && this.WhatId !='' && this.WhoId ==null)
			{					
					redirectUrl = baseUrl + ObjUrl + this.taskID + '&what_id=' + this.task.WhatID + typeId + this.task.Type + '&'+ SubjectId + '=' + this.task.Subject1__c + '&' + SubjectGroupId + '=' + this.task.Subject_Group__c + '&' + idField + '=' + baseUrl + '/' + taskID + '&ent=' + this.Target;                	
			}
			else
			{					
					redirectUrl = baseUrl + ObjUrl + this.taskID + typeId + this.task.Type + '&'+ SubjectId + '=' + this.task.Subject1__c + '&' + SubjectGroupId + '=' + this.task.Subject_Group__c +'&' + idField + '=' + baseUrl + '/' + taskID + '&ent=' + this.Target;                					
			}
				
			PageReference pageRedirect = new PageReference(redirectUrl);        
			pageRedirect.setRedirect(true);                
			return pageRedirect;    
		}   
				     
		public PageReference Cancel()    
		{        
			return (Utilities.Redirect(task.Id));			
		}
}