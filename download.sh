#!/bin/bash
set -e

INPUT="$1"
mkdir -p downloads

# اگر لینک یوتیوب نبود → دانلود فایل مستقیم
if [[ "$INPUT" != *"youtube.com"* && "$INPUT" != *"youtu.be"* ]]; then
    echo "📦 Direct file URL detected."

    FILENAME=$(basename "$INPUT")
    echo "⬇️ Downloading: $FILENAME"

    curl -L --retry 3 --progress-bar "$INPUT" -o "downloads/$FILENAME"
    echo "🎉 Saved to downloads/$FILENAME"
    exit 0
fi


##############################################
#              YouTube MODE
##############################################

VIDEO_ID=$(echo "$INPUT" | sed 's/.*v=//;s/&.*//')
echo "🎥 YouTube detected — VIDEO ID = $VIDEO_ID"

# چند API برای Failover
APIS=(
    "https://api.poketube.fun/api/v1/videos/$VIDEO_ID"
    "https://tube.kavin.rocks/api/v1/videos/$VIDEO_ID"
    "https://ytapi.net/api/info?videoId=$VIDEO_ID"
)

JSON=""
WORKING_API=""

echo "🌐 Testing YouTube mirrors..."

for API in "${APIS[@]}"; do
    echo "➡️ Trying: $API"

    # دیباگ فعال: شامل header و status code
    RESPONSE=$(curl -4 -s -D headers.txt --max-time 15 "$API" -o body.txt || true)

    # اگر body خالی باشد → رد کن
    if [[ ! -s body.txt ]]; then
        echo "❌ Empty body from $API"
        continue
    fi

    # تست JSON بودن
    if jq empty body.txt 2>/dev/null; then
        JSON=$(cat body.txt)
        WORKING_API="$API"
        echo "✅ Valid JSON from: $API"
        break
    else
        echo "⚠️ Not JSON from $API"
        head -c 200 body.txt
        echo
    fi
done

# اگر هیچ API جواب نداد
if [[ -z "$JSON" ]]; then
    echo "❌ ALL MIRRORS FAILED"
    echo "📄 Debug Headers:"
    cat headers.txt
    echo
    echo "📄 Body preview:"
    head -c 500 body.txt
    exit 1
fi


##############################################
#       استخراج اطلاعات و دانلود ویدیو
##############################################

TITLE=$(echo "$JSON" | jq -r '.title // .videoDetails.title')
TITLE=$(echo "$TITLE" | sed 's/[\/:*?"<>|]/-/g')

STREAM_URL=$(echo "$JSON" | jq -r '
    .streams // .formats // []
    | map(select(.mimeType // .type | contains("mp4")))
    | sort_by(.quality // .qualityLabel // "0" | sub("p";"") | tonumber)
    | reverse
    | .[0].url
')

if [[ -z "$STREAM_URL" || "$STREAM_URL" == "null" ]]; then
    echo "❌ No mp4 streams found."
    echo "🔍 JSON structure:"
    echo "$JSON" | head -c 500
    exit 1
fi

echo "⬇️ Downloading video: $TITLE"
curl -L --retry 3 "$STREAM_URL" -o "downloads/${TITLE}.mp4"

echo "🎉 Done: downloads/${TITLE}.mp4"
