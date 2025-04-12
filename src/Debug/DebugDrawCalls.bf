using System.Collections;
namespace Leaf;

static class DebugDrawCalls
{
	private static List<delegate void()> DebugDrawCalls = new .() ~ delete _;

	public static bool Display = true;

	public static void DrawDefered(delegate void() drawcall)
	{
		DebugDrawCalls.Add(drawcall);
	}

	//in world space
	public static void Render()
	{
		for(int i = DebugDrawCalls.Count-1; i >= 0; i--)
		{
			var drawcall = DebugDrawCalls[i];

			if(Display)
				drawcall?.Invoke();

			DebugDrawCalls.RemoveAt(i);
			delete drawcall;
		}
	}
}