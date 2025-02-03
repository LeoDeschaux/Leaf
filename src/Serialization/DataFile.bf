using System;
using System.IO;
using System.Collections;

using BJSON;
using System.Diagnostics;
using Leaf.Serialization;

using static Leaf.Scenes.SceneDataFile;

namespace Leaf;

public class DataFile
{
	BJSON.Models.JsonObject root = .();

	public this()
	{
	}

	public ~this()
	{
		root.Dispose();
	}

	public BJSON.Models.JsonValue this[String path]
	{
		get {
			return root[path];
		}

		set{
			root[path] = value;
		}
	}

	public static bool Exist(String path)
	{
		return File.Exists(path);
	}

	public static DataFile LoadFileOrCreate(String path)
	{
		if(File.Exists(path))
			return LoadFile(path);
		else
		{
			Log.Message(scope $"File \"{path}\" not found, new file created");
			return new DataFile();
		}
	}

	public static DataFile LoadFile(String path)
	{
		String fileContent = scope .();
		if(File.ReadAllText(path,fileContent,true) case .Err(let error))
			Debug.WriteLine(scope $"MSG ERROR 1: {error}");

		var result = Json.Deserialize(fileContent);
		if(result case .Err(let err))
			Debug.WriteLine(scope $"Error:{err}");

		var res = new DataFile();
		res.root.Dispose();
		res.root = result.Value.AsObject();

		return res;
	}

	public void SaveFileAppend()
	{

	}

	public void SaveFileOverwrite(String path)
	{
		//READ ORIGINAL TO CHECK
		/*
		String fileContent = scope .();
		if(File.ReadAllText(path,fileContent,true) case .Err(let error))
			Console.WriteLine(error);

		var result = Json.Deserialize(fileContent);
		if(result case .Err(let err))
			Console.WriteLine(scope $"Error:{err}");
		var value = result.Value;
		*/

		String strBuffer = scope .();
		Json.Serialize(root, strBuffer);
		Json.Stringify(strBuffer);

		if(File.WriteAllText(path, strBuffer) case .Err(let error))
			Console.WriteLine(error);
	}

	public override void ToString(String strBuffer)
	{
		root.ToString(strBuffer);
	}


	///Convert memory to JSON
	public BJSON.Models.JsonObject Serialize(Object object)
	{
		var jsonObject = BJSON.Models.JsonObject();

		jsonObject["PlayerHealth"] = 100;
		jsonObject["PlayerName"] = "Hero";

		SerializationHelper.PrintType(typeof(Object));

		return jsonObject;
	}

	///Load JSON inside memory
	public void Deserialize(BJSON.Models.JsonObject jsonObject, ref PlayerData object)
	{
		var fieldName = "PlayerHealth";
		var fieldType = object.GetType().GetField(fieldName).Get().FieldType;
		//var fieldPointerType = fieldType as System.Reflection.PointerType;
		//var ptr = object.GetType().GetField(fieldName).Value.GetValueReference(&object).ValueRef.DataPtr;

		if(fieldType == typeof(float))
		{
			//*(float*)ptr = 5;
			object.GetType().GetField(fieldName).Value.SetValue(&object, (float)5);
		}
	}
}