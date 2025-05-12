using RaylibBeef;
using static RaylibBeef.Raylib;

namespace Leaf;

class Time
{
	public static float TimeScale = 1f;

	private static float m_deltaTime;
	public static float DeltaTime => m_deltaTime;

	private static void UpdateDeltaTime()
	{
		m_deltaTime = GetFrameTime() * TimeScale;
	}

	public static void ClearDeltaTime()
	{
		m_deltaTime = 0f;
		Log.Message("----- CLEARED -----");
	}
}