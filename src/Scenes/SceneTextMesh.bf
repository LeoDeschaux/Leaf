using System;
using Leaf;
using RaylibBeef;
using System.Collections;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;

namespace Leaf.Scenes;

class SceneTextMesh : Leaf.BaseScene
{
	RichText tm;

    public this()
    {
		Camera.target = .(GetScreenWidth()/2f, 0);

		tm = new .();

		Font font = LoadFontEx("res/fonts/Arial.ttf", (int32)256, null,0);

		String text = @"""
		This is a random text with random colors
		""";

		for(var c in text.RawChars)
		{
			tm.Add(new .(
				new $"{c}",
				BLACK,
				/*
				Color(
					(uint8)GetRandomValue(0,255),
					(uint8)GetRandomValue(0,255),
					(uint8)GetRandomValue(0,255),
					255),
				*/
				font)
			);
		}

		tm.TextSprites[0].Color = RED;

    }

    public ~this()
    {
    }


	int letterIndex = -1;

    public override void Update()
    {
		if(IsKeyPressed(KeyboardKey.KEY_SPACE))
		{
			letterIndex++;
			tm.TextSprites[letterIndex%tm.TextSprites.Count].Color = RED;
		}

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

    public override void Draw()
    {
    }
}

