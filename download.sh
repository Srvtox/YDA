#!/bin/bash

set -e

# Check dependencies
if ! command -v yt-dlp &> /dev/null; then
    echo "❌ yt-dlp نصب نیست."
    exit 1
fi

if ! command -v ffmpeg &> /dev/null; then
    echo "❌ ffmpeg نصب نیست."
    exit 1
fi

# Check URL
if [ -z "$1" ]; then
    echo "❌ هیچ لینکی داده نشده."
    exit 1
fi

YOUTUBE_URL="$1"

mkdir -p downloads

echo "📥 در حال دانلود: $YOUTUBE_URL"

COMMON_ARGS=(
  --force-ipv4
  --geo-bypass
  --no-playlist
  --no-check-certificates
  --merge-output-format mp4
  --ffmpeg-location "$(command -v ffmpeg)"
  --embed-thumbnail
  --add-metadata
  --write-thumbnail
  --write-auto-subs
  --sub-langs "en.*,fa.*"
  -o "downloads/%(title)s.%(ext)s"
)

# try Android client (best for bypass)
echo "🔹 Trying Android client..."
if yt-dlp \
  --extractor-args "youtube:player_client=android" \
  --user-agent "com.google.android.youtube/17.31.35 (Linux; U; Android 11)" \
  "${COMMON_ARGS[@]}" \
  "$YOUTUBE_URL"; then
  echo "✅ دانلود موفق با android client"
  exit 0
fi

# try Web client
echo "🔹 Trying Web client..."
if yt-dlp \
  --extractor-args "youtube:player_client=web" \
  --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" \
  "${COMMON_ARGS[@]}" \
  "$YOUTUBE_URL"; then
  echo "✅ دانلود موفق با web client"
  exit 0
fi

# try TV client
echo "🔹 Trying TV client..."
if yt-dlp \
  --extractor-args "youtube:player_client=tv" \
  "${COMMON_ARGS[@]}" \
  "$YOUTUBE_URL"; then
  echo "✅ دانلود موفق با tv client"
  exit 0
fi

echo "❌ دانلود ناموفق بود."
exit 1
