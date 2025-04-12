using RaylibBeef;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;

using System;
using System.Collections;

namespace Leaf;

static class AABB
{
	public static bool IsOverlapping(Circle c1, Circle c2)
	{
		return Vector2.Distance(c1.Position, c2.Position) < c1.Radius+c2.Radius;
	}

	public static Vector2 ClosestPoint(Circle c1, Rectangle r1)
	{
		var difference = c1.Position - r1.Center;

		Vector2 clamped = .(
			Raymath.Clamp(difference.x, -r1.width/2, r1.width/2),
			Raymath.Clamp(difference.y, -r1.height/2, r1.height/2)
		);

		return r1.Center + clamped;
	}

	public static Vector2 ClosestVertex(Circle c1, Rectangle r1)
	{
		Vector2 result = r1.A;

		if(Vector2.Distance(c1.Position, r1.B) < Vector2.Distance(c1.Position, result))
			result = r1.B;
		if(Vector2.Distance(c1.Position, r1.C) < Vector2.Distance(c1.Position, result))
			result = r1.C;
		if(Vector2.Distance(c1.Position, r1.D) < Vector2.Distance(c1.Position, result))
			result = r1.D;

		return result;
	}

	public static Vector2 ClosestPointOnEdge(Circle c1, Rectangle r1)
	{
		Vector2 left = .(r1.Left,Raymath.Clamp(c1.Position.y, r1.A.y, r1.D.y));
 		Vector2 right = .(r1.Right,Raymath.Clamp(c1.Position.y, r1.B.y, r1.C.y));
		Vector2 top = .(Raymath.Clamp(c1.Position.x, r1.A.x, r1.B.x), r1.Top);
		Vector2 bottom = .(Raymath.Clamp(c1.Position.x, r1.D.x, r1.C.x), r1.Bottom);

		Vector2 result = left;

		if(Vector2.Distance(c1.Position, right) < Vector2.Distance(c1.Position, result))
			result = right;
		if(Vector2.Distance(c1.Position, top) < Vector2.Distance(c1.Position, result))
			result = top;
		if(Vector2.Distance(c1.Position, bottom) < Vector2.Distance(c1.Position, result))
			result = bottom;

		DrawCircleV(left, 6, WHITE);
		DrawCircleV(right, 6, WHITE);
		DrawCircleV(top, 6, WHITE);
		DrawCircleV(bottom, 6, WHITE);

		DrawCircleV(result, 8, RED);

		return result;
	}

	public static bool IsOverlapping(Circle c1, Rectangle r1)
	{
		var difference = c1.Position - r1.Center;

		Vector2 clamped = .(
			Raymath.Clamp(difference.x, -r1.width/2, r1.width/2),
			Raymath.Clamp(difference.y, -r1.height/2, r1.height/2)
		);

		Vector2 closest = r1.Center + clamped;

		var distance = closest - c1.Position;

		return Raymath.Vector2Length(distance) < c1.Radius;
	}

	public static bool IsOverlapping(Rectangle r1, Rectangle r2)
	{
		return
			r1.x < r2.x + r2.width &&
			r1.x + r1.width > r2.x &&
			r1.y < r2.y + r2.height &&
			r1.y + r1.height > r2.y;
	}

	public static bool IsColliding(Circle c1, Circle c2)
	{
		float margin = 0.01f;
		float distance = Vector2.Distance(c1.Position, c2.Position) - (c1.Radius + c2.Radius);

		return distance <= margin;
	}

	public static bool IsColliding(Circle c1, Rectangle r1)
	{
		var margin = 0.1f;

		var difference = c1.Position - r1.Center;

		Vector2 clamped = .(
			Raymath.Clamp(difference.x, -r1.width/2, r1.width/2),
			Raymath.Clamp(difference.y, -r1.height/2, r1.height/2)
		);

		Vector2 closest = r1.Center + clamped;

		var distance = closest - c1.Position;

		return Raymath.Vector2Length(distance) <= c1.Radius+margin;
	}

	public static bool IsColliding(Rectangle r1, Rectangle r2)
	{
		bool isXAligned = r1.x < r2.x + r2.width && r1.x + r1.width > r2.x;
		bool isYAligned = r1.y < r2.y + r2.height && r1.y + r1.height > r2.y;

		float margin = 0;
		bool isXAxisTouching = Math.Abs(r1.Right-r2.Left) <= margin || Math.Abs(r1.Left-r2.Right) <= margin;
		bool isYAxisTouching = Math.Abs(r1.Top-r2.Bottom) <= margin || Math.Abs(r1.Bottom-r2.Top) <= margin;

		return (isXAligned && isYAxisTouching) || (isYAligned && isXAxisTouching);
	}

	public static Vector2 Resolve(Circle c1, Circle c2)
	{
		var result = c1.Position;

		Vector2 dir = Raymath.Vector2Normalize(c2.Position-c1.Position);

		float distance = Vector2.Distance(c1.Position, c2.Position);
		float penetration = distance - (c1.Radius + c2.Radius);

		if(penetration > 0)
			return result;

		return result+(dir*penetration);
	}

	public static Vector2 ResolveGPT1(Circle c1, List<Rectangle> rectangles)
	{
	    Vector2 result = c1.Position;
	    Vector2 totalCorrection = .(0,0);

	    for (var r1 in rectangles)
	    {
	        Vector2 nearestPoint;
	        nearestPoint.x = Math.Clamp(c1.Position.x, r1.x, r1.x + r1.width);
	        nearestPoint.y = Math.Clamp(c1.Position.y, r1.y, r1.y + r1.height);

	        Vector2 rayToNearest = nearestPoint - c1.Position;
	        float distance = Vector2.Magnitude(rayToNearest);
	        float overlap = c1.Radius - distance;

	        if (overlap > 0)
	            totalCorrection -= rayToNearest.Normalized() * overlap;
	    }

	    result += totalCorrection;

	    return result;
	}

	public static Vector2 ResolveMistral(Circle c1, Rectangle r1)
	{
	    Vector2 result = c1.Position;

	    Vector2 nearestPoint;
	    nearestPoint.x = Math.Clamp(c1.Position.x, r1.x, r1.x + r1.width);
	    nearestPoint.y = Math.Clamp(c1.Position.y, r1.y, r1.y + r1.height);

	    Vector2 rayToNearest = nearestPoint - c1.Position;
	    float overlap = c1.Radius - Vector2.Magnitude(rayToNearest);

	    if (overlap > 0)
	    {
	        Vector2 normal = rayToNearest.Normalized();
	        result = c1.Position - (normal * overlap);
	    }

	    return result;
	}

	public static Vector2 ResolveMistralTiles(Circle c1, List<Rectangle> tiles, int maxIterations = 10)
	{
	    Vector2 result = c1.Position;
	    int iterations = 0;

	    // Iterate until no collisions are detected or max iterations are reached
	    while (iterations < maxIterations)
	    {
	        iterations++;
	        bool collisionDetected = false;
	        float minOverlap = float.MaxValue;
	        Vector2 minOverlapVector = .(0,0);

	        for(var r1 in tiles)
	        {
	            Vector2 nearestPoint;
	            nearestPoint.x = Math.Clamp(c1.Position.x, r1.x, r1.x + r1.width);
	            nearestPoint.y = Math.Clamp(c1.Position.y, r1.y, r1.y + r1.height);

	            Vector2 rayToNearest = nearestPoint - c1.Position;
	            float overlap = c1.Radius - Vector2.Magnitude(rayToNearest);

	            if (overlap > 0 && overlap < minOverlap)
	            {
	                minOverlap = overlap;
	                minOverlapVector = rayToNearest.Normalized() * overlap;
	                collisionDetected = true;
	            }
	        }

	        if (collisionDetected)
	        {
	            result = c1.Position - minOverlapVector;
	        }
	        else
	        {
	            break;
	        }
	    }

	    return result;
	}

	public static Vector2 Resolve(Circle c1, Rectangle r1)
	{
		Vector2 result = c1.Position;

		Vector2 nearestPoint;
		nearestPoint.x = Math.Clamp(c1.Position.x, r1.x, r1.x+r1.width);
		nearestPoint.y = Math.Clamp(c1.Position.y, r1.y, r1.y+r1.height);

		Vector2 rayToNearest = nearestPoint - c1.Position;
		float overlap = c1.Radius - Vector2.Magnitude(rayToNearest);

		if(overlap > 0)
			result = c1.Position - (rayToNearest.Normalized() * overlap);

		return result;
	}

	public static Vector2 ResolveOld(Circle c1, Rectangle r1)
	{
		var closestVertex = ClosestVertex(c1, r1);
		var closestPointOnEdge = ClosestPointOnEdge(c1, r1);

		var isClosestVertexOverlapping = Vector2.Distance(c1.Position, closestVertex) < c1.Radius;
		var isClosestPointOntEdgeOverlapping = Vector2.Distance(c1.Position, closestPointOnEdge) < c1.Radius;

		if(!isClosestVertexOverlapping && !isClosestPointOntEdgeOverlapping)
			return c1.Position;

		bool shouldResolveVertex =
			Vector2.Distance(closestVertex, closestPointOnEdge) <= 0;

		if(shouldResolveVertex)
			return ResolveVertex(c1, r1);
		else
			return ResolveEdge(c1, r1);
	}

	public static Vector2 ResolveVertex(Circle c1, Rectangle r1)
	{
		var result = c1.Position;

		var closestVertex = ClosestVertex(c1, r1);

		Vector2 dir = Raymath.Vector2Normalize(closestVertex-c1.Position);

		float distance = Vector2.Distance(c1.Position, closestVertex);
		float penetration = distance - c1.Radius;

		if(penetration > 0)
			return result;

		return result+(dir*penetration);
	}

	public static Vector2 ResolveEdge(Circle c1, Rectangle r1)
	{
		var result = c1.Position;
		var penetration = Vector2(0,0);

		var closestPointOnEdge = ClosestPointOnEdge(c1, r1);

		bool isLeftSide = closestPointOnEdge.x < r1.Center.x;
		penetration.x = isLeftSide ? c1.Position.x+c1.Radius - r1.Left : c1.Position.x-c1.Radius - r1.Right;

		bool isTopSide = closestPointOnEdge.y < r1.Center.y;
		penetration.y = isTopSide ? c1.Position.y+c1.Radius - r1.Top : c1.Position.y-c1.Radius - r1.Bottom;

		if(Math.Abs(penetration.x) < Math.Abs(penetration.y))
			penetration.y = 0;
		else
			penetration.x = 0;

		//Console.WriteLine(penetration.ToString(.. scope .()));

		return result-penetration;
	}

	/// we consider only r1 is moved for the resolution
	public static Vector2 Resolve(Rectangle r1, Rectangle r2)
	{
		var result = r1.Center;
		var penetration = Vector2(0,0);

		bool xAxisOverlap = r1.x < r2.x + r2.width && r1.x + r1.width > r2.x;
		bool isLeftSide = r1.Center.x < r2.Center.x;
		if(xAxisOverlap)
			penetration.x = isLeftSide ? r1.x+r1.width - r2.x : (r2.x+r2.width - r1.x) * -1f;

		bool yAxisOverlap = r1.y < r2.y + r2.height && r1.y + r1.height > r2.y;
		bool isTopSide = r1.Center.y < r2.Center.y;
		if(yAxisOverlap)
			penetration.y = isTopSide ? r1.y+r1.height - r2.y: (r2.y+r2.height - r1.y) * -1f;

		//Console.WriteLine(penetration.ToString(.. scope .()));

		if(Math.Abs(penetration.x) < Math.Abs(penetration.y))
			penetration.y = 0;
		else
			penetration.x = 0;

		return result-penetration;
	}

	public static bool RayIntersectsAABB(Vector2 rayOrigin, Vector2 rayEnd, Rectangle rectangle, out Vector2 hitPoint)
	{
		hitPoint = default;
		float tHit = float.MaxValue;

		Vector2 rayDir = rayEnd-rayOrigin;
		float rayLength = Vector2Length(rayDir);
		rayDir = rayDir.Normalized();

	    // Avoid division by zero by replacing 0 with a very small number
	    Vector2 invDir = .(
			1 / (rayDir.x != 0 ? rayDir.x : float.Epsilon), 
	     	1 / (rayDir.y != 0 ? rayDir.y : float.Epsilon));

	    float t1 = (rectangle.Left - rayOrigin.x) * invDir.x;
	    float t2 = (rectangle.Right - rayOrigin.x) * invDir.x;
	    float t3 = (rectangle.Top - rayOrigin.y) * invDir.y;
	    float t4 = (rectangle.Bottom - rayOrigin.y) * invDir.y;

	    float tmin = Math.Max(Math.Min(t1, t2), Math.Min(t3, t4));
	    float tmax = Math.Min(Math.Max(t1, t2), Math.Max(t3, t4));

	    if (tmax < 0 || tmin > tmax)
	        return false;

	    tHit = tmin > 0 ? tmin : tmax;
		if (tHit > rayLength)
			return false;

		hitPoint = .(rayOrigin.x + rayDir.x * tHit, rayOrigin.y + rayDir.y * tHit);

		Runtime.Assert(hitPoint.x != float.NaN);
		Runtime.Assert(hitPoint.y != float.NaN);

	    return true;
	}

	public static bool RayIntersects(Vector2 rayOrigin, Vector2 rayEnd, Circle circle, out Vector2 hitPoint)
	{
		hitPoint = default;

	    Vector2 rayDir = rayEnd - rayOrigin;
	    float rayLength = Vector2Length(rayDir);
	    rayDir = rayDir.Normalized();

	    Vector2 toCircle = circle.Position - rayOrigin;
	    float projection = Vector2DotProduct(toCircle, rayDir);
	    float distanceSquared = Vector2DotProduct(toCircle, toCircle) - (projection * projection);
	    float radiusSquared = circle.Radius * circle.Radius;

	    // If the closest approach is outside the circle, there's no intersection
	    if (distanceSquared > radiusSquared)
	        return false;

	    float thc = Math.Sqrt(radiusSquared - distanceSquared);
	    float tHit = projection - thc;

	    // If the intersection is behind the ray or beyond its length, no hit
	    if (tHit < 0 || tHit > rayLength)
	        return false;

	    hitPoint = Vector2(rayOrigin.x + rayDir.x * tHit, rayOrigin.y + rayDir.y * tHit);
	    return true;
	}
}