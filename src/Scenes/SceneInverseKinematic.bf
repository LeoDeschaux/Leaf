using System;
using Leaf;
using RaylibBeef;
using System.Collections;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;
using static Leaf.IK;

namespace Leaf.Scenes;

class Finger
{
	public Vector2 Anchor;
	public Vector2 Target;

	public int Segment;
	public float TotalLength;
	public float SegmentLength => TotalLength / Segment;

	public this(Vector2 anchor, Vector2 target)
	{
		Anchor = anchor;
		Target = target;
	}
}

class Hand
{
	public List<Finger> Fingers;

	public this()
	{
		Fingers = new List<Finger>();

		//LEFT HAND
		Fingers.Add(new .(.(-400,0),.(-400,-200)));
		Fingers.Add(new .(.(-300,0),.(-300,-300)));
		Fingers.Add(new .(.(-200,0),.(-200,-320)));
		Fingers.Add(new .(.(-100,0),.(-100,-300)));
		Fingers.Add(new .(.(0,100),.(200,-50))); //Thumb
	}

	public ~this()
	{
		for(var finger in Fingers)
			delete finger;
		delete Fingers;
	}

	public int GetClosestFingerFromAnchor(Vector2 pos)
	{
		int bestFinger = 0;
		for(int fingerIndex = 0; fingerIndex < Fingers.Count; fingerIndex++)
		{
			if(Vector2.Distance(pos, Fingers[fingerIndex].Anchor) <
				Vector2.Distance(pos, Fingers[bestFinger].Anchor))
				bestFinger = fingerIndex;
		}
		return bestFinger;
	}

	public int GetClosestFingerFromTarget(Vector2 pos)
	{
		int bestFinger = 0;
		for(int fingerIndex = 0; fingerIndex < Fingers.Count; fingerIndex++)
		{
			if(Vector2.Distance(pos, Fingers[fingerIndex].Target) <
				Vector2.Distance(pos, Fingers[bestFinger].Target))
				bestFinger = fingerIndex;
		}
		return bestFinger;
	}

	public void DrawHand()
	{
		for(int fingerIndex = 0; fingerIndex < Fingers.Count; fingerIndex++)
		{
			Vector2 fingerAnchor = Fingers[fingerIndex].Anchor;
			Vector2 desiredPos = Fingers[fingerIndex].Target;

			float maxSegmentLength = 200;
			int segmentCount = 3;
			Vector2 lastAnchorPos = fingerAnchor;
			for(int i = 0; i < segmentCount; i++)
			{
				lastAnchorPos = AnchoredPosProportionnal(lastAnchorPos, desiredPos, segmentCount, fingerAnchor, maxSegmentLength);
			}
			Fingers[fingerIndex].Target = lastAnchorPos;
		}

		Vector2 fingerOffset = .(-20,0);

		Rectangle rec = .(
			Fingers[0].Anchor+fingerOffset,
			.(Vector2Distance(Fingers[0].Anchor, Fingers[Fingers.Count-1].Anchor),300)
		);
		DrawRectanglePro(rec, .(0,0), 0, BEIGE);
	}

}

[Reflect(.Methods), AlwaysInclude(IncludeAllMethods=true)]
class SceneInverseKinematic : Leaf.BaseScene
{
	Hand hand = new Hand() ~ delete _;

    public this()
    {
    }

    public ~this()
    {
    }

    public override void Update()
    {
		void AttractMultipleFingers()
		{
			for(int fingerIndex = 0; fingerIndex < hand.Fingers.Count; fingerIndex++)
			{
				var fingerTarget = hand.Fingers[fingerIndex].Target;
				var mPos = GetScreenToWorld2D(GetMousePosition(),Camera);
				Log.Message(mPos);
				if(Vector2.Distance(mPos, fingerTarget) < 50)
					hand.Fingers[fingerIndex].Target = mPos;
			}
		}

		if(IsMouseButtonDown(MouseButton.MOUSE_BUTTON_LEFT))
		{
			var mPos = GetScreenToWorld2D(GetMousePosition(),Camera);
			hand.Fingers[hand.GetClosestFingerFromTarget(mPos)].Target = mPos;
		}
    }

    public override void Draw()
    {
		hand.DrawHand();
		//SimpleDragAnchor();
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

