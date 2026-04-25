#!/bin/bash

set -e

# بررسی وجود yt-dlp
if ! command -v yt-dlp &> /dev/null; then
    echo "❌ yt-dlp نصب نیست."
    exit 1
fi

# بررسی وجود ffmpeg (yt-dlp برای ادغام به آن نیاز دارد)
if ! command -v ffmpeg &> /dev/null; then
    echo "❌ ffmpeg نصب نیست."
    exit 1
fi

# بررسی وجود ورودی
if [ -z "$1" ]; then
    echo "❌ لطفاً آدرس m3u8 را به عنوان ورودی وارد کنید:"
    echo "   مثال: ./download.sh https://example.com/video.m3u8 [نام فایل]"
    exit 1
fi

# دریافت آدرس از آرگومان اول
M3U8_URL="$1"

# مسیر خروجی (داخل مخزن)
OUTPUT_DIR="downloads"

# ایجاد پوشه خروجی اگر وجود نداشت
if [ ! -d "$OUTPUT_DIR" ]; then
    echo "📁 ایجاد پوشه: $OUTPUT_DIR"
    mkdir -p "$OUTPUT_DIR"
fi

# نام فایل خروجی (با قابلیت تغییر با آرگومان دوم)
if [ -n "$2" ]; then
    # اگر نام فایل با پسوند وارد شده
    if [[ "$2" == *.* ]]; then
        FILENAME="$2"
    else
        FILENAME="$2.mp4"
    fi
else
    # نام پیش‌فرض با تاریخ و زمان
    FILENAME="classino_$(date +%Y%m%d_%H%M%S).mp4"
fi

# مسیر کامل فایل خروجی
OUTPUT_PATH="$OUTPUT_DIR/$FILENAME"

echo "📥 در حال دریافت با yt-dlp: $M3U8_URL"
echo "📂 مسیر خروجی: $OUTPUT_DIR"
echo "💾 نام فایل: $FILENAME"
echo "🔄 در حال دانلود..."

# اجرای yt-dlp با هدرها و تنظیمات مقاوم
yt-dlp \
    --add-header "Referer: https://panel.classino.com/" \
    --add-header "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64)" \
    --concurrent-fragments 4 \
    --retries 10 \
    --fragment-retries 10 \
    --file-access-retries 10 \
    --merge-output-format mp4 \
    --output "$OUTPUT_PATH" \
    "$M3U8_URL"

# بررسی نتیجه
if [ $? -eq 0 ]; then
    echo "✅ دانلود با موفقیت کامل شد:"

    # پیدا کردن فایل نهایی (ممکن است yt-dlp پسوند دقیق را رعایت کند یا تغییر دهد)
    if [ -f "$OUTPUT_PATH" ]; then
        FINAL_FILE="$OUTPUT_PATH"
    else
        # اگر فایل با نام دقیق پیدا نشد، به دنبال فایلی با همان نام و هر پسوندی می‌گردیم
        FINAL_FILE=$(find "$OUTPUT_DIR" -maxdepth 1 -name "${FILENAME%.*}.*" -print -quit)
    fi

    if [ -n "$FINAL_FILE" ]; then
        echo "   $FINAL_FILE"
        FILESIZE=$(du -h "$FINAL_FILE" | cut -f1)
        echo "📊 حجم فایل: $FILESIZE"
    else
        echo "⚠️ فایل ذخیره شد اما نام دقیق آن مشخص نیست. پوشه را بررسی کنید."
    fi
else
    echo "❌ خطا در دانلود"
    exit 1
fi
