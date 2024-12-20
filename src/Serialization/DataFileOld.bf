using System;
using System.IO;
using System.Collections;

namespace Leaf;

public struct DataFileNode
{
	Dictionary<String,DataFileNode> dic = new .();

	private int intData = default;
	private String stringData = default;

	public this()
	{
	}

	public DataFileNode this[String path]
	{
		get {
			if(!dic.ContainsKey(path))
				dic.Add(path, DataFileNode());

			return dic[path];
		}
		set{
			if(dic.ContainsKey(path))
				dic[path] = value;
			else
				dic.Add(path, value);
		}
	}

	[Inline]
	public static implicit operator Self(int value)
	{
		var n = DataFileNode();
		n.intData = value;
		return n;
	}

	[Inline]
	public static implicit operator int(Self self)
	{
		return self.intData;
	}

	[Inline]
	public static implicit operator Self(String value)
	{
		var n = DataFileNode();
		n.stringData = value;
		return n;
	}

	[Inline]
	public static implicit operator String(Self self)
	{
		return self.stringData;
	}
}

public class DataFile
{
	DataFileNode root = .();

	private this()
	{
	}

	public ~this()
	{
	}

	public DataFileNode this[String path]
	{
		get {
			return root[path];
		}

		set{
			root[path] = value;
		}
	}

	public static DataFile LoadFile(String path)
	{
		return new DataFile();
	}

	public void SaveFile()
	{

	}

	public T Load<T>(String name)
	{
		return default;
	}

	public void Load<T>(ref T field)
	{

	}

	public void Save()
	{

	}








	private static void Serialize(Path path)
	{

	}

	private static void Deserialize()
	{

	}
}