using System.Collections;
using System;
namespace Leaf;

interface ITransaction
{
	void Apply();
	void Revert();
}

class Transaction<T> : ITransaction
{
	T* valuePtr;
	T oldValue;
	T newValue;

	public this(T* valuePtr, T newValue)
	{
		this.valuePtr = valuePtr;
		this.oldValue = *valuePtr;
		this.newValue = newValue;
	}

	public void Apply()
	{
		*valuePtr = newValue;
	}

	public void Revert()
	{
		*valuePtr = oldValue;
	}
}

class Transaction
{
	struct Trans<T>
	{
		public T* valuePtr;
		public T oldValue;
		public T newValue;
	}

	List<ITransaction> bank = new .();

	public ~this()
	{
		for(var item in bank)
			delete item;
		delete bank;
	}

	public void Add<T>(T* valuePtr, T newValue)
	{
		bank.Add(new Transaction<T>(valuePtr, newValue));
	}

	public void Apply()
	{
		for(var item in bank)
			item.Apply();
	}

	public void Revert()
	{
		for(var item in bank)
			item.Revert();
	}	
}