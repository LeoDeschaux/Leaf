using System;
using Leaf;
using RaylibBeef;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;

using static RaylibBeef.Rlgl;
using System.IO;
using BJSON;
using ImGui;
using System.Collections;
using rlCImGuiBeef;

namespace Leaf.Scenes;

class SceneShader : Leaf.BaseScene
{
	Texture2D image;
	Shader shader;

	Vector2 imagePos = .(500,500);

	Vector2 fxCursorPos = .(0,0);
	float fxRadius = 250f;
	float fxAngle = 0.8f;

    public this()
    {
		//Camera.zoom = 1f;
		//Camera.offset = .(GetScreenWidth()/2,GetScreenHeight()/2);

		image = LoadTexture("res/images/piece.png");
		shader = LoadShader("", "res/shaders/swirl.fs");
		Console.WriteLine("START");
    }

    public ~this()
    {
		Console.WriteLine("END");
    }

    public override void Update()
    {
		if (IsKeyDown(KeyboardKey.KEY_G)) //IsMouseButtonDown((int32)MouseButton.MOUSE_BUTTON_LEFT))
		{
			fxCursorPos = GetMousePosition();
			fxCursorPos = GetScreenToWorld2D(fxCursorPos, Camera);
		}

		float[2] swirlCenter = .(
			fxCursorPos.x-imagePos.x + image.width/2f,
			fxCursorPos.y-imagePos.y + image.height/2f,
		);

		SetShaderValue(shader, GetShaderLocation(shader, "center"), &swirlCenter, ShaderUniformDataType.SHADER_UNIFORM_VEC2);

		SetShaderValue(shader, GetShaderLocation(shader, "radius"), &fxRadius, ShaderUniformDataType.SHADER_UNIFORM_FLOAT);
		SetShaderValue(shader, GetShaderLocation(shader, "angle"), &fxAngle, ShaderUniformDataType.SHADER_UNIFORM_FLOAT);

		if (IsMouseButtonDown((int32)MouseButton.MOUSE_BUTTON_RIGHT))
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
		}
    }

    public override void Draw()
    {
		Rectangle srcRec = .(
			0,0,image.width,image.height
		);
		Rectangle destRec = .(
			imagePos.x,imagePos.y,image.width,image.height
		);

		BeginShaderMode(shader);
			DrawTexturePro(image, srcRec, destRec, .(image.width/2f,image.height/2f), 0, WHITE);
		EndShaderMode();

		DrawCircleV(fxCursorPos, 10, RED);
    }

	public override void DrawScreenSpace()
	{
		ImGui.SliderFloat("FX Radius", &fxRadius, 0f,1000f);
		ImGui.SliderFloat("FX Angle", &fxAngle, -1f,1f);
	}
}