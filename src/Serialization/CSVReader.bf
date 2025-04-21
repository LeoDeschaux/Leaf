using System;
using System.Collections;
using System.IO;
using System.Diagnostics;

namespace Leaf;

class CSVReader
{
	var parsedFile = new List<List<String>>();

	var rawContent = new String() ~ delete _;

	public this(String filePath)
	{
		if(!File.Exists(filePath))
			Log.Message(scope $"ERROR - file {filePath} not found");

		if(File.ReadAllText(filePath,rawContent,true) case .Err(let error))
			Debug.WriteLine(scope $"MSG ERROR 1: {error}");

		var rows = SplitCsvRowsSimple(rawContent);
		for(var row in rows)
		{
			parsedFile.Add(CSVReader.ParseCsvRow(row));
			delete row;
		}
		delete rows;
	}

	public ~this()
	{
		for(var row in parsedFile)
		{
			for(var col in row)
				delete col;
			delete row;
		}

		delete parsedFile;
	}

	public String GetCell(int rowIndex, int columnIndex)
	{
		return parsedFile[rowIndex][columnIndex];
	}

	public String GetCell(String rowKey, String columnKey)
	{
		return GetCell(GetRowIndex(rowKey), GetColumnIndex(columnKey));
	}

	public int GetRowIndex(String key)
	{
		for(int rowIndex = 0; rowIndex < parsedFile.Count; rowIndex++)
		{
			var rowKey = parsedFile[rowIndex][0];
			if(rowKey == key)
				return rowIndex;
		}

		return -1;
	}

	public int GetColumnIndex(String key)
	{
		for(int colIndex = 0; colIndex < parsedFile[0].Count; colIndex++)
		{
			var colItem = parsedFile[0][colIndex];
			if(colItem == key)
				return colIndex;
		}

	  	return -1;
	}

	public List<String> GetRow(int index)
	{
		var row = new List<String>();
		for(var el in parsedFile[index])
			row.Add(el);
		return row;
	}

	public List<String> GetColumn(int index)
	{
		var column = new List<String>();
		for(var row in parsedFile)
			column.Add(row[index]);
		return column;
	}

	public List<String> GetRow(String key)
	{
		return GetRow(GetRowIndex(key));
	}

	public List<String> GetColumn(String key)
	{
		return GetColumn(GetColumnIndex(key));
	}

	//does not support \n inside cells
	private static List<String> SplitCsvRowsSimple(String fileContent)
	{
		fileContent.TrimEnd();
		var lines = new List<String>();
		var rows = fileContent.Split('\n');
		for(var row in rows)
		{
			row.TrimEnd();
			lines.Add(new String(row));
		}
		return lines;
	}

	[Warn("not working")]
	private static List<String> SplitCsvRows(String fileContent)
	{
	    var lines = new List<String>();
	    String current = new String();
	    bool inQuotes = false;

		int quoteCount = 0;
		for(var char in fileContent.RawChars)
		{
			current.Append(char);

			if (char == '"')
				quoteCount++;

			inQuotes ^= quoteCount % 2 != 0;

			if (!inQuotes)
			{
			    lines.Add(current);
			    current = new String();
			}
		}

		delete current;
	        
	    return lines;
	}

    public static List<String> ParseCsvRow(StringView line)
    {
        var result = new List<String>();
        var current = new String();
        bool inQuotes = false;
        int i = 0;

        while (i < line.Length)
        {
            char8 c = line[i];

            if (inQuotes)
            {
                if (c == '"')
                {
                    if (i + 1 < line.Length && line[i + 1] == '"')
                    {
                        current += '"';
                        i++;
                    }
                    else
                    {
                        inQuotes = false;
                    }
                }
                else
                {
                    current += c;
                }
            }
            else
            {
                if (c == '"')
                {
                    inQuotes = true;
                }
                else if (c == ',')
                {
                    result.Add(current);
					current = new String();
                }
                else
                {
                    current += c;
                }
            }

            i++;
        }

        result.Add(current);
        return result;
    }

	public void Print(List<String> list)
	{
		for(var el in list)
			Log.Message(el);
	}

	public override void ToString(String strBuffer)
	{
		strBuffer.Append(rawContent);
	}
}