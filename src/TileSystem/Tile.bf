using System;
using Leaf;
using RaylibBeef;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;

namespace Leaf;

class Tile : Leaf.Entity
{
	public Vec2Int TileIndex;
	public TileMap TileMap;

	public Vector2 Position;
	public Vector2 Size => .(TileMap.TileSize, TileMap.TileSize);

	public PhysicComponent physicComponent;

    public this(TileMap tileMap, Vec2Int tileIndex)
    {
		TileMap = tileMap;
		TileIndex = tileIndex;

		Position = TileMap.GetTilePositionFromIndex(TileIndex);

		physicComponent = new .(this, ref Position);
		physicComponent.OnDelete = new () => {
		  physicComponent = null;
		};

		var clR = new CollisionRectangle();
		/*
		clR.Rectangle = .(
			Position.x-Size.x/2,
			Position.y-Size.y/2,
			Size.x,
			Size.y
		);
		clR.Origin = .(-Size.x/2, -Size.y/2);
		*/
		clR.Rectangle = .(
			-Size.x/2f,
			-Size.y/2f,
			Size.x,
			Size.y
		);
		physicComponent.CollisionShape = clR;
    }

    public ~this()
    {
		if(physicComponent != null)
			delete physicComponent;
    }

    public override void Update()
    {
    }

	//To draw your tile, override this function in your child class
    public override void Draw()
    {
		var rec = (physicComponent.CollisionShape as CollisionRectangle).Rectangle;
		DrawRectangleRec(rec, PINK);
    }

	public void DrawCollision()
	{
		var rec = (physicComponent.CollisionShape as CollisionRectangle).Rectangle;
		DrawRectangleLinesEx(rec, 2f, GREEN);
	}
}