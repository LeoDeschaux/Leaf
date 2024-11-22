using System;
using RaylibBeef;
using System.Collections;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;

namespace Leaf;

abstract class BaseScene
{
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

	public void Restart()
	{
		GameEngine.RestartGame();
	}

	public abstract void Update();
	public abstract void Draw();

	public void InternalUpdate()
	{
		mTimer.Update();
		mTimeline.Update();
		Update();
	}

	public void InternalDraw()
	{
		ClearBackground(BackgroundColor);

		Draw();

		//INFO
		/*
		char8* frameTime = scope $"getFrameTime: {GetFrameTime()}".ToString(.. scope .());
		DrawText(frameTime, 20,60,24,DARKGREEN);
		char8* getTime = scope $"getTime: {GetTime()}".ToString(.. scope .());
		DrawText(getTime, 20,100,24,RED);
		*/

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

		DrawFPS(GetScreenWidth()-80, 10);
	}
}