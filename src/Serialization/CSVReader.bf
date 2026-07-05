using System;
using System.Collections;
using System.IO;
using System.Diagnostics;

namespace Leaf;

class CSVReader
{
	var parsedFile = new List<List<String>>();
	var rawContent = new String() ~ delete _;

	public var MissingFields = new List<(String, String)>();

	public this(String filePath)
	{
		if(!File.Exists(filePath))
			Log.Message(scope $"ERROR - file {filePath} not found");

		if(File.ReadAllText(filePath,rawContent,true) case .Err(let error))
			Debug.WriteLine(scope $"MSG ERROR 1: {error}");

		var fileLines = GetFileRawLines(rawContent);
		for(var line in fileLines)
		{
			parsedFile.Add(CSVReader.ParseCsvRow(line));
			delete line;
		}
		delete fileLines;
	}

	public void SaveTo(String filePath)
	{
		String strBuffer = scope .();
		ToString(strBuffer);

		String directory = Path.GetDirectoryPath(filePath, .. scope .());
		if (!String.IsNullOrEmpty(directory))
		    Directory.CreateDirectory(directory);

		if(File.WriteAllText(filePath, strBuffer) case .Err(let error))
			Log.Message(error);
	}

	public ~this()
	{
		for(var f in MissingFields)
		{
			delete f.0;
			delete f.1;
		}

		delete MissingFields;

		for(var row in parsedFile)
		{
			for(var col in row)
				delete col;
			delete row;
		}

		delete parsedFile;
	}


	public void SetCell(int rowIndex, int columnIndex, StringView value)
	{

	}

	public void SetCell(StringView rowKey, StringView columnKey, StringView value)
	{
		var rowIndex = GetRowIndex(rowKey);
		var columnIndex = GetColumnIndex(columnKey);

		if(rowIndex == -1)
		{
			//insert row
			var newRow = new List<String>();
			parsedFile.Add(newRow);
			rowIndex = parsedFile.Count-1;
			parsedFile[rowIndex].Insert(0, new String(rowKey));
			//parsedFile[rowIndex][0] = new String(rowKey);
		}

		if(columnIndex == -1)
		{
			//insert column
			parsedFile[0].Add(new String(columnKey));
			columnIndex = parsedFile[0].Count-1;
		}

		EnsureCell(rowIndex, columnIndex);
		parsedFile[rowIndex][columnIndex].Set(value);
	}

	void EnsureCell(int row, int col)
	{
	    while (parsedFile.Count <= row)
	        parsedFile.Add(new List<String>());
	    while (parsedFile[row].Count <= col)
	        parsedFile[row].Add(new String());
	}

	public String GetCell(int rowIndex, int columnIndex)
	{
		return parsedFile[rowIndex][columnIndex];
	}

	public bool DoesCellExist(String rowKey, String columnKey)
	{
		var rowIndex = GetRowIndex(rowKey);
		var columnIndex = GetColumnIndex(columnKey);

		return !(rowIndex == -1 || columnIndex == -1);
	}

	public String GetCell(String rowKey, String columnKey)
	{
		var rowIndex = GetRowIndex(rowKey);
		var columnIndex = GetColumnIndex(columnKey);

		if(rowIndex == -1)
		{
			if(!MissingFields.Contains((rowKey, columnKey)))
				MissingFields.Add((new String(rowKey), new String(columnKey)));
			return rowKey;
		}
		if(columnIndex == -1)
			return rowKey;

		var res = GetCell(rowIndex, columnIndex);

		if(res == "")
			return rowKey;

		return res;
	}

	public int GetRowIndex(StringView key)
	{
		for(int rowIndex = 0; rowIndex < parsedFile.Count; rowIndex++)
		{
			var rowKey = parsedFile[rowIndex][0];
			if(rowKey == key)
				return rowIndex;
		}

		return -1;
	}

	public int GetColumnIndex(StringView key)
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
	private static List<String> GetFileRawLines(String fileContent)
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

	/*
	[Warn("not working")]
	private static List<StringView> SplitCsvRows(StringView fileContent)
	{
	    var lines = new List<StringView>();
	    StringView current;// = new StringView();
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
	*/
    public static List<String> ParseCsvRow(String line)
    {
        var result = new List<String>();
        var current = new String();
		defer delete current;
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
                    result.Add(new String(current));
					current.Clear();
                }
                else
                {
                    current += c;
                }
            }

            i++;
        }

        result.Add(new String(current));
        return result;
    }

	public void Print(List<String> list)
	{
		for(var el in list)
			Log.Message(el);
	}

	public override void ToString(String strBuffer)
	{
		for(int rowIndex = 0; rowIndex < parsedFile.Count; rowIndex++)
		{
			var row = parsedFile[rowIndex];
			for(int columnIndex = 0; columnIndex < row.Count; columnIndex++)
			{
				var cell = row[columnIndex];

				if(cell.Contains(','))
				{
					cell.Insert(0, '"');
					cell.Insert(cell.Length, '"');
				}

				strBuffer.Append(cell);

				if(columnIndex < parsedFile[0].Count-1)
					strBuffer.Append(',');
			}

			if(rowIndex < parsedFile.Count-1)
				strBuffer.Append("\n");
		}
	}
}