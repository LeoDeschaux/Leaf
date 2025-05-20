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
			String txtMode = mode.ToString(.. scope .());
			int32 fontSize = 24;
			var txtSize = MeasureText(txtMode, fontSize);
			DrawText(txtMode, 0, GetScreenHeight()-fontSize, fontSize, WHITE);
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
	Socket socket;
	SockAddr_in sock;

	String serverIp = "127.0.0.1";
	int32 port = 9096;

	public this()
	{
		Socket.Init();
		socket = new Socket();

		var res = socket.OpenUDP(0);
		if (res case .Err(let err))
			Console.WriteLine("Failed to open {}", err);
		else if (res case .Ok)
			Log.Message("OK");

		Log.Message("");

		sock = default;
		sock.sin_family = AF_INET;
		sock.sin_addr = .(127,0,0,1);
		sock.sin_port = (.)port;
	}

	public ~this()
	{ 
		delete socket;
	}

	private void SendToServer(String messageToSend)
	{
		var sendRes = socket.SendTo(messageToSend, messageToSend.Length, sock);
		if (sendRes case .Err(let err))
		{
			Console.WriteLine("Failed to send data: {}", err);
			//socket.Close();
			return;
		}
	}

	public override void Update()
	{
		SendToServer("HELLO");
		//ReceiveFromServer();
	}

	String msg = new String("Hello") ~ delete _;
	public override void Draw()
	{
		ImGui.SetKeyboardFocusHere();
		ImGui.InputText("message", msg);

		if(IsKeyPressed(.KEY_ENTER) || ImGui.Button("Send to Server"))
		{
			SendToServer(msg);
			msg.Clear();
		}
	}
}

class Server : Leaf.Entity
{
	Socket listener;
	int32 port = 9096;

	DataFile df;

	List<Socket.SockAddr_in> clients = new .() ~ delete _;
	List<String> debugMsg = new List<String>() ~ delete _;

	public this()
	{
		df = new .();
		df["PlayerPosition"] = 123;

		Socket.Init();
		listener = new Socket();

		if (listener.OpenUDP(port) case .Ok)
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

	String msg = new String("Hello") ~ delete _;
	public override void DrawScreenSpace()
	{
		for(var m in debugMsg)
		{
			ViewportConsole.Log(m, YELLOW);
		}

		ImGui.SetKeyboardFocusHere();
		ImGui.InputText("message", msg);

		if(IsKeyPressed(.KEY_ENTER) || ImGui.Button("Send to Server"))
		{
			msg.Clear();
		}
	}

	public override void Update()
	{
		ReceiveFromClients();
	}

	private void ReceiveFromClients()
	{
	    void* buffer = Internal.Malloc(4096);
	    SockAddr_in clientAddr = default;

	    var res = listener.RecvFrom(buffer, 4096, out clientAddr);
	    if (res case .Err(let err))
	    {
	        //Console.WriteLine("RecvFrom error: {}", err);
	        Internal.Free(buffer);
	        return;
	    }

		Log.Message("RECEIVE ?");

	    var readSize = res.Get();
	    if (readSize <= 0)
	    {
	        Internal.Free(buffer);
	        return;
	    }

	    bool known = false;
	    for (let addr in clients)
	    {
	        if (addr.sin_addr == clientAddr.sin_addr && addr.sin_port == clientAddr.sin_port)
	        {
	            known = true;
	            break;
	        }
	    }

	    if (!known)
	    {
	        clients.Add(clientAddr);
	        Console.WriteLine("New client joined from IP {}:{}", clientAddr.sin_addr.ToString(.. scope .()), clientAddr.sin_port);
	    }

	    String message = scope String((char8*)buffer, readSize);
	    debugMsg.Add(new String(message));
	    Console.WriteLine("From client: {}", message);

	    Internal.Free(buffer);
	}
}