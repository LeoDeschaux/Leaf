using System;
using Leaf;
using RaylibBeef;
using Leaf.Serialization;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;

namespace Leaf.Scenes;
class SceneDataFile : Leaf.BaseScene
{
	[Serialize]
	public int myInt;

	[Serialize]
	private PlayerData playerData;

	private int notSerializedInt;

    public this()
    {
		Player player = scope Player();

		/*
		PlayerData playerData;
		playerData.PlayerHealth = 500f;
		DataFile.Serialize();
		DataFile.Deserialize();
		*/

		for(var type in Type.Types) 
		{
			for (var field in type.GetFields())
			{
				if (let fieldAttribute = field.GetCustomAttribute<SerializeAttribute>())
				{
					SerializationHelper.PrintField(field);
					Log.Message(fieldAttribute.MyCustomFunction());
				}
			}
		}
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
struct PlayerData {
	public float PlayerHealth = 100;
	public String PlayerName = "Hero";

	public Vector2 PlayerPosition = .(1,2);
	//Player Items[]
}

class Player {

	Vector2 Position;

	public this()
	{
		Log.Message(nameof(Position));
		Log.Message(Position.GetType());
	}

	public ~this()
	{

	}
}
}