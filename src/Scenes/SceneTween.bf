using System;
using Leaf;
using RaylibBeef;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;

namespace Leaf.Scenes;

[Reflect(.Methods), AlwaysInclude(IncludeAllMethods=true)]
class SceneTween : Leaf.BaseScene
{
	public DumbTween dumb = new DumbTween() ~ delete _;
	float start;

    public this()
    {
		start = 1f;
		float end = 0f;
		dumb.Play(ref start, end, 2f, new => Tween.EaseLinearIn);
    }

    public ~this()
    {
    }

    public override void Update()
    {
		dumb.Update();
		Log.Message(start);
    }

    public override void Draw()
    {
    }
}