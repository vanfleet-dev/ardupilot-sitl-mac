# ArduPilot SITL Usage Guide

Headless Docker-based SITL environment for testing MAVProxy changes on macOS.

## Quick Start

```bash
# Start SITL
sitl plane

# In another terminal, connect with your MAVProxy
mavproxy.py --master=localhost:14550

# When done
sitl stop
```

## Available Commands

### Vehicle Commands

| Command | Description |
|---------|-------------|
| `sitl plane` | Start ArduPlane (default plane frame) |
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
| `--wipe` | Wipe parameters (fresh start) | `sitl plane --wipe` |
| `--location <name>` | Start at named location | `sitl copter --location CMAC` |
| `--speedup <n>` | Simulation speed multiplier | `sitl plane --speedup 10` |

## Common Workflows

### Basic Testing

```bash
# 1. Start SITL
sitl plane

# 2. Connect with your local MAVProxy
mavproxy.py --master=localhost:14550

# 3. Test your MAVProxy changes
# ... do your testing ...

# 4. Stop SITL
sitl stop
```

### Testing Multiple Vehicle Types

```bash
# Test plane
sitl plane
mavproxy.py --master=localhost:14550
sitl stop

# Test copter
sitl copter
mavproxy.py --master=localhost:14550
sitl stop

# Test quadplane
sitl quadplane
mavproxy.py --master=localhost:14550
sitl stop
```

### Fresh Start with Wiped Parameters

```bash
sitl plane --wipe
```

### Test at Specific Location

```bash
sitl copter --location CMAC
```

Available locations are defined in the SITL locations.txt file. Common ones include:
- `CMAC` - Canberra Model Aircraft Club, Australia
- `Ballarat` - Ballarat, Australia
- `OBC` - Outback Challenge location

## MAVProxy Connection Details

- **Protocol**: UDP
- **Host**: `localhost` or `127.0.0.1`
- **Port**: `14550`
- **Alternative TCP Port**: `5760`

Example connection commands:

```bash
# Standard connection
mavproxy.py --master=localhost:14550

# With console and map (if you have XQuartz)
mavproxy.py --master=localhost:14550 --console --map

# Connection with specific system ID
mavproxy.py --master=localhost:14550 --target-system=1
```

## File Locations

```
~/sitl/
├── docker-compose.yml    # Docker configuration
├── .env                  # Environment variables
├── logs/                 # SITL logs directory
├── eeprom.bin           # SITL parameter storage
└── sitl                 # CLI script (copied to ~/bin)
```

## Troubleshooting

### SITL won't start

```bash
# Check Docker is running
docker info

# Check if container already exists
sitl status

# Force stop and restart
sitl stop
sitl plane
```

### Can't connect with MAVProxy

1. Verify SITL is running:
   ```bash
   sitl status
   ```

2. Check logs for errors:
   ```bash
   sitl logs
   ```

3. Verify port is listening:
   ```bash
   lsof -i :14550
   ```

### Container issues

```bash
# Open shell to debug
sitl shell

# Check running processes inside container
ps aux

# Check SITL binary location
ls -la /ardupilot/build/sitl/bin/
```

### Permission errors

The script should work without sudo. If you get permission errors:

```bash
# Fix ownership
sudo chown -R $(whoami) ~/sitl

# Ensure script is executable
chmod +x ~/bin/sitl
```

## Advanced Usage

### Custom Frame Types

```bash
# List available frames (inside container)
sitl shell
sim_vehicle.py --help | grep -A 50 "Frame Type"

# Use custom frame
sitl plane --frame plane-jet
sitl copter --frame dodeca-hexa
```

### Multiple MAVProxy Outputs

If you need to connect multiple GCS applications, configure MAVProxy to output to additional ports:

```bash
mavproxy.py --master=localhost:14550 --out udp:127.0.0.1:14551
```

Then connect your second GCS to port 14551.

### Accessing Logs

SITL logs are stored in `~/sitl/logs/` and include:
- `.bin` files - Flight data logs
- `.tlog` files - MAVLink telemetry logs (if enabled)

## Development Notes

### Docker Image

- **Image**: `orthuk/ardupilot-sitl-debian:latest`
- **Base**: Debian 12 (Bookworm)
- **ArduPilot Version**: Latest stable
- **Python**: 3.13

### Port Mapping

- Container UDP 14550 → Host UDP 14550
- Container TCP 5760 → Host TCP 5760 (optional)

### Container Lifecycle

1. `sitl plane` creates and starts container
2. Container runs SITL with `--no-mavproxy`
3. SITL outputs MAVLink on UDP port 14550
4. Your local MAVProxy connects to localhost:14550
5. `sitl stop` stops and removes container

## References

- [ArduPilot SITL Documentation](https://ardupilot.org/dev/docs/sitl-simulator-software-in-the-loop.html)
- [MAVProxy Documentation](https://ardupilot.org/mavproxy/index.html)
- [Docker SITL Repository](https://github.com/ben-xD/ardupilot-sitl-docker)
- [SITL Tutorial](https://ardupilot.org/dev/docs/copter-sitl-mavproxy-tutorial.html)

## Support

For issues with:
- **SITL/ArduPilot**: [ArduPilot Discord](https://ardupilot.org/discord) or [Discuss Forum](https://discuss.ardupilot.org/)
- **Docker Image**: [GitHub Issues](https://github.com/ben-xD/ardupilot-sitl-docker/issues)
- **This Setup**: Check the runbook in your home directory
