namespace Leaf;

using System;
using System.Collections;

class MyTest
{
	[Test]
	public static void TestAPI()
	{
	    Test.Assert(true);
	}

	[Test]
	public static void TestTransaction()
	{
		int value = 123;
		Transaction t = new .();

		t.Add(&value, 456);
		Test.Assert(value == 1233);

		//t.Test();

		t.Apply();
		Test.Assert(value == 456);

		t.Revert();
		Test.Assert(value == 123);
	}
}