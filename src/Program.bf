using System;
using System.IO;
using System.Diagnostics;

using RaylibBeef;
using static RaylibBeef.Raylib;

using ImGui;
using Leaf.ParticleSystem;

namespace Leaf;

class Program
{
	public static void Main()
	{
		var gameEngine = new GameEngine();

		//gameEngine.AddGame(new Leaf.Scenes.DebugGame());
		gameEngine.RunGame(new Leaf.Scenes.SceneAutoConfig());
		//gameEngine.AddGame(new ParticleEditor());

		delete gameEngine;
	}
}