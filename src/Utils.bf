using System;
namespace Leaf;

public static class Utils
{
	public static void OpenFile(String path)
	{
		//var dir = System.IO.Path.GetDirectoryPath(Environment.GetExecutableFilePath(.. scope .()), .. scope String());
		var dir = System.IO.Directory.GetCurrentDirectory(.. scope .());
		char16* file = scope $"{dir}/{path}".ToScopedNativeWChar!();

		System.Windows.Handle hwnd = System.Windows.GetStdHandle(0);
		var res = System.Windows.ShellExecuteW(hwnd, null, file, null, null, System.Windows.SW_SHOW); 
		Log.Message(res);
	}

	public static void OpenFileWithApp(String filePath, String appPath)
	{
		//var dir = System.IO.Path.GetDirectoryPath(Environment.GetExecutableFilePath(.. scope .()), .. scope String());
		var dir = System.IO.Directory.GetCurrentDirectory(.. scope .());
		char16* fp = scope $"{dir}/{filePath}".ToScopedNativeWChar!();
		char16* ap = scope $"{appPath}".ToScopedNativeWChar!();

		System.Windows.Handle hwnd = System.Windows.GetStdHandle(0);

		var res = System.Windows.ShellExecuteW(hwnd, null, ap, fp, null, System.Windows.SW_SHOW); 
		Log.Message(res);
	}
}