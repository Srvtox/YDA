#!/bin/bash

set -e

# Check yt-dlp
if ! command -v yt-dlp &> /dev/null; then
    echo "❌ yt-dlp نصب نیست."
    exit 1
fi

# Check ffmpeg
if ! command -v ffmpeg &> /dev/null; then
    echo "❌ ffmpeg نصب نیست!"
    exit 1
fi

# Check deno (optional)
if ! command -v deno &> /dev/null; then
    echo "⚠️ deno نصب نیست."
fi

# Check URL
if [ -z "$1" ]; then
    echo "❌ هیچ لینکی ارائه نشده است."
    exit 1
fi

YOUTUBE_URL="$1"

mkdir -p downloads

echo "📥 در حال دانلود ویدیو از ${YOUTUBE_URL}..."

yt-dlp \
  --force-ipv4 \
  --geo-bypass \
  --no-playlist \
  --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" \
  --add-header "Accept-Language: en-US,en;q=0.9" \
  --ffmpeg-location "$(command -v ffmpeg)" \
  --merge-output-format mp4 \
  --embed-thumbnail \
  --add-metadata \
  --write-thumbnail \
  --write-auto-subs \
  --sub-langs "en.*,fa.*" \
  -o "downloads/%(title)s.%(ext)s" \
  "$YOUTUBE_URL"

echo "✅ ویدیو با موفقیت دانلود شد."
