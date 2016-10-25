global class ScheduleBAPackageAndFee implements Schedulable
{
    global void execute(SchedulableContext SC)
    {
        BAPackageAndFee BApf = new BAPackageAndFee();
        database.executebatch(BApf);
    } 
}