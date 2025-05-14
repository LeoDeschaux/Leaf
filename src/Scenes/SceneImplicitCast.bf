using System;
using Leaf;
using RaylibBeef;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;

namespace Leaf.Scenes;

[Reflect(.Methods), AlwaysInclude(IncludeAllMethods=true)]
class SceneImplicitCast : Leaf.BaseScene
{
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
		//DrawText("hello", pos.x, pos.y, 32, RED);

		if(IsMouseButtonPressed(MouseButton.MOUSE_BUTTON_LEFT))
		{

		}
    }
}