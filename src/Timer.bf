using System;
using RaylibBeef;
using System.Collections;
using static RaylibBeef.Raylib;

namespace Leaf;


class TimedEvent
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
	List<TimedEvent> mTimedEvents;

	bool hasBeenDeleted;

	public this()
	{
		mTimedEvents = new List<TimedEvent>();
	}

	public ~this()
	{
		for(var timer in mTimedEvents)
			delete timer;

		delete mTimedEvents;
	}

	public void Update()
	{
		for(int i = 0; i < mTimedEvents.Count; i++)
		{
			var timer = mTimedEvents[i];
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

	public TimedEvent DelayedAction(float delay, delegate void() myEvent)
	{
		var timedEvent = new TimedEvent(delay, myEvent);
		mTimedEvents.Add(timedEvent);

		timedEvent.event = new () => {
			mTimedEvents.Remove(timedEvent);
			myEvent.Invoke(); //same as delete this, because it call the delete in Game
		};

		return timedEvent;
	}

	public void SetNow()
	{
		for(var timer in mTimedEvents)
			timer.SetNow();
	}

	public void Delete()
	{
		hasBeenDeleted = true;
	}
}

class DelayedAction : Leaf.Entity
{
	delegate void() eventRef;

	float remaining;

	public this(float delay, delegate void() event)
	{
		eventRef = event;
		remaining = delay;
	}

	public ~this()
	{
	}

	public override void Update()
	{
		remaining -= Time.DeltaTime;

		if(remaining <= 0)
		{
			var e = eventRef;
			delete this;
			e?.Invoke();
			delete e;
		}
	}
}