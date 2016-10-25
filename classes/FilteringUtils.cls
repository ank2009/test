/**
* @author Nicolas Dolet
* @date 29/11/2011
* @description Filtering utilities class for ProvisioningUsrMgt class
*/
public with sharing class FilteringUtils {
    
    /**
     * Manipulated object
     */
    ProvisioningUserMgt pum;
    
    /**
     * Internal variables for filter management
     */
    private Boolean isAccNameSetByUser, isAccNbSetByUser, isTLRNbSetByUser,
            isDebtorNbSetByUser, isCountrySetByUser, isCitySetByUser;

    /**
     * Constructor
     */
    public FilteringUtils(ProvisioningUserMgt p) {
        pum = p;
        
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
        pum.displayedList.clear();
                
        for (ProvisioningUserMgt.WrapperSelectedContact c : pum.contactList) {
              if(isToDisplay(c))
                pum.displayedList.add(c);
        }
        
        pum.dataToDisplay = (pum.displayedList.size() > 0);
        
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
    private Boolean isToDisplay(ProvisioningUserMgt.WrapperSelectedContact cont) {
        // Prepare all unit checks
        Boolean accountNameMatch, accountNumberMatch, tlrNumberMatch,
                dnMatch, billingCtrMatch, billingCityMatch;

        // Perform unit checks
        if(pum.accountOp == 'None')
            accountNameMatch = true;
        else
            accountNameMatch = pum.accountOp == cont.con.Account.Name;
        if(pum.accountNbOp == 'None')
            accountNumberMatch = true;
        else
            accountNumberMatch = pum.accountNbOp == cont.con.Account.AccountNumber;
        if(pum.tlrNbOp == 'None')
            tlrNumberMatch = true;
        else
            tlrNumberMatch = pum.tlrNbOp == cont.con.Account.Teleroute_Number__c;
        if(pum.debtorNumberOp == 'None')
            dnMatch = true;
        else
            dnMatch = pum.debtorNumberOp == cont.con.Account.Debtor_Number__c;
        if(pum.billingCountriesOp == 'None')
            billingCtrMatch = true;
        else
            billingCtrMatch = pum.billingCountriesOp == cont.con.Account.BillingCountry;
        if(pum.cityOp == 'None')
            billingCityMatch = true;
        else
            billingCityMatch = pum.cityOp == cont.con.Account.BillingCity;
        
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
            for(ProvisioningUserMgt.WrapperSelectedContact c : pum.displayedList) {
                allValues.add(c.con.Account.Name);
            }
        }
        if(apiName == Account.AccountNumber.getDescribe().getName()) {
            for(ProvisioningUserMgt.WrapperSelectedContact c : pum.displayedList) {
                allValues.add(c.con.Account.AccountNumber);
            }
        }
        if(apiName == Account.Teleroute_Number__c.getDescribe().getName()) {
            for(ProvisioningUserMgt.WrapperSelectedContact c : pum.displayedList) {
                allValues.add(c.con.Account.Teleroute_Number__c);
            }
        }

        if(apiName == Account.Debtor_Number__c.getDescribe().getName()) {
            for(ProvisioningUserMgt.WrapperSelectedContact c : pum.displayedList) {
                allValues.add(c.con.Account.Debtor_Number__c);
            }
        }
    
        if(apiName == Account.BillingCountry.getDescribe().getName()) {
            for(ProvisioningUserMgt.WrapperSelectedContact c : pum.displayedList) {
                allValues.add(c.con.Account.BillingCountry);
            }
        }

        if(apiName == Account.BillingCity.getDescribe().getName()) {
            for(ProvisioningUserMgt.WrapperSelectedContact c : pum.displayedList) {
                allValues.add(c.con.Account.BillingCity);
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
            
        if(!isAccNameSetByUser || isAccNameSetByUser && pum.accountOp == 'None')
            refreshPicklist(pum.accountOptions, Account.Name.getDescribe().getName());
        if(!isAccNbSetByUser || isAccNbSetByUser && pum.accountNbOp == 'None')
            refreshPicklist(pum.accountNbOptions, Account.AccountNumber.getDescribe().getName());
        if(!isTLRNbSetByUser || isTLRNbSetByUser && pum.tlrNbOp == 'None')
            refreshPicklist(pum.tlrNbOptions, Account.Teleroute_Number__c.getDescribe().getName());
        if(!isDebtorNbSetByUser || isDebtorNbSetByUser && pum.debtorNumberOp == 'None')
            refreshPicklist(pum.dnOptions, Account.Debtor_Number__c.getDescribe().getName());
        if(!isCountrySetByUser || isCountrySetByUser && pum.billingCountriesOp == 'None')
            refreshPicklist(pum.bilCtrOptions, Account.BillingCountry.getDescribe().getName());
        if(!isCitySetByUser || isCitySetByUser && pum.cityOp == 'None')
            refreshPicklist(pum.cityOptions, Account.BillingCity.getDescribe().getName());

    }

}