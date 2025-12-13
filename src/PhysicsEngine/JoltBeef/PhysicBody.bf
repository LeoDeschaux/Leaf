using Jolt;
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

	protected PhysicEngine3D engine;
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