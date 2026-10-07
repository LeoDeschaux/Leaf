using System;
using System.IO;
using System.Diagnostics;

using RaylibBeef;
using static RaylibBeef.Raylib;

using ImGui;
using rlCImGuiBeef;
using static rlCImGuiBeef.rlCImGuiBeef;
/*
using rlImGuiBeef;
using static rlImGuiBeef.rlImGuiBeef;
*/

namespace Leaf.Engine;

public class WebEngine
{
#if BF_PLATFORM_WASM
	private const int WEB_FRAME_RATE = 60;
	private function void em_callback_func();

	[CLink, CallingConvention(.Stdcall)]
	private static extern void emscripten_set_main_loop(em_callback_func func, int32 fps, int32 simulateInfinteLoop);

	[CLink, CallingConvention(.Stdcall)]
	private static extern int32 emscripten_set_main_loop_timing(int32 mode, int32 value);

	[CLink, CallingConvention(.Stdcall)]
	private static extern double emscripten_get_now();

	[CLink, CallingConvention(.Stdcall)]
	private static extern void emscripten_cancel_main_loop();

	[CLink, CallingConvention(.Stdcall)]
	private static extern void emscripten_force_exit(int32 status);

	[CLink, CallingConvention(.Stdcall)]
	private static extern void emscripten_exit_with_live_runtime();
	public static void Exit(){
		emscripten_cancel_main_loop();
		emscripten_exit_with_live_runtime();
	};
	//public static void Exit() => emscripten_force_exit(127);

	public static void EmscriptenMainLoop(em_callback_func tickFunction)
	{
		emscripten_set_main_loop(=> tickFunction, 0, 1);
		//emscripten_set_main_loop_timing(1, 0);
	}
#endif
}