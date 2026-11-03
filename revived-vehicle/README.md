# Revived Vehicle for Omarchy

A minimal, read-only vehicle dashboard for cars, motorcycles, scooters, and
e-bikes. The bar shows current speed; clicking it opens a glanceable panel with
speed, power, RPM, voltage, temperature, connection state, and warnings.

The current UI prototype uses simulated telemetry by default. It includes
profiles for a US-market 1996 Honda Civic and a 1996 Volkswagen Golf Mk3, with
mock transport and diagnostic behavior appropriate to each generation. It also accepts a JSON
file written by an external OBD-II, CAN bus, Bluetooth, or serial bridge. The
plugin never sends commands to a vehicle.

The detail panel is divided into the driver dashboard, vehicle profile,
vehicle network, OBD overview, and a small debug trace. “Vehicle Network” is
intentionally broader than “CAN”: both starter profiles predate diagnostic CAN
and are modeled as K-line vehicles.

## Install

```bash
omarchy plugin add https://github.com/OWNER/REPOSITORY --enable
omarchy bar move myomarchy.revived-vehicle --section right
```

Replace the example URL after publishing this repository.

## Connect telemetry

Choose a mock profile with `vehicleProfile`:

- `honda-civic-1996-us` — generic OBD-II over simulated ISO 9141-2
- `vw-golf-mk3-1996` — simulated VW K-line/KWP-1281 measuring blocks

These are starting assumptions, not universal claims. Region, engine, ECU, and
transmission must be identified before connecting real hardware.

For external data, set `dataSource` to `file` and `telemetryFile` to the
absolute path of a JSON file. The bridge should atomically replace that file
with one JSON object. See `examples/telemetry.json` for the complete v2 shape.
The high-level portion remains straightforward:

```json
{
  "schemaVersion": 2,
  "timestamp": 0,
  "vehicle": "My vehicle",
  "connection": "file",
  "mock": false,
  "readOnly": true,
  "speedKph": 42,
  "powerPercent": 36,
  "rpm": 2450,
  "voltage": 13.9,
  "temperatureC": 71,
  "warning": "none"
}
```

`speedKph` is canonical regardless of display units. `warning` should be
`none` or a short driver-facing message. The nested `profile`, `transport`,
`obd`, and `signals` objects are documented in
[`docs/telemetry-contract.md`](docs/telemetry-contract.md).

## Development

Exercise the adapter directly:

```bash
./adapters/telemetry.sh --source simulation --profile honda-civic-1996-us
./adapters/telemetry.sh --source simulation --profile vw-golf-mk3-1996
./adapters/telemetry.sh --source file --file examples/telemetry.json
```

Validate the plugin from this directory with:

```bash
omarchy plugin validate .
```

The intended next adapter is a separate, least-privilege bridge using K-line,
SocketCAN, or an OBD-II library. Keep vehicle I/O outside QML, preserve this
JSON contract, discover capabilities at runtime, and remain read-only by
default.
