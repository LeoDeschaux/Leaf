using System.Collections;
using System.IO;
using System;

using RaylibBeef;
using static RaylibAsepriteBeef.RaylibAseprite;
using static RaylibBeef.Raylib;

namespace Leaf;

class CachedAsset
{
	public void* Asset;
	public String Path;
	public int32 ModificationTime;

	private Type ASSET_TYPE;

	public this<T>(String path)
	{
		ASSET_TYPE = typeof(T);

		Path = path;
		Asset = default;
		ModificationTime = -1;
	}

	public ~this()
	{
		delete Asset;
	}

	public T* GetAsset<T>()
	{
		Runtime.Assert(typeof(T) == ASSET_TYPE);
		//Runtime.Assert(typeof(T) == Asset.GetType());
		return (T*)Asset;
	}

	private void Unload()
	{
		if(ASSET_TYPE == typeof(Texture))
			UnloadTexture((Texture)*(Texture*)Asset);
		if(ASSET_TYPE == typeof(Aseprite))
			UnloadAseprite((Aseprite)*(Aseprite*)Asset);
	}

	public void Load(String path)
	{
		bool LoadedSuccessfully = false;

		if(Asset != null)
		{
			Unload();
			delete Asset;
		}

		if(ASSET_TYPE == typeof(Texture))
		{
			Texture* data = new Texture(0,0,0,0,0);
			*data = Raylib.LoadTexture(path);
			Asset = (void*)data;
			LoadedSuccessfully = true; 
		}

		if(ASSET_TYPE == typeof(Aseprite))
		{
			Aseprite* data = new Aseprite();
			*data = LoadAseprite(path);
			Asset = (void*)data;
			LoadedSuccessfully = true;
		}

		Runtime.Assert(LoadedSuccessfully);

		if(LoadedSuccessfully)
		{
			ModificationTime = GetFileModTime(path);
		}
	}
}

public static class AssetLoader
{
	private static Dictionary<String, CachedAsset> cachedAssets = new .();

	public static void Unload()
	{
		for(var cachedAsset in cachedAssets)
			delete cachedAsset.value;
		delete cachedAssets;
	}

	public static T* Load<T>(String path)
	{
		if(cachedAssets.ContainsKey(path))
		{
			var ca = cachedAssets.GetValue(path).Get().GetAsset<T>();
			return (T*)ca;
		}

		if(!File.Exists(path))
		{
			Log.Message(scope $"Error LoadTexture - Texture \"{path}\" not found");
			return default;
		}

		CachedAsset cachedAsset = new CachedAsset.this<T>(path);
		cachedAsset.Load(path);
		cachedAssets.Add(path, cachedAsset);

		return (T*)cachedAsset.Asset;
	}

	public static void CheckModification()
	{
		for(var path in cachedAssets.Keys)
		{
			var cached = cachedAssets.GetValue(path).Value;
			if(cached.ModificationTime != GetFileModTime(path))
			{
				cached.Load(path);
				cached.ModificationTime = GetFileModTime(path);
			}
		}
	}
}