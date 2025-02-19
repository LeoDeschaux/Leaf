using System;
namespace Leaf;

class Entity
{
	public int DrawOrder = 0; //TODO on get => sort order
	public bool Visible = true;

	private bool DeleteNextFrame = false;

	public this()
	{
		Leaf.Engine.EntitySystem.Entities.Add(this);
		Leaf.Serialization.AutoSerializeAttribute.Deserialize(this);
	}

	public ~this()
	{
		OnDelete?.Invoke();
		delete OnDelete;

		Leaf.Engine.EntitySystem.Entities.Remove(this);
		Leaf.Serialization.AutoSerializeAttribute.Serialize(this);
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
	public virtual void DrawScreenSpace() {};

	public delegate void() OnDelete;

	public BaseScene Scene => Leaf.GameEngine.CurrentScene;
}