global class ScheduleBAServiceAttribute implements Schedulable
{
    global void execute(SchedulableContext SC)
    {
        BAServiceAttribute BAsat = new BAServiceAttribute();
        database.executebatch(BAsat);
    } 
}