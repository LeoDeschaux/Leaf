using System;
namespace Leaf.Generators;

public class EntityClassGenerator : Compiler.Generator
{
    public override String Name => "New Leaf.Entity";

    public override void InitUI()
    {
        AddEdit("name", "Class Name", "");
    }

    public override void Generate(String outFileName, String outText, ref Flags generateFlags)
    {
		//generateFlags |= Flags.AllowRegenerate;

        var name = mParams["name"];
        if (name.EndsWith(".bf", .OrdinalIgnoreCase))
          name.RemoveFromEnd(3);

    	outFileName.Append(name);
    	outText.AppendF(
		$"""
        using System;
        using Leaf;
        using RaylibBeef;
        using static RaylibBeef.Raylib;
        using static RaylibBeef.Raymath;

        namespace {Namespace};

        class {name} : {typeof(Entity)}
        {{
            public this()
            {{
            }}

            public ~this()
            {{
            }}

            public override void Update()
            {{
            }}

            public override void Draw()
            {{
            }}
        }}
        """);
    }
}