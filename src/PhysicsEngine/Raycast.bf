using RaylibBeef;
using System.Collections;

using RaylibBeef;
using System;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;

namespace Leaf;

struct RaycastResult
{
	public Vector2 hitPoint;
	public PhysicComponent physicComponent;

	public this(PhysicComponent phc, Vector2 hitpoint)
	{
		physicComponent = phc;
		hitPoint = hitpoint;
	}
}

public static class Raycast
{
	public static bool Display = true;

	public static bool RayIntersect(Vector2 rayOrigin, Vector2 rayEnd, List<RaycastResult> results, bool ignoreNonSolid = false, PhysicComponent self = null, bool displayDebugRaycast = true)
	{
		if(Display && displayDebugRaycast)
		{
			DebugDrawCalls.DrawDefered(new () => {
				DrawLine((int32)rayOrigin.x, (int32)rayOrigin.y, (int32)rayEnd.x, (int32)rayEnd.y, RED);
			});
		}

		for(var phc in PhysicsEngine.Components)
		{
			if(self != null && phc == self)
				continue;
			if(ignoreNonSolid && !phc.Solid)
				continue;

			Vector2 hitPoint = default;
			bool isIntersecting = false;

			if(var recCol = phc.CollisionShape as CollisionRectangle)
				isIntersecting = AABB.RayIntersectsAABB(rayOrigin, rayEnd, recCol.Rectangle, out hitPoint);
			else if(var recCol = phc.CollisionShape as CollisionCircle)
				isIntersecting = AABB.RayIntersects(rayOrigin, rayEnd, recCol.Circle, out hitPoint);

			if(isIntersecting)
			{
				if(Display && displayDebugRaycast)
				{
					DebugDrawCalls.DrawDefered(new () => {
						DrawCircleV(hitPoint, 5, GREEN);
					});
				}

				Runtime.Assert(hitPoint.x != float.NaN);
				Runtime.Assert(hitPoint.y != float.NaN);

				results.Add(.(phc, hitPoint));
			}
		}

		//results.Sort()
		float Distance(Vector2 hitpoint){
			return Vector2LengthSqr(hitpoint-rayOrigin);
		}
		results.Sort(scope (lhs, rhs) => Distance(lhs.hitPoint) <=> Distance(rhs.hitPoint));

		return results.Count > 0;
	}
}