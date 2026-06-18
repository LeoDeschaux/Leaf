using System;
using Leaf;
using RaylibBeef;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;
using System.Collections;

namespace Leaf;

class InputSystem : Leaf.Entity
{
	Dictionary<StringView, List<delegate bool()>> m_boolActions;
	Dictionary<StringView, List<delegate float()>> m_floatActions;

	public float AxisDeadZone = 0.1f;

	List<String> intKeys;

    public this()
    {
		m_boolActions = new .();
		m_floatActions = new .();
		intKeys = new .();
    }

    public ~this()
    {
		for(var binds in m_boolActions.Values)
		{
			for(var bind in binds)
				delete bind;
			delete binds;
		}
		delete m_boolActions;

		for(var binds in m_floatActions.Values)
		{
			for(var bind in binds)
				delete bind;
			delete binds;
		}
		delete m_floatActions;

		for(var key in intKeys)
			delete key;
		delete intKeys;
    }

	public void BindAction(int key, delegate bool() func)
	{
		String s = key.ToString(.. scope .());
		if(!m_boolActions.ContainsKey(s))
		{
			s = new String(s);
			intKeys.Add(s);
		}
		BindAction(s, func);
	}

	public void BindAction(StringView key, delegate bool() func)
	{
		if(!m_boolActions.ContainsKey(key))
			m_boolActions.Add(key, new .());

		m_boolActions.GetValue(key).Get().Add(func);
	}

	public void BindAxis(int key, delegate float() func)
	{
		String s = key.ToString(.. scope .());
		if(!m_boolActions.ContainsKey(s))
		{
			s = new String(s);
			intKeys.Add(s);
		}
		BindAxis(s, func);
	}

	public void BindAxis(StringView key, delegate float() func)
	{
		if(!m_floatActions.ContainsKey(key))
			m_floatActions.Add(key, new .());

		m_floatActions.GetValue(key).Get().Add(func);
	}

	public bool Get(int key)
	{
		return Get(key.ToString(.. scope .()));
	}

	public bool Get(StringView key)
	{
		if(!m_boolActions.ContainsKey(key))
		{
			Log.Message(scope $"WARNING - {key} does not exist");
			return false;
		}

		bool res = false;
		for(var bind in m_boolActions.GetValue(key).Get())
			res |= bind.Invoke();
		return res;
	}

	public float GetAxis(int key)
	{
		return GetAxis(key.ToString(.. scope .()));
	}

	public float GetAxis(StringView key)
	{
		if(!m_floatActions.ContainsKey(key))
		{
			Log.Message(scope $"WARNING - {key} does not exist");
			return 0;
		}

		float res = 0f;
		for(var bind in m_floatActions.GetValue(key).Get())
			res += bind.Invoke();

		//Apply deadzone correction
		if (Math.Abs(res) < AxisDeadZone)
		    res = 0f;
		else
		    res = (res - Math.Sign(res) * AxisDeadZone) / (1f - AxisDeadZone);

		return res;
	}

	public void InitDefaultBindings()
	{
		BindAxis("XAxis", new () => IsKeyDown(KeyboardKey.KEY_A) ? -1 : 0);
		BindAxis("XAxis", new () => IsKeyDown(KeyboardKey.KEY_D) ? 1 : 0);
		BindAxis("XAxis", new () => IsKeyDown(KeyboardKey.KEY_LEFT) ? -1 : 0);
		BindAxis("XAxis", new () => IsKeyDown(KeyboardKey.KEY_RIGHT) ? 1 : 0);

		BindAxis("YAxis", new () => IsKeyDown(KeyboardKey.KEY_W) ? -1 : 0);
		BindAxis("YAxis", new () => IsKeyDown(KeyboardKey.KEY_S) ? 1 : 0);
		BindAxis("YAxis", new () => IsKeyDown(KeyboardKey.KEY_UP) ? -1 : 0);
		BindAxis("YAxis", new () => IsKeyDown(KeyboardKey.KEY_DOWN) ? 1 : 0);

		BindAction("Jump", new () => IsKeyPressed(KeyboardKey.KEY_UP));
		BindAction("Jump", new () => IsKeyPressed(KeyboardKey.KEY_SPACE));

		BindAction("ReleaseJump", new () => IsKeyReleased(KeyboardKey.KEY_UP));
		BindAction("ReleaseJump", new () => IsKeyReleased(KeyboardKey.KEY_SPACE));

		BindAction("Sneak", new () => IsKeyDown(KeyboardKey.KEY_LEFT_CONTROL));
		BindAction("Sprint", new () => IsKeyDown(KeyboardKey.KEY_LEFT_SHIFT));

		BindAction("MeleeAttack", new () => IsKeyPressed(KeyboardKey.KEY_Z));
		BindAction("RangeAttack", new () => IsKeyPressed(KeyboardKey.KEY_X));
		BindAction("RangeAttack", new () => IsKeyDown(KeyboardKey.KEY_X)); //hold
		BindAction("Dash", new () => IsKeyPressed(KeyboardKey.KEY_C));
	}
}