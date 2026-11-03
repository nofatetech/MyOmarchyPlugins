# Revived Laptop Status for Omarchy

A small Omarchy Shell bar widget aimed at older laptops. It keeps CPU load and
temperature visible, shows fan speed when Linux exposes it, and puts memory,
swap, and load-average detail in a tooltip.

The collector reads `/proc` and `/sys/class/hwmon` directly. It needs no extra
packages and runs once every three seconds by default.

## Install

```bash
omarchy plugin add https://github.com/nofatetech/revived-laptop-status --enable
omarchy bar move myomarchy.revived-laptop-status --section right
```

Click the widget to open `btop`; hover it for the full reading.

## Settings

- `refreshIntervalSec`: polling interval, from 2 to 60 seconds
- `showFan`: include RPM in the bar when a fan sensor exists
- `showMemory`: include RAM usage in the bar (off by default)
- `minimumTemperatureC`: cool end of the dashboard gauge (35°C by default)
- `maximumTemperatureC`: hot end of the dashboard gauge (100°C by default)
- `temperatureWarningC`: switch to the urgent theme color at this temperature

Fan RPM is hardware-dependent. Many laptops control the fan through firmware
without exposing a readable Linux hwmon sensor; in that case the widget simply
omits RPM.

## Development

Validate the checkout with:

```bash
omarchy plugin validate .
```
