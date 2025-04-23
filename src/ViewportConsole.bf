using System;
using RaylibBeef;
using static RaylibBeef.Raylib;
namespace Leaf;

class ViewportConsole
{
	static int lineIndex = 0;
	static float xMargin = 10;
	static float ySpacing = 30;
	static int fontSize = 24;

	static Vector2 m_offset = .(0,0);

	public static void NewFrame()
	{
		lineIndex = 0;
	}

	public static void SetOffSet(Vector2 offset)
	{
		m_offset = offset;
	}

	public static void Log(char8* text, Color color)
	{
		DrawText(text, (int32)(xMargin+m_offset.x), (int32)((lineIndex*ySpacing)+m_offset.y), (int32)fontSize, color);
		lineIndex++;
	}

	public static void Log(String text, Color color)
	{
		DrawText(text, (int32)(xMargin+m_offset.x), (int32)((lineIndex*ySpacing)+m_offset.y), (int32)fontSize, color);
		lineIndex++;
	}

	public static void Log(StringView text, Color color)
	{
		DrawText(scope String(text), (int32)(xMargin+m_offset.x), (int32)((lineIndex*ySpacing)+m_offset.y), (int32)fontSize, color);
		lineIndex++;
	}

	public static void Log(Object obj, Color color)
	{
		String str = scope String(256);
		if (obj == null)
			str.Append("null");
		else
			obj.ToString(str);
		DrawText(str, (int32)(xMargin+m_offset.x), (int32)((lineIndex*ySpacing)+m_offset.y), (int32)fontSize, color);
		lineIndex++;
	}

	/*
	public static void Log(StringView text, Color color)
	{
		DrawText(text.Ptr, (int32)(xMargin+m_offset.x), (int32)((lineIndex*ySpacing)+m_offset.y), (int32)fontSize, color);
		lineIndex++;
	}
	*/
}