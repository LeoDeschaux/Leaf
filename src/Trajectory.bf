using RaylibBeef;
using static RaylibBeef.Raylib;
using System;
using System.Diagnostics;
namespace Leaf;

class Trajectory
{
	/*
	public static Vector2 CalculateVelocityRamped(float ramp, Vector2 minTarget, Vector2 maxTarget, float minApex, float maxApex)
	{
		var ramp;
		ramp = Math.Clamp(ramp, 0, 1);
		Vector2 target = minTarget + ((maxTarget - minTarget) * ramp);
		float apex = minApex + ((maxApex - minApex) * ramp);
		return CalculateLaunchData(target, apex).initialVelocity;
	}
	*/

	

	public struct LaunchData
	{
		public readonly Vector2 initialVelocity;
		public readonly float timeToTarget;
		public readonly float gravity;

		public readonly Vector2 startPos;
		public readonly Vector2 endPos;

		public this(Vector2 startPos, Vector2 endPos, Vector2 initialVelocity, float timeToTarget, float gravity)
		{
			this.initialVelocity = initialVelocity;
			this.timeToTarget = timeToTarget;
			this.gravity = gravity;

			this.startPos = startPos;
			this.endPos = endPos;
		}
	}

	public static LaunchData CalculateLaunchDataG(Vector2 startPos, Vector2 target, float height, float gravity)
	{
		float displacementY = -(target.y - startPos.y);
		Vector2 displacementX = .(target.x - startPos.x, 0);

		Debug.Assert(height > displacementY);

		float time = Math.Sqrt(-2 * height / -gravity) + Math.Sqrt(2 * (displacementY - height) / -gravity);
		Vector2 velocityY = Vector2.UP * Math.Sqrt(-2 * -gravity * height);
		Vector2 velocityX = displacementX / time;

		return LaunchData(startPos, target, velocityX + velocityY * -Math.Sign(-gravity), time, gravity);
	}

	public static LaunchData CalculateLaunchData(Vector2 startPos, Vector2 target, float height, float duration)
	{
	    float displacementY = -(target.y - startPos.y);
	    Vector2 displacementX = Vector2(target.x - startPos.x, 0);

	    //Debug.Assert(height > displacementY);

	    float sqrtHeight = Math.Sqrt(height);
	    float sqrtHeightMinusDisp = Math.Sqrt(height - displacementY);
	    float totalSqrt = sqrtHeight + sqrtHeightMinusDisp;

	    float gravity = 2 * totalSqrt * totalSqrt / (duration * duration);

	    Vector2 velocityY = Vector2.UP * Math.Sqrt(2 * gravity * height);
	    Vector2 velocityX = displacementX / duration;

	    return LaunchData(startPos, target, velocityX + velocityY * -Math.Sign(-gravity), duration, gravity);
	}


	public static void DrawPath(Vector2 startPos, Vector2 target, float height, float gravity, float duration)
	{
		LaunchData res = CalculateLaunchData(startPos, target, height, duration);
		//LaunchData res = CalculateLaunchDataG(startPos, target, height, gravity);
		DrawPath(res);
	}

	public static void DrawPath(LaunchData res)
	{
		Vector2 previousDrawPoint = res.startPos;
		int resolution = 30;
		for (int i = 1; i <= resolution; i++)
		{
			float simulationTime = i / (float)resolution * res.timeToTarget;
			Vector2 displacement = res.initialVelocity * simulationTime + Vector2.UP * -res.gravity * simulationTime * simulationTime / 2f;
			Vector2 drawPoint = res.startPos + displacement;
			float coef = (float)i / (float)resolution;
			DrawLineV(previousDrawPoint, drawPoint, .((uint8)(coef * 255), (uint8)((1f-coef)*255),0,255));
			previousDrawPoint = drawPoint;
		}
	}
}