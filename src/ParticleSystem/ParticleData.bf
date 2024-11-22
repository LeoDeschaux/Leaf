using BJSON;
using System;
using System.IO;
using RaylibBeef;
using static RaylibBeef.Raylib;

namespace Leaf.ParticleSystem;

class ParticleData
{
	public bool BurstMode = false;
	public bool Loop = false;
	public bool StartAwake = false;
	public bool DestroyOnFinished = false;

	public float Duration = 5f;

	public int BurstAmount = 30;
	public int SpawnRate = 50;

	public int MaxParticles = 10000;


	//public Vector2 offset
	public float Rotation = 0;
	public Vector2 Size = .(30,30);

	public Color Color = WHITE;
	//Texture
	public float Lifetime = 0.5f;

	public Vector2 Velocity = .(100,100);

	public float AngularVelocity = 900;

	var Path = "res/ParticleSystem/ParticleData.json";

	public this()
	{

	}

	public this(String path)
	{
		Path = path;
		//LoadData(Path);
		//SaveData();
	}

	public void SaveData()
	{
		String fileContent = scope .();
		if(File.ReadAllText(Path,fileContent,true) case .Err(let error))
			Console.WriteLine(error);

		var result = Json.Deserialize(fileContent);
		if(result case .Err(let err))
			Console.WriteLine(scope $"Error:{err}");

		var value = result.Value;

		/*
		value["ScaleX"] = Scale.x;
		value["ScaleY"] = Scale.y;
		value["skibidi"] = 123;
		*/

		String strBuffer = scope .();
		Json.Serialize(value, strBuffer);
		Json.Stringify(strBuffer);

		File.WriteAllText(Path, strBuffer);

		/*
		if(File.WriteAllText(Path, strBuffer) case .Err(let error))
			Console.WriteLine(error);
		*/

		value.Dispose();
	}

	public void LoadData(String path)
	{
		String fileContent = scope .();
		if(File.ReadAllText(path,fileContent,true) case .Err(let error))
			Console.WriteLine(error);

		var result = Json.Deserialize(fileContent);
		if(result case .Err(let err))
			Console.WriteLine(scope $"Error:{err}");

		var value = result.Value;

		Console.WriteLine(value.ToString(.. scope .()));

		//mGame.Arena.Radius = value["Arena"]["Radius"];

		value.Dispose();
	}
}