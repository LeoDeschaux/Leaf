using RaylibBeef;
using RaylibBeef;
using static RaylibBeef.Raylib;

namespace Leaf.ParticleSystem;

class ParticleInstance
{
	public Vector2 Position;
	public float Rotation;
	public Vector2 Scale;

	public Color Color;
	public Texture2D Texture;
	public float Lifetime;

	public Vector2 Velocity;
	public float AngularVelocity;

	ParticleData ParticleData;

	/*
	public this(Vector2 position, float rotation, Vector2 size,
		Color color, float lifetime, Vector2 velocity, float rotationSpeed)
	{
		Position = position;
		Rotation = rotation;
		Size = size;
		Color = color;
		LifeTime = lifetime;
		Velocity = velocity;
		RotationSpeed = rotationSpeed;
	}
	*/

	public this(ParticleData particleData, Vector2 SpawnPosition)
	{
		ParticleData = particleData;

		Position = SpawnPosition;
		Rotation = particleData.Rotation;
		Scale = particleData.Size;

		Color = particleData.Color;
		//Texture
		Lifetime = particleData.Lifetime;

		Velocity = particleData.Velocity;

		AngularVelocity = particleData.AngularVelocity;
	}

	public ~this()
	{

	}

	public void Update()
	{
		Position += Velocity * GetFrameTime();
		Rotation += AngularVelocity * GetFrameTime();
		Lifetime -= GetFrameTime();
	}

	public void Draw()
	{
		Rectangle rec = Rectangle(Position.x, Position.y, Scale.x, Scale.y);
		DrawRectanglePro(rec, Scale/2f, Rotation, Color);
		//DrawRectangle(Position, Size, Color);
	}
}