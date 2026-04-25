#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Check if yt-dlp is installed
if ! command -v yt-dlp &> /dev/null
then
    echo "❌ yt-dlp نصب نیست."
    exit 1
fi

# Check if ffmpeg is installed (yt-dlp might need it for some formats)
if ! command -v ffmpeg &> /dev/null
then
    echo "⚠️ ffmpeg نصب نیست. دانلود ممکن است با مشکل مواجه شود."
    # We don't exit here, yt-dlp might still work for some formats
fi

# Check if a URL was provided
if [ -z "$1" ]; then
    echo "❌ هیچ لینکی ارائه نشده است."
    exit 1
fi

YOUTUBE_URL="$1"
# DOWNLOAD_DIR="downloads" # این خط را کامنت یا حذف کن

# Create download directory if it doesn't exist - yt-dlp will create it if needed.
# mkdir -p "$DOWNLOAD_DIR" # این خط را کامنت یا حذف کن

echo "📥 در حال دانلود ویدیو از ${YOUTUBE_URL}..."

# yt-dlp command to download the best quality video and audio, merge if necessary, and save with a clean filename
# Using --parse-metadata "%(title)s" to ensure we get the title correctly for filename
# Using --sub-langs "en.*,fa.*" to prioritize English and Farsi subtitles if available
# Using --embed-thumbnail to embed thumbnail
# Using --add-metadata to add metadata
# Using --output to specify the download path and filename format
# yt-dlp automatically creates the directory specified in the output path if it doesn't exist.
yt-dlp --force-overwrites --ffmpeg-location "$(command -v ffmpeg)" \
       -o "downloads/%(title)s.%(ext)s" \
       --embed-thumbnail \
       --add-metadata \
       --write-thumbnail \
       --sub-langs "en.*,fa.*" \
       --parse-metadata "%(title)s" \
       "${YOUTUBE_URL}"

echo "✅ ویدیو با موفقیت دانلود شد."
