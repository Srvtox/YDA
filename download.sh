#!/bin/bash
set -e

if [ -z "$1" ]; then
    echo "❌ هیچ لینکی ارسال نشده."
    exit 1
fi

URL="$1"

echo "📥 ویدیو: $URL"

# استخراج ID ویدیو
VIDEO_ID=$(echo "$URL" | sed 's/.*v=//;s/&.*//')

if [ -z "$VIDEO_ID" ]; then
    echo "❌ نتوانستم Video ID را پیدا کنم."
    exit 1
fi

# لیست mirror های Piped برای fallback
MIRRORS=(
    "https://piped.video"
    "https://pipedapi.adminforge.de"
    "https://pipedapi.esmailelbob.xyz"
    "https://pipedapi-libre.kavin.rocks"
    "https://pipedapi.leptons.xyz"
)

mkdir -p downloads

echo "🔍 تلاش برای گرفتن لینک دانلود..."

STREAM_JSON=""

for API in "${MIRRORS[@]}"; do
    echo "🌐 تست: $API"
    STREAM_JSON=$(curl -s --max-time 5 "$API/streams/$VIDEO_ID") || true

    if [[ -n "$STREAM_JSON" && "$STREAM_JSON" != *"error"* ]]; then
        echo "✅ اتصال موفق به $API"
        break
    fi
done

if [ -z "$STREAM_JSON" ] || [[ "$STREAM_JSON" == *"error"* ]]; then
    echo "❌ هیچ Piped API قابل دسترس نبود."
    exit 1
fi

# گرفتن بهترین لینک ویدیو
VIDEO_URL=$(echo "$STREAM_JSON" | jq -r '.videoStreams | max_by(.quality) | .url')

if [ -z "$VIDEO_URL" ] || [ "$VIDEO_URL" = "null" ]; then
    echo "❌ نتوانستم لینک ویدیو را بگیرم."
    exit 1
fi

TITLE=$(echo "$STREAM_JSON" | jq -r '.title' | sed 's/[\/:*?"<>|]/-/g')

OUTPUT="downloads/${TITLE}.mp4"

echo "⬇️ شروع دانلود..."
curl -L --output "$OUTPUT" "$VIDEO_URL"

echo "🎉 دانلود با موفقیت انجام شد:"
echo "$OUTPUT"
