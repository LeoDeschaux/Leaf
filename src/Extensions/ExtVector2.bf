namespace RaylibBeef
{
	using System;

	extension Vector2
	{
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

		public static Vector2 operator*(Vector2 left, float right)
		{
			return .(left.x*right, left.y*right);
		}

		public static Vector2 operator/(Vector2 left, float right)
		{
			return .(left.x/right, left.y/right);
		}

		public static float Distance(Vector2 left, Vector2 right)
		{
			return Raymath.Vector2Distance(left, right);
		}
	}
}
