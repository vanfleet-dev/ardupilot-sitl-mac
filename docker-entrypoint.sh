#!/bin/bash

# Docker entrypoint script for SITL
# Handles both single vehicle and swarm modes

set -e

# Default values
SITL_VEHICLE=${SITL_VEHICLE:-ArduPlane}
SITL_FRAME=${SITL_FRAME:-plane}
SWARM_MODE=${SWARM_MODE:-false}
SITL_LOCATION=${SITL_LOCATION:-CMAC}
OFFSET_LINE=${OFFSET_LINE:-90,10}

echo "========================================="
echo "ArduPilot SITL Docker Container"
echo "========================================="
echo "Vehicle: $SITL_VEHICLE"
echo "Frame: $SITL_FRAME"
echo "Mode: $([ "$SWARM_MODE" = "true" ] && echo "Swarm ($SWARM_COUNT vehicles)" || echo "Single Vehicle")"
echo "========================================="

cd /home/docker/ardupilot

if [ "$SWARM_MODE" = "true" ] && [ -n "$SWARM_COUNT" ]; then
    echo ""
    echo "Starting SITL Swarm..."
    echo "Count: $SWARM_COUNT"
    echo "Location: $SITL_LOCATION"
    echo "Offset: $OFFSET_LINE"
    echo ""
    echo "MAVLink Ports (TCP):"
    for i in $(seq 0 $((SWARM_COUNT - 1))); do
        port=$((5760 + i))
        sysid=$((i + 1))
        echo "  Vehicle $sysid: localhost:$port (TCP)"
    done
    echo ""
    
    # In swarm mode without mavproxy, each instance listens on TCP port 5760+i
    # We use --auto-sysid to assign SYS IDs automatically
    exec ./Tools/autotest/sim_vehicle.py \
        -v "$SITL_VEHICLE" \
        -f "$SITL_FRAME" \
        --no-mavproxy \
        --count "$SWARM_COUNT" \
        --auto-sysid \
        --location "$SITL_LOCATION" \
        --auto-offset-line "$OFFSET_LINE"
else
    echo ""
    echo "Starting Single Vehicle SITL..."
    echo "MAVLink: localhost:14550 (UDP)"
    echo ""
    
    exec ./Tools/autotest/sim_vehicle.py \
        -v "$SITL_VEHICLE" \
        -f "$SITL_FRAME" \
        --no-mavproxy \
        --out udp:0.0.0.0:14550
fi
