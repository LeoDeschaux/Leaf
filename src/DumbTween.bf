using System;
using RaylibBeef;
using System.Collections;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;

namespace Leaf;

class DTween {
	float* mProperty;
	delegate float(float, float, float, float) mEasingFunction;

	public delegate void() OnTweenEnd; 

	double mStartTime;
	double mStartDelay;

	float mDuration = 1f;
	float mStart;
	float mEnd;

	public this(ref float property, float start, float end, float duration, delegate float(float, float, float, float) easingFunction)
	{
		mStartTime = GetTime();

		mProperty = &property;
		mEasingFunction = easingFunction;

		mStart = start;
		mEnd = end;
		mDuration = duration;
	}

	public ~this()
	{
		delete mEasingFunction;
		delete OnTweenEnd;
	}

	private void TweenEnded()
	{
		OnTweenEnd.Invoke();
		delete this;
		//delete mEasingFunction;
		//mEasingFunction = null;
	}

	public void Update()
	{
		var time = GetTime() - mStartTime;

		if(mEasingFunction == null)
			return;

		if(time >= mDuration)
		{
			*mProperty = mEnd;
			TweenEnded();
			return;
		}

		*mProperty = mEasingFunction.Invoke((float)time, mStart, mEnd-mStart, mDuration);
	}
}

class DumbTween
{
	List<DTween> tweens;

	public this()
	{
		tweens = new List<DTween>();
	}

	public ~this()
	{
		for(var tween in tweens)
			delete tween;

		delete tweens;
	}

	public void Update()
	{
		for(var tween in tweens)
			tween.Update();
	}

	public void Play(ref float property, float end, float duration, delegate float(float, float, float, float) easingFunction)
	{
		float start = property;
		Play(ref property, start, end, duration, easingFunction);
	}	

	public void Play(ref float property, float start, float end, float duration, delegate float(float, float, float, float) easingFunction)
	{
		DTween tween = new DTween(
			ref property,
			start,
			end,
			duration,
			easingFunction
		);

		tweens.Add(tween);
		tween.OnTweenEnd = new () => tweens.Remove(tween);
	}
}