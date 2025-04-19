using System.Collections;
using System;

namespace Leaf.Engine;

public class EntitySystem
{
	public static List<Entity> Entities;
	private bool mHasBeenDisposed = false;

	public this()
	{
		Entities = new List<Entity>();
	}

	public ~this()
	{
		int i = Entities.Count-1;
		for (; i >= 0; i--)
		{
			i = Entities.Count-1;
			var entity = Entities[i];
			delete entity;
		}

		delete Entities;
	}

	public void Dispose()
	{
		mHasBeenDisposed = true;
	}

	public void Update()
	{
		for(int i = 0; i < Entities.Count; i++)
		{
			var e = Entities[i];
			e.Update();
		}

		for(int i = 0; i < Entities.Count; i++)
		{
			var e = Entities[i];
			e.LateUpdate();
		}
	}

	public void PostPhysicUpdate()
	{
		for(int i = 0; i < Entities.Count; i++)
		{
			var e = Entities[i];
			e.PostPhysicUpdate();
		}
	}

	public void CleanDeletedEntities()
	{
		int i = Entities.Count-1;
		for (; i >= 0; i--)
		{
			var entity = Entities[i];
			if(entity.[Friend]DeleteNextFrame)
				delete entity;
		}
	}

	public void Draw()
	{
		SortDrawOrder();

		for(var entity in Entities)
		{
			if(entity.Visible)
				entity.Draw();
		}
	}

	public void DrawScreenSpace()
	{
		SortDrawOrder();

		for(var entity in Entities)
		{
			if(entity.Visible)
				entity.DrawScreenSpace();
		}
	}

	public void SortDrawOrder()
	{
		Entities.Sort(scope (lhs, rhs) => lhs.DrawOrder <=> rhs.DrawOrder);
	}

	public static int CountOccurence(Type entityType)
	{
		int occurence = 0;
		for(var e in Entities)
		{
			if(e.GetType() == entityType)
				occurence++;
		}
		return occurence;
	}

	public static List<T> GetAll<T>() where T : Leaf.Entity
	{
		List<T> res = new .();
		for(var e in Entities)
		{
			if(e is T)
				res.Add(e as T);
		}
		return res;
	}
}