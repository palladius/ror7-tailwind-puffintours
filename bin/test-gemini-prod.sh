#! /bin/bash

# echo "🐧 ♊️🔑 PUFFIN_TOURS_GEMINI_API_KEY=#{PUFFIN_TOURS_GEMINI_API_KEY}"
# echo "🐧 ♊️🔑 GOOGLE_APPLICATION_CREDENTIALS=#{GOOGLE_APPLICATION_CREDENTIALS}"

echo "🐧" * 40

echo 'a = Article.find 34
puts(a.inspect)

# sum = a.generate_summary
# puts(sum)

img_sum = a.generate_image_synopsis
puts(img_sum)

' | RAILS_ENV=production rails c
