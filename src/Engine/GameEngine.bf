using System;
using System.IO;
using System.Diagnostics;

using RaylibBeef;
using static RaylibBeef.Raylib;

using ImGui;
using rlCImGuiBeef;
using Leaf.Engine;

namespace Leaf;

class GameEngine
{
	private static BaseScene CurrentScene;
	private static RenderTexture2D RenderTexture;

	public static EntitySystem EntitySystem;

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

		EntitySystem = new EntitySystem();
	}

	public ~this()
	{
		delete EntitySystem;
		delete CurrentScene;

		rlCImGuiBeef.rlCImGuiShutdown();

		CloseAudioDevice();
		CloseWindow();
	}

	public void RunGame(BaseScene scene)
	{
		CurrentScene = scene;
		CurrentScene.GameEngine = this;

#if BF_PLATFORM_WASM
		Leaf.Engine.WebEngine.EmscriptenMainLoop(=> Tick);
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
		Type t = CurrentScene.GetType();
		delete CurrentScene;

		var obj = t.CreateObject();
		if(obj case .Err(let err))
			Console.WriteLine(err);

		CurrentScene = (BaseScene)obj;
		CurrentScene.GameEngine = this;

		Console.WriteLine("--- GAME RESTARTED ---");
	}

	private static void Tick()
	{
		//UPDATE
		CurrentScene.InternalUpdate();
		EntitySystem.Update();

		//DRAW
		BeginTextureMode(RenderTexture);
		EndTextureMode();
		
		BeginDrawing();
		rlCImGuiBeef.rlCImGuiBegin();

		CurrentScene.InternalDraw();
		EntitySystem.Draw();

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
		
		rlCImGuiBeef.rlCImGuiEnd();
		EndDrawing();
	}
}