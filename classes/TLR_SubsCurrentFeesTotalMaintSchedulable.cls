/** 
* @author       Anton Solovyev (anton_soloveyv@epam.com)
* @date         2013 September 17
* @description  Schedulable for TLR_SubsCurrentFeesTotalMaintBatchable
*/
public class TLR_SubsCurrentFeesTotalMaintSchedulable implements Schedulable
{
	public void execute(SchedulableContext sc)
	{
		TLR_SubsCurrentFeesTotalMaintBatchable batch = new TLR_SubsCurrentFeesTotalMaintBatchable();
		Database.executeBatch(batch);
	}
}