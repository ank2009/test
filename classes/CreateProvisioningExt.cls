/*
* @ Description :- It inserts the provision as well as offer templates and multiple right templates.
* @ Author      :- Atos
* @ Date        :- 11/01/2012
**/

public with sharing class CreateProvisioningExt
{
    private final Subscription__c subs;
    public Provisioning__c prov;
    public Rights_Template__c rightsTpl;

    /*
     @ Description: Constructor with standard controller
    */
    public CreateProvisioningExt(ApexPages.StandardController controller) 
    {
        Id subsId = System.currentPagereference().getParameters().get('id');
        this.subs = [SELECT Id, Contract__c, Offer_Template__c, Product__c, Status__c, Contract__r.AccountId, Opportunity__r.Name FROM Subscription__c WHERE Id = :subsId];
    }
    
    /*
     @ Description: Constructor with standard controller
    */
    public CreateProvisioningExt(Id subsId) 
    {
        this.subs = [SELECT Id, Contract__c, Offer_Template__c, Product__c, Status__c, Contract__r.AccountId, Opportunity__r.Name FROM Subscription__c WHERE Id = :subsId];
    }
    
    /*
     @ Description: This is the first method which will call from the page
    */
    public void init()
    {
        if ([SELECT count() FROM Provisioning__c WHERE Subscription__c = :this.subs.Id] > 0)
        {
            Generic.StandardException ex = new Generic.StandardException();
            ex.SetMessage('Provisioning already initiated, check the corresponding related list in subscription');
            throw ex;
        }
        else
        {
            if (this.subs.Product__c == null)
            {
                Generic.StandardException ex = new Generic.StandardException();
                ex.SetMessage('Subscription error: Product field should not be empty');
                throw ex;
            }
            else if (this.subs.Offer_Template__c == null)
            {
                Generic.StandardException ex = new Generic.StandardException();
                ex.SetMessage('Subscription error: Offer Template field should not be empty');
                throw ex;
            }
            
            CreateProvAndRightsTpl(this.subs);
        }
    }
    
     /*
     @ Description: It checks the offer template is present or not.
                                 It checks the status of subscription
    */
    public PageReference initInternal()
    {
        if ([SELECT count() FROM Provisioning__c WHERE Subscription__c = :this.subs.Id] > 0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Provisioning already initiated, check the corresponding related list in subscription')); 
            return null;
        }
        else
        {
            if (this.subs.Status__c != 'Waiting For Provisioning')
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Provisioning can be started only on subscriptions under \'Waiting for Provisioning\' status')); 
                return null;
            }
            else if (this.subs.Product__c == null)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Product field should not be empty')); 
                return null;
            }
//            else if (subscription.Offer_Template__c == null)
//            {
//              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Offer Template field should not be empty')); 
//              return null;
//            }
            
            System.Savepoint sp = Database.setSavepoint();
            
            try
            {
                CreateProvAndRightsTpl(this.subs);
            }
            catch (Generic.StandardException e)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage()));
                
                Database.rollback(sp);
                
                return null;
            }
            
            return (Utilities.Redirect(this.prov.Id));
        }
    }
    
    /*
     @ Description: It inserts the Provision, Provisioning Service, Provisioning Service Attribute, Rights template, Rights template service records
    */
    
    public void CreateProvAndRightsTpl(Subscription__c subscription)
    {
        Map<Id, Id> mappingProvServ = new Map<Id, Id>();
        Map<Id, Id> mappingRTServ = new Map<Id, Id>();
        
        // Provisioning creation
        try
        {
            this.prov                   = new Provisioning__c();
            this.prov.Name             = 'Provisioning - '+subscription.Opportunity__r.Name;
            //this.prov.Name              = 'Provisioning';
            this.prov.OwnerId           = UserInfo.getUserId();
            //prov.RecordTypeId = Schema.getGlobalDescribe().get('Provisioning__c').getDescribe().getRecordTypeInfosByName().get('TLR Provisioning').getRecordTypeId();
            this.prov.Account__c        = subscription.Contract__r.AccountId;
            this.prov.Contract__c       = subscription.Contract__c;
            this.prov.Offer_Template__c = subscription.Offer_Template__c;
            this.prov.Subscription__c   = subscription.Id;
            
            insert this.prov;
        }
        catch (Exception e){
            Generic.StandardException ex = new Generic.StandardException();
            ex.SetMessage('Error: Provisioning insertion: ' + e.getMessage());
            throw ex; 
        }        
        // Provisioning Services
        ID productId = subscription.Product__c;
        List<Offer_Line_Item__c> offerLIs = [SELECT Id, Service__c, Service__r.Name, Service_Attribute_Template__c 
                                             FROM Offer_Line_Item__c 
                                             WHERE Offer_Template__c = :subscription.Offer_Template__c
                                             ORDER BY Service__r.Name ASC];
        
        List<Product_Line_Item__c> productLineItems = [SELECT Service__c FROM Product_Line_Item__c WHERE Parent__c = :productId];
        Set<ID> serviceIDs = new Set<ID>();        
        for (Product_Line_Item__c pli : productLineItems)
            serviceIDs.add(pli.Service__c);
          
        try{
            // Provisioning Services
            List<Provisioning_Service__c> lstProvServ = new List<Provisioning_Service__c>();            
            // Services first
            for (Offer_Line_Item__c offerLI : offerLIs){
                if (serviceIDs.contains(offerLI.Service__c)){
                    Provisioning_Service__c ps  = new Provisioning_Service__c();
                    ps.Name                     = offerLI.Service__r.Name;
                    //ps.RecordTypeId = Schema.getGlobalDescribe().get('Provisioning_Service__c').getDescribe().getRecordTypeInfosByName().get('TLR Provisioning Service').getRecordTypeId();
                    ps.Provisioning__c          = this.prov.Id;
                    ps.Service__c               = offerLI.Service__c;
                    
                    lstProvServ.add(ps);
                }
            }            
            //Then add-ons
            for (Offer_Line_Item__c offerLI : offerLIs){
                if (!serviceIDs.contains(offerLI.Service__c)){
                    Provisioning_Service__c ps  = new Provisioning_Service__c();
                    ps.Name                     = offerLI.Service__r.Name;
                    //ps.RecordTypeId = Schema.getGlobalDescribe().get('Provisioning_Service__c').getDescribe().getRecordTypeInfosByName().get('TLR Provisioning Service').getRecordTypeId();
                    ps.Provisioning__c          = this.prov.Id;
                    ps.Service__c               = offerLI.Service__c;
                    
                    lstProvServ.add(ps);
                }
            }
            
            if (lstProvServ.size() > 0)
                insert lstProvServ;
                
            for (Provisioning_Service__c ps : lstProvServ)
                mappingProvServ.put(ps.Service__c, ps.Id);
        }catch (Exception e){
            Generic.StandardException ex = new Generic.StandardException();
            ex.SetMessage('Error: Provisioning Service insertion: ' + e.getMessage());
            throw ex; 
        }
           
        // Provisioning Service Attributes & Rights Template Service Attributes creation
        List<Id> servAttrTempls = new List<Id>();
        for (Offer_Line_Item__c offerLI : offerLIs)
        {
            if (offerLI.Service_Attribute_Template__c != null)
                servAttrTempls.add(offerLI.Service_Attribute_Template__c);
        }
        
        List<Service_Attribute_Template_Line_Item__c> servAttrTplLIs = [SELECT Service_Attribute__c FROM Service_Attribute_Template_Line_Item__c WHERE Service_Attribute_Template__c IN :servAttrTempls];
        List<Id> servAttrs = new List<Id>();
        for (Service_Attribute_Template_Line_Item__c servAttrTplLI : servAttrTplLIs)
            servAttrs.add(servAttrTplLI.Service_Attribute__c);
        
        List<Service_Attribute__c> serviceAttributes = [SELECT Id, Name, Parent__c FROM Service_Attribute__c WHERE Id IN :servAttrs ORDER BY Name ASC];
        try
        {
            List<Provisioning_Service_Attribute__c>     lstPsa  = new List<Provisioning_Service_Attribute__c>();                
            for (Service_Attribute__c serviceAttribute : serviceAttributes){
            	
                Provisioning_Service_Attribute__c psa = new Provisioning_Service_Attribute__c();
                psa.Name                              = serviceAttribute.Name;
                psa.Provisioning_Service__c           = mappingProvServ.get(serviceAttribute.Parent__c);
                psa.Service_Attribute__c              = serviceAttribute.Id;
                
                lstPsa.add(psa);
            }            
            if (lstPsa.size() > 0)
                insert lstPsa;
        }catch (Exception e){
            Generic.StandardException ex = new Generic.StandardException();
            ex.SetMessage('Error: Provisioning Service Attributes insertion: ' + e.getMessage());
            throw ex; 
        }
        //Sart HCL ***Copy Right Template from Offer Template****
        List<Rights_Template_Default__c> listOfRTDefault = new List<Rights_Template_Default__c>(); 
        List<Rights_Template__c> listOfRT = new List<Rights_Template__c>();                
        Map<Id, Rights_Template__c> mapRTDnRT = new Map<Id, Rights_Template__c>();
        
        List<Rights_Template_Default__c> lisstOFRTD = [Select r.Status__c,r.Default__c,r.WKTS_Profiles__c, r.Private_Exchange_ID__c, r.PUG_Name__c, r.PIA_Interface__c, r.Offer_Template__c, r.Name, r.Id 
                								         From Rights_Template_Default__c r
                                  						 WHERE r.Offer_Template__c = :this.prov.Offer_Template__c];
          if(! lisstOFRTD.isEmpty()){
	         for(Rights_Template_Default__c objRTD: lisstOFRTD){
	         			Rights_Template__c objRT = new Rights_Template__c(); 
	         	    objRT.Name                   = objRTD.Name;
		            objRT.Provisioning__c        = this.prov.Id;
		            objRT.Status__c              = objRTD.Status__c;
		            objRT.Default__c             = objRTD.Default__c;
		            objRT.Private_Exchange_ID__c = objRTD.Private_Exchange_ID__c;
		            objRT.PUG_Name__c		     = objRTD.PUG_Name__c;
		            objRT.PIA_Interface__c	     = objRTD.PIA_Interface__c;
		            objRT.WKTS_Profiles__c		 = objRTD.WKTS_Profiles__c;
		            listOfRT.add(objRT);
		            listOfRTDefault.add(objRTD);
		            mapRTDnRT.put(objRTD.Id,objRT);
	        	}  
          } 	
        if(! listOfRT.isEmpty()){
         try{
         		System.debug('**listOfRT=>'+listOfRT);
        		insert listOfRT;        		
        	}catch (Exception e){
	            Generic.StandardException ex = new Generic.StandardException();
	            ex.SetMessage('Error: Default Rights Template insertion: ' + e.getMessage());
	            throw ex; 
        	}
        }
        // **********	
        List<Rights_Template_Service__c> listOfRTS = new List<Rights_Template_Service__c>(); 
        List<Rights_Template_Service_Default__c> listOfRTSDefault = new List<Rights_Template_Service_Default__c>(); 
        Map<Id, Rights_Template_Service__c> mapRTSDnRTS = new Map<Id, Rights_Template_Service__c>();
        if(! listOfRTDefault.isEmpty() && !listOfRT.isEmpty()){
	        List<Rights_Template_Service_Default__c> lisstOFRTSD = [Select r.Service__c, r.Rights_Template__c, r.Name, r.Id
	                       											 From Rights_Template_Service_Default__c r
	        	                       								 WHERE r.Rights_Template__c IN :listOfRTDefault];
	  			if(! lisstOFRTSD.isEmpty()){
	        	for(Rights_Template_Service_Default__c objRTSD : lisstOFRTSD){ 	
	         		Rights_Template_Service__c objRTS = new Rights_Template_Service__c();
	         		System.debug('**mapRTDnRT.get(objRTSD.Rights_Template__c)==='+mapRTDnRT.get(objRTSD.Rights_Template__c));   
	         	            		      objRTS.Name = objRTSD.Name;	
	         	            objRTS.Rights_Template__c = mapRTDnRT.get(objRTSD.Rights_Template__c).Id;
	         	        	        objRTS.Service__c = objRTSD.Service__c;
		         	        	 	listOfRTS.add(objRTS);
		         	        	 	listOfRTSDefault.add(objRTSD);
		         	            	mapRTSDnRTS.put(objRTSD.Id,objRTS);		 	
	        	}
	        }	        
	        if(! listOfRTS.isEmpty()){
	        	try{
	        		insert listOfRTS;
	        	}catch (Exception e){
			            Generic.StandardException ex = new Generic.StandardException();
			            ex.SetMessage('Error: Rights Template Services insertion: ' + e.getMessage());
			            throw ex; 
			    }
	        }	       
	      // *********Rights Template Service Attributes insertion**********
	       List<Rights_Template_Service_Attribute__c>  lstRTSA = new List<Rights_Template_Service_Attribute__c>();
	      
	      if(!listOfRTSDefault.isEmpty() && !listOfRTS.isEmpty()){	      	
		      List<Rights_Template_Service_Attribute_Def__c> lisstOFRTSAD = [Select r.Service_Attribute__c, r.Rights_Template_Service__c, r.Name, r.Id 
	                								 							    From Rights_Template_Service_Attribute_Def__c r
	                                  			      								WHERE r.Rights_Template_Service__c IN :listOfRTSDefault];
	          if(! lisstOFRTSAD.isEmpty()){                  			      								
	               for(Rights_Template_Service_Attribute_Def__c objRTSADeafult : lisstOFRTSAD){                   			      									
		      		Rights_Template_Service_Attribute__c objRTSA = new Rights_Template_Service_Attribute__c();
		      		   objRTSA.Name                              = objRTSADeafult.Name; 
                       objRTSA.Rights_Template_Service__c        = mapRTSDnRTS.get(objRTSADeafult.Rights_Template_Service__c).Id;
                       objRTSA.Service_Attribute__c              = objRTSADeafult.Service_Attribute__c;
                       lstRTSA.add(objRTSA);							
		         }
	          }
	       }	      
	      if(!lstRTSA.isEmpty()){
	      	try{
	      		insert lstRTSA;
	      	}catch (Exception e){
	            Generic.StandardException ex = new Generic.StandardException();
	            ex.SetMessage('Error: Rights Template Service Attributes insertion: ' + e.getMessage());
	            throw ex; 
	        }
	      }          
        }
        //End HCL
        
        try{
            this.subs.Status__c = 'Provisioning initiated';
            update this.subs;
        }catch (DmlException e){
            Generic.StandardException ex = new Generic.StandardException();
            ex.SetMessage('Insufficient Privileges: ' + e.getDmlMessage(0));
            throw ex; 
        }
    }
    
    public Provisioning__c getProv(){
        return prov;
    }
        
    public PageReference Cancel(){
        return (Utilities.Redirect(this.subs.id));
    }
}