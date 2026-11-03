#!/usr/bin/env bash
set -u

source_name="simulation"
telemetry_file=""
vehicle_profile="honda-civic-1996-us"

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
    --profile)
      vehicle_profile="${2:-}"
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
rx_total=$((18420 + tick % 10000))
latency=$((42 + tick % 17))
throttle=$((12 + phase))
map_kpa=$((28 + phase * 2))

case "$vehicle_profile" in
  honda-civic-1996-us)
    profile='{"id":"honda-civic-1996-us","name":"1996 Honda Civic","generation":"6th gen","region":"US","engine":"unspecified","transmission":"unspecified","connector":"SAE J1962 16-pin"}'
    transport='{"kind":"k-line","protocol":"ISO 9141-2 (mock)","interface":"mock-kline0","state":"connected","readOnly":true,"bitrateKbps":10.4,"rxRate":12,"rxTotal":'"$rx_total"',"uniqueIds":1,"errorFrames":0,"droppedFrames":0,"busLoadPercent":null,"lastFrame":"48 6B 10 41 0C 1A F8"}'
    obd='{"available":true,"mode":"Generic OBD-II","ecu":"Powertrain / 0x10","supportedItems":13,"latencyMs":'"$latency"',"mil":false,"dtcCount":0,"readiness":"7/8 ready","ignition":"engine running","vin":"not requested","debug":["01 00 → supported PID bitmap","01 0C → engine RPM","01 0D → vehicle speed"]}'
    vehicle_name="1996 Honda Civic"
    ;;
  vw-golf-mk3-1996)
    profile='{"id":"vw-golf-mk3-1996","name":"1996 Volkswagen Golf Mk3","generation":"1H","region":"selectable","engine":"unspecified","transmission":"unspecified","connector":"16-pin or market-specific"}'
    transport='{"kind":"k-line","protocol":"KWP-1281 (mock)","interface":"mock-kline0","state":"connected","readOnly":true,"bitrateKbps":10.4,"rxRate":9,"rxTotal":'"$rx_total"',"uniqueIds":2,"errorFrames":0,"droppedFrames":0,"busLoadPercent":null,"lastFrame":"01 03 00 1A F8 45 00"}'
    obd='{"available":true,"mode":"VW measuring blocks","ecu":"01 Engine (mock)","supportedItems":11,"latencyMs":'"$((latency + 24))"',"mil":false,"dtcCount":0,"readiness":"market dependent","ignition":"engine running","vin":"not requested","debug":["KWP-1281 wakeup complete","Controller 01 identified","Measuring block 001 sampled"]}'
    vehicle_name="1996 Volkswagen Golf Mk3"
    ;;
  *)
    printf '{"error":"unknown vehicle profile"}\n'
    exit 1
    ;;
esac

printf '{"schemaVersion":2,"timestamp":%s,"vehicle":"%s","connection":"simulated","mock":true,"readOnly":true,"profile":%s,"transport":%s,"obd":%s,"signals":{"shortFuelTrimPercent":1.6,"intakeTemperatureC":29,"throttlePercent":%s,"mapKpa":%s,"fuelLevelPercent":62},"speedKph":%s,"powerPercent":%s,"rpm":%s,"voltage":13.8,"temperatureC":%s,"warning":"none"}\n' \
  "$tick" "$vehicle_name" "$profile" "$transport" "$obd" "$throttle" "$map_kpa" "$speed" "$power" "$rpm" "$temperature"
