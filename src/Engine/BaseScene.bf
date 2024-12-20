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

	public this()
	{
		mTimer = new Timer();
		mTimeline = new Timeline();
	}

	public ~this()
	{
		delete mTimer;
		delete mTimeline;
	}

	public virtual void OnBeforeExit(){};

	public void Restart()
	{
		GameEngine.RestartGame();
	}

	public void InternalUpdate()
	{
		if(WindowShouldClose())
			Console.WriteLine("YO");

		mTimer.Update();
		mTimeline.Update();
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