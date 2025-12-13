using System;
using Leaf;
using RaylibBeef;
using ImGui;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;

namespace Leaf.Scenes;

[Reflect(.Methods), AlwaysInclude(IncludeAllMethods=true)]
class Scene3DCamera : Leaf.BaseScene
{
    private Camera3D camera;
	private Vector3 cubePosition;
	private Vector3 cubeRotation;
	private Vector3 cubeScale;

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
	}

	public override void Update()
	{

	}

	public override void Draw()
	{
		UpdateCamera(&camera, 2);

		BeginMode3D(camera);
		{
			DrawCube(cubePosition, cubeRotation, cubeScale, RED);
		    DrawGrid(10, 1);
		}
		EndMode3D();

		ImGui.ShowDemoWindow();
		
		ImGui.SliderFloat3("Position", ref cubePosition, -5,5);
		ImGui.SliderFloat3("Rotation", ref cubeRotation, -180,180);
		ImGui.SliderFloat3("Scale", ref cubeScale, 0,5);
	}
	public override void DrawScreenSpace()
	{
		DrawRectangle(0,0,100,100, YELLOW);

		//DrawText(ImGui.VERSION_NUM.ToString(.. scope .()),0,0,50,RED);

		//DrawText(ImGui.GetWindowSize().x.ToString(.. scope .()),0,0,50,RED);
		DrawText(ImGui.GetWindowWidth().ToString(.. scope .()),0,0,50,GREEN);
	}
}