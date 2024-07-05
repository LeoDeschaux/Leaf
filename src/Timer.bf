using System;
using RaylibBeef;
using System.Collections;
using static RaylibBeef.Raylib;

namespace Leaf;


class Teemo
{
	public delegate void() event;

	public delegate void() mOldEvent;

	public delegate void() OnDeleted;

	float mDelay;
	float startTime;

	public this(float delay, delegate void() oldEvent)
	{
		mOldEvent = oldEvent;

		startTime = (float)GetTime();
		mDelay = delay;
	}

	public ~this()
	{
		OnDeleted?.Invoke();
		delete OnDeleted;
		delete mOldEvent;
		delete event;
	}

	public void Update()
	{
		if(GetTime()-startTime >= mDelay)
		{
			event.Invoke();
			delete this;
		}
	}

	public void SetNow()
	{
		startTime = (float)GetTime();
	}
}

class Timer
{
	List<Teemo> timers;

	bool hasBeenDeleted;

	public this()
	{
		timers = new List<Teemo>();
	}

	public ~this()
	{
		for(var timer in timers)
			delete timer;

		delete timers;
	}

	public void Update()
	{
		for(int i = 0; i < timers.Count; i++)
		{
			var timer = timers[i];
			timer.Update();
			if(hasBeenDeleted)
			{
				delete this;
				return;
			}
		}

		/*
		for(var timer in timers)
			timer.Update();
		*/
	}

	public Teemo DelayedAction(float delay, delegate void() myEvent)
	{
		var teemo = new Teemo(delay, myEvent);
		timers.Add(teemo);

		teemo.event = new () => {
			timers.Remove(teemo);
			myEvent.Invoke(); //same as delete this, because it call the delete in Game
		};

		return teemo;
	}

	public void SetNow()
	{
		for(var timer in timers)
			timer.SetNow();
	}

	public void Delete()
	{
		hasBeenDeleted = true;
	}
}