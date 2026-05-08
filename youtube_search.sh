#!/bin/bash

QUERY="$1"
OUTPUT="youtube_results.txt"

if [ -z "$QUERY" ]; then
  echo "Usage: ./youtube_search.sh \"search keywords\""
  exit 1
fi

> "$OUTPUT"

echo "🔎 Searching YouTube safely for: $QUERY"
echo "-----------------------------------"

# Build arguments safely using array
ARGS=(
  "ytsearch10:${QUERY}"
  --extractor-args "youtube:player_client=tvhtml5"
  --js-runtimes "node:$(which node)"
  --sleep-requests 2
  --retries 5
  --no-warnings
  --proxy "socks5://127.0.0.1:1080"
  --add-header "User-Agent: Mozilla/5.0"
  --print "
Title: %(title)s
Channel: %(channel)s
Duration: %(duration_string)s
Views: %(view_count)s
Upload Date: %(upload_date)s
URL: %(webpage_url)s
-----------------------------------
"
)

if [ -f cookies.txt ]; then
  echo "🍪 Using cookies..."
  yt-dlp --cookies cookies.txt "${ARGS[@]}" >> "$OUTPUT"
else
  yt-dlp "${ARGS[@]}" >> "$OUTPUT"
fi

echo "✅ Search finished"
cat "$OUTPUT"
