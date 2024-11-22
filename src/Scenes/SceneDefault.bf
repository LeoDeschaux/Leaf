using System;
using System.IO;
using System.Diagnostics;

using RaylibBeef;
using static RaylibBeef.Raylib;

using ImGui;
using Leaf.ParticleSystem;

namespace Leaf.Scenes;

class SceneDefault : BaseScene
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