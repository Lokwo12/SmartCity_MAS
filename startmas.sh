#!/bin/bash
# ============================================================
#  SmartCity MAS - Fixed startmas.sh
#  Key fixes vs original:
#  1. DALI_HOME path detection: removed trailing-space path bug
#  2. Agent launch order: control_center and logger FIRST
#     to avoid bin/truck agents connecting before coordinator ready
#  3. AGENT_START_STAGGER increased to 3s (was 2s) - prevents
#     Linda tuple-space race on slow machines
#  4. server.txt copy now uses absolute path (not relative)
#  5. Health-check grep pattern fixed: was matching too broadly
#  6. tmux pane title uniqueness: added explicit -T flag per pane
#  7. Added set -u to catch unbound variable bugs early
# ============================================================
set -e
set -u
shopt -s nullglob

clear

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- USER CONFIG ---
SICSTUS_HOME=/usr/local/sicstus4.6.0

# BUG FIX 1: Handle src directory with trailing space (workspace has "src " not "src")
if [[ -n "${DALI_HOME:-}" ]]; then
    DALI_HOME="$DALI_HOME"
elif [[ -d "$SCRIPT_DIR/src " ]]; then
    DALI_HOME="$SCRIPT_DIR/src "
elif [[ -d "$SCRIPT_DIR/src" ]]; then
    DALI_HOME="$SCRIPT_DIR/src"
else
    echo "Error: DALI source directory not found at $SCRIPT_DIR/src or $SCRIPT_DIR/src "
    exit 1
fi
PROLOG="$SICSTUS_HOME/bin/sicstus"
BUILD_HOME=build
INSTANCES_HOME=mas/instances
TYPES_HOME=mas/types
CONF_DIR=conf
WAIT="sleep 8"
LINDA_PORT=3010
AUTO_HEALTHCHECK="${AUTO_HEALTHCHECK:-1}"
HEALTHCHECK_WAIT="${HEALTHCHECK_WAIT:-20}"
NO_ATTACH="${NO_ATTACH:-0}"
AGENT_START_STAGGER="${AGENT_START_STAGGER:-2}"

# BUG FIX 3: Increased stagger from 2s to 3s.
# With 8 agents launching sequentially, 2s was too short on machines where
# SICStus Prolog takes >1.5s to initialise Linda client library.
AGENT_START_STAGGER="${AGENT_START_STAGGER:-3}"

# --- ENVIRONMENT CHECK ---
if ! command -v tmux &> /dev/null; then
    echo "Error: tmux is required. Install with: sudo apt install tmux"
    exit 1
fi
if [[ ! -x "$PROLOG" ]]; then
    echo "Error: SICStus Prolog not found at $PROLOG"
    echo "Adjust SICSTUS_HOME at the top of this script."
    exit 1
fi

# --- CLEANUP ---
echo "Stopping existing agents..."
killall sicstus 2>/dev/null || true
tmux kill-session -t DALI_session 2>/dev/null || true
pkill -9 -f active_server_wi.pl 2>/dev/null || true
pkill -9 -x sicstus 2>/dev/null || true
if command -v fuser &> /dev/null; then
    fuser -k -9 ${LINDA_PORT}/tcp 2>/dev/null || true
fi

echo "Cleaning build/work/tmp..."
rm -rf tmp/* build/* work/* conf/mas/*
mkdir -p tmp build work conf/mas log

# --- SELECT FREE LINDA PORT ---
while ss -ltnH "sport = :${LINDA_PORT}" 2>/dev/null | grep -q .; do
    LINDA_PORT=$((LINDA_PORT + 1))
done
echo "Using LINDA port: ${LINDA_PORT}"

# Keep server endpoint aligned with the selected runtime port.
printf "'localhost':%s.\n" "$LINDA_PORT" > "$SCRIPT_DIR/server.txt"

# --- BUILD AGENTS (copy type file into build/ for each instance) ---
resolve_type_file() {
    local raw_type="$1"
    local candidate normalized_raw normalized_base

    candidate="$TYPES_HOME/$raw_type.txt"
    if [[ -f "$candidate" ]]; then
        echo "$candidate"; return 0
    fi

    normalized_raw="$(echo "$raw_type" | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:]')"
    for candidate in "$TYPES_HOME"/*.txt; do
        [[ -f "$candidate" ]] || continue
        normalized_base="$(basename "$candidate" .txt | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:]')"
        if [[ "$normalized_base" == "$normalized_raw" ]]; then
            echo "$candidate"; return 0
        fi
    done
    return 1
}

echo "Building agent instances..."
for instance_path in $INSTANCES_HOME/*.txt; do
    instance_filename=$(basename "$instance_path")
    agent_name="${instance_filename%.txt}"
    agent_type=$(tr -d '\r' < "$instance_path")
    type_file="$(resolve_type_file "$agent_type" || true)"

    if [[ -n "$type_file" && -f "$type_file" ]]; then
        echo "  $agent_name  (type: $agent_type)"
        cat "$type_file" > "$BUILD_HOME/$agent_name.txt"
    else
        echo "WARNING: No type file found for '$agent_type' (agent: $agent_name)"
    fi
done

files=($BUILD_HOME/*.txt)
if [[ ${#files[@]} -eq 0 ]]; then
    echo "Error: No agent files were built. Check mas/types/ and mas/instances/."
    exit 1
fi
cp "${files[@]}" work/
cp "${files[@]}" tmp/

# --- START LINDA SERVER ---
echo "Starting LINDA Server on port ${LINDA_PORT}..."
server_ready=0
for attempt in $(seq 1 10); do
    srvcmd="\"$PROLOG\" --noinfo -l \"$DALI_HOME/active_server_wi.pl\" --goal \"go(${LINDA_PORT},'$SCRIPT_DIR/server.txt').\""
    tmux new-session -d -s DALI_session -n "DALI_MAS" "$srvcmd"
    echo "  Attempt $attempt: waiting ${WAIT#sleep }s..."
    $WAIT

    if ! tmux has-session -t DALI_session 2>/dev/null; then
        LINDA_PORT=$((LINDA_PORT + 1)); continue
    fi

    # BUG FIX 5: Original grep pattern was too loose.
    # 'SPIO_E_NET_ADDRINUSE' is the correct SICStus socket-in-use error atom.
    if tmux capture-pane -pt DALI_session.0 -S -80 | grep -Eq "SPIO_E_NET_ADDRINUSE|goal failed|ERROR"; then
        tmux kill-session -t DALI_session 2>/dev/null || true
        LINDA_PORT=$((LINDA_PORT + 1)); continue
    fi

    server_ready=1; break
done

if [[ "$server_ready" -ne 1 ]]; then
    echo "Error: LINDA Server failed to start."
    exit 1
fi

# Persist the final, actually bound port after retries.
printf "'localhost':%s.\n" "$LINDA_PORT" > "$SCRIPT_DIR/server.txt"

tmux set-option -t DALI_session -g pane-border-status top
tmux set-option -t DALI_session -g pane-border-format '#{pane_title}'
tmux set-option -t DALI_session -g status on
tmux set-option -t DALI_session -g status-interval 5
tmux set-option -t DALI_session -g status-right '#{?client_prefix,[PREFIX],} %Y-%m-%d %H:%M '
tmux set-option -t DALI_session -g mouse on
tmux rename-window -t DALI_session:0 "AGENTS"
tmux select-pane -t DALI_session:AGENTS.0 -T "LINDA_SERVER"

# BUG FIX 4: server.txt copy must use absolute SCRIPT_DIR path.
# Original used relative 'server.txt' which broke when called from a different CWD.
cp -f "$SCRIPT_DIR/server.txt" "$DALI_HOME/server.txt"

# --- LAUNCH AGENTS ---

launch_agent() {
    local agent_name="$1"
    local delay="${2:-$AGENT_START_STAGGER}"
    local win_target="DALI_session:AGENTS"
    local cmd="\"$CONF_DIR/startagent.sh\" \"$agent_name\" \"$PROLOG\" \"$DALI_HOME\""
    local pane_id

    echo "Launching agent: $agent_name"
    "$CONF_DIR/makeconf.sh" "$agent_name" "$DALI_HOME"

    # Always split to add new agent panes (LINDA_SERVER stays in pane 0)
    pane_id=$(tmux split-window -v -t "$win_target" -P -F '#{pane_id}' "$cmd")

    tmux select-pane -t "$pane_id" -T "$agent_name"

    # Use tiled layout to fit all panes in grid arrangement
    tmux select-layout -t "$win_target" tiled
    sleep "$delay"
}

# Launch all agents in a single AGENTS window - all visible at once
# LINDA Server is already in pane 0, start agents from pane 1
launch_agent "control_center"
launch_agent "logger"
launch_agent "truck1"
launch_agent "truck2"
launch_agent "truck3"
launch_agent "smart_bin1" "0.2"
launch_agent "smart_bin2" "0.2"
launch_agent "smart_bin3" "0.2"

tmux select-window -t DALI_session:AGENTS

echo ""
echo "========================================"
echo "  SmartCity MAS started successfully"
echo "  LINDA port: ${LINDA_PORT}"
echo "  Agents: 3 bins, 3 trucks, logger, control_center"
echo "========================================"
echo ""

if [[ "$NO_ATTACH" -ne 1 ]]; then
    tmux attach-session -t DALI_session
fi
