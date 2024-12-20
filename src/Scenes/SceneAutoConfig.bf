using System;
using Leaf;
using RaylibBeef;
using Leaf.Config;
using Leaf.Serialization;
using ImGui;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;

namespace Leaf.Scenes;

class SceneAutoConfig : BaseScene
{
	//[AutoConfig]
	public int PlayerHealth = 100;

	//[AutoConfig]
	public int PlayerSpeed = 350;

	[AutoConfig]
	public int PosX = 150;

	[AutoConfig]
	public bool IsVisible = true; 

    public this()
    {
    }

    public ~this()
    {
    }

    public override void Update()
    {
    }

    public override void Draw()
    {
		if(IsVisible)
			DrawRectangle((int32)PosX,50, 50,50, RED);
    }
}