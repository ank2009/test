@isTest
public class Tip2Test 
{
	public static testMethod void testTip2Test()
	{
		Integer ret = Tip2.addition(0);
		ret = Tip2.addition2(ret);
		ret = Tip2.addition3(ret);
		ret = Tip2.addition5(ret);
		ret = Tip2.addition6(ret);
		ret = Tip2.addition7(ret);
		ret = Tip2.addition8(ret);
		ret = Tip2.addition9(ret);
		ret = Tip2.addition10(ret);
		ret = Tip2.addition11(ret);
		ret = Tip2.addition12(ret);
		
		System.Assert(ret >= 0);
	}
}