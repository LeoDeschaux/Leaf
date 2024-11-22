using System;
using Leaf;
using RaylibBeef;
using System.Collections;
using System.Threading;
using static System.IO.Directory;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;

namespace Leaf;

class AnimationPlayerV2 : Leaf.Entity
{
	public List<Texture2D> Frames;

	public int CurrentFrameIndex = 0;
	public int Framerate = 24;

	private float elapsed = 0;

	private String CurrentAnimation;

	//LOAD VARS
	List<String> filePaths;
	private bool finishedLoading = false;
	System.IO.FileEnumerator Enumerator;
	String AbsolutePath;
	private bool IsEnumeratorReady = false;

	//TODO: looping

	//TEXTURE
	public Rectangle Rectangle = .(0,0,GetScreenWidth(), GetScreenHeight());

    public this()
    {
		Frames = new .();
		filePaths = new .();
		AbsolutePath = new .("hello world");
		CurrentAnimation = new .("eofkoekfoek");
    }

    public ~this()
    {
		delete Frames;
		for(var filePath in filePaths)
			delete filePath;
		delete filePaths;
		delete AbsolutePath;
		delete CurrentAnimation;

		ClearEnumerator();
    }

	private void Clear()
	{
		delete Frames;
		for(var filePath in filePaths)
			delete filePath;
		delete filePaths;
		delete AbsolutePath;
		delete CurrentAnimation;

		Frames = new .();
		filePaths = new .();
		//AbsolutePath = new .();

		ClearEnumerator();

		CurrentFrameIndex = 0;

		finishedLoading = false;
		IsEnumeratorReady = false;
	}

	private void ClearEnumerator()
	{
		//Check if next exist
		/*
		if(IsEnumeratorReady)
		{
			var result = Enumerator.MoveNext();
			if(result)
				Enumerator.Dispose();
		}
		*/

		//if(finishedLoading)
		Enumerator.Dispose();
	}

	public void LoadAnimation(String path)
	{
		System.Diagnostics.Stopwatch sw = scope .();
		sw.Start();

		Clear();

		String executableDir = System.IO.Path.GetDirectoryPath(Environment.GetExecutableFilePath(.. scope .()), .. scope String());
		Log.Message(executableDir, ConsoleColor.Red);
		AbsolutePath = new $"{executableDir}/res/{path}";

		CurrentAnimation = new .(path);

		//TODO print every .png in folder
		Enumerator = System.IO.Directory.EnumerateFiles(AbsolutePath);
		IsEnumeratorReady = true;

		/*
		sw.Stop();
		Log.Message(sw.Elapsed, ConsoleColor.Red);
		*/
	}

	private void LoadNext()
	{
		if(finishedLoading)
			return;

		//LOAD NEXT PATH
		if(!IsEnumeratorReady)
			return;
		String fileName = scope .();
		Enumerator.Current.GetFileName(fileName);

		//LOAD FRAME
		var framePath = new $"{AbsolutePath}/{fileName}";
		Log.Message(fileName);
		filePaths.Add(framePath);
		Frames.Add(LoadTexture(filePaths[Frames.Count]));

		//INCREMENT
		var result = Enumerator.MoveNext();
		//Check if next exist
		if(result == false)
			finishedLoading = true;
	}

	public override void Update()
	{
		LoadNext();

		elapsed += Time.DeltaTime;
		var frameDuration = 1f / (float)Framerate;

		bool isNextFrameReady() {
			return finishedLoading || ((CurrentFrameIndex+1) < Frames.Count);
		}

		while(elapsed >= frameDuration && isNextFrameReady())
		{
			CurrentFrameIndex = (CurrentFrameIndex+1)%Frames.Count;
			elapsed -= frameDuration;
		}
	}

    public override void Draw()
    {
		if(Frames.Count == 0)
			return;

		var image = Frames[CurrentFrameIndex];
		DrawTexturePro(image,
			Rectangle(0,0,image.width,image.height),
			Rectangle,
			Vector2(0,0),
			0,
			WHITE
		);

		DrawText(CurrentFrameIndex.ToString(.. scope .()), (int32)Rectangle.x+5, (int32)Rectangle.y+5, 24, RED);
		DrawText(CurrentAnimation, (int32)Rectangle.x+5, (int32)Rectangle.y+25, 24, RED);
    }
}