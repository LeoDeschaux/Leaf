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
	[Comptime(ConstEval=true)]
	static var GetBuildVersion()
	{
		//Console.Write(456);
		//Log.Message(789);
	    return 123;
	}

	public static void Main()
	{
		var gameEngine = new GameEngine();
		Log.Message(GetBuildVersion());
		gameEngine.RunGame(new Leaf.Scenes.Scene3DGlobalIllumination());
		delete gameEngine;
	}
}

