param ($postname)
$name = (get-date -format "yyyy-MM-dd")+"-"+$postname+".md"
$date = (get-date -format "yyyy-MM-dd HH:mm:ss zzz")
$file = ".\docs\_posts\"+$name
$content = @"
---
layout: post
title: "$postname"
date:   $date
tags: 
---
"@

New-Item $file -Value $content