using System;
using Leaf;
using RaylibBeef;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;

namespace Leaf;

class Tile : Leaf.Entity
{
	public Vector2 Position;
	public Vector2 Size;
	public Color Color = BLUE;

	public PhysicComponent physicComponent;

    public this(Vector2 position, Vector2 size, Color color)
    {
		Position = position;
		Size = size;
		Color = color;

		physicComponent = new .(ref Position);
		physicComponent.OnDelete = new () => {
		  physicComponent = null;
		};

		var clR = new CollisionRectangle();
		clR.Rectangle = .(
			Position.x-Size.x/2,
			Position.y-Size.y/2,
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

    public override void Draw()
    {
		var rec = (physicComponent.CollisionShape as CollisionRectangle).Rectangle;
		DrawRectangleRec(rec, Color);
    }
}