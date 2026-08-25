#!/usr/bin/env bash

set -u

# Keep collection dependency-free so revived hardware bears minimal overhead.

read -r _ cpu_user cpu_nice cpu_system cpu_idle cpu_iowait cpu_irq cpu_softirq cpu_steal _ < /proc/stat
cpu_idle_first=$((cpu_idle + cpu_iowait))
cpu_total_first=$((cpu_user + cpu_nice + cpu_system + cpu_idle + cpu_iowait + cpu_irq + cpu_softirq + cpu_steal))

sleep 0.15

read -r _ cpu_user cpu_nice cpu_system cpu_idle cpu_iowait cpu_irq cpu_softirq cpu_steal _ < /proc/stat
cpu_idle_second=$((cpu_idle + cpu_iowait))
cpu_total_second=$((cpu_user + cpu_nice + cpu_system + cpu_idle + cpu_iowait + cpu_irq + cpu_softirq + cpu_steal))
cpu_delta=$((cpu_total_second - cpu_total_first))
idle_delta=$((cpu_idle_second - cpu_idle_first))
if ((cpu_delta > 0)); then
  cpu_percent=$(((100 * (cpu_delta - idle_delta) + cpu_delta / 2) / cpu_delta))
else
  cpu_percent=0
fi

temperature="null"
best_temperature=0
fan_rpm=0
for hwmon_dir in /sys/class/hwmon/hwmon*; do
  [[ -d "$hwmon_dir" ]] || continue
  for input in "$hwmon_dir"/temp*_input; do
    [[ -r "$input" ]] || continue
    read -r raw_temperature < "$input" || continue
    [[ "$raw_temperature" =~ ^[0-9]+$ ]] || continue
    ((raw_temperature > best_temperature && raw_temperature < 150000)) && best_temperature=$raw_temperature
  done
  for input in "$hwmon_dir"/fan*_input; do
    [[ -r "$input" ]] || continue
    read -r raw_fan < "$input" || continue
    [[ "$raw_fan" =~ ^[0-9]+$ ]] || continue
    ((raw_fan > fan_rpm)) && fan_rpm=$raw_fan
  done
done
if ((best_temperature > 0)); then
  temperature=$(awk -v value="$best_temperature" 'BEGIN { printf "%.1f", value / 1000 }')
fi

memory_total=0
memory_available=0
swap_total=0
swap_free=0
while read -r key value _; do
  case "$key" in
    MemTotal:) memory_total=$value ;;
    MemAvailable:) memory_available=$value ;;
    SwapTotal:) swap_total=$value ;;
    SwapFree:) swap_free=$value ;;
  esac
done < /proc/meminfo

memory_percent=0
swap_percent=0
((memory_total > 0)) && memory_percent=$(((100 * (memory_total - memory_available) + memory_total / 2) / memory_total))
((swap_total > 0)) && swap_percent=$(((100 * (swap_total - swap_free) + swap_total / 2) / swap_total))
read -r load_average _ < /proc/loadavg

printf '{"cpuPercent":%d,"temperatureC":%s,"fanRpm":%d,"memoryPercent":%d,"swapPercent":%d,"loadAverage":"%s"}\n' \
  "$cpu_percent" "$temperature" "$fan_rpm" "$memory_percent" "$swap_percent" "$load_average"
