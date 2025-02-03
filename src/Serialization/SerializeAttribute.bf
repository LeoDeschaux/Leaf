using System;
using System.Collections;
namespace Leaf.Serialization;

[AttributeUsage(.Class | .Struct | .Field, .ReflectAttribute, ReflectUser=.Methods)]
struct AutoSerializeAttribute : Attribute
{
	public this()
	{
		//Log.Message(scope $"FieldGetSerialized, {this.GetType()}");
	}

	public void MyCustomFunction()
	{
		//Log.Message("Hello World");
	}

	public static void Serialize(Entity entity)
	{
		for (var field in entity.GetType().GetFields())
		{
			if (let fieldAttribute = field.GetCustomAttribute<AutoSerializeAttribute>())
			{
				if(field.FieldType == typeof(int))
				{
					//var pointer = (int*)field.GetValueReference(entity).Get().DataPtr;
					//field.Name
				}

				//SerializationHelper.PrintField(field);
				Log.Message(fieldAttribute.MyCustomFunction());
			}
		}
	}

	public static void Deserialize(Entity entity)
	{
		for (var field in entity.GetType().GetFields())
		{
			if (let fieldAttribute = field.GetCustomAttribute<AutoSerializeAttribute>())
			{
				if(field.FieldType == typeof(int))
				{
					//var pointer = (int*)field.GetValueReference(entity).Get().DataPtr;
					//field.Name
				}

				//SerializationHelper.PrintField(field);
				Log.Message(fieldAttribute.MyCustomFunction());
			}
		}
	}
}
