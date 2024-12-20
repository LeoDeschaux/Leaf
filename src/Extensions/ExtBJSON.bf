using System;
using Leaf;
using System.Collections;
namespace BJSON.Models;

extension JsonValue
{
	public JsonValue this[String key]
	{
		get
		{
			Runtime.Assert(type == .OBJECT, "JsonValue is not an object!");

			if(data.object.ContainsKey(key))
				return data.object[key];
			else
			{
				this.data.object.Add(new String(key), BJSON.Models.JsonObject());
				return data.object[key];
			}
		}
		set
		{
			Runtime.Assert(type == .OBJECT, "JsonValue is not an object!");

			if(data.object.ContainsKey(key))
			{
				data.object[key].Dispose();
				data.object[key] = value;
			}
			else
			{
				this.data.object.Add(new String(key), value);
			}
		}
	}

	// Access array
	public  JsonValue this[int index]
	{
		get
		{
			Runtime.Assert(type == .ARRAY, "JsonValue is not an array!");

			if(data.array.Count > index)
				return data.array[index];
			else
			{
			  	this.data.array.Add(BJSON.Models.JsonValue());
				return data.array[index];
			}

			//return this.As<JsonArray>()[index];
		}
		set
		{
			Runtime.Assert(type == .ARRAY, "JsonValue is not an array!");

			if(data.array.Count > index)
			{
				data.array[index].Dispose();
				data.array[index] = value;
			}
			else
			{
				this.data.array.Add(value);
			}

			//this.As<JsonArray>()[index] = value;
		}
	}
}

extension JsonObject
{
	public JsonValue this[String key]
	{
		get
		{
			if(data.object.ContainsKey(key))
				return data.object[key];
			else
			{
				this.Add(key, BJSON.Models.JsonObject());
				return data.object[key];
			}
		}

		set
		{
			if(data.object.ContainsKey(key))
			{
				data.object[key].Dispose();
				data.object[key] = value;
			}
			else
				this.Add(key, value);
		}
	}
}

extension JsonArray
{
	public JsonValue this[int index]
	{
		get
		{
			if(data.array.Count > index)
				return data.array[index];
			else
			{
				this.Add(BJSON.Models.JsonObject());
				return data.array[index];
			}
		}

		set
		{
			if(data.array.Count > index)
			{
				data.array[index].Dispose();
				data.array[index] = value;
			}
			else
				this.Add(value);

			//data.array.Reserve(index + 1);
			//data.array[index] = value;
		}
	}
}