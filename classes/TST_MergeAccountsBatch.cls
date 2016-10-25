@isTest
private class TST_MergeAccountsBatch {

    private static Integer NUMBER_OF_RELATED_RECORDS = 5;

    private static User testUser;
    
    private static Id conRT_TLR = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByName().get('TLR Contact').getRecordTypeId();
    private static Id conRT_TWD = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByName().get('TWD Contact').getRecordTypeId();

    private static Account masterTLR;
    private static Account masterTWA;
    private static Account dupTLR;
    private static Account dupTWA;
    
    private static Account parentToMasterTLR;
    private static Account parentToMasterTWA;
    private static Account parentToDupTLR;
    private static Account parentToDupTWA;    

    private static Account[] childrenToMasterTLR;
    private static Account[] childrenToDupTLR;
    private static Account[] childrenToMasterTWA;
    private static Account[] childrenToDupTWA;

    private static Contact[] contactsRelatedToMasterTLR;
    private static Contact[] contactsRelatedToMasterTWA;

    private static void init(Boolean createContacts, String hierarchyType, Boolean masterHasParent, Boolean masterHasChildren, Boolean dupHasParent, Boolean dupHasChildren) 
    {
    	TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        if(hierarchyType == 'TLR') {
            masterTLR = TST_AccountTestHelper.createDummyAccount(true);   
            dupTLR = TST_AccountTestHelper.createDummyAccount();
            dupTLR.Dedup_Account__c = masterTLR.Id;
            insert dupTLR;

            if(createContacts) {
                contactsRelatedToMasterTLR = TST_ContactTestHelper.createDummyContactList(dupTLR, NUMBER_OF_RELATED_RECORDS, conRT_TLR, true);
            }

            if(masterHasParent) {
                parentToMasterTLR = TST_AccountTestHelper.createDummyAccount(true); 
                masterTLR.ParentId = parentToMasterTLR.Id;
                update masterTLR;
            }

            if(masterHasChildren) {
                childrenToMasterTLR = TST_AccountTestHelper.createDummyAccountList(NUMBER_OF_RELATED_RECORDS); 
                for(Account child : childrenToMasterTLR) {
                    child.ParentId = masterTLR.Id;
                }
                insert childrenToMasterTLR;
            }

            if(dupHasParent) {
                parentToDupTLR = TST_AccountTestHelper.createDummyAccount(true); 
                dupTLR.ParentId = parentToDupTLR.Id;
                update dupTLR;
            }

            if(dupHasChildren) {
                childrenToDupTLR = TST_AccountTestHelper.createDummyAccountList(NUMBER_OF_RELATED_RECORDS); 
                for(Account child : childrenToDupTLR) {
                    child.ParentId = dupTLR.Id;
                }
                insert childrenToDupTLR;
            }  
        }
        else if(hierarchyType == 'TWA') {
            masterTWA = TST_AccountTestHelper.createDummyAccount(true);   
            dupTWA = TST_AccountTestHelper.createDummyAccount();
            dupTWA.Dedup_Account__c = masterTWA.Id;
            insert dupTWA;

            if(createContacts) {
                contactsRelatedToMasterTWA = TST_ContactTestHelper.createDummyContactList(dupTWA, NUMBER_OF_RELATED_RECORDS, conRT_TWD, true);                      
            }

            if(masterHasParent) {
                parentTomasterTWA = TST_AccountTestHelper.createDummyAccount(true); 
                masterTWA.Parent_TWA__c = parentTomasterTWA.Id;
                update masterTWA;
            }

            if(masterHasChildren) {
                childrenToMasterTWA = TST_AccountTestHelper.createDummyAccountList(NUMBER_OF_RELATED_RECORDS); 
                for(Account child : childrenToMasterTWA) {
                    child.Parent_TWA__c = masterTWA.Id;
                }
                insert childrenToMasterTWA;
            }

            if(dupHasParent) {
                parentToDupTWA = TST_AccountTestHelper.createDummyAccount(true); 
                dupTWA.Parent_TWA__c = parentToDupTWA.Id;
                update dupTWA;
            }

            if(dupHasChildren) {
                childrenTodupTWA = TST_AccountTestHelper.createDummyAccountList(NUMBER_OF_RELATED_RECORDS); 
                for(Account child : childrenTodupTWA) {
                    child.Parent_TWA__c = dupTWA.Id;
                }
                insert childrenTodupTWA;
            } 
        }
    }   

    public static User createTestUser() {
        Profile p = [Select Id, Name from Profile where Name = 'System Administrator' limit 1];
        User adminUser = new User();
        adminUser.Email = 'test@test.com';
        adminUser.Username = 'adminUser123@adminUser.test';
        adminUser.LastName = 'test';
        adminUser.Alias = 'test';
        adminUser.ProfileId = p.Id;
        adminUser.LanguageLocaleKey = 'en_US';
        adminUser.LocaleSidKey = 'en_US';
        adminUser.TimeZoneSidKey = 'America/Chicago';
        adminUser.EmailEncodingKey = 'UTF-8';
        adminUser.Disable_Validation_Rules_and_Workflows__c = true;
        //adminUser.Disable_All_Triggers__c = true; //temporarily commented out because flag doesn't exist yet on prod       
        insert adminUser;
        return adminUser;
    }         

/**********************************/
//TLR
/**********************************/
    @isTest static void TLR_MasterHasParent() {
        testUser = createTestUser();
        init(true, 'TLR', true, false, false, false);

        System.assertEquals(0, [Select count() from Contact where AccountId = :masterTLR.Id]);
        
        Test.startTest();
            System.runAs(testUser) {
                Database.executeBatch(new MergeAccountsBatch(new Account[]{dupTLR}, true),1);
            }
        Test.stopTest();

        System.assertEquals(NUMBER_OF_RELATED_RECORDS, [Select count() from Contact where AccountId = :masterTLR.Id]);
    }

    @isTest static void TLR_MasterHasChildren() {
        testUser = createTestUser();
        init(true, 'TLR', false, true, false, false);

        System.assertEquals(0, [Select count() from Contact where AccountId = :masterTLR.Id]);
        
        Test.startTest();
            System.runAs(testUser) {
                Database.executeBatch(new MergeAccountsBatch(new Account[]{dupTLR}, true),1);
            }
        Test.stopTest();

        System.assertEquals(NUMBER_OF_RELATED_RECORDS, [Select count() from Contact where AccountId = :masterTLR.Id]);
    }

    @isTest static void TLR_MasterHasParentAndChildren() {
        testUser = createTestUser();
        init(true, 'TLR', true, true, false, false);

        System.assertEquals(0, [Select count() from Contact where AccountId = :masterTLR.Id]);
        
        Test.startTest();
            System.runAs(testUser) {
                Database.executeBatch(new MergeAccountsBatch(new Account[]{dupTLR}, true),1);
            }
        Test.stopTest();

        System.assertEquals(NUMBER_OF_RELATED_RECORDS, [Select count() from Contact where AccountId = :masterTLR.Id]);
    }

    @isTest static void TLR_DupHasParent() {
        testUser = createTestUser();
        init(true, 'TLR', false, false, true, false);

        System.assertEquals(0, [Select count() from Contact where AccountId = :masterTLR.Id]);
        System.assertEquals(null, [Select ParentId from Account where Id = :masterTLR.Id][0].ParentId);

        Test.startTest();
            System.runAs(testUser) {
                Database.executeBatch(new MergeAccountsBatch(new Account[]{dupTLR}, true),1);
            }
        Test.stopTest();

        System.assertEquals(NUMBER_OF_RELATED_RECORDS, [Select count() from Contact where AccountId = :masterTLR.Id]);
        System.assertEquals(dupTLR.ParentId, [Select ParentId from Account where Id = :masterTLR.Id][0].ParentId);
    }   

    @isTest static void TLR_DupHasChildren() {
        testUser = createTestUser();
        init(true, 'TLR', false, false, false, true);

        System.assertEquals(0, [Select count() from Contact where AccountId = :masterTLR.Id]);
        System.assertEquals(0, [Select count() from Account where ParentId = :masterTLR.Id]);

        Test.startTest();
            System.runAs(testUser) {
                Database.executeBatch(new MergeAccountsBatch(new Account[]{dupTLR}, true),1);
            }
        Test.stopTest();

        System.assertEquals(NUMBER_OF_RELATED_RECORDS, [Select count() from Contact where AccountId = :masterTLR.Id]);
        System.assertEquals(NUMBER_OF_RELATED_RECORDS, [Select count() from Account where ParentId = :masterTLR.Id]);
    }

    @isTest static void TLR_DupHasParentAndChildren() {
        testUser = createTestUser();
        init(true, 'TLR', false, false, true, true);

        System.assertEquals(0, [Select count() from Contact where AccountId = :masterTLR.Id]);
        System.assertEquals(null, [Select ParentId from Account where Id = :masterTLR.Id][0].ParentId);
        System.assertEquals(0, [Select count() from Account where ParentId = :masterTLR.Id]);

        Test.startTest();
            System.runAs(testUser) {
                Database.executeBatch(new MergeAccountsBatch(new Account[]{dupTLR}, true),1);
            }
        Test.stopTest();

        System.assertEquals(NUMBER_OF_RELATED_RECORDS, [Select count() from Contact where AccountId = :masterTLR.Id]);
        System.assertEquals(NUMBER_OF_RELATED_RECORDS, [Select count() from Account where ParentId = :masterTLR.Id]);
        System.assertEquals(dupTLR.ParentId, [Select ParentId from Account where Id = :masterTLR.Id][0].ParentId);
    }

    @isTest static void TLR_BothHaveNoParentAndNoChildren() {
        testUser = createTestUser();
        init(true, 'TLR', false, false, false, false);

        System.assertEquals(0, [Select count() from Contact where AccountId = :masterTLR.Id]);

        Test.startTest();
            System.runAs(testUser) {
                Database.executeBatch(new MergeAccountsBatch(new Account[]{dupTLR}, true),1);
            }
        Test.stopTest();

        System.assertEquals(NUMBER_OF_RELATED_RECORDS, [Select count() from Contact where AccountId = :masterTLR.Id]);
    }

/**********************************/
//TWA
/**********************************/

    @isTest static void TWA_MasterHasParent() {
        testUser = createTestUser();
        init(true, 'TWA', true, false, false, false);

        System.assertEquals(0, [Select count() from Contact where AccountId = :masterTWA.Id]);
        
        Test.startTest();
            System.runAs(testUser) {
                Database.executeBatch(new MergeAccountsBatch(new Account[]{dupTWA}, true),1);
            }
        Test.stopTest();

        System.assertEquals(NUMBER_OF_RELATED_RECORDS, [Select count() from Contact where AccountId = :masterTWA.Id]);
    }

    @isTest static void TWA_MasterHasChildren() {
        testUser = createTestUser();
        init(true, 'TWA', false, true, false, false);

        System.assertEquals(0, [Select count() from Contact where AccountId = :masterTWA.Id]);
        
        Test.startTest();
            System.runAs(testUser) {
                Database.executeBatch(new MergeAccountsBatch(new Account[]{dupTWA}, true),1);
            }
        Test.stopTest();

        System.assertEquals(NUMBER_OF_RELATED_RECORDS, [Select count() from Contact where AccountId = :masterTWA.Id]);
    }

    @isTest static void TWA_MasterHasParentAndChildren() {
        testUser = createTestUser();
        init(true, 'TWA', true, true, false, false);

        System.assertEquals(0, [Select count() from Contact where AccountId = :masterTWA.Id]);
        
        Test.startTest();
            System.runAs(testUser) {
                Database.executeBatch(new MergeAccountsBatch(new Account[]{dupTWA}, true),1);
            }
        Test.stopTest();

        System.assertEquals(NUMBER_OF_RELATED_RECORDS, [Select count() from Contact where AccountId = :masterTWA.Id]);
    }

    @isTest static void TWA_DupHasParent() {
        testUser = createTestUser();
        init(true, 'TWA', false, false, true, false);

        System.assertEquals(0, [Select count() from Contact where AccountId = :masterTWA.Id]);
        System.assertEquals(null, [Select Parent_TWA__c from Account where Id = :masterTWA.Id][0].Parent_TWA__c);

        Test.startTest();
            System.runAs(testUser) {
                Database.executeBatch(new MergeAccountsBatch(new Account[]{dupTWA}, true),1);
            }
        Test.stopTest();

        System.assertEquals(NUMBER_OF_RELATED_RECORDS, [Select count() from Contact where AccountId = :masterTWA.Id]);
        System.assertEquals(dupTWA.Parent_TWA__c, [Select Parent_TWA__c from Account where Id = :masterTWA.Id][0].Parent_TWA__c);
    }   

    @isTest static void TWA_DupHasChildren() {
        testUser = createTestUser();
        init(true, 'TWA', false, false, false, true);

        System.assertEquals(0, [Select count() from Contact where AccountId = :masterTWA.Id]);
        System.assertEquals(0, [Select count() from Account where Parent_TWA__c = :masterTWA.Id]);

        Test.startTest();
            System.runAs(testUser) {
                Database.executeBatch(new MergeAccountsBatch(new Account[]{dupTWA}, true),1);
            }
        Test.stopTest();

        System.assertEquals(NUMBER_OF_RELATED_RECORDS, [Select count() from Contact where AccountId = :masterTWA.Id]);
        System.assertEquals(NUMBER_OF_RELATED_RECORDS, [Select count() from Account where Parent_TWA__c = :masterTWA.Id]);
    }

    @isTest static void TWA_DupHasParentAndChildren() {
        testUser = createTestUser();
        init(true, 'TWA', false, false, true, true);

        System.assertEquals(0, [Select count() from Contact where AccountId = :masterTWA.Id]);
        System.assertEquals(null, [Select Parent_TWA__c from Account where Id = :masterTWA.Id][0].Parent_TWA__c);
        System.assertEquals(0, [Select count() from Account where Parent_TWA__c = :masterTWA.Id]);

        Test.startTest();
            System.runAs(testUser) {
                Database.executeBatch(new MergeAccountsBatch(new Account[]{dupTWA}, true),1);
            }
        Test.stopTest();

        System.assertEquals(NUMBER_OF_RELATED_RECORDS, [Select count() from Contact where AccountId = :masterTWA.Id]);
        System.assertEquals(NUMBER_OF_RELATED_RECORDS, [Select count() from Account where Parent_TWA__c = :masterTWA.Id]);
        System.assertEquals(dupTWA.Parent_TWA__c, [Select Parent_TWA__c from Account where Id = :masterTWA.Id][0].Parent_TWA__c);
    }

    @isTest static void TWA_BothHaveNoParentAndNoChildren() {
        testUser = createTestUser();
        init(true, 'TWA', false, false, false, false);

        System.assertEquals(0, [Select count() from Contact where AccountId = :masterTWA.Id]);

        Test.startTest();
            System.runAs(testUser) {
                Database.executeBatch(new MergeAccountsBatch(new Account[]{dupTWA}, true),1);
            }
        Test.stopTest();

        System.assertEquals(NUMBER_OF_RELATED_RECORDS, [Select count() from Contact where AccountId = :masterTWA.Id]);
    }

//this code depends on a randomly chosen validation rule Control_Percent_Groupage
//the Account got saved without the above VR active and the merge occured with the active rule
/* temporarily commented out because disable_all_triggers flag doesn't exist yet on prod
    @isTest static void TWA_GenerateCustomValidationExceptionAndWriteToLog() {
        testUser = createTestUser();

        System.runAs(testUser) {
            init(true, 'TWA', false, false, false, false);
            masterTWA.precent_groupage__c  = 200;
            update masterTWA;
        }

        testUser.Disable_Validation_Rules_and_Workflows__c = false;
        update testUser;

        System.assertEquals(0, [Select count() from temp_batch_log__c]);

        System.runAs(testUser) {
            Test.startTest();
                Database.executeBatch(new MergeAccountsBatch(new Account[]{dupTWA}),1);
            Test.stopTest();
        }

        temp_batch_log__c errorLog = [Select DmlFieldNames__c, DmlMessage__c, DmlStatusCode__c from temp_batch_log__c limit 1];
        System.assertEquals('(precent_groupage__c)', errorLog.DmlFieldNames__c);
        System.assertEquals('The value should be between 0-100%', errorLog.DmlMessage__c);
        System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION', errorLog.DmlStatusCode__c);
    }
*/    

}