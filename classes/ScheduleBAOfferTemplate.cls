global class ScheduleBAOfferTemplate implements Schedulable
{
    global void execute(SchedulableContext SC)
    {
        BAOfferTemplate BAot = new BAOfferTemplate();
        database.executebatch(BAot);
    } 
}