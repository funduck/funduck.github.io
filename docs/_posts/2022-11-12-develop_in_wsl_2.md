---
layout: post
title: "Run VsCode in WSL, Luke"
date:   2022-11-12 07:44:11 +03:00
tags: 
---

Not much to say but when I run VsCode from WSL terminal all problems with slow I/O just disappeared.  
Just enter the directory with your repo and type
```
code .
```

You'll have to install all extensions again.  
And in my case when I run tests WSL sometimes freezes and I have to reboot it.  
So I monitor CPU and when it is too high I close VsCode and maybe Chrome to give WSL extra resources.  