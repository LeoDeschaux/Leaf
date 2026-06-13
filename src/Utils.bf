#pragma warning disable 168
using System;
using RaylibBeef;
using System.Collections;
using static RaylibBeef.Raylib;

namespace Leaf;

public class Utils
{
	public static List<Type> GetListOfBaseType<T>()
	{
		var types = new List<Type>();
		for(var t in Type.Enumerator())
		{
			if(t.BaseType == typeof(T))
			{
				//Log.Message(t);
				types.Add(t);
			}
		}
		return types;
	}

	public static Type ConvertStringToType(StringView strType)
	{
		for(Type t in Type.Enumerator())
		{
			if(strType == t.ToString(.. scope .()))
				return t;
		}

		return null;
	}

	public static int GenerateUUID()
	{
		return Guid.Create().GetHashCode();
	}

	public static void OpenFile(String path)
	{
#if BF_PLATFORM_WINDOWS
		//var dir = System.IO.Path.GetDirectoryPath(Environment.GetExecutableFilePath(.. scope .()), .. scope String());
		var dir = System.IO.Directory.GetCurrentDirectory(.. scope .());
		char16* file = scope $"{dir}/{path}".ToScopedNativeWChar!();

		System.Windows.Handle hwnd = System.Windows.GetStdHandle(0);
		var res = System.Windows.ShellExecuteW(hwnd, null, file, null, null, System.Windows.SW_SHOW); 
		//Log.Message(res);

		Log.Message(scope $"OPEN FILE {dir}/{path}");
#endif
	}

	public static void OpenDirectory(String path)
	{
#if BF_PLATFORM_WINDOWS

		var dir = System.IO.Directory.GetCurrentDirectory(.. scope .());

		var path;
		path = System.IO.Path.GetFullPath(path, .. scope .());

		char16* fp = path.ToScopedNativeWChar!();

		System.Windows.Handle hwnd = System.Windows.GetStdHandle(0);
		var res = System.Windows.ShellExecuteW(hwnd, null, fp, null, null, System.Windows.SW_SHOW); 

		Log.Message(scope $"trying to open {path}");
#endif
	}

	public static void OpenFileWithApp(String filePath, String appPath)
	{
#if BF_PLATFORM_WINDOWS
		//var dir = System.IO.Path.GetDirectoryPath(Environment.GetExecutableFilePath(.. scope .()), .. scope String());
		var appPath;
		var filePath;

		/*
		var dir = System.IO.Directory.GetCurrentDirectory(.. scope .());
		filePath = scope $"{dir}/{filePath}";
		*/

		filePath = System.IO.Path.GetFullPath(filePath, .. scope .());
		appPath = System.IO.Path.GetFullPath(appPath, .. scope .());

		char16* fp = filePath.ToScopedNativeWChar!();
		char16* ap = appPath.ToScopedNativeWChar!();

		System.Windows.Handle hwnd = System.Windows.GetStdHandle(0);

		var res = System.Windows.ShellExecuteW(hwnd, null, ap, fp, null, System.Windows.SW_SHOW); 

		Log.Message(scope $"trying to open {filePath} with {appPath}");
#endif
	}

	public static mixin GetNameFromPath(StringView path)
	{
		String name = "";
		for(var s in path.Split('/'))
			name = scope:: .(s);
		/*
		for(var s in path.Split('\\'))
			name = scope:: .(s);
		*/
		name
	}

	public static Color GetColorFromIndex(int index)
	{
		Color[?] colors = .(
			YELLOW,
			GOLD,
			ORANGE,
			PINK,
			RED,
			MAROON,
			GREEN,
			LIME,
			DARKGREEN,
			SKYBLUE,
			BLUE,
			DARKBLUE,
			PURPLE,
			VIOLET,
			DARKPURPLE,
			BEIGE,
			BROWN,
			DARKBROWN,
			MAGENTA,

			WHITE,
			LIGHTGRAY,
			GRAY,
			DARKGRAY,
			RAYWHITE,
			BLACK,
		);

		return colors[index%colors.Count];
	}
}