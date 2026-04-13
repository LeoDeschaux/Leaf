using System;

namespace RaylibBeef
{
	extension Color
	{
		public override void ToString(String strBuffer)
		{
			strBuffer.Append(scope $"Color r:{r},g:{g},b:{b},a:{a}");
		}

	}
}