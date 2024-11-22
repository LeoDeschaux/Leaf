using System;
using System.Threading;
using System.Diagnostics;

using RaylibBeef;
using static RaylibBeef.Raylib;

namespace Leaf.Scenes;

public class SceneThread : BaseScene
{
	System.Diagnostics.Stopwatch sw = new Stopwatch();

	public this()
	{
		//System.Threading.Tasks.Task task = new .(=> {});

		//System.Diagnostics.AutoStopwatchPerf
		//System.Diagnostics.Profiler
		//System.Diagnostics.ProfilerScope

		//var sw = System.Diagnostics.Stopwatch.StartNew();

		Console.WriteLine("START THREAD");
		System.Threading.ThreadStart threadStart = new () => {
			//TODO
			sw.Start();
			Console.WriteLine("threadStart");
			Thread.Sleep(16);
		};

		System.Threading.Thread thread = new .(threadStart);

		thread.AddExitNotify(new () => {
			sw.Stop();

			Thread.Sleep(500);
			Console.WriteLine("AddExitNotify");
			//Console.WriteLine(System.Diagnostics.Stopwatch.GetTimestamp());

			/*
			Console.ForegroundColor = ConsoleColor.Red;
			//60 fps = 16ms
			Console.WriteLine($"{sw.ElapsedMilliseconds}ms ({sw.Elapsed})");

			Console.ForegroundColor = ConsoleColor.White;
			Console.WriteLine($"{sw.ElapsedMilliseconds}ms ({sw.Elapsed})");
			*/

			Log.Message();
			Log.Message(scope $"{sw.ElapsedMilliseconds}ms ({sw.Elapsed})", textColor: ConsoleColor.Black, ConsoleColor.Red);
			Log.Message("Yeah");
		});

		/*
		delegate void() dl = new () => {
		   Console.WriteLine("RemovedExitNotify");
		};

		var res = thread.RemovedExitNotify(dl);

		switch (res)
		{
		    case .Ok(let newVal): Console.WriteLine("Val: {}", newVal);
		    case .Err(let newVal): Console.WriteLine("Failed: {}", newVal);
		}
		delete dl;
		*/

		//thread.Join();
		//thread.Resume();
		//thread.AutoDelete = true;

		thread.Start();

		/*
		Thread thread = new Thread(new () => {
			for(int i < 100)
			{
				Console.Write(".");
			}
		});

		Thread.Sleep(500);
		thread.Start();

		Console.WriteLine("@@@@@@@@@@");

		Monitor m = new .();
		m.Enter();
		//do thing
		m.Exit();
		*/
	}

	public ~this()
	{
		delete sw;
	}

	public override void Update()
	{
		DrawRectangle(100,100,50,50,YELLOW);
	}

	public override void Draw()
	{

	}
}