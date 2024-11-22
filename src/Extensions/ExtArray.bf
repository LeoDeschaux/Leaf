namespace System.Collections;

extension List<T>
{
    public bool IsNullAt(T item)
    {
        for (int i < this.Count) {
            if (this[i] == item)
                return true;
        }

        return false;
    }
}
