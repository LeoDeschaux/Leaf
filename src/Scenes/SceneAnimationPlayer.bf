using System;
using Leaf;
using RaylibBeef;
using System.Collections;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;

namespace Leaf.Scenes;

class SceneAnimationPlayer : Leaf.BaseScene
{
	AnimationPlayer AnimationPlayerV1;
	AnimationPlayerV2 AnimationPlayerV2;

	List<String> anims = new .(){
		"animations/mono",
		"animations/kono",
		"animations/piece",
		"animations/dan",
	};

	private int currentAnimIndex = 0; 

    public this()
    {
		for(var anim in anims)
			Log.Message(anim);

		AnimationPlayerV1 = new .();
		AnimationPlayerV1.Rectangle = .(0,0, GetScreenWidth()/2, GetScreenHeight());
		AnimationPlayerV1.LoadAnimation(anims[currentAnimIndex]);

		AnimationPlayerV2 = new .();
		AnimationPlayerV2.Rectangle = .(GetScreenWidth()/2,0,
			GetScreenWidth()/2, GetScreenHeight());
		AnimationPlayerV2.LoadAnimation(anims[currentAnimIndex]);
    }

    public ~this()
    {
		delete anims;
    }

    public override void Update()
    {
		if(IsKeyPressed((int32)KeyboardKey.KEY_R))
			this.Restart();

		if(IsKeyPressed((int32)KeyboardKey.KEY_RIGHT))
		{
			currentAnimIndex = (currentAnimIndex + 1) % anims.Count;
			//AnimationPlayerV1.LoadAnimation(anims[currentAnimIndex]);
			AnimationPlayerV2.LoadAnimation(anims[currentAnimIndex]);
		}

		if(IsKeyPressed((int32)KeyboardKey.KEY_LEFT))
		{
			currentAnimIndex = (currentAnimIndex - 1 + anims.Count) % anims.Count;
			AnimationPlayerV1.LoadAnimation(anims[currentAnimIndex]);
			AnimationPlayerV2.LoadAnimation(anims[currentAnimIndex]);
		}
    }

    public override void Draw()
    {
		DrawText(currentAnimIndex.ToString(.. scope .()), 0,0, 24, RED);
    }
}