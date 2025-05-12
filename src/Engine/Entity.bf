using System;
using System.Collections;
namespace Leaf;

class Entity
{
	public int DrawOrder = 0; //TODO on get => sort order
	public bool Visible = true;

	public bool DeleteNextFrame {get; private set;} = false;

	public this()
	{
		Leaf.Engine.EntitySystem.Entities.Add(this);
		//Leaf.Serialization.AutoSerializeAttribute.Deserialize(this);
	}

	public ~this()
	{
		OnDelete?.Invoke();
		OnDelete.Dispose();

		Leaf.Engine.EntitySystem.Entities.Remove(this);
		//Leaf.Serialization.AutoSerializeAttribute.Serialize(this);
	}

	public void DeleteNow()
	{
		delete this;
	}

	public void DeleteNextFrame()
	{
		DeleteNextFrame = true;
	}

	public virtual void Update() {};
	public virtual void LateUpdate() {};
	public virtual void PostPhysicUpdate() {};

	public virtual void Draw() {};
	public virtual void DrawPostEntities() {};
	public virtual void DrawScreenSpace() {};
	public virtual void DrawAboveImGui() {};

	public Event<delegate void()> OnDelete = default;

	public BaseScene Scene => Leaf.GameEngine.CurrentScene;

	public static List<T> GetAll<T>() where T : Leaf.Entity => Leaf.Engine.EntitySystem.GetAll<T>();
	public static T GetFirst<T>() where T : Leaf.Entity => Leaf.Engine.EntitySystem.GetFirst<T>();
}