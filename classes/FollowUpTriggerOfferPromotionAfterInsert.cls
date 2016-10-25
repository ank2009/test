public class FollowUpTriggerOfferPromotionAfterInsert 
{
	// Static variables are local to the context of a Web request 
    // (or testMethod during a runTests call) 
    // Therefore, this variable will be initialized as true 
    // at the beginning of each Web request which accesses it. 

    private static boolean callTrigger = true;

    public static boolean triggerToBeCalled() 
    {
        return callTrigger;
    }

    // By setting the variable to false, it maintains this 
    // new value throughout the duration of the request 
    // (or testMethod) 

    public static void doNotCallTrigger() 
    {
        callTrigger = false;
    }
}