# ArduPilot SITL for macOS

[![Docker](https://img.shields.io/badge/docker-required-blue.svg)](https://docker.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Simple CLI wrapper for running ArduPilot SITL (Software In The Loop) on macOS using Docker.

Perfect for MAVProxy development and testing without physical hardware.

## Features

- **Headless**: No GUI dependencies or X11 setup required
- **Simple CLI**: Just type `sitl plane` or `sitl copter`
- **Multiple Vehicles**: Support for Plane, Copter, QuadPlane, Rover, and more
- **MAVProxy Ready**: Connect your local MAVProxy installation via localhost:14550
- **Cross-Platform**: Works on both Intel and Apple Silicon Macs
- **Isolated**: Docker container keeps your system clean

## Prerequisites

**One-time setup required:**

1. **Docker Desktop** - [Download and install](https://www.docker.com/products/docker-desktop/)
   - Start Docker Desktop after installation
   - No additional Docker configuration needed

2. **Git** - Usually pre-installed on macOS, or install via [Homebrew](https://brew.sh)

## Quick Start

```bash
# Clone the repository
git clone https://github.com/vanfleet-dev/ardupilot-sitl-mac.git
cd ardupilot-sitl-mac

# Run the install script
./install.sh

# Start SITL
sitl plane

# In another terminal, connect with your MAVProxy
mavproxy.py --master=localhost:14550
```

## Installation

The `install.sh` script will:
- Check that Docker is installed and running
- Create `~/bin` directory if it doesn't exist
- Install the `sitl` command to your PATH
- Set executable permissions

**Manual Installation:**

If you prefer manual setup:

```bash
# Ensure ~/bin exists and is in PATH
mkdir -p ~/bin

# Copy the script
cp sitl ~/bin/sitl
chmod +x ~/bin/sitl

# Pull the Docker image
docker pull orthuk/ardupilot-sitl-debian:latest
```

## Commands

### Vehicle Commands

| Command | Description |
|---------|-------------|
| `sitl plane` | Start ArduPlane (default frame) |
| `sitl quadplane` | Start ArduPlane with quadplane frame |
| `sitl copter` | Start ArduCopter (quad frame) |
| `sitl copter-hexa` | Start hexacopter |
| `sitl copter-octa` | Start octocopter |
| `sitl copter-tri` | Start tricopter |
| `sitl copter-heli` | Start helicopter |
| `sitl rover` | Start Rover |
| `sitl rover-skid` | Start Rover with skid steering |

### Management Commands

| Command | Description |
|---------|-------------|
| `sitl stop` | Stop the SITL container |
| `sitl status` | Check if SITL is running |
| `sitl shell` | Open bash shell in container |
| `sitl logs` | View SITL logs |
| `sitl --help` | Show help message |

### Options

| Option | Description | Example |
|--------|-------------|---------|
| `--frame <name>` | Override default frame | `sitl copter --frame hexa` |
| `--swarm <n>` | Launch n vehicles as a swarm | `sitl copter --swarm 5` |
| `--offset-line` | Spread swarm in a line | `sitl copter --swarm 5 --offset-line 90,10` |
| `--wipe` | Wipe parameters (fresh start) | `sitl plane --wipe` |
| `--location <name>` | Start at named location | `sitl copter --location CMAC` |
| `--speedup <n>` | Simulation speed multiplier | `sitl plane --speedup 10` |

## Usage Examples

### Basic Testing Workflow

```bash
# Terminal 1: Start SITL
sitl plane

# Terminal 2: Connect with MAVProxy
mavproxy.py --master=localhost:14550

# When done
sitl stop
```

### Testing Multiple Vehicles

```bash
# Test plane
sitl plane
# ... test ...
sitl stop

# Test copter
sitl copter
# ... test ...
sitl stop

# Test quadplane
sitl quadplane
# ... test ...
sitl stop
```

### Swarm Mode (Multi-Vehicle)

Launch multiple vehicles simultaneously with auto-assigned SYS IDs:

```bash
# Start 5 copters in a swarm
sitl copter --swarm 5

# Start 3 planes at CMAC location
sitl plane --swarm 3 --location CMAC

# Start 10 copters in a line (heading 90°, 10m spacing)
sitl copter --swarm 10 --offset-line 90,10

# Connect with MAVProxy (auto-detects all vehicles)
mavproxy.py --master=localhost:14550
```

**Swarm Features:**
- All vehicles are the same type (e.g., all copters or all planes)
- Auto-assigns unique SYS IDs (1, 2, 3, etc.)
- Vehicles spawn in a line formation to avoid collisions
- MAVProxy can control all vehicles simultaneously
- Use `vehicle <n>` in MAVProxy to switch between vehicles
- Use `alllinks <cmd>` to send commands to all vehicles

**Note:** Maximum recommended swarm size is 20 vehicles for performance.

### Fresh Start with Wiped Parameters

```bash
sitl plane --wipe
```

### Test at Specific Location

```bash
sitl copter --location CMAC
```

## MAVProxy Connection

SITL exposes MAVLink on UDP port 14550:

```bash
# Standard connection
mavproxy.py --master=localhost:14550

# With console and map (requires XQuartz if using GUI)
mavproxy.py --master=localhost:14550 --console --map
```

**Connection Details:**
- Protocol: UDP
- Host: localhost (127.0.0.1)
- Port: 14550

## Documentation

- **[Detailed Usage Guide](docs/USAGE.md)** - Comprehensive documentation
- **[Troubleshooting](docs/USAGE.md#troubleshooting)** - Common issues and solutions

## How It Works

```
┌─────────────────┐         ┌──────────────────┐
│   Your Mac      │         │  Docker Container │
│                 │  UDP    │                  │
│  mavproxy.py    │◄───────►│  ArduPilot SITL  │
│  (localhost)    │ :14550  │  (Debian-based)  │
│                 │         │                  │
└─────────────────┘         └──────────────────┘
```

1. `sitl plane` starts a Docker container with ArduPilot SITL
2. SITL runs in headless mode (no MAVProxy inside container)
3. SITL outputs MAVLink on UDP port 14550
4. Your local MAVProxy connects to localhost:14550
5. `sitl stop` removes the container

## Development

This project is designed for MAVProxy development:

- Run SITL in Docker (stable, isolated environment)
- Connect with your local, modified MAVProxy
- Test changes without affecting your system
- No need for physical flight controller

## Requirements

- macOS 10.14+ (Intel or Apple Silicon)
- Docker Desktop 4.0+
- ~4GB free disk space (for Docker image)

## File Structure

```
ardupilot-sitl-mac/
├── sitl                 # CLI script
├── docker-compose.yml   # Docker configuration
├── install.sh          # Installation script
├── docs/
│   └── USAGE.md        # Detailed documentation
├── LICENSE             # MIT License
└── README.md           # This file
```

## Troubleshooting

**SITL won't start:**
```bash
# Check Docker is running
docker info

# Check status
sitl status

# Force stop and restart
sitl stop
sitl plane
```

**Can't connect with MAVProxy:**
```bash
# Verify SITL is running
sitl status

# Check logs
sitl logs

# Verify port is listening
lsof -i :14550
```

See [docs/USAGE.md](docs/USAGE.md#troubleshooting) for more troubleshooting tips.

## Contributing

Contributions welcome! Please feel free to submit issues or pull requests.

## Acknowledgments

- Docker image: [orthuk/ardupilot-sitl-debian](https://hub.docker.com/r/orthuk/ardupilot-sitl-debian) by [ben-xD](https://github.com/ben-xD/ardupilot-sitl-docker)
- ArduPilot: [ardupilot.org](https://ardupilot.org)
- MAVProxy: [ardupilot.org/mavproxy](https://ardupilot.org/mavproxy)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
