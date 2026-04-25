#!/bin/bash
set -e

# Check dependencies
if ! command -v yt-dlp &> /dev/null; then
    echo "❌ yt-dlp نصب نیست."
    exit 1
fi

if ! command -v ffmpeg &> /dev/null; then
    echo "❌ ffmpeg نصب نیست!"
    exit 1
fi

if ! command -v deno &> /dev/null; then
    echo "⚠️ deno نصب نیست. برخی ویدیوها ممکن است به درستی پردازش نشوند."
fi

if [ -z "$1" ]; then
    echo "❌ هیچ لینکی ارائه نشده است."
    exit 1
fi

YOUTUBE_URL="$1"

echo "📥 دانلود از: ${YOUTUBE_URL}"

yt-dlp \
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


echo "✅ ویدیو با موفقیت دانلود شد."
