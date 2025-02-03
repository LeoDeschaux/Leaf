using System;
using Leaf;
using RaylibBeef;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;

namespace Leaf.Scenes;

class SceneTexturePaint : Leaf.BaseScene
{

	Texture2D canvas;

    public this()
    {
		//generate white canvas
		//canvas = //GenTextureMipmaps();

		//stencil draw

    }

    public ~this()
    {
    }

    public override void Update()
    {
    }

    public override void Draw()
    {
		DrawTexture(canvas, 0,0,WHITE);
    }
}