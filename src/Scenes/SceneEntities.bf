using System;
using System.IO;
using System.Diagnostics;

using RaylibBeef;
using static RaylibBeef.Raylib;

using ImGui;
using Leaf.ParticleSystem;
using System.Collections;

namespace Leaf.Scenes;

class SceneEntities : BaseScene
{
	public Player Player1;
	public Player Player2;

	public this()
	{
		Player1 = new Player();
		Player2 = new Player();

		Player1.Color = RED;
		Player2.Color = GREEN;

		Player1.Position = .(100,100);
		Player2.Position = .(150,150);

		Player1.DrawOrder = 100;
		Player2.DrawOrder = 50;

		Swap();
	}

	private void Swap()
	{
		this.mTimer.DelayedAction(1f, new () => {
			Player1.DrawOrder = Player1.DrawOrder == 50 ? 100 : 50;
			Player2.DrawOrder = Player2.DrawOrder == 50 ? 100 : 50;

			Swap();
		});
	}

	public ~this()
	{
		
	}

	public override void Update()
	{
		
	}

	public override void Draw()
	{
		
	}
}

extension SceneEntities{
public class Player : Entity
{
	public Color Color = RED;
	public Vector2 Position;

	public override void Update()
	{

	}

	public override void Draw()
	{
		DrawRectangle((int32)Position.x,(int32)Position.y,100,100,Color);
	}
}}
