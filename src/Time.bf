using RaylibBeef;
using static RaylibBeef.Raylib;

namespace Leaf;

class Time
{
	public static float TimeScale = 1f;
	public static float DeltaTime => GetFrameTime() * TimeScale;
}