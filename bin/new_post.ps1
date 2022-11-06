param ($postname)
$name = (get-date -format "yyyy-dd-MM")+"-"+$postname+".md"
$date = (get-date -format "yyyy-dd-MM HH:mm:ss zzz")
Write-Output @"
---
layout: post
title: "$postname"
date:   $date
tags: 
---
"@ > .\docs\_posts\$name