/*
* @author       Anton Solovyev (anton_soloveyv@epam.com)
* @date         2013 June 31
* @description  class with static methods to call all the trigger helpers
**/
public class TRIG_TriggerHandlerInvoker 
{
    //private static final boolean DEFAULT_SKIP_TRIGGERS_VALUE = false;
    private static boolean First_Invoke = true;
    private static boolean SKIP_TRIGGERS_VALUE = false;
    /**
    * Evaluate global trigger execution.
    */
    public static boolean skipTriggerInvocation 
    {
       get
        {
            System.Debug('----------First_Invoke' + First_Invoke + '------SKIP_TRIGGERS_VALUE -----' + SKIP_TRIGGERS_VALUE );
            if(First_Invoke)
            {
                User user = [Select Disable_All_Triggers__c From User where id =: Userinfo.getUserId()  Limit 1];
                SKIP_TRIGGERS_VALUE = user.Disable_All_Triggers__c; //General_Settings__c.getInstance().Skip_Triggers__c;
                First_Invoke = false;
                return SKIP_TRIGGERS_VALUE;
            }
            // consider the global 'skipTriggers' flag only in real executions (and do NOT if invoked from unit tests)
            // return ! Test.isRunningTest() && result;  
            return SKIP_TRIGGERS_VALUE;  // I don't know why we might want to skip tests so I am not including that condition here.
            
        }
    }

    /**
    * Invoke the trigger handler according to the trigger type.
    * Trigger.old => oldValues
    * Trigger.new => newValues
    * Trigger.oldMap => oldValuesMap
    * Trigger.newMap => newValuesMap
    */
    public static void invoke(TRIG_TriggerHandlerInterface handler)
    {
        if (Trigger.isBefore && Trigger.isInsert)       { handler.OnBeforeInsert(Trigger.new);                                              }
        else if (Trigger.isAfter  && Trigger.isInsert)  { handler.OnAfterInsert(Trigger.new, Trigger.newMap);                               }
        else if (Trigger.isBefore && Trigger.isUpdate)  { handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap); }
        else if (Trigger.isAfter  && Trigger.isUpdate)  { handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);  }
        else if (Trigger.isBefore && Trigger.isDelete)  { handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);                              }
        else if (Trigger.isAfter  && Trigger.isDelete)  { handler.OnAfterDelete(Trigger.old, Trigger.oldMap);                               }
        else if (Trigger.isUndelete                  )  { handler.OnAfterUndelete(Trigger.old, Trigger.oldMap);                             }
    }
}