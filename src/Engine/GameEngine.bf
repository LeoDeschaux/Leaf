using System;
using System.IO;
using System.Diagnostics;

using RaylibBeef;
using static RaylibBeef.Raylib;
using static RaylibBeef.Rlgl;
using static RaylibBeef.Raymath;

using ImGui;
using rlCImGuiBeef;
using Leaf.Engine;

namespace Leaf;

class GameEngine
{                                                  
	public static BaseScene CurrentScene;
	private static RenderTexture2D RenderTexture;

	public static EntitySystem EntitySystem;
	public static PhysicsEngine PhysicsEngine;

	private int32 windowWidth = 1280;
	private int32 windowHeight = 720;

	private DataFile preferences;

	private static bool ExitReady = false;
	public static void Exit() => ExitReady = true;

	private void LoadPreferences()
	{
		preferences = DataFile.LoadFileOrCreate("res/pref.json");
		windowWidth = 1280;//(int32)preferences["WindowWidth"].data.number;
		windowHeight = 720;//(int32)preferences["WindowHeight"].data.number;
	}

	private void SavePreferences()
	{
		preferences["WindowWidth"] = GetScreenWidth();
		preferences["WindowHeight"] = GetScreenHeight();

		preferences["IsMaximized"] = IsWindowMaximized();

		preferences.SaveFileOverwrite("res/pref.json");

		delete preferences;
	}

	public this()
	{
		Console.Clear();

		SetConfigFlags((int32)ConfigFlags.FLAG_WINDOW_RESIZABLE);

		SetConfigFlags(ConfigFlags.FLAG_VSYNC_HINT);
		//set_target_fps(get_monitor_refresh_rate(get_current_monitor()));

		LoadPreferences();

		InitWindow(windowWidth, windowHeight, scope $"Title");
		InitAudioDevice();

		if(preferences["IsMaximized"])
			MaximizeWindow();

		rlCImGuiBeef.rlCImGuiSetup();

		//GetMonitorPosition(0);

		SetWindowMonitor(1);
		SetWindowFocused();


		RenderTexture = LoadRenderTexture(windowWidth, windowHeight);

		EntitySystem = new EntitySystem();
		PhysicsEngine = new PhysicsEngine();
	}

	public ~this()
	{
		SavePreferences();

		CurrentScene.OnBeforeExit();

		delete EntitySystem;
		delete PhysicsEngine;

		//delete CurrentScene;

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

		while (!WindowShouldClose() && !ExitReady)
		{
			Tick();
		}
#endif
	}

	public void RestartGame()
	{
		Type t = CurrentScene.GetType();
		delete CurrentScene;

		EntitySystem.Dispose();
		delete EntitySystem;
		EntitySystem = new EntitySystem();

		var obj = t.CreateObject();
		if(obj case .Err(let err))
		{
			Console.WriteLine(err);
			Log.Message("Error - can't CreateObject() have you put [Reflect(.Methods), AlwaysInclude(IncludeAllMethods=true)] above the constructor ?", ConsoleColor.Red);
		}

		CurrentScene = (BaseScene)obj;
		CurrentScene.GameEngine = this;
		CurrentScene.OnFinishedSwitchingScene();

		Console.WriteLine("--- GAME RESTARTED ---");
		Log.Message(Leaf.Engine.EntitySystem.Entities.Count);
	}

	public BaseScene ChangeGame(Type sceneType)
	{
		delete CurrentScene;

		EntitySystem.Dispose();
		delete EntitySystem;
		EntitySystem = new EntitySystem();

		var obj = sceneType.CreateObject();
		if(obj case .Err(let err))
		{
			Console.WriteLine(err);
			Log.Message("Error - can't CreateObject() have you put [Reflect(.Methods), AlwaysInclude(IncludeAllMethods=true)] above the constructor ?", ConsoleColor.Red);
		}

		CurrentScene = (BaseScene)obj;
		CurrentScene.GameEngine = this;
		CurrentScene.OnFinishedSwitchingScene();

		Console.WriteLine($"--- LOADED {sceneType} ---");
		Log.Message(Leaf.Engine.EntitySystem.Entities.Count);

		return CurrentScene;
	}	

	public void ChangeGameOld(BaseScene scene)
	{
		Type t = scene.GetType();
		delete CurrentScene;

		EntitySystem.Dispose();
		delete EntitySystem;
		EntitySystem = new EntitySystem();

		var obj = t.CreateObject();
		if(obj case .Err(let err))
		{
			Console.WriteLine(err);
			Log.Message("Error - can't CreateObject() have you put [Reflect(.Methods), AlwaysInclude(IncludeAllMethods=true)] above the constructor ?", ConsoleColor.Red);
		}

		CurrentScene = (BaseScene)obj;
		CurrentScene.GameEngine = this;
		CurrentScene.OnFinishedSwitchingScene();

		Console.WriteLine($"--- LOADED {t} ---");
		Log.Message(Leaf.Engine.EntitySystem.Entities.Count);
	}	

	private static void Tick()
	{
		//UPDATE
		CurrentScene.InternalUpdate();
		EntitySystem.Update();
		PhysicsEngine.Update();
		EntitySystem.PostPhysicUpdate();
		EntitySystem.CleanDeletedEntities();
		CurrentScene.PostEntities();

		//DRAW
		//BeginTextureMode(RenderTexture);
		//EndTextureMode();

		ViewportConsole.NewFrame();

		BeginDrawing();
		rlCImGuiBeef.rlCImGuiBegin();

		CurrentScene.InternalDraw();

		BeginMode2D(CurrentScene.Camera);
		EntitySystem.Draw();
		DebugDrawCalls.Render();
		EndMode2D();

		EntitySystem.DrawScreenSpace();

		Leaf.Config.AutoConfigAttribute.Update(Leaf.Engine.EntitySystem.Entities);

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

		CallBackChecker.Update();
	}
}