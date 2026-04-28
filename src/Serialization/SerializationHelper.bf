using System;
using System.Reflection;
using System.Collections;
using ImGui;
using RaylibBeef;
namespace Leaf.Serialization;

//full path name is : field.FieldType
class SerializationHelper
{
	public static void PrintType(Type type)
	{
		Log.Message(scope $"({type.GetName(.. scope .())}) {type.GetName(.. scope .())}");

		for(var info in type.GetFields())
			PrintFields(info, 0);
	}

	public static void PrintField(Type type, String fieldName)
	{
		Log.Message($"({type.GetName(.. scope .())}) {fieldName}");

		for(var info in type.GetFields())
			PrintFields(info, 0);
	}

	public static void PrintField(FieldInfo type)
	{
		Log.Message($"({type.FieldType.GetName(.. scope .())}) {type.Name}");

		for(var info in type.FieldType.GetFields())
			PrintFields(info, 0);
	}

	private static void PrintFields(FieldInfo type, int depth)
	{
		var depth;
		depth++;

		for(int i = 0; i < depth; i++)
			Log.Message("  ");

		//Console.WriteLine($"({type.FieldType}) {type.Name}");
		Log.Message($"({type.FieldType.GetName(.. scope .())}) {type.Name}");

		for(var subField in type.FieldType.GetFields())
			PrintFields(subField, depth);
	}

	public static void AutoImGuiField(Object entity)
	{
		for (var field in entity.GetType().GetFields())
		{
			T* GetValuePtr<T>()
			{
				return (T*)field.GetValueReference(entity).Get().DataPtr;
			}

			mixin GetValuePtrRef<T>()
			{
				(T*)field.GetValueReference(entity).Get().DataPtr
			}

			if (let fieldAttribute = field.GetCustomAttribute<AutoSerializeAttribute>())
			{
				if(field.FieldType == typeof(int))
				{
					ImGui.SliderInt(scope $"{field.Name}", GetValuePtr<int32>(), 0, 500);
					continue;
				}

				if(field.FieldType == typeof(float))
				{
					ImGui.SliderFloat(scope $"{field.Name}", GetValuePtr<float>(), 0, 500);
				}

				if(field.FieldType == typeof(bool))
				{
					ImGui.Checkbox(scope $"{field.Name}", GetValuePtr<bool>());
				}

				if(field.FieldType == typeof(Vector2))
				{
					ImGui.SliderFloat2(scope $"{field.Name}", ref *GetValuePtrRef!<Vector2>(), 0, 500);
				}

				if(field.FieldType == typeof(Vector3))
				{
					ImGui.SliderFloat3(scope $"{field.Name}", ref *GetValuePtrRef!<Vector3>(), 0, 500);
					continue;
				}

				if(field.FieldType == typeof(Color))
				{
					//ImGui.SliderFloat3(scope $"{field.Name}", ref *GetValuePtrRef!<Vector3>(), 0, 500);
					ImGui.ColorEdit4(scope $"{field.Name}", ref *GetValuePtrRef!<Color>());
					continue;
				}

				//AutoImGuiField(*field.GetValueReference(entity).Get().DataPtr);
				//AutoImGuiField(*field.GetValue(entity).Get().DataPtr);
				//AutoImGuiField(*(Object*)field.GetValueReference(entity).Get().DataPtr);

				//var fieldObject = field.GetValueReference(entity).Get();

				//var tPtr = (SerializeEngine.Transform*)field.GetValueReference(entity).Get().DataPtr;
				//(*tPtr).Position.x = 123;
				//AutoImGuiField(*tPtr);

				AutoImGuiField(*(Object*)field.GetValueReference(entity).Get().DataPtr);

				/*
				for(var subField in field.FieldType.GetFields())
				{
					var parent = field.GetValueReference(entity).Get();

					Log.Message(entity);
					Log.Message(field.GetValueReference(entity).Get().VariantType);
					Log.Message(field.GetValueReference(entity).Get().RawVariantType);


					if(field.GetValueReference(entity).Get().IsValueType)
						Log.Message(field.GetValueReference(entity).Get().GetValueData());
					//Log.Message(subField.GetValueReference(parent).Get());

					AutoImGuiField(field.GetValueReference(entity).Get().GetValueData());
				}
				*/
				//SerializationHelper.PrintField(field);
				//Log.Message(fieldAttribute.MyCustomFunction());
			}
		}
	}
}