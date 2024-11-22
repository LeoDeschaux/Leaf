namespace Leaf;

class Entity
{
	public int DrawOrder = 0; //TODO on get => sort order

	public this()
	{
		Leaf.Engine.EntitySystem.Entities.Add(this);
		//TODO sort order
	}

	public ~this()
	{
		Leaf.Engine.EntitySystem.Entities.Remove(this);
		//TODO sort order
	}

	public virtual void Update() {};
	public virtual void Draw() {};
}