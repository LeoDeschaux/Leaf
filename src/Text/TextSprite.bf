using System;
using RaylibBeef;

using Leaf;
using System.Collections;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;

namespace Leaf;

public class TextSprite
{
	public String Text;
	public Color Color;
	public Font Font;
	public int FontSize = 128;
	public int Spacing = 20;
	public Vector2 Margin = .(20,20);

	public bool Shake = false;

	public this(String text, Color color, Font font)
	{
		Text = text;
		Color = color;
		Font = font;
	}

	public ~this()
	{
		delete Text;
	}

	public void Draw(Vector2 origin)
	{
		DrawTextPro(Font, Text, origin, .(0,0), 0, (int32)FontSize, Spacing, Color);

		if(GameEngine.CurrentScene.DisplayDebug)
			DrawRectangleLines((int32)origin.x, (int32)origin.y,(int32)GetSize().x, (int32)GetSize().y, RED);
	}

	public Vector2 GetSize()
	{
		return MeasureTextEx(Font, Text, FontSize, Spacing) + Margin;
	}
}