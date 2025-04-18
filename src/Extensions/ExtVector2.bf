using System;

namespace RaylibBeef
{
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

		public Vector2 Normalized()
		{
			return Raymath.Vector2Normalize(this);
		}

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

		public static operator Vector2(ImGui.ImGui.Vec2 val)
		{
			return Vector2(val.x, val.y);
		}

		public static operator ImGui.ImGui.Vec2(Vector2 val)
		{
			return ImGui.ImGui.Vec2(val.x, val.y);
		}
	}
}
