#!/bin/bash

set -e

# بررسی وجود yt-dlp
if ! command -v yt-dlp &> /dev/null; then
    echo "❌ yt-dlp نصب نیست."
    exit 1
fi

# بررسی وجود ffmpeg
if ! command -v ffmpeg &> /dev/null; then
    echo "❌ ffmpeg نصب نیست."
    exit 1
fi

# بررسی ورودی
if [ -z "$1" ]; then
    echo "❌ لطفاً لینک ویدئوی یوتیوب را وارد کنید:"
    echo "   مثال: ./download.sh https://www.youtube.com/watch?v=ID"
    exit 1
fi

VIDEO_URL="$1"

OUTPUT_DIR="downloads"
mkdir -p "$OUTPUT_DIR"

# نام فایل ویدیو بر اساس عنوان ویدیو
yt-dlp \
  -f "bestvideo+bestaudio/best" \
  --merge-output-format mp4 \
  -o "${OUTPUT_DIR}/%(title)s.%(ext)s" \
  "$VIDEO_URL"

echo "✅ ویدیو با موفقیت دانلود شد. مسیر خروجی:"
ls -lh "$OUTPUT_DIR"
