using System;
using Leaf;
using RaylibBeef;
using System.Collections;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;

namespace Leaf.Scenes;

[Reflect(.Methods), AlwaysInclude(IncludeAllMethods=true)]
class SceneEvents : Leaf.BaseScene
{
    public this()
    {
		Event<delegate void()> OnDeath = default;
		OnDeath.Add(new () => {Log.Message("HOLLA");});
		OnDeath.Add(new => PlayerDeathSFX);
		OnDeath.Invoke();
		OnDeath.Remove(scope => PlayerDeathSFX, true);
		OnDeath.Dispose();
    }

	public void PlayerDeathSFX()
	{
		Log.Message("PLAYER DEATH SFX");
	}

    public ~this()
    {
    }

    public override void Update()
    {
    }

    public override void Draw()
    {
    }
}