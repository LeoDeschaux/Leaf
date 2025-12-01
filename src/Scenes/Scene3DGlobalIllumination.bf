using System;
using Leaf;
using RaylibBeef;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;

using static RaylibBeef.Rlgl;

using ImGui;
using Leaf.Serialization;

namespace Leaf.Scenes;

[Reflect(.Methods), AlwaysInclude(IncludeAllMethods=true)]
class Scene3DGlobalIllumination : Leaf.BaseScene
{
	Camera camera;
	Model model;
	Vector3 position;
	Texture2D texture;

	float scale;

	[AutoConfig]
	float cameraSpeed = 200;

	[AutoConfig]
	float cameraSensitivity = 0.3f;

    public this()
    {
		camera.position = .(6.0f, 6.0f, 6.0f);
		camera.target = .(0.0f, 0.0f, 0.0f);
		camera.up = .(0.0f, 1.0f, 0.0f);
		camera.fovy = 45.0f;
		camera.projection = 0; // camera projection

		//model = LoadModel("res/models/crytek_sponza/sponza.obj");
		model = LoadModel("res/models/sponza-atrium-3/source/glTF/glTF/Sponza.gltf");
		
		position = .(0.0f, 0.0f, 0.0f);
		scale = 1f;

		/*
		texture = LoadTexture("res/models/crytek_sponza/bridge_diffuse.png");
		model.materials[0].maps[MaterialMapIndex.MATERIAL_MAP_ALBEDO].texture = texture;
		*/

		for (int i = 0; i < model.materialCount; i++)
		{
		    Log.Message(scope $"Material {i}");
		    for (int m = 0; m < 12; m++)
		    {
				//model.materials[i].maps[m].color = Utils.GetColorFromIndex(i);

		        if (model.materials[i].maps[m].texture.id != 0)
		            Log.Message(scope $"   Map {m} loaded: {model.materials[i].maps[m].texture.id}");
		    }
		}

		SetGamepadVibration(0, 1,1, 10);
    }

    public ~this()
    {
		UnloadModel(model);
		UnloadTexture(texture);
    }

    public override void Update()
    {
		//UpdateCamera(&camera, CameraMode.CAMERA_FREE);

		Vector3 dir = .(0,0,0);

		if(IsKeyDown(KeyboardKey.KEY_W))
			dir.x += 1;
		if(IsKeyDown(KeyboardKey.KEY_S))
			dir.x -= 1;
		if(IsKeyDown(KeyboardKey.KEY_A))
			dir.y -= 1;
		if(IsKeyDown(KeyboardKey.KEY_D))
			dir.y += 1;

		if(IsKeyDown(KeyboardKey.KEY_Q))
			dir.z -= 1;
		if(IsKeyDown(KeyboardKey.KEY_E))
			dir.z += 1;

		Vector3 deltaRot = .(0,0,0);

		if(IsMouseButtonDown(.MOUSE_BUTTON_RIGHT))
		{
			deltaRot.x = GetMouseDelta().x;
			deltaRot.y = GetMouseDelta().y;

			DisableCursor();
		}

		deltaRot *= cameraSensitivity;

		if(IsMouseButtonReleased(.MOUSE_BUTTON_RIGHT))
			EnableCursor();

		cameraSpeed += cameraSpeed * (GetMouseWheelMove()*0.5f);
		//cameraSpeed += GetMouseWheelMove()*10f;
		cameraSpeed = Math.Clamp(cameraSpeed, 0.1f, 500);

		Vector3 camMove = dir * cameraSpeed * Time.DeltaTime;

		bool lockView = true;
		bool rotateAroundTarget = false;
		bool rotateUp = false;

		bool moveInWorldPlane = false;

		// Camera rotation
		CameraPitch(&camera, -deltaRot.y*DEG2RAD, lockView, rotateAroundTarget, rotateUp);
		CameraYaw(&camera, -deltaRot.x*DEG2RAD, rotateAroundTarget);
		CameraRoll(&camera, deltaRot.z*DEG2RAD);

		// Camera movement
		CameraMoveForward(&camera, camMove.x, moveInWorldPlane);
		CameraMoveRight(&camera, camMove.y, moveInWorldPlane);
		CameraMoveUp(&camera, camMove.z);
    }

    public override void Draw()
    {
	    ClearBackground(BLACK);

	    BeginMode3D(camera);

	        DrawModel(model, position, scale, WHITE);
			DrawGrid(10, 1.0f);
	    EndMode3D();


		ImGui.SliderFloat3(nameof(camera.position), ref camera.position, -10, 10);

		if(ImGui.Button("ResetPos"))
		{
			camera.position = .(6.0f, 6.0f, 6.0f);
			camera.target = .(0.0f, 0.0f, 0.0f);
			camera.up = .(0.0f, 1.0f, 0.0f);
			camera.fovy = 45.0f;
			camera.projection = 0; // camera projection
		}
    }

	// CAMERA CONTROLLER
	Vector3 GetCameraForward(Camera *camera)
	{
	    return Vector3Normalize(Vector3Subtract(camera.target, camera.position));
	}

	Vector3 GetCameraRight(Camera *camera)
	{
	    Vector3 forward = GetCameraForward(camera);
	    Vector3 up = GetCameraUp(camera);

	    return Vector3Normalize(Vector3CrossProduct(forward, up));
	}

	Vector3 GetCameraUp(Camera *camera)
	{
	    return Vector3Normalize(camera.up);
	}

	void CameraMoveForward(Camera *camera, float distance, bool moveInWorldPlane)
	{
	    Vector3 forward = GetCameraForward(camera);

	    if (moveInWorldPlane)
	    {
	        // Project vector onto world plane
	        forward.y = 0;
	        forward = Vector3Normalize(forward);
	    }

	    // Scale by distance
	    forward = Vector3Scale(forward, distance);

	    // Move position and target
	    camera.position = Vector3Add(camera.position, forward);
	    camera.target = Vector3Add(camera.target, forward);
	}

	// Moves the camera target in its current right direction
	void CameraMoveRight(Camera *camera, float distance, bool moveInWorldPlane)
	{
	    Vector3 right = GetCameraRight(camera);

	    if (moveInWorldPlane)
	    {
	        // Project vector onto world plane
	        right.y = 0;
	        right = Vector3Normalize(right);
	    }

	    // Scale by distance
	    right = Vector3Scale(right, distance);

	    // Move position and target
	    camera.position = Vector3Add(camera.position, right);
	    camera.target = Vector3Add(camera.target, right);
	}

	// Moves the camera in its up direction
	void CameraMoveUp(Camera *camera, float distance)
	{
	    Vector3 up = GetCameraUp(camera);

	    // Scale by distance
	    up = Vector3Scale(up, distance);

	    // Move position and target
	    camera.position = Vector3Add(camera.position, up);
	    camera.target = Vector3Add(camera.target, up);
	}

	// Rotates the camera around its up vector
	// Yaw is "looking left and right"
	// If rotateAroundTarget is false, the camera rotates around its position
	// Note: angle must be provided in radians
	void CameraYaw(Camera *camera, float angle, bool rotateAroundTarget)
	{
	    // Rotation axis
	    Vector3 up = GetCameraUp(camera);

	    // View vector
	    Vector3 targetPosition = Vector3Subtract(camera.target, camera.position);

	    // Rotate view vector around up axis
	    targetPosition = Vector3RotateByAxisAngle(targetPosition, up, angle);

	    if (rotateAroundTarget)
	    {
	        // Move position relative to target
	        camera.position = Vector3Subtract(camera.target, targetPosition);
	    }
	    else // rotate around camera.position
	    {
	        // Move target relative to position
	        camera.target = Vector3Add(camera.position, targetPosition);
	    }
	}

	// Rotates the camera around its right vector, pitch is "looking up and down"
	//  - lockView prevents camera overrotation (aka "somersaults")
	//  - rotateAroundTarget defines if rotation is around target or around its position
	//  - rotateUp rotates the up direction as well (typically only usefull in CAMERA_FREE)
	// NOTE: angle must be provided in radians
	void CameraPitch(Camera *camera, float angle, bool lockView, bool rotateAroundTarget, bool rotateUp)
	{
		var angle;

	    // Up direction
	    Vector3 up = GetCameraUp(camera);

	    // View vector
	    Vector3 targetPosition = Vector3Subtract(camera.target, camera.position);

	    if (lockView)
	    {
	        // In these camera modes we clamp the Pitch angle
	        // to allow only viewing straight up or down.

	        // Clamp view up
	        float maxAngleUp = Vector3Angle(up, targetPosition);
	        maxAngleUp -= 0.001f; // avoid numerical errors
	        if (angle > maxAngleUp) angle = maxAngleUp;

	        // Clamp view down
	        float maxAngleDown = Vector3Angle(Vector3Negate(up), targetPosition);
	        maxAngleDown *= -1.0f; // downwards angle is negative
	        maxAngleDown += 0.001f; // avoid numerical errors
	        if (angle < maxAngleDown) angle = maxAngleDown;
	    }

	    // Rotation axis
	    Vector3 right = GetCameraRight(camera);

	    // Rotate view vector around right axis
	    targetPosition = Vector3RotateByAxisAngle(targetPosition, right, angle);

	    if (rotateAroundTarget)
	    {
	        // Move position relative to target
	        camera.position = Vector3Subtract(camera.target, targetPosition);
	    }
	    else // rotate around camera.position
	    {
	        // Move target relative to position
	        camera.target = Vector3Add(camera.position, targetPosition);
	    }

	    if (rotateUp)
	    {
	        // Rotate up direction around right axis
	        camera.up = Vector3RotateByAxisAngle(camera.up, right, angle);
	    }
	}

	// Rotates the camera around its forward vector
	// Roll is "turning your head sideways to the left or right"
	// Note: angle must be provided in radians
	void CameraRoll(Camera *camera, float angle)
	{
	    // Rotation axis
	    Vector3 forward = GetCameraForward(camera);

	    // Rotate up direction around forward axis
	    camera.up = Vector3RotateByAxisAngle(camera.up, forward, angle);
	}
}