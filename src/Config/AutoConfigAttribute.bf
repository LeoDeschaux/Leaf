using System;
using System.Collections;
using ImGui;
namespace Leaf.Config;

[AttributeUsage(.Class | .Struct | .Field, .ReflectAttribute, ReflectUser=.Methods)]
struct AutoConfigAttribute : Attribute
{
	public this()
	{
		//Log.Message(scope $"AutoConfig, {this.GetType()}");
	}

	public void MyCustomFunction()
	{
		//Log.Message("Hello World");
	}

	public static void Update(List<Entity> entities)
	{
		for(var entity in entities) 
		{
			for (var field in entity.GetType().GetFields())
			{
				if (let fieldAttribute = field.GetCustomAttribute<AutoConfigAttribute>())
				{
					if(field.FieldType == typeof(int))
					{
						var pointer = (int*)field.GetValueReference(entity).Get().DataPtr;
						ImGui.SliderInt(scope $"{field.Name}", (int32*)pointer, 0, 500);
					}

					if(field.FieldType == typeof(bool))
					{
						var pointer = (bool*)field.GetValueReference(entity).Get().DataPtr;
						ImGui.Checkbox(scope $"{field.Name}", (bool*)pointer);
					}

					//SerializationHelper.PrintField(field);
					//Log.Message(fieldAttribute.MyCustomFunction());
				}
			}
		}
	}
}