using System;
using Leaf;
using RaylibBeef;
using Leaf.Config;
using Leaf.Serialization;
using ImGui;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;

namespace Leaf.Scenes;

class SceneAutoConfig : Leaf.BaseScene
{
	[Config]
	public int PlayerHealth = 100;

	[Config]
	public int PlayerSpeed = 350;

    public this()
    {

    }

    public ~this()
    {
    }

    public override void Update()
    {
    }

    public override void Draw()
    {
		for(var type in Type.Types) 
		{
			for (var field in type.GetFields())
			{
				if (let fieldAttribute = field.GetCustomAttribute<ConfigAttribute>())
				{
					if(field.FieldType == typeof(int))
					{
						//field.GetValueReference();
						//field.DeclaringType.

						/*
						int x = 0;
						field.GetValue<int>(, out x);
						Log.Message(PlayerHealth);
						ImGui.SliderInt(scope $"{field.Name}", (int32*)&x, 0, 500);
						field.SetValue(this, x);
						*/

						var pointer = (int*)field.GetValueReference(this).Get().DataPtr;
						ImGui.SliderInt(scope $"{field.Name}", (int32*)pointer, 0, 500);
						//Log.Message(MyCustomInt);
					}

					//SerializationHelper.PrintField(field);
					//Log.Message(fieldAttribute.MyCustomFunction());
				}
			}
		}
    }
}

public class Player : Entity, Configable
{

}

public interface Configable
{
	public void Register()
	{
	}

	public void Unregister()
	{
	}
}
