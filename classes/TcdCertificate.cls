public class TcdCertificate
{
		public String SalesforceId
		{
			get;
			set
			{
				this.SalesforceId = value;
				this.myDocuments = [
					SELECT 
						Id, ContentType, Name, 
						CreatedDate, Description
					FROM Attachment
					WHERE ParentId = :this.SalesforceId];
			}
		}
		public String CompanyId { get ;set; }
		public Integer Index { get ;set; }
		
		public List<Attachment> myDocuments;
		//Object used only to have a nice display
		//public Certificate_Structure__c certif{get;set;}
		public CertificateStructure__c certif { get ;set; }
		public Boolean AtLeastOneAttachment
		{
			get
			{
				return (this.myDocuments != null && this.myDocuments.size() > 0);
			}
		}
		
		//public CertificateManagement CertificateManager;
		
		public TcdCertificate()
		{
			certif = new CertificateStructure__c();
			//certif = new Certificate_Structure__c();
		}
		
		/*public void updateCertificate()
		{
			CertificateManager.updateCertificateId(this.Index);
		}*/
		
		/*public void deleteCertificate()
		{
			CertificateManager.deleteCertificate(this.Index);
//			return null;
		}*/
		
		/*public Pagereference uploadCertificate()
		{
			return CertificateManager.uploadCertificate(this.Index);
		}*/
	    
	    public List<Attachment> getmyDocuments()
	    {
	    	this.myDocuments = [select Id,ContentType,Name,CreatedDate,Description from Attachment where ParentId=:this.SalesforceId];
	        return this.myDocuments;
	    }
	    
		/*public Pagereference savedoc()
	    {
	        return CertificateManager.saveNewDocument();     
    	}  
    	
    	public Pagereference cancel()
	    {
	    	return CertificateManager.reloadCertificateManagement();
    	}*/
}