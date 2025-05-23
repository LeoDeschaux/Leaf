using System;
using System.IO;
using System.Diagnostics;

using RaylibBeef;
using static RaylibBeef.Raylib;

using ImGui;
using rlCImGuiBeef;
using Leaf.Engine;

namespace Leaf;

class CallBackChecker
{
	public static Event<delegate void()> OnMonitorChange = default ~ _.Dispose();
	public static Event<delegate void()> OnWindowResize = default ~ _.Dispose();

	private static int32 m_currentMonitor;
	private static Vector2 m_windowSize;

	public static void Update()
	{
#if BF_PLATFORM_WINDOWS
		if(m_currentMonitor != GetCurrentMonitor())
		{
			OnMonitorChange.Invoke();
			m_currentMonitor = GetCurrentMonitor();
		}
#endif

		Vector2 wSize = .(GetScreenWidth(), GetScreenHeight());
		if(m_windowSize != wSize)
		{
			m_windowSize = wSize;
			OnWindowResize.Invoke();
		}
	}
}