using System;
using Leaf;
using RaylibBeef;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;

namespace Leaf.Scenes;

[Reflect(.Methods), AlwaysInclude(IncludeAllMethods=true)]
class SceneInput : Leaf.BaseScene
{
	InputSystem input;

    public this()
    {
		input = new InputSystem();

		input.BindAction("Jump", new () => IsKeyPressed(KeyboardKey.KEY_SPACE));
		input.BindAction("Jump", new () => IsMouseButtonPressed(MouseButton.MOUSE_BUTTON_LEFT));
		input.BindAction("Jump", new () => IsGamepadButtonPressed(0,GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_DOWN));

		input.BindAxis("YAxis", new () => IsKeyDown(KeyboardKey.KEY_W) ? 1 : 0);
		input.BindAxis("YAxis", new () => IsKeyDown(KeyboardKey.KEY_S) ? -1 : 0);
		input.BindAxis("YAxis", new () => GetGamepadAxisMovement(0, GamepadAxis.GAMEPAD_AXIS_LEFT_Y));
    }

    public ~this()
    {
    }

    public override void Update()
    {
		if(input.Get("Jump"))
			Log.Message("Jump");

		Log.Message(scope $"YAxis:{input.GetAxis("YAxis")}");
    }

    public override void Draw()
    {
    }
}