using System;
using System.Collections;
using ImGui;
using Leaf.Serialization;

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