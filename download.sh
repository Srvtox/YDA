#!/bin/bash
set -e

# ----------- Dependency Checks -----------

if ! command -v yt-dlp &> /dev/null; then
    echo "❌ yt-dlp نصب نیست."
    exit 1
fi

if ! command -v ffmpeg &> /dev/null; then
    echo "❌ ffmpeg نصب نیست!"
    exit 1
fi

if ! command -v curl &> /dev/null; then
    echo "❌ curl نصب نیست!"
    exit 1
fi

if [ -z "$1" ]; then
    echo "❌ هیچ لینکی ارائه نشده است."
    exit 1
fi

YOUTUBE_URL="$1"
TEST_URL="https://www.youtube.com/watch?v=dQw4w9WgXcQ"

echo "📥 دانلود از: ${YOUTUBE_URL}"

# ----------- Fetch Proxy List -----------

echo "🌍 دریافت لیست پروکسی‌های رایگان..."

PROXY_LIST=$(curl -s "https://api.proxyscrape.com/v2/?request=getproxies&protocol=http&timeout=2000&country=all&ssl=all&anonymity=all" | head -n 20)

WORKING_PROXY=""

echo "🔍 در حال تست پروکسی‌ها..."

for proxy in $PROXY_LIST; do
    echo "➡️ تست پروکسی: $proxy"

    if yt-dlp --proxy "http://$proxy" \
              --socket-timeout 10 \
              --extractor-args "youtube:player_client=android" \
              --user-agent "com.google.android.youtube/17.31.35 (Linux; U; Android 11)" \
              --skip-download \
              "$TEST_URL" &> /dev/null
    then
        echo "✅ پروکسی سالم پیدا شد: $proxy"
        WORKING_PROXY="$proxy"
        break
    else
        echo "❌ ناموفق"
    fi
done

# ----------- Download Section -----------

if [ -n "$WORKING_PROXY" ]; then
    echo "🚀 استفاده از پروکسی سالم: $WORKING_PROXY"

    yt-dlp \
        --proxy "http://$WORKING_PROXY" \
        --force-overwrites \
        --ffmpeg-location "$(command -v ffmpeg)" \
        -o "downloads/%(title)s.%(ext)s" \
        --embed-thumbnail \
        --embed-metadata \
        --add-metadata \
        --write-thumbnail \
        --sub-langs "en.*,fa.*" \
        --write-subs \
        --extractor-args "youtube:player_client=android" \
        --user-agent "com.google.android.youtube/17.31.35 (Linux; U; Android 11)" \
        "${YOUTUBE_URL}"

else
    echo "⚠️ هیچ پروکسی سالمی پیدا نشد. تلاش بدون پروکسی..."

    yt-dlp \
        --force-overwrites \
        --ffmpeg-location "$(command -v ffmpeg)" \
        -o "downloads/%(title)s.%(ext)s" \
        --extractor-args "youtube:player_client=android" \
        "${YOUTUBE_URL}"
fi

echo "✅ عملیات دانلود پایان یافت."
