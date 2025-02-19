using System;
using Leaf;
using RaylibBeef;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;
using static RaylibAsepriteBeef.RaylibAseprite;

using ImGui;
using System.IO;

namespace Leaf.Scenes;

class SceneAseprite : Leaf.BaseScene
{
	Aseprite* george;
	AsepriteTag walking;

	float scale = 8;
	Vector2 position = .(-300,-200);

    public this()
    {
		/*
		Texture* tex = AssetLoader.Load<Texture>("assets/texture.png");
		Sound* sound = AssetLoader.Load<Sound>("assets/sound.wav");
		Shader* shader = AssetLoader.Load<Shader>("assets/shader.glsl");
		*/

		george = AssetLoader.Load<Aseprite>("res/aseprite/george.aseprite");

		//george = LoadAseprite("res/aseprite/george.aseprite");
		walking = LoadAsepriteTag(*george, "Walk-Down");

		//TraceAseprite(george);
    }

    public ~this()
    {
		AssetLoader.Unload();
    }

    public override void Update()
    {
		AssetLoader.CheckModification();
    }

    public override void Draw()
    {
		UpdateAsepriteTag(&walking);
		DrawAsepriteTagEx(walking, position, 0, scale, WHITE);
    }

	float angle = 0;
	public override void DrawScreenSpace()
	{
		DrawAseprite(*george, 0, 100, 100, WHITE);
		DrawAseprite(*george, 4, 100, 150, WHITE);
		DrawAseprite(*george, 8, 100, 200, WHITE);
		DrawAsepriteFlipped(*george, 12, 100, 250, false, true, WHITE);

		Rectangle dest = .(500,500,500,500);
		DrawAsepritePro(*george, 0, dest, .(250,300), angle, WHITE);

		var text = GetAsepriteTexture(*george);
		DrawTexture(text, 0,0,RED);
	}
}