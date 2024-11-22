using System.Collections;
using RaylibBeef;
using static RaylibBeef.Raylib;
using System;
namespace Leaf.ParticleSystem;

class ParticleEmitter
{
	public Vector2 Location;

	ParticleData ParticleData;
	private List<ParticleInstance> instances;
	float spawnRateTimer;
	float durationTimer;

	bool isRunning;

	private Random random;

	public bool IsFinished() => durationTimer >= ParticleData.Duration;

	public this(ParticleData particleData)
	{
		ParticleData = particleData;

		isRunning = ParticleData.StartAwake;

		instances = new List<ParticleInstance>();
		random = new System.Random();
	}

	public ~this()
	{
		//delete ParticleData;

		for(var particle in instances)
			delete particle;
		delete instances;

		delete random;
	}

	public void Play()
	{
		isRunning = true;
	}

	public void PlayAtLocation(Vector2 location)
	{
		Location = location;
		PlayFromStart();
	}

	public void PlayFromStart()
	{
		isRunning = true;
		spawnRateTimer = 0f;
		durationTimer = 0f;
	}

	public void Stop() => isRunning = false;

	public void Restart()
	{
		for (int i = 0; i < instances.Count; i++)
		{
			var instance = instances[i];
		    instances.RemoveAt(i);
			delete instance;
		    i--;
		}

		spawnRateTimer = 0f;
		durationTimer = 0f;
	}

	private ParticleInstance GenerateNewParticle()
	{
		var particle = new ParticleInstance(ParticleData, Location);

		particle.Velocity = .(
			particle.Velocity.x * (float)(random.NextDouble() * 2 - 1),
			particle.Velocity.x * (float)(random.NextDouble() * 2 - 1)
		);

		return particle;
	}

	private ParticleInstance GenerateCustomNewParticle()
	{
		ParticleData particleData = scope ParticleData();

	    Vector2 position = Location;

	    particleData.Velocity = particleData.Velocity * (float)(random.NextDouble() * 2 - 1);

	    particleData.Rotation = 0;
	    particleData.AngularVelocity = 900 * (float)(random.NextDouble() * 2 - 1);

		particleData.Size = .(
			30,//(float)random.NextDouble() * 30,
			30//(float)random.NextDouble() * 30
		);

	    particleData.Color = Color(
            (uint8)(random.NextDouble()*255),
            (uint8)(random.NextDouble()*255),
            (uint8)(random.NextDouble()*255),
			(uint8)(random.NextDouble()*255)
		);

	    particleData.Lifetime = 0.5f + (float)random.NextDouble() * 0.3f;

		return new ParticleInstance(particleData, position);
	}

	public void Update()
	{
		if(isRunning && !IsFinished())
		{
			durationTimer += GetFrameTime();
			spawnRateTimer += GetFrameTime();
		}

		/*
	    for (int i = instances.Count; i < maxInstance; i++)
	        instances.Add(GenerateNewParticle());
		*/

		var spawnDelay = 1/(float)ParticleData.SpawnRate;
		while(
			isRunning &&
			!IsFinished() &&
			spawnRateTimer - spawnDelay > 0 &&
			instances.Count < ParticleData.MaxParticles)
		{
			instances.Add(GenerateNewParticle());
			spawnRateTimer -= spawnDelay;
		}

		//UPDATE PARTICLES
	    for (int i = 0; i < instances.Count; i++)
	    {
	        instances[i].Update();
	        if (instances[i].Lifetime <= 0)
	        {
				var instance = instances[i];
	            instances.RemoveAt(i);
				delete instance;
	            i--;
	        }
	    }
	}

	public void Draw()
	{
		for(var particle in instances)
			particle.Draw();
	}
}