using System;
using RaylibBeef;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;

namespace Leaf;

class Sprite
{
	public Vector2 position = .(0,0);
	public Vector2 size = .(0,0);
	public Vector2 scale = .(1,1);
	public float rotation = 0;
	public Color color = WHITE;
	public Vector2 Center = .(0,0);

	public bool flipX = false;
	public bool flipY = false;
	public bool display = true;

	public Texture2D texture;


	public this()
	{

	}

	public ~this()
	{
	}

	public void LoadTexture(char8* path)
	{
		texture = Raylib.LoadTexture(path);
		//size.x = texture.width;
		//size.y = texture.height;
	}

	public void Draw()
	{
		if(!display)
			return;

		Vector2 center = size * scale * Center;
		DrawTexturePro(
			texture,
			Rectangle(0,0,texture.width * (flipX ? -1 : 1) ,texture.height * (flipY ? -1 : 1)),
			Rectangle(position.x,position.y,size.x * scale.x,size.y * scale.y),
			center,
			rotation,
			color
		);
	}

	public Rectangle GetButtonRectangle()
	{
		/*
		return Rectangle(
			position.x-((size.x*scale.x)*Center.x),
			position.y-((size.y*scale.y)*Center.y),
			size.x*scale.x,
			size.y*scale.y
		);
		*/

		Vector2 btnSize = .(200,200);

		return Rectangle(
			position.x-((btnSize.x*scale.x)*Center.x),
			position.y-((btnSize.y*scale.y)*Center.y),
			btnSize.x*scale.x,
			btnSize.y*scale.y
		);
	}
}