using System;
using Leaf;
using RaylibBeef;
using ImGui;
using System.Collections;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;

using static RaylibBeef.Rlgl;

using Jolt;
using static Jolt.Jolt;

namespace Leaf.Scenes;

[Reflect(.Methods), AlwaysInclude(IncludeAllMethods=true)]
class Scene3DJolt : Leaf.BaseScene
{
    private Camera3D camera;
	private Vector3 cubePosition;
	private Vector3 cubeRotation;
	private Vector3 cubeScale;

	private PhysicEngine3D physic = new .() ~ delete _;
	private SpherePhysic spherePhysic;

	public this()
	{
		camera = .(.(0,0,0),.(0,0,0),.(0,0,0),90,0);
		camera.position = .(0.0f, 5.0f, 10.0f);
		camera.target = .(0f, 0f, 0f);
		camera.up = .(0.0f, 1.0f, 0.0f);
		camera.fovy = 45.0f;

		cubePosition = .(0,0,0);
		cubeRotation = .(0,0,0);
		cubeScale = .(1,1,1);

		BackgroundColor = Raylib.WHITE;

		physic.Init();
		physic.StartSimulation();
	}

	public ~this()
	{
		//delete spherePhysic;
	}

	public override void Update()
	{
		physic.Update();

		if(IsKeyPressed(.KEY_SPACE))
		{
			Random r = scope .();
			Vector3 pos = .(0,10,0);
			pos.x = (.)r.NextDoubleSigned();
			Console.WriteLine(pos.x);
			pos.z = (.)r.NextDoubleSigned();
			physic.GenerateSphere(pos, .(0,-5,0), 1);
		}

		if(IsKeyPressed(.KEY_C))
		{
			Random r = scope .();
			Vector3 pos = .(0,10,0);
			pos.x = (.)r.NextDoubleSigned();
			Console.WriteLine(pos.x);
			pos.z = (.)r.NextDoubleSigned();
			physic.GenerateBox(pos, .(0,-5,0), .(1,1,1));
		}

		if(IsKeyPressed(.KEY_J))
		{
			Log.Message("JUMP");
			for(var body in physic.[Friend]bodies)
			{
				body.Velocity.y = 5;
			}
			physic.Apply();
		}
	}

	public static Vector3 QuatToEuler(JPH_Quat q)
	{
	    // Normalize just to be safe
	    float ysqr = q.y * q.y;

	    // Roll (X axis rotation)
	    float t0 = +2.0f * (q.w * q.x + q.y * q.z);
	    float t1 = +1.0f - 2.0f * (q.x * q.x + ysqr);
	    float roll = Math.Atan2(t0, t1);

	    // Pitch (Y axis rotation)
	    float t2 = +2.0f * (q.w * q.y - q.z * q.x);
	    t2 = Math.Clamp(t2, -1.0f, +1.0f);
	    float pitch = Math.Asin(t2);

	    // Yaw (Z axis rotation)
	    float t3 = +2.0f * (q.w * q.z + q.x * q.y);
	    float t4 = +1.0f - 2.0f * (ysqr + q.z * q.z);
	    float yaw = Math.Atan2(t3, t4);

	    // Convert radians → degrees because Raylib uses degrees
	    const float RAD2DEG = 57.2957795f;
	    return .(roll * RAD2DEG, pitch * RAD2DEG, yaw * RAD2DEG);
	}

	public override void Draw()
	{
		var cPos = camera.position;
		UpdateCamera(&camera, 2);
		//camera.position = cPos;

		BeginMode3D(camera);
		{
			//DrawCube(cubePosition, cubeRotation, cubeScale, RED);
		    DrawGrid(10, 1);

			for(var body in physic.[Friend]bodies)
			{
				if(body is SpherePhysic)
					DrawSphere(body.Position, (body as SpherePhysic).Radius, Utils.GetColorFromIndex(body.ID));
				if(body is BoxPhysic)
					DrawCube(body.Position, QuatToEuler(body.Rotation), (body as BoxPhysic).HalfExtents*2f, Utils.GetColorFromIndex(body.ID));
			}
		}
		EndMode3D();
	}
	public override void DrawScreenSpace()
	{
		//DrawRectangle(0,0,100,100, YELLOW);
	}
}