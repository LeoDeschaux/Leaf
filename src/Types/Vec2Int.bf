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

	public static Vec2Int operator+(Vec2Int left, Vec2Int right)
	{
		return .(left.x+right.x, left.y+right.y);
	}

	public override void ToString(String strBuffer)
	{
		strBuffer.Append(scope $"x:{x},y:{y}");
	}

}
