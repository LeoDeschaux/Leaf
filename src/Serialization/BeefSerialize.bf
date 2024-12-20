using System.IO;
using System;
using Leaf.Serialize;

namespace Leaf.Serialize;

/* All implementers of this interface will have dynamic boxing available */
[Reflect(.None, ReflectImplementer=.DynamicBoxing)]
interface ISerializable
{
    void Serialize(Stream stream);
}

namespace System
{
    extension StringView : ISerializable
    {
        void ISerializable.Serialize(Stream stream)
        {
            stream.Write(mLength);
            stream.TryWrite(.((uint8*)mPtr, mLength));
        }
    }
}

class Serializer
{
    public void Serialize(Variant v, Stream stream)
    {
        ISerializable iSerializable;
        if (v.IsObject)
            iSerializable = v.Get<Object>() as ISerializable;
        else
        {
            /* 'v.GetBoxed' works for types implementing ISerializable because of the 'ReflectImplementer=.DynamicBoxing' attribute */
            iSerializable = v.GetBoxed().GetValueOrDefault() as ISerializable;
            defer:: delete iSerializable;
        }
        iSerializable?.Serialize(stream);
    }
}
