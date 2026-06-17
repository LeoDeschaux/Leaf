using System;

namespace RaylibBeef
{
	extension Vector2
	{
		public static Vector2 UP = .(0,-1);

		public static Vector2 operator*(Vector2 left, Vector2 right)
		{
			return .(left.x*right.x, left.y*right.y);
		}

		public static Vector2 operator/(Vector2 left, Vector2 right)
		{
			return .(left.x/right.x, left.y/right.y);
		}

		public static Vector2 operator+(Vector2 left, Vector2 right)
		{
			return .(left.x+right.x, left.y+right.y);
		}

		public static Vector2 operator-(Vector2 left, Vector2 right)
		{
			return .(left.x-right.x, left.y-right.y);
		}

		[Commutable]
		public static Vector2 operator*(Vector2 left, float right)
		{
			return .(left.x*right, left.y*right);
		}

		public static Vector2 operator/(Vector2 left, float right)
		{
			return .(left.x/right, left.y/right);
		}

		public Vector2 Normalized()
		{
			return Raymath.Vector2Normalize(this);
		}

		public float Magnitude() => Raymath.Vector2Length(this);

		public static float Distance(Vector2 left, Vector2 right)
		{
			return Raymath.Vector2Distance(left, right);
		}

		public static float Magnitude(Vector2 left)
		{
			return Raymath.Vector2Length(left);
		}

		public override void ToString(String strBuffer)
		{
			strBuffer.Append(scope $"x:{x},y:{y}");
		}

		public static Vector2 Clamp(Vector2 value, Vector2 min, Vector2 max)
		{
			return .(
				Math.Clamp(value.x, min.x, max.x),
				Math.Clamp(value.y, min.y, max.y));
		}
	}
}
