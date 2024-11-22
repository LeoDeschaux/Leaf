using System.Collections;

namespace Leaf.Engine;

public class EntitySystem
{
	public static List<Entity> Entities;

	public this()
	{
		Entities = new List<Entity>();
	}

	public ~this()
	{
		for (int i = Entities.Count-1; i >= 0; i--)
		{
			var entity = Entities[i];
			delete entity;
		}

		delete Entities;
	}

	public void Update()
	{
		for(var entity in Entities)
			entity.Update();
	}

	public void Draw()
	{
		for(var entity in Entities)
			entity.Draw();
	}

	public void SortDrawOrder()
	{
		Entities.Sort(scope (lhs, rhs) => lhs.DrawOrder <=> rhs.DrawOrder);
	}
}