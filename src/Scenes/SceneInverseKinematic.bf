#pragma warning disable 168
using System;
using Leaf;
using RaylibBeef;
using System.Collections;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;
using static Leaf.IK;

namespace Leaf.Scenes;

[Reflect(.Methods), AlwaysInclude(IncludeAllMethods=true)]
class SceneInverseKinematic : Leaf.BaseScene
{
    public this()
    {
    }

    public ~this()
    {
    }

    public override void Update()
    {
    }

    public override void Draw()
    {
		SimpleDragAnchor();
		//SimpleFixAnchor();
    }

	Vector2 targetPos = .(0,0);
	Vector2 anchorPos = .(0,0);
	private void SimpleDragAnchor()
	{
		if(IsMouseButtonDown(MouseButton.MOUSE_BUTTON_LEFT))
		{
			targetPos = GetMousePosition();
			targetPos = GetScreenToWorld2D(targetPos, Camera);
		}

		if(IsMouseButtonDown(MouseButton.MOUSE_BUTTON_RIGHT))
		{
			anchorPos = GetMousePosition();
			anchorPos = GetScreenToWorld2D(anchorPos, Camera);
		}

		Vector2 desiredPos = targetPos;

		float maxSegmentLength = 100f;
		int segmentCount = 3;
		Vector2 lastAnchorPos = anchorPos;
		for(int i = 0; i < segmentCount; i++)
		{
			lastAnchorPos = AnchoredPosProportionnal(lastAnchorPos, desiredPos, segmentCount, anchorPos, maxSegmentLength);
		}
		//DRAG
		targetPos = lastAnchorPos;
	}

	private void SimpleFixAnchor()
	{
		if(IsMouseButtonDown(MouseButton.MOUSE_BUTTON_LEFT))
		{
			targetPos = GetMousePosition();
			targetPos = GetScreenToWorld2D(targetPos, Camera);
		}

		if(IsMouseButtonDown(MouseButton.MOUSE_BUTTON_RIGHT))
		{
			anchorPos = GetMousePosition();
			anchorPos = GetScreenToWorld2D(anchorPos, Camera);
		}

		Vector2 desiredPos = targetPos;

		//Chained anchor
		Vector2 firstAnchor = AnchoredPos(anchorPos, desiredPos);
		Vector2 secondAnchor = AnchoredPos(firstAnchor, desiredPos);
		Vector2 thirdAnchor = AnchoredPos(secondAnchor, desiredPos);

		//Single anchor
		Vector2 singleAnchor = AnchoredPos(.(-500,0), desiredPos);
	}
}

