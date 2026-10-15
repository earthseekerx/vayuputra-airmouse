# Vayuputra simulation setup

This repository now contains a reproducible Docker entry point, a first-pass sensor quad SDF, and a bounded indoor test world.

## Start the team's known-good stock PX4 SITL baseline

```bash
bash simulation/gazebo/vayuputra-sim.sh check
bash simulation/gazebo/vayuputra-sim.sh up
bash simulation/gazebo/vayuputra-sim.sh status
bash simulation/gazebo/vayuputra-sim.sh ros-check
```

The script uses a digest-pinned image, does not arm or take off automatically, and will not replace an existing container. See [full setup notes](../../docs/gazebo-reproducible.md).

## New simulation assets

- `simulation/models/vayuputra_sensor_quad/model.sdf`: 1.5 kg body, dimensions 0.24 × 0.18 × 0.07 m, inertia values, IMU at 250 Hz, 2D GPU LiDAR at 10 Hz, and RGB-D camera at 15 Hz.
- `simulation/worlds/vayuputra_indoor.sdf`: enclosed 12 × 10 m room, 3 m walls, lighting, floor, and a collision obstacle.
- `simulation/gazebo/check_assets.py`: basic XML and required-sensor/world checks.

Validate the asset files:

```bash
python3 simulation/gazebo/check_assets.py
```

**Important integration boundary:** the sensor quad is a first-pass SDF asset, not yet a verified PX4-controlled airframe. Its sensor topics are Gazebo Transport topics until bridged into ROS 2. PX4 motor plugins/actuator mapping, model spawn in the active PX4 world, and a repeatable takeoff–hover–landing acceptance test still require integration and simulation testing. The stock PX4 baseline can fly, but that alone does not prove the custom model can fly.
