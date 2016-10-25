public  class TR002ServiceAttributeTemplateLI {
public static void updateServiceAttributeParent(Service_Attribute_Template_Line_Item__c[] lstServiceAttributeTemplateLI){
	
	PAD.myLog('START TR002ServiceAttributeTemplateLI.updateServiceAttributeParent');
		
	
		 Set<ID> setIdSATLIs = new Set<ID>();
		  Set<ID> setIdSAs = new Set<ID>();
		   Set<ID> setIdSATs = new Set<ID>();
		    for (Service_Attribute_Template_Line_Item__c satli : lstServiceAttributeTemplateLI) {
            setIdSATLIs.add(satli.Id);   
            setIdSAs.add(satli.Service_Attribute__c);
            setIdSATs.add(satli.Service_Attribute_Template__c);
            	 }
		
		
		Map<ID, Service_Attribute_Template_Line_Item__c> SATLIList = new Map<ID, Service_Attribute_Template_Line_Item__c>([select Service_Attribute_Template__c,Service_Attribute__c from Service_Attribute_Template_Line_Item__c where Id in :setIdSATLIs]);
		
		Map<ID, Service_Attribute__c> ServiceAttributeList = new Map<ID, Service_Attribute__c>([select Name,Parent__c from Service_Attribute__c where Id in :setIdSAs]);
		
		Map<ID, Service_Attribute_Template__c> ServiceAttributeTemplateList = new Map<ID, Service_Attribute_Template__c>([select Name,Parent__c from Service_Attribute_Template__c where Id in :setIdSATs]);
		
		
		for(Service_Attribute_Template_Line_Item__c satliobject : SATLIList.values() ){
		
		for(Service_Attribute__c saobject : ServiceAttributeList.values() ){
		
		for(Service_Attribute_Template__c satobject : ServiceAttributeTemplateList.values() ){
		if(satliobject.Service_Attribute__c == saobject.Id && satliobject.Service_Attribute_Template__c == satobject.Id )
		
		saobject.Parent__c = satobject.Parent__c;
		}
		}
		
		}
		update ServiceAttributeList.values();
		
		/*
		Id idSAT = lstServiceAttributeTemplateLI[0].Service_Attribute_Template__c;	
		
		Id idSA = lstServiceAttributeTemplateLI[0].Service_Attribute__c;
		Service_Attribute_Template__c [] lstSAT = [Select Name,Parent__c from Service_Attribute_Template__c where id =: idSAT ];					 
	   Service_Attribute__c [] lstSA = [Select Name,Parent__c from Service_Attribute__c where id =: idSA ];					 
	   lstSA[0].Parent__c = lstSAT[0].Parent__c;
	  update	lstSA;*/
		
	PAD.myLog('END TR002ServiceAttributeTemplateLI.updateServiceAttributeParent');
	}
}