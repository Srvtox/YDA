#!/bin/bash

QUERY="$1"

if [ -z "$QUERY" ]; then
  echo "Usage: ./youtube_search.sh \"search keywords\""
  exit 1
fi

OUTPUT="youtube_results.txt"

echo "🔎 Searching YouTube for: $QUERY"
echo "-----------------------------------"

# پاک کردن فایل قبلی
> "$OUTPUT"

yt-dlp "ytsearch10:${QUERY}" \
--print "Title: %(title)s
Channel: %(channel)s
Duration: %(duration_string)s
Views: %(view_count)s
Upload Date: %(upload_date)s
URL: %(webpage_url)s
-----------------------------------" >> "$OUTPUT"

echo "✅ Search complete!"
echo ""

cat "$OUTPUT"
