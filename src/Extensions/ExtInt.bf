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
	}

	public extension Int
	{
		public static explicit operator Self(bool self)
		{
			return self == true ? 1 : 0;
		}
	}

	public extension Boolean
	{
		public static explicit operator int(Self self)
		{
			return self == true ? 1 : 0;
		}

		public int ToInt()
		{
			return this == true ? 1 : 0;
		}
	}
}

