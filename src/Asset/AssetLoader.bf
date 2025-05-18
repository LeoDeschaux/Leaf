using System.Collections;
using System.IO;
using System;

using RaylibBeef;
using System;
using static RaylibAsepriteBeef.RaylibAseprite;
using static RaylibBeef.Raylib;

namespace Leaf;

class CachedAsset
{
	public void* Asset;
	public String Path;
	public int32 ModificationTime;

	private Type ASSET_TYPE;

	public Event<delegate void()> OnAssetReload = default;

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
		OnAssetReload.Dispose();
	}

	public T* GetAsset<T>()
	{
		Runtime.Assert(typeof(T) == ASSET_TYPE);
		//Runtime.Assert(typeof(T) == Asset.GetType());
		return (T*)Asset;
	}

	public void Unload()
	{
		if(ASSET_TYPE == typeof(Texture))
			UnloadTexture((Texture)*(Texture*)Asset);
		if(ASSET_TYPE == typeof(Aseprite))
			UnloadAseprite((Aseprite)*(Aseprite*)Asset);

		//Log.Message(scope $"UNLOADED {Path}");
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
			if(GetAsepriteTagCount(*data) == 0)
				GenDefaultTag(*data);
			Asset = (void*)data;
			LoadedSuccessfully = true;
		}

		Runtime.Assert(LoadedSuccessfully);

		if(LoadedSuccessfully)
		{
			ModificationTime = GetFileModTime(path);
			OnAssetReload.Invoke();
			//Log.Message(scope $"LOADED {Path}");
		}
	}
}

public static class AssetLoader
{
	private static Dictionary<String, CachedAsset> cachedAssets = new .() ~ delete _;

	public static void Unload()
	{
		for(var value in cachedAssets.Values)
			delete value;
		for(var key in cachedAssets.Keys)
			delete key;
		cachedAssets.Clear();
	}

	public static void Unload<T>(String path)
	{
		if(cachedAssets.ContainsKey(path))
		{
			var item = cachedAssets.GetAndRemove(path);
			item.Value.value.Unload();
			delete item.Value.key;
			delete item.Value.value;
		}
	}

	public static void BindReloadListener(String path, delegate void() OnAssetLoad = null)
	{
		if(OnAssetLoad == null)
			return;
		if(!cachedAssets.ContainsKey(path))
		{
			delete OnAssetLoad;
			return;
		}
		
		var eventListener = &cachedAssets.GetValue(path).Get().OnAssetReload;
		eventListener.Add(OnAssetLoad);
	}

	private static bool Contains(Event<delegate void()>.Enumerator e, delegate void() d)
	{
		for(var event in e)
			if(event.Equals(d))
				return true;
		return false;
	}

	public static void Unbind(String path, delegate void() OnAssetLoad = null)
	{
		if(!cachedAssets.ContainsKey(path))
			return;
		if(OnAssetLoad == null)
			return;
		var eventListener = &cachedAssets.GetValue(path).Get().OnAssetReload;
		if(eventListener == default)
			return;
		if(eventListener.IsEmpty)
			return;
		if(!eventListener.HasListeners)
			return;
		eventListener.Remove(OnAssetLoad, true);
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

		var key = new String(path);
		CachedAsset cachedAsset = new CachedAsset.this<T>(key);
		cachedAsset.Load(key);
		cachedAssets.Add(key, cachedAsset);
		
		return (T*)cachedAsset.Asset;
	}

	public static void CheckModification()
	{
		for(var path in cachedAssets.Keys)
		{
			var cached = cachedAssets.GetValue(path).Value;
			var hasBeenModified = GetFileModTime(path) != cached.ModificationTime;
			var secondsSinceLastModification = GetFileModTime(path) - cached.ModificationTime;
			if(hasBeenModified)
				cached.Load(path);
		}
	}
}