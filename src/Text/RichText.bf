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
	public bool Shake = false;

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

		TextSprites = new .();
		for(var char in txt.DecodedChars)
		{
			TextSprites.Add(new TextSprite(new String(char.ToString(.. scope .())), color, font));
		}
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

	public override void Draw()
	{
		if(Scene.DisplayDebug)
		{
			DrawRectangleRec(GetBounds(), .(0,255,0,100));
			DrawText(TextSprites.Count.ToString(.. scope .()), (int32)Position.x, (int32)Position.y, 24, WHITE);
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

		var origin = Position;
		for(int i = 0; i <= index; i++)
		{
			Vector2 offset = .(0,0);
			var ts = TextSprites[i];
			if(ts.Shake || this.Shake)
				offset.y = Math.Sin((float)((GetTime()*waveSpeed) + (lineIndex*waveOffset))) * waveMaxHeight;

			if(ts.Text[0] == '\n')
			{
				origin.y += 50;
				origin.x = Position.x;
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
		Vector2 size = .(0,0);
		for(int i = 0; i < TextSprites.Count; i++)
		{
			var ts = TextSprites[i];
			var endCoord = GetPosition(i) + ts.GetSize();

			size.x = Math.Max(size.x, Math.Abs(Position.x-endCoord.x));
			size.y = Math.Max(size.y, Math.Abs(Position.y-endCoord.y));
		}

		return .(
			Position.x,
			Position.y,
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
}