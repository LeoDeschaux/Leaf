using System;
using System.Reflection;
namespace Leaf.Serialization;

//full path name is : field.FieldType
class SerializationHelper
{
	public static void PrintType(Type type)
	{
		Console.WriteLine($"({type.GetName(.. scope .())}) {type.GetName(.. scope .())}");

		for(var info in type.GetFields())
			PrintFields(info, 0);
	}

	public static void PrintField(Type type, String fieldName)
	{
		Console.WriteLine($"({type.GetName(.. scope .())}) {fieldName}");

		for(var info in type.GetFields())
			PrintFields(info, 0);
	}

	public static void PrintField(FieldInfo type)
	{
		Console.WriteLine($"({type.FieldType.GetName(.. scope .())}) {type.Name}");

		for(var info in type.FieldType.GetFields())
			PrintFields(info, 0);
	}

	private static void PrintFields(FieldInfo type, int depth)
	{
		var depth;
		depth++;

		for(int i = 0; i < depth; i++)
			Console.Write("  ");

		//Console.WriteLine($"({type.FieldType}) {type.Name}");
		Console.WriteLine($"({type.FieldType.GetName(.. scope .())}) {type.Name}");

		for(var subField in type.FieldType.GetFields())
			PrintFields(subField, depth);
	}
}