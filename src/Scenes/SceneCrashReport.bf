using System;
using Leaf;
using RaylibBeef;
using System.Diagnostics;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;

namespace Leaf.Scenes;

[Reflect(.Methods), AlwaysInclude(IncludeAllMethods=true)]
class SceneCrashReport : Leaf.BaseScene
{
    public this()
    {
		Runtime.SetCrashReportKind(System.Runtime.RtCrashReportKind.GUI);
		Runtime.AddErrorHandler(
			new (e,f) => {
				if(e.HasFlag(.PreFail))
					return default;

				var error = f as System.Runtime.AssertError;

				Log.Message("ERROR");
				Log.Message(error.mError);
				Log.Message(error.mLineNum);
				Log.Message(error.mFilePath);
				Log.Message(error.mKind);

				return default;
		});
		Debug.Assert(123 == 456);
    }

    public ~this()
    {
    }

    public override void Update()
    {
    }

    public override void Draw()
    {
    }
}