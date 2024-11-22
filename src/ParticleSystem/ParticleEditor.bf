using System;
using System.IO;
using System.Diagnostics;

using RaylibBeef;
using static RaylibBeef.Raylib;

using ImGui;
using rlCImGuiBeef;
using static rlCImGuiBeef.rlCImGuiBeef;

namespace Leaf.ParticleSystem;

class ParticleEditor : BaseScene
{
	private ParticleEmitter mouseEmitter;
	private ParticleEmitter stationaryEmitter;

	private ParticleData particleData;

	public this()
	{
		particleData = new ParticleData("res/ParticleSystem/ParticleData.json");

		stationaryEmitter = new ParticleEmitter(particleData);
		mouseEmitter = new ParticleEmitter(particleData);

		stationaryEmitter.Location = .(GetScreenWidth()*0.2f, GetScreenHeight()/2);
	}

	public ~this()
	{
		delete particleData;

		delete stationaryEmitter;
		delete mouseEmitter;
	}

	public override void Update()
	{
		stationaryEmitter.Update();

		var mousePos = GetMousePosition();
		mouseEmitter.Update();
		mouseEmitter.Location = mousePos;
		//TODO: burst emitter that spawn where I click
	}

	float panelWidth = 300.0f;

	public override void Draw()
	{
		stationaryEmitter.Draw();
		mouseEmitter.Draw();

		//
		DrawFPS(10,10);

		ImGui.Vec2 display_size = ImGui.GetIO().DisplaySize;
		float panelHeight = display_size.y;

		ImGui.SetNextWindowPos(ImGui.Vec2(display_size.x - panelWidth, 0));
		ImGui.SetNextWindowSize(ImGui.Vec2(panelWidth, panelHeight));

		ImGui.Begin("Config", null, ImGui.WindowFlags.NoMove | ImGui.WindowFlags.NoCollapse);// | ImGui.WindowFlags.NoNav);
		panelWidth = ImGui.GetWindowSize().x;

		ImGui.Text("This is a resizable panel on the right!");

		/*
		ImGui.BeginCombo("Combo", "preview");
		ImGui.EndCombo();

		ImGui.BeginMenu("Menu");
		ImGui.EndMenu();

		ImGui.BeginListBox("List");
		ImGui.EndListBox();
		*/

		if(ImGui.CollapsingHeader("Particle Settings", ImGui.TreeNodeFlags.DefaultOpen))
		{
			ImGui.SliderFloat2("Size", ref particleData.Size, 0.1f, 1000);
			ImGui.SliderFloat2("Velocity", ref particleData.Velocity, 0.1f, 1000);
			ImGui.SliderFloat("AngularVelocity", &particleData.AngularVelocity, 0.1f, 1000);
			ImGui.ColorEdit4("Color", ref particleData.Color); 
			ImGui.SliderFloat("Lifetime", &particleData.Lifetime, 0.1f, 100);
		}

		if(ImGui.CollapsingHeader("Emitter Settings", ImGui.TreeNodeFlags.DefaultOpen))
		{
			ImGui.SliderInt("SpawnRate", (int32*)&particleData.SpawnRate, 1, 1000);
			ImGui.SliderInt("BurstAmount", (int32*)&particleData.BurstAmount, 1, 1000);
			ImGui.SliderInt("MaxParticles", (int32*)&particleData.MaxParticles, 1, 10000);

			ImGui.SliderFloat("Duration", &particleData.Duration, 0.1f, 100);

			ImGui.Checkbox("BurstMode", &particleData.BurstMode);
			ImGui.Checkbox("Loop", &particleData.Loop);
			ImGui.Checkbox("StartAwake", &particleData.StartAwake);
			ImGui.Checkbox("DestroyOnFinished", &particleData.DestroyOnFinished);
		}

		ImGui.Separator();

		if(ImGui.ButtonEx("Play", .(100,30)))
		{
			stationaryEmitter.Play();
			mouseEmitter.Play();
		}

		if(ImGui.ButtonEx("PlayFromStart", .(100,30)))
		{
			stationaryEmitter.PlayFromStart();
			mouseEmitter.PlayFromStart();
		}

		if(ImGui.ButtonEx("PlayRandomRandomLocation", .(100,30)))
		{
			stationaryEmitter.PlayAtLocation(.(
				Random.GetRandomValue(0,GetScreenWidth()-(int32)panelWidth),
				Random.GetRandomValue(0,GetScreenHeight())
			));

			Console.WriteLine(stationaryEmitter.Location.ToString(.. scope .()));
		}

		if(ImGui.ButtonEx("Burst", .(100,30)))
		{

		}

		if(ImGui.ButtonEx("Restart", .(100,30)))
		{
			stationaryEmitter.Restart();
			mouseEmitter.Restart();
			/*
			delete stationaryEmitter;
			delete mouseEmitter;
			stationaryEmitter = new ParticleEmitter(particleData);
			mouseEmitter = new ParticleEmitter(particleData);
			*/
		}

		ImGui.End();
	}
}