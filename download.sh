#!/bin/bash
set -e

URL="$1"
VIDEO_ID=$(echo "$URL" | sed 's/.*v=//;s/&.*//')

echo "📥 Video ID = $VIDEO_ID"

MIRRORS=(
    "https://piped.video"
    "https://pipedapi.adminforge.de"
    "https://pipedapi.esmailelbob.xyz"
    "https://pipedapi-libre.kavin.rocks"
    "https://pipedapi.leptons.xyz"
)

STREAM_JSON=""

echo "🔍 Checking mirrors..."

for API in "${MIRRORS[@]}"; do
    echo "🌐 Testing: $API"

    # Save raw output for debugging
    RAW=$(curl -s --max-time 6 "$API/streams/$VIDEO_ID" || true)

    if [ -z "$RAW" ]; then
        echo "⚠️ Empty response."
        continue
    fi

    # Print first 200 chars of response
    echo "📄 RAW RESPONSE (first 200 chars):"
    echo "$RAW" | head -c 200
    echo ""
    echo ""

    # Try detecting JSON
    if echo "$RAW" | jq empty 2>/dev/null; then
        echo "✅ Valid JSON from $API"
        STREAM_JSON="$RAW"
        break
    else
        echo "❌ Not valid JSON from $API"
    fi
done

if [ -z "$STREAM_JSON" ]; then
    echo "❌ No valid JSON from any Piped mirror."
    exit 1
fi

# Now extract video URL
VIDEO_URL=$(echo "$STREAM_JSON" | jq -r '.videoStreams | max_by(.quality) | .url')

echo "⬇️ Video URL: $VIDEO_URL"
