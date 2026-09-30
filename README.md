# vayuputra-airmouse

## Milestone Guide

- M1 — Simulation Foundation
  - Goal: Get the UAV flying in Gazebo/SITL.
- M2 — ROS 2 Integration
  - Goal: Establish sensor, TF, and vehicle communication.
- M3 — SLAM & Localization
  - Goal: Generate a live map and estimate UAV pose.
- M4 — Autonomous Navigation
  - Goal: Navigate autonomously using Nav2.
- M5 — Exploration
  - Goal: Frontier + NBV autonomous exploration.
- M6 — Survivor Detection
  - Goal: YOLOv11 detection and localization.
- M7 — GCS Integration
  - Goal: Live telemetry, map, and survivor information.
- M8 — Mission Manager
  - Goal: Complete autonomous mission.
- M9 — Hardware Integration
  - Goal: Move validated software from simulation to Jetson + H743.

## Workflow

1. Create issue
2. Create feature branch
3. Develop
4. Test
5. Commit
6. Push
7. Pull request
8. Code review
9. CI/Test
10. Merge into develop
11. Integration test
12. Merge into main

```text
Create Issue
     ↓
Create feature branch
     ↓
Develop
     ↓
Test
     ↓
Commit
     ↓
Push
     ↓
Pull Request
     ↓
Code Review
     ↓
CI/Test
     ↓
Merge into develop
     ↓
Integration test
     ↓
Merge into main
```