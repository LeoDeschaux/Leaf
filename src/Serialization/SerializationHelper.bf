using System;
using System.Reflection;
using System.Collections;
using ImGui;
using RaylibBeef;
using System.Diagnostics;
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

		//($"({type.FieldType}) {type.Name}");
		Log.Message($"({type.FieldType.GetName(.. scope .())}) {type.Name}");

		for(var subField in type.FieldType.GetFields())
			PrintFields(subField, depth);
	}

	public static void AutoImGuiField(Object entity)
	{
		for (var field in entity.GetType().GetFields())
		{
			if(field.HasCustomAttribute<HideInInspectorAttribute>())
				continue;

			T* GetValuePtr<T>()
			{
				return (T*)field.GetValueReference(entity).Get().DataPtr;
			}

			mixin GetValuePtrRef<T>()
			{
				(T*)field.GetValueReference(entity).Get().DataPtr
			}

			//Log.Message(field.Name);

			if(!field.HasCustomAttribute<AutoSerializeAttribute>() && !field.FieldType.HasCustomAttribute<AutoSerializeAttribute>())
				continue;

			if(field.HasCustomAttribute<NonEditableAttribute>())
			{
				if(field.FieldType == typeof(int))
					ImGui.Text(scope $"{*GetValuePtr<int>()}");
				continue;
			}

			/*
			if(field.FieldType.IsSubtypeOf(typeof(Entity)))
			{
				AutoImGuiField(*(Object*)field.GetValueReference(entity).Get().DataPtr);
			}
			*/

			//if (let fieldAttribute = field.GetCustomAttribute<AutoSerializeAttribute>())
			if(field.FieldType == typeof(int))
			{
				ImGui.SliderInt(scope $"{field.Name}", GetValuePtr<int32>(), 0, 500);
				continue;
			}

			if(field.FieldType == typeof(float))
			{
				ImGui.SliderFloat(scope $"{field.Name}", GetValuePtr<float>(), 0, 500);
				continue;
			}

			if(field.FieldType == typeof(bool))
			{
				ImGui.Checkbox(scope $"{field.Name}", GetValuePtr<bool>());
				continue;
			}

			if(field.FieldType == typeof(Vector2))
			{
				ImGui.SliderFloat2(scope $"{field.Name}", ref *GetValuePtrRef!<Vector2>(), 0, 500);
				continue;
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

			if(field.FieldType == typeof(String))
			{
				ImGui.Text(scope $"{*GetValuePtr<String>()}");
				continue;
			}

			ImGui.PushStyleColor(.Text, .(255,0,0,255));
			ImGui.Text(scope $"ERROR - {field.FieldType} not handled");
			ImGui.PopStyleColor();

			//AutoImGuiField(*field.GetValueReference(entity).Get().DataPtr);
			//AutoImGuiField(*field.GetValue(entity).Get().DataPtr);
			//AutoImGuiField(*(Object*)field.GetValueReference(entity).Get().DataPtr);

			//var fieldObject = field.GetValueReference(entity).Get();

			//var tPtr = (SerializeEngine.Transform*)field.GetValueReference(entity).Get().DataPtr;
			//(*tPtr).Position.x = 123;
			//AutoImGuiField(*tPtr);

			//AutoImGuiField(*(Object*)field.GetValueReference(entity).Get().DataPtr);

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

	public static void AutoSaveField(Object entity, BJSON.Models.JsonObject df)
	{
		df["Type"] = entity.GetType().ToString(.. scope .());

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

			if(!field.HasCustomAttribute<AutoSerializeAttribute>() && !field.FieldType.HasCustomAttribute<AutoSerializeAttribute>())
				continue;

			if(field.FieldType == typeof(int))
			{
				df[field.Name] = *GetValuePtr<int32>();
				continue;
			}

			if(field.FieldType == typeof(float))
			{
				df[field.Name] = *GetValuePtr<float>();
				continue;
			}

			if(field.FieldType == typeof(Color))
			{
				df[field.Name] = Raylib.ColorToInt(*GetValuePtrRef!<Color>());
				continue;
			}

			if(field.FieldType == typeof(Vector3))
			{
				df[field.Name] = BJSON.Models.JsonObject();
				df[field.Name]["x"] = (*GetValuePtrRef!<Vector3>()).x;
				df[field.Name]["y"] = (*GetValuePtrRef!<Vector3>()).y;
				df[field.Name]["z"] = (*GetValuePtrRef!<Vector3>()).z;
				continue;
			}

			if(field.FieldType == typeof(String))
			{
				df[field.Name] = *GetValuePtr<String>();
				continue;
			}

			if(field.FieldType.IsGenericType &&
				((System.Reflection.SpecializedGenericType)field.FieldType).UnspecializedType == typeof(List<>))
			{
				df[field.Name] = BJSON.Models.JsonArray();
				var list = *GetValuePtr<List<Object>>();
				int i = 0;
				for(var obj in list)
				{
					df[field.Name][i] = BJSON.Models.JsonObject();
					AutoSaveField(obj, df[field.Name][i].AsObject());
					Log.Message(obj.ToString(.. scope .()));
					i++;
				}

				continue;
			}

			/*

			Log.Message(field.GetValue(entity).Get().VariantType);
			//var test = field.FieldType;
			var test = field.GetValue(entity).Get().Get<List<Object>>();

			Log.Message(test.IsSplattable);
			Log.Message(test.IsArray);

			Log.Message(test.IsSubtypeOf(typeof(List<>)));
			Log.Message(test.IsSubtypeOf(typeof(List<Object>)));

			Log.Message(test == typeof(List<>));
			Log.Message(test == typeof(List<Object>));

			Log.Message(test is List);
			Log.Message(test is List<Object>);

			Log.Message(test is IList);
			Log.Message(test is System.Collections.IEnumerable<Object>);
			Log.Message(test is System.Collections.ICollection<Object>);
			*/

			//Log.Message(field.GetValueReference(entity).Get());

			/*
			Log.Message(field.FieldType);
			Log.Message(field.GetType());
			Log.Message(field.DeclaringType);

			Log.Message(field.FieldType.GetType());
			Log.Message(field.FieldType.BaseType);
			Log.Message(field.FieldType.BoxedType);
			Log.Message(field.FieldType.OuterType);
			Log.Message(field.FieldType.WrappedType);
			Log.Message(field.FieldType.BoxedPtrType);
			Log.Message(field.FieldType.UnderlyingType);
			Log.Message(field.FieldType.TypeDeclaration);
			*/

			Debug.FatalError(scope $"ERROR - {field.Name} ({field.FieldType}) not handled");
			Log.Error(scope $"ERROR - {field.Name} ({field.FieldType}) not handled");
		}
	}

	public static Object AutoLoadField(BJSON.Models.JsonValue df, Object entity = null)
	{
		var entity;
		Type type = Utils.ConvertStringToType(df["Type"]);

		if(entity == null)
		{
			//entity = new Object();
			entity = type.CreateObject().Get();
		}

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

			if(!field.HasCustomAttribute<AutoSerializeAttribute>() && !field.FieldType.HasCustomAttribute<AutoSerializeAttribute>())
				continue;

			if(field.FieldType == typeof(int))
			{
				*GetValuePtr<int>() = df[field.Name];
				continue;
			}

			if(field.FieldType == typeof(float))
			{
				*GetValuePtr<float>() = df[field.Name];
				continue;
			}

			if(field.FieldType == typeof(Color))
			{
				*GetValuePtrRef!<Color>() = Raylib.GetColor((int32)df[field.Name]);
				continue;
			}

			if(field.FieldType == typeof(Vector3))
			{
				*GetValuePtrRef!<Vector3>() = Vector3(
					df[field.Name]["x"],
					df[field.Name]["y"],
					df[field.Name]["z"]);
				continue;
			}

			if(field.FieldType == typeof(String))
			{
				continue;
			}

			/*
			if(field.FieldType.IsGenericType &&
				((System.Reflection.SpecializedGenericType)field.FieldType).UnspecializedType == typeof(List<>))
			{
				int i = 0;
				for(var obj in df[field.Name].AsArray().Get())
				{
					AutoLoadField(df[field.Name][i].AsObject());
					Log.Message(obj.ToString(.. scope .()));
					i++;
				}

				continue;
			}
			*/

			/*
			Debug.FatalError(scope $"ERROR - {field.Name} ({field.FieldType}) not handled");
			Log.Error(scope $"ERROR - {field.Name} ({field.FieldType}) not handled");
			*/
		}

		return entity;
	}
}