using Jolt;
using System;
using System.Collections;
using RaylibBeef;
using static Jolt.Jolt;

namespace Leaf;

class PhysicBody
{
	public int ID;

	public Vector3 Position;
	public Vector3 Velocity;
	public JPH_Quat Rotation;
	public Object UserData;

	protected PhysicEngine3D engine;
}

class CapsulePhysic : PhysicBody
{
	public float HalfHeight;
	public float Radius;

	public this(PhysicEngine3D e)
	{
		engine = e;
	}
}

class CharacterPhysic
{
	public JPH_CharacterVirtual* Virtual;
	public int ID;

	public Vector3 Position;
	public Vector3 Velocity;
	public JPH_Quat Rotation;
	public Object UserData;

	public float Height;
	public float Radius;
	public bool IsGrounded;
	public JPH_ObjectLayer Layer;

	protected PhysicEngine3D engine;

	public this(PhysicEngine3D e)
	{
		engine = e;
	}
}

class SpherePhysic : PhysicBody
{
	public float Radius;

	public this(PhysicEngine3D e)
	{
		engine = e;
	}

	public ~this()
	{
	}
}

class BoxPhysic : PhysicBody
{
    public Vector3 HalfExtents;

    public this(PhysicEngine3D e)
    {
        engine = e;
    }

	public ~this()
	{
	}
}

class ShapePhysic : PhysicBody
{
	public this(PhysicEngine3D e)
	{
		engine = e;
	}
}