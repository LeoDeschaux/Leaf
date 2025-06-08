using System;
using Leaf;
using RaylibBeef;
using System.Collections;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;

namespace Leaf;

public class RichText : Leaf.Entity
{
	public List<TextSprite> TextSprites;
	public Vector2 Position = .(0,0);
	public Vector2 Origin = .(0,0);
	public bool Shake = false;

	public Vector2 RelativePos => Position-Origin;

	Font m_font;
	Color m_color;

	public this()
	{
		TextSprites = new .();
	}

	public this(String txt, Vector2 position = .(0,0), Color color = WHITE, Font font = default)
	{
		var font;
		if(font == default)
			font = GetFontDefault();

		Position = position;
		m_font = font;
		m_color = color;

		TextSprites = new .();
		this.Set(txt);
	}

	public ~this()
	{
		for(var ts in TextSprites)
			delete ts;
		delete TextSprites;
	}

	public void Add(TextSprite textSprite)
	{
		TextSprites.Add(textSprite);
	}

	public void PlainText(String outBuffer)
	{
		for(var ts in TextSprites)
		{
			outBuffer.Append(ts.Text);
		}
	}

	public void Set(String txt)
	{
		Clear();

		for(var char in txt.DecodedChars)
		{
			var ts = new TextSprite(new String(char.ToString(.. scope .())), m_color, m_font);
			TextSprites.Add(ts);
		}
	}	

	private void Clear()
	{
		for(var ts in TextSprites)
			delete ts;
		TextSprites.Clear();
	}

	public override void Draw()
	{
		if(Scene.DisplayDebug)
		{
			DrawCircleV(Position, 12, RED);
			DrawRectangleRec(GetBounds(), .(0,255,0,100));
			DrawText(TextSprites.Count.ToString(.. scope .()), (int32)RelativePos.x, (int32)RelativePos.y, 24, WHITE);
		}

		for(int i = 0; i < TextSprites.Count; i++)
		{
			var ts = TextSprites[i];
			var pos = GetPosition(i);
			ts.Draw(pos);
		}
	}

	public Vector2 GetPosition(int index)
	{
		var res = Vector2(0,0);

		float waveSpeed = 4;
		float waveMaxHeight = 10;
		float waveOffset = 0.4f;

		int lineIndex = 0;

		var relativePos = Position-Origin;
		var origin = relativePos;
		for(int i = 0; i <= index; i++)
		{
			Vector2 offset = .(0,0);
			var ts = TextSprites[i];
			if(ts.Shake || this.Shake)
				offset.y = Math.Sin((float)((GetTime()*waveSpeed) + (lineIndex*waveOffset))) * waveMaxHeight;

			if(ts.Text[0] == '\n')
			{
				origin.y += ts.GetSize().y;
				origin.x = relativePos.x;
				lineIndex = 0;
			}

			var pos = origin+offset;
			res = pos;

			origin.x += ts.GetSize().x;

			lineIndex++;
		}

		return res;
	}

	public Rectangle GetBounds()
	{
		var relativePos = Position-Origin;

		Vector2 size = .(0,0);
		for(int i = 0; i < TextSprites.Count; i++)
		{
			var ts = TextSprites[i];
			var endCoord = GetPosition(i) + ts.GetSize();

			size.x = Math.Max(size.x, Math.Abs(relativePos.x-endCoord.x));
			size.y = Math.Max(size.y, Math.Abs(relativePos.y-endCoord.y));
		}

		return .(
			relativePos.x,
			relativePos.y,
			size.x,
			size.y
		);
	}

	public Rectangle GetBounds(int index)
	{
		var index;
		if(index >= TextSprites.Count)
		{
			index = TextSprites.Count-1;
			var p = GetPosition(index);
			var size = this.TextSprites[index].GetSize();
			return .(
				p.x + size.x,
				p.y,
				0,
				size.y
			);
		}

		var pos = GetPosition(index);
		var size = this.TextSprites[index].GetSize();
		return .(
			pos.x,
			pos.y,
			size.x,
			size.y
		);
	}

	public void SetCentered()
	{
		Origin = GetBounds().Size/2;
	}
}