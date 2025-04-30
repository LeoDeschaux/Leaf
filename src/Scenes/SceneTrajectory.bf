using System;
using Leaf;
using RaylibBeef;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;

namespace Leaf.Scenes;

[Reflect(.Methods), AlwaysInclude(IncludeAllMethods=true)]
class SceneTrajectory : Leaf.BaseScene
{
	bool launched = false;
	Vector2 position = .(0,0);
	Vector2 velocity = .(0,0);

	[AutoConfig]
	Vector2 startPos = .(0,0);
	[AutoConfig]
	Vector2 endPos = .(400,0);
	[AutoConfig]
	float height = 200f;
	[AutoConfig]
	float gravity = 9.81f;
	[AutoConfig]
	float duration = 1f;

    public this()
    {
    }

    public ~this()
    {
    }

    public override void Update()
    {
		if(IsKeyPressed(KeyboardKey.KEY_SPACE))
		{
			Launch();
		}

		if(launched)
		{
			velocity.y += gravity * Time.DeltaTime;
			position += velocity * Time.DeltaTime;
		}

		if(Vector2.Distance(position, endPos) < 10)
		{
			launched = false;
		}	 
    }

	public void Launch()
	{
		position = startPos;
		//var res = Trajectory.CalculateLaunchDataG(startPos, endPos, height, gravity);
		var res = Trajectory.CalculateLaunchData(startPos, endPos, height, duration);
		velocity = res.initialVelocity;
		gravity = res.gravity;
		duration = res.timeToTarget;
		launched = true;
	}

    public override void Draw()
    {
		Trajectory.DrawPath(startPos, endPos, height, gravity, duration);
		DrawCircleV(position, 12, WHITE);

		DrawCircleV(startPos, 6, BLACK);
		DrawCircleV(endPos, 6, BLACK);
    }
}