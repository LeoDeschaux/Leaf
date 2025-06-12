using RaylibBeef;
using System.Collections;
using static RaylibBeef.Raylib;
using static RaylibBeef.Rlgl;
using static RaylibBeef.Color;

namespace RaylibBeef;

public extension Raylib
{
	public new static bool IsMouseButtonUp(MouseButton button) => !IsMouseButtonDown((int32)button);
}
