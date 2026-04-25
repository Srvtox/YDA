#!/bin/bash
set -e

URL="$1"
VIDEO_ID=$(echo "$URL" | sed 's/.*v=//;s/&.*//')

API="https://api.poketube.fun/api/v1/videos/$VIDEO_ID"

echo "📥 Video ID = $VIDEO_ID"
echo "🌐 Fetching metadata from Poketube API..."

JSON=$(curl -4 -s --max-time 15 "$API")

if [ -z "$JSON" ]; then
    echo "❌ Empty response from Poketube API."
    exit 1
fi

# Validate JSON
echo "$JSON" | jq empty 2>/dev/null || {
    echo "❌ Invalid JSON:"
    echo "$JSON" | head -c 200
    exit 1
}

echo "✅ JSON received."

TITLE=$(echo "$JSON" | jq -r '.title' | sed 's/[\/:*?"<>|]/-/g')

# Pick best mp4 video stream
STREAM_URL=$(echo "$JSON" | jq -r '
    .streams
    | map(select(.mimeType | contains("video") and contains("mp4")))
    | sort_by(.quality | tonumber)
    | reverse
    | .[0].url
')

if [ -z "$STREAM_URL" ] || [ "$STREAM_URL" = "null" ]; then
    echo "❌ No mp4 streams found."
    exit 1
fi

mkdir -p downloads

echo "⬇️ Downloading best mp4 stream..."
curl -L --retry 3 --retry-delay 2 "$STREAM_URL" -o "downloads/${TITLE}.mp4"

echo "🎉 Download complete: downloads/${TITLE}.mp4"
