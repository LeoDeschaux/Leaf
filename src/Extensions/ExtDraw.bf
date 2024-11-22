using RaylibBeef;
using System.Collections;
using static RaylibBeef.Raylib;
using static RaylibBeef.Rlgl;
using static RaylibBeef.Color;

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

	public static void DrawTexturedPoly()
	{
		Texture texture = LoadTexture("res/images/background.png");
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
}
