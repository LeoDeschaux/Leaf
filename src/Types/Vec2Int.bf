using System;
using System.Interop;

namespace Leaf;

public struct Vec2Int : System.IHashable
{
	public int x;
	public int y;
	
	public this(int x, int y)
	{
		this.x = x;
		this.y = y;
	}

	public int GetHashCode()
	{
		//return x.GetHashCode() + y.GetHashCode();
		return System.HashCode.Mix(x,y);
	}
}
