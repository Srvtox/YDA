#!/bin/bash
set -e

URL="$1"
VIDEO_ID=$(echo "$URL" | sed 's/.*v=//;s/&.*//')

echo "📥 Video ID = $VIDEO_ID"

MIRRORS=(
    "https://pipedapi.coldwire.xyz"
    "https://pipedapi.cdnfrom.net"
    "https://pipedapi.smnz.de"
)

STREAM_JSON=""

echo "🔍 Checking mirrors..."

for API in "${MIRRORS[@]}"; do
    echo "🌐 Testing: $API"

    RAW=$(curl -4 -s --max-time 6 "$API/streams/$VIDEO_ID" || true)

    if [ -z "$RAW" ]; then
        echo "⚠️ Empty response."
        continue
    fi

    if echo "$RAW" | jq empty 2>/dev/null; then
        echo "✅ Valid JSON from $API"
        STREAM_JSON="$RAW"
        break
    else
        echo "❌ Not valid JSON: $(echo "$RAW" | head -c 80)"
    fi
done

if [ -z "$STREAM_JSON" ]; then
    echo "❌ No valid JSON from any mirror."
    exit 1
fi

VIDEO_URL=$(echo "$STREAM_JSON" | jq -r '.videoStreams | max_by(.quality) | .url')

TITLE=$(echo "$STREAM_JSON" | jq -r '.title' | sed 's/[\/:*?"<>|]/-/g')

mkdir -p downloads

echo "⬇️ Downloading…"
curl -L "$VIDEO_URL" -o "downloads/${TITLE}.mp4"

echo "🎉 Done: downloads/${TITLE}.mp4"
