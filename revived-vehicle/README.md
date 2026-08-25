# Revived Vehicle for Omarchy

A minimal, read-only vehicle dashboard for cars, motorcycles, scooters, and
e-bikes. The bar shows current speed; clicking it opens a glanceable panel with
speed, power, RPM, voltage, temperature, connection state, and warnings.

The first release uses simulated telemetry by default. It also accepts a JSON
file written by an external OBD-II, CAN bus, Bluetooth, or serial bridge. The
plugin never sends commands to a vehicle.

## Install

```bash
omarchy plugin add https://github.com/OWNER/REPOSITORY --enable
omarchy bar move myomarchy.revived-vehicle --section right
```

Replace the example URL after publishing this repository.

## Connect telemetry

Set `dataSource` to `file` and `telemetryFile` to the absolute path of a JSON
file. The bridge should atomically replace that file with one JSON object:

```json
{
  "schemaVersion": 1,
  "timestamp": 0,
  "vehicle": "My vehicle",
  "connection": "obd2",
  "speedKph": 42,
  "powerPercent": 36,
  "rpm": 2450,
  "voltage": 13.9,
  "temperatureC": 71,
  "warning": "none"
}
```

`speedKph` is the canonical speed regardless of display units. Missing numeric
fields render as zero. `warning` should be `none` or a short driver-facing
message. See `examples/telemetry.json` for a ready-to-use sample.

## Development

Exercise the adapter directly:

```bash
./adapters/telemetry.sh --source simulation
./adapters/telemetry.sh --source file --file examples/telemetry.json
```

Validate the plugin from this directory with:

```bash
omarchy plugin validate .
```

The intended next adapter is a separate, least-privilege bridge using
SocketCAN or an OBD-II library. Keep vehicle I/O outside QML and preserve this
JSON contract.
