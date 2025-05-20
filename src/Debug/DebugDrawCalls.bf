using System.Collections;
namespace Leaf;

static class DebugDrawCalls
{
	class DebugDrawCall {
		public delegate void() dc;
		public float duration;

		public this(delegate void() dc, float duration = 0f)
		{
			this.dc = dc;
			this.duration = duration;
		}

		public ~this()
		{
			delete dc;
		}
	}

	private static List<DebugDrawCall> DebugDrawCalls = new .() ~ delete _;

	public static bool Display = true;

	public static void Clear()
	{
		for(var item in DebugDrawCalls)
			delete item;
		DebugDrawCalls.Clear();
	}

	public static void DrawDefered(delegate void() drawcall, float duration = 0f)
	{
		DebugDrawCalls.Add(new .(drawcall, duration));
	}

	public static void Render()
	{
		for(int i = DebugDrawCalls.Count-1; i >= 0; i--)
		{
			var item = DebugDrawCalls[i];

			if(Display)
				item.dc?.Invoke();

			item.duration -= Time.DeltaTime;

			if(item.duration <= 0)
			{
				DebugDrawCalls.RemoveAt(i);
				delete item;
			}
		}
	}
}