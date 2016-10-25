public with sharing class TLR_TemplateSelector
{ 
    public final static String PUBLIC_EMAIL_TEMPLATES_FOLDER = 'Unfiled Public Email Templates';
    public final static String PERSONAL_EMAIL_TEMPLATES_FOLDER = 'My Personal Email Templates';

    public List<SelectOption> templateFolders {get;set;} //List of email template folders
    public String selectedFolderId {get;set;}    //Id of selected email template
    public List<EmailTemplate> lstEmailTemplate {get;set;}  //List of email templates in selected email template folder

    public TLR_TemplateSelector()
    {
        queryFolders();
    }

    private void queryFolders()
    {
        List<Folder> lstFolder = new List<Folder>();

        lstFolder = [SELECT   Id, Name, DeveloperName
                       FROM     Folder
                       WHERE    Type = 'Email'
                       ORDER BY Name ASC];

        createFolderSelectList(lstFolder);
        selectedFolderId = UserInfo.getOrganizationId();
        queryTemplates();
    }

    private void createFolderSelectList(List<Folder> lstFolder)
    {
        templateFolders = new List<SelectOption>();

        /**  "Unfiled Public Email Templates" and "My Personl Email Template"
          *  are system folders that are not returned if you query Folder table.
          *  So we have to add these two folders explicitly in Folder select list.
          **/
        templateFolders.add(new SelectOption(UserInfo.getOrganizationId(), PUBLIC_EMAIL_TEMPLATES_FOLDER));
        templateFolders.add(new SelectOption(UserInfo.getUserId(), PERSONAL_EMAIL_TEMPLATES_FOLDER));

        if(!lstFolder.isEmpty())
        {
            for(Folder objFolder : lstFolder)
                templateFolders.add(new SelectOption(objFolder.Id, objFolder.Name));
        }
    }

    public void queryTemplates()
    {
        lstEmailTemplate = new List<EmailTemplate>();

    	if(selectedFolderId != null || selectedFolderId != '')
    	{
            lstEmailTemplate = [SELECT    Id, Name, TemplateType, Description
                                 FROM      EmailTemplate
                                 WHERE     FolderId = :selectedFolderId
                                 ORDER BY  Name ASC];
    	}
    }
}