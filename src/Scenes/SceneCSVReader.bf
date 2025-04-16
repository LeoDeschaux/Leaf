using System;
using Leaf;
using RaylibBeef;
using System.IO;
using System.Diagnostics;
using System.Collections;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;

namespace Leaf.Scenes;

[Reflect(.Methods), AlwaysInclude(IncludeAllMethods=true)]
class SceneCSVReader : Leaf.BaseScene
{
    public this()
    {
		var csv = scope CSVReader("res/localization.csv");

		//PRINT ALL CSV
		Log.Message(csv.ToString(.. scope .()));
		Console.WriteLine("-------");

		//PRINT FIRST ROW
		var row = csv.GetRow(0);
		csv.Print(row);
		for(var el in row)
			Log.Message(el);
		delete row;
		Console.WriteLine("---------");

		//PRINT ROW "key"
		var keyRow = csv.GetRow("key");
		for(var el in keyRow)
			Log.Message(el);
		delete keyRow;
		Console.WriteLine("---------");

		//PRINT FIRST COLUMN
		var column = csv.GetColumn(0);
		for(var el in column)
			Log.Message(el);
		delete column;
		Console.WriteLine("---------");

		//PRINT COLUMN "french"
		var keyCol = csv.GetColumn("french");
		for(var el in keyCol)
			Log.Message(el);
		delete keyCol;
		Console.WriteLine("---------");

		//PRINT FIRST CELL 
		var cell = csv.GetCell(0,0);
		Log.Message(cell);
		Console.WriteLine("---------");

		//PRINT CELL inside "menu.file" row and "french" column
		cell = csv.GetCell("menu.file","french");
		Log.Message(cell);
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