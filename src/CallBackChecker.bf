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
	public static delegate void() OnMonitorChange ~ delete _;

	private static int32 currentMonitor;

	public static void Update()
	{
		if(currentMonitor != GetCurrentMonitor())
			OnMonitorChange?.Invoke();

		currentMonitor = GetCurrentMonitor();
	}
}