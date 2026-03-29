#!/usr/bin/env bash
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/log"
CC_LOG="$LOG_DIR/log_control_center.txt"
BIN_LOGS=(
  "$LOG_DIR/log_smart_bin1.txt"
  "$LOG_DIR/log_smart_bin2.txt"
  "$LOG_DIR/log_smart_bin3.txt"
)

INTERVAL="${1:-30}"
MODE="${2:-live}"

if ! [[ "$INTERVAL" =~ ^[0-9]+$ ]] || [[ "$INTERVAL" -lt 1 ]]; then
  INTERVAL=30
fi

count_in_file() {
  local pattern="$1"
  local file="$2"
  local out
  if [[ -f "$file" ]]; then
    out="$(grep -c "$pattern" "$file" 2>/dev/null || true)"
    out="${out//$'\n'/}"
    if [[ -z "$out" ]]; then
      out=0
    fi
    echo "$out"
  else
    echo 0
  fi
}

pct() {
  local num="$1"
  local den="$2"
  awk -v n="$num" -v d="$den" 'BEGIN { if (d <= 0) { printf "0.0" } else { printf "%.1f", (n*100.0)/d } }'
}

snapshot() {
  local opened closed assignment_acked reset_sent duplicate_bin_full
  local truck_refused collection_failed dead_letter
  local reply_timeout assign_ack_timeout completion_timeout reset_ack_timeout
  local level_update_total bin_full_total bin_reset_total expected_full
  local lifecycle_pct tick_engine_pct

  opened=$(count_in_file "request_opened" "$CC_LOG")
  closed=$(count_in_file "request_closed" "$CC_LOG")
  assignment_acked=$(count_in_file "assignment_acked" "$CC_LOG")
  reset_sent=$(count_in_file "reset_sent" "$CC_LOG")
  duplicate_bin_full=$(count_in_file "duplicate_bin_full" "$CC_LOG")
  truck_refused=$(count_in_file "truck_refused" "$CC_LOG")
  collection_failed=$(count_in_file "collection_failed" "$CC_LOG")
  dead_letter=$(count_in_file "dead_letter" "$CC_LOG")
  reply_timeout=$(count_in_file "reply_timeout" "$CC_LOG")
  assign_ack_timeout=$(count_in_file "assign_ack_timeout" "$CC_LOG")
  completion_timeout=$(count_in_file "completion_timeout" "$CC_LOG")
  reset_ack_timeout=$(count_in_file "reset_ack_timeout" "$CC_LOG")

  level_update_total=0
  bin_full_total=0
  bin_reset_total=0

  for f in "${BIN_LOGS[@]}"; do
    level_update_total=$((level_update_total + $(count_in_file "level_update" "$f")))
    bin_full_total=$((bin_full_total + $(count_in_file "bin_full" "$f")))
    bin_reset_total=$((bin_reset_total + $(count_in_file "bin_reset" "$f")))
  done

  expected_full=$((level_update_total / 5))
  lifecycle_pct=$(pct "$closed" "$opened")
  tick_engine_pct=$(pct "$bin_full_total" "$expected_full")

  if awk -v p="$tick_engine_pct" 'BEGIN { exit !(p > 100.0) }'; then
    tick_engine_pct="100.0"
  fi

  echo "===================================================="
  echo " SmartCity MAS Ticking Dashboard"
  echo " Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
  echo "===================================================="
  echo "Lifecycle counters"
  echo "  opened=$opened closed=$closed assignment_acked=$assignment_acked reset_sent=$reset_sent"
  echo "  duplicate_bin_full=$duplicate_bin_full truck_refused=$truck_refused collection_failed=$collection_failed dead_letter=$dead_letter"
  echo "  timeouts reply=$reply_timeout assign_ack=$assign_ack_timeout completion=$completion_timeout reset_ack=$reset_ack_timeout"
  echo
  echo "Tick counters"
  echo "  level_update_total=$level_update_total bin_full_total=$bin_full_total bin_reset_total=$bin_reset_total expected_full_from_ticks=$expected_full"
  echo
  echo "Percentages"
  echo "  lifecycle_ticking_percentage=$lifecycle_pct%"
  echo "  tick_engine_percentage=$tick_engine_pct%"
  echo
  echo "Interpretation"
  echo "  lifecycle_ticking_percentage = closed/opened"
  echo "  tick_engine_percentage = bin_full_total/floor(level_update_total/5)"
}

if [[ "$MODE" == "once" ]]; then
  snapshot
  exit 0
fi

while true; do
  clear
  snapshot
  sleep "$INTERVAL"
done
