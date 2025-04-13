namespace RaylibBeef
{
	using System;

	extension Rectangle
	{
		public this(Vector2 pos, Vector2 size)
		{
			x = pos.x;
			y = pos.y;
			width = size.x;
			height = size.y;
		}

		public Vector2 Center => .(x+(width/2), y+(height/2));

		public float Right => x+width;
		public float Left => x;
		public float Top => y;
		public float Bottom => y+height;

		public Vector2 A => .(x,y);
		public Vector2 B => .(x+width,y);
		public Vector2 C => .(x+width,y+height);
		public Vector2 D => .(x,y+height);

		public Vector2 Position => .(x,y);
		public Vector2 Size => .(width, height);
	}
}
