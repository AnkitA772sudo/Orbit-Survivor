# Orbit Survivor

A physics-based sci-fi survival game built in **Godot 4**.
Pilot a small spaceship trapped near a dying star and survive using gravity slingshots around planets.

## Controls

| Key | Action |
|-----|--------|
| W / UP | Thrust |
| A / LEFT | Rotate Left |
| D / RIGHT | Rotate Right |
| SHIFT / SPACE | Boost |
| ESC / P | Pause |

## Features

- **Gravity Physics** - Realistic planetary gravity pulls; use orbital slingshots to maneuver
- **Momentum-Based Flight** - Rotate and thrust with fuel management
- **Hazards** - Meteors, asteroids, solar flares, and black holes
- **Upgrades** - Thrusters, shields, fuel capacity, gravity stabilizer
- **Progressive Difficulty** - Hazards increase over time
- **High Score** - Persistent high score saved locally

## Project Structure

```
Main game/
├── project.godot          # Godot project settings
├── export_presets.cfg     # HTML5 export preset
├── scripts/               # All GDScript files
│   ├── global.gd
│   ├── main_menu.gd
│   ├── game.gd
│   ├── player.gd
│   ├── planet.gd
│   ├── black_hole.gd
│   ├── meteor.gd
│   ├── asteroid.gd
│   ├── solar_flare.gd
│   ├── pickup.gd
│   ├── spawner.gd
│   ├── hud.gd
│   ├── pause_menu.gd
│   ├── game_over.gd
│   └── starfield.gd
└── scenes/                # All Godot scenes
    ├── main_menu.tscn
    ├── game.tscn
    ├── player.tscn
    ├── planet.tscn
    ├── black_hole.tscn
    ├── meteor.tscn
    ├── asteroid.tscn
    ├── solar_flare.tscn
    ├── fuel_pickup.tscn
    ├── repair_kit.tscn
    ├── upgrade.tscn
    ├── hud.tscn
    ├── pause_menu.tscn
    └── game_over.tscn
```

## How to Build & Run

1. Open Godot 4.x
2. Import the `Main game` folder as a project
3. Press **Play** (F5) to test locally
4. For HTML5 export:
   - Project → Export → Web
   - Export Project → Choose a folder
   - Zip the output files
   - Upload to itch.io (set "Kind of project" to HTML)

## itch.io Optimization Notes

- Uses the **Compatibility** renderer for broad WebGL support
- No external assets - all visuals drawn via `_draw()` and CPUParticles2D
- Zero textures - tiny build size
- Keyboard-only controls - no right-click issues in browsers
- Thread support disabled for maximum browser compatibility

"# Orbit-Survivor" 
