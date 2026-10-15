#!/usr/bin/env python3
"""Offline structural checks for Vayuputra SDF assets; no simulator required."""
from pathlib import Path
import sys
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[2]
MODEL = ROOT / "simulation/models/vayuputra_sensor_quad/model.sdf"
CONFIG = ROOT / "simulation/models/vayuputra_sensor_quad/model.config"
WORLD = ROOT / "simulation/worlds/vayuputra_indoor.sdf"

def parse(path):
    try:
        return ET.parse(path).getroot()
    except (ET.ParseError, OSError) as exc:
        print(f"FAIL {path.relative_to(ROOT)}: {exc}")
        return None

def main():
    ok = True
    model, config, world = map(parse, (MODEL, CONFIG, WORLD))
    for name, root in (("model", model), ("config", config), ("world", world)):
        if root is None:
            ok = False
        else:
            print(f"PASS {name} XML parses")
    if model is not None:
        sensors = {node.attrib.get("name"): node.attrib.get("type") for node in model.findall(".//sensor")}
        for name, expected in (("imu", "imu"), ("front_lidar", "gpu_lidar"), ("depth_camera", "rgbd_camera")):
            if sensors.get(name) == expected:
                print(f"PASS sensor {name}: {expected}")
            else:
                print(f"FAIL sensor {name}: expected {expected}, got {sensors.get(name)}")
                ok = False
        mass = model.findtext(".//link[@name='base_link']/inertial/mass")
        if mass and float(mass) > 0:
            print(f"PASS base mass: {mass} kg")
        else:
            print("FAIL base mass must be positive")
            ok = False
        size = model.findtext(".//link[@name='base_link']/collision/geometry/box/size")
        if size:
            dims = [float(v) for v in size.split()]
            if len(dims) == 3 and all(v > 0 for v in dims):
                print(f"PASS body dimensions: {size} m")
            else:
                print("FAIL body dimensions must be three positive values")
                ok = False
        else:
            print("FAIL body collision geometry missing")
            ok = False
    if world is not None:
        names = {n.attrib.get("name") for n in world.findall("./world/model")}
        for name in ("floor", "north_wall", "south_wall", "east_wall", "west_wall", "test_obstacle"):
            if name in names:
                print(f"PASS indoor world element: {name}")
            else:
                print(f"FAIL indoor world missing: {name}")
                ok = False
    print("STRUCTURAL CHECKS PASSED" if ok else "STRUCTURAL CHECKS FAILED")
    return 0 if ok else 1

if __name__ == "__main__":
    sys.exit(main())
