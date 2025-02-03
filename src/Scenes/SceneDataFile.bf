using System;
using Leaf;
using RaylibBeef;
using Leaf.Serialization;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;

namespace Leaf.Scenes;
class SceneDataFile : Leaf.BaseScene
{
	private int playerID;
	private PlayerData playerData;

    public this()
    {

		/*
		{
			Player player = scope Player();
			DataFile dataFile = DataFile.LoadFileOrCreate("res/config.json");

			dataFile["PlayerName"] = "John";
			StringView pName = dataFile["PlayerName"];

			dataFile["PlayerHealth"] = 666;
			int pHealth = dataFile["PlayerHealth"];

			Log.Message(dataFile);

			dataFile.SaveFileOverwrite("res/config.json");

			delete dataFile;
		}
		*/
		
		///IDEA
		//put everything inside struct and automate load/save
		{
			DataFile dataFile = scope .();

			playerData.PlayerHealth = 3;
			playerData.PlayerName = "John";

			var obj = dataFile.Serialize(playerData);
			dataFile["PlayerData"] = obj;

			dataFile.Deserialize(obj, ref playerData);

			Log.Message(playerData.PlayerHealth);
		}

		///IDEA 2
		/* 
		SaveLocation = map[""]
		LoadLocation = &playerID

		LoadAndSave.Register(map[""], &playerID)

		Load:
			LoadLocation = SaveLocation
		Save:
			SaveLocation = LoadLocation
		*/

		///IDEA 3
		//[AutoSerialize]

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

extension SceneDataFile{
[Reflect]
public struct PlayerData {
	[Reflect]
	public float PlayerHealth = 100;
	public String PlayerName = "Hero";

	//public Vector2 PlayerPosition = .(1,2);
	//Player Items[]
}

class Player {

	Vector2 Position;

	public this()
	{
	}

	public ~this()
	{
	}
}
}