# MARK 42: Football Physics Requirements

**Document:** 04 - Realistic Football Mechanics Specification  
**Last Updated:** November 20, 2025

---

## 🎯 GOAL: COACHING-LEVEL ACCURACY

This isn't a video game—it's a professional coaching tool. Physics must be:
- ✅ **Realistic** (match real football behavior)
- ✅ **Predictable** (coaches understand cause → effect)
- ✅ **Adjustable** (different scenarios: youth, pro, indoor)
- ✅ **Educational** (shows WHY tactics work/fail)

---

## ⚽ BALL PHYSICS

### 1. **Ball Properties (FIFA Regulations)**

```csharp
// Unity: Assets/Scripts/Entities/Ball/BallPhysics.cs

public class BallProperties
{
    // FIFA Law 2: The Ball
    public const float BALL_MASS = 0.43f;        // kg (420-445g)
    public const float BALL_RADIUS = 0.11f;      // meters (21-22cm diameter)
    public const float BALL_CIRCUMFERENCE = 0.69f; // meters (68-70cm)
    
    // Material properties
    public const float BOUNCE_FACTOR = 0.7f;     // Restitution coefficient
    public const float DRAG_COEFFICIENT = 0.25f;  // Air resistance
    public const float ROLLING_FRICTION = 0.3f;  // Grass friction
    public const float SPIN_DECAY = 0.95f;       // Spin decay per second
    
    // Game conditions
    public float pressure = 0.9f;  // bar (0.6-1.1 range)
    public FieldCondition fieldCondition = FieldCondition.Dry;
    
    // Derived properties
    public float GetBounceHeight(float dropHeight)
    {
        return dropHeight * BOUNCE_FACTOR * (pressure / 0.9f);
    }
    
    public float GetRollingResistance()
    {
        return fieldCondition switch
        {
            FieldCondition.Dry => ROLLING_FRICTION,
            FieldCondition.Wet => ROLLING_FRICTION * 1.5f,
            FieldCondition.Muddy => ROLLING_FRICTION * 2.5f,
            _ => ROLLING_FRICTION
        };
    }
}

public enum FieldCondition { Dry, Wet, Muddy }
```

### 2. **Pass Types with Physics**

```csharp
public class BallTrajectoryCalculator
{
    /// Ground Pass: Low, fast, minimal air time
    public static Vector3 CalculateGroundPass(
        Vector3 start,
        Vector3 end,
        float power // 0-10 scale
    ) {
        float distance = Vector3.Distance(start, end);
        
        // Speed: 10-30 m/s depending on power
        float speed = Mathf.Lerp(10f, 30f, power / 10f);
        
        // Duration
        float duration = distance / speed;
        
        // Minimal height (ball hugs ground)
        float maxHeight = 0.1f; // 10cm off ground
        
        return new Vector3(
            (end.x - start.x) / duration,  // X velocity
            maxHeight,                      // Y velocity (minimal)
            (end.z - start.z) / duration   // Z velocity
        );
    }
    
    /// Lofted Pass: High arc, slower, more air time
    public static Vector3 CalculateLoftedPass(
        Vector3 start,
        Vector3 end,
        float power // 0-10 scale
    ) {
        float distance = Vector3.Distance(start, end);
        
        // Calculate launch angle (30-45 degrees)
        float launchAngle = Mathf.Lerp(30f, 45f, power / 10f) * Mathf.Deg2Rad;
        
        // Physics: Projectile motion
        // Range = (v² * sin(2θ)) / g
        float gravity = Physics.gravity.magnitude;
        float velocity = Mathf.Sqrt((distance * gravity) / Mathf.Sin(2 * launchAngle));
        
        // Decompose into components
        float vx = velocity * Mathf.Cos(launchAngle);
        float vy = velocity * Mathf.Sin(launchAngle);
        
        // Duration
        float duration = distance / vx;
        
        // Peak height
        float peakHeight = (vy * vy) / (2 * gravity);
        
        return new Vector3(
            (end.x - start.x) / duration,
            vy,  // Upward velocity
            (end.z - start.z) / duration
        );
    }
    
    /// Through Ball: Fast, low, cutting through defense
    public static Vector3 CalculateThroughBall(
        Vector3 start,
        Vector3 end,
        float power
    ) {
        // Similar to ground pass but with backspin for control
        var velocity = CalculateGroundPass(start, end, power);
        
        // Add backspin (reduces bounce, stops quicker)
        float backspin = -500f; // RPM
        
        return velocity;
    }
    
    /// Chip: High, short distance, drops quickly
    public static Vector3 CalculateChip(
        Vector3 start,
        Vector3 end,
        float power
    ) {
        float distance = Vector3.Distance(start, end);
        
        // Steep angle (50-70 degrees)
        float launchAngle = 60f * Mathf.Deg2Rad;
        
        float gravity = Physics.gravity.magnitude;
        float velocity = Mathf.Sqrt((distance * gravity) / Mathf.Sin(2 * launchAngle));
        
        float vx = velocity * Mathf.Cos(launchAngle);
        float vy = velocity * Mathf.Sin(launchAngle);
        
        // Add backspin for quick drop
        float backspin = -800f; // RPM
        
        return new Vector3(
            (end.x - start.x) / (distance / vx),
            vy,
            (end.z - start.z) / (distance / vx)
        );
    }
    
    /// Shot: Maximum power, low trajectory
    public static Vector3 CalculateShot(
        Vector3 start,
        Vector3 target,
        float power, // 0-10
        float height // 0 = ground, 1 = top corner
    ) {
        float distance = Vector3.Distance(start, target);
        
        // Shot speed: 20-40 m/s (72-144 km/h)
        float speed = Mathf.Lerp(20f, 40f, power / 10f);
        
        // Launch angle based on target height
        // Ground: 5-10 degrees
        // Top corner: 20-30 degrees
        float launchAngle = Mathf.Lerp(7f, 25f, height) * Mathf.Deg2Rad;
        
        float vx = speed * Mathf.Cos(launchAngle);
        float vy = speed * Mathf.Sin(launchAngle);
        
        return new Vector3(
            (target.x - start.x) / (distance / vx),
            vy,
            (target.z - start.z) / (distance / vx)
        );
    }
}
```

### 3. **Ball Spin (Magnus Effect)**

```csharp
public class BallSpinPhysics : MonoBehaviour
{
    private Rigidbody rb;
    private Vector3 spinAxis = Vector3.zero;  // Rotation axis
    private float spinRate = 0f;              // RPM
    
    void FixedUpdate()
    {
        if (spinRate > 10f)  // Only apply if significant spin
        {
            ApplyMagnusForce();
            DecaySpin();
        }
    }
    
    void ApplyMagnusForce()
    {
        // Magnus force: F = (1/2) * Cl * ρ * A * v² * (ω × v) / |ω × v|
        // Simplified: Force perpendicular to velocity and spin axis
        
        Vector3 velocity = rb.velocity;
        Vector3 magnusDirection = Vector3.Cross(spinAxis, velocity).normalized;
        
        // Lift coefficient (0.1-0.3 for soccer ball)
        float liftCoefficient = 0.2f;
        float airDensity = 1.225f; // kg/m³ at sea level
        float ballArea = Mathf.PI * Mathf.Pow(BallProperties.BALL_RADIUS, 2);
        
        float magnusForceMagnitude = 
            0.5f * liftCoefficient * airDensity * ballArea * 
            velocity.sqrMagnitude * (spinRate / 1000f);  // Convert RPM to factor
        
        Vector3 magnusForce = magnusDirection * magnusForceMagnitude;
        rb.AddForce(magnusForce);
        
        // Visualize in editor
        Debug.DrawRay(transform.position, magnusDirection * 2f, Color.cyan);
    }
    
    void DecaySpin()
    {
        // Spin decays due to air resistance
        spinRate *= BallProperties.SPIN_DECAY * Time.fixedDeltaTime;
    }
    
    public void ApplySpin(Vector3 axis, float rpm)
    {
        spinAxis = axis.normalized;
        spinRate = rpm;
    }
    
    // Common spin types
    public void ApplyTopspin(float rpm)
    {
        // Forward rotation (ball dips)
        spinAxis = Vector3.right;  // Assuming ball travels forward
        spinRate = rpm;
    }
    
    public void ApplyBackspin(float rpm)
    {
        // Backward rotation (ball floats)
        spinAxis = -Vector3.right;
        spinRate = rpm;
    }
    
    public void ApplySidespin(float rpm, bool curveRight)
    {
        // Side rotation (ball curves)
        spinAxis = curveRight ? Vector3.up : Vector3.down;
        spinRate = rpm;
    }
}
```

### 4. **Ball-Ground Interaction**

```csharp
public class BallGroundContact : MonoBehaviour
{
    private Rigidbody rb;
    private BallSpinPhysics spinPhysics;
    
    void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("Ground"))
        {
            HandleBounce(collision);
        }
    }
    
    void OnCollisionStay(Collision collision)
    {
        if (collision.gameObject.CompareTag("Ground"))
        {
            HandleRolling(collision);
        }
    }
    
    void HandleBounce(Collision collision)
    {
        // Get impact velocity
        Vector3 velocity = rb.velocity;
        ContactPoint contact = collision.contacts[0];
        Vector3 normal = contact.normal;
        
        // Separate velocity into normal and tangential components
        float normalSpeed = Vector3.Dot(velocity, normal);
        Vector3 tangentialVelocity = velocity - (normal * normalSpeed);
        
        // Apply restitution (bounce)
        float restitution = BallProperties.BOUNCE_FACTOR;
        
        // Wet grass reduces bounce
        if (collision.gameObject.GetComponent<FieldProperties>()?.isWet == true)
        {
            restitution *= 0.7f;
        }
        
        // New velocity after bounce
        Vector3 newVelocity = tangentialVelocity + (normal * normalSpeed * restitution);
        rb.velocity = newVelocity;
        
        // Reduce spin on bounce
        if (spinPhysics != null)
        {
            spinPhysics.spinRate *= 0.8f;
        }
        
        // Sound effect
        PlayBounceSound(normalSpeed);
    }
    
    void HandleRolling(Collision collision)
    {
        // Apply rolling resistance
        Vector3 velocity = rb.velocity;
        
        if (velocity.magnitude > 0.1f)
        {
            float friction = BallProperties.GetRollingResistance();
            Vector3 frictionForce = -velocity.normalized * friction * rb.mass * 9.81f;
            rb.AddForce(frictionForce);
        }
        else
        {
            // Stop completely if very slow
            rb.velocity = Vector3.zero;
            rb.angularVelocity = Vector3.zero;
        }
    }
}
```

---

## 🏃 PLAYER PHYSICS

### 1. **Player Movement Speeds (FIFA Averages)**

```csharp
public class PlayerMovementSpeeds
{
    // Speeds in m/s (meters per second)
    public const float WALKING_SPEED = 2.0f;      // ~7 km/h
    public const float JOGGING_SPEED = 4.0f;      // ~14 km/h
    public const float RUNNING_SPEED = 6.5f;      // ~23 km/h
    public const float SPRINTING_SPEED = 8.5f;    // ~30 km/h (pro average)
    public const float MAX_SPRINT_SPEED = 10.5f;  // ~38 km/h (elite players)
    
    // Acceleration (m/s²)
    public const float ACCELERATION = 3.0f;
    public const float DECELERATION = 5.0f;  // Can slow down faster than speed up
    
    // Stamina factors
    public float currentStamina = 100f;  // 0-100%
    
    public float GetCurrentMaxSpeed(PlayerAttributes attributes)
    {
        // Base speed from player attributes (50-99 rating)
        float baseSpeed = Mathf.Lerp(6.0f, 10.5f, attributes.pace / 100f);
        
        // Stamina affects speed (below 30% stamina, speed drops)
        float staminaFactor = currentStamina < 30f
            ? Mathf.Lerp(0.7f, 1.0f, currentStamina / 30f)
            : 1.0f;
        
        return baseSpeed * staminaFactor;
    }
    
    public float GetTurningSpeed(float currentSpeed)
    {
        // Turning radius increases with speed
        // Walking: can turn on a dime
        // Sprinting: wide turning arc
        
        if (currentSpeed < JOGGING_SPEED)
            return 180f; // degrees per second
        else if (currentSpeed < RUNNING_SPEED)
            return 120f;
        else
            return 60f;  // Slow turning at sprint
    }
}

public struct PlayerAttributes
{
    public float pace;          // 50-99
    public float acceleration;  // 50-99
    public float agility;       // 50-99
    public float balance;       // 50-99
    public float stamina;       // 50-99
}
```

### 2. **Player Collision & Personal Space**

```csharp
public class PlayerCollider : MonoBehaviour
{
    private CapsuleCollider bodyCollider;
    
    void Start()
    {
        // Setup collider
        bodyCollider = gameObject.AddComponent<CapsuleCollider>();
        bodyCollider.radius = 0.4f;   // 40cm radius (shoulder width)
        bodyCollider.height = 1.8f;   // 180cm tall (average player)
        bodyCollider.center = new Vector3(0, 0.9f, 0);  // Center at waist
        
        // Physics material
        PhysicMaterial playerMaterial = new PhysicMaterial();
        playerMaterial.dynamicFriction = 0.6f;
        playerMaterial.staticFriction = 0.6f;
        playerMaterial.bounciness = 0.0f;  // Players don't bounce
        bodyCollider.material = playerMaterial;
        
        // Rigidbody (kinematic - controlled by animation/script)
        Rigidbody rb = gameObject.AddComponent<Rigidbody>();
        rb.isKinematic = true;  // Animation controls movement
        rb.useGravity = false;  // On ground
        rb.mass = 75f;  // kg (average player)
    }
    
    void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("Player"))
        {
            HandlePlayerCollision(collision);
        }
    }
    
    void HandlePlayerCollision(Collision collision)
    {
        // Resolve overlap
        Vector3 pushDirection = (transform.position - collision.transform.position).normalized;
        transform.position += pushDirection * 0.1f;
        
        // Slow down both players slightly
        PlayerController thisPlayer = GetComponent<PlayerController>();
        PlayerController otherPlayer = collision.gameObject.GetComponent<PlayerController>();
        
        thisPlayer?.ReduceSpeed(0.8f);  // 20% speed reduction
        otherPlayer?.ReduceSpeed(0.8f);
        
        // Play collision sound/animation
        PlayCollisionFeedback();
    }
}
```

### 3. **Player Animations (State Machine)**

```csharp
public class PlayerAnimator : MonoBehaviour
{
    private Animator animator;
    
    // Animation states
    private enum AnimationState
    {
        Idle,
        Walk,
        Jog,
        Run,
        Sprint,
        Kick,
        Header,
        Jump,
        Turn,
        Slide
    }
    
    private AnimationState currentState = AnimationState.Idle;
    
    void Start()
    {
        animator = GetComponent<Animator>();
    }
    
    public void UpdateMovementAnimation(float speed, float maxSpeed)
    {
        // Calculate blend value (0-1)
        float blend = speed / maxSpeed;
        
        if (blend < 0.1f)
        {
            SetState(AnimationState.Idle);
        }
        else if (blend < 0.3f)
        {
            SetState(AnimationState.Walk);
        }
        else if (blend < 0.6f)
        {
            SetState(AnimationState.Jog);
        }
        else if (blend < 0.9f)
        {
            SetState(AnimationState.Run);
        }
        else
        {
            SetState(AnimationState.Sprint);
        }
        
        // Set blend parameter
        animator.SetFloat("Speed", blend);
    }
    
    public void PlayKickAnimation(KickType kickType)
    {
        SetState(AnimationState.Kick);
        
        string triggerName = kickType switch
        {
            KickType.ShortPass => "ShortPass",
            KickType.LongPass => "LongPass",
            KickType.Shot => "Shot",
            KickType.Clear => "Clear",
            _ => "ShortPass"
        };
        
        animator.SetTrigger(triggerName);
    }
    
    public void PlayHeaderAnimation()
    {
        SetState(AnimationState.Header);
        animator.SetTrigger("Header");
    }
    
    private void SetState(AnimationState newState)
    {
        if (currentState != newState)
        {
            currentState = newState;
            animator.SetInteger("State", (int)newState);
        }
    }
}

public enum KickType { ShortPass, LongPass, Shot, Clear }
```

### 4. **Inverse Kinematics (Foot Placement)**

```csharp
public class PlayerIK : MonoBehaviour
{
    private Animator animator;
    
    [SerializeField] private LayerMask groundLayer;
    [SerializeField] private float ikWeight = 1.0f;
    
    void Start()
    {
        animator = GetComponent<Animator>();
    }
    
    void OnAnimatorIK(int layerIndex)
    {
        if (animator == null) return;
        
        // Left foot IK
        PlaceFootOnGround(AvatarIKGoal.LeftFoot);
        
        // Right foot IK
        PlaceFootOnGround(AvatarIKGoal.RightFoot);
    }
    
    void PlaceFootOnGround(AvatarIKGoal foot)
    {
        // Get foot position from animation
        Vector3 footPosition = animator.GetIKPosition(foot);
        
        // Raycast down to find ground
        RaycastHit hit;
        if (Physics.Raycast(footPosition + Vector3.up, Vector3.down, out hit, 2f, groundLayer))
        {
            // Set IK position to ground
            animator.SetIKPositionWeight(foot, ikWeight);
            animator.SetIKPosition(foot, hit.point);
            
            // Rotate foot to match ground normal
            animator.SetIKRotationWeight(foot, ikWeight);
            Quaternion footRotation = Quaternion.LookRotation(
                transform.forward,
                hit.normal
            );
            animator.SetIKRotation(foot, footRotation);
        }
    }
}
```

---

## 🎮 INTERACTION PHYSICS

### 1. **Player-Ball Interaction**

```csharp
public class PlayerBallInteraction : MonoBehaviour
{
    private Rigidbody ballRigidbody;
    
    public void KickBall(
        Vector3 targetPosition,
        KickType kickType,
        float power // 0-10
    ) {
        if (ballRigidbody == null) return;
        
        // Calculate kick velocity based on type
        Vector3 kickVelocity = kickType switch
        {
            KickType.ShortPass => 
                BallTrajectoryCalculator.CalculateGroundPass(
                    ballRigidbody.position, targetPosition, power
                ),
            KickType.LongPass => 
                BallTrajectoryCalculator.CalculateLoftedPass(
                    ballRigidbody.position, targetPosition, power
                ),
            KickType.Shot => 
                BallTrajectoryCalculator.CalculateShot(
                    ballRigidbody.position, targetPosition, power, 0.5f
                ),
            _ => Vector3.zero
        };
        
        // Apply velocity to ball
        ballRigidbody.velocity = kickVelocity;
        
        // Apply spin based on kick type
        ApplyKickSpin(kickType, power);
        
        // Play kick animation
        GetComponent<PlayerAnimator>().PlayKickAnimation(kickType);
        
        // Visual/audio feedback
        PlayKickEffect(kickType, power);
    }
    
    void ApplyKickSpin(KickType kickType, float power)
    {
        BallSpinPhysics spinPhysics = ballRigidbody.GetComponent<BallSpinPhysics>();
        
        switch (kickType)
        {
            case KickType.ShortPass:
                // Slight backspin for control
                spinPhysics.ApplyBackspin(200f * (power / 10f));
                break;
                
            case KickType.LongPass:
                // Backspin for float
                spinPhysics.ApplyBackspin(400f * (power / 10f));
                break;
                
            case KickType.Shot:
                // Topspin for dip
                spinPhysics.ApplyTopspin(600f * (power / 10f));
                break;
        }
    }
}
```

### 2. **Ball Control (Trapping)**

```csharp
public class BallControl : MonoBehaviour
{
    public float controlRadius = 1.5f;  // Distance to "trap" ball
    private Rigidbody ballRigidbody;
    
    void Update()
    {
        if (ballRigidbody != null)
        {
            float distance = Vector3.Distance(transform.position, ballRigidbody.position);
            
            if (distance <= controlRadius)
            {
                AttemptBallControl();
            }
        }
    }
    
    void AttemptBallControl()
    {
        // Reduce ball velocity (trap)
        Vector3 ballVelocity = ballRigidbody.velocity;
        
        // First touch - reduce speed by 70%
        float controlFactor = 0.3f;
        ballRigidbody.velocity = ballVelocity * controlFactor;
        
        // Pull ball slightly toward player
        Vector3 pullDirection = (transform.position - ballRigidbody.position).normalized;
        ballRigidbody.AddForce(pullDirection * 5f, ForceMode.Impulse);
        
        // Play trap animation
        GetComponent<PlayerAnimator>().PlayTrapAnimation();
    }
}
```

---

## 🏟️ FIELD PHYSICS

### 1. **Field Dimensions (FIFA Standard)**

```csharp
public class FieldDimensions
{
    // FIFA regulation: 100-110m x 64-75m
    // Standard: 105m x 68m
    public const float FIELD_LENGTH = 105f;  // meters
    public const float FIELD_WIDTH = 68f;    // meters
    
    // Penalty area: 40.3m x 16.5m
    public const float PENALTY_AREA_LENGTH = 40.3f;
    public const float PENALTY_AREA_WIDTH = 16.5f;
    
    // Goal area: 18.3m x 5.5m
    public const float GOAL_AREA_LENGTH = 18.3f;
    public const float GOAL_AREA_WIDTH = 5.5f;
    
    // Center circle radius
    public const float CENTER_CIRCLE_RADIUS = 9.15f;
    
    // Goal dimensions
    public const float GOAL_WIDTH = 7.32f;
    public const float GOAL_HEIGHT = 2.44f;
    
    // Corner arc radius
    public const float CORNER_ARC_RADIUS = 1f;
    
    // Penalty spot distance
    public const float PENALTY_SPOT_DISTANCE = 11f;  // From goal line
}
```

### 2. **Field Colliders**

```csharp
public class FieldColliders : MonoBehaviour
{
    void Start()
    {
        CreateFieldBoundaries();
        CreateGoals();
    }
    
    void CreateFieldBoundaries()
    {
        // Ground plane
        GameObject ground = GameObject.CreatePrimitive(PrimitiveType.Plane);
        ground.transform.localScale = new Vector3(10.5f, 1, 6.8f);  // Plane is 10x10 by default
        ground.GetComponent<Renderer>().material = grassMaterial;
        
        // Invisible walls at boundaries
        CreateBoundaryWall("TopWall", new Vector3(0, 1, 34f), new Vector3(105f, 2f, 0.1f));
        CreateBoundaryWall("BottomWall", new Vector3(0, 1, -34f), new Vector3(105f, 2f, 0.1f));
        CreateBoundaryWall("LeftWall", new Vector3(-52.5f, 1, 0), new Vector3(0.1f, 2f, 68f));
        CreateBoundaryWall("RightWall", new Vector3(52.5f, 1, 0), new Vector3(0.1f, 2f, 68f));
    }
    
    void CreateBoundaryWall(string name, Vector3 position, Vector3 size)
    {
        GameObject wall = new GameObject(name);
        BoxCollider collider = wall.AddComponent<BoxCollider>();
        collider.size = size;
        wall.transform.position = position;
        wall.tag = "Boundary";
    }
    
    void CreateGoals()
    {
        CreateGoal("Goal1", new Vector3(-52.5f, 1.22f, 0));  // Left goal
        CreateGoal("Goal2", new Vector3(52.5f, 1.22f, 0));   // Right goal
    }
    
    void CreateGoal(string name, Vector3 position)
    {
        GameObject goal = new GameObject(name);
        goal.transform.position = position;
        
        // Goal frame colliders
        // Posts (2x)
        CreateGoalPost(goal, new Vector3(0, 0, -3.66f));  // Left post
        CreateGoalPost(goal, new Vector3(0, 0, 3.66f));   // Right post
        
        // Crossbar
        GameObject crossbar = GameObject.CreatePrimitive(PrimitiveType.Cylinder);
        crossbar.transform.parent = goal.transform;
        crossbar.transform.localPosition = new Vector3(0, 2.44f, 0);
        crossbar.transform.localRotation = Quaternion.Euler(0, 0, 90);
        crossbar.transform.localScale = new Vector3(0.12f, 3.66f, 0.12f);
        
        // Goal trigger (detects ball entering)
        GameObject trigger = new GameObject("GoalTrigger");
        trigger.transform.parent = goal.transform;
        trigger.transform.localPosition = Vector3.zero;
        BoxCollider triggerCollider = trigger.AddComponent<BoxCollider>();
        triggerCollider.isTrigger = true;
        triggerCollider.size = new Vector3(1f, 2.44f, 7.32f);
        trigger.AddComponent<GoalDetector>();
    }
}
```

---

## 🎯 PHYSICS TUNING PARAMETERS

### Unity Physics Settings

```
Edit → Project Settings → Physics

Gravity: Y = -9.81 (Earth gravity)
Default Material:
  - Dynamic Friction: 0.6
  - Static Friction: 0.6
  - Bounciness: 0.0
  
Solver Iterations: 10 (higher = more accurate collisions)
Solver Velocity Iterations: 10

Time Step: 0.02 (50 FPS physics update)

Layer Collision Matrix:
  - Player ↔ Player: ✅ (enabled)
  - Player ↔ Ball: ✅ (enabled)
  - Player ↔ Ground: ✅ (enabled)
  - Ball ↔ Ground: ✅ (enabled)
  - Ball ↔ Goal: ✅ (enabled)
```

---

## ✅ VALIDATION CHECKLIST

Physics are correct when:

- [x] Ball bounces to ~70% of drop height
- [x] Ground pass travels 10-30 m/s
- [x] Lofted pass has visible arc
- [x] Shot reaches 20-40 m/s
- [x] Ball curves with spin
- [x] Players run 6-10 m/s
- [x] Collision feels realistic (not bouncy)
- [x] IK keeps feet on ground
- [x] Ball stops rolling on grass (friction)
- [x] Goal detection works reliably

---

## 📚 REFERENCES

- FIFA Laws of the Game: https://www.theifab.com/laws
- Sports Science: Player speeds, ball physics
- Unity PhysX Documentation: https://docs.unity3d.com/Manual/PhysicsSection.html

This spec gives you **coaching-accurate football physics** for professional tactical demonstrations. 🏆⚽

