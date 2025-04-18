using System;
using RaylibBeef;
using System.Collections;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;

namespace Leaf;

class BaseScene : Entity
{
	public Camera2D Camera;

	public Color BackgroundColor = Color(20,30,50,255);
	protected Timer mTimer;
	protected Timeline mTimeline;

	public GameEngine GameEngine;

	public bool EnableDebugCameraControl = true;

	public this()
	{
		mTimer = new Timer();
		mTimeline = new Timeline();

		Camera.zoom = 1f;
		Camera.offset = .(GetScreenWidth()/2,GetScreenHeight()/2);
	}

	public ~this()
	{
		delete mTimer;
		delete mTimeline;
	}

	public virtual void OnFinishedSwitchingScene(){};
	public virtual void OnBeforeExit(){};

	public void Restart()
	{
		GameEngine.RestartGame();
	}

	private bool m_displayDebug;
	public bool DisplayDebug {
		get{
			return m_displayDebug;
			
		}
		set {
			m_displayDebug = value;

			PhysicComponent.Display = m_displayDebug;
			Raycast.Display = m_displayDebug;
			DebugDrawCalls.Display = m_displayDebug;
		}
	}

	public void InternalUpdate()
	{
		mTimer.Update();
		mTimeline.Update();

		if(IsKeyDown(KeyboardKey.KEY_LEFT_CONTROL) && IsKeyPressed(KeyboardKey.KEY_R))
		{
			Restart();
			return;
		}

		if(IsKeyPressed(KeyboardKey.KEY_F1))
		{
			DisplayDebug = !DisplayDebug;
		}

		if(!EnableDebugCameraControl)
			return;

		//je pense que zoom in devrait être sur la pos de la souris
		//et zoom out devrait être sur le centre de l'écran
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

	//SCREEN SPACE
	public void InternalDraw() 
	{
		ClearBackground(BackgroundColor);

		//INFO
		/*
		char8* frameTime = scope $"getFrameTime: {GetFrameTime()}".ToString(.. scope .());
		DrawText(frameTime, 20,60,24,DARKGREEN);
		char8* getTime = scope $"getTime: {GetTime()}".ToString(.. scope .());
		DrawText(getTime, 20,100,24,RED);

		void DrawPlatform(char8* text)
		{
			int32 fontSize = 20;
			DrawText(text, GetScreenWidth() - MeasureText(text, fontSize) - 5, GetScreenHeight() - fontSize - 2, fontSize, GRAY);
		}

#if BF_PLATFORM_WASM
		DrawPlatform("webassembly");
#else
		DrawPlatform("windows");
#endif
		*/

		DrawFPS(GetScreenWidth()-80, 10);

		DrawText(Leaf.Engine.EntitySystem.Entities.Count.ToString(.. scope .()),
			GetScreenWidth()-80,30, 24, WHITE);
	}
}