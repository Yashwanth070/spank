<p align="center">
  <img src="doc/logo.png" alt="spank logo" width="200">
</p>

# spank

Slap your MacBook, it yells back.


**Exclusive for macOS:** `spank` uses securely isolated AVFoundation microphone hooks to listen for the structural "thud" that travels through the metal chassis when you slap your laptop. Single binary, no dependencies, no `sudo` required.

## Requirements

- macOS (Intel or Apple Silicon)
- A built-in microphone attached to the chassis
- Go 1.26+ and Swift (`swiftc`) to build from source

## How it works

Since modern macOS versions explicitly block root-level Terminal access to raw IMU sensors and accelerometers, `spank` executes a lightweight native Swift script (`mic_sensor`) in the background. 

1. Reads raw volume buffers directly from the macOS audio engine.
2. Isolates instantaneous structural volume spikes ("thuds") from ambient noise.
3. When a significant impact is detected, it plays a randomized or escalating audio response.

## Install

Download or clone the repository, and build the binaries:

```bash
# Build the native MacOS microphone bridge
swiftc mic_sensor.swift -o mic_sensor

# Build the Go application
go build -o spank .
```

## Usage

*Note: The first time you run this, macOS will ask for permission for your Terminal to access the Microphone.*

```bash
# Normal mode — says "ow!" when slapped
./spank

# Sexy mode — escalating responses based on slap frequency
./spank --sexy

# Halo mode — plays Halo death sounds when slapped
./spank --halo

# Custom mode — plays your own MP3 files from a directory
./spank --custom /path/to/mp3s

# Adjust sensitivity with amplitude threshold (lower = more sensitive)
./spank --min-amplitude 0.1   # extremely sensitive (hears typing)
./spank --min-amplitude 0.25  # default balanced sensitivity
./spank --sexy --min-amplitude 0.4 # requires a very hard slap

# Set cooldown period in millisecond (default: 750)
./spank --cooldown 600
```

### Modes

**Pain mode** (default): Randomly plays from 10 pain/protest audio clips when a slap is detected.

**Sexy mode** (`--sexy`): Tracks slaps within a rolling 5-minute window. The more you slap, the more intense the audio response. 60 levels of escalation.

**Halo mode** (`--halo`): Randomly plays from death sound effects from the Halo video game series when a slap is detected.

## License

MIT
