using System;
using Leaf;
using RaylibBeef;
using System.Collections;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;

namespace Leaf.Scenes;

class ScenePhysics : Leaf.BaseScene
{
	PhysicComponent phc;
	Vector2 position = .(200,200);

    public this()
    {
		phc = new PhysicComponent(this, ref position);
		phc.Owner = this;
		var clC = new CollisionCircle();
		clC.Circle = .(.(0,0), 50);
		phc.CollisionShape = clC;
		phc.OnCollision = new (other) => {
		};
    }

    public ~this()
    {
    }

    public override void Update()
    {
		Vector2 rayStart = .(0,0);
		Vector2 rayEnd = GetScreenToWorld2D(GetMousePosition(), Scene.Camera);
		List<RaycastResult> res = new .();
		Raycast.RayIntersect(rayStart, rayEnd, res);
		delete res;

		if(IsKeyDown(KeyboardKey.KEY_LEFT_CONTROL))
		{
			position = rayEnd;
		}
    }

    public override void Draw()
    {
    }
}