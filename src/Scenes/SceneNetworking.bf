using System;
using Leaf;
using RaylibBeef;
using ImGui;
using Leaf.Networking;
using System.Net;
using System.Collections;
using static System.Net.Socket;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;

namespace Leaf.Scenes;

[Reflect(.Methods), AlwaysInclude(IncludeAllMethods=true)]
class SceneNetworking : Leaf.BaseScene
{
	int32 port = 9096;

	enum NetModes {
		CLIENT,
		SERVER
	}

	NetModes mode;

	bool hasBeenInit;

    public this()
    {

    }

    public ~this()
    {
    }

    public override void Update()
    {
    }

    public override void DrawScreenSpace()
	{
		if(hasBeenInit)
		{
			DrawText(mode.ToString(.. scope .()), 0, 0, 48, WHITE);
		}
		else
		{
			if(ImGui.Button("Host"))
			{
				new Server();
				mode = .SERVER;
				hasBeenInit = true;
			}

			if(ImGui.Button("Join"))
			{
				new Client();
				mode = .CLIENT;
				hasBeenInit = true;
			}
		}
    }
}

class Client : Leaf.Entity
{
	Socket client;
	SockAddr_in sock = default;

	String serverIp = "127.0.0.1";
	int32 port = 9096;

	public this()
	{
		Socket.Init();

		client = new Socket();
		serverIp = "127.0.0.1";
		port = 9096;
	}

	public ~this()
	{
		delete client;
	}

	private void SendMessage(String messageToSend)
	{
		if(client.Connect(serverIp, port, out sock) case .Err)
		{
			Console.WriteLine("Failed to connect to server");
			client.Close();
			return;
		}

		var sendRes = client.Send(messageToSend, messageToSend.Length);
		if (sendRes case .Err(let err))
		{
			Console.WriteLine("Failed to send data");
			client.Close();
			return;
		}

		var sentSize = sendRes.Get();
	    void* buffer = Internal.Malloc(4096);

		var recvRes = client.Recv(buffer, 4096);

		if(recvRes case .Err)
		{
			Console.WriteLine("Failed to receive data from server");
			Internal.Free(buffer);
			client.Close();
			return;
		}

		var readSize = recvRes.Get();
		if(readSize <= 0)
		{
			Internal.Free(buffer);
			client.Close();
			return;
		}

	    String received = scope String((char8*)buffer, readSize);

		Internal.Free(buffer);
	    client.Close();
	}

	public override void Update()
	{
	}

	String msg = new String() ~ delete _;
	public override void Draw()
	{
		ImGui.SetKeyboardFocusHere();
		ImGui.InputText("message", msg);

		if(IsKeyPressed(.KEY_ENTER) || ImGui.Button("Send to Server"))
		{
			SendMessage(msg);
			msg.Clear();
		}
	}
}

class Server : Leaf.Entity
{
	Socket listener;
	int32 port = 9096;

	DataFile df;

	List<String> debugMsg = new List<String>() ~ delete _;

	public this()
	{
		df = new .();
		df["PlayerPosition"] = 123;

		Socket.Init();
		listener = new Socket();
		port = 9096;

		if (listener.Listen(port) case .Ok)
			Console.WriteLine("Started server at port {0}", port);
		else
			Console.WriteLine("Cannot start server at port {0}", port);
	}

	public ~this()
	{
		for(var m in debugMsg)
			delete m;
		delete listener;

		delete df;
	}

	public override void DrawScreenSpace()
	{
		for(var m in debugMsg)
		{
			ViewportConsole.Log(m, YELLOW);
		}
	}

	public override void Update()
	{
		ReceiveFromClient();
	}

	private void ReceiveFromClient()
	{
		Socket client = scope Socket();

		if (client.AcceptFrom(listener) case .Err(let err))
		{
			return;
		}

		void* buffer = Internal.Malloc(4096);

		var res = client.Recv(buffer, 4096);

		if (res case .Err(let er))
		{
			Log.Message(er);
			Console.WriteLine("Failed to receive data from socket");
			Internal.Free(buffer);
			return;
		}

		var readSize = res.Get();
		if(readSize <= 0)
		{
			Log.Message("ERROR");
			Internal.Free(buffer);
			return;
		}

		//client.Send(buffer, readSize);
		String message = scope String((char8*)buffer, readSize);

		debugMsg.Add(new String(message));
		Console.WriteLine(message);

		Internal.Free(buffer);
	}

	private void SendMessage(String messageToSend)
	{
		Socket.Init();

		var client = new Socket();
		SockAddr_in sock = default;

		String serverIp = "127.0.0.1";
		port = 9096;

		if (listener.Listen(port) case .Ok)
			Console.WriteLine("Started server at port {0}", port);
		else
			Console.WriteLine("Cannot start server at port {0}", port);

		if(client.Connect(serverIp, port, out sock) case .Err)
		{
			Console.WriteLine("Failed to connect to server");
			client.Close();
			return;
		}

		var sendRes = client.Send(messageToSend, messageToSend.Length);
		if (sendRes case .Err(let err))
		{
			Console.WriteLine("Failed to send data");
			client.Close();
			return;
		}

		var sentSize = sendRes.Get();
	    void* buffer = Internal.Malloc(4096);

		var recvRes = client.Recv(buffer, 4096);

		if(recvRes case .Err)
		{
			Console.WriteLine("Failed to receive data from server");
			Internal.Free(buffer);
			client.Close();
			return;
		}

		var readSize = recvRes.Get();
		if(readSize <= 0)
		{
			Internal.Free(buffer);
			client.Close();
			return;
		}

	    String received = scope String((char8*)buffer, readSize);

		Internal.Free(buffer);
	    client.Close();
	}
}