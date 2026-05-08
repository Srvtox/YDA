#!/bin/bash
set -e

QUERY="$1"
OUTPUT="youtube_results.txt"

if [ -z "$QUERY" ]; then
  echo "Usage: ./youtube_search.sh \"search keywords\""
  exit 1
fi

> "$OUTPUT"

echo "🔎 Searching YouTube safely for: $QUERY"
echo "-----------------------------------"

NODE_PATH="$(which node || true)"

ARGS=(
  "ytsearch10:${QUERY}"
  --extractor-args "youtube:player_client=tvhtml5"
  --sleep-requests 2
  --retries 5
  --socket-timeout 20
  --no-warnings
  --proxy "socks5://127.0.0.1:1080"
  --add-header "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"
  --print "Title: %(title)s
Channel: %(channel)s
Duration: %(duration_string)s
Views: %(view_count)s
Upload Date: %(upload_date)s
URL: %(webpage_url)s
-----------------------------------"
)

if [ -n "$NODE_PATH" ]; then
  ARGS+=( --js-runtimes "node:${NODE_PATH}" )
fi

if [ -f cookies.txt ]; then
  echo "🍪 Using cookies..."
  yt-dlp --cookies cookies.txt "${ARGS[@]}" >> "$OUTPUT"
else
  yt-dlp "${ARGS[@]}" >> "$OUTPUT"
fi

echo "✅ Search finished"
cat "$OUTPUT"
