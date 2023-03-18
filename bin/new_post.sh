postname=$(echo "$1" | sed 's/ /_/g')
name=$(date -u +%Y-%m-%d)"-$postname.md"
date=$(date -u +%Y-%m-%dT%H:%M:%S%Z)
file="./docs/_posts/$name"
content="---
layout: post
title: \"$postname\"
date: $date
tags: 
---
"
printf "%s" "$content" > $file