# Zeka City: Cleanup Empire

A mobile-first 3D industrial cleanup and recycling management game built with **Godot 4.7.2**.

You operate a mechanized recycling business: collect waste across the city, expand your processing plant, automate collection and sorting, feed production lines, and ship finished goods.

## Gameplay systems

- Third-person industrial recycler robot with touch and keyboard movement.
- City-wide waste collection with capacity, bulky items, rare scrap, and progression missions.
- Automatic unloading into the factory waste tank and a connected conveyor distribution network.
- Five production lines with up to three processing machines each, staged construction, production queues, and dispatch trucks.
- Autonomous utility drones, a ground collection rover, sorting loader robots, and a street-sweeper vehicle.
- Four material-sorting stations for plastic, paper, metal, and glass.
- Factory upgrades for conveyor speed, tank capacity, unloading, packaging, truck fleet, and delivery cadence.
- Local save/load, new-world reset, upgrade progression, and a large endgame cleanup target.
- Procedural industrial environment: steel pipe racks, exhaust stacks, marked service lanes, reinforced waste bins, factory equipment detailing, and industrial vehicle styling.

## Controls

### Android
- Move with the virtual joystick at the lower-left.
- Tap **COLLECT** when close to waste.
- Open **UPGRADES** to improve equipment and automation.
- Pinch with two fingers to zoom the camera.
- Stand on the marked factory waste-tank pad to build it or automatically unload collected waste after it is built.

### Desktop
- Move with **WASD** or the arrow keys.
- Use the on-screen **COLLECT** and **UPGRADES** controls.
- Stand on the marked service pads to trigger automatic interactions.

## Run from source

1. Install **Godot 4.7.2 stable**.
2. Import `project.godot`.
3. Run `Scenes/Main.tscn` (or press **F5**).

The world, vehicles, machines, bins, and industrial props are generated procedurally by the project; no external art pack is required.

## Android release builds

The GitHub Actions workflows validate the project, run a headless gameplay-startup smoke test, and export Android builds.

- **APK:** signed Android package for direct device installation.
- **AAB:** signed Android App Bundle for Google Play submission.
- **Minimum Android SDK:** 24.
- **Target Android SDK:** 36.
- **Architecture:** arm64-v8a.

The release workflow uses the repository's permanent Android signing secrets. Keep the release keystore and its passwords safe: future updates must use the same signing identity.

A successful build is not the same as a Play Store submission. Store listing content, screenshots, privacy disclosures, age rating, and Play Console review are handled separately.

## Save data

Progress is stored locally in `user://trash_empire.save`. Selecting **NEW** permanently resets the current world and its upgrades.
