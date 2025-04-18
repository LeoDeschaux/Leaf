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


    public this(TileMap tileMap, Vec2Int tileIndex)
    {
		TileMap = tileMap;
		TileIndex = tileIndex;

		Position = TileMap.GetTilePositionFromIndex(TileIndex);
    }

    public ~this()
    {
    }

    public override void Update()
    {
    }

	//To draw your tile, override this function in your child class
    public override void Draw()
    {
    }

	public void DrawCollision()
	{
	}

	public Tile Clone()
	{
		var clone = new Tile(TileMap, TileIndex);
		clone.Position = Position;
		return clone;
	}
}