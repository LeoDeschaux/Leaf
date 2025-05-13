using System;
using Leaf;
using RaylibBeef;
using System.Collections;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;
using static RaylibAsepriteBeef.RaylibAseprite;

namespace Leaf;

class AnimatedSprite : Leaf.Entity
{
	Aseprite* ase;
	AsepriteTag tag;

	public Vector2 Pos;
	public Vector2 Size = .(100,100);
	public float Rotation;

	public bool FlipX = false;
	public bool FlipY = false;

    public this(String path)
    {
		ase = AssetLoader.Load<Aseprite>(path);
    }

    public ~this()
    {
    }

	public void PlayDefault()
	{
		tag = LoadAsepriteTagFromIndex(*ase, 0);
	}

	public void Play(String animName)
	{
		tag = LoadAsepriteTag(*ase, animName);
	}

	public bool IsCurrentlyPlaying(String animName)
	{
		return animName.Equals(scope String(tag.name));
	}

	private static List<String> GetTagsName(Aseprite ase)
	{
		var res = new List<String>();
		var count = GetAsepriteTagCount(ase);
		for(int i = 0; i < count; i++)
		{
			var t = LoadAsepriteTagFromIndex(ase, (int32)i);
			res.Add(new String(t.name));
		}
		return res;
	}

    public override void Update()
    {
		UpdateAsepriteTag(&tag);
    }

    public override void Draw()
    {
		Rectangle destRec = .(Pos.x,Pos.y,Size.x, Size.y);
		Vector2 origin = .((float)Size.x/2f, (float)Size.y/2f);

		DrawAsepriteTagProFlipped(tag, destRec, origin, Rotation, FlipX, FlipY, WHITE);
    }
}