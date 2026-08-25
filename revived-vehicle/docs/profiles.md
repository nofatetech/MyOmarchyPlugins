# Starter vehicle profiles

Profiles provide connection hints and UI context. They never override runtime
protocol or capability detection.

## 1996 Honda Civic — US

- Profile ID: `honda-civic-1996-us`
- Generation: sixth generation
- Expected connector: SAE J1962 16-pin DLC
- Mock transport: ISO 9141-2 over K-line
- Mock diagnostics: generic emissions-related OBD-II

The engine, transmission, ECU, and trim remain unspecified. Other markets can
differ and should receive separate profiles once verified.

## 1996 Volkswagen Golf Mk3

- Profile ID: `vw-golf-mk3-1996`
- Chassis family: 1H
- Mock transport: K-line
- Mock diagnostics: VW KWP-1281 measuring blocks
- Generic OBD-II: capability-detected, not assumed

Connector, emissions support, available controllers, and measuring blocks vary
by market, engine, and installed control modules. A real adapter should identify
the controller before selecting any decoder.

## Fields still needed from the owner

For a reliable real-hardware profile, record region/market, VIN with private
portions redacted, engine code, transmission, ECU/controller identification,
diagnostic connector type, and tested adapter hardware.
