#!/usr/bin/env bash
set -e

QUERY="$1"
COOKIES_FILE="$2"

echo "🔎 Searching YouTube safely for: $QUERY"
echo "-----------------------------------"

ARGS=(
  --proxy "socks5://127.0.0.1:1080"
  --extractor-args "youtube:player_client=tvhtml5"
  --no-warnings
  --ignore-errors
  --sleep-requests 1
  --sleep-interval 1
  --retries 3
  --limit-rate 5M
  --no-check-certificates
)

if [ -n "$COOKIES_FILE" ] && [ -f "$COOKIES_FILE" ]; then
  echo "🍪 Cookies detected → Using authentication"
  ARGS+=( --cookies "$COOKIES_FILE" )
else
  echo "⚠️ No cookies → Age-restricted videos will be skipped"
fi

echo "🚀 Running yt-dlp search..."
set +e
OUTPUT=$(yt-dlp "ytsearch5:$QUERY" -j "${ARGS[@]}" 2>&1)
EXIT_CODE=$?
set -e

if echo "$OUTPUT" | grep -q "Sign in to confirm your age"; then
  echo "⛔ Age-restricted video detected!"
  if [ -z "$COOKIES_FILE" ]; then
    echo "➡️ No cookies → Skipping video safely without failing workflow."
    exit 0
  else
    echo "➡️ Cookies exist but still restricted → Skipping anyway."
    exit 0
  fi
fi

echo "$OUTPUT"
echo "✅ Search completed"
