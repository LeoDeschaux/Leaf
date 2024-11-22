using System;
namespace Leaf.Networking;

[AttributeUsage(.Class | .Struct | .Field, .ReflectAttribute, ReflectUser=.Methods)]
struct ReplicateAttribute : Attribute
{
	public this()
	{
		//Log.Message(scope $"AutoConfig, {this.GetType()}");
	}

	public void MyCustomFunction()
	{
		//Log.Message("Hello World");
	}
}