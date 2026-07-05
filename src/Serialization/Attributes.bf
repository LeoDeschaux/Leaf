using System;
using System.Collections;
using ImGui;
using Leaf.Serialization;
using System.Reflection;

namespace Leaf;

//[AttributeUsage(.All, .ReflectAttribute | .AlwaysIncludeTarget, ReflectUser=.Methods)]
[AttributeUsage(.Class | .Struct | .Field, .ReflectAttribute, ReflectUser=.Methods)]
struct HideInInspectorAttribute : Attribute
{
}

[AttributeUsage(.Class | .Struct | .Field, .ReflectAttribute, ReflectUser=.Methods)]
struct NonEditableAttribute : Attribute
{
}

struct SerializableuhAttribute : Attribute, IOnTypeInit
{
    [Comptime]
    public void OnTypeInit(Type type, Self* prev)
    {
        Compiler.EmitAddInterface(type, typeof(ISerializable));

        Compiler.EmitTypeBody(type, """
            public void ISerializable.Serialize(Serializer serializer)
            {
            
            """);

        Compiler.EmitTypeBody(type, scope $"\tserializer.StartType(typeof({type.GetName(.. scope .())}));\n");
        for (let field in type.GetFields())
        {
            if (!field.IsInstanceField || field.DeclaringType != type)
                continue;

            Compiler.EmitTypeBody(type, scope $"\tserializer.Store(\"{field.Name}\", {field.Name});\n");
        }
        Compiler.EmitTypeBody(type, "\tserializer.EndType();\n}");
    }
}