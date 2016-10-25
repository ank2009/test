public class MergeAccountsBatch implements Database.Batchable<sObject> {
	
	private Account[] accountsToMerge;
	private Boolean reparentDupToMaster = false;
	
	public MergeAccountsBatch(Account[] accountsToMerge) {
		this.accountsToMerge = accountsToMerge;
	}

	public MergeAccountsBatch(Account[] accountsToMerge, Boolean reparentDupToMaster) {
		this.accountsToMerge = accountsToMerge;
		this.reparentDupToMaster = reparentDupToMaster;
	}	
	
	public List<sObject> start(Database.BatchableContext BC) {
		return accountsToMerge;
	}

   	public void execute(Database.BatchableContext BC, List<sObject> scope) {
		mergeAccounts((Account[])scope);
	}
	
	public void finish(Database.BatchableContext BC) {
		
	}

	private void mergeAccounts(Account[] dupAccounts) {
		dupAccounts = [Select Id, ParentId, Parent_TWA__c, Dedup_Account__c from Account where Id in :dupAccounts];
		Map<Id,Account> dupAccountsMap = new Map<Id,Account>(dupAccounts);
		Map<Id,Id> dupToMasterMap = new Map<Id,Id>();

		for(Account dupAccount : dupAccounts) {
			if(dupAccount.Dedup_Account__c != null) {
				dupToMasterMap.put(dupAccount.Id, dupAccount.Dedup_Account__c);			
			}
		}

		Map<Id,Account> masterAccountsMap = new Map<Id,Account>([Select Id, ParentId, Parent_TWA__c from Account where Id in :dupToMasterMap.values()]);
		temp_batch_log__c[] logList = new temp_batch_log__c[]{};

        Account[] dupChildren = [Select Id, ParentId, Parent_TWA__c from Account where ParentId in :dupToMasterMap.keySet()];

        Map<Id,Account[]> dupToChildrenMap = new Map<Id,Account[]>();

        Set<Id> parentIds = new Set<Id>();
        for(Account child : dupChildren) {
        	parentIds.add(child.parentId);
        }
        
        for(Id parentId : new List<Id>(parentIds)) {
        	Account[] accountsToParent = new Account[]{};
	        for(Account child : dupChildren) {
	        	if(child.ParentId == parentId) {
	        		accountsToParent.add(child);
	        	}
	        }
        	dupToChildrenMap.put(parentId, accountsToParent);
	    }

		for(Id dupId : dupToMasterMap.keySet()) {
			Account masterAccount = masterAccountsMap.get(dupToMasterMap.get(dupId));
			Account dupAccount = dupAccountsMap.get(dupId);

			Account[] accountsToUpdate = new Account[]{};
			if(reparentDupToMaster) {
				Boolean updateMaster = false;
				if(masterAccount.ParentId == null && dupAccount.ParentId != null) {
					masterAccount.ParentId = dupAccount.ParentId;
					updateMaster = true;	            		
            	}

				if(masterAccount.Parent_TWA__c == null && dupAccount.Parent_TWA__c != null) {
					masterAccount.Parent_TWA__c = dupAccount.Parent_TWA__c;
					updateMaster = true;	            		
            	}
            	if(updateMaster) {
            		accountsToUpdate.add(masterAccount);
            	}

    	        Account[] currentDupChildren = dupToChildrenMap.get(dupId);
    	        if(currentDupChildren != null) {
        	        for(Account dupChild : currentDupChildren) {        	        	
        	        	if(dupChild.ParentId != null) {
        	        		dupChild.ParentId = dupToMasterMap.get(dupChild.ParentId);
        	        	}
        	        }
	            	accountsToUpdate.addAll(currentDupChildren);
	            }
        	}

			Savepoint sp = Database.setSavepoint();
			try {
				merge masterAccount dupAccount;
				if(accountsToUpdate.size() > 0) {
					update accountsToUpdate;
				}
			}
			catch(DmlException e) {
				Database.rollback(sp);

				for(Integer i=0; i<e.getNumDml(); i++) {
					temp_batch_log__c log = new temp_batch_log__c();
					log.DmlFieldNames__c = String.valueOf(e.getDmlFieldNames(i));
					log.DmlId__c = e.getDmlId(i);
					log.DmlMessage__c = e.getDmlMessage(i);
					log.DmlStatusCode__c = e.getDmlStatusCode(i);
					logList.add(log);
				}	
			}			
		}
		if(logList.size() > 0) {
	    	insert logList;
	    }
	}
	
}