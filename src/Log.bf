using System;
using System.Diagnostics;
using System.Collections;
namespace Leaf;

public static class Log
{
	public static List<String> Logs = new .() ~ {
		ClearLogs();
		delete _;
	};

	public static void ClearLogs()
	{
		Logs.ClearAndDeleteItems();
	}

	private static ConsoleColor DefaultTextColor = ConsoleColor.Cyan;
	private static ConsoleColor DefaultBackgroundColor = ConsoleColor.Black;

	//MessageThreashold(shouldPrintRed: ms > 50)
	//MessageThreashold(colorCoef: ms / 200) between 0f-1f
	//Log.Message("message", ms<20 ? GREEN : RED

	public static void MessageThreashold(bool shouldPrintRed)
	{
		//if < 0.5 print red, otherwise green
	}

	public static void MessageThreashold()
	{
		//if < 0.5 print red, otherwise green
	}

	public static void Error(StringView message)
	{
		Log.Message(message, .Red, .Yellow);
	}

	public static void Message(StringView fmt, params Object[] args)
	{
		String str = scope String(256);
		str.AppendF(fmt, params args);
		Message(str);
	}

	public static void Message(StringView message,
		String file = Compiler.CallerFileName,
		int lineNum = Compiler.CallerLineNum)
	{
		Log.Message(message, textColor:DefaultTextColor, backgroundColor:DefaultBackgroundColor,
			file:file, lineNum:lineNum);
	}

	public static void Message(
		ConsoleColor textColor = DefaultTextColor,
		ConsoleColor backgroundColor = DefaultBackgroundColor)
	{
		Message("\n", textColor, backgroundColor);
	}

	/*
	public static void Message(StringView line,
		ConsoleColor textColor = DefaultTextColor,
		ConsoleColor backgroundColor = DefaultBackgroundColor)
	{
		String str = scope String(line);
		Message(str, textColor, backgroundColor);
	}
	*/

	/*
	public static void Message(StringView fmt,
		ConsoleColor textColor = ConsoleColor.White,
		ConsoleColor backgroundColor = ConsoleColor.Black,
		params Object[] args)
		
	{
		String str = scope String(256);
		str.AppendF(fmt, params args);
		Message(str);
	}
	*/

	/*
	public static void Message(StringView fmt,
		params Object[] args)
	{
		String str = scope String(256);
		str.AppendF(fmt, params args);
		Message(str);
	}
	*/

	public static void Message(Object obj,
		ConsoleColor textColor = DefaultTextColor,
		ConsoleColor backgroundColor = DefaultBackgroundColor)
	{
		String str = scope String(256);
		if (obj == null)
			str.Append("null");
		else
			obj.ToString(str);
		Message(str, textColor, backgroundColor);
	}

	public static void Message(StringView message,
		ConsoleColor textColor = DefaultTextColor,
		ConsoleColor backgroundColor = DefaultBackgroundColor,

		String file = Compiler.CallerFileName,
		int lineNum = Compiler.CallerLineNum)
	{
		Console.ForegroundColor = textColor;
		Console.BackgroundColor = backgroundColor;

		Console.WriteLine(message);
		Debug.WriteLine(message);

		Logs.Add(new String(scope $"[{file}:{lineNum}] {message} - {DateTime.Now}"));

		Console.ForegroundColor = ConsoleColor.White;
		Console.BackgroundColor = ConsoleColor.Black;
	}
}