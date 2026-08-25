# Telemetry contract v2

The dashboard reads one JSON object per refresh. File-based bridges should
write a temporary file and atomically rename it over the configured telemetry
file so the UI never observes a partial object.

## Top-level fields

| Field | Type | Meaning |
| --- | --- | --- |
| `schemaVersion` | integer | Contract version; currently `2` |
| `timestamp` | integer | Unix timestamp of the sample |
| `vehicle` | string | Driver-facing vehicle name |
| `connection` | string | Adapter source such as `file` or `simulation` |
| `mock` | boolean | Whether values are synthetic |
| `readOnly` | boolean | Whether the entire data path forbids vehicle writes |
| `speedKph` | number | Canonical vehicle speed |
| `powerPercent` | number | Normalized engine/motor output estimate |
| `rpm` | number | Engine or motor revolutions per minute |
| `voltage` | number | Reported system voltage |
| `temperatureC` | number | Primary coolant or motor temperature |
| `warning` | string | `none` or a short driver-facing warning |

## `profile`

Contains `id`, `name`, `generation`, `region`, `engine`, `transmission`, and
`connector`. Unknown identity fields must say `unknown` or `unspecified`; a
bridge must not infer a specific engine or ECU from model year alone.

## `transport`

Describes the actual vehicle network or diagnostic link:

- `kind`: `can`, `k-line`, `serial`, `bluetooth`, or another explicit type
- `protocol`, `interface`, and `state`
- `readOnly`
- `bitrateKbps` and `busLoadPercent`, or `null` when not meaningful
- `rxRate`, `rxTotal`, `uniqueIds`, `errorFrames`, and `droppedFrames`
- `lastFrame`: a short, display-safe debug representation

CAN-specific statistics must not be fabricated for K-line transports. Linux
SocketCAN adapters can populate error-frame, traffic, bitrate, and bus-load
fields; slower request/response transports will commonly leave bus load null.

## `obd`

Contains `available`, `mode`, `ecu`, `supportedItems`, `latencyMs`, `mil`,
`dtcCount`, `readiness`, `ignition`, `vin`, and `debug`.

`debug` is a short array of sanitized protocol events. Do not include secrets,
full VINs, or an unbounded frame history. Trouble-code clearing, actuator tests,
coding, and other writes are outside the v2 contract.

## `signals`

The prototype displays short-term fuel trim, intake temperature, throttle,
manifold pressure, and fuel level. A real bridge should advertise and emit only
signals actually supported by the connected ECU. Missing data should eventually
be represented as unavailable rather than a synthetic zero.

See [`../examples/telemetry.json`](../examples/telemetry.json) for a complete
sample.
