using RaylibBeef;
using System.Collections;
using Jolt;
using System;
using static RaylibBeef.Raylib;
using static RaylibBeef.Rlgl;
using static RaylibBeef.Color;

namespace RaylibBeef;
public extension Vector3
{
	/*
	public static operator Vector3(JPH_Vec3 val)
	{
		return .(val.x, val.y, val.z);
	}

	public static operator JPH_Vec3(Vector3 val)
	{
		return .(val.x, val.y, val.z);
	}
	*/
}


namespace Jolt;
//typealias JPH_Vec3 = RaylibBeef.Vector3;

/*
extension JPH_Vec3
{
	public static operator Vector3(JPH_Vec3 val)
	{
		return .(val.x, val.y, val.z);
	}

	public static operator JPH_Vec3(Vector3 val)
	{
		return .(val.x, val.y, val.z);
	}
}
*/

using Leaf;

extension Jolt {
	public static bool NearlyEqual(Vector3 a, Vector3 b, float delta)
	{
		return Math.Abs(a.x - b.x) < delta
			&& Math.Abs(a.y - b.y) < delta
			&& Math.Abs(a.z - b.z) < delta;
	}

	public static JPH_Quat EulerToQuat(Vector3 euler)
	{
		var q = Raymath.QuaternionFromEuler(euler.x * DEG2RAD, euler.y * DEG2RAD, euler.z * DEG2RAD);

		JPH_Quat result;
		result.x = q.x;
		result.y = q.y;
		result.z = q.z;
		result.w = q.w;
		return result;
	}

	public static Vector3 QuatToEuler(JPH_Quat q)
	{
		float ysqr = q.y * q.y;

		float t0 = +2.0f * (q.w * q.x + q.y * q.z);
		float t1 = +1.0f - 2.0f * (q.x * q.x + ysqr);
		float roll = Math.Atan2(t0, t1);

		float t2 = +2.0f * (q.w * q.y - q.z * q.x);
		t2 = Math.Clamp(t2, -1.0f, +1.0f);
		float pitch = Math.Asin(t2);

		float t3 = +2.0f * (q.w * q.z + q.x * q.y);
		float t4 = +1.0f - 2.0f * (ysqr + q.z * q.z);
		float yaw = Math.Atan2(t3, t4);

		return .(roll * RAD2DEG, pitch * RAD2DEG, yaw * RAD2DEG);
	}
}