param ($postname)
$name = (get-date -format "yyyy-dd-MM")+"-"+$postname+".md"
$date = (get-date -format "yyyy-dd-MM HH:mm:ss zzz")
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