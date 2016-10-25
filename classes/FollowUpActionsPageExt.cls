public class FollowUpActionsPageExt 
{
    private Id CaseId;   
    private Case myCase;

    /*Retrieve the profile of the current user
    */   
    private boolean IsManager;
    private User CurrentUser{get;set;}
    private UserRole CurrentUserRole{get;set;}
    private Profile CurrentUserProfile{get;set;}
    private Id CurrentUserID;

   
    public FollowUpActionsPageExt(ApexPages.StandardController controller) 
    {
       this.myCase= (Case)controller.getRecord();
    }
      public Case getMyCase()
    {
       return myCase;
    } 
    
    public PageReference save()
    { 
       update myCase;
       Case CaseToUpdate = [select Id, Status, Need_Approval__c, Follow_up_action__c, Disable_Posting_Rights__c, Disable_Consultation_Rights__c from Case where Id =:myCase.Id];
       CurrentUser=[Select Id, UserRoleId, ProfileId from User where Id =:UserInfo.getUserId()];
       CurrentUserProfile =[Select Name from Profile where Id =:CurrentUser.ProfileId limit 1];
       
       if (CurrentUserProfile.Name !='System Administrator') {
       CurrentUserRole=[Select Name from UserRole where Id =:CurrentUser.UserRoleId limit 1];
       if ( CurrentUserProfile.Name =='TLR Service' && (CurrentUserRole.Name =='TLR CEE Manager' || CurrentUserRole.Name =='TLR North Manager' || CurrentUserRole.Name =='TLR South Manager' || CurrentUserRole.Name =='TLR West Manager')) {
       
            IsManager = true;
            } else {
            IsManager = false;
            } 
       } else {
        IsManager = true;
       }
           
       if(CaseToUpdate.Need_Approval__c=='Y' && IsManager ==false){    
           CaseToUpdate.Status = 'Need Approval';
          }
        else {
           CaseToUpdate.Status = 'Action Applied';     
        }
         
        if(CaseToUpdate.Follow_up_action__c =='Level 2') {
            CaseToUpdate.Disable_Posting_Rights__c=false;
            CaseToUpdate.Disable_Consultation_Rights__c=false;
            CaseToUpdate.Disable_CoC__c=false;
            CaseToUpdate.Disable_All_Rights__c=false;
            CaseToUpdate.Terminate_Contract__c=false;
            CaseToUpdate.Send_Warning_Letter__c=false;
            CaseToUpdate.Remove_CD__c=false;
        }
        if(CaseToUpdate.Follow_up_action__c =='Level 3') {
            CaseToUpdate.Disable_Posting_Rights__c=false;
            CaseToUpdate.Disable_Consultation_Rights__c=false;
            CaseToUpdate.Disable_CoC__c=false;
            CaseToUpdate.Disable_All_Rights__c=false;
            CaseToUpdate.Terminate_Contract__c=false;
            CaseToUpdate.Friendly_Warning__c=false;
            CaseToUpdate.Remove_CD__c=false;
        }
        if(CaseToUpdate.Follow_up_action__c =='Level 4') {
            CaseToUpdate.Disable_Posting_Rights__c=false;
            CaseToUpdate.Disable_Consultation_Rights__c=false;
            CaseToUpdate.Disable_All_Rights__c=false;
            CaseToUpdate.Terminate_Contract__c=false;
            CaseToUpdate.Friendly_Warning__c=false;
            CaseToUpdate.Send_Warning_Letter__c=false;
            CaseToUpdate.Remove_CD__c=false;
        }
        if(CaseToUpdate.Follow_up_action__c =='Level 5' && CaseToUpdate.Disable_Consultation_Rights__c == false && CaseToUpdate.Disable_Posting_Rights__c == false){
          
          ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please  tick at least one of the following  checkboxes : - Disable Posting Rights, - Disable Consultation Rights');
          ApexPages.addmessage(myMsg);
          return null;
          } 
         
        if(CaseToUpdate.Follow_up_action__c =='Level 5' && CaseToUpdate.Disable_Consultation_Rights__c == true || CaseToUpdate.Disable_Posting_Rights__c == true){

            CaseToUpdate.Disable_All_Rights__c=false;
            CaseToUpdate.Terminate_Contract__c=false;
            CaseToUpdate.Friendly_Warning__c=false;
            CaseToUpdate.Send_Warning_Letter__c=false;
            CaseToUpdate.Remove_CD__c=false;
        }
        if(CaseToUpdate.Follow_up_action__c =='Level 6') {
            CaseToUpdate.Disable_Posting_Rights__c=false;
            CaseToUpdate.Disable_Consultation_Rights__c=false;
            CaseToUpdate.Terminate_Contract__c=false;
            CaseToUpdate.Friendly_Warning__c=false;
            CaseToUpdate.Send_Warning_Letter__c=false;
            CaseToUpdate.Remove_CD__c=false;
        }
       
        if(CaseToUpdate.Follow_up_action__c =='Level 7') {
            CaseToUpdate.Disable_Posting_Rights__c=false;
            CaseToUpdate.Disable_Consultation_Rights__c=false;
            CaseToUpdate.Disable_All_Rights__c=false;
            CaseToUpdate.Friendly_Warning__c=false;
            CaseToUpdate.Send_Warning_Letter__c=false;
            CaseToUpdate.Remove_CD__c=false;
            CaseToUpdate.Disable_CoC__c=false;
        }
        
        if(CaseToUpdate.Follow_up_action__c =='Level 0' || CaseToUpdate.Follow_up_action__c =='Level 1') {
            CaseToUpdate.Disable_Posting_Rights__c=false;
            CaseToUpdate.Disable_Consultation_Rights__c=false;
            CaseToUpdate.Disable_All_Rights__c=false;
            CaseToUpdate.Friendly_Warning__c=false;
            CaseToUpdate.Send_Warning_Letter__c=false;
            CaseToUpdate.Remove_CD__c=false;
            CaseToUpdate.Disable_CoC__c=false;
            CaseToUpdate.Terminate_Contract__c=false;
        }
        
        
        update CaseToUpdate;
        
        PageReference Page = new PageReference('/'+CaseToUpdate.Id);
        Page.setRedirect(true);
        return Page;
    }
    
    public PageReference init(){
    myCase.Action_Start_Date__c= null;
    myCase.Action_End_Date__c= null;
    myCase.Status='In progress';
    myCase.Follow_up_action__c=null;
    myCase.Disable_Posting_Rights__c=false;
    myCase.Disable_Consultation_Rights__c=false;
    myCase.Disable_CoC__c=true;
    myCase.Disable_All_Rights__c=true;
    myCase.Terminate_Contract__c=true;
    myCase.Send_Warning_Letter__c=true;
    myCase.Friendly_Warning__c=true;
    myCase.Remove_CD__c=true;
    return null;
    }
     
    
}