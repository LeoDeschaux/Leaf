using System;
using Leaf;
using RaylibBeef;
using System.Collections;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;

namespace Leaf;

class CollisionShape{
	public Color color = GREEN;
	public virtual void Update(Vector2 ownerPos){};
	public virtual void Draw(){};
}

class CollisionRectangle : CollisionShape
{
	private Vector2 origin;

	public Rectangle rec;
	public Rectangle Rectangle {
		get{
			return Rectangle(
				origin.x+rec.x,
				origin.y+rec.y,
				rec.width,
				rec.height
			);
		}
		set{
			rec = value;
		}
	}

	public override void Update(Vector2 ownerPos)
	{
		origin = ownerPos;
	}
	public override void Draw()
	{
		DrawRectangleLines((int32)Rectangle.x, (int32)Rectangle.y, (int32)Rectangle.width, (int32)Rectangle.height, RED);
	}
}

class CollisionCircle : CollisionShape
{
	public Circle Circle;
	public override void Update(Vector2 ownerPos)
	{
		Circle.Position = ownerPos;
	}

	public override void Draw()
	{
		DrawCircleLinesV(Circle.Position, Circle.Radius, color);
	}
}

class PhysicComponent : Leaf.Entity
{
	public static bool Display = true;

	private CollisionShape collisionShape;
	public CollisionShape CollisionShape {
		get{
			collisionShape.Update(*ownerPos);
			return collisionShape;
		}
		set{
			collisionShape = value;
		}
	};

	private Vector2* ownerPos;
	public Leaf.Entity Owner;

	public delegate void(PhysicComponent other) OnCollision;

	public bool Solid = true;

    public this(Leaf.Entity owner, ref Vector2 ownerPosition)
    {
		DrawOrder = 1000;

		Owner = owner;
		ownerPos = &ownerPosition;

		PhysicsEngine.Components.Add(this);
    }

    public ~this()
    {
		delete OnCollision;
		PhysicsEngine.Components.Remove(this);
		delete CollisionShape;
    }

	public override void Update()
	{
	}

	public bool IsTouching()
	{
		bool isColliding = false;
		bool isOverlapping = false;

		for(var other in PhysicsEngine.Components)
		{
			if(other == this)
				continue;

			if(other.CollisionShape is CollisionCircle && this.CollisionShape is CollisionCircle)
			{
				var otherShape = other.CollisionShape as CollisionCircle;
				var selfShape = this.CollisionShape as CollisionCircle;

				isColliding |= AABB.IsColliding(selfShape.Circle, otherShape.Circle);
				isOverlapping |= AABB.IsOverlapping(selfShape.Circle, otherShape.Circle);
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

				isColliding |= AABB.IsColliding(selfShape.Circle, otherShape.Rectangle);
				isOverlapping |= AABB.IsOverlapping(selfShape.Circle, otherShape.Rectangle);
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

		return isColliding || isOverlapping;
	}

	public Vector2 ResolveMistral(Vector2 currentPosition)
	{
		Vector2 newPos = currentPosition;

		List<Rectangle> rectangles = new .();

		for(var other in PhysicsEngine.Components)
		{
			if(other == this)
				continue;
			if(!other.Solid)
				continue;

			if(other.CollisionShape is CollisionRectangle)
				rectangles.Add((other.CollisionShape as CollisionRectangle).Rectangle);
		}

		if(this.CollisionShape is CollisionCircle)
			newPos = AABB.ResolveMistralTiles((this.CollisionShape as CollisionCircle).Circle, rectangles);

		delete rectangles;

		return newPos;
	}

    public Vector2 Resolve(Vector2 currentPosition)
    {
		Vector2 newPos = currentPosition;

		bool isColliding = false;
		bool isOverlapping = false;

		for(var other in PhysicsEngine.Components)
		{
			if(other == this)
				continue;

			if(!other.Solid)
				continue;

			if(other.CollisionShape is CollisionCircle && this.CollisionShape is CollisionCircle)
			{
				var otherShape = other.CollisionShape as CollisionCircle;
				var selfShape = this.CollisionShape as CollisionCircle;

				//BUG: maybe here ? we are modifying the actual position
				var circle = Circle(newPos, selfShape.Circle.Radius);

				isColliding |= AABB.IsColliding(circle, otherShape.Circle);
				isOverlapping |= AABB.IsOverlapping(circle, otherShape.Circle);

				newPos = AABB.Resolve(circle, otherShape.Circle);
			}

			if(other.CollisionShape is CollisionRectangle && this.CollisionShape is CollisionCircle)
			{
				var otherShape = other.CollisionShape as CollisionRectangle;
				var selfShape = this.CollisionShape as CollisionCircle;

				//BUG: maybe here ? we are modifying the actual position
				var circle = Circle(newPos, selfShape.Circle.Radius);

				isColliding |= AABB.IsColliding(circle, otherShape.Rectangle);
				isOverlapping |= AABB.IsOverlapping(circle, otherShape.Rectangle);

				//newPos = AABB.Resolve(circle, otherShape.Rectangle);
				newPos = AABB.ResolveMistral(circle, otherShape.Rectangle);
			}
		}

		if(isColliding || isOverlapping)
			CollisionShape.color = RED;
		else
			CollisionShape.color = GREEN;

		return newPos;
    }

	public bool Intersect(PhysicComponent other)
	{
		bool isColliding = false;
		bool isOverlapping = false;

		if(other == this)
			return false;

		if(other.CollisionShape is CollisionCircle && this.CollisionShape is CollisionCircle)
		{
			var otherShape = other.CollisionShape as CollisionCircle;
			var selfShape = this.CollisionShape as CollisionCircle;

			isColliding |= AABB.IsColliding(selfShape.Circle, otherShape.Circle);
			isOverlapping |= AABB.IsOverlapping(selfShape.Circle, otherShape.Circle);
		}

		if(other.CollisionShape is CollisionCircle && this.CollisionShape is CollisionRectangle)
		{
			var otherShape = other.CollisionShape as CollisionCircle;
			var selfShape = this.CollisionShape as CollisionRectangle;

			isColliding |= AABB.IsColliding(otherShape.Circle, selfShape.Rectangle);
			isOverlapping |= AABB.IsOverlapping(otherShape.Circle, selfShape.Rectangle);
		}

		if(other.CollisionShape is CollisionRectangle && this.CollisionShape is CollisionCircle)
		{
			var otherShape = other.CollisionShape as CollisionRectangle;
			var selfShape = this.CollisionShape as CollisionCircle;

			isColliding |= AABB.IsColliding(selfShape.Circle, otherShape.Rectangle);
			isOverlapping |= AABB.IsOverlapping(selfShape.Circle, otherShape.Rectangle);
		}

		if(other.CollisionShape is CollisionRectangle && this.CollisionShape is CollisionRectangle)
		{
			var otherShape = other.CollisionShape as CollisionRectangle;
			var selfShape = this.CollisionShape as CollisionRectangle;

			isColliding |= AABB.IsColliding(selfShape.Rectangle, otherShape.Rectangle);
			isOverlapping |= AABB.IsOverlapping(selfShape.Rectangle, otherShape.Rectangle);
		}

		return isColliding || isOverlapping;
	}

	public List<PhysicComponent> GetCollidingComponents()
	{
		List<PhysicComponent> collidingActors = new .();


		for(var other in PhysicsEngine.Components)
		{
			bool isColliding = false;
			bool isOverlapping = false;

			if(other == this)
				continue;

			if(other.CollisionShape is CollisionCircle && this.CollisionShape is CollisionCircle)
			{
				var otherShape = other.CollisionShape as CollisionCircle;
				var selfShape = this.CollisionShape as CollisionCircle;


				isColliding |= AABB.IsColliding(selfShape.Circle, otherShape.Circle);
				isOverlapping |= AABB.IsOverlapping(selfShape.Circle, otherShape.Circle);
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

				isColliding |= AABB.IsColliding(selfShape.Circle, otherShape.Rectangle);
				isOverlapping |= AABB.IsOverlapping(selfShape.Circle, otherShape.Rectangle);
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

			if(isColliding || isOverlapping)
				collidingActors.Add(other);
		}

		return collidingActors;
	}

    public override void Draw()
    {
		if(Display)
			CollisionShape.Draw();
    }
}