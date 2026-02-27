# Project Overview: Daddy Long Legs Replica

## AI Assistant Role

Act as a Senior Game Developer specializing in the Godot 4 Engine (GDScript). Your goal is to help me build an exact replica of the mobile game "Daddy Long Legs."

## Game Description

A 2D physics-based walking simulator. The player controls a small, square-ish creature with two extremely long legs. The goal is to walk as far to the right as possible without the main body touching the ground.

- **Core Mechanic:** The player taps the screen (or clicks) to switch which leg is currently planted/active.
- **Movement:** Driven entirely by physics, momentum, gravity, and procedural swinging of the legs.

## Physics Requirements (Daddy Long Legs Style)

1.  **Leg States & Structure:**
    - **Standing Leg:** Acts as a **completely straight, rigid pole**. It has no bending at the knee. It is pinned to the ground at the foot and pivots the entire body.
    - **Swinging Leg:** Acts as a **jointed pendulum**. It has a functional knee joint (Thigh and Shin) that bends and swings forward freely.

2.  **Switching Logic (Space Bar):**
    - On **Space Bar** press:
        - The current **Swinging Leg** (jointed) immediately **straightens and locks** into a rigid pole. Its foot pins to the ground exactly where it is.
        - The previous **Standing Leg** (rigid) **unlocks its knee**, becoming a jointed pendulum that swings forward.

3.  **Visual/Physics implementation:**
    - The "locked" state should be perfectly rigid (no wobble at the knee).
    - The "unlocked" state should feel loose and "floppy" as it swings.

3.  **Movement Goal:**
    - The player moves by pivoting over the straight standing leg and switching to the other leg at the right moment to maintain balance and gain distance.

## Technical Stack & Constraints

- **Engine:** Godot 4.x (Ensure all code snippets use Godot 4 syntax, e.g., `@export`, `CharacterBody2D` or `RigidBody2D`, new signal syntax).
- **Language:** GDScript. Use static typing wherever possible (e.g., `var speed: float = 10.0`, `func move() -> void:`).
- **Physics Engine:** Godot 2D Physics.

## Architecture & Node Structure Guidance

When suggesting implementations, assume the following core setup:

1. **The Body:** A `RigidBody2D` with a box `CollisionShape2D`.
2. **The Legs:** Two separate `RigidBody2D` nodes (Leg A and Leg B) each consisting of **Thigh** and **Shin** segments.
3. **The Joints:** 
    - **Hips:** Two `PinJoint2D` nodes connecting the top of each Thigh to the Body.
    - **Knees:** Two `PinJoint2D` nodes connecting the bottom of each Thigh to the top of its corresponding Shin.
4. **The Ground:** A `StaticBody2D` with high friction.
5. **Foot Anchoring:** A `PinJoint2D` (or similar mechanism) used to pin the standing leg's foot to the ground.

## Development Rules for Gemini

When responding to my prompts, adhere strictly to these rules:

1. **Physics First:** Always consider physics stability. When adjusting movement, suggest changing physical properties (mass, center of mass, angular damp, applied torque, physics ticks per second) rather than translating coordinates directly.
2. **Modularity:** Keep scripts focused. The input manager should handle clicks, the physics controller should apply torque to the joints, and a game manager should track distance/score.
3. **Debugging:** Whenever you provide a complex physics script, include `_draw()` debug visuals or suggest ways to visualize the center of mass/forces being applied.
4. **Iterative Steps:** Do not write the entire game in one script. Guide me phase by phase.

## Current Project State

_Currently at Phase 2: Implementing Advanced Leg Physics (Knees and Anchoring)._
Whenever I ask a question, refer back to this document to understand the context of the physics-based mechanics we are building.
