using System;
using System.IO;
using System.Diagnostics;

using RaylibBeef;
using static RaylibBeef.Raylib;

using ImGui;
using rlCImGuiBeef;

namespace Leaf;

class GameEngine
{
#if BF_PLATFORM_WASM
	private const int WEB_FRAME_RATE = 60;
	private function void em_callback_func();

	[CLink, CallingConvention(.Stdcall)]
	private static extern void emscripten_set_main_loop(em_callback_func func, int32 fps, int32 simulateInfinteLoop);

	[CLink, CallingConvention(.Stdcall)]
	private static extern int32 emscripten_set_main_loop_timing(int32 mode, int32 value);

	[CLink, CallingConvention(.Stdcall)]
	private static extern double emscripten_get_now();

	private static void EmscriptenMainLoop()
	{
		Tick();
	}
#endif

	private static BaseGame Game;
	private static RenderTexture2D RenderTexture;

	private int32 screenWidth = 1280;
	private int32 screenHeight = 720;

	public this()
	{
		SetConfigFlags((int32)ConfigFlags.FLAG_WINDOW_RESIZABLE);
		InitWindow(screenWidth, screenHeight, scope $"Title");
		InitAudioDevice();

		rlCImGuiBeef.rlCImGuiSetup();

		SetWindowFocused();

		// Request a texture to render to. The size is the screen size of the raylib example.
		RenderTexture = LoadRenderTexture(screenWidth, screenHeight);
	}

	public ~this()
	{
		delete Game;

		rlCImGuiBeef.rlCImGuiShutdown();

		CloseAudioDevice();
		CloseWindow();
	}

	public void AddGame(BaseGame game)
	{
		Game = game;
		Game.mGameEngine = this;


#if BF_PLATFORM_WASM
		emscripten_set_main_loop(=> EmscriptenMainLoop, 0, 1);
		//emscripten_set_main_loop_timing(1, 0);
#else
		SetTargetFPS(60);

		while (!WindowShouldClose())
		{
			Tick();
		}

#endif
	}

	public void RestartGame()
	{
		Type t = Game.GetType();

		delete Game;

		var obj = t.CreateObject();
		if(obj case .Err(let err))
			Console.WriteLine(err);

		Game = (BaseGame)obj;
		Game.mGameEngine = this;
	}

	private static void Tick()
	{
		//UPDATE
		Game.InternalUpdate();

		//DRAW
		BeginTextureMode(RenderTexture);
		EndTextureMode();
		
		BeginDrawing();

		Game.InternalDraw();

		/*
		DrawTexturePro(
			renderTexture.texture,
			Rectangle(0, 0, renderTexture.texture.width, -renderTexture.texture.height),
			Rectangle(0, 0, GetScreenWidth(), GetScreenHeight()),
			Vector2(0, 0),
			0,
			WHITE
		);
		*/

		rlCImGuiBeef.rlCImGuiBegin();
		bool open = true;
		ImGui.ShowDemoWindow(&open);
		rlCImGuiBeef.rlCImGuiEnd();

		EndDrawing();
	}
}