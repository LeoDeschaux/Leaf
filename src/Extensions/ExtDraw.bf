using RaylibBeef;
using System.Collections;
using System;
using static RaylibBeef.Raylib;
using static RaylibBeef.Rlgl;
using static RaylibBeef.Color;
using static RaylibBeef.Raymath;

namespace RaylibBeef;

public extension Raylib
{
	public static void DrawCube(Vector3 position, Vector3 rotation, Vector3 scale, Color color)
	{
		rlPushMatrix();
		rlTranslatef(position.x,position.y,position.z);
		rlRotatef(rotation.x, 1, 0, 0);
		rlRotatef(rotation.y, 0, 1, 0);
		rlRotatef(rotation.z, 0, 0, 1);
		DrawCubeV(RaylibBeef.Vector3(0,0,0), scale, color);
		rlPopMatrix();
	}

	public static void DrawTrianglePro(Vector2 origin, Vector2 v1, Vector2 v2, Vector2 v3, float rotation, Color color)
	{
		rlPushMatrix();
		rlTranslatef(origin.x, origin.y,0);
		rlRotatef(rotation, 0f, 0f, 1f);
		DrawTriangle(
			v1,
			v2,
			v3,
			color
		);
		rlPopMatrix();
	}

	public static void DrawStar() //(Vector2 origin, Vector2 innerRadius, Vector2 outerRadius, int points)
	{

	}

	public static void DrawPolygon()
	{
		Vector2[] points = scope Vector2[](
		    .(10, 10),
		    .(10, 100),
		    .(100, 100),
		);

		DrawTriangleStrip(&points[0], (int32)points.Count, RED);
	}

	/*
	public static void DrawTexturedPoly()
	{
		Texture texture = LoadTexture("res/images/Background.png");
		List<Vector2> points = scope List<Vector2>() {
			.(10, 10),
			.(10, 100),
			.(100, 100),
		};
		List<Vector2> textCoords = scope List<Vector2>() {
			.(0,0),
			.(0,1),
			.(1,1)
		};
		DrawTexturePoly(texture, .(0,0), points, textCoords, 3, RED);
	}
	*/

	public static void DrawTexturePoly(Texture2D texture, Vector2 center, List<Vector2> points, List<Vector2> texcoords, int pointCount, Color tint)
	{
	    rlSetTexture(texture.id);

	    // Texturing is only supported on RL_QUADS
	    rlBegin(RL_QUADS);

	        rlColor4ub(tint.r, tint.g, tint.b, tint.a);

	        for (int i = 0; i < pointCount - 1; i++)
	        {
	            rlTexCoord2f(0.5f, 0.5f);
	            rlVertex2f(center.x, center.y);

	            rlTexCoord2f(texcoords[i].x, texcoords[i].y);
	            rlVertex2f(points[i].x + center.x, points[i].y + center.y);

	            rlTexCoord2f(texcoords[i + 1].x, texcoords[i + 1].y);
	            rlVertex2f(points[i + 1].x + center.x, points[i + 1].y + center.y);

	            rlTexCoord2f(texcoords[i + 1].x, texcoords[i + 1].y);
	            rlVertex2f(points[i + 1].x + center.x, points[i + 1].y + center.y);
	        }
	    rlEnd();

	    rlSetTexture(0);
	}

	public static void DrawText(char8* text, Vector2 pos, int32 fontSize, Color color)
	{
		DrawText(text, (int32)pos.x, (int32)pos.y, fontSize,color);
	}

	public static void DrawDiagonales(Rectangle bounds)
	{
		//DIAG
		DrawLineV(bounds.A, bounds.C, RED);
		DrawLineV(bounds.D, bounds.B, RED);
	}

	public static void DrawGuide(Rectangle bounds)
	{
		//DIAG
		DrawLineV(bounds.A, bounds.C, RED);
		DrawLineV(bounds.D, bounds.B, RED);

		//MIDLES
		DrawLineV(.(bounds.x, bounds.height/2), .(bounds.width,bounds.height/2), RED);
		DrawLineV(.(bounds.width/2, bounds.y), .(bounds.width/2,bounds.height), RED);

		//DrawThirds
		DrawLineV(.(bounds.x, bounds.height/3), .(bounds.width,bounds.height/3), YELLOW);
		DrawLineV(.(bounds.x, (bounds.height/3)*2), .(bounds.width,(bounds.height/3)*2), YELLOW);

		DrawLineV(.(bounds.width/3, bounds.y), .(bounds.width/3,bounds.height), YELLOW);
		DrawLineV(.((bounds.width/3)*2, bounds.y), .((bounds.width/3)*2,bounds.height), YELLOW);
	}

	public static void DrawGuide()
	{
		DrawGuide(.(.(0,0), .(GetScreenWidth(), GetScreenHeight())));
	}

	public static Vector2 GetScreenSize()
	{
		return .(GetScreenWidth(), GetScreenHeight());
	}
	
	public static void DrawRuller()
	{
		var mPos = GetMousePosition();
		Rectangle bounds = .(.(0,0), .(GetScreenWidth(), GetScreenHeight()));

		DrawLineV(.(mPos.x, bounds.x), .(mPos.x,bounds.height), ORANGE);
		DrawLineV(.(bounds.x, mPos.y), .(bounds.width,mPos.y), ORANGE);

		

		//DrawText(scope $"{mPos.x/bounds.width},{mPos.y/bounds.height}",mPos, 24, ORANGE);

		DrawText(scope $"{Math.Floor((mPos.x/bounds.width)*100)}%", .(mPos.x, bounds.x), 24, ORANGE);
		DrawText(scope $"{Math.Floor((mPos.y/bounds.height)*100)}%", .(bounds.y, mPos.y), 24, ORANGE);
	}

	public static void DrawArrow(Vector2 position, Vector2 direction)
	{
		float length = 60.0f;    
		float headSize = 20.0f;

		float mag = Vector2Length(direction);
		if (mag <= 0.0001f)
			return;

		var dir = direction / mag;
		var end = position + (dir * length);

		DrawLineEx(position, end, 3f, RED);

		var perp = Vector2(-dir.y, dir.x);
		end += (headSize/2) * dir;
		var left = end - dir * headSize + perp * (headSize * 0.6f);
		var right = end - dir * headSize - perp * (headSize * 0.6f);

		DrawTriangle(left, end, right, RED);
	}

	public static void DrawArrow(
	    Vector2 start,
	    Vector2 end,
	    float thickness = 2.0f,
	    float headLength = 12.0f,
	    float headWidth = 8.0f)
	{
	    Vector2 direction = end - start;
	    float length = Vector2Length(direction);

	    if (length <= 0.001f)
	        return;

	    direction /= length;

	    // Perpendicular direction
	    Vector2 perpendicular = Vector2(-direction.y, direction.x);

	    // Base of the arrowhead
	    Vector2 headBase = end - direction * headLength;

	    Vector2 left = headBase + perpendicular * (headWidth * 0.5f);
	    Vector2 right = headBase - perpendicular * (headWidth * 0.5f);

	    // Shaft stops at the arrowhead
	    Vector2 shaftEnd = headBase;

	    Raylib.DrawLineEx(start, shaftEnd, thickness, WHITE);

	    // Pointy arrowhead
	    Raylib.DrawTriangleFan(
		    &Vector2[3] (end, right, left),
		    3,
		    WHITE
		);
	}

	public static void DrawCurvedArrow(
	    Vector2 start,
	    Vector2 end,
	    float curve,
	    float thickness = 2.0f,
	    float headLength = 12.0f,
	    float headWidth = 8.0f)
	{
	    Vector2 direction = end - start;
	    float length = Vector2Length(direction);

	    if (length <= 0.001f)
	        return;

	    direction /= length;

	    // Perpendicular direction
	    Vector2 perpendicular = Vector2(-direction.y, direction.x);

	    // Control point
	    Vector2 middle = (start + end) * 0.5f;
	    Vector2 control = middle + perpendicular * curve;

		// Direction of the curve at the end
		Vector2 arrowDirection = end - control;
		arrowDirection = arrowDirection.Normalized();
		Vector2 arrowPerpendicular = Vector2(-arrowDirection.y, arrowDirection.x);

		// Arrowhead base
		Vector2 headBase = end - (arrowDirection * headLength);
		Vector2 left = headBase + arrowPerpendicular * (headWidth * 0.5f);
		Vector2 right = headBase - arrowPerpendicular * (headWidth * 0.5f);

	    // Smooth quadratic Bézier
	    Raylib.DrawSplineBezierQuadratic(
	        &Vector2[3] (start,control, end - (arrowDirection*headLength)),
			3,
	        thickness,
	        WHITE
	    );

	    Raylib.DrawTriangle(
	        end,
	        right,
	        left,
	        WHITE
	    );
	}
}
