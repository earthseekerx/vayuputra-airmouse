#!/usr/bin/env bash
# Portable Docker wrapper for the Vayuputra PX4 SITL baseline.
# Run with: bash simulation/gazebo/vayuputra-sim.sh <command>
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
CONTAINER_NAME="${VAYUPUTRA_CONTAINER_NAME:-vayuputra-px4-bridge}"
IMAGE="${VAYUPUTRA_IMAGE:-px4io/px4-sitl-gazebo-ros2@sha256:f16b9968853ecf37a93301c54fbaaa7363b4d0c50fd7c8a4d8077a8c93f683b1}"
ROS_DOMAIN_ID="${ROS_DOMAIN_ID:-83}"

usage() {
  cat <<'EOF'
Vayuputra SITL helper
Commands: check | up | resume | status | logs | shell | ros-check | stop | remove | help
Set VAYUPUTRA_IMAGE or VAYUPUTRA_CONTAINER_NAME to override defaults.
EOF
}
need_docker() {
  command -v docker >/dev/null 2>&1 || { echo 'ERROR: Docker CLI is required.' >&2; exit 2; }
  docker info >/dev/null 2>&1 || { echo 'ERROR: Docker daemon unavailable or permission denied.' >&2; exit 2; }
}
check() {
  need_docker
  docker --version
  if docker image inspect "$IMAGE" >/dev/null 2>&1; then echo 'Pinned image is present.'; else echo 'Pinned image will be pulled on up.'; fi
  [[ -d "$REPO_ROOT/simulation/gazebo" ]] || { echo 'Missing simulation/gazebo directory.' >&2; exit 2; }
  echo "Project root: $REPO_ROOT"
}
up() {
  need_docker
  if docker container inspect "$CONTAINER_NAME" >/dev/null 2>&1; then
    state="$(docker inspect -f '{{.State.Status}}' "$CONTAINER_NAME")"
    if [[ "$state" == running ]]; then echo "Already running: $CONTAINER_NAME"; return; fi
    echo "Container already exists (state: $state). Use resume or stop; it will not be replaced." >&2; exit 3
  fi
  docker run -d --name "$CONTAINER_NAME" --network bridge -e HEADLESS=1 -e ROS_DOMAIN_ID="$ROS_DOMAIN_ID" -p 8888:8888/udp -p 14540:14540/udp -p 14550:14550/udp "$IMAGE" /usr/local/bin/ros2-entrypoint.sh /bin/bash -lc 'MicroXRCEAgent udp4 -p 8888 & exec px4-gazebo'
  echo "Started $CONTAINER_NAME. Inspect with: bash simulation/gazebo/vayuputra-sim.sh status"
}
resume() {
  need_docker
  docker container inspect "$CONTAINER_NAME" >/dev/null 2>&1 || { echo "No container $CONTAINER_NAME; run up first." >&2; exit 3; }
  docker start "$CONTAINER_NAME"
}
status() {
  need_docker
  docker ps -a --filter "name=^/${CONTAINER_NAME}$"
  docker top "$CONTAINER_NAME" 2>/dev/null || true
}
ros_check() {
  need_docker
  docker exec -e ROS_DOMAIN_ID="$ROS_DOMAIN_ID" "$CONTAINER_NAME" /bin/bash -lc 'source /usr/local/lib/px4/network.sh; source /opt/ros/jazzy/setup.bash; source /opt/px4_ros2/install/local_setup.bash; export RMW_IMPLEMENTATION=rmw_fastrtps_cpp; ros2 topic list; for t in /fmu/out/sensor_combined /fmu/out/vehicle_status_v4 /fmu/out/vehicle_local_position_v1; do ros2 topic list | grep -Fxq "$t" && echo "DISCOVERED $t" || echo "MISSING $t"; done'
}
remove_container() {
  need_docker
  docker container inspect "$CONTAINER_NAME" >/dev/null 2>&1 || { echo 'Container does not exist.'; return; }
  printf "Remove container %s only? Type REMOVE to confirm: " "$CONTAINER_NAME"
  read -r answer
  [[ "$answer" == REMOVE ]] || { echo Cancelled.; return; }
  docker rm -f "$CONTAINER_NAME"
}
case "${1:-help}" in
  check) check ;;
  up) up ;;
  resume) resume ;;
  status) need_docker; status ;;
  logs) need_docker; docker logs -f "$CONTAINER_NAME" ;;
  shell) need_docker; docker exec -it "$CONTAINER_NAME" /bin/bash ;;
  ros-check) ros_check ;;
  stop) need_docker; docker stop "$CONTAINER_NAME" ;;
  remove) remove_container ;;
  help|-h|--help) usage ;;
  *) usage >&2; exit 2 ;;
esac
