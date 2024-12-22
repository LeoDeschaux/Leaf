using System;
using Leaf;
using RaylibBeef;
using System.Collections;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;

namespace Leaf;

class CollisionShape{
	public virtual void Draw(){};
}

class CollisionRectangle : CollisionShape
{
	public Rectangle Rectangle;
}

class CollisionCircle : CollisionShape
{
	public Circle Circle;
	public override void Draw()
	{
		//DrawCircleV(Circle.Position, Circle.Radius, .(0,255,0,100));
		DrawCircleLinesV(Circle.Position, Circle.Radius, GREEN);
	}
}

class PhysicComponent : Leaf.Entity
{
	public CollisionShape CollisionShape;

	private Vector2* ownerPos;

    public this(ref Vector2 ownerPosition)
    {
		DrawOrder = 1000;
		ownerPos = &ownerPosition;

		PhysicsEngine.Components.Add(this);
    }

    public ~this()
    {
		PhysicsEngine.Components.Remove(this);
		delete CollisionShape;
    }

	public override void Update()
	{
		if(var circl = CollisionShape as CollisionCircle)
			circl.Circle.Position = *ownerPos;

		/*
		if(var rec = CollisionShape as CollisionRectangle)
			rec.Rectangle.Center = ownerPos;
		//(CollisionShape as CollisionCircle).Circle.Position = ownerPos;
		*/
	}

    public Vector2 Resolve(Vector2 currentPosition)
    {
		Vector2 newPos = currentPosition;

		for(var other in PhysicsEngine.Components)
		{
			if(other == this)
				continue;

			if(other.CollisionShape is CollisionCircle && this.CollisionShape is CollisionCircle)
			{
				var otherShape = other.CollisionShape as CollisionCircle;
				var selfShape = this.CollisionShape as CollisionCircle;

				//BUG: maybe here ? we are modifying the actual position
				var circle = Circle(newPos, selfShape.Circle.Radius);

				//if(AABB.IsOverlapping(selfShape.Circle, otherShape.Circle))
				newPos = AABB.Resolve(circle, otherShape.Circle);
			}

			/*
			if(other.CollisionShape is CollisionCircle && this.CollisionShape is CollisionRectangle)
			{
				var otherShape = other.CollisionShape as CollisionCircle;
				var selfShape = this.CollisionShape as CollisionRectangle;

				//selfShape.Rectangle.Position = currentPosition;
				newPos = AABB.Resolve(otherShape.Circle, selfShape.Rectangle);
			}
			*/

			if(other.CollisionShape is CollisionRectangle && this.CollisionShape is CollisionCircle)
			{
				var otherShape = other.CollisionShape as CollisionRectangle;
				var selfShape = this.CollisionShape as CollisionCircle;

				//BUG: maybe here ? we are modifying the actual position
				var circle = Circle(newPos, selfShape.Circle.Radius);

				//if(AABB.IsOverlapping(selfShape.Circle, otherShape.Rectangle))
				newPos = AABB.Resolve(circle, otherShape.Rectangle);
				selfShape.Circle.Position = newPos; 
			}

			/*
			if(other.CollisionShape is CollisionRectangle && this.CollisionShape is CollisionRectangle)
			{
				var otherShape = other.CollisionShape as CollisionRectangle;
				var selfShape = this.CollisionShape as CollisionRectangle;

				//selfShape.Rectangle.Position = currentPosition;
				newPos = AABB.Resolve(selfShape.Rectangle, otherShape.Rectangle);
			}
			*/
		}

		/*
		if(AABB.IsColliding(newCircle, mGame.Circle))
			Color = RED;
		else
			Color = GREEN;

		if(AABB.IsOverlapping(newCircle, mGame.Circle))
			Color = RED;
		else if(AABB.IsOverlapping(newCircle, mGame.Block.BoundRec))
			Color = RED;
		else
			Color = GREEN;
		*/

		return newPos;
    }

    public override void Draw()
    {
		CollisionShape.Draw();
    }
}