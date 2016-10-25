global class ProvisioningReturnEsbToSf 
{
    // Received Information
    global class AWL_CRM_ESB_Provisioning_Return_Type
    {
        webservice String transactionId;
        webservice String objectId;
        webservice String objectType;
        webservice String status;
        webservice String errorMessage;
        webservice String login;
    }

	/*
		2013 somewhere
		ATOS
		refactored by Anton Solovyev at 2014-10-16
		
		main webservice method
	*/
    webservice static Boolean provisioningReturn(AWL_CRM_ESB_Provisioning_Return_Type ret) 
    {
        System.Debug('--------------- ProvisioningReturnEsbToSf: provisioningReturn: input parameter: ' + ret);

        String accountKeyPrefix = Schema.SObjectType.Account.getKeyPrefix();
        String contactKeyPrefix = Schema.SObjectType.Contact.getKeyPrefix();

        List<Provisioning_Transaction__c> pTransactions;
        if (ret.objectId.substring(0, 3) == accountKeyPrefix)
        {
            pTransactions = [SELECT Id, Status__c, Login__c, Error__c, Account__c, Subscription__c, Type__c 
                     FROM Provisioning_Transaction__c
                     WHERE TransactionId__c = :ret.transactionId 
                     AND Account__c = :ret.objectId 
                     AND Contact__c = null];
        }
        else if (ret.objectId.substring(0, 3) == contactKeyPrefix)
        {
            pTransactions = [SELECT Id, Status__c, Login__c, Error__c, Contact__c, Account__c, Subscription__c, Type__c 
                     FROM Provisioning_Transaction__c
                     WHERE TransactionId__c = :ret.transactionId 
                     AND Contact__c = :ret.objectId];
        }
        else
        {
            pTransactions = [SELECT Id, Status__c, Login__c, Error__c, Subscription__c, Type__c 
                     FROM Provisioning_Transaction__c
                     WHERE TransactionId__c = :ret.transactionId 
                     AND Subscription__c = :ret.objectId 
                     AND Account__c = null 
                     AND Contact__c = null];
        }
        
        System.Debug('--------------- ProvisioningReturnEsbToSf: provisioningReturn: Transactions: ' + pTransactions);

		// if there are actual transactions
        if (pTransactions.size() > 0)
        {
        	// if we need to update transaction information
            if (!(pTransactions[0].Status__c == 'Failed' && ret.status == 'Success'))
            {
                System.Debug('--------------- ProvisioningReturnEsbToSf: provisioningReturn: transactions status changed. updating now.');
                
                for (Provisioning_Transaction__c t : pTransactions)
                {
                    System.Debug('--------------- ProvisioningReturnEsbToSf: provisioningReturn: transaction to update: ' + t.Id);
                    t.Status__c = ret.status;
                    t.Error__c  = ret.errorMessage;
                    t.Login__c  = ret.login;
                }
                update pTransactions;
                
                List<Provisioning_Transaction__c> transPre;
                
                if (ret.objectId.substring(0, 3) == accountKeyPrefix)
                {
                    transPre = [SELECT Id, TransactionId__c 
                                FROM Provisioning_Transaction__c
                                WHERE Account__c = :ret.objectId
                                AND Status__c != 'In Progress'
                                ORDER BY TransactionId__c DESC];
                }
                else if (ret.objectId.substring(0, 3) == contactKeyPrefix)
                {
                    transPre = [SELECT Id, TransactionId__c 
                                FROM Provisioning_Transaction__c
                                WHERE Contact__c = :ret.objectId
                                AND Status__c != 'In Progress' 
                                ORDER BY TransactionId__c DESC];
                }
                else
                {
                    transPre = [SELECT Id, TransactionId__c 
                                FROM Provisioning_Transaction__c
                                WHERE Subscription__c = :ret.objectId
                                AND Status__c != 'In Progress'
                                ORDER BY TransactionId__c DESC];
                }
                //if (transPre.size() == 0 || transPre[0].TransactionId__c <= ret.transactionId)
                if (true)
                {
                    if (ret.objectId.substring(0, 3) != accountKeyPrefix && 
                        ret.objectId.substring(0, 3) != contactKeyPrefix)
                    {
                        parseSubscription(pTransactions[0], ret);
                    } // if ret.objectId is subscription
                    else if (ret.objectId.substring(0, 3) == accountKeyPrefix)
                    {
                        parseAccount(pTransactions[0], ret);
                    }
                    else
                    {
                        parseContact(pTransactions[0], ret);
                    }
                } // if true !!??
            } // if transactions needs to be updated
            return true;
        } // if pTransactions.size() > 0
        else 
            return false;
    } //webservice static Boolean provisioningReturn(AWL_CRM_ESB_Provisioning_Return_Type ret)
	
	private static void parseSubscription(Provisioning_Transaction__c trans, AWL_CRM_ESB_Provisioning_Return_Type retVal)
	{
		System.Debug('#### ProvisioningReturnEsbToSf: parseSubscription: start.');
		
		Provisioning__c prov = [
			SELECT 
				Id, Provisioning_Status__c, Provisioning_Error__c,
				(SELECT Id, Status__c, Provisioning_Error__c
					FROM User_Profiles_del__r WHERE Status__c = 'In Progress')
			FROM Provisioning__c 
			WHERE Subscription__c = :trans.Subscription__c
		];
		
		if (retVal.status != 'Success')
		{
			List<ID> idUp = new List<ID>();
			for (User_Profile__c up : prov.User_Profiles_del__r)
				idUp.add(up.Id);
			
			Map<ID, List<User_Profile_Service__c>> mapUpServ = ProvisioningMessages.getUserProfileServices(idUp);
			
			List<User_Profile_Service_Attribute__c> upsaToUpdate = new List<User_Profile_Service_Attribute__c>();
			List<User_Profile_Service__c>           upsToUpdate  = new List<User_Profile_Service__c>();
			
			for (User_Profile__c up : prov.User_Profiles_del__r)
			{
				System.Debug('#### ProvisioningReturnEsbToSf: parseSubscription: User_Profile__c ' + up + ' failed');
				
				up.Status__c             = 'Failed';
				up.Provisioning_Error__c = retVal.errorMessage;
				
				if (mapUpServ.containsKey(up.Id))
				{
					for (User_Profile_Service__c ups : mapUpServ.get(up.Id))
					{
						ups.Provisioning_Status__c = 'Failed';
						upsToUpdate.add(ups);
						
						for (User_Profile_Service_Attribute__c upsa : ups.User_Profile_Service_Attributes__r)
						{
							upsa.Provisioning_Status__c = 'Failed';
							upsaToUpdate.add(upsa);
						}
					}
				}
			} //for (User_Profile__c up : prov.User_Profiles_del__r)
			
			System.Debug('#### ProvisioningReturnEsbToSf: parseSubscription: Provisioning__c ' + prov + ' failed');
			
			prov.Provisioning_Status__c = 'Failed';
			prov.Provisioning_Error__c  = retVal.errorMessage;
			
			if (upsaToUpdate.size() > 0)
				update upsaToUpdate;
			if (upsToUpdate.size() > 0)
				update upsToUpdate;
			
			update prov.User_Profiles_del__r;
			update prov;
		}
		else // successful provisioning
		{
			System.Debug('#### ProvisioningReturnEsbToSf: parseSubscription: Successful provisioning');
			
			if (trans.Type__c != 'Cancellation')
			{
				// Provisioning update if all success and not cancellation
				Boolean allSuccess = true;
				for (Provisioning_Transaction__c tr : [
					SELECT Id, Status__c FROM Provisioning_Transaction__c
					WHERE TransactionId__c = :retVal.transactionId AND Id != :trans.Id])
				{
					if (tr.Status__c != 'Success')
					{
						System.Debug('#### ProvisioningReturnEsbToSf: parseSubscription: Not success transaction: ' + tr);
						allSuccess = false;
						break;
					}
				} // for transactions
				
				if (allSuccess)
				{
					prov.Provisioning_Status__c = 'Success';
					prov.Provisioning_Error__c  = '';
					update prov;
				}
			} //if (trans[0].Type__c != 'Cancellation')
		} // else means provisioning is successful
	} //parseSubscription
	
	private static void parseAccount(Provisioning_Transaction__c trans, AWL_CRM_ESB_Provisioning_Return_Type retVal)
	{
		System.Debug('#### Account management');
		
		if (retVal.status != 'Success' && trans.Type__c != 'Cancellation')
		{
			System.Debug('#### Not Cancellation and Failed');
			
			Provisioning__c prov = [
				SELECT 
					Id, Provisioning_Status__c, Provisioning_Error__c,
					(SELECT Id, Status__c, Provisioning_Error__c
						FROM User_Profiles_del__r
						WHERE Contact__r.AccountId = :trans.Account__c AND Status__c = 'In Progress')
				FROM Provisioning__c 
				WHERE Subscription__c = :trans.Subscription__c
			];

			List<ID> idUp = new List<ID>();
			for (User_Profile__c up : prov.User_Profiles_del__r)
				idUp.add(up.Id);
			
			Map<ID, List<User_Profile_Service__c>> mapUpServ = ProvisioningMessages.getUserProfileServices(idUp);
			
			List<User_Profile_Service_Attribute__c> upsaToUpdate = new List<User_Profile_Service_Attribute__c>();
			List<User_Profile_Service__c>           upsToUpdate  = new List<User_Profile_Service__c>();
			
			for (User_Profile__c up : prov.User_Profiles_del__r)
			{
				System.Debug('#### User_Profile__c ' + up + ' failed');
				
				up.Status__c             = 'Failed';
				up.Provisioning_Error__c = retVal.errorMessage;
				
				if (mapUpServ.containsKey(up.Id))
				{
					for (User_Profile_Service__c ups : mapUpServ.get(up.Id))
					{
						ups.Provisioning_Status__c = 'Failed';
						upsToUpdate.add(ups);
						
						for (User_Profile_Service_Attribute__c upsa : ups.User_Profile_Service_Attributes__r)
						{
							upsa.Provisioning_Status__c = 'Failed';
							upsaToUpdate.add(upsa);
						}
					}
				}
			} //for (User_Profile__c up : prov.User_Profiles_del__r)
			
			System.Debug('#### Provisioning__c ' + prov + ' failed');
			
			prov.Provisioning_Status__c = 'Failed';
			prov.Provisioning_Error__c  = retVal.errorMessage;
			
			if (upsaToUpdate.size() > 0)
				update upsaToUpdate;
			if (upsToUpdate.size() > 0)
				update upsToUpdate;
			
			update prov.User_Profiles_del__r;
			update prov;
		}
		else if (retVal.status != 'Success' && trans.Type__c == 'Cancellation')
		{
			System.Debug('#### Cancellation and Failed');
			
			Provisioning__c prov = [
				SELECT 
					Id, Provisioning_Status__c, Provisioning_Error__c,
						(SELECT Id, Status__c, Provisioning_Error__c
							FROM User_Profiles_del__r
							WHERE Status__c = 'In Progress')
				FROM Provisioning__c 
				WHERE Subscription__c = :trans.Subscription__c
			];
			
			List<ID> idUp = new List<ID>();
			for (User_Profile__c up : prov.User_Profiles_del__r)
				idUp.add(up.Id);
			
			Map<ID, List<User_Profile_Service__c>> mapUpServ = ProvisioningMessages.getUserProfileServices(idUp);
			
			List<User_Profile_Service_Attribute__c> upsaToUpdate = new List<User_Profile_Service_Attribute__c>();
			List<User_Profile_Service__c>           upsToUpdate  = new List<User_Profile_Service__c>();
			
			for (User_Profile__c up : prov.User_Profiles_del__r)
			{
				System.Debug('#### User_Profile__c ' + up + ' failed');
				
				up.Status__c             = 'Failed';
				up.Provisioning_Error__c = retVal.errorMessage;
				
				if (mapUpServ.containsKey(up.Id))
				{
					for (User_Profile_Service__c ups : mapUpServ.get(up.Id))
					{
						ups.Provisioning_Status__c = 'Failed';
						upsToUpdate.add(ups);
						
						for (User_Profile_Service_Attribute__c upsa : ups.User_Profile_Service_Attributes__r)
						{
							upsa.Provisioning_Status__c = 'Failed';
							upsaToUpdate.add(upsa);
						}
					}
				}
			} //for (User_Profile__c up : prov.User_Profiles_del__r)
			
			System.Debug('#### Provisioning__c ' + prov + ' failed');
			
			prov.Provisioning_Status__c = 'Failed';
			prov.Provisioning_Error__c  = retVal.errorMessage;
			
			if (upsaToUpdate.size() > 0)
				update upsaToUpdate;
			if (upsToUpdate.size() > 0)
				update upsToUpdate;
			
			update prov.User_Profiles_del__r;
			update prov;
        }
        else if (retVal.status == 'Success' && trans.Type__c == 'Cancellation')
        {
            System.Debug('#### Cancellation and Success');
            
            Provisioning__c prov = [SELECT Id, Provisioning_Status__c, Provisioning_Error__c,
                                   (SELECT Id, Status__c, Provisioning_Error__c
                                    FROM User_Profiles_del__r)
                                    FROM Provisioning__c WHERE Subscription__c = :trans.Subscription__c];
            
            List<ID> idUp = new List<ID>();
            for (User_Profile__c up : prov.User_Profiles_del__r)
                idUp.add(up.Id);
            
            Map<ID, List<User_Profile_Service__c>> mapUpServ = ProvisioningMessages.getUserProfileServices(idUp);
            
            List<User_Profile_Service_Attribute__c> upsaToUpdate = new List<User_Profile_Service_Attribute__c>();
            List<User_Profile_Service__c>           upsToUpdate  = new List<User_Profile_Service__c>();
            
            for (User_Profile__c up : prov.User_Profiles_del__r)
            {
                System.Debug('#### User_Profile__c ' + up + ' cancelled');
                
                up.Status__c             = 'Cancelled';
                up.Provisioning_Error__c = '';
                
                if (mapUpServ.containsKey(up.Id))
                {
                    for (User_Profile_Service__c ups : mapUpServ.get(up.Id))
                    {
                        ups.Provisioning_Status__c = 'Cancelled';
                        upsToUpdate.add(ups);
                        
                        for (User_Profile_Service_Attribute__c upsa : ups.User_Profile_Service_Attributes__r)
                        {
                            upsa.Provisioning_Status__c = 'Cancelled';
                            upsaToUpdate.add(upsa);
                        }
                    }
                }
            }
            
            System.Debug('#### Provisioning__c ' + prov + ' cancelled');
            
            prov.Provisioning_Status__c = 'Cancelled';
            prov.Provisioning_Error__c  = '';
            
            if (upsaToUpdate.size() > 0)
                update upsaToUpdate;
            if (upsToUpdate.size() > 0)
                update upsToUpdate;
                
            update prov.User_Profiles_del__r;
            update prov;
        }
        else if (retVal.status == 'Success')
        {
            System.Debug('#### Success');
            
            Provisioning__c prov = [SELECT Id, Provisioning_Status__c, Provisioning_Error__c
                                    FROM Provisioning__c WHERE Subscription__c = :trans.Subscription__c];
                                    
            // Provisioning update if all success
            Boolean allSuccess = true;
            for (Provisioning_Transaction__c tr : [SELECT Id, Status__c FROM Provisioning_Transaction__c
                                                   WHERE TransactionId__c = :retVal.transactionId
                                                   AND Id != :trans.Id])
            {
                if (tr.Status__c != 'Success')
                {
                    System.Debug('#### Not success transaction: ' + tr);
                    allSuccess = false;
                    break;
                }
            }
            
            if (allSuccess)
            {
                prov.Provisioning_Status__c = 'Success';
                prov.Provisioning_Error__c  = '';
            
                update prov;
            }
        }
	} //parseAccount
	
	private static void parseContact(Provisioning_Transaction__c pTransaction, AWL_CRM_ESB_Provisioning_Return_Type retVal)
	{
		Boolean enableDualProvisioning = General_Settings__c.getInstance('Default').ESB_Dual_provisioning_enabled__c;
		// Contact
        System.Debug('--------------- ProvisioningReturnEsbToSf: parseContact: transaction: ' + pTransaction);
        
        Provisioning__c prov = [SELECT Id, Provisioning_Status__c, Provisioning_Error__c,
                                Subscription__r.Status__c, Subscription__r.Contract__r.Status__c,
                                Subscription__r.Contract__r.Status,
                                Subscription__r.Opportunity__c,
                                Subscription__r.Opportunity__r.StageName, 
                                Subscription__r.Opportunity__r.CloseDate,
                               (SELECT Id, Contact__r.Username__c, Status__c, Provisioning_Error__c
                                FROM User_Profiles_del__r
                                WHERE Contact__r.AccountId = :pTransaction.Account__c
                                AND Contact__c = :pTransaction.Contact__c
                                AND Status__c = 'In Progress') 
                                FROM Provisioning__c WHERE Subscription__c = :pTransaction.Subscription__c];
        
        List<ID> idUp = new List<ID>();
        for (User_Profile__c up : prov.User_Profiles_del__r)
            idUp.add(up.Id);
        
        Map<ID, List<User_Profile_Service__c>> mapUpServ = ProvisioningMessages.getUserProfileServices(idUp);
        
        List<User_Profile_Service_Attribute__c> upsaToUpdate = new List<User_Profile_Service_Attribute__c>();
        List<User_Profile_Service__c>           upsToUpdate  = new List<User_Profile_Service__c>();
                                        
        if (retVal.status != 'Success')
        {
            System.Debug('#### Failed');
                                    
            for (User_Profile__c up : prov.User_Profiles_del__r)
            {
                System.Debug('#### User_Profile__c ' + up + ' failed');
                 
                up.Status__c             = 'Failed';
                up.Provisioning_Error__c = retVal.errorMessage;
                
                if (mapUpServ.containsKey(up.Id))
                {
                    for (User_Profile_Service__c ups : mapUpServ.get(up.Id))
                    {
                        ups.Provisioning_Status__c = 'Failed';
                        upsToUpdate.add(ups);
                        
                        for (User_Profile_Service_Attribute__c upsa : ups.User_Profile_Service_Attributes__r)
                        {
                            upsa.Provisioning_Status__c = 'Failed';
                            upsaToUpdate.add(upsa);
                        }
                    }
                }
            }
            
            System.Debug('#### Provisioning__c ' + prov + ' failed');
            
            prov.Provisioning_Status__c = 'Failed';
            prov.Provisioning_Error__c  = retVal.errorMessage;
            
            if (upsaToUpdate.size() > 0)
                update upsaToUpdate;
            if (upsToUpdate.size() > 0)
                update upsToUpdate;
                
            update prov.User_Profiles_del__r;
            update prov;
        }
        else
        {
            System.Debug('#### Success');
                                    
            List<Contact> cons = new List<Contact>();
            List<Contact> contactsToSendToCM = new List<Contact>();
            
            for (User_Profile__c up : prov.User_Profiles_del__r)
            {
                if (pTransaction.Type__c == 'Provisioning' || pTransaction.Type__c == 'Update')
                {
                    System.Debug('#### User_Profile__c ' + up + ' activated');
                    up.Status__c = 'Activated';
                }
                else
                {
                    System.Debug('#### User_Profile__c ' + up + ' suspended');
                    up.Status__c = 'Suspended';
                }
                
                up.Provisioning_Error__c  = '';
                
                if (retVal.login != null && retVal.login != '')
                {
                    up.Contact__r.Username__c = retVal.login;
                    cons.add(up.Contact__r);
                    // for dual provisioning
                    if (pTransaction.Type__c == 'Provisioning' || pTransaction.Type__c == 'Update')
                    	contactsToSendToCM.add(up.Contact__r);
                }
                
                if (mapUpServ.containsKey(up.Id))
                {
                    for (User_Profile_Service__c ups : mapUpServ.get(up.Id))
                    {
                        if (ups.Suspension_Start_Date__c == null || ups.Suspension_Start_Date__c > Date.Today() || ups.Suspension_End_Date__c < Date.Today())
                            ups.Provisioning_Status__c = 'Activated';
                        else
                            ups.Provisioning_Status__c = 'Suspended';
                        upsToUpdate.add(ups);
                        
                        for (User_Profile_Service_Attribute__c upsa : ups.User_Profile_Service_Attributes__r)
                        {
                            if (upsa.Suspension_Start_Date__c == null || upsa.Suspension_Start_Date__c > Date.Today() || upsa.Suspension_End_Date__c < Date.Today())
                                upsa.Provisioning_Status__c = 'Activated';
                            else
                                upsa.Provisioning_Status__c = 'Suspended';
                            upsaToUpdate.add(upsa);
                        }
                    }
                }
            }
            
            if (upsaToUpdate.size() > 0)
                update upsaToUpdate;
            if (upsToUpdate.size() > 0)
                update upsToUpdate;
            
            if (cons.size() > 0)
                update cons;
            if (prov.User_Profiles_del__r.size() > 0)
                update prov.User_Profiles_del__r;
                
            // we need to do it avter contacts are updated to avoid unneeded 'update' calls
            if(enableDualProvisioning)
	            for(Contact c : contactsToSendToCM)
	            	ESB_Proxy.CreateUser(c.Id, false);
            
            // Subscription, Contract, Opportunity
            if (pTransaction.Type__c == 'Provisioning' || pTransaction.Type__c == 'Update')
            {
                if (prov.Subscription__r.Opportunity__c != null)
                {
                    if (prov.Subscription__r.Opportunity__r.StageName == 'Contract request')
                    {
                        System.Debug('#### update Opportunity');
                        prov.Subscription__r.Opportunity__r.StageName = 'Closed Won';
                        prov.Subscription__r.Opportunity__r.CloseDate = Date.Today();
                        update prov.Subscription__r.Opportunity__r;
                    }
                }
                
                if (prov.Subscription__r.Contract__r.Status__c == 'Draft')
                {
                    System.Debug('#### update Contract');
                    prov.Subscription__r.Contract__r.Status__c = 'Active';
                    prov.Subscription__r.Contract__r.Status    = 'Activated';
                    update prov.Subscription__r.Contract__r;
                }
                
                if (prov.Subscription__r.Status__c == 'Provisioning initiated')
                {
                    System.Debug('#### update Subscription');
                    prov.Subscription__r.Status__c = 'Active';
                    update prov.Subscription__r;
                }
            }
            
            // Provisioning update if all success
            Boolean allSuccess = true;
            for (Provisioning_Transaction__c tr : [SELECT Id, Status__c FROM Provisioning_Transaction__c
                                                   WHERE TransactionId__c = :retVal.transactionId
                                                   AND Id != :pTransaction.Id])
            {
                if (tr.Status__c != 'Success')
                {
                    System.Debug('#### Not success transaction: ' + tr);
                    allSuccess = false;
                    break;
                }
            }
            
            if (allSuccess)
            {
                prov.Provisioning_Status__c = 'Success';
                prov.Provisioning_Error__c  = '';
            
                update prov;
            }
        }
	} //parseContact
} // global class ProvisioningReturnEsbToSf