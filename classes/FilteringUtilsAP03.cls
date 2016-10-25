/**
* @author Nicolas Dolet
* @date 29/11/2011
* @description Filtering utilities class for CtrlAP03SuspendAccount class
*/
public with sharing class FilteringUtilsAP03 {
    
    /**
     * Manipulated object
     */
    CtrlAP03SuspendAccount saCtrl;
    
    /**
     * Internal variables for filter management
     */
    private Boolean isAccNameSetByUser, isAccNbSetByUser, isTLRNbSetByUser,
            isDebtorNbSetByUser, isCountrySetByUser, isCitySetByUser;

    /**
     * Constructor
     */
    public FilteringUtilsAP03(CtrlAP03SuspendAccount sa) {
        saCtrl = sa;
        
        isAccNameSetByUser = false; isAccNbSetByUser = false;
        isTLRNbSetByUser = false; isDebtorNbSetByUser = false;
        isCountrySetByUser = false; isCitySetByUser = false;
    }
    
    /**
     * @author Nicolas Dolet
     * @date 01/12/2011
     * @description Update the contact list according to the
     *              selected Account Name
     */
    public void applyFilterAccName() {
        isAccNameSetByUser = true;
        isAccNbSetByUser = false; 
        isTLRNbSetByUser = false;
        isDebtorNbSetByUser = false;
        isCountrySetByUser = false;
        isCitySetByUser = false;
        applyFilter();
    }

    /**
     * @author Nicolas Dolet
     * @date 01/12/2011
     * @description Update the contact list according to the
     *              selected Account Number
     */
    public void applyFilterAccNumber() {
        isAccNameSetByUser = false;
        isAccNbSetByUser = true; 
        isTLRNbSetByUser = false;
        isDebtorNbSetByUser = false;
        isCountrySetByUser = false;
        isCitySetByUser = false;
        applyFilter();
    }

    /**
     * @author Nicolas Dolet
     * @date 01/12/2011
     * @description Update the contact list according to the
     *              selected Teleroute Number
     */
    public void applyFilterTlrNumber() {
        isAccNameSetByUser = false;
        isAccNbSetByUser = false; 
        isTLRNbSetByUser = true;
        isDebtorNbSetByUser = false;
        isCountrySetByUser = false;
        isCitySetByUser = false;
        applyFilter();
    }

    /**
     * @author Nicolas Dolet
     * @date 01/12/2011
     * @description Update the contact list according to the
     *              selected Debtor Number
     */
    public void applyFilterDebtorNumber() {
        isAccNameSetByUser = false;
        isAccNbSetByUser = false; 
        isTLRNbSetByUser = false;
        isDebtorNbSetByUser = true;
        isCountrySetByUser = false;
        isCitySetByUser = false;
        applyFilter();
    }

    /**
     * @author Nicolas Dolet
     * @date 01/12/2011
     * @description Update the contact list according to the
     *              selected Billing Country
     */
    public void applyFilterCountry() {
        isAccNameSetByUser = false;
        isAccNbSetByUser = false; 
        isTLRNbSetByUser = false;
        isDebtorNbSetByUser = false;
        isCountrySetByUser = true;
        isCitySetByUser = false;
        applyFilter();
    }

    /**
     * @author Nicolas Dolet
     * @date 01/12/2011
     * @description Update the contact list according to the
     *              selected Billing City
     */
    public void applyFilterCity() {
        isAccNameSetByUser = false;
        isAccNbSetByUser = false; 
        isTLRNbSetByUser = false;
        isDebtorNbSetByUser = false;
        isCountrySetByUser = false;
        isCitySetByUser = true;
        applyFilter();
    }

    /**
     * @author Nicolas Dolet
     * @date 01/12/2011
     * @description Update the contact list according to the
     *              selected items of filter
     */
    private void applyFilter() {
        saCtrl.contacts.clear();
                
        for (CtrlAP03SuspendAccount.UserProfileWrapper upw : saCtrl.availableContacts) {
              if(isToDisplay(upw))
                saCtrl.contacts.add(upw);
        }
                
        refreshPicklists();
    }

    /**
     * @author Nicolas Dolet
     * @date 01/12/2011
     * @description Check if a contact is to be displayed according to the
     *              filter values
     * @param cont The contact to check
     * @return True if the contact is to be displayed, else false.
     */
    private Boolean isToDisplay(CtrlAP03SuspendAccount.UserProfileWrapper upw) {
        // Prepare all unit checks
        Boolean accountNameMatch, accountNumberMatch, tlrNumberMatch,
                dnMatch, billingCtrMatch, billingCityMatch;

        // Perform unit checks
        if(saCtrl.accountOp == 'None')
            accountNameMatch = true;
        else
            accountNameMatch = saCtrl.accountOp == upw.up.Contact__r.Account.Name;
        if(saCtrl.accountNbOp == 'None')
            accountNumberMatch = true;
        else
            accountNumberMatch = saCtrl.accountNbOp == upw.up.Contact__r.Account.AccountNumber;
        if(saCtrl.tlrNbOp == 'None')
            tlrNumberMatch = true;
        else
            tlrNumberMatch = saCtrl.tlrNbOp == upw.up.Contact__r.Account.Teleroute_Number__c;
        if(saCtrl.debtorNumberOp == 'None')
            dnMatch = true;
        else
            dnMatch = saCtrl.debtorNumberOp == upw.up.Contact__r.Account.Debtor_Number__c;
        if(saCtrl.billingCountriesOp == 'None')
            billingCtrMatch = true;
        else
            billingCtrMatch = saCtrl.billingCountriesOp == upw.up.Contact__r.Account.BillingCountry;
        if(saCtrl.cityOp == 'None')
            billingCityMatch = true;
        else
            billingCityMatch = saCtrl.cityOp == upw.up.Contact__r.Account.BillingCity;
        
        // Result is the conjonction of unit checks
        return accountNameMatch && accountNumberMatch && tlrNumberMatch &&
                dnMatch && billingCtrMatch && billingCityMatch;
    }
    
    /**
     * @author Nicolas Dolet
     * @date 03/12/2011
     * @description Refresh a picklist on the page
     * @param pl The picklist to refresh
     * @param apiName The API name of field related to pl
     */
    private void refreshPicklist(List<SelectOption> pl, String apiName) {

    
        // Prepare data before refresh
        Set<String> allValues = new Set<String>();

        if(apiName == Account.Name.getDescribe().getName()) {
            for(CtrlAP03SuspendAccount.UserProfileWrapper upw : saCtrl.contacts) {
                allValues.add(upw.up.Contact__r.Account.Name);
            }
        }
        if(apiName == Account.AccountNumber.getDescribe().getName()) {
            for(CtrlAP03SuspendAccount.UserProfileWrapper upw : saCtrl.contacts) {
                allValues.add(upw.up.Contact__r.Account.AccountNumber);
            }
        }
        if(apiName == Account.Teleroute_Number__c.getDescribe().getName()) {
            for(CtrlAP03SuspendAccount.UserProfileWrapper upw : saCtrl.contacts) {
                allValues.add(upw.up.Contact__r.Account.Teleroute_Number__c);
            }
        }

        if(apiName == Account.Debtor_Number__c.getDescribe().getName()) {
            for(CtrlAP03SuspendAccount.UserProfileWrapper upw : saCtrl.contacts) {
                allValues.add(upw.up.Contact__r.Account.Debtor_Number__c);
            }
        }
    
        if(apiName == Account.BillingCountry.getDescribe().getName()) {
            for(CtrlAP03SuspendAccount.UserProfileWrapper upw : saCtrl.contacts) {
                allValues.add(upw.up.Contact__r.Account.BillingCountry);
            }
        }

        if(apiName == Account.BillingCity.getDescribe().getName()) {
            for(CtrlAP03SuspendAccount.UserProfileWrapper upw : saCtrl.contacts) {
                allValues.add(upw.up.Contact__r.Account.BillingCity);
            }
        }
        
        // Perform the refresh
        for(SelectOption so : pl) {
            if(so.getValue() != 'None')
                so.setDisabled(true);
            if(allValues.contains(so.getValue()))
                so.setDisabled(false);
        }
    }
    
    /**
     * @author Nicolas Dolet
     * @date 01/12/2011
     * @description Disable/Enable respectively irrelevant/relevant values in picklists
     */
    private void refreshPicklists() {            
            
        if(!isAccNameSetByUser || isAccNameSetByUser && saCtrl.accountOp == 'None')
            refreshPicklist(saCtrl.accountOptions, Account.Name.getDescribe().getName());
        if(!isAccNbSetByUser || isAccNbSetByUser && saCtrl.accountNbOp == 'None')
            refreshPicklist(saCtrl.accountNbOptions, Account.AccountNumber.getDescribe().getName());
        if(!isTLRNbSetByUser || isTLRNbSetByUser && saCtrl.tlrNbOp == 'None')
            refreshPicklist(saCtrl.tlrNbOptions, Account.Teleroute_Number__c.getDescribe().getName());
        if(!isDebtorNbSetByUser || isDebtorNbSetByUser && saCtrl.debtorNumberOp == 'None')
            refreshPicklist(saCtrl.dnOptions, Account.Debtor_Number__c.getDescribe().getName());
        if(!isCountrySetByUser || isCountrySetByUser && saCtrl.billingCountriesOp == 'None')
            refreshPicklist(saCtrl.bilCtrOptions, Account.BillingCountry.getDescribe().getName());
        if(!isCitySetByUser || isCitySetByUser && saCtrl.cityOp == 'None')
            refreshPicklist(saCtrl.cityOptions, Account.BillingCity.getDescribe().getName());

    }

}