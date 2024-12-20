using System.Collections;
namespace Leaf;

class PhysicsEngine
{
	public static List<PhysicComponent> Components;

	public this()
	{
		 Components = new List<PhysicComponent>();
	}

	public ~this()
	{
		delete Components;
	}
}