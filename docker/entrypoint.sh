#!/bin/bash
set -e

echo "[rails-claw] Starting up..."

# Run pending migrations
echo "[rails-claw] Running migrations..."
bin/rails db:migrate 2>/dev/null || bin/rails db:setup

# Verify PicoClaw binary
if [ -x "$PICOCLAW_BINARY_PATH" ]; then
  echo "[rails-claw] PicoClaw binary found at $PICOCLAW_BINARY_PATH"
else
  echo "[rails-claw] WARNING: PicoClaw binary not found at $PICOCLAW_BINARY_PATH"
fi

# Log VV Provider URL
echo "[rails-claw] VV Provider URL: ${VV_PROVIDER_URL:-http://localhost:8321}"

# Trap signals for graceful shutdown
cleanup() {
  echo "[rails-claw] Shutting down..."
  # Stop all running PicoClaw processes
  bin/rails runner "Workspace.running.each { |w| PicoClaw::ProcessManager.new(w).stop }" 2>/dev/null || true
  exit 0
}
trap cleanup SIGTERM SIGINT

echo "[rails-claw] Starting server..."
exec "$@"
