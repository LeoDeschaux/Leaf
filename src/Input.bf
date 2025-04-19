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
		return res;
	}
}