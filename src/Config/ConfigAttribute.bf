using System;
namespace Leaf.Config;

[AttributeUsage(.Class | .Struct | .Field, .ReflectAttribute, ReflectUser=.Methods)]
struct ConfigAttribute : Attribute
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