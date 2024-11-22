using System;
using Leaf;
using RaylibBeef;
using System.Collections;
using System.Threading;
using static System.IO.Directory;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;

namespace Leaf;

class AnimationPlayer : Leaf.Entity
{
	public List<Texture2D> Frames;

	public int CurrentFrameIndex = 0;
	public int Framerate = 24;

	private float elapsed = 0;

	private String CurrentAnimation;

	//LOAD VARS
	List<String> filePaths;
	private bool finishedLoading = false;

	//TODO: looping

	//TEXTURE
	public Rectangle Rectangle = .(0,0,GetScreenWidth(), GetScreenHeight());

    public this()
    {
		Frames = new .();
		filePaths = new .();
    }

    public ~this()
    {
		delete Frames;

		for(var filePath in filePaths)
			delete filePath;
		delete filePaths;
    }

	private void Clear()
	{
		delete Frames;
		for(var filePath in filePaths)
			delete filePath;
		delete filePaths;

		Frames = new .();
		filePaths = new .();

		CurrentFrameIndex = 0;

		finishedLoading = false;
	}

	public void LoadAnimation(String path)
	{
		System.Diagnostics.Stopwatch sw = scope .();
		sw.Start();

		Clear();

		String executableDir = System.IO.Path.GetDirectoryPath(Environment.GetExecutableFilePath(.. scope .()), .. scope String());
		Log.Message(executableDir, ConsoleColor.Red);
		var absolutePath = scope $"{executableDir}/res/{path}";

		CurrentAnimation = path;

		//TODO print every .png in folder
		var enumerator = System.IO.Directory.EnumerateFiles(absolutePath);
		for(var e in enumerator)
		{
			String fileName = scope .();
			e.GetFileName(fileName);

			var framePath = new $"{absolutePath}/{fileName}";
			Log.Message(fileName);

			filePaths.Add(framePath);
		}

		/*
		finishedLoading = true;

		sw.Stop();
		Log.Message(sw.Elapsed, ConsoleColor.Red);
		*/
	}

	private void LoadNext()
	{
		if(finishedLoading)
			return;

		if(filePaths.Count == 0)
			return;

		Frames.Add(LoadTexture(filePaths[Frames.Count]));

		finishedLoading = Frames.Count == filePaths.Count;
	}

	public override void Update()
	{
		LoadNext();

		if(!finishedLoading)
			return;

		elapsed += Time.DeltaTime;

		var frameDuration = 1f / (float)Framerate;

		while(elapsed >= frameDuration)
		{
			CurrentFrameIndex = (CurrentFrameIndex+1)%Frames.Count;
			elapsed -= frameDuration;
		}
	}

    public override void Draw()
    {
		if(!finishedLoading)
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