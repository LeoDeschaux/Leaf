using System;
using Leaf;
using RaylibBeef;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;

namespace Leaf.Scenes;

class SceneOrderedDrawCall : Leaf.BaseScene
{
    public this()
    {
		new OrderedDrawCall(10, new () => {
			DrawRectangle(50,50,150,150,GREEN);
		});

		new OrderedDrawCall(-10, new () => {
			DrawRectangle(0,0,100,100,RED);
		});
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

class OrderedDrawCall : Leaf.Entity
{
	delegate void() drawCallRef;

	public this(int DrawOrder, delegate void () DrawCall)
	{
		this.DrawOrder = DrawOrder;
		drawCallRef = DrawCall;
	}

	public ~this()
	{
		delete drawCallRef;
	}

	public override void Draw()
	{
		drawCallRef?.Invoke();
	}
}