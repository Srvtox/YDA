#!/bin/bash

# Exit immediately if a command exits with non-zero status.
set -e

# Check if yt-dlp is installed
if ! command -v yt-dlp &> /dev/null
then
    echo "❌ yt-dlp نصب نیست."
    exit 1
fi

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null
then
    echo "❌ ffmpeg نصب نیست! لطفا ffmpeg را نصب کنید."
    exit 1
fi

# Check if deno is installed
if ! command -v deno &> /dev/null
then
    echo "⚠️ deno نصب نیست. ممکن است برخی ویدیوها به درستی پردازش نشوند."
    # We don't exit here, yt-dlp might still work for some formats
fi

# Check if a URL was provided
if [ -z "$1" ]; then
    echo "❌ هیچ لینکی ارائه نشده است."
    exit 1
fi

YOUTUBE_URL="$1"

echo "📥 در حال دانلود ویدیو از ${YOUTUBE_URL}..."

# Use --ffmpeg-location to specify the ffmpeg path
# yt-dlp automatically creates the directory specified in the output path if it doesn't exist.
yt-dlp --force-overwrites --ffmpeg-location "$(command -v ffmpeg)" \
       -o "downloads/%(title)s.%(ext)s" \
       --embed-thumbnail \
       --add-metadata \
       --write-thumbnail \
       --sub-langs "en.*,fa.*" \
       "${YOUTUBE_URL}"

echo "✅ ویدیو با موفقیت دانلود شد."
       --embed-thumbnail \
       --add-metadata \
       --write-thumbnail \
       --sub-langs "en.*,fa.*" \
       "${YOUTUBE_URL}"

echo "✅ ویدیو با موفقیت دانلود شد."
