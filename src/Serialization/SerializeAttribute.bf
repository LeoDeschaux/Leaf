using System;
namespace Leaf.Serialization;

[AttributeUsage(.Class | .Struct | .Field, .ReflectAttribute, ReflectUser=.Methods)]
struct SerializeAttribute : Attribute
{
	public this()
	{
		Log.Message(scope $"FieldGetSerialized, {this.GetType()}");
	}

	public void MyCustomFunction()
	{
		Log.Message("Hello World");
	}
}
