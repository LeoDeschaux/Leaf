using System;
using Leaf;
using RaylibBeef;
using System.Collections;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;

namespace Leaf;

class TileMap : Leaf.Entity
{
	//public List<Tile> Tiles;
	Dictionary<Vec2Int, Tile> mTiles;

	public System.Collections.Dictionary<Vec2Int, Tile>.ValueEnumerator Tiles => mTiles.Values;
	public int Count => mTiles.Count;

	public int TileSize = 100;

	private BaseScene SceneRef;

    public this(BaseScene sceneRef)
    {
		mTiles = new .();
		SceneRef = sceneRef;
    }

    public ~this()
    {
		delete mTiles;
    }

    public override void Update()
    {
    }

    public override void Draw()
    {
    }

	public void AddTile(Vec2Int tileIndex)
	{
		if(mTiles.ContainsKey(tileIndex))
			return;

		var pos = GetTilePositionFromIndex(tileIndex);
		mTiles.TryAdd(tileIndex, new Tile(pos, .(TileSize, TileSize)));
	}

	public bool CanAddTileAtPos(Vec2Int tileIndex)
	{
		return !mTiles.ContainsKey(tileIndex);
	}

	public bool ExistAtIndex(Vec2Int tileIndex)
	{
		return mTiles.ContainsKey(tileIndex);
	}

	public void RemoveTile(Vec2Int tileIndex)
	{
		if(!mTiles.ContainsKey(tileIndex))
			return;

		var tile = mTiles.GetValue(tileIndex);
		mTiles.Remove(tileIndex);
		delete tile.Value;
	}

	public void DeleteAllTiles()
	{
		for(var tile in mTiles.Keys)
			RemoveTile(tile);
		mTiles.Clear();
	}

	public Vector2 GetTilePositionFromIndex(Vec2Int tileIndex)
	{
		Vector2 res = .(0,0);
		res.x = (tileIndex.x * TileSize) + (TileSize/2);
		res.y = (tileIndex.y * TileSize) + (TileSize/2);
		return res;
	}

	public Vector2 GetTileLeftPosFromIndex(Vec2Int tileIndex)
	{
		Vector2 cellPos = GetScreenToWorld2D(GetMousePosition(), SceneRef.Camera);
		int offsetX = cellPos.x < 0 ? -1 : 0;
		int offsetY = cellPos.y < 0 ? -1 : 0;
		cellPos.x = (((int)cellPos.x / TileSize)+offsetX)*TileSize;
		cellPos.y = (((int)cellPos.y / TileSize)+offsetY)*TileSize;
		return cellPos;
	}

	public Vector2 GetTilePositionAtLocation(Vector2 location)
	{
		return .(0,0);
	}

	public Vec2Int GetTileIndex(Vector2 screenPos)
	{
		Vector2 cellPos = GetScreenToWorld2D(screenPos, SceneRef.Camera);
		int offsetX = cellPos.x < 0 ? -1 : 0;
		int offsetY = cellPos.y < 0 ? -1 : 0;
		cellPos.x = (((int)cellPos.x / TileSize)+offsetX);
		cellPos.y = (((int)cellPos.y / TileSize)+offsetY);
		return .((int)cellPos.x, (int)cellPos.y);
	}

	public Vec2Int GetTileIndexFromWorldPos(Vector2 worldPos)
	{
		var cellPos = worldPos;
		int offsetX = cellPos.x < 0 ? -1 : 0;
		int offsetY = cellPos.y < 0 ? -1 : 0;
		cellPos.x = (((int)cellPos.x / TileSize)+offsetX);
		cellPos.y = (((int)cellPos.y / TileSize)+offsetY);
		return .((int)cellPos.x, (int)cellPos.y);
	}
}