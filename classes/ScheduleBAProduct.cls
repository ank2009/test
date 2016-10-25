global class ScheduleBAProduct implements Schedulable
{
    global void execute(SchedulableContext SC)
    {
        BAProduct BAprod = new BAProduct();
        database.executebatch(BAprod);
    } 
}