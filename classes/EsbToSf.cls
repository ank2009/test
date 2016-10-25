global class EsbToSf {

    // Received Information
    global class AWL_CRM_ESB_Account_Type{
        webservice String id;
        webservice String status;
    }
    global class AWL_CRM_ESB_Contact_Type{
        webservice String id;
        webservice String status;
        webservice String login;
    }
    global class AWL_CRM_ESB_Subscription_Type{
        webservice String id;
        webservice String status;
    }

    webservice static Boolean esbAddLogin(AWL_CRM_ESB_Account_Type acc, AWL_CRM_ESB_Contact_Type con, AWL_CRM_ESB_Subscription_Type sub) {
        //System.Debug('webservice esbAddLogin called');
        if ((acc.status != 'OK') || (con.status != 'OK') || (sub.status != 'OK'))
        {
            try
            {
                Contact myContact = [SELECT Id, Username__c FROM Contact WHERE id = :con.id];
                myContact.Username__c = 'Error During Provisioning';
                update myContact;
            }
            catch (Exception e)
            {
            }
            
            return false;
        }
        
        try
        {
            Contact myContact = [SELECT Id, Username__c FROM Contact WHERE id = :con.id];
            myContact.Username__c = con.login;
            update myContact;
            
            return true;
        }
        catch (Exception e)
        {
            return false;
        }
    }
    
    static testMethod void testWS(){
        AWL_CRM_ESB_Account_Type accObj = new AWL_CRM_ESB_Account_Type();
        accObj.id = '';
        accObj.status = 'OK';
        
        AWL_CRM_ESB_Contact_Type conObj = new AWL_CRM_ESB_Contact_Type();
        conObj.id = '';
        conObj.status = 'OK';
        conObj.login = '';
        
        AWL_CRM_ESB_Subscription_Type subObj = new AWL_CRM_ESB_Subscription_Type();
        subObj.id = '';
        subObj.status = 'OK';
    
        // Test for response 'true'
        Contact testContact = new Contact(LastName = 'Penne', Username__c = 'TestUN', Key_contact_or_decision_maker__c=true, Language__c = utilities.getPicklistValues('Contact', 'Language__c')[0]);
        insert testContact;
        
        conObj.id = testContact.Id;
        conObj.login = 'NouveauUN';
        Boolean ret = esbAddLogin(accObj, conObj, subObj);
        
        System.assertEquals(true, ret);
        
        Contact updatedContact = [SELECT Id, Username__c FROM Contact WHERE id = :testContact.Id];
        System.assertEquals('NouveauUN', updatedContact.Username__c);
        
        // Test for response 'false' 1
        conObj.id = 'toto';
        ret = esbAddLogin(accObj, conObj, subObj);
        
        System.assertEquals(false, ret);
        
        // Test for response 'false' 2
        accObj.status = 'ERROR';
        conObj.id = testContact.Id;
        ret = esbAddLogin(accObj, conObj, subObj);
        
        System.assertEquals(false, ret);
    }   
}