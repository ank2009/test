/*
* @ Description :- This class is used to communicate with SFDC and ESB.
* @ Author      :- Atos
* @ Date        :- 11/01/2012
**/

public class ProvisioningMessages
{ 
    // Wrapper for request output
    public class RequestPreparationResult
    {
        public LibWKTSComCrmProvisioningV2.CRMProvisionningObjectsTypev2 req;
        public Boolean status;
        public String error;
    } 
    
    public class ProvisioningResult
    { 
        public Boolean status;
        public String IAM_LOGIN;
        public String error;
        public List<Provisioning_Transaction__c> transactions;
        
        public ProvisioningResult()
        {
            status    = false;
            IAM_LOGIN = '';
            error     = ''; 
        }
    }
    
    /* @Description : Fetches User Profile Service present on given user profile Id.
    */
    public static Map<ID, List<User_Profile_Service__c>> getUserProfileServices(List<Id> idUp)
    {
        Map<ID, List<User_Profile_Service__c>> mapUpServ = new Map<ID, List<User_Profile_Service__c>>();
        List<User_Profile_Service__c> uProvServ = [SELECT Id, Provisioning_Status__c, User_Profile__c,
                                                   Suspension_Start_Date__c, Suspension_End_Date__c,
                                                  (SELECT Id, Provisioning_Status__c,
                                                   Suspension_Start_Date__c, Suspension_End_Date__c
                                                   FROM User_Profile_Service_Attributes__r)
                                                   FROM User_Profile_Service__c
                                                   WHERE User_Profile__c IN :idUp];

        for (User_Profile_Service__c ups : uProvServ)
        {
            if (!mapUpServ.containsKey(ups.User_Profile__c))
                mapUpServ.put(ups.User_Profile__c, new List<User_Profile_Service__c>());
            
            mapUpServ.get(ups.User_Profile__c).add(ups);
        }
        
        return mapUpServ;
    }
    
    /* @Description : It update the provisioning status after getting response from ESB.
    */
    private static void reportStatusOnProvisioning(Provisioning__c prov, ProvisioningResult out, boolean needInsert)
    {
        if (out.status)
        {
            prov.Provisioning_Status__c = 'In Progress';
            prov.Provisioning_Error__c = '';
        }
        else
        {
            prov.Provisioning_Status__c = 'Failed';
            prov.Manual_Status__c = 'In Progress';
            prov.Provisioning_Error__c = out.error;
        }
        if(needInsert)
        {
        	update prov;
        }
    }
    
    public static String generateTransactionId(ID provId)
    {
        String transactionId = DateTime.Now().format('yyyyMMddHHmmssSSS') + ' ' + provId + UserInfo.getUserId();
        
        return transactionId;
    }
    
    /* @Description : validates the start date and end date with todays date
    */
    private static List<ID> getNotSuspended(Map<ID, User_Profile__c> mapUP)
    {
        List<ID> idUp = new List<ID>();
        idUp.addAll(mapUP.keySet());
        for (Integer ind = 0; ind < idUp.size(); ind++)
        {
            if (mapUP.get(idUp[ind]).Suspension_Start_Date__c != null && mapUP.get(idUp[ind]).Suspension_Start_Date__c <= Date.Today() &&
               (mapUP.get(idUp[ind]).Suspension_End_Date__c == null || mapUP.get(idUp[ind]).Suspension_End_Date__c >= Date.Today()))
            {  
                idUp.remove(ind);
                ind--;
            }
        }
        
        return idUp;
    }   
    
    /* @Description : Method updates the status of UP, UPS, UPSA after getting response from ESB by user profile Id.
    */
    private static void handleReturnForUserProfilesById(ProvisioningResult out, List<ID> idUp, Map<ID, User_Profile__c> mapUP, Map<ID, List<User_Profile_Service__c>> mapUpServ)
    {
        List<User_Profile_Service_Attribute__c> upsaToUpdate = new List<User_Profile_Service_Attribute__c>();
        List<User_Profile_Service__c>           upsToUpdate  = new List<User_Profile_Service__c>();
        
        if (!out.status)
        {
            for (Integer i = 0; i < idUp.size(); i++)
            {
                mapUP.get(idUp[i]).Status__c = 'Failed';
                if (out.error.length() > 252)
                    mapUP.get(idUp[i]).Provisioning_Error__c = out.error.substring(0, 252) + '...';
                else
                    mapUP.get(idUp[i]).Provisioning_Error__c = out.error;
                
                if (mapUpServ.containsKey(idUp[i]))
                {
                    for (User_Profile_Service__c ups : mapUpServ.get(idUp[i]))
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
        }
        else
        {
            for (Integer i = 0; i < idUp.size(); i++)
            {
                mapUP.get(idUp[i]).Status__c = 'In Progress';
                mapUP.get(idUp[i]).Provisioning_Error__c = '';
                
                if (mapUpServ.containsKey(idUp[i]))
                {
                    for (User_Profile_Service__c ups : mapUpServ.get(idUp[i]))
                    {
                        ups.Provisioning_Status__c = 'In Progress';
                        upsToUpdate.add(ups);
                        
                        for (User_Profile_Service_Attribute__c upsa : ups.User_Profile_Service_Attributes__r)
                        {
                            upsa.Provisioning_Status__c = 'In Progress';
                            upsaToUpdate.add(upsa);
                        }
                    }
                }
            }
            
            insert out.transactions;
        }
        System.debug('***upsaToUpdate.size()--->'+upsaToUpdate.size());
        System.debug('***upsToUpdate.size()--->'+upsToUpdate.size());
        if (upsaToUpdate.size() > 0)
            update upsaToUpdate;
        if (upsToUpdate.size() > 0)
            update upsToUpdate;
            
        update mapUP.values();
    } 
    
    /* @Description : Method updates the status of UP, UPS, UPSA after getting response from ESB by user profile.
    */
    private static void handleReturnForUserProfilesByUser(ProvisioningResult out, List<User_Profile__c> users, Map<ID, List<User_Profile_Service__c>> mapUpServ)
    {
        List<User_Profile_Service_Attribute__c> upsaToUpdate = new List<User_Profile_Service_Attribute__c>();
        List<User_Profile_Service__c>           upsToUpdate  = new List<User_Profile_Service__c>();
                
        if (!out.status)
        {
            for (User_Profile__c user : users)
            {
                user.Status__c = 'Failed';
                if (out.error.length() > 252)
                    user.Provisioning_Error__c = out.error.substring(0, 252) + '...';
                else
                    user.Provisioning_Error__c = out.error;
                
                if (mapUpServ.containsKey(user.Id))
                {
                    for (User_Profile_Service__c ups : mapUpServ.get(user.Id))
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
        }
        else
        {
            for (User_Profile__c user : users)
            {
                user.Status__c = 'In Progress';
                user.Provisioning_Error__c = '';
                
                if (mapUpServ.containsKey(user.Id))
                {
                    for (User_Profile_Service__c ups : mapUpServ.get(user.Id))
                    {
                        ups.Provisioning_Status__c = 'In Progress';
                        upsToUpdate.add(ups);
                        
                        for (User_Profile_Service_Attribute__c upsa : ups.User_Profile_Service_Attributes__r)
                        {
                            upsa.Provisioning_Status__c = 'In Progress';
                            upsaToUpdate.add(upsa);
                        }
                    }
                }
            }
            
            insert out.transactions;
        }
        
        if (upsaToUpdate.size() > 0)
            update upsaToUpdate;
        if (upsToUpdate.size() > 0)
            update upsToUpdate;
                    
        update users;
    }
    
    /* @Description : This method updates the user profile by getting user profile Id.
    */       
    private static void prepareReturnForUserProfilesById(ID subId,
                                                        ProvisioningResult out, 
                                                        Map<ID, List<ID>> mapSubUP, 
                                                        Map<ID, User_Profile__c> mapUP, 
                                                        Map<ID, List<User_Profile_Service__c>> mapUpServ, 
                                                        List<User_Profile_Service__c> upsToUpdate, 
                                                        List<User_Profile_Service_Attribute__c> upsaToUpdate, 
                                                        List<Provisioning_Transaction__c> lstTrans)
    {
        if (!out.status)
        {
            for (Integer i = 0; i < mapSubUP.get(subId).size(); i++)
            {
                System.Debug('## Return user: ' + i + ' id: ' + mapSubUP.get(subId)[i]);
                System.Debug('## Failed');
                mapUp.get(mapSubUP.get(subId)[i]).Status__c = 'Failed';
                if (out.error.length() > 252)
                    mapUp.get(mapSubUP.get(subId)[i]).Provisioning_Error__c = out.error.substring(0, 252) + '...';
                else
                    mapUp.get(mapSubUP.get(subId)[i]).Provisioning_Error__c = out.error;
                
                if (mapUpServ.containsKey(mapSubUP.get(subId)[i]))
                {
                    for (User_Profile_Service__c ups : mapUpServ.get(mapSubUP.get(subId)[i]))
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
        }
        else
        {
            for (Integer i = 0; i < mapSubUP.get(subId).size(); i++)
            {
                System.Debug('## Return user: ' + i + ' id: ' + mapSubUP.get(subId)[i]);
                System.Debug('## OK');
                mapUp.get(mapSubUP.get(subId)[i]).Status__c = 'In Progress';
                mapUp.get(mapSubUP.get(subId)[i]).Provisioning_Error__c = '';
                
                if (mapUpServ.containsKey(mapSubUP.get(subId)[i]))
                {
                    for (User_Profile_Service__c ups : mapUpServ.get(mapSubUP.get(subId)[i]))
                    {
                        ups.Provisioning_Status__c = 'In Progress';
                        upsToUpdate.add(ups);
                        
                        for (User_Profile_Service_Attribute__c upsa : ups.User_Profile_Service_Attributes__r)
                        {
                            upsa.Provisioning_Status__c = 'In Progress';
                            upsaToUpdate.add(upsa);
                        }
                    }
                }
            }
            
            lstTrans.addAll(out.transactions);
        }
    }
    
    /* @Description : This method called for first time provisioning.
    */ 
    public static void SendInitialProvisioningRequests(List<Id> userProfileIds)
    {
        Map<ID, User_Profile__c> mapUP = new Map<ID, User_Profile__c>([SELECT Id, Contact__c, Contact__r.Username__c, Status__c, Provisioning__c, Provisioning_Error__c, Suspension_Start_Date__c, Suspension_End_Date__c FROM User_Profile__c WHERE Id IN :userProfileIds]);
        Provisioning__c prov = [SELECT Id, Provisioning_Status__c, Provisioning_Error__c, Subscription__c FROM Provisioning__c WHERE Id = :mapUP.get(userProfileIds[0]).Provisioning__c];
        Provisioning__c provLT = [SELECT LastTransaction__c FROM Provisioning__c WHERE Id = :prov.Id];
        
        List<ID> idUp = getNotSuspended(mapUP); 
        
        if (idUp.size() > 0)
        {
            Map<ID, List<User_Profile_Service__c>> mapUpServ = getUserProfileServices(idUp);
                                                               
            System.Debug('## Start Callout - Timestamp:' + DateTime.now().format('HH:mm:ss:SSS'));
            ProvisioningResult out = Provision(idUp, 'Provision');
            System.Debug('## End Callout - Output:' + out + ' - Timestamp:' + DateTime.now().format('HH:mm:ss:SSS'));
            
            // Store last transaction
            provLT.LastTransaction__c = 'Provisioning';
            for (ID id : userProfileIds)
                provLT.LastTransaction__c += ';' + id;
            update provLT;
            
            // Return for user profiles
            handleReturnForUserProfilesById(out, idUp, mapUP, mapUpServ);
            
            // Provisioning outcome
            reportStatusOnProvisioning(prov, out, true);
        }
    }
        
    /* @Description : This method called from the reprovisioning functionality and update the lat provisioning trasaction after getting the response.
    */ 
    public static void SendReProvisioning(List<Id> userProfileIds)
    {
        System.Debug('## Reprovisioning List: ' + userProfileIds);
        
        if (userProfileIds.size() > 0)
        {
            Map<ID, User_Profile__c> mapUP = new Map<ID, User_Profile__c>([SELECT Id, Contact__c, Contact__r.Username__c, Contact__r.LastName, Status__c, Provisioning__c, Provisioning_Error__c, Suspension_Start_Date__c, Suspension_End_Date__c FROM User_Profile__c WHERE Id IN :userProfileIds]);
            System.Debug('mapUP************' + mapUP);
            System.Debug('mapUP.get(userProfileIds[0]).Provisioning__c************' + mapUP.get(userProfileIds[0]).Provisioning__c);
            Provisioning__c prov = [SELECT Id, Provisioning_Status__c, Subscription__c, Provisioning_Error__c FROM Provisioning__c WHERE Id = :mapUP.get(userProfileIds[0]).Provisioning__c];
            System.Debug('prov************' + prov);
            Provisioning__c provLT = [SELECT LastTransaction__c FROM Provisioning__c WHERE Id = :prov.Id];//No need this SOQL
                                  
            List<ID> idUp = getNotSuspended(mapUP); //checks if suspention start/end date come between today's
            System.Debug('idUp************' + idUp);
            if (idUp.size() > 0)
            {
                Map<ID, List<User_Profile_Service__c>> mapUpServ = getUserProfileServices(idUp);//Get map of (Id and UPS) 
                System.Debug('mapUpServ************' + mapUpServ);
                ProvisioningResult out = Provision(idUp, 'Update');
    
                // Store last transaction
                provLT.LastTransaction__c = 'Update';
                for (ID id : userProfileIds)
                    provLT.LastTransaction__c += ';' + id;
                update provLT;
                
                // Return for user profiles
                handleReturnForUserProfilesById(out, idUp, mapUP, mapUpServ);
                
                // Provisioning outcome
                reportStatusOnProvisioning(prov, out, true);
            }
        }
    }
    
    /* @Description : This method called for cancel the subscription.
    */ 
    public static void CancelSubscription(Id subId, Date cancelDate)
    {
        Provisioning__c prov        = [SELECT Id, Provisioning_Status__c, Provisioning_Error__c FROM Provisioning__c WHERE Subscription__c = :subId];
        List<User_Profile__c> users = [SELECT Id, Status__c, Provisioning_Error__c FROM User_Profile__c WHERE Provisioning__c = :prov.Id];
        Provisioning__c provLT      = [SELECT LastTransaction__c FROM Provisioning__c WHERE Id = :prov.Id];
        
        List<ID> idUp = new List<ID>();
        for (User_Profile__c user : users)
            idUp.add(user.Id);
            
        Map<ID, List<User_Profile_Service__c>> mapUpServ = getUserProfileServices(idUp);
        
        ProvisioningResult out = Deprovision(subId, cancelDate);

        // Store last transaction
        provLT.LastTransaction__c = 'Cancellation;' + subId + ';' + cancelDate;
        update provLT;
                
        // Return for user profiles
        handleReturnForUserProfilesByUser(out, users, mapUpServ);        
        
        // Provisioning outcome
        reportStatusOnProvisioning(prov, out, true);
    }
        /**
    * @author HCL
    * @date 29/05/2013
    * @description : Method perform Cancel Subscription operation
    */
    public static void CancelSubscriptionMassProvisioning(Id subId, Date cancelDate,List<ID> idUp)
    {
        Provisioning__c prov        = [SELECT Id, Provisioning_Status__c, Provisioning_Error__c FROM Provisioning__c WHERE Subscription__c = :subId];
        List<User_Profile__c> users = [SELECT Id, Status__c, Provisioning_Error__c FROM User_Profile__c WHERE Id IN: idUp];
        Provisioning__c provLT      = [SELECT LastTransaction__c FROM Provisioning__c WHERE Subscription__c = :subId];
        
       if(!idUp.isEmpty()){          
            Map<ID, List<User_Profile_Service__c>> mapUpServ = getUserProfileServices(idUp);
            
            ProvisioningResult out = Deprovision(subId, cancelDate);
    
            // Store last transaction
            provLT.LastTransaction__c = 'Cancellation;' + subId + ';' + cancelDate;
            update provLT;
                    
            // Return for user profiles
            handleReturnForUserProfilesByUser(out, users, mapUpServ);        
            
            // Provisioning outcome
            reportStatusOnProvisioning(prov, out, true);
       }
    }
    
    /* @Description : This method called from the suspend functionality.
    */ 
    public static void SuspendUsersInSubscription(Map<ID, List<ID>> mapSubUP, String operation)
    {
        System.debug('***mapSubUP==>'+mapSubUP);
        System.debug('***mapSubUP.size()==>'+mapSubUP.size());  
        System.debug('***mapSubUP.keySet()==>'+mapSubUP.keySet());  
        if (mapSubUP.keySet().size() > 0)
        {
            List<ID> setIdUp   = new List<ID>();
            Set<ID> setIdProv  = new Set<ID>();
            
            for (List<ID> lst : mapSubUP.values())
                setIdUp.addAll(lst);
                
            Map<ID, User_Profile__c> mapUP = new Map<ID, User_Profile__c>([SELECT Id, Contact__c, 
                                                                                  Contact__r.LastName, 
                                                                                  Status__c, 
                                                                                  Provisioning__c, 
                                                                                  Provisioning_Error__c
                                                                           FROM User_Profile__c 
                                                                           WHERE Id IN :setIdUp]);
            
            for (List<ID> lst : mapSubUP.values())
                setIdProv.add(mapUP.get(lst[0]).Provisioning__c);
                                                                               
            Map<ID, Provisioning__c> provs = new Map<ID, Provisioning__c>([SELECT Id, 
                                                                                  Provisioning_Status__c, 
                                                                                  Provisioning_Error__c 
                                                                           FROM Provisioning__c 
                                                                           WHERE Id IN :setIdProv]);
                                                                           
            Map<ID, Provisioning__c> provLTs = new Map<ID, Provisioning__c>([SELECT LastTransaction__c 
                                                                             FROM Provisioning__c 
                                                                             WHERE Id IN :setIdProv]);
                                                                           
            List<Provisioning_Transaction__c> lstTrans = new List<Provisioning_Transaction__c>();
            
            Map<ID, List<User_Profile_Service__c>> mapUpServ = getUserProfileServices(setIdUp);
        
            List<User_Profile_Service_Attribute__c> upsaToUpdate = new List<User_Profile_Service_Attribute__c>();
            List<User_Profile_Service__c>           upsToUpdate  = new List<User_Profile_Service__c>();
            System.Debug('##operation= mapSubUP.keySet() => ' + mapSubUP.keySet() );
            for (ID subId : mapSubUP.keySet())
            {
                System.Debug('##operation= subId => ' + subId );
                if(subId != null ){
                    
                    System.Debug('## ' + operation + ' Request - Subscription: ' + subId + ' Users: ' + mapSubUP.get(subId));
                    
                    ProvisioningResult out = Provision(mapSubUP.get(subId), operation);
                    System.Debug('##operation=after service=> ' + operation );
                    // Store last transaction
                    if (operation == 'SuspendAll')
                        provLTs.get(mapUP.get(mapSubUP.get(subId)[0]).Provisioning__c).LastTransaction__c = 'Suspension;' + subId;
                    else
                        provLTs.get(mapUP.get(mapSubUP.get(subId)[0]).Provisioning__c).LastTransaction__c = 'ServSusp;' + subId;
                        
                    for (ID id : mapSubUP.get(subId))
                        provLTs.get(mapUP.get(mapSubUP.get(subId)[0]).Provisioning__c).LastTransaction__c += ';' + id;
                    
                    // Return for user profiles
                    prepareReturnForUserProfilesById(subId, out, mapSubUP, mapUP, mapUpServ, upsToUpdate, upsaToUpdate, lstTrans);
                    
                    // Provisioning outcome
                    reportStatusOnProvisioning(provs.get(mapUP.get(mapSubUP.get(subId)[0]).Provisioning__c), out, false);
                    
                    System.Debug('## End ' + operation + ' Request');
                }
            }
            
            if (upsaToUpdate.size() > 0)
                update upsaToUpdate;
            if (upsToUpdate.size() > 0)
                update upsToUpdate;
            
            update provLTs.values();
            
            update mapUP.values();
            update provs.values();
            
            if (lstTrans.size() > 0)
                insert lstTrans;
        }
    }
    
    /* @Description : This method called from the unsuspend functionality.
    */ 
    public static void UnsuspendUsersInSubscription(Map<ID, List<Id>> mapSubUP)
    {
        if (mapSubUP.keySet().size() > 0)
        {
            List<ID> setIdUp   = new List<ID>();
            Set<ID> setIdProv  = new Set<ID>();
            
            for (List<ID> lst : mapSubUP.values())
                for (ID id : lst)
                    setIdUp.add(id);
            
            Map<ID, User_Profile__c> mapUP = new Map<ID, User_Profile__c>([SELECT Id, Contact__c, Contact__r.LastName, Status__c, Provisioning__c, Provisioning_Error__c
                                                                           FROM User_Profile__c WHERE Id IN :setIdUp]);

            for (List<ID> lst : mapSubUP.values())
                setIdProv.add(mapUP.get(lst[0]).Provisioning__c);
                
            Map<ID, Provisioning__c> provs   = new Map<ID, Provisioning__c>([SELECT Id, Provisioning_Status__c, Provisioning_Error__c FROM Provisioning__c WHERE Id IN :setIdProv]);
            Map<ID, Provisioning__c> provLTs = new Map<ID, Provisioning__c>([SELECT LastTransaction__c 
                                                                             FROM Provisioning__c 
                                                                             WHERE Id IN :setIdProv]);
                                                                             
            List<Provisioning_Transaction__c> lstTrans = new List<Provisioning_Transaction__c>();
            
            Map<ID, List<User_Profile_Service__c>> mapUpServ = getUserProfileServices(setIdUp);
        
            List<User_Profile_Service_Attribute__c> upsaToUpdate = new List<User_Profile_Service_Attribute__c>();
            List<User_Profile_Service__c>           upsToUpdate  = new List<User_Profile_Service__c>();
            
            for (ID subId : mapSubUP.keySet())
            {
                System.Debug('## Unsuspension Request - Subscription: ' + subId + ' Users: ' + mapSubUP.get(subId));
                
                ProvisioningResult out = Provision(mapSubUP.get(subId), 'Standard');

                // Store last transaction
                provLTs.get(mapUP.get(mapSubUP.get(subId)[0]).Provisioning__c).LastTransaction__c = 'Unsuspension;' + subId;
                for (ID id : mapSubUP.get(subId))
                    provLTs.get(mapUP.get(mapSubUP.get(subId)[0]).Provisioning__c).LastTransaction__c += ';' + id;
                    
                // Return for user profiles
                prepareReturnForUserProfilesById(subId, out, mapSubUP, mapUP, mapUpServ, upsToUpdate, upsaToUpdate, lstTrans);
                
                // Provisioning outcome
                reportStatusOnProvisioning(provs.get(mapUP.get(mapSubUP.get(subId)[0]).Provisioning__c), out,false);
                
                System.Debug('## End Unsuspension Request');
            }
            
            if (upsaToUpdate.size() > 0)
                update upsaToUpdate;
            if (upsToUpdate.size() > 0)
                update upsToUpdate;
            
            update provLTs.values();
            
            update mapUP.values();
            update provs.values();
            
            if (lstTrans.size() > 0)
                insert lstTrans;
        }
    }
    
    /* @Description : This is webservice method to prepare request with the help of user proile Id and operation.
    */ 
    private static ProvisioningResult Provision(List<Id> lstUpIds, String operation)
    {
        System.Debug('## Start request Preparation - Timestamp:' + DateTime.now().format('HH:mm:ss:SSS'));
        RequestPreparationResult res = prepareRequest(lstUpIds, operation);
        System.Debug('## End request Preparation - Timestamp:' + DateTime.now().format('HH:mm:ss:SSS'));
        
        ProvisioningResult out = callWSAndRespond(res, operation);
        
        return out;
    }
    
    /* @Description : This is webservice method to prepare request with the help of user proile Id and operation for deprovisioning.
    */ 
    private static ProvisioningResult Deprovision(ID subId, Date cancelDate)
    {   
        System.Debug('## Start request Preparation - Timestamp:' + DateTime.now().format('HH:mm:ss:SSS'));
        RequestPreparationResult res = prepareRequestAccountAndSub(subId, cancelDate, true);
        System.Debug('## End request Preparation - Timestamp:' + DateTime.now().format('HH:mm:ss:SSS'));
        
        ProvisioningResult out = callWSAndRespond(res, '');
        
        return out;
    }
    
    /* @Description : This method update the account after getting response from ESB.
    */ 
    public static ProvisioningResult UpdateAccount(ID subsId)
    {   
        System.Debug('## Start request Preparation - Timestamp:' + DateTime.now().format('HH:mm:ss:SSS'));
        RequestPreparationResult res = prepareRequestAccountAndSub(subsId, Date.Today(), false);
        System.Debug('## End request Preparation - Timestamp:' + DateTime.now().format('HH:mm:ss:SSS'));
        
        ProvisioningResult out = callWSAndRespond(res, '');
        
        return out;
    }
    
    /* @Description : This method update the contact after getting response from ESB.
    */ 
    public static ProvisioningResult UpdateContact(List <Id> UpIds)
    {   
        System.Debug('## Start request Preparation - Timestamp:' + DateTime.now().format('HH:mm:ss:SSS'));
        RequestPreparationResult res = prepareRequest(UpIds, 'Update');
        System.Debug('## End request Preparation - Timestamp:' + DateTime.now().format('HH:mm:ss:SSS'));
        
        ProvisioningResult out = callWSAndRespond(res, '');
        
        return out;
    }
    
    /* @Description : This method prepares WS request and get response from WSB.
    */ 
    private static ProvisioningResult callWSAndRespond(RequestPreparationResult res, String operation)
    {
    	
        ProvisioningResult out = new ProvisioningResult();
        
        if (res.status)
        {
            System.Debug('## Start create WS - Timestamp:' + DateTime.now().format('HH:mm:ss:SSS'));
            LibSFDCToESBV2.SFToESBv2Export2_SFToESBv2HttpPort ws = createWS();
            System.Debug('## End create WS - Timestamp:' + DateTime.now().format('HH:mm:ss:SSS'));
            
            System.Debug('## Start callout - Timestamp:' + DateTime.now().format('HH:mm:ss:SSS'));
            LibWKTSComCrmProvisioningV2.CRMProvisionningResponseTypev2 ret = callWS(ws, res.req);
            System.Debug('## End callout - Timestamp:' + DateTime.now().format('HH:mm:ss:SSS'));
            
            System.Debug('## Start response management - Timestamp:' + DateTime.now().format('HH:mm:ss:SSS'));
            handleResponse(ret, out, res.req, operation);
            System.Debug('## End response management - Timestamp:' + DateTime.now().format('HH:mm:ss:SSS'));
        }
        else
        {
            out.status = res.status;
            out.error  = res.error;
        }
        
        return out;
    }
    
    /* @Description : This method prepares the request for ESB.
    */ 
    private static RequestPreparationResult prepareRequest(List<Id> lstUpIds, String operation)
    {
        System.Debug('############ operation = ' + operation);
        System.Debug('############ lstUpIds = ' + lstUpIds);
        
        RequestPreparationResult output = new RequestPreparationResult();
                
        //Current date
        Time midnight         = Time.newInstance(0, 0, 0, 0);
        Time midnightMinusOne = Time.newInstance(23, 59, 59, 0);
        Datetime dateAndTime  = Datetime.now();
        Date     dateNow      = Date.Today();
        String StrDateAndTime = dateAndTime.format('MM/dd/yyyy HH:mm:ss');
        
        // Database query for information
        User_Profile__c firstUserProfile = [SELECT Provisioning__c, 
                                                   Provisioning__r.Subscription__c 
                                            FROM User_Profile__c 
                                            WHERE Id = :lstUpIds[0]];
        System.debug('firstUserProfile***ONLYFOR_1_RECORD****'+firstUserProfile);                                    
        ID provID = firstUserProfile.Provisioning__c; 
        ID subID  = firstUserProfile.Provisioning__r.Subscription__c;
        Subscription__c sub = [SELECT Start_Date__c, End_Date__c, Access_Kind__c, Product__r.Access_Roles__c, Product__r.IAM_Target__c,
                               Name, Contract__r.AccountId FROM Subscription__c WHERE Id = :subID];
        System.debug('sub**ONLYFOR_1_RECORD****'+sub);
        User_Profile__c[] userProfiles = [SELECT Tivios_Role__c, FX_Login__c, FX_Acces_Kind__c, Id, Private_Exchange_ID__c,
                                          Suspension_Start_Date__c, Suspension_End_Date__c, Contact__r.Gender__c,
                                          Contact__r.Job_Title__c, Contact__r.Salutation, Contact__r.Phone, 
                                          Contact__r.Name, Contact__r.MobilePhone, Contact__r.MailingStreet, 
                                          Contact__r.MailingState, Contact__r.MailingPostalCode, Contact__r.AccountId,
                                          Contact__r.Account.BillingCountry, PIA_Interface__c, 
                                          Contact__r.MailingCountry, Contact__r.MailingCity, Contact__r.LastName, 
                                          Contact__r.Language__c, Contact__c, Contact__r.FirstName, Contact__r.Fax, 
                                          Contact__r.Email, Contact__r.Description, Contact__r.CreatedById, Test_login__c,
                                          Contact__r.Job_Profile__c, Contact__r.Is_Visible__c, User_PUG_Name__c
                                          FROM User_Profile__c WHERE Id IN :lstUpIds];
        System.debug('userProfiles.size()********'+userProfiles.size());
        // Map id user profile --> list of services / attributes
        List<User_Profile_Service__c> upServices = [SELECT Provisioning_Service__r.Service__r.Access_Roles__c, Suspension_Start_Date__c, Suspension_End_Date__c, User_Profile__c,
                                                   (SELECT Provisioning_Service_Attribute__r.Service_Attribute__r.Access_Role__c, Suspension_Start_Date__c, Suspension_End_Date__c
                                                    FROM User_Profile_Service_Attributes__r)
                                                    FROM User_Profile_Service__c 
                                                    WHERE User_Profile__c IN :lstUpIds];
        System.debug('upServices.size()****1****'+upServices.size());
        Map<ID, List<User_Profile_Service__c>> mapIdUpServ = new Map<ID, List<User_Profile_Service__c>>();
        
        for (User_Profile_Service__c ups : upServices)
        {
            if (mapIdUpServ.get(ups.User_Profile__c) == null)
                mapIdUpServ.put(ups.User_Profile__c, new List<User_Profile_Service__c>());
                
            mapIdUpServ.get(ups.User_Profile__c).add(ups);
        }
        System.debug('mapIdUpServ.size()****2****'+mapIdUpServ.size());
        System.debug('mapIdUpServ*********'+mapIdUpServ);
        Set<ID> accountIds = new Set<ID>();
        accountIds.add(sub.Contract__r.AccountId);
        System.debug('accountIds****1*****'+accountIds);
        Boolean contactsAtSubLevel = false;
        for (User_Profile__c up : userProfiles)
        {
            accountIds.add(up.Contact__r.AccountId);
            
            if (up.Contact__r.AccountId == sub.Contract__r.AccountId)
                contactsAtSubLevel = true;
        }
        System.debug('accountIds****2*****'+accountIds);
        Map<ID, Account> accounts = new Map<ID, Account>([SELECT Website, VAT__c, Phone, ParentId, Name, Id, 
                                       Fax, Deactivation_Date__c, BillingStreet, BillingState, BillingPostalCode, 
                                       BillingCountry, BillingCity, Activation_Date__c, Account_Level__c,
                                       About_Specialization__c, BIC_Code__c, AccountNumber, Level_of_Certification__c,
                                       Company_Creation_Date__c, Completion_Level__c, CurrencyIsoCode,
                                       Customer_Since__c, Total_employees__c, Iban_Number__c, ISO_Certification__c,
                                       Company_Registration_Number__c, Teleroute_Number__c, Number_of_trucks_owned__c,
                                       LastModifiedDate, Teleroute_Name__c, TCD_Visibility__c
                                       FROM Account WHERE Id IN :accountIds]);
        System.debug('accounts****1*****'+accounts);                              
        Account accSub = accounts.get(sub.Contract__r.AccountId);
        System.debug('accSub****1*****'+accSub);  
        // Data quality check
        List<String> missingInfo = new String[0];
        if (accSub.Name == null) 
        	missingInfo.add('Account ' + accSub.Id + ':Name');
        if (sub.Start_Date__c == null) 
        	missingInfo.add('Subscription ' + subID + ' :Start Date');
        
        if (missingInfo.size() > 0)
        {
            output.status = false;
            output.error  = 'Error: following information are missing\n';
            for (String s : missingInfo)
                output.error += '\t- ' + s + '\n';
                
            return output;
        }
        
        // Request to send
        output.req = new LibWKTSComCrmProvisioningV2.CRMProvisionningObjectsTypev2(); 
        // Subscription
        output.req.subscription = new WKTSComCrmProvisioningV2.CRMProvisioningSubscriptionType();
        System.debug('output.req.subscription****1*****'+output.req.subscription); 
        System.debug('sub.Product__r.Access_Roles__c ****1*****'+sub.Product__r.Access_Roles__c); 
        output.req.subscription.subscriptionID   = subID;
        output.req.subscription.description      = sub.Product__r.IAM_Target__c + ((sub.Product__r.Access_Roles__c != null) ? '.' + sub.Product__r.Access_Roles__c : '') + ' Subscription';
        output.req.subscription.fullName         = (sub.Product__r.Access_Roles__c != null && sub.Product__r.Access_Roles__c != '') ? sub.Product__r.Access_Roles__c : 'T_PRO';
        try 
        {
             System.debug('sub.Contract__r.AccountId**********'+sub.Contract__r.AccountId); 
            output.req.subscription.parentID = sub.Contract__r.AccountId;
        }
        catch (Exception ex) 
        {
            output.status = false;
            output.error  = 'Error: Invalid parent Account Id:' + sub.Contract__r.AccountId;
            return output;
        }
        output.req.subscription.productType       = String.isNotBlank(sub.Product__r.Access_Roles__c) ? sub.Product__r.Access_Roles__c : 'T_PRO';
        output.req.subscription.status            = 'Active';
        output.req.subscription.timeStamp         = StrDateAndTime;
        output.req.subscription.sourceSystemID    = 'CRM';
        output.req.subscription.targetSystemID    = new String[1];
        output.req.subscription.targetSystemID[0] = sub.Product__r.IAM_Target__c;
        output.req.subscription.action            = 'add';
        output.req.subscription.field             = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType[3];
        output.req.subscription.field[0]          = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
        output.req.subscription.field[0].name     = 'activationDate';
        output.req.subscription.field[0].value    = new String[1];
        output.req.subscription.field[0].value[0] = (sub.Start_Date__c != null) ? Datetime.newInstance(sub.Start_Date__c, midnight).format('MM/dd/yyyy HH:mm') : StrDateAndTime;
        output.req.subscription.field[1]          = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
        output.req.subscription.field[1].name     = 'deactivationDate';
        if (sub.End_Date__c != null)
        {
            output.req.subscription.field[1].value    = new String[1];
            output.req.subscription.field[1].value[0] = Datetime.newInstance(sub.End_Date__c, midnightMinusOne).format('MM/dd/yyyy HH:mm');
        }
        output.req.subscription.field[2]          = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
        output.req.subscription.field[2].name     = 'fxAccknd';
        output.req.subscription.field[2].value    = new String[1];
        output.req.subscription.field[2].value[0] = (sub.Access_Kind__c != null && sub.Access_Kind__c != '') ? sub.Access_Kind__c : 'WEB30';
        
        // AccountSub        
        output.req.accountSub = new WKTSComCrmProvisioningV2.CRMProvisioningAccountType();
        output.req.accountSub.companyId = (accSub.AccountNumber != null) ? accSub.AccountNumber : accSub.Id;
        
        try 
        {
            output.req.accountSub.id = accSub.Id;
        }
        catch (Exception ex) 
        {
            output.status = false;
            output.error  = 'Error : Invalid Account Id:' + accSub.Id;
            return output;
        }
        
        output.req.accountSub.companyName     = String.isNotBlank(accSub.Teleroute_Name__c) ? accSub.Teleroute_Name__c : '.';
        output.req.accountSub.country         = String.isNotBlank(accSub.BillingCountry) ? accSub.BillingCountry.toUpperCase() : 'FRANCE';
        output.req.accountSub.postalCode      = String.isNotBlank(accSub.BillingPostalCode) ? accSub.BillingPostalCode : '.';
        output.req.accountSub.telephoneNumber = String.isNotBlank(accSub.Phone) ? accSub.Phone : '.';
        output.req.accountSub.location       += (String.isNotBlank(accSub.BillingStreet) ? accSub.BillingStreet + '.' : '.');
        output.req.accountSub.location       += (String.isNotBlank(accSub.BillingPostalCode) ? accSub.BillingPostalCode + '.' : '.');
        output.req.accountSub.location       += (String.isNotBlank(accSub.BillingCity) ? accSub.BillingCity + '.' : '.');
        output.req.accountSub.location       += (String.isNotBlank(accSub.BillingState) ? accSub.BillingState + '.' : '.');
        output.req.accountSub.location       += (String.isNotBlank(accSub.BillingCountry) ? accSub.BillingCountry: 'FRANCE');
        output.req.accountSub.state           = String.isNotBlank(accSub.BillingState) ? accSub.BillingState : '.';
        output.req.accountSub.city            = String.isNotBlank(accSub.BillingCity) ? accSub.BillingCity : '.';
        output.req.accountSub.fax             = String.isNotBlank(accSub.Fax) ? accSub.Fax : '.';
        output.req.accountSub.level           = String.isNotBlank(accSub.Account_Level__c) ? accSub.Account_Level__c : '.';
        output.req.accountSub.vat             = String.isNotBlank(accSub.VAT__c) ? accSub.VAT__c : '.';
        try
        {
            output.req.accountSub.parentId = accSub.ParentId;
        }
        catch (Exception ex) 
        {
            output.status = false;
            output.error  = 'Error : Parent Account Id:' + accSub.ParentId;
            return output;
        }
        output.req.accountSub.adressLine1         = String.isNotBlank(accSub.BillingStreet) ? accSub.BillingStreet : '.';
        output.req.accountSub.webSiteUrl          = String.isNotBlank(accSub.Website) ? accSub.Website : '.';
        output.req.accountSub.phoneNumber         = String.isNotBlank(accSub.Phone) ? accSub.Phone : '.';
        output.req.accountSub.faxNumber           = String.isNotBlank(accSub.Fax) ? accSub.Fax : '.';
        output.req.accountSub.timeStamp           = StrDateAndTime;
        output.req.accountSub.sourceSystemID      = 'CRM';
        output.req.accountSub.targetSystemID      = new String[1];
        output.req.accountSub.targetSystemID[0]   = sub.Product__r.IAM_Target__c;
        output.req.accountSub.action              = 'add';
        
        output.req.accountSub.field               = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType[17];
        output.req.accountSub.field[0]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
        output.req.accountSub.field[0].name       = 'aboutSpecialization';
        if (accSub.About_Specialization__c != null)
        {
            output.req.accountSub.field[0].value      = new String[1];
            output.req.accountSub.field[0].value[0]   = String.isNotBlank(accSub.About_Specialization__c) ? accSub.About_Specialization__c : '.';
        }
        output.req.accountSub.field[1]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
        output.req.accountSub.field[1].name       = 'bankAccountNumber';
        if (accSub.BIC_Code__c != null)
        {
            output.req.accountSub.field[1].value      = new String[1];
            output.req.accountSub.field[1].value[0]   = String.isNotBlank(accSub.BIC_Code__c) ? accSub.BIC_Code__c : '.';
        }
        output.req.accountSub.field[2]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
        output.req.accountSub.field[2].name       = 'certificationLevel';
        if (accSub.Level_of_Certification__c != null)
        {
            output.req.accountSub.field[2].value      = new String[1];
            output.req.accountSub.field[2].value[0]   = String.isNotBlank(accSub.Level_of_Certification__c) ? accSub.Level_of_Certification__c : '.';
        }
        output.req.accountSub.field[3]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
        output.req.accountSub.field[3].name       = 'companyCreationDate';
        if (accSub.Company_Creation_Date__c != null)
        {
            DateTime creation = DateTime.newInstance(accSub.Company_Creation_Date__c, Time.newInstance(0, 0, 0, 0));
            output.req.accountSub.field[3].value      = new String[1];
            output.req.accountSub.field[3].value[0]   = creation.format('MM/dd/yyyy');
        }
        output.req.accountSub.field[4]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
        output.req.accountSub.field[4].name       = 'completionLevel';
        if (accSub.Completion_Level__c != null)
        {
            output.req.accountSub.field[4].value      = new String[1];
            output.req.accountSub.field[4].value[0]   = accSub.Completion_Level__c.format().replaceAll('[^0-9]', '');
        }
        output.req.accountSub.field[5]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
        output.req.accountSub.field[5].name       = 'currency';
        if (accSub.CurrencyIsoCode != null)
        {
            output.req.accountSub.field[5].value      = new String[1];
            output.req.accountSub.field[5].value[0]   = String.isNotBlank(accSub.CurrencyIsoCode) ? accSub.CurrencyIsoCode : 'EUR';
        }
        output.req.accountSub.field[6]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
        output.req.accountSub.field[6].name       = 'customerSinceDate';
        if (accSub.Customer_Since__c != null)
        {
            DateTime customerSince = DateTime.newInstance(accSub.Customer_Since__c, Time.newInstance(0, 0, 0, 0));
            output.req.accountSub.field[6].value      = new String[1];
            output.req.accountSub.field[6].value[0]   = customerSince.format('MM/dd/yyyy');
        }
        output.req.accountSub.field[7]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
        output.req.accountSub.field[7].name       = 'employeesNumber';
        if (accSub.Total_employees__c != null)
        {
            output.req.accountSub.field[7].value      = new String[1];
            output.req.accountSub.field[7].value[0]   = accSub.Total_employees__c.format().replaceAll('[^0-9]', '');
        }
        output.req.accountSub.field[8]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
        output.req.accountSub.field[8].name       = 'iban';
        if (accSub.Iban_Number__c != null)
        {
            output.req.accountSub.field[8].value      = new String[1];
            output.req.accountSub.field[8].value[0]   = (accSub.Iban_Number__c != '') ? accSub.Iban_Number__c : '.';
        }
        output.req.accountSub.field[9]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
        output.req.accountSub.field[9].name       = 'iso';
        if (accSub.ISO_Certification__c != null)
        {
            output.req.accountSub.field[9].value      = new String[1];
            output.req.accountSub.field[9].value[0]   = (accSub.ISO_Certification__c != '') ? accSub.ISO_Certification__c : '.';
        }
        output.req.accountSub.field[10]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
        output.req.accountSub.field[10].name       = 'lastUpdateBy';
        output.req.accountSub.field[10].value      = new String[1];
        output.req.accountSub.field[10].value[0]   = UserInfo.getName();
        output.req.accountSub.field[11]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
        output.req.accountSub.field[11].name       = 'lastUpdateDate';
        output.req.accountSub.field[11].value      = new String[1];
        output.req.accountSub.field[11].value[0]   = accSub.LastModifiedDate.format('MM/dd/yyyy HH:mm');
        output.req.accountSub.field[12]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
        output.req.accountSub.field[12].name       = 'siret';
        if (accSub.Company_Registration_Number__c != null)
        {
            output.req.accountSub.field[12].value      = new String[1];
            output.req.accountSub.field[12].value[0]   = (accSub.Company_Registration_Number__c != '') ? accSub.Company_Registration_Number__c : '.';
        }
        output.req.accountSub.field[13]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
        output.req.accountSub.field[13].name       = 'tlrNumber';
        if (accSub.Teleroute_Number__c != null)
        {
            output.req.accountSub.field[13].value      = new String[1];
            output.req.accountSub.field[13].value[0]   = (accSub.Teleroute_Number__c != '') ? accSub.Teleroute_Number__c : '.';
        }
        output.req.accountSub.field[14]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
        output.req.accountSub.field[14].name       = 'trucksNumber';
        if (accSub.Number_of_trucks_owned__c != null)
        {
            output.req.accountSub.field[14].value      = new String[1];
            output.req.accountSub.field[14].value[0]   = accSub.Number_of_trucks_owned__c.format().replaceAll('[^0-9]', '');
        }
        output.req.accountSub.field[15]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
        output.req.accountSub.field[15].name       = 'id';
        output.req.accountSub.field[15].value      = new String[1];
        output.req.accountSub.field[15].value[0]   = accSub.Id;
        
        // TCD Published Status
        output.req.accountSub.field[16]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
        output.req.accountSub.field[16].name       = 'TCDVisibility';
        output.req.accountSub.field[16].value      = new String[1];
        output.req.accountSub.field[16].value[0]   = accSub.TCD_Visibility__c;
        
        
        // Members
        Integer nbMembers  = contactsAtSubLevel ? accountIds.size() : accountIds.size() - 1;
        output.req.members = new LibWKTSComCrmProvisioningV2.CRMProvisionningMemberType[nbMembers];
        Integer index = 0;
        
        for (Account acc : accounts.values())
        {
            // List user profiles
            List<User_Profile__c> lstUserProfile = new List<User_Profile__c>();
            for (User_Profile__c up : userProfiles)
            {
                if (up.Contact__r.AccountId == acc.Id)
                    lstUserProfile.add(up);
            }
            
            if (lstUserProfile.size() > 0)
            {
                List<String> missing = new String[0];
                if (acc.Name == null) missing.add('Account ' + acc.Id + ':Name');
                
                if (missing.size() > 0)
                {
                    output.status = false;
                    output.error  = 'Error: following information are missing\n';
                    for (String s : missing)
                        output.error += '\t- ' + s + '\n';
                        
                    return output;
                }
        
                // Account member
                output.req.members[index] = new LibWKTSComCrmProvisioningV2.CRMProvisionningMemberType();
                output.req.members[index].account = new WKTSComCrmProvisioningV2.CRMProvisioningAccountType();
                output.req.members[index].account.companyId = (acc.AccountNumber != null) ? acc.AccountNumber : acc.Id;
                
                try 
                {
                    output.req.members[index].account.id = acc.Id;
                }
                catch (Exception ex) 
                {
                    output.status = false;
                    output.error  = 'Error : Invalid Account Id:' + acc.Id;
                    return output;
                }
                
                output.req.members[index].account.companyName     = String.isNotBlank(acc.Teleroute_Name__c) ? acc.Teleroute_Name__c : '.';
                output.req.members[index].account.country         = String.isNotBlank(acc.BillingCountry) ? acc.BillingCountry.toUpperCase() : 'FRANCE';
                output.req.members[index].account.postalCode      = String.isNotBlank(acc.BillingPostalCode) ? acc.BillingPostalCode : '.';
                output.req.members[index].account.telephoneNumber = String.isNotBlank(acc.Phone) ? acc.Phone : '.';
                output.req.members[index].account.location       += (String.isNotBlank(acc.BillingStreet) ? acc.BillingStreet + '.' : '.');
                output.req.members[index].account.location       += (String.isNotBlank(acc.BillingPostalCode) ? acc.BillingPostalCode + '.' : '.');
                output.req.members[index].account.location       += (String.isNotBlank(acc.BillingCity) ? acc.BillingCity + '.' : '.');
                output.req.members[index].account.location       += (String.isNotBlank(acc.BillingState) ? acc.BillingState + '.' : '.');
                output.req.members[index].account.location       += (String.isNotBlank(acc.BillingCountry) ? acc.BillingCountry: 'FRANCE');
                output.req.members[index].account.state           = String.isNotBlank(acc.BillingState) ? acc.BillingState : '.';
                output.req.members[index].account.city            = String.isNotBlank(acc.BillingCity) ? acc.BillingCity : '.';
                output.req.members[index].account.fax             = String.isNotBlank(acc.Fax) ? acc.Fax : '.';
                output.req.members[index].account.level           = String.isNotBlank(acc.Account_Level__c) ? acc.Account_Level__c : '.';
                output.req.members[index].account.vat             = String.isNotBlank(acc.VAT__c) ? acc.VAT__c : '.';
                try
                {
                    output.req.members[index].account.parentId = acc.ParentId;
                }
                catch (Exception ex) 
                {
                    output.status = false;
                    output.error  = 'Error : Parent Account Id:' + acc.ParentId;
                    return output;
                }
                output.req.members[index].account.adressLine1         = String.isNotBlank(acc.BillingStreet) ? acc.BillingStreet : '.';
                output.req.members[index].account.webSiteUrl          = String.isNotBlank(acc.Website) ? acc.Website : '.';
                output.req.members[index].account.phoneNumber         = String.isNotBlank(acc.Phone) ? acc.Phone : '.';
                output.req.members[index].account.faxNumber           = String.isNotBlank(acc.Fax) ? acc.Fax : '.';
                output.req.members[index].account.timeStamp           = StrDateAndTime;
                output.req.members[index].account.sourceSystemID      = 'CRM';
                output.req.members[index].account.targetSystemID      = new String[1];
                output.req.members[index].account.targetSystemID[0]   = sub.Product__r.IAM_Target__c;
                output.req.members[index].account.action              = 'add';
                
                output.req.members[index].account.field               = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType[17];
                output.req.members[index].account.field[0]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
                output.req.members[index].account.field[0].name       = 'aboutSpecialization';
                if (acc.About_Specialization__c != null)
                {
                    output.req.members[index].account.field[0].value      = new String[1];
                    output.req.members[index].account.field[0].value[0]   = (acc.About_Specialization__c != '') ? acc.About_Specialization__c : '.';
                }
                output.req.members[index].account.field[1]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
                output.req.members[index].account.field[1].name       = 'bankAccountNumber';
                if (acc.BIC_Code__c != null)
                {
                    output.req.members[index].account.field[1].value      = new String[1];
                    output.req.members[index].account.field[1].value[0]   = (acc.BIC_Code__c != '') ? acc.BIC_Code__c : '.';
                }
                output.req.members[index].account.field[2]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
                output.req.members[index].account.field[2].name       = 'certificationLevel';
                if (acc.Level_of_Certification__c != null)
                {
                    output.req.members[index].account.field[2].value      = new String[1];
                    output.req.members[index].account.field[2].value[0]   = (acc.Level_of_Certification__c != '') ? acc.Level_of_Certification__c : '.';
                }
                output.req.members[index].account.field[3]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
                output.req.members[index].account.field[3].name       = 'companyCreationDate';
                if (acc.Company_Creation_Date__c != null)
                {
                    DateTime creation = DateTime.newInstance(acc.Company_Creation_Date__c, Time.newInstance(0, 0, 0, 0));
                    output.req.members[index].account.field[3].value      = new String[1];
                    output.req.members[index].account.field[3].value[0]   = creation.format('MM/dd/yyyy');
                }
                output.req.members[index].account.field[4]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
                output.req.members[index].account.field[4].name       = 'completionLevel';
                if (acc.Completion_Level__c != null)
                {
                    output.req.members[index].account.field[4].value      = new String[1];
                    output.req.members[index].account.field[4].value[0]   = acc.Completion_Level__c.format().replaceAll('[^0-9]', '');
                }
                output.req.members[index].account.field[5]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
                output.req.members[index].account.field[5].name       = 'currency';
                if (acc.CurrencyIsoCode != null)
                {
                    output.req.members[index].account.field[5].value      = new String[1];
                    output.req.members[index].account.field[5].value[0]   = (acc.CurrencyIsoCode != '') ? acc.CurrencyIsoCode : '.';
                }
                output.req.members[index].account.field[6]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
                output.req.members[index].account.field[6].name       = 'customerSinceDate';
                if (acc.Customer_Since__c != null)
                {
                    DateTime customerSince = DateTime.newInstance(acc.Customer_Since__c, Time.newInstance(0, 0, 0, 0));
                    output.req.members[index].account.field[6].value      = new String[1];
                    output.req.members[index].account.field[6].value[0]   = customerSince.format('MM/dd/yyyy');
                }
                output.req.members[index].account.field[7]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
                output.req.members[index].account.field[7].name       = 'employeesNumber';
                if (acc.Total_employees__c != null)
                {
                    output.req.members[index].account.field[7].value      = new String[1];
                    output.req.members[index].account.field[7].value[0]   = acc.Total_employees__c.format().replaceAll('[^0-9]', '');
                }
                output.req.members[index].account.field[8]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
                output.req.members[index].account.field[8].name       = 'iban';
                if (acc.Iban_Number__c != null)
                {
                    output.req.members[index].account.field[8].value      = new String[1];
                    output.req.members[index].account.field[8].value[0]   = (acc.Iban_Number__c != '') ? acc.Iban_Number__c : '.';
                }
                output.req.members[index].account.field[9]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
                output.req.members[index].account.field[9].name       = 'iso';
                if (acc.ISO_Certification__c != null)
                {
                    output.req.members[index].account.field[9].value      = new String[1];
                    output.req.members[index].account.field[9].value[0]   = (acc.ISO_Certification__c != '') ? acc.ISO_Certification__c : '.';
                }
                output.req.members[index].account.field[10]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
                output.req.members[index].account.field[10].name       = 'lastUpdateBy';
                output.req.members[index].account.field[10].value      = new String[1];
                output.req.members[index].account.field[10].value[0]   = UserInfo.getName();
                output.req.members[index].account.field[11]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
                output.req.members[index].account.field[11].name       = 'lastUpdateDate';
                output.req.members[index].account.field[11].value      = new String[1];
                output.req.members[index].account.field[11].value[0]   = acc.LastModifiedDate.format('MM/dd/yyyy HH:mm');
                output.req.members[index].account.field[12]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
                output.req.members[index].account.field[12].name       = 'siret';
                if (acc.Company_Registration_Number__c != null)
                {
                    output.req.members[index].account.field[12].value      = new String[1];
                    output.req.members[index].account.field[12].value[0]   = (acc.Company_Registration_Number__c != '') ? acc.Company_Registration_Number__c : '.';
                }
                output.req.members[index].account.field[13]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
                output.req.members[index].account.field[13].name       = 'tlrNumber';
                if (acc.Teleroute_Number__c != null)
                {
                    output.req.members[index].account.field[13].value      = new String[1];
                    output.req.members[index].account.field[13].value[0]   = (acc.Teleroute_Number__c != '') ? acc.Teleroute_Number__c : '.';
                }
                output.req.members[index].account.field[14]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
                output.req.members[index].account.field[14].name       = 'trucksNumber';
                if (acc.Number_of_trucks_owned__c != null)
                {
                    output.req.members[index].account.field[14].value      = new String[1];
                    output.req.members[index].account.field[14].value[0]   = acc.Number_of_trucks_owned__c.format().replaceAll('[^0-9]', '');
                }
                output.req.members[index].account.field[15]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
                output.req.members[index].account.field[15].name       = 'id';
                output.req.members[index].account.field[15].value      = new String[1];
                output.req.members[index].account.field[15].value[0]   = acc.Id;
                
                output.req.members[index].account.field[16]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
                output.req.members[index].account.field[16].name       = 'TCDVisibility';
                output.req.members[index].account.field[16].value      = new String[1];
                output.req.members[index].account.field[16].value[0]   = acc.TCD_Visibility__c;
                
                
                output.req.members[index].contact = new WKTSComCrmProvisioningV2.CRMProvisioningContactType[lstUserProfile.size()];
                
                for (Integer i = 0; i < lstUserProfile.size(); i++)
                {
                    User_Profile__c up = lstUserProfile[i];
                    
                    // Data quality check
                    List<String> missingOnContact = new String[0];
                    if (!String.isNotBlank(up.Contact__r.Email)) missingOnContact.add('Contact ' + up.Contact__c + ':Email');
                    if (!String.isNotBlank(up.Contact__r.Gender__c)) missingOnContact.add('Contact ' + up.Contact__c + ':Gender');
                    if (!String.isNotBlank(up.Contact__r.Phone)) missingOnContact.add('Contact ' + up.Contact__c + ':Phone');
                    if (!String.isNotBlank(up.Contact__r.LastName)) missingOnContact.add('Contact ' + up.Contact__c + ':Last Name');
                    if (!String.isNotBlank(up.Contact__r.FirstName)) missingOnContact.add('Contact ' + up.Contact__c + ':First Name');
                    if (!String.isNotBlank(up.Contact__r.Language__c)) missingOnContact.add('Contact ' + up.Contact__c + ':Language');
                    
                    if (missingOnContact.size() > 0)
                    {
                        output.status = false;
                        output.error  = 'Error: following information are missing\n';
                        for (String s : missingOnContact)
                            output.error += '\t- ' + s + '\n';
                            
                        return output;
                    }
        
                    output.req.members[index].contact[i] = new WKTSComCrmProvisioningV2.CRMProvisioningContactType();
                    try
                    {
                        output.req.members[index].contact[i].contactSourceUID = up.Contact__r.Id;
                    }
                    catch (Exception ex) 
                    {
                        output.status = false;
                        output.error  = 'Error : Invalid Contact Id:' + up.Contact__r.Id;
                        return output;
                    }
                    output.req.members[index].contact[i].id                  = up.Contact__r.Id;
                    output.req.members[index].contact[i].description         = String.isNotBlank(up.Contact__r.Description) ? up.Contact__r.Description : 'No Description';
                    output.req.members[index].contact[i].fullName            = String.isNotBlank(up.Contact__r.Name) ? up.Contact__r.Name : '.';
                    output.req.members[index].contact[i].givenName           = String.isNotBlank(up.Contact__r.FirstName) ? up.Contact__r.FirstName : '.';
                    output.req.members[index].contact[i].fax                 = String.isNotBlank(up.Contact__r.Fax) ? up.Contact__r.Fax : '.';
                    output.req.members[index].contact[i].initials           += String.isNotBlank(up.Contact__r.FirstName) ? up.Contact__r.FirstName.substring(0, 1) : '.';
                    output.req.members[index].contact[i].initials           += String.isNotBlank(up.Contact__r.LastName) ? up.Contact__r.LastName.substring(0, 1) : '.';
                    output.req.members[index].contact[i].internetEmailAdress = String.isNotBlank(up.Contact__r.Email) ? up.Contact__r.Email : '.';
                    output.req.members[index].contact[i].location           += (String.isNotBlank(up.Contact__r.MailingStreet) ? up.Contact__r.MailingStreet + '.' : '.');
                    output.req.members[index].contact[i].location           += (String.isNotBlank(up.Contact__r.MailingPostalCode) ? up.Contact__r.MailingPostalCode + '.' : '.');
                    output.req.members[index].contact[i].location           += (String.isNotBlank(up.Contact__r.MailingCity) ? up.Contact__r.MailingCity + '.' : '.');
                    output.req.members[index].contact[i].location           += (String.isNotBlank(up.Contact__r.MailingState) ? up.Contact__r.MailingState + '.' : '.');
                    output.req.members[index].contact[i].location           += (String.isNotBlank(up.Contact__r.MailingCountry) ? up.Contact__r.MailingCountry : ((up.Contact__r.Account.BillingCountry != null && up.Contact__r.Account.BillingCountry != '') ? up.Contact__r.Account.BillingCountry : 'France'));
                    output.req.members[index].contact[i].surname             = String.isNotBlank(up.Contact__r.LastName) ? up.Contact__r.LastName : '.';
                    output.req.members[index].contact[i].telephoneNumber     = String.isNotBlank(up.Contact__r.Phone) ? up.Contact__r.Phone : '.';
                    output.req.members[index].contact[i].title               = String.isNotBlank(up.Contact__r.Salutation) ? up.Contact__r.Salutation : (up.Contact__r.Gender__c == 'Female') ? 'Mrs.' : 'Mr.';
                    output.req.members[index].contact[i].jobCode             = String.isNotBlank(up.Contact__r.Job_Title__c) ? up.Contact__r.Job_Title__c : '.';
                    output.req.members[index].contact[i].language            = String.isNotBlank(up.Contact__r.Language__c) ? up.Contact__r.Language__c.toUpperCase() : '.';
                    output.req.members[index].contact[i].streetAddress       = String.isNotBlank(up.Contact__r.MailingStreet) ? up.Contact__r.MailingStreet : '.';
                    output.req.members[index].contact[i].state               = String.isNotBlank(up.Contact__r.MailingState) ? up.Contact__r.MailingState : '.';
                    output.req.members[index].contact[i].postalCode          = String.isNotBlank(up.Contact__r.MailingPostalCode) ? up.Contact__r.MailingPostalCode : '.';
                    output.req.members[index].contact[i].city                = String.isNotBlank(up.Contact__r.MailingCity) ? up.Contact__r.MailingCity : '.';
                    output.req.members[index].contact[i].country             = String.isNotBlank(up.Contact__r.MailingCountry) ? up.Contact__r.MailingCountry.toUpperCase() : ((up.Contact__r.Account.BillingCountry != null && up.Contact__r.Account.BillingCountry != '') ? up.Contact__r.Account.BillingCountry.toUpperCase() : 'FRANCE');
                    System.Debug('## Contact:' + output.req.members[index].contact[i].fullName + 'Mailing Cntry:' + up.Contact__r.MailingCountry + '-Account.Country:' + up.Contact__r.Account.BillingCountry + '-Envoye:' + output.req.members[index].contact[i].country);
                    output.req.members[index].contact[i].otherPhoneNumber    = (up.Contact__r.MobilePhone != null && up.Contact__r.MobilePhone != '') ? up.Contact__r.MobilePhone : '.';                
                    output.req.members[index].contact[i].phoneNumber         = String.isNotBlank(up.Contact__r.Phone) ? up.Contact__r.Phone : '.';
                    output.req.members[index].contact[i].faxNumber           = String.isNotBlank(up.Contact__r.Fax) ? up.Contact__r.Fax : '.';
                    output.req.members[index].contact[i].mobileNumber        = String.isNotBlank(up.Contact__r.MobilePhone) ? up.Contact__r.MobilePhone : '.';
                    output.req.members[index].contact[i].fxLogin             = String.isNotBlank(up.FX_Login__c) ? up.FX_Login__c : '';
                    output.req.members[index].contact[i].fxAccknd            = String.isNotBlank(up.FX_Acces_Kind__c) ? up.FX_Acces_Kind__c : '.';
                    output.req.members[index].contact[i].activationDate      = (sub.Start_Date__c != null) ? Datetime.newInstance(sub.Start_Date__c, midnight).format('MM/dd/yyyy HH:mm') : StrDateAndTime;
                    output.req.members[index].contact[i].userCreatorId       = UserInfo.getName();
                    if (operation == 'SuspendAll')
                        output.req.members[index].contact[i].contactStatus       = 'Suspended';
                    else
                        output.req.members[index].contact[i].contactStatus       = 'Activated';
                    output.req.members[index].contact[i].groupsMembership    = new WKTSComCrmProvisioningV2.CRMProvisioningGroupsMembershipType();
                    
                    if (operation != 'SuspendAll')
                    {
                        // Access Roles
                        if (up.Tivios_Role__c != null)
                        {
                            List<String> roles = up.Tivios_Role__c.split(';');
                        
                            output.req.members[index].contact[i].groupsMembership.groupMembership = new String[roles.size()];
                                   
                            for (Integer j = 0; j < roles.size(); j++)
                                output.req.members[index].contact[i].groupsMembership.groupMembership[i] = roles[j];
                        }
                        else
                        {
                            List<User_Profile_Service__c> services = mapIdUpServ.get(up.Id);
                            
                            List<String> roles = new List<String>();
                            if (services != null)
                            {
                                for (User_Profile_Service__c service : services)
                                {
                                    if (service.Suspension_Start_Date__c == null || service.Suspension_Start_Date__c > Date.Today() || service.Suspension_End_Date__c < Date.Today())
                                    {
                                        if (service.Provisioning_Service__r.Service__r.Access_Roles__c != null)
                                        {
                                            List<String> accessServices = service.Provisioning_Service__r.Service__r.Access_Roles__c.split(';');
                                            for (String accServ : accessServices)
                                            {
                                                accServ = accServ.replace('$AK$', String.isNotBlank(sub.Access_Kind__c) ? sub.Access_Kind__c : 'WEB30');
                                                roles.add(accServ);
                                            }
                                        }
                                        
                                        for (User_Profile_Service_Attribute__c serviceAttr : service.User_Profile_Service_Attributes__r)
                                        {
                                            if (serviceAttr.Suspension_Start_Date__c == null || serviceAttr.Suspension_Start_Date__c > Date.Today() || serviceAttr.Suspension_End_Date__c < Date.Today())
                                            {
                                                if (serviceAttr.Provisioning_Service_Attribute__r.Service_Attribute__r.Access_Role__c != null)
                                                {
                                                    List<String> accessServiceAttrs = serviceAttr.Provisioning_Service_Attribute__r.Service_Attribute__r.Access_Role__c.split(';');
                                                    for (String accServAtt : accessServiceAttrs)
                                                    {
                                                        accServAtt = accServAtt.replace('$AK$', String.isNotBlank(sub.Access_Kind__c) ? sub.Access_Kind__c : 'WEB30');
                                                        roles.add(accServAtt);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                
                            output.req.members[index].contact[i].groupsMembership.groupMembership = new String[roles.size()];
                            for (Integer j = 0; j < roles.size(); j++)
                                output.req.members[index].contact[i].groupsMembership.groupMembership[j] = roles[j];
                        }
                    }
                    
                    try 
                    {
                        output.req.members[index].contact[i].ownerAccountID = up.Contact__r.AccountId;
                    }
                    catch (Exception ex) 
                    {
                        output.status = false;
                        output.error  = 'Error : Invalid owner Account Id:' + up.Contact__r.AccountId;
                        return output;
                    }
                    output.req.members[index].contact[i].timeStamp           = StrDateAndTime;
                    output.req.members[index].contact[i].sourceSystemID      = 'CRM';
                    output.req.members[index].contact[i].targetSystemID      = new String[1];
                    output.req.members[index].contact[i].targetSystemID[0]   = sub.Product__r.IAM_Target__c;
                    output.req.members[index].contact[i].action              = 'add';
                    output.req.members[index].contact[i].field               = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType[10];
                    output.req.members[index].contact[i].field[0]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
                    output.req.members[index].contact[i].field[0].name       = 'CUGs';
                    if (operation != 'SuspendAll')
                    {
                        output.req.members[index].contact[i].field[0].value      = new String[1];
                        output.req.members[index].contact[i].field[0].value[0]   = (up.Private_Exchange_ID__c != null && up.Private_Exchange_ID__c != '') ? up.Private_Exchange_ID__c : 'OPEN';
                    }
                    output.req.members[index].contact[i].field[1]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
                    output.req.members[index].contact[i].field[1].name       = 'PUGs';
                    
                    if (operation != 'SuspendAll')
                    {
                                                
                        Set <string> pugs = new Set <String>();
                        if(String.isNotBlank(up.User_PUG_Name__c))
                            pugs.AddAll(up.User_PUG_Name__c.split(';'));
                                                
                        TLR_PX_CUG__c PX_CUG = TLR_PX_CUG__c.getValues(up.Private_Exchange_ID__c);
                        
                        if(PX_CUG != null) {
                        pugs.Add(PX_CUG.CUG_code__c);   
                                                
                        if(PX_CUG.CUG_code_2__c != null)
                        pugs.Add(PX_CUG.CUG_code_2__c);                       
                        }
                        System.Debug ('PUGs'+pugs);
                        output.req.members[index].contact[i].field[1].value = new String[pugs.size()];
                        Integer p = 0;
                        for (String str : pugs) {
                            output.req.members[index].contact[i].field[1].value[p] = str;
                            p++;
                        }   
                    }
                    output.req.members[index].contact[i].field[2]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
                    output.req.members[index].contact[i].field[2].name       = 'test';
                    output.req.members[index].contact[i].field[2].value      = new String[1];
                    output.req.members[index].contact[i].field[2].value[0]   = up.Test_login__c ? 'true' : 'false';
                    output.req.members[index].contact[i].field[3]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
                    output.req.members[index].contact[i].field[3].name       = 'contactType';
                    output.req.members[index].contact[i].field[3].value      = new String[1];
                    output.req.members[index].contact[i].field[3].value[0]   = 'Teleroute';
                    output.req.members[index].contact[i].field[4]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
                    output.req.members[index].contact[i].field[4].name       = 'mobilePhone';
                    if (up.Contact__r.MobilePhone != null)
                    {
                        output.req.members[index].contact[i].field[4].value      = new String[1];
                        output.req.members[index].contact[i].field[4].value[0]   = (up.Contact__r.MobilePhone != '') ? up.Contact__r.MobilePhone : '.';
                    }
                    output.req.members[index].contact[i].field[5]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
                    output.req.members[index].contact[i].field[5].name       = 'function';
                    if (up.Contact__r.Job_Profile__c != null)
                    {
                        output.req.members[index].contact[i].field[5].value      = new String[1];
                        output.req.members[index].contact[i].field[5].value[0]   = (up.Contact__r.Job_Profile__c != '') ? up.Contact__r.Job_Profile__c : '.';
                    }
                    output.req.members[index].contact[i].field[6]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
                    output.req.members[index].contact[i].field[6].name       = 'visible';
                    output.req.members[index].contact[i].field[6].value      = new String[1];
                    output.req.members[index].contact[i].field[6].value[0]   = up.Contact__r.Is_Visible__c ? 'true' : 'false';
                    output.req.members[index].contact[i].field[7]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
                    output.req.members[index].contact[i].field[7].name       = 'id';
                    output.req.members[index].contact[i].field[7].value      = new String[1];
                    output.req.members[index].contact[i].field[7].value[0]   = up.Contact__r.Id;
                    output.req.members[index].contact[i].field[8]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
                    output.req.members[index].contact[i].field[8].name       = 'fxAccknd';
                    output.req.members[index].contact[i].field[8].value      = new String[1];
                    output.req.members[index].contact[i].field[8].value[0]   = (sub.Access_Kind__c != null && sub.Access_Kind__c != '') ? sub.Access_Kind__c : 'WEB30';
                    output.req.members[index].contact[i].field[9]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
                    output.req.members[index].contact[i].field[9].name       = 'PIA';
                    if (up.PIA_Interface__c != null && up.PIA_Interface__c != '' && up.PIA_Interface__c != '-1')
                    {
                        output.req.members[index].contact[i].field[9].value      = new String[1];
                        output.req.members[index].contact[i].field[9].value[0]   = up.PIA_Interface__c;
                    }
                }
                
                index++;
            }
        }
        
        output.req.transactionId = generateTransactionId(provId);
        
        output.status = true;
        return output;
    }
    
    /* @Description : This method prepare the WS request and get the response.
    */ 
    private static RequestPreparationResult prepareRequestAccountAndSub(ID subsId, Date cancelDate, Boolean cancel)
    {
        RequestPreparationResult output = new RequestPreparationResult();
        
        //Current date
        Time midnight         = Time.newInstance(0, 0, 0, 0);
        Time midnightMinusOne = Time.newInstance(23, 59, 59, 0);
        Datetime dateAndTime  = Datetime.now();
        Date     dateNow      = Date.Today();
        String StrDateAndTime = dateAndTime.format('MM/dd/yyyy HH:mm:ss');
        
        // Database query for information
        Subscription__c sub = [SELECT Start_Date__c, End_Date__c, 
                                      Product__r.Access_Roles__c, 
                                      Product__r.IAM_Target__c,
                                      Name, Contract__r.AccountId,
                                      Access_Kind__c,
                                      (SELECT Id FROM Provisioning__r) 
                               FROM Subscription__c 
                               WHERE Id = :subsId];
        
        Account accSub      = [SELECT Website, VAT__c, Phone, ParentId, Name, Id, Fax, 
                                      Deactivation_Date__c, BillingStreet, BillingState, 
                                      BillingPostalCode, BillingCountry, BillingCity, 
                                      Activation_Date__c, Account_Level__c, 
                                      About_Specialization__c, BIC_Code__c, AccountNumber, 
                                      Level_of_Certification__c,  
                                      Company_Creation_Date__c, Completion_Level__c, 
                                      CurrencyIsoCode, Customer_Since__c, Total_employees__c, 
                                      Iban_Number__c, ISO_Certification__c, 
                                      Company_Registration_Number__c, Teleroute_Number__c, 
                                      Number_of_trucks_owned__c, LastModifiedDate, Teleroute_Name__c, TCD_Visibility__c
                               FROM Account 
                               WHERE Id = :sub.Contract__r.AccountId];
                          
        // Request to send
        output.req = new LibWKTSComCrmProvisioningV2.CRMProvisionningObjectsTypev2();
        
        // Subscription
        output.req.subscription = new WKTSComCrmProvisioningV2.CRMProvisioningSubscriptionType();
        output.req.subscription.subscriptionID   = subsID;
        output.req.subscription.description      = sub.Product__r.IAM_Target__c + ((sub.Product__r.Access_Roles__c != null) ? '.' + sub.Product__r.Access_Roles__c : '') + ' Subscription';
        output.req.subscription.fullName         = String.isNotBlank(sub.Product__r.Access_Roles__c) ? sub.Product__r.Access_Roles__c : 'T_PRO';
        try 
        {
            output.req.subscription.parentID = sub.Contract__r.AccountId;
        }
        catch (Exception ex) 
        {
            output.status = false;
            output.error  = 'Error: Invalid parent Account Id:' + sub.Contract__r.AccountId;
            return output;
        }
        output.req.subscription.productType       = String.isNotBlank(sub.Product__r.Access_Roles__c) ? sub.Product__r.Access_Roles__c : 'T_PRO';
        output.req.subscription.status            = 'Active';
        output.req.subscription.timeStamp         = StrDateAndTime;
        output.req.subscription.sourceSystemID    = 'CRM';
        output.req.subscription.targetSystemID    = new String[1];
        output.req.subscription.targetSystemID[0] = sub.Product__r.IAM_Target__c;
        output.req.subscription.action            = 'add';
        output.req.subscription.field             = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType[3];
        output.req.subscription.field[0]          = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
        output.req.subscription.field[0].name     = 'activationDate';
        output.req.subscription.field[0].value    = new String[1];
        output.req.subscription.field[0].value[0] = (sub.Start_Date__c != null) ? Datetime.newInstance(sub.Start_Date__c, midnight).format('MM/dd/yyyy HH:mm') : StrDateAndTime;
        output.req.subscription.field[1]          = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
        output.req.subscription.field[1].name     = 'deactivationDate';
        if (cancel)
        {
            output.req.subscription.field[1].value    = new String[1];
            output.req.subscription.field[1].value[0] = Datetime.newInstance(cancelDate, midnightMinusOne).format('MM/dd/yyyy HH:mm');
        }
        else if (sub.End_Date__c != null)
        {
            output.req.subscription.field[1].value    = new String[1];
            output.req.subscription.field[1].value[0] = Datetime.newInstance(sub.End_Date__c, midnightMinusOne).format('MM/dd/yyyy HH:mm');
        }
        output.req.subscription.field[2]          = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
        output.req.subscription.field[2].name     = 'fxAccknd';
        output.req.subscription.field[2].value    = new String[1];
        output.req.subscription.field[2].value[0] = String.isNotBlank(sub.Access_Kind__c) ? sub.Access_Kind__c : 'WEB30';
        
        // AccountSub        
        output.req.accountSub = new WKTSComCrmProvisioningV2.CRMProvisioningAccountType();
        output.req.accountSub.companyId = (accSub.AccountNumber != null) ? accSub.AccountNumber : accSub.Id;
        
        try 
        {
            output.req.accountSub.id = accSub.Id;
        }
        catch (Exception ex) 
        {
            output.status = false;
            output.error  = 'Error : Invalid Account Id:' + accSub.Id;
            return output;
        }
        
        output.req.accountSub.companyName     = String.isNotBlank(accSub.Teleroute_Name__c ) ? accSub.Teleroute_Name__c : '.';
        output.req.accountSub.country         = String.isNotBlank(accSub.BillingCountry) ? accSub.BillingCountry.toUpperCase() : 'FRANCE';
        output.req.accountSub.postalCode      = String.isNotBlank(accSub.BillingPostalCode) ? accSub.BillingPostalCode : '.';
        output.req.accountSub.telephoneNumber = String.isNotBlank(accSub.Phone) ? accSub.Phone : '.';
        output.req.accountSub.location       += (String.isNotBlank(accSub.BillingStreet) ? accSub.BillingStreet + '.' : '.');
        output.req.accountSub.location       += (String.isNotBlank(accSub.BillingPostalCode) ? accSub.BillingPostalCode + '.' : '.');
        output.req.accountSub.location       += (String.isNotBlank(accSub.BillingCity) ? accSub.BillingCity + '.' : '.');
        output.req.accountSub.location       += (String.isNotBlank(accSub.BillingState) ? accSub.BillingState + '.' : '.');
        output.req.accountSub.location       += (String.isNotBlank(accSub.BillingCountry) ? accSub.BillingCountry: 'FRANCE');
        output.req.accountSub.state           = String.isNotBlank(accSub.BillingState) ? accSub.BillingState : '.';
        output.req.accountSub.city            = String.isNotBlank(accSub.BillingCity) ? accSub.BillingCity : '.';
        output.req.accountSub.fax             = String.isNotBlank(accSub.Fax) ? accSub.Fax : '.';
        output.req.accountSub.level           = String.isNotBlank(accSub.Account_Level__c) ? accSub.Account_Level__c : '.';
        output.req.accountSub.vat             = String.isNotBlank(accSub.VAT__c) ? accSub.VAT__c : '.';
        try
        {
            output.req.accountSub.parentId = accSub.ParentId;
        }
        catch (Exception ex) 
        {
            output.status = false;
            output.error  = 'Error : Parent Account Id:' + accSub.ParentId;
            return output;
        }
        output.req.accountSub.adressLine1         = String.isNotBlank(accSub.BillingStreet) ? accSub.BillingStreet : '.';
        output.req.accountSub.webSiteUrl          = String.isNotBlank(accSub.Website) ? accSub.Website : '.';
        output.req.accountSub.phoneNumber         = String.isNotBlank(accSub.Phone) ? accSub.Phone : '.';
        output.req.accountSub.faxNumber           = String.isNotBlank(accSub.Fax) ? accSub.Fax : '.';
        output.req.accountSub.timeStamp           = StrDateAndTime;
        output.req.accountSub.sourceSystemID      = 'CRM';
        output.req.accountSub.targetSystemID      = new String[1];
        output.req.accountSub.targetSystemID[0]   = sub.Product__r.IAM_Target__c;
        output.req.accountSub.action              = 'add';
        
        output.req.accountSub.field               = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType[17];
        output.req.accountSub.field[0]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
        output.req.accountSub.field[0].name       = 'aboutSpecialization';
        if (accSub.About_Specialization__c != null)
        {
            output.req.accountSub.field[0].value      = new String[1];
            output.req.accountSub.field[0].value[0]   = (accSub.About_Specialization__c != '') ? accSub.About_Specialization__c : '.';
        }
        output.req.accountSub.field[1]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
        output.req.accountSub.field[1].name       = 'bankAccountNumber';
        if (accSub.BIC_Code__c != null)
        {
            output.req.accountSub.field[1].value      = new String[1];
            output.req.accountSub.field[1].value[0]   = (accSub.BIC_Code__c != '') ? accSub.BIC_Code__c : '.';
        }
        output.req.accountSub.field[2]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
        output.req.accountSub.field[2].name       = 'certificationLevel';
        if (accSub.Level_of_Certification__c != null)
        {
            output.req.accountSub.field[2].value      = new String[1];
            output.req.accountSub.field[2].value[0]   = (accSub.Level_of_Certification__c != '') ? accSub.Level_of_Certification__c : '.';
        }
        output.req.accountSub.field[3]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
        output.req.accountSub.field[3].name       = 'companyCreationDate';
        if (accSub.Company_Creation_Date__c != null)
        {
            DateTime creation = DateTime.newInstance(accSub.Company_Creation_Date__c, Time.newInstance(0, 0, 0, 0));
            output.req.accountSub.field[3].value      = new String[1];
            output.req.accountSub.field[3].value[0]   = creation.format('MM/dd/yyyy');
        }
        output.req.accountSub.field[4]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
        output.req.accountSub.field[4].name       = 'completionLevel';
        if (accSub.Completion_Level__c != null)
        {
            output.req.accountSub.field[4].value      = new String[1];
            output.req.accountSub.field[4].value[0]   = accSub.Completion_Level__c.format().replaceAll('[^0-9]', '');
        }
        output.req.accountSub.field[5]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
        output.req.accountSub.field[5].name       = 'currency';
        if (accSub.CurrencyIsoCode != null)
        {
            output.req.accountSub.field[5].value      = new String[1];
            output.req.accountSub.field[5].value[0]   = (accSub.CurrencyIsoCode != '') ? accSub.CurrencyIsoCode : 'EUR';
        }
        output.req.accountSub.field[6]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
        output.req.accountSub.field[6].name       = 'customerSinceDate';
        if (accSub.Customer_Since__c != null)
        {
            DateTime customerSince = DateTime.newInstance(accSub.Customer_Since__c, Time.newInstance(0, 0, 0, 0));
            output.req.accountSub.field[6].value      = new String[1];
            output.req.accountSub.field[6].value[0]   = customerSince.format('MM/dd/yyyy');
        }
        output.req.accountSub.field[7]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
        output.req.accountSub.field[7].name       = 'employeesNumber';
        if (accSub.Total_employees__c != null)
        {
            output.req.accountSub.field[7].value      = new String[1];
            output.req.accountSub.field[7].value[0]   = accSub.Total_employees__c.format().replaceAll('[^0-9]', '');
        }
        output.req.accountSub.field[8]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
        output.req.accountSub.field[8].name       = 'iban';
        if (accSub.Iban_Number__c != null)
        {
            output.req.accountSub.field[8].value      = new String[1];
            output.req.accountSub.field[8].value[0]   = (accSub.Iban_Number__c != '') ? accSub.Iban_Number__c : '.';
        }
        output.req.accountSub.field[9]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
        output.req.accountSub.field[9].name       = 'iso';
        if (accSub.ISO_Certification__c != null)
        {
            output.req.accountSub.field[9].value      = new String[1];
            output.req.accountSub.field[9].value[0]   = (accSub.ISO_Certification__c != '') ? accSub.ISO_Certification__c : '.';
        }
        output.req.accountSub.field[10]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
        output.req.accountSub.field[10].name       = 'lastUpdateBy';
        output.req.accountSub.field[10].value      = new String[1];
        output.req.accountSub.field[10].value[0]   = UserInfo.getName();
        output.req.accountSub.field[11]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
        output.req.accountSub.field[11].name       = 'lastUpdateDate';
        output.req.accountSub.field[11].value      = new String[1];
        output.req.accountSub.field[11].value[0]   = accSub.LastModifiedDate.format('MM/dd/yyyy HH:mm');
        output.req.accountSub.field[12]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
        output.req.accountSub.field[12].name       = 'siret';
        if (accSub.Company_Registration_Number__c != null)
        {
            output.req.accountSub.field[12].value      = new String[1];
            output.req.accountSub.field[12].value[0]   = (accSub.Company_Registration_Number__c != '') ? accSub.Company_Registration_Number__c : '.';
        }
        output.req.accountSub.field[13]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
        output.req.accountSub.field[13].name       = 'tlrNumber';
        if (accSub.Teleroute_Number__c != null)
        {
            output.req.accountSub.field[13].value      = new String[1];
            output.req.accountSub.field[13].value[0]   = (accSub.Teleroute_Number__c != '') ? accSub.Teleroute_Number__c : '.';
        }
        output.req.accountSub.field[14]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
        output.req.accountSub.field[14].name       = 'trucksNumber';
        if (accSub.Number_of_trucks_owned__c != null)
        {
            output.req.accountSub.field[14].value      = new String[1];
            output.req.accountSub.field[14].value[0]   = accSub.Number_of_trucks_owned__c.format().replaceAll('[^0-9]', '');
        }
        output.req.accountSub.field[15]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
        output.req.accountSub.field[15].name       = 'id';
        output.req.accountSub.field[15].value      = new String[1];
        output.req.accountSub.field[15].value[0]   = accSub.Id;
        
        // TCD Published Status
        output.req.accountSub.field[16]            = new LibWKTSComCrmProvisioningV2.CRMProvisionningFieldType();
        output.req.accountSub.field[16].name       = 'TCDVisibility';
        output.req.accountSub.field[16].value      = new String[1];
        output.req.accountSub.field[16].value[0]   = accSub.TCD_Visibility__c;
        
        
        // Members
        output.req.members = new List<LibWKTSComCrmProvisioningV2.CRMProvisionningMemberType>();
        
        output.req.transactionId = generateTransactionId(sub.Provisioning__r[0].Id);
                
        output.status = true;
        return output;
    }
    
    private static LibSFDCToESBV2.SFToESBv2Export2_SFToESBv2HttpPort createWS()
    {  
        // Web Service to call
        LibSFDCToESBV2.SFToESBv2Export2_SFToESBv2HttpPort WS = new LibSFDCToESBV2.SFToESBv2Export2_SFToESBv2HttpPort();
        WS.timeout_x = 120000;
        WS.clientCertName_x = FXSettings__c.getValues('FXSettings').Proxy_ESB_Certificate__c;
        return WS;
    }
    
    private static LibWKTSComCrmProvisioningV2.CRMProvisionningResponseTypev2 callWS(LibSFDCToESBV2.SFToESBv2Export2_SFToESBv2HttpPort WS, LibWKTSComCrmProvisioningV2.CRMProvisionningObjectsTypev2 req)
    {
        System.Debug('Provisioning start');
        LibWKTSComCrmProvisioningV2.CRMProvisionningResponseTypev2 ret = WS.ProvisionningV2(req);
        ret.transactionId = req.transactionId;
        System.Debug('Provisioning return: ' + ret);
        return ret;
    }
    
    /* @Description : This method handles the response.
    */ 
    // Synchronous
    private static void handleResponse(LibWKTSComCrmProvisioningV2.CRMProvisionningResponseTypev2 ret, ProvisioningResult out, LibWKTSComCrmProvisioningV2.CRMProvisionningObjectsTypev2 req, String operation)
    {
        if (ret.status != 'Success')
        {
            out.status = false;
            out.error  = ret.status;
        }
        else
        {
            out.status = true;
            out.transactions = new List<Provisioning_Transaction__c>();
            
            Provisioning_Transaction__c transSub = new Provisioning_Transaction__c();
            transSub.Subscription__c  = req.subscription.subscriptionID;
            transSub.TransactionId__c = ret.transactionId;
            transSub.Type__c          = getTransactionType(operation);
            out.transactions.add(transSub);
            
            Provisioning_Transaction__c transAccSub = new Provisioning_Transaction__c();
            transAccSub.Subscription__c      = req.subscription.subscriptionID;
            transAccSub.Account__c       = req.subscription.parentID;
            transAccSub.TransactionId__c = ret.transactionId;
            transAccSub.Type__c          = getTransactionType(operation);
            out.transactions.add(transAccSub);
            
            for (LibWKTSComCrmProvisioningV2.CRMProvisionningMemberType member : req.members)
            {
                Provisioning_Transaction__c transAcc = new Provisioning_Transaction__c();
                transAcc.Subscription__c  = req.subscription.subscriptionID;
                transAcc.Account__c       = member.account.id;
                transAcc.TransactionId__c = ret.transactionId;
                transAcc.Type__c          = getTransactionType(operation);
                out.transactions.add(transAcc);
                
                for (WKTSComCrmProvisioningV2.CRMProvisioningContactType con : member.contact)
                {
                    Provisioning_Transaction__c transCon = new Provisioning_Transaction__c();
                    transCon.Subscription__c  = req.subscription.subscriptionID;
                    transCon.Account__c       = member.account.id;
                    transCon.Contact__c       = con.id;
                    transCon.TransactionId__c = ret.transactionId;
                    transCon.Type__c          = getTransactionType(operation);
                    out.transactions.add(transCon);
                }
            }
        }
    }
    
    private static String getTransactionType(String operation)
    {
        if (operation == 'Provision')
            return ('Provisioning');
        else if (operation == 'Update')
            return ('Update');
        else if (operation == 'SuspendAll')
            return ('Suspension');
        else if (operation == 'Standard')
            return ('Update');
        else
            return ('Cancellation');
    }
}