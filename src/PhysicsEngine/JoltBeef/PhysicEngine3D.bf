using Jolt;
using System.Collections;
using RaylibBeef;
using Leaf;
using static Jolt.Jolt;

namespace Leaf;

class PhysicEngine3D
{
	struct Layers
	{
		public static JPH_ObjectLayer NON_MOVING = 0;
		public static JPH_ObjectLayer MOVING = 1;
		public static JPH_ObjectLayer NUM_LAYERS = 2;
	};

	struct BroadPhaseLayers
	{
		public static JPH_BroadPhaseLayer NON_MOVING = 0;
		public static JPH_BroadPhaseLayer MOVING = 1;
		public static int NUM_LAYERS = 2;
	};

	JPH_JobSystem* jobSystem;

	float cDeltaTime;
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

		// Remove and destroy the floor
		JPH_BodyInterface_RemoveAndDestroyBody(BodyInterface, floorId);

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

		//
		floorId = .();
		{
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
		}
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

	public SpherePhysic GenerateSphere(Vector3 position, Vector3 velocity, float radius)
	{
		// Sphere
		int sphereId = .();
		{
			JPH_SphereShape* sphereShape = JPH_SphereShape_Create(radius);
			JPH_Vec3 spherePosition = position;
			JPH_BodyCreationSettings* sphereSettings = JPH_BodyCreationSettings_Create3(
				(JPH_Shape*)sphereShape,
				&spherePosition,
				null, // Identity, 
				JPH_MotionType.Dynamic,
				Layers.MOVING);

			sphereId = JPH_BodyInterface_CreateAndAddBody(BodyInterface, sphereSettings, JPH_Activation.Activate);
			JPH_BodyCreationSettings_Destroy(sphereSettings);
		}

		// Now you can interact with the dynamic body, in this case we're going to give it a velocity.
		// (note that if we had used CreateBody then we could have set the velocity straight on the body before adding it to the physics system)
		JPH_Vec3 vel = velocity;
		JPH_BodyInterface_SetLinearVelocity(BodyInterface, (.)sphereId, &vel);

		SpherePhysic sphere = new .(this);
		sphere.ID = sphereId;
		sphere.Position = position;
		sphere.Velocity = velocity;
		sphere.Radius = radius;

		bodies.Add(sphere);

		return sphere;
	}

	public BoxPhysic GenerateBox(Vector3 position, Vector3 velocity, Vector3 halfExtents)
	{
	    int boxId = .();
	    {
	        JPH_Vec3 he = halfExtents;
	        JPH_BoxShape* boxShape = JPH_BoxShape_Create(&he, JPH_DEFAULT_CONVEX_RADIUS);

	        JPH_Vec3 boxPosition = position;
	        JPH_BodyCreationSettings* boxSettings = JPH_BodyCreationSettings_Create3(
	            (JPH_Shape*)boxShape,
	            &boxPosition,
	            null,
	            JPH_MotionType.Dynamic,
	            Layers.MOVING);

	        boxId = JPH_BodyInterface_CreateAndAddBody(BodyInterface, boxSettings, JPH_Activation.Activate);
	        JPH_BodyCreationSettings_Destroy(boxSettings);
	    }

	    JPH_Vec3 vel = velocity;
	    JPH_BodyInterface_SetLinearVelocity(BodyInterface, (.)boxId, &vel);

	    BoxPhysic b = new .(this);
	    b.ID = boxId;
	    b.HalfExtents = halfExtents;
	    b.Position = position;
	    b.Velocity = velocity;

	    bodies.Add(b);

	    return b;
	}

	public void StartSimulation()
	{
		JPH_SixDOFConstraintSettings jointSettings;
		JPH_SixDOFConstraintSettings_Init(&jointSettings);

		// We simulate the physics world in discrete time steps. 60 Hz is a good rate to update the physics system.
		cDeltaTime = 1.0f / 60.0f;

		// Optional step: Before starting the physics simulation you can optimize the broad phase. This improves collision detection performance (it's pointless here because we only have 2 bodies).
		// You should definitely not call this every frame or when e.g. streaming in a new level section as it is an expensive operation.
		// Instead insert all new objects in batches instead of 1 at a time to keep the broad phase efficient.
		JPH_PhysicsSystem_OptimizeBroadPhase(system);
	}

	int step = 0;
	public void Update()
	{
		++step;

		for(var body in bodies)
		{
			JPH_BodyInterface_GetCenterOfMassPosition(BodyInterface, (.)body.ID, &body.Position);
			JPH_BodyInterface_GetLinearVelocity(BodyInterface, (.)body.ID, &body.Velocity);

			JPH_BodyInterface_GetRotation(BodyInterface, (.)body.ID, &body.Rotation);
		}

		// If you take larger steps than 1 / 60th of a second you need to do multiple collision steps in order to keep the simulation stable. Do 1 collision step per 1 / 60th of a second (round up).
		const int cCollisionSteps = 1;

		// Step the world
		JPH_PhysicsSystem_Update(system, cDeltaTime, cCollisionSteps, jobSystem);
	}

	public void Apply()
	{
		for(var body in bodies)
		{
			JPH_BodyInterface_SetLinearVelocity(BodyInterface, (.)body.ID, &body.Velocity);
		}
	}
}