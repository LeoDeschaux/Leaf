using Jolt;
using System;
using System.Collections;
using RaylibBeef;
using Leaf;
using static Jolt.Jolt;
using static RaylibBeef.Raymath;

namespace Leaf;

public struct PhysicRaycastHit
{
	public PhysicBody Body;
	public JPH_BodyID BodyID;
	public Vector3 Point;
	public Vector3 Normal;
	public float Distance;
}

public struct PhysicShapeCastHit
{
	public PhysicBody Body;
	public JPH_BodyID BodyID;
	public Vector3 Point;
	public Vector3 Normal;
	public float Distance;
	public float Fraction;
}

struct PhysicOverlapContext
{
	public List<JPH_BodyID> Hits;
}

struct PhysicShapeCastContext
{
	public List<JPH_ShapeCastResult> Hits;
}

class PhysicEngine3D
{
	public static PhysicEngine3D Active;

	static int initCount;

	public struct Layers
	{
		public static JPH_ObjectLayer NON_MOVING = 0;
		public static JPH_ObjectLayer MOVING = 1;
		public static JPH_ObjectLayer PLAYER = 2;
		public static JPH_ObjectLayer SENSOR = 3;
		public static JPH_ObjectLayer NUM_LAYERS = 4;
	};

	public struct BroadPhaseLayers
	{
		public static JPH_BroadPhaseLayer NON_MOVING = 0;
		public static JPH_BroadPhaseLayer MOVING = 1;
		public static JPH_BroadPhaseLayer PLAYER = 2;
		public static JPH_BroadPhaseLayer SENSOR = 3;
		public static int NUM_LAYERS = 4;
	};

	public const uint32 ALL_LAYERS = 0xFFFFFFFF;

	bool initialized;
	JPH_JobSystem* jobSystem;

	float cDeltaTime;
	float timeAccumulator;
	JPH_PhysicsSystem* system;
	public JPH_BodyInterface* BodyInterface;
	JPH_BodyID floorId;

	List<PhysicBody> bodies = new .() ~ delete _;
	List<CharacterPhysic> characters = new .() ~ delete _;

	public Event<delegate void(float)> OnFixedStep = default;

	public float FixedDeltaTime => cDeltaTime;
	public JPH_PhysicsSystem* System => system;

	public this()
	{
	}

	public ~this()
	{
		if(Active == this)
			Active = null;

		for(var character in characters)
		{
			if(character.Virtual != null)
				JPH_CharacterBase_Destroy((JPH_CharacterBase*)character.Virtual);

			delete character;
		}

		for(var body in bodies)
		{
			JPH_BodyInterface_RemoveAndDestroyBody(BodyInterface, (.)body.ID);
			delete body;
		}

		OnFixedStep.Dispose();

		if(!initialized)
			return;

		if(jobSystem != null)
			JPH_JobSystem_Destroy(jobSystem);

		if(system != null)
			JPH_PhysicsSystem_Destroy(system);

		initialized = false;
		initCount--;
		if(initCount == 0)
			JPH_Shutdown();
	}

	public void Init()
	{
		if(initialized)
			return;

		if(initCount == 0 && !JPH_Init())
			return;

		initCount++;
		initialized = true;
		jobSystem = JPH_JobSystemThreadPool_Create(null);

		JPH_ObjectLayerPairFilter* objectLayerPairFilterTable = JPH_ObjectLayerPairFilterTable_Create((uint32)Layers.NUM_LAYERS);
		for(uint32 a = 0; a < Layers.NUM_LAYERS; a++)
			for(uint32 b = 0; b < Layers.NUM_LAYERS; b++)
				JPH_ObjectLayerPairFilterTable_EnableCollision(objectLayerPairFilterTable, a, b);

		JPH_BroadPhaseLayerInterface* broadPhaseLayerInterfaceTable = JPH_BroadPhaseLayerInterfaceTable_Create((uint32)Layers.NUM_LAYERS, (uint32)BroadPhaseLayers.NUM_LAYERS);
		JPH_BroadPhaseLayerInterfaceTable_MapObjectToBroadPhaseLayer(broadPhaseLayerInterfaceTable, Layers.NON_MOVING, BroadPhaseLayers.NON_MOVING);
		JPH_BroadPhaseLayerInterfaceTable_MapObjectToBroadPhaseLayer(broadPhaseLayerInterfaceTable, Layers.MOVING, BroadPhaseLayers.MOVING);
		JPH_BroadPhaseLayerInterfaceTable_MapObjectToBroadPhaseLayer(broadPhaseLayerInterfaceTable, Layers.PLAYER, BroadPhaseLayers.PLAYER);
		JPH_BroadPhaseLayerInterfaceTable_MapObjectToBroadPhaseLayer(broadPhaseLayerInterfaceTable, Layers.SENSOR, BroadPhaseLayers.SENSOR);

		JPH_ObjectVsBroadPhaseLayerFilter* objectVsBroadPhaseLayerFilter = JPH_ObjectVsBroadPhaseLayerFilterTable_Create(broadPhaseLayerInterfaceTable,
			(uint32)BroadPhaseLayers.NUM_LAYERS, objectLayerPairFilterTable, (uint32)Layers.NUM_LAYERS);

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
		JPH_Vec3 boxHalfExtents = .(100.0f, 1.0f, 100.0f);
		JPH_BoxShape* floorShape = JPH_BoxShape_Create(&boxHalfExtents, JPH_DEFAULT_CONVEX_RADIUS);

		JPH_Vec3 floorPosition = .(0.0f, -1.0f, 0.0f);
		JPH_BodyCreationSettings* floorSettings = JPH_BodyCreationSettings_Create3(
			(JPH_Shape*)floorShape,
			&floorPosition,
			null,
			JPH_MotionType.Static,
			Layers.NON_MOVING);

		floorId = JPH_BodyInterface_CreateAndAddBody(BodyInterface, floorSettings, JPH_Activation.DontActivate);
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

	public SpherePhysic GenerateSphere(Vector3 position, Vector3 velocity, float radius,
		JPH_Quat* rotation = null, float gravityFactor = 1.0f, JPH_MotionType motionType = .Dynamic, JPH_ObjectLayer layers = Layers.MOVING,
		bool isSensor = false)
	{
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

			JPH_BodyCreationSettings_SetIsSensor(sphereSettings, isSensor);
			sphereId = (.)JPH_BodyInterface_CreateAndAddBody(BodyInterface, sphereSettings, JPH_Activation.Activate);
			JPH_BodyCreationSettings_Destroy(sphereSettings);
			JPH_Shape_Destroy((JPH_Shape*)sphereShape);
		}

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
		JPH_Quat* rotation = null, float gravityFactor = 1.0f, JPH_MotionType motionType = .Dynamic, JPH_ObjectLayer layers = Layers.MOVING,
		bool isSensor = false)
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

			JPH_BodyCreationSettings_SetIsSensor(boxSettings, isSensor);
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

	public CapsulePhysic GenerateCapsule(Vector3 position, Vector3 velocity, float halfHeight, float radius,
		JPH_Quat* rotation = null, float gravityFactor = 1.0f, JPH_MotionType motionType = .Dynamic, JPH_ObjectLayer layers = Layers.MOVING,
		bool isSensor = false)
	{
		JPH_CapsuleShape* capsuleShape = JPH_CapsuleShape_Create(halfHeight, radius);
		if(capsuleShape == null)
			return null;

		JPH_Vec3 capsulePosition = position;
		JPH_BodyCreationSettings* capsuleSettings = JPH_BodyCreationSettings_Create3(
			(JPH_Shape*)capsuleShape,
			&capsulePosition,
			rotation,
			motionType,
			layers);

		JPH_BodyCreationSettings_SetIsSensor(capsuleSettings, isSensor);
		int capsuleId = (.)JPH_BodyInterface_CreateAndAddBody(BodyInterface, capsuleSettings, JPH_Activation.Activate);
		JPH_BodyCreationSettings_Destroy(capsuleSettings);
		JPH_Shape_Destroy((JPH_Shape*)capsuleShape);

		JPH_Vec3 vel = velocity;
		JPH_BodyInterface_SetLinearVelocity(BodyInterface, (.)capsuleId, &vel);
		JPH_BodyInterface_SetGravityFactor(BodyInterface, (.)capsuleId, gravityFactor);

		CapsulePhysic capsule = new .(this);
		capsule.ID = capsuleId;
		capsule.Position = position;
		capsule.Velocity = velocity;
		capsule.Rotation = rotation != null ? *rotation : IdentityRotation();
		capsule.HalfHeight = halfHeight;
		capsule.Radius = radius;

		bodies.Add(capsule);

		return capsule;
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

	public CharacterPhysic CreateCharacter(Vector3 position, float height, float radius,
		float maxSlopeAngle = 50.0f, JPH_ObjectLayer layer = Layers.PLAYER)
	{
		float halfHeight = Math.Max(height * 0.5f - radius, 0.01f);
		JPH_CapsuleShape* capsuleShape = JPH_CapsuleShape_Create(halfHeight, radius);
		if(capsuleShape == null)
			return null;

		JPH_CharacterVirtualSettings settings;
		JPH_CharacterVirtualSettings_Init(&settings);
		settings.base.shape = (JPH_Shape*)capsuleShape;
		settings.base.up = .(0, 1, 0);
		settings.base.maxSlopeAngle = maxSlopeAngle * DEG2RAD;
		settings.base.supportingVolume.normal = .(0, 1, 0);
		settings.base.supportingVolume.distance = -radius;
		settings.mass = 80.0f;
		settings.maxStrength = 500.0f;
		settings.penetrationRecoverySpeed = 0.2f;
		settings.characterPadding = 0.02f;

		JPH_RVec3 characterPosition = position;
		JPH_Quat rotation = IdentityRotation();
		JPH_CharacterVirtual* character = JPH_CharacterVirtual_Create(&settings, &characterPosition, &rotation, 0, system);
		JPH_Shape_Destroy((JPH_Shape*)capsuleShape);

		if(character == null)
			return null;

		CharacterPhysic result = new .(this);
		result.Virtual = character;
		result.ID = (.)JPH_CharacterVirtual_GetID(character);
		result.Position = position;
		result.Velocity = default;
		result.Rotation = rotation;
		result.Height = height;
		result.Radius = radius;
		result.Layer = layer;
		result.IsGrounded = false;
		characters.Add(result);
		return result;
	}

	public void DestroyCharacter(CharacterPhysic character)
	{
		if(character == null)
			return;

		if(character.Virtual != null)
			JPH_CharacterBase_Destroy((JPH_CharacterBase*)character.Virtual);

		characters.Remove(character);
		delete character;
	}

	public void SetCharacterPosition(CharacterPhysic character, Vector3 position, JPH_Quat* rotation = null)
	{
		if(character == null || character.Virtual == null)
			return;

		JPH_RVec3 p = position;
		JPH_CharacterVirtual_SetPosition(character.Virtual, &p);

		if(rotation != null)
			JPH_CharacterVirtual_SetRotation(character.Virtual, rotation);

		character.Position = position;
	}

	public void SetCharacterVelocity(CharacterPhysic character, Vector3 velocity)
	{
		if(character == null || character.Virtual == null)
			return;

		JPH_Vec3 v = velocity;
		JPH_CharacterVirtual_SetLinearVelocity(character.Virtual, &v);
		character.Velocity = velocity;
	}

	public Vector3 GetCharacterVelocity(CharacterPhysic character)
	{
		if(character == null || character.Virtual == null)
			return default;

		JPH_Vec3 velocity = default;
		JPH_CharacterVirtual_GetLinearVelocity(character.Virtual, &velocity);
		return velocity;
	}

	public Vector3 GetCharacterGroundVelocity(CharacterPhysic character)
	{
		if(character == null || character.Virtual == null)
			return default;

		JPH_Vec3 velocity = default;
		JPH_CharacterBase_GetGroundVelocity((JPH_CharacterBase*)character.Virtual, &velocity);
		return velocity;
	}

	public void UpdateCharacter(CharacterPhysic character, float deltaTime, float stepHeight = 0.4f, float snapToGround = 0.5f)
	{
		if(character == null || character.Virtual == null)
			return;

		JPH_ExtendedUpdateSettings settings;
		settings.stickToFloorStepDown = .(0, -snapToGround, 0);
		settings.walkStairsStepUp = .(0, stepHeight, 0);
		settings.walkStairsMinStepForward = 0.02f;
		settings.walkStairsStepForwardTest = 0.15f;
		settings.walkStairsCosAngleForwardContact = Math.Cos(75.0f * DEG2RAD);
		settings.walkStairsStepDownExtra = default;

		JPH_CharacterVirtual_ExtendedUpdate(character.Virtual, deltaTime, &settings, character.Layer, system, null, null);

		JPH_RVec3 position = default;
		JPH_CharacterVirtual_GetPosition(character.Virtual, &position);
		character.Position = position;

		JPH_Vec3 velocity = default;
		JPH_CharacterVirtual_GetLinearVelocity(character.Virtual, &velocity);
		character.Velocity = velocity;

		JPH_Quat rotation = IdentityRotation();
		JPH_CharacterVirtual_GetRotation(character.Virtual, &rotation);
		character.Rotation = rotation;

		character.IsGrounded = JPH_CharacterBase_IsSupported((JPH_CharacterBase*)character.Virtual);
	}

	public Vector3 GetCharacterGroundNormal(CharacterPhysic character)
	{
		if(character == null || character.Virtual == null)
			return .(0, 1, 0);

		JPH_Vec3 normal = .(0, 1, 0);
		JPH_CharacterBase_GetGroundNormal((JPH_CharacterBase*)character.Virtual, &normal);
		return normal;
	}

	public JPH_GroundState GetCharacterGroundState(CharacterPhysic character)
	{
		if(character == null || character.Virtual == null)
			return .InAir;

		return JPH_CharacterBase_GetGroundState((JPH_CharacterBase*)character.Virtual);
	}

	public void SetCharacterSlopeLimit(CharacterPhysic character, float maxSlopeAngle)
	{
		if(character == null || character.Virtual == null)
			return;

		JPH_CharacterBase_SetMaxSlopeAngle((JPH_CharacterBase*)character.Virtual, maxSlopeAngle * DEG2RAD);
	}

	public PhysicBody FindBody(JPH_BodyID bodyID)
	{
		for(var body in bodies)
			if((JPH_BodyID)body.ID == bodyID)
				return body;

		return null;
	}

	public CharacterPhysic FindCharacter(JPH_CharacterID characterID)
	{
		for(var character in characters)
			if((JPH_CharacterID)character.ID == characterID)
				return character;

		return null;
	}

	public List<PhysicBody> Bodies => bodies;
	public List<CharacterPhysic> Characters => characters;

	public static uint32 LayerBit(JPH_ObjectLayer layer)
	{
		return (uint32)1 << (uint32)layer;
	}

	public bool MatchesLayer(JPH_BodyID bodyID, uint32 layerMask)
	{
		var layer = JPH_BodyInterface_GetObjectLayer(BodyInterface, bodyID);
		return (layerMask & LayerBit(layer)) != 0;
	}

	public bool Raycast(Vector3 origin, Vector3 direction, float maxDistance, out PhysicRaycastHit hit,
		uint32 layerMask = ALL_LAYERS, PhysicBody ignore = null)
	{
		hit = default;

		float length = Vector3Length(direction);
		if(length <= 0.00001f || maxDistance <= 0.0f)
			return false;

		Vector3 dir = direction / length;
		Vector3 start = origin;
		float remaining = maxDistance;
		JPH_NarrowPhaseQuery* query = JPH_PhysicsSystem_GetNarrowPhaseQuery(system);

		for(int attempt = 0; attempt < 32; attempt++)
		{
			if(remaining <= 0.0001f)
				return false;

			JPH_RVec3 rayOrigin = start;
			JPH_Vec3 rayDirection = dir * remaining;
			JPH_RayCastResult result = default;

			if(!JPH_NarrowPhaseQuery_CastRay(query, &rayOrigin, &rayDirection, &result, null, null, null))
				return false;

			float distance = result.fraction * remaining;
			Vector3 point = start + dir * distance;
			var body = FindBody(result.bodyID);

			bool accepted = body != null && (ignore == null || body != ignore) && MatchesLayer(result.bodyID, layerMask);

			if(accepted)
			{
				Vector3 normal = .(0, 1, 0);
				JPH_RVec3 worldPoint = point;
				JPH_BodyLockRead bodyLock = default;
				JPH_BodyLockInterface* lockInterface = JPH_PhysicsSystem_GetBodyLockInterface(system);
				JPH_BodyLockInterface_LockRead(lockInterface, result.bodyID, &bodyLock);
				if(bodyLock.body != null)
					JPH_Body_GetWorldSpaceSurfaceNormal(bodyLock.body, result.subShapeID2, &worldPoint, &normal);
				JPH_BodyLockInterface_UnlockRead(lockInterface, &bodyLock);

				hit.Body = body;
				hit.BodyID = result.bodyID;
				hit.Point = point;
				hit.Normal = normal;
				hit.Distance = maxDistance - remaining + distance;
				return true;
			}

			float advance = Math.Min(distance + 0.01f, remaining);
			start += dir * advance;
			remaining -= advance;
		}

		return false;
	}

	[CLink]
	static void OverlapCollector(void* userData, JPH_CollideShapeResult* result)
	{
		var context = (PhysicOverlapContext*)userData;
		context.Hits.Add(result.bodyID2);
	}

	public void OverlapShape(JPH_Shape* shape, Vector3 position, Quaternion rotation, List<PhysicBody> results,
		uint32 layerMask = ALL_LAYERS, PhysicBody ignore = null)
	{
		if(shape == null)
			return;

		PhysicOverlapContext context = .();
		context.Hits = new .();
		defer delete context.Hits;

		JPH_RMat4 transform = MakeTransform(position, rotation);
		JPH_Vec3 scale = .(1, 1, 1);
		JPH_CollideShapeSettings settings;
		JPH_CollideShapeSettings_Init(&settings);
		settings.base.collectFacesMode = .NoFaces;
		JPH_RVec3 baseOffset = .(0, 0, 0);

		JPH_CollideShapeResultCallback callback = => OverlapCollector;
		JPH_NarrowPhaseQuery* query = JPH_PhysicsSystem_GetNarrowPhaseQuery(system);
		JPH_NarrowPhaseQuery_CollideShape2(query, shape, &scale, &transform, &settings, &baseOffset,
			.AllHit, callback, &context, null, null, null, null);

		for(var bodyID in context.Hits)
		{
			var body = FindBody(bodyID);
			if(body == null || (ignore != null && body == ignore) || !MatchesLayer(bodyID, layerMask))
				continue;

			if(!results.Contains(body))
				results.Add(body);
		}
	}

	public void OverlapSphere(Vector3 center, float radius, List<PhysicBody> results,
		uint32 layerMask = ALL_LAYERS, PhysicBody ignore = null)
	{
		JPH_SphereShape* shape = JPH_SphereShape_Create(radius);
		if(shape == null)
			return;

		OverlapShape((JPH_Shape*)shape, center, default, results, layerMask, ignore);
		JPH_Shape_Destroy((JPH_Shape*)shape);
	}

	public void OverlapBox(Vector3 center, Vector3 halfExtents, Quaternion rotation, List<PhysicBody> results,
		uint32 layerMask = ALL_LAYERS, PhysicBody ignore = null)
	{
		JPH_Vec3 he = halfExtents;
		JPH_BoxShape* shape = JPH_BoxShape_Create(&he, JPH_DEFAULT_CONVEX_RADIUS);
		if(shape == null)
			return;

		OverlapShape((JPH_Shape*)shape, center, rotation, results, layerMask, ignore);
		JPH_Shape_Destroy((JPH_Shape*)shape);
	}

	public void OverlapCapsule(Vector3 center, float halfHeight, float radius, Quaternion rotation, List<PhysicBody> results,
		uint32 layerMask = ALL_LAYERS, PhysicBody ignore = null)
	{
		JPH_CapsuleShape* shape = JPH_CapsuleShape_Create(halfHeight, radius);
		if(shape == null)
			return;

		OverlapShape((JPH_Shape*)shape, center, rotation, results, layerMask, ignore);
		JPH_Shape_Destroy((JPH_Shape*)shape);
	}

	[CLink]
	static void ShapeCastCollector(void* userData, JPH_ShapeCastResult* result)
	{
		var context = (PhysicShapeCastContext*)userData;
		context.Hits.Add(*result);
	}

	public bool CastShape(JPH_Shape* shape, Vector3 position, Quaternion rotation, Vector3 direction, float maxDistance,
		out PhysicShapeCastHit hit, uint32 layerMask = ALL_LAYERS, PhysicBody ignore = null)
	{
		hit = default;

		if(shape == null)
			return false;

		PhysicShapeCastContext context = .();
		context.Hits = new .();
		defer delete context.Hits;

		JPH_RMat4 transform = MakeTransform(position, rotation);
		JPH_Vec3 sweep = direction * maxDistance;
		JPH_ShapeCastSettings settings;
		JPH_ShapeCastSettings_Init(&settings);
		settings.base.collectFacesMode = .NoFaces;
		JPH_RVec3 baseOffset = .(0, 0, 0);

		JPH_CastShapeResultCallback callback = => ShapeCastCollector;
		JPH_NarrowPhaseQuery* query = JPH_PhysicsSystem_GetNarrowPhaseQuery(system);
		JPH_NarrowPhaseQuery_CastShape2(query, shape, &transform, &sweep, &settings, &baseOffset,
			.AllHitSorted, callback, &context, null, null, null, null);

		for(var result in context.Hits)
		{
			var body = FindBody(result.bodyID2);
			if(body == null || (ignore != null && body == ignore) || !MatchesLayer(result.bodyID2, layerMask))
				continue;

			hit.Body = body;
			hit.BodyID = result.bodyID2;
			hit.Point = result.contactPointOn1;
			hit.Normal = result.penetrationAxis;
			hit.Fraction = result.fraction;
			hit.Distance = result.fraction * maxDistance;
			return true;
		}

		return false;
	}

	public bool CastSphere(Vector3 position, float radius, Vector3 direction, float maxDistance,
		out PhysicShapeCastHit hit, uint32 layerMask = ALL_LAYERS, PhysicBody ignore = null)
	{
		JPH_SphereShape* shape = JPH_SphereShape_Create(radius);
		if(shape == null)
		{
			hit = default;
			return false;
		}

		bool result = CastShape((JPH_Shape*)shape, position, default, direction, maxDistance, out hit, layerMask, ignore);
		JPH_Shape_Destroy((JPH_Shape*)shape);
		return result;
	}

	public bool CastBox(Vector3 position, Vector3 halfExtents, Quaternion rotation, Vector3 direction, float maxDistance,
		out PhysicShapeCastHit hit, uint32 layerMask = ALL_LAYERS, PhysicBody ignore = null)
	{
		JPH_Vec3 he = halfExtents;
		JPH_BoxShape* shape = JPH_BoxShape_Create(&he, JPH_DEFAULT_CONVEX_RADIUS);
		if(shape == null)
		{
			hit = default;
			return false;
		}

		bool result = CastShape((JPH_Shape*)shape, position, rotation, direction, maxDistance, out hit, layerMask, ignore);
		JPH_Shape_Destroy((JPH_Shape*)shape);
		return result;
	}

	public bool CastCapsule(Vector3 position, float halfHeight, float radius, Quaternion rotation, Vector3 direction, float maxDistance,
		out PhysicShapeCastHit hit, uint32 layerMask = ALL_LAYERS, PhysicBody ignore = null)
	{
		JPH_CapsuleShape* shape = JPH_CapsuleShape_Create(halfHeight, radius);
		if(shape == null)
		{
			hit = default;
			return false;
		}

		bool result = CastShape((JPH_Shape*)shape, position, rotation, direction, maxDistance, out hit, layerMask, ignore);
		JPH_Shape_Destroy((JPH_Shape*)shape);
		return result;
	}

	public static JPH_RMat4 MakeTransform(Vector3 position, Quaternion rotation)
	{
		Vector3 right = Vector3RotateByQuaternion(.(1, 0, 0), rotation);
		Vector3 up = Vector3RotateByQuaternion(.(0, 1, 0), rotation);
		Vector3 forward = Vector3RotateByQuaternion(.(0, 0, 1), rotation);

		JPH_RMat4 matrix = default;
		matrix.column[0].x = right.x;
		matrix.column[0].y = right.y;
		matrix.column[0].z = right.z;
		matrix.column[0].w = 0;

		matrix.column[1].x = up.x;
		matrix.column[1].y = up.y;
		matrix.column[1].z = up.z;
		matrix.column[1].w = 0;

		matrix.column[2].x = forward.x;
		matrix.column[2].y = forward.y;
		matrix.column[2].z = forward.z;
		matrix.column[2].w = 0;

		matrix.column[3].x = position.x;
		matrix.column[3].y = position.y;
		matrix.column[3].z = position.z;
		matrix.column[3].w = 1;
		return matrix;
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
		Active = this;
		cDeltaTime = 1.0f / 60.0f;
		timeAccumulator = 0;
		JPH_PhysicsSystem_OptimizeBroadPhase(system);
	}

	int step = 0;
	public void Update()
	{
		++step;

		timeAccumulator += Time.DeltaTime;

		const int cMaxStepsPerFrame = 5;
		if (timeAccumulator > cDeltaTime * cMaxStepsPerFrame)
			timeAccumulator = cDeltaTime * cMaxStepsPerFrame;

		const int cCollisionSteps = 1;
		while (timeAccumulator >= cDeltaTime)
		{
			OnFixedStep.Invoke(cDeltaTime);
			JPH_PhysicsSystem_Update(system, cDeltaTime, cCollisionSteps, jobSystem);
			timeAccumulator -= cDeltaTime;
		}

		SyncBodies();
	}

	public void StepOnce()
	{
		if(!initialized || system == null)
			return;

		if(cDeltaTime <= 0.0f)
			cDeltaTime = 1.0f / 60.0f;

		OnFixedStep.Invoke(cDeltaTime);
		JPH_PhysicsSystem_Update(system, cDeltaTime, 1, jobSystem);
		SyncBodies();
		timeAccumulator = 0.0f;
	}

	void SyncBodies()
	{
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
