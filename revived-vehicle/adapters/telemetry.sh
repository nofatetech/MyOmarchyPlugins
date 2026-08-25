#!/usr/bin/env bash
set -u

source_name="simulation"
telemetry_file=""

while (( $# > 0 )); do
  case "$1" in
    --source)
      source_name="${2:-}"
      shift 2
      ;;
    --file)
      telemetry_file="${2:-}"
      shift 2
      ;;
    *)
      printf '{"error":"unknown adapter argument"}\n'
      exit 2
      ;;
  esac
done

if [[ "$source_name" == "file" ]]; then
  if [[ -z "$telemetry_file" ]]; then
    printf '{"error":"telemetry file is not configured"}\n'
    exit 1
  fi
  if [[ ! -r "$telemetry_file" ]]; then
    printf '{"error":"telemetry file is not readable"}\n'
    exit 1
  fi
  exec head -n 1 -- "$telemetry_file"
fi

if [[ "$source_name" != "simulation" ]]; then
  printf '{"error":"unsupported data source"}\n'
  exit 1
fi

tick=$(date +%s)
phase=$((tick % 60))
if (( phase > 30 )); then
  phase=$((60 - phase))
fi

speed=$((phase * 3))
power=$((18 + phase * 2))
rpm=$((800 + phase * 135))
temperature=$((34 + phase / 2))

printf '{"schemaVersion":1,"timestamp":%s,"vehicle":"Demo vehicle","connection":"simulated","speedKph":%s,"powerPercent":%s,"rpm":%s,"voltage":13.8,"temperatureC":%s,"warning":"none"}\n' \
  "$tick" "$speed" "$power" "$rpm" "$temperature"
