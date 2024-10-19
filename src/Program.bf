using System;
using System.IO;
using System.Diagnostics;

using RaylibBeef;
using static RaylibBeef.Raylib;

using ImGui;

namespace Leaf;

class Program
{
	public static void Main()
	{
		var gameEngine = new GameEngine();

		gameEngine.AddGame(new DebugGame());

		delete gameEngine;
	}
}

class DebugGame : BaseGame
{
	public override void Update()
	{

	}

	public override void Draw()
	{
		DrawRectangle(0,0,100,100,BLUE);

		ImGui.ShowDemoWindow();
	}
}