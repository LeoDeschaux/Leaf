#pragma warning disable 168
using System;
using RaylibBeef;
using System.Collections;
using static RaylibBeef.Raylib;

namespace Leaf;

public class Utils
{
	public static List<T> ToList<T>(IEnumerator<T> enumerator)
	{
		List<T> list = new .();

		for(var item in enumerator)
			list.Add(item);

		return list;
	}

	public static List<Type> GetTypes<T>()
	{
		var types = new List<Type>();
		for(var t in Type.Enumerator())
		{
			//if(t.BaseType == typeof(T))
			if(t.IsSubtypeOf(typeof(T)))
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

		Log.Message(scope $"trying to open {path}");

		System.Windows.Handle hwnd = System.Windows.GetStdHandle(0);
		var res = System.Windows.ShellExecuteW(hwnd, null, fp, null, null, System.Windows.SW_SHOW); 
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
		
		if(!System.IO.File.Exists(filePath))
		{
			Log.Error(scope $"filePath does not exists {filePath}");
			return;
		}
		if(!System.IO.File.Exists(appPath))
		{
			Log.Error(scope $"appPath does not exists {appPath}");
			return;
		}

		char16* fp = filePath.ToScopedNativeWChar!();
		char16* ap = appPath.ToScopedNativeWChar!();

		Log.Message(scope $"trying to open {filePath} with {appPath}");

		System.Windows.Handle hwnd = System.Windows.GetStdHandle(0);
		var res = System.Windows.ShellExecuteW(hwnd, null, ap, fp, null, System.Windows.SW_SHOW); 

		if(res.IsInvalid)
			return;

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