using RaylibBeef;
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
		DrawCubeV(.(0,0,0), scale, color);
		rlPopMatrix();
	}

}
