using System;
using Leaf;
using RaylibBeef;
using System.Collections;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;

namespace Leaf.Scenes;

[Reflect(.Methods), AlwaysInclude(IncludeAllMethods=true)]
class SceneTextMesh : Leaf.BaseScene
{
	RichText tm;

	char8* alphabet = "!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHI\nJKLMNOPQRSTUVWXYZ[]^_`abcdefghijklmn\nopqrstuvwxyz{|}~¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓ\nÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷\nøùúûüýþÿ";
	Font font;// = new .(0,0,0,default,default,default);
	int32* codepoints;
	int32 codepointCount = 0;

    public this()
    {
		Camera.target = .(GetScreenWidth()/2f, 0);

		tm = new .();

		codepoints = LoadCodepoints(alphabet, &codepointCount);
		font = LoadFontEx("res/fonts/Arial.ttf", 128, codepoints, codepointCount);

		/*
		String text = @"""
		This is a random text with random colors
		""";
		*/

		String text = scope String(alphabet);

		for(var c in text.DecodedChars)
		{
			tm.Add(new TextSprite(
				new $"{c}",
				WHITE,
				/*
				Color(
					(uint8)GetRandomValue(0,255),
					(uint8)GetRandomValue(0,255),
					(uint8)GetRandomValue(0,255),
					255),
				*/
				font)
			);
		}

		tm.TextSprites[0].Color = RED;

		for(var ts in tm.TextSprites)
		{
			//ts.FontSize = 48;
			ts.Spacing = 0;
			ts.Margin.x = 10;
		}

		tm.Origin = tm.GetBounds().Size/2;
    }

    public ~this()
    {
    }

	protected override void Restart()
	{
		var Cam = this.Camera;

		base.Restart(new (newScene) => {
			newScene.Camera = Cam;
		});
	}

	int letterIndex = 0;

    public override void Update()
    {
		if(IsKeyPressed(KeyboardKey.KEY_SPACE))
		{
			letterIndex++;
			tm.TextSprites[letterIndex%tm.TextSprites.Count].Color = RED;
		}
    }

    public override void Draw()
    {
		//DrawTextEx(font, alphabet, .(160, 600), 48, 5, WHITE);
		DrawCircleV(.(0,0), 12, GRAY);
		DrawLineV(.(0,-50000),.(0,50000), GRAY);
		DrawLineV(.(-50000,0),.(50000,0), GRAY);
    }

	public override void DrawScreenSpace()
	{
		//DrawGuide();
	}
}

