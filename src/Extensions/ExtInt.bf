using System;

namespace System
{
	extension Int8
	{
	}

	extension Int32
	{
	}

	extension Float
	{
		/*
		public static implicit operator int32(ref System.Float val)
		{
			return *(int32*)&val;
		}
		*/

		public static implicit operator int(in Self self)
		{
			return 0;
		}
	}

	extension Int
	{
	}

	extension Boolean
	{
		public static implicit operator int(Self self)
		{
			return self == true ? 1 : 0;
		}
	}
}

