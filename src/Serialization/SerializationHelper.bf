using System;
using System.Reflection;
using System.Collections;
using ImGui;
using RaylibBeef;
using System.Diagnostics;

namespace Leaf.Serialization;

public enum DataTypesFlags
{
	NONE,
	PRIMITIVES,
	STRUCTS,
	OBJECTS,
	LISTS,
	ALL = .PRIMITIVES | STRUCTS | OBJECTS | LISTS,
}

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

	public static void AutoImGuiField(Object entity, int depth = 0, bool force = false, DataTypesFlags ignoreFlags = .NONE, List<Type> ignoreTypes = null)
	{
		int CountFields()
		{
			int i = 0;
			for(var f in entity.GetType().GetFields())
				i++;
			return i;
		}

		for (var field in entity.GetType().GetFields())
		{
			if(ignoreTypes != null)
			{
				bool shouldBeIgnored = false;
				for(var ignoreType in ignoreTypes)
					if(field.FieldType.IsSubtypeOf(ignoreType) || field.FieldType.GetType() == ignoreType)
						shouldBeIgnored = true;
				if(shouldBeIgnored)
					continue;
			}

			//ImGui.Text(CountFields().ToString(.. scope .()));
			if(field.HasCustomAttribute<HideInInspectorAttribute>())
				continue;

			var DataPtr = field.GetValueReference(entity).Get().DataPtr;

			T* GetValuePtr<T>()
			{
				return (T*)field.GetValueReference(entity).Get().DataPtr;
			}

			mixin GetValuePtrRef<T>()
			{
				(T*)field.GetValueReference(entity).Get().DataPtr
			}

			//ImGui.Button(scope $"x:{field.FieldType.GetName(.. scope .())}");
			//Log.Message(field.Name);

			bool hasTag = field.HasCustomAttribute<AutoSerializeAttribute>() || field.FieldType.HasCustomAttribute<AutoSerializeAttribute>();
			if(!force && !hasTag)
				continue;

			if(field.HasCustomAttribute<NonEditableAttribute>())
			{
				if(field.FieldType == typeof(int))
					ImGui.Text(scope $"{*GetValuePtr<int>()}");
				continue;
			}

			if(field.FieldType == typeof(int) || field.FieldType == typeof(int32))
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
				ImGui.ColorEdit4(scope $"{field.Name}", ref *GetValuePtrRef!<Color>());
				continue;
			}

			if(field.FieldType == typeof(String))
			{
				ImGui.Text(scope $"{*GetValuePtr<String>()}");
				continue;
			}

			if(field.FieldType.IsStruct)
			{
				ImGui.BeginColoredGroup(.(0.3f, 0.1f, 0.3f, 1f));
				defer ImGui.EndColoredGroup();

				var variant = field.GetValueReference(entity).Get();
				var boxed = variant.GetBoxed().Get();
				defer delete boxed;

				AutoImGuiField(boxed, depth, true);
				field.SetValue(entity, boxed);

				continue;
			}

			if(!field.FieldType.IsGenericType &&
				(field.FieldType.IsSubtypeOf(typeof(Object)) || field.FieldType.IsInterface))
			{
				if(ignoreFlags.HasFlag(.OBJECTS))
					continue;

				ImGui.PushStyleColor(.Text, .(255,255,0,255));
				ImGui.Text(scope $"{field.Name}");
				ImGui.PopStyleColor();

				ImGui.BeginColoredGroup(RaylibBeef.Raylib.RayToImGuiColor(Raylib.RED));

				if (ImGui.CollapsingHeader(scope $"{field.Name}"))
				{
					ImGui.Indent(16*depth);
					AutoImGuiField(*(Object*)field.GetValueReference(entity).Get().DataPtr, depth+1);
					ImGui.Unindent();
				}

				ImGui.EndColoredGroup();

				continue;
			}

			ImGui.PushStyleColor(.Text, .(255,0,0,255));
			ImGui.Text(scope $"ERROR - {field.FieldType} not handled");
			ImGui.PopStyleColor();
		}
	}

	public static BJSON.Models.JsonObject AutoSaveField(Object entity, BJSON.Models.JsonObject df,
		StringView objectName = Compiler.CallerExpression[0], bool force = false, DataTypesFlags ignoreFlags = .NONE, List<Type> ignoreTypes = null, bool wrap = true)
	{
		var df;
		if(wrap && (entity.GetType().IsObject || entity.GetType().IsStruct || entity.GetType().IsSubtypeOf(typeof(Object))))
		{
			if(!df.ContainsKey(objectName))
				df[objectName] = BJSON.Models.JsonObject();
			df = df[objectName].AsObject();
		}

		df["Type"] = entity.GetType().ToString(.. scope .());

		Log.Message(entity.GetType().ToString(.. scope .()));

		for (var field in entity.GetType().GetFields())
		{
			if(ignoreTypes != null)
			{
				bool shouldBeIgnored = false;
				for(var ignoreType in ignoreTypes)
					if(field.FieldType.IsSubtypeOf(ignoreType) || field.FieldType.GetType() == ignoreType)
						shouldBeIgnored = true;
				if(shouldBeIgnored)
					continue;
			}

			Log.Message(field.Name);

			T* GetValuePtr<T>()
			{
				return (T*)field.GetValueReference(entity).Get().DataPtr;
			}

			mixin GetValuePtrRef<T>()
			{
				(T*)field.GetValueReference(entity).Get().DataPtr
			}

			bool hasTag = field.HasCustomAttribute<AutoSerializeAttribute>() || field.FieldType.HasCustomAttribute<AutoSerializeAttribute>();
			if(!force && !hasTag)
				continue;

			if(field.FieldType == typeof(int) || field.FieldType == typeof(int32))
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

			if(field.FieldType == typeof(String))
			{
				df[field.Name] = *GetValuePtr<String>();
				continue;
			}

			if(field.FieldType.IsStruct && !field.FieldType.IsStatic)
			{
				//df[field.Name] = BJSON.Models.JsonObject();

				var variant = field.GetValueReference(entity).Get();
				var boxed = variant.GetBoxed().Get();

				AutoSaveField(boxed, df, field.Name, true);

				delete boxed;
				continue;
			}

			if(!field.FieldType.IsGenericType &&
				(field.FieldType.IsSubtypeOf(typeof(Object)) || field.FieldType.IsInterface))
			{
				Log.Message(field.FieldType.GetName(.. scope .()), .DarkMagenta);
				//df[field.Name] = BJSON.Models.JsonObject();
				//AutoSaveField(*(Object*)field.GetValueReference(entity).Get().DataPtr, df[field.Name].AsObject(), true);

				var variant = field.GetValueReference(entity).Get();

				if(*(Object*)variant.DataPtr == null)
				{
					df[field.Name] = BJSON.Models.JsonNull();
					continue;
				}
				//var i = variant.GetBoxed().GetValueOrDefault();

				AutoSaveField(*(Object*)variant.DataPtr, df, field.Name, true);

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
					i++;
				}
				continue;
			}

			Debug.FatalError(scope $"ERROR - {field.Name} ({field.FieldType}) not handled");
			Log.Error(scope $"ERROR - {field.Name} ({field.FieldType}) not handled");
		}

		return df;
	}

	public static Object AutoLoadField(BJSON.Models.JsonValue df, Object entity = null, StringView objectName = Compiler.CallerExpression[1], bool force = false, DataTypesFlags ignoreFlags = .NONE, List<Type> ignoreTypes = null)
	{
		Log.Message(scope $"trying to load {objectName}");

		var entity;
		var df;
		if(entity.GetType().IsObject || entity.GetType().IsStruct || entity.GetType().IsSubtypeOf(typeof(Object)))
		{
			df = df[objectName].AsObject();
		}

		Type type = Utils.ConvertStringToType(df["Type"]);

		if(type == null)
		{
			Log.Error(scope $"ERROR - type not found {objectName}");
			return null;
		}

		Log.Message(type);

		if(entity == null)
			entity = type.CreateObject().Get();

		for (var field in entity.GetType().GetFields())
		{
			if(ignoreTypes != null)
			{
				bool shouldBeIgnored = false;
				for(var ignoreType in ignoreTypes)
					if(field.FieldType.IsSubtypeOf(ignoreType) || field.FieldType.GetType() == ignoreType)
						shouldBeIgnored = true;
				if(shouldBeIgnored)
					continue;
			}

			T* GetValuePtr<T>()
			{
				return (T*)field.GetValueReference(entity).Get().DataPtr;
			}

			mixin GetValuePtrRef<T>()
			{
				(T*)field.GetValueReference(entity).Get().DataPtr
			}

			bool hasTag = field.HasCustomAttribute<AutoSerializeAttribute>() || field.FieldType.HasCustomAttribute<AutoSerializeAttribute>();
			if(!force && !hasTag)
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

			if(field.FieldType == typeof(String))
			{
				String s = *GetValuePtrRef!<String>();
				s.Clear();
				s.Append(df[field.Name]);
				continue;
			}

			if(field.FieldType.IsStruct)
			{
				var variant = field.GetValueReference(entity).Get();
				var boxed = variant.GetBoxed().Get();

				var tmp = AutoLoadField(df, boxed, field.Name, true);
				field.SetValue(entity, tmp);

				delete boxed;

				continue;
			}

			if(!field.FieldType.IsGenericType &&
				(field.FieldType.IsSubtypeOf(typeof(Object)) || field.FieldType.IsInterface))
			{
				Log.Message(field.FieldType.GetName(.. scope .()), .DarkMagenta);

				var variant = field.GetValueReference(entity).Get();

				if(df[field.Name].IsNull())
					continue;

				AutoLoadField(df, *(Object*)variant.DataPtr, field.Name, true);

				continue;
			}

			/*
			if(field.FieldType.IsGenericType &&
				((System.Reflection.SpecializedGenericType)field.FieldType).UnspecializedType == typeof(List<>))
			{
				int i = 0;
				for(var obj in df[field.Name].AsArray().Get())
				{
					Log.Message(obj.ToString(.. scope .()));
					var instance = AutoLoadField(df[field.Name][i].AsObject(), null, true);
					(entity as List<Object>).Add(instance);
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