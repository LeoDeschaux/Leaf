using System;
using Leaf;
using RaylibBeef;
using System.Collections;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;

namespace Leaf;

public class IK
{
	public static Vector2 AnchoredPosProportionnal(Vector2 anchorPos, Vector2 desiredPos, int totalSegment, Vector2 initialAnchorPos, float segmentMaxLength = 200f)
	{
		float totalDistance = Vector2Distance(initialAnchorPos, desiredPos);

		float distance = Vector2Distance(anchorPos, desiredPos);
		Vector2 dir = Vector2Normalize(desiredPos-anchorPos);

		float proportionnalSegmentLength =  totalDistance/totalSegment;
		float segmentLength = Math.Clamp(distance,0,Math.Min(segmentMaxLength, proportionnalSegmentLength));
		Vector2 endPos = anchorPos + (dir * segmentLength);

		DrawCircleV(anchorPos, 24, BLUE);
		DrawCircleV(endPos, 24, RED);

		DrawLineV(anchorPos, endPos, RED);

		DrawCircleLinesV(anchorPos, segmentMaxLength, BLUE);

		Rectangle rec = .(
			anchorPos,
			.(segmentLength, 50)
		);
		float angle = Math.Atan2(dir.y, dir.x) * (180/Math.PI_f);
		DrawRectanglePro(rec, .(0,rec.height/2f), angle, BEIGE);

		return endPos;
	}

	public static Vector2 AnchoredPos(Vector2 anchorPos, Vector2 desiredPos)
	{
		float maxLength = 200;

		float distance = Vector2Distance(anchorPos, desiredPos);
		Vector2 dir = Vector2Normalize(desiredPos-anchorPos);

		Vector2 endPos = anchorPos + (dir * Math.Clamp(distance,0,maxLength));

		DrawCircleV(anchorPos, 24, BLUE);
		DrawCircleV(endPos, 24, RED);

		DrawLineV(anchorPos, endPos, RED);

		DrawCircleLinesV(anchorPos, maxLength, BLUE);

		return endPos;
	}
}