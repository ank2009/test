/**
* @author Nicolas Dolet
* @date 29/11/2011
* @description Filtering utilities class for LinkUsersInSubExt class
*/
public with sharing class FilteringUtilsLinkUsers {
    
    /**
     * Manipulated object
     */
    LinkUsersInSubExt luise;
    
    /**
     * Internal variables for filter management
     */
    private Boolean isAccNameSetByUser, isAccNbSetByUser, isTLRNbSetByUser,
            isDebtorNbSetByUser, isCountrySetByUser, isCitySetByUser;

    /**
     * Constructor
     */
    public FilteringUtilsLinkUsers(LinkUsersInSubExt sa) {
        luise = sa;
        
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
        luise.availableContacts.clear();
                
        for (LinkUsersInSubExt.WrapperContact upw : luise.contactList) {
              if(isToDisplay(upw))
                luise.availableContacts.add(upw);
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
    private Boolean isToDisplay(LinkUsersInSubExt.WrapperContact upw) {
        // Prepare all unit checks
        Boolean accountNameMatch, accountNumberMatch, tlrNumberMatch,
                dnMatch, billingCtrMatch, billingCityMatch;

        // Perform unit checks
        if(luise.accountOp == 'None')
            accountNameMatch = true;
        else
            accountNameMatch = luise.accountOp == upw.con.Account.Name;
        if(luise.accountNbOp == 'None')
            accountNumberMatch = true;
        else
            accountNumberMatch = luise.accountNbOp == upw.con.Account.AccountNumber;
        if(luise.tlrNbOp == 'None')
            tlrNumberMatch = true;
        else
            tlrNumberMatch = luise.tlrNbOp == upw.con.Account.Teleroute_Number__c;
        if(luise.debtorNumberOp == 'None')
            dnMatch = true;
        else
            dnMatch = luise.debtorNumberOp == upw.con.Account.Debtor_Number__c;
        if(luise.billingCountriesOp == 'None')
            billingCtrMatch = true;
        else
            billingCtrMatch = luise.billingCountriesOp == upw.con.Account.BillingCountry;
        if(luise.cityOp == 'None')
            billingCityMatch = true;
        else
            billingCityMatch = luise.cityOp == upw.con.Account.BillingCity;
        
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
            for(LinkUsersInSubExt.WrapperContact upw : luise.availableContacts) {
                allValues.add(upw.con.Account.Name);
            }
        }
        if(apiName == Account.AccountNumber.getDescribe().getName()) {
            for(LinkUsersInSubExt.WrapperContact upw : luise.availableContacts) {
                allValues.add(upw.con.Account.AccountNumber);
            }
        }
        if(apiName == Account.Teleroute_Number__c.getDescribe().getName()) {
            for(LinkUsersInSubExt.WrapperContact upw : luise.availableContacts) {
                allValues.add(upw.con.Account.Teleroute_Number__c);
            }
        }

        if(apiName == Account.Debtor_Number__c.getDescribe().getName()) {
            for(LinkUsersInSubExt.WrapperContact upw : luise.availableContacts) {
                allValues.add(upw.con.Account.Debtor_Number__c);
            }
        }
    
        if(apiName == Account.BillingCountry.getDescribe().getName()) {
            for(LinkUsersInSubExt.WrapperContact upw : luise.availableContacts) {
                allValues.add(upw.con.Account.BillingCountry);
            }
        }

        if(apiName == Account.BillingCity.getDescribe().getName()) {
            for(LinkUsersInSubExt.WrapperContact upw : luise.availableContacts) {
                allValues.add(upw.con.Account.BillingCity);
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
            
        if(!isAccNameSetByUser || isAccNameSetByUser && luise.accountOp == 'None')
            refreshPicklist(luise.accountOptions, Account.Name.getDescribe().getName());
        if(!isAccNbSetByUser || isAccNbSetByUser && luise.accountNbOp == 'None')
            refreshPicklist(luise.accountNbOptions, Account.AccountNumber.getDescribe().getName());
        if(!isTLRNbSetByUser || isTLRNbSetByUser && luise.tlrNbOp == 'None')
            refreshPicklist(luise.tlrNbOptions, Account.Teleroute_Number__c.getDescribe().getName());
        if(!isDebtorNbSetByUser || isDebtorNbSetByUser && luise.debtorNumberOp == 'None')
            refreshPicklist(luise.dnOptions, Account.Debtor_Number__c.getDescribe().getName());
        if(!isCountrySetByUser || isCountrySetByUser && luise.billingCountriesOp == 'None')
            refreshPicklist(luise.bilCtrOptions, Account.BillingCountry.getDescribe().getName());
        if(!isCitySetByUser || isCitySetByUser && luise.cityOp == 'None')
            refreshPicklist(luise.cityOptions, Account.BillingCity.getDescribe().getName());

    }

}