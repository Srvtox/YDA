#!/bin/bash
set -e

if ! command -v yt-dlp &> /dev/null; then echo "❌ yt-dlp نصب نیست."; exit 1; fi
if ! command -v ffmpeg &> /dev/null; then echo "❌ ffmpeg نصب نیست!"; exit 1; fi
if ! command -v curl &> /dev/null; then echo "❌ curl نصب نیست!"; exit 1; fi

if [ -z "$1" ]; then echo "❌ هیچ لینکی ارائه نشده است."; exit 1; fi

URL="$1"
TEST_URL="https://www.youtube.com/watch?v=dQw4w9WgXcQ"

echo "🌍 دریافت پروکسی‌های HTTPS از چند منبع..."

TEMP_PROXIES="/tmp/proxies.txt"
> "$TEMP_PROXIES"

# 1. Geonode (پروکسی با کیفیت‌تر)
curl -s "https://proxylist.geonode.com/api/proxy-list?limit=30&page=1&sort_by=lastChecked&sort_type=desc&protocols=https" \
 | grep -oE '"ip":"[0-9\.]+","port":[0-9]+' \
 | sed -E 's/"ip":"([^"]+)","port":([0-9]+)/\1:\2/' >> "$TEMP_PROXIES"

# 2. ProxyScrape HTTPS
curl -s "https://api.proxyscrape.com/v2/?request=getproxies&protocol=https" >> "$TEMP_PROXIES"

# 3. Proxyscan HTTPS
curl -s "https://www.proxyscan.io/download?type=https" >> "$TEMP_PROXIES"

echo "🔍 در حال تست پروکسی‌های HTTPS..."

WORKING_PROXY=""

while IFS= read -r proxy; do
    [ -z "$proxy" ] && continue
    echo "➡️ تست: $proxy"

    if yt-dlp --proxy "https://$proxy" \
              --socket-timeout 5 \
              --skip-download \
              --extractor-args "youtube:player_client=android" \
              "$TEST_URL" &> /dev/null
    then
        echo "✅ پروکسی سالم: $proxy"
        WORKING_PROXY="$proxy"
        break
    else
        echo "❌ خراب است"
    fi
done < "$TEMP_PROXIES"

if [ -z "$WORKING_PROXY" ]; then
    echo "⚠️ هیچ پروکسی سالمی پیدا نشد."
    echo "🚫 دانلود از GitHub Actions با IP فعلی تقریباً غیرممکن است."
    exit 1
fi

echo "🚀 استفاده از پروکسی سالم: $WORKING_PROXY"

yt-dlp \
    --proxy "https://$WORKING_PROXY" \
    --force-overwrites \
    --ffmpeg-location "$(command -v ffmpeg)" \
    -o "downloads/%(title)s.%(ext)s" \
    --embed-thumbnail \
    --embed-metadata \
    --add-metadata \
    --write-thumbnail \
    --write-subs \
    --sub-langs "en.*,fa.*" \
    --extractor-args "youtube:player_client=android" \
    "$URL"

echo "✅ عملیات دانلود پایان یافت."
