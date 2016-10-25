/**
 * An apex page controller that exposes the site login functionality
 */
global with sharing class CommunitiesLoginController {

    global CommunitiesLoginController () {}
    
    // Code we will invoke on page load.
    global PageReference forwardToAuthPage() {
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        String displayType = System.currentPageReference().getParameters().get('display');
        String usingSSO = System.currentPageReference().getParameters().get('usingSSO'); // this is parameter should be receive by WKTSA side
        String myCommunityUrl = ApexPages.currentPage().getHeaders().get('Host');
        if(String.isNotEmpty(usingSSO))
        {
            return new PageReference('https://' + myCommunityUrl + '/customer'); // '/customer' - this is name of community
        }
        return Network.forwardToAuthPage(startUrl, displayType);
    }
}