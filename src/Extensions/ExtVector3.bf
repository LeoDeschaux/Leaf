using System;

namespace RaylibBeef
{
	extension Vector3
	{
		public static Vector2 UP = .(0,-1);

		public static Vector3 operator*(Vector3 left, Vector3 right)
		{
			return .(left.x*right.x, left.y*right.y, left.z*right.z);
		}

		public static Vector3 operator/(Vector3 left, Vector3 right)
		{
			return .(left.x/right.x, left.y/right.y, left.z/right.z);
		}

		public static Vector3 operator+(Vector3 left, Vector3 right)
		{
			return .(left.x+right.x, left.y+right.y, left.z+right.z);
		}

		public static Vector3 operator-(Vector3 left, Vector3 right)
		{
			return .(left.x-right.x, left.y-right.y, left.z-right.z);
		}

		public static Vector3 operator*(Vector3 left, float right)
		{
			return .(left.x*right, left.y*right, left.z*right);
		}

		public static Vector3 operator/(Vector3 left, float right)
		{
			return .(left.x/right, left.y/right, left.z/right);
		}

		public Vector3 Normalized()
		{
			return Raymath.Vector3Normalize(this);
		}

		public static float Distance(Vector3 left, Vector3 right)
		{
			return Raymath.Vector3Distance(left, right);
		}

		public static float Magnitude(Vector3 left)
		{
			return Raymath.Vector3Length(left);
		}

		public override void ToString(String strBuffer)
		{
			strBuffer.Append(scope $"x:{x},y:{y}");
		}

		/*
		public static operator Vector3(ImGui.ImGui.Vec3 val)
		{
			return Vector3(val.x, val.y);
		}

		public static operator ImGui.ImGui.Vec3(Vector3 val)
		{
			return ImGui.ImGui.Vec3(val.x, val.y);
		}
		*/
	}
}
