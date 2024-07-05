using System;
using RaylibBeef;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;
using System.Collections;

namespace Leaf;

class Timeline
{
	Timer timer;
	public float totalDuration;

	bool isPlaying = false;

	public this()
	{
		timer = new Timer();
	}

	public ~this()
	{
		delete timer;
	}

	public void Update()
	{
		if(!isPlaying)
			return;

		timer.Update();
	}

	public void Add(float duration, delegate void(float) event)
	{
		var teemo = timer.DelayedAction(totalDuration, new () => {
			event?.Invoke(duration);
		});

		teemo.OnDeleted = new () => {
			delete event;
		};

		totalDuration += duration;
	}

	public void Play()
	{
		isPlaying = true;
		timer.SetNow();
	}
}