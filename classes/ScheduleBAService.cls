global class ScheduleBAService implements Schedulable
{
    global void execute(SchedulableContext SC)
    {
        BAService BAserv = new BAService();
        database.executebatch(BAserv);
    } 
}