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
		gameEngine.RunGame(new Leaf.Scenes.SceneOrderedDrawCall());
		delete gameEngine;
	}
}