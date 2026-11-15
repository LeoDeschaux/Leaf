using Jolt;
using System.Collections;
using RaylibBeef;
using Leaf;
using static Jolt.Jolt;
using static RaylibBeef.Raymath;

namespace Leaf;

class PhysicEngine3D
{
	public struct Layers
	{
		public static JPH_ObjectLayer NON_MOVING = 0;
		public static JPH_ObjectLayer MOVING = 1;
		public static JPH_ObjectLayer NUM_LAYERS = 2;
	};

	public struct BroadPhaseLayers
	{
		public static JPH_BroadPhaseLayer NON_MOVING = 0;
		public static JPH_BroadPhaseLayer MOVING = 1;
		public static int NUM_LAYERS = 2;
	};

	JPH_JobSystem* jobSystem;

	float cDeltaTime;
	float timeAccumulator;
	JPH_PhysicsSystem* system;
	public JPH_BodyInterface* BodyInterface;
	JPH_BodyID floorId;

	List<PhysicBody> bodies = new .() ~ delete _;
	//List<int> bodies = new .() ~ delete _;

	public this()
	{
	}

	public ~this()
	{
		for(var body in bodies)
		{
			// Remove the destroy sphere from the physics system. Note that the sphere itself keeps all of its state and can be re-added at any time.
			JPH_BodyInterface_RemoveAndDestroyBody(BodyInterface, (.)body.ID);

			delete body;
		}

		JPH_JobSystem_Destroy(jobSystem);

		JPH_PhysicsSystem_Destroy(system);
		JPH_Shutdown();
	}

	public void Init()
	{
		if (!JPH_Init())
			return;

		//JPH_SetTraceHandler(TraceImpl);
		//JPH_SetAssertFailureHandler(JPH_AssertFailureFunc handler);

		jobSystem = JPH_JobSystemThreadPool_Create(null);

		// We use only 2 layers: one for non-moving objects and one for moving objects
		JPH_ObjectLayerPairFilter* objectLayerPairFilterTable = JPH_ObjectLayerPairFilterTable_Create(2);
		JPH_ObjectLayerPairFilterTable_EnableCollision(objectLayerPairFilterTable, Layers.NON_MOVING, Layers.MOVING);
		JPH_ObjectLayerPairFilterTable_EnableCollision(objectLayerPairFilterTable, Layers.MOVING, Layers.NON_MOVING);

		// We use a 1-to-1 mapping between object layers and broadphase layers
		JPH_BroadPhaseLayerInterface* broadPhaseLayerInterfaceTable = JPH_BroadPhaseLayerInterfaceTable_Create(2, 2);
		JPH_BroadPhaseLayerInterfaceTable_MapObjectToBroadPhaseLayer(broadPhaseLayerInterfaceTable, Layers.NON_MOVING, BroadPhaseLayers.NON_MOVING);
		JPH_BroadPhaseLayerInterfaceTable_MapObjectToBroadPhaseLayer(broadPhaseLayerInterfaceTable, Layers.MOVING, BroadPhaseLayers.MOVING);

		JPH_ObjectLayerPairFilterTable_EnableCollision(objectLayerPairFilterTable, Layers.MOVING, Layers.MOVING);

		JPH_ObjectVsBroadPhaseLayerFilter* objectVsBroadPhaseLayerFilter = JPH_ObjectVsBroadPhaseLayerFilterTable_Create(broadPhaseLayerInterfaceTable, 2, objectLayerPairFilterTable, 2);

		JPH_PhysicsSystemSettings settings = .();
		settings.maxBodies = 65536;
		settings.numBodyMutexes = 0;
		settings.maxBodyPairs = 65536;
		settings.maxContactConstraints = 65536;
		settings.broadPhaseLayerInterface = broadPhaseLayerInterfaceTable;
		settings.objectLayerPairFilter = objectLayerPairFilterTable;
		settings.objectVsBroadPhaseLayerFilter = objectVsBroadPhaseLayerFilter;
		system = JPH_PhysicsSystem_Create(&settings);
		BodyInterface = JPH_PhysicsSystem_GetBodyInterface(system);
	}

	public void GenerateFloor()
	{
		floorId = .();
		// Next we can create a rigid body to serve as the floor, we make a large box
		// Create the settings for the collision volume (the shape). 
		// Note that for simple shapes (like boxes) you can also directly construct a BoxShape.
		JPH_Vec3 boxHalfExtents = .(100.0f, 1.0f, 100.0f);
		JPH_BoxShape* floorShape = JPH_BoxShape_Create(&boxHalfExtents, JPH_DEFAULT_CONVEX_RADIUS);

		JPH_Vec3 floorPosition = .(0.0f, -1.0f, 0.0f);
		JPH_BodyCreationSettings* floorSettings = JPH_BodyCreationSettings_Create3(
			(JPH_Shape*)floorShape,
			&floorPosition,
			null, // Identity, 
			JPH_MotionType.Static,
			Layers.NON_MOVING);

		// Create the actual rigid body
		floorId = JPH_BodyInterface_CreateAndAddBody(BodyInterface, floorSettings,JPH_Activation.DontActivate);
		JPH_BodyCreationSettings_Destroy(floorSettings);
		JPH_Shape_Destroy((JPH_Shape*)floorShape);

		BoxPhysic b = new .(this);
		b.ID = floorId;
		b.HalfExtents = boxHalfExtents;
		b.Position = floorPosition;
		b.Velocity = default;
		b.Rotation = IdentityRotation();

		bodies.Add(b);
	}

	/*
	{
		static float	cCharacterHeightStanding = 1.35f;
		static float	cCharacterRadiusStanding = 0.3f;
		static float	cCharacterHeightCrouching = 0.8f;
		static float	cCharacterRadiusCrouching = 0.3f;
		static float	cInnerShapeFraction = 0.9f;

		JPH_CapsuleShape* capsuleShape = JPH_CapsuleShape_Create(0.5f * cCharacterHeightStanding, cCharacterRadiusStanding);
		JPH_Vec3 position = .(0, 0.5f * cCharacterHeightStanding + cCharacterRadiusStanding, 0);
		var mStandingShape = JPH_RotatedTranslatedShape_Create(&position, null, (JPH_Shape*)capsuleShape);

		JPH_CharacterVirtualSettings characterSettings;
		JPH_CharacterVirtualSettings_Init(&characterSettings);
		characterSettings.base.shape = (JPH_Shape*)mStandingShape;
		characterSettings.base.supportingVolume = .(){normal = .(0, 1, 0), distance = -cCharacterRadiusStanding }; // Accept contacts that touch the lower sphere of the capsule
		static JPH_RVec3 characterVirtualPosition = .(-5.0f, 0, 3.0f);

		var mAnimatedCharacterVirtual = JPH_CharacterVirtual_Create(&characterSettings, &characterVirtualPosition, null, 0, system);
	}
	*/

	public SpherePhysic GenerateSphere(Vector3 position, Vector3 velocity, float radius,
		JPH_Quat* rotation = null, float gravityFactor = 1.0f, JPH_MotionType motionType = .Dynamic, JPH_ObjectLayer layers = Layers.MOVING)
	{
		// Sphere
		int sphereId = .();
		{
			JPH_SphereShape* sphereShape = JPH_SphereShape_Create(radius);
			JPH_Vec3 spherePosition = position;
			JPH_BodyCreationSettings* sphereSettings = JPH_BodyCreationSettings_Create3(
				(JPH_Shape*)sphereShape,
				&spherePosition,
				rotation,
				motionType,
				layers);

			sphereId = (.)JPH_BodyInterface_CreateAndAddBody(BodyInterface, sphereSettings, JPH_Activation.Activate);
			JPH_BodyCreationSettings_Destroy(sphereSettings);
			JPH_Shape_Destroy((JPH_Shape*)sphereShape);
		}

		// Now you can interact with the dynamic body, in this case we're going to give it a velocity.
		// (note that if we had used CreateBody then we could have set the velocity straight on the body before adding it to the physics system)
		JPH_Vec3 vel = velocity;
		JPH_BodyInterface_SetLinearVelocity(BodyInterface, (.)sphereId, &vel);
		JPH_BodyInterface_SetGravityFactor(BodyInterface, (.)sphereId, gravityFactor);

		SpherePhysic sphere = new .(this);
		sphere.ID = sphereId;
		sphere.Position = position;
		sphere.Velocity = velocity;
		sphere.Rotation = rotation != null ? *rotation : IdentityRotation();
		sphere.Radius = radius;

		bodies.Add(sphere);

		return sphere;
	}

	public BoxPhysic GenerateBox(Vector3 position, Vector3 velocity, Vector3 halfExtents,
		JPH_Quat* rotation = null, float gravityFactor = 1.0f, JPH_MotionType motionType = .Dynamic, JPH_ObjectLayer layers = Layers.MOVING)
	{
	    int boxId = .();
	    {
	        JPH_Vec3 he = halfExtents;
	        JPH_BoxShape* boxShape = JPH_BoxShape_Create(&he, JPH_DEFAULT_CONVEX_RADIUS);

	        JPH_Vec3 boxPosition = position;
	        JPH_BodyCreationSettings* boxSettings = JPH_BodyCreationSettings_Create3(
	            (JPH_Shape*)boxShape,
	            &boxPosition,
	            rotation,
	            motionType,
	            layers);

	        boxId = (.)JPH_BodyInterface_CreateAndAddBody(BodyInterface, boxSettings, JPH_Activation.Activate);
	        JPH_BodyCreationSettings_Destroy(boxSettings);
	        JPH_Shape_Destroy((JPH_Shape*)boxShape);
	    }

	    JPH_Vec3 vel = velocity;
	    JPH_BodyInterface_SetLinearVelocity(BodyInterface, (.)boxId, &vel);
		JPH_BodyInterface_SetGravityFactor(BodyInterface, (.)boxId, gravityFactor);

	    BoxPhysic b = new .(this);
	    b.ID = boxId;
	    b.HalfExtents = halfExtents;
	    b.Position = position;
	    b.Velocity = velocity;
		b.Rotation = rotation != null ? *rotation : IdentityRotation();

	    bodies.Add(b);

	    return b;
	}

	public PhysicBody GenerateMesh(Vector3 position, Vector3 velocity, Vector3* vertices, int vertexCount,
		uint32* indices, int indexCount, JPH_Quat* rotation = null, float gravityFactor = 1.0f,
		JPH_MotionType motionType = .Dynamic, JPH_ObjectLayer layers = Layers.MOVING)
	{
		if(vertices == null || indices == null || vertexCount < 3 || indexCount < 3)
			return null;

		int triangleCount = indexCount / 3;

		var triangles = new JPH_IndexedTriangle[triangleCount];
		defer delete triangles;

		for(int i = 0; i < triangleCount; i++)
		{
			triangles[i].i1 = indices[i * 3];
			triangles[i].i2 = indices[i * 3 + 1];
			triangles[i].i3 = indices[i * 3 + 2];
			triangles[i].materialIndex = 0;
			triangles[i].userData = 0;
		}

		JPH_MeshShapeSettings* settings = JPH_MeshShapeSettings_Create2(
			(JPH_Vec3*)vertices, (uint32)vertexCount, triangles.Ptr, (uint32)triangleCount);

		if(settings == null)
			return null;

		JPH_MeshShape* shape = JPH_MeshShapeSettings_CreateShape(settings);
		JPH_ShapeSettings_Destroy((JPH_ShapeSettings*)settings);

		if(shape == null)
			return null;

		return GenerateShape((JPH_Shape*)shape, position, velocity, rotation, gravityFactor, motionType, layers);
	}

	public PhysicBody GenerateConvexHull(Vector3 position, Vector3 velocity, Vector3* vertices, int vertexCount,
		JPH_Quat* rotation = null, float gravityFactor = 1.0f, JPH_MotionType motionType = .Dynamic,
		JPH_ObjectLayer layers = Layers.MOVING)
	{
		if(vertices == null || vertexCount < 4)
			return null;

		var uniqueVertices = new List<JPH_Vec3>();
		defer delete uniqueVertices;

		for(int i = 0; i < vertexCount; i++)
		{
			bool found = false;

			for(var existing in uniqueVertices)
			{
				if(Vector3DistanceSqr(existing, vertices[i]) < 0.00000001f)
				{
					found = true;
					break;
				}
			}

			if(!found)
				uniqueVertices.Add(vertices[i]);
		}

		if(uniqueVertices.Count < 4)
			return null;

		JPH_ConvexHullShapeSettings* settings = JPH_ConvexHullShapeSettings_Create(
			uniqueVertices.Ptr, (uint32)uniqueVertices.Count, JPH_DEFAULT_CONVEX_RADIUS);

		if(settings == null)
			return null;

		JPH_ConvexHullShape* shape = JPH_ConvexHullShapeSettings_CreateShape(settings);
		JPH_ShapeSettings_Destroy((JPH_ShapeSettings*)settings);

		if(shape == null)
			return null;

		return GenerateShape((JPH_Shape*)shape, position, velocity, rotation, gravityFactor, motionType, layers);
	}

	public PhysicBody GenerateShape(JPH_Shape* shape, Vector3 position, Vector3 velocity, JPH_Quat* rotation = null,
		float gravityFactor = 1.0f, JPH_MotionType motionType = .Dynamic, JPH_ObjectLayer layers = Layers.MOVING)
	{
		if(shape == null)
			return null;

		JPH_Vec3 bodyPosition = position;
		JPH_BodyCreationSettings* settings = JPH_BodyCreationSettings_Create3(shape, &bodyPosition, rotation, motionType, layers);

		if(settings == null)
		{
			JPH_Shape_Destroy(shape);
			return null;
		}

		int id = (.)JPH_BodyInterface_CreateAndAddBody(BodyInterface, settings, JPH_Activation.Activate);
		JPH_BodyCreationSettings_Destroy(settings);
		JPH_Shape_Destroy(shape);

		JPH_Vec3 vel = velocity;
		JPH_BodyInterface_SetLinearVelocity(BodyInterface, (.)id, &vel);
		JPH_BodyInterface_SetGravityFactor(BodyInterface, (.)id, gravityFactor);

		ShapePhysic body = new .(this);
		body.ID = id;
		body.Position = position;
		body.Velocity = velocity;
		body.Rotation = rotation != null ? *rotation : IdentityRotation();

		bodies.Add(body);

		return body;
	}

	static JPH_Quat IdentityRotation()
	{
		JPH_Quat rotation;
		rotation.x = 0;
		rotation.y = 0;
		rotation.z = 0;
		rotation.w = 1;
		return rotation;
	}

	public void DestroyBody(PhysicBody body)
	{
		if(body == null)
			return;

		JPH_BodyInterface_RemoveAndDestroyBody(BodyInterface, (.)body.ID);

		bodies.Remove(body);
		delete body;
	}

	public void StartSimulation()
	{
		JPH_SixDOFConstraintSettings jointSettings;
		JPH_SixDOFConstraintSettings_Init(&jointSettings);

		// We simulate the physics world in discrete time steps. 60 Hz is a good rate to update the physics system.
		cDeltaTime = 1.0f / 60.0f;
		timeAccumulator = 0;

		// Optional step: Before starting the physics simulation you can optimize the broad phase. This improves collision detection performance (it's pointless here because we only have 2 bodies).
		// You should definitely not call this every frame or when e.g. streaming in a new level section as it is an expensive operation.
		// Instead insert all new objects in batches instead of 1 at a time to keep the broad phase efficient.
		JPH_PhysicsSystem_OptimizeBroadPhase(system);
	}

	int step = 0;
	public void Update()
	{
		++step;

		// Accumulate the real frame time so the simulation advances at the same speed regardless of the frame rate.
		// Without this the world was stepped once per frame with a fixed 1/60 s, making it run faster than
		// real time on displays rendering above 60 FPS.
		timeAccumulator += Time.DeltaTime;

		// Don't try to catch up more than a few steps at once (e.g. after a long stall or a breakpoint),
		// otherwise the simulation can enter a spiral of death.
		const int cMaxStepsPerFrame = 5;
		if (timeAccumulator > cDeltaTime * cMaxStepsPerFrame)
			timeAccumulator = cDeltaTime * cMaxStepsPerFrame;

		// Step the world in fixed 1 / 60th of a second increments.
		const int cCollisionSteps = 1;
		while (timeAccumulator >= cDeltaTime)
		{
			JPH_PhysicsSystem_Update(system, cDeltaTime, cCollisionSteps, jobSystem);
			timeAccumulator -= cDeltaTime;
		}

		// Read the simulated state back into our bodies after stepping.
		for(var body in bodies)
		{
			JPH_BodyInterface_GetCenterOfMassPosition(BodyInterface, (.)body.ID, &body.Position);
			JPH_BodyInterface_GetLinearVelocity(BodyInterface, (.)body.ID, &body.Velocity);

			JPH_BodyInterface_GetRotation(BodyInterface, (.)body.ID, &body.Rotation);
		}
	}

	public void Apply()
	{
		for(var body in bodies)
			JPH_BodyInterface_SetLinearVelocity(BodyInterface, (.)body.ID, &body.Velocity);
	}
}