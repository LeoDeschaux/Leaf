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

	//UPDATE
	public void Update()
	{
	    for (int i = 0; i < Components.Count - 1; i++)
	    {
	        PhysicComponent other = Components[i];

	        for (int j = i+1; j < Components.Count; j++)
	        {
	            PhysicComponent c = Components[j];

	            if (c.Intersect(other))
	            {
	                c.OnCollision?.Invoke(other);
	                other.OnCollision?.Invoke(c);
	            }
	        }
	    }
	}

	public void UpdateOld()
	{
	    for (int i = 0; i < Components.Count - 1; i++)
	    {
	        PhysicComponent other = Components[i];

	        for (int j = i+1; j < Components.Count; j++)
	        {
	            PhysicComponent c = Components[j];

	            if (c.Intersect(other))
	            {
	                c.OnCollision?.Invoke(other);
	                other.OnCollision?.Invoke(c);
	            }
	        }
	    }
	}
}