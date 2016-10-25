@isTest
public class TipTest 
{
	public static testMethod void testTipTest()
	{
		Integer ret = Tip.addition(0);
		ret = Tip.addition2(ret);
		ret = Tip.addition3(ret);
		ret = Tip.addition5(ret);
		ret = Tip.addition6(ret);
		ret = Tip.addition7(ret);
		ret = Tip.addition8(ret);
		ret = Tip.addition9(ret);
		ret = Tip.addition10(ret);
		ret = Tip.addition11(ret);
		ret = Tip.addition12(ret);
		
		System.Assert(ret >= 0);
	}
}