postname="$1"
name=$(date -u +%Y-%m-%d)"-"$(echo "$postname" | sed 's/ /_/g')".md"
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