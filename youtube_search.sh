#!/usr/bin/env bash
set -e

QUERY="$1"
PROXY="socks5://127.0.0.1:1080"

echo "🔎 Searching YouTube safely for: $QUERY"
echo "-----------------------------------"

SEARCH_URL="https://www.youtube.com/results?search_query=$(printf '%s' "$QUERY" | sed 's/ /+/g')"

echo "🌐 Fetching search page..."

HTML=$(curl -s --proxy $PROXY \
  -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" \
  "$SEARCH_URL")

IDS=$(echo "$HTML" | grep -oE "watch\\?v=[a-zA-Z0-9_-]{11}" | head -n 5 | sed 's/watch?v=//')

if [ -z "$IDS" ]; then
  echo "❌ No video IDs found"
  exit 0
fi

echo "🎬 Found videos:"
echo "$IDS"
echo "-----------------------------------"

for ID in $IDS; do
  URL="https://www.youtube.com/watch?v=$ID"
  echo "📺 $URL"

  yt-dlp \
    --proxy "$PROXY" \
    --skip-download \
    --print "%(title)s | %(duration)s | %(view_count)s views" \
    "$URL" || true

  sleep 2
done

echo "✅ Search completed"
