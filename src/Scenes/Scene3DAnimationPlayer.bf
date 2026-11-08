using System;
using Leaf;
using RaylibBeef;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;

namespace Leaf.Scenes;

[Reflect(.Methods), AlwaysInclude(IncludeAllMethods=true)]
class Scene3DAnimationPlayer : Leaf.BaseScene
{
	Camera camera;
	Model model;
	Vector3 position;

	int32 animsCount;
	int32 animIndex;
	int32 animCurrentFrame;
	ModelAnimation* modelAnimations;
	ModelAnimation anim;

    public this()
    {
		camera.position = .(6.0f, 6.0f, 6.0f);
		camera.target = .(0.0f, 2.0f, 0.0f);
		camera.up = .(0.0f, 1.0f, 0.0f);
		camera.fovy = 45.0f;
		camera.projection = 0; // camera projection

		model = LoadModel("res/models/gltf/robot.glb");
		position = .(0.0f, 0.0f, 0.0f);

		animsCount = 0;
		animIndex = 0;
		animCurrentFrame = 0;
		modelAnimations = LoadModelAnimations("res/models/gltf/robot.glb", &animsCount);

		SetTargetFPS(60);
    }

    public ~this()
    {
		UnloadModel(model);
    }

    public override void Update()
    {
		UpdateCamera(&camera, CameraMode.CAMERA_ORBITAL);

		// Select current animation
		if (IsMouseButtonPressed(MouseButton.MOUSE_BUTTON_RIGHT)) animIndex = (animIndex + 1)%animsCount;
		else if (IsMouseButtonPressed(MouseButton.MOUSE_BUTTON_LEFT)) animIndex = (animIndex + animsCount - 1)%animsCount;

		// Update model animation
		anim = modelAnimations[animIndex];
		animCurrentFrame = (animCurrentFrame + 1)%anim.frameCount;
		UpdateModelAnimation(model, anim, animCurrentFrame);
    }

    public override void Draw()
    {
	    ClearBackground(RAYWHITE);

	    BeginMode3D(camera);
	        DrawModel(model, position, 1.0f, WHITE);
	        DrawGrid(10, 1.0f);
	    EndMode3D();

	    DrawText("Use the LEFT/RIGHT mouse buttons to switch animation", 10, 10, 20, GRAY);
	    DrawText(&anim.name, 10, GetScreenHeight() - 20, 10, DARKGRAY);
    }
}