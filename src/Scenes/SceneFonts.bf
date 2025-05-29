using System;
using Leaf;
using RaylibBeef;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;

namespace Leaf.Scenes;

[Reflect(.Methods), AlwaysInclude(IncludeAllMethods=true)]
class SceneFonts : Leaf.BaseScene
{
	char8* text = "!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHI\nJKLMNOPQRSTUVWXYZ[]^_`abcdefghijklmn\nopqrstuvwxyz{|}~¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓ\nÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷\nøùúûüýþÿ";
	Font font;

	int32* codepoints;
	int32 codepointCount = 0;

    public this()
    {
		codepoints = LoadCodepoints(text, &codepointCount);
		font = LoadFontEx("res/typewriter.ttf", 128, codepoints, codepointCount);
		SetTextLineSpacing(50);
    }

    public ~this()
    {
		UnloadFont(font);
    }

    public override void Update()
    {
		if(IsKeyPressed(.KEY_SPACE))
		{
			UnloadFont(font);
			font = LoadFontEx("res/typewriter.ttf", 128, codepoints, codepointCount);
		}
    }

    public override void Draw()
    {
		// Draw provided text with laoded font, containing all required codepoint glyphs
		DrawTextEx(font, text, .(160, 0), 48, 5, WHITE);

        // Draw generated font texture atlas containing provided codepoints
        DrawTexture(font.texture, 150, 400, WHITE);
        DrawRectangleLines(150, 400, font.texture.width, font.texture.height, WHITE);
    }
}