using System;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;
using static RaylibBeef.Rlgl;

namespace RaylibBeef;

extension Raylib
{
	public static void UpdateSimpleCameraControl(ref Camera2D Camera)
	{
		if (IsMouseButtonDown((int32)MouseButton.MOUSE_BUTTON_RIGHT) && !IsKeyDown(KeyboardKey.KEY_LEFT_SHIFT))
		{
		    Vector2 delta = GetMouseDelta();
		    delta = Vector2Scale(delta, -1.0f/Camera.zoom);
		    Camera.target = Vector2Add(Camera.target, delta);
		}

		float wheel = GetMouseWheelMove();
		if (wheel != 0)
		{
		    Vector2 mouseWorldPos = GetScreenToWorld2D(GetMousePosition(), Camera);
		    Camera.offset = GetMousePosition();
		    Camera.target = mouseWorldPos;

			float zoomMult = 1.5f;
			if(wheel > 0)
				Camera.zoom *= zoomMult;
			if(wheel < 0)
				Camera.zoom /= zoomMult;

			Camera.zoom = Math.Clamp(Camera.zoom, 0.1f,10f);
		}
	}
}