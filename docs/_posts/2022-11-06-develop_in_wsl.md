---
layout: post
title: "Developing Linux app in WSL on Windows"
date:   2022-11-06 17:46:40 +03:00
tags: pain
---

I found a new work after 9 months of pause and was so enthusiastic to start working as fast as possible. 
So when I received access to repo I wanted to run and debug some service to see what's going on in there.  

There are several services in TypeScript, all have `Makefile` with commands for setup and run on local machine.  
Cool, but I'm on Windows and here I should make a remark.

    The reason why I'm on windows is just my laptop that lacks drivers for Linux. 6-7 years old HP Omen with Core i5 it is.

So, the story is about how I run and debug TypeScript Nestjs service in docker on Windows.

## Makefiles
Project has `Makefile` to do almost everything that you can imagine so I wanted to use it too. This is how I can use **make** in Windows.
1.  Install the [chocolatey package manager](https://chocolatey.org/install)
2.  Run `choco install make`

Or just from the WSL terminal.

## Build
Just `make build` and ...  
For some reason containers were building very very slowly. I waited about 30 minutes, thought it was my slow Turkish internet.  
As I've found out later it was not my internet.  
Slowly, but I built all dockers and was ready to run the service.  

## Run
This is when I stucked for the first time.  
The compilation of TypeScript was even slower than building stage.  
Remember that song "Sorry seems to be the hardest word?". Those lyrics came to my mind instantly

    It's sad, so sad
    It's a sad, sad situation
    And it's getting more
    And more absurd

So, here is what I found:  
If data is stored in windows directories and used in WSL (in docker for example) access is slow because of drivers in between.  
And a couple of links: [one](https://youtrack.jetbrains.com/issue/WI-63786/Working-with-projects-on-WSL-is-extremely-slow-basically-not-possible-to-work-with) [two](https://stackoverflow.com/questions/68972448/why-is-wsl-extremely-slow-when-compared-with-native-windows-npm-yarn-processing)

Just put files into WSL if you use them in WSL. Great, code compiled and service started.

## Debug
    WSL strikes back

Honestly I spent more than a day trying to debug that service running in docker with VSCode.  
Debugger connected but breakpoints didn't work. Console reported unknown errors with source maps like this
```
Could not read source map for file:///app/dist/api/src/modules/user/http/middleware/account-subscription.middleware.js: UNKNOWN: unknown error, open '\\wsl$\Ubuntu20.04LTS\home\xxxx\xxxx_repos\xxxx\api\dist\api\src\modules\user\http\middleware\account-subscription.middleware.js.map'
```
At first I thought that no breakpoints work at all. So I watched youtube, read docs and tested in a small project that my config is ok, `.vscode/launch.json`
```
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "App1",
            "type": "node",
            "request": "attach",
            "port": 9229,
            "localRoot": "${workspaceFolder}/docker-nest-debug/",
            "remoteRoot": "/app/"
        }
    ]
}
```
With this config a small app on Nestjs can be debugged in docker.  
`Makefile`
```
build:
	docker-compose build

up:
	docker-compose up -d

install:
	docker-compose exec app1 npm i

debug:
	docker-compose exec app1 npm run start:debug
```
`docker-compose.yml`
```
version: '3'
services:
  app1:
    container_name: app1
    tty: true
    image: node:14
    volumes:
      - .:/app
    ports:
      - 3000:3000
      - 9229:9229
```
Though debug succeded with test project, it failed with the actual one from work. Why?    

In VSCode several times I looked at 'What scripts and sourcemaps are loaded' in 'Debug doctor'. It is accessed when you hover on a gray dot on breakpoint line.  
And at some point I noticed something weird, **two files in one folder had different status**.

```
url
file:///app/dist/api/src/modules/user/http/quard/auth.guard.js
sourceReference
527852774
absolutePath
\\wsl$\Ubuntu20.04LTS\home\xxxx\xxxx_repos\xxxx\api\dist\api\src\modules\user\http\quard\auth.guard.js
absolutePath verified?
❌ Disk verification failed (does not exist or different content)
sourcemap children:
referenced from sourcemap:
None (not from a sourcemap)
```

```
url
file:///app/dist/api/src/main.bootstrap.js
sourceReference
1208731873
absolutePath
\\wsl$\Ubuntu20.04LTS\home\xxxx\xxxx_repos\xxxx\api\dist\api\src\main.bootstrap.js
absolutePath verified?
✅ Verified on disk
sourcemap children:
../../../src/main.bootstrap.ts → main.bootstrap.ts (#373026932)
referenced from sourcemap:
None (not from a sourcemap)
```

One available for debug and one not. How can it be I wondered?  

## Inline source map
I started experimenting with options in `tsconfig.json` and when I changed
```
"sourceMap": true,
```
To
```
"inlineSourceMap": true,
```
the miracle happened.  

All files were loaded into debugger. And all breakpoints worked.  
I suppose that it took some time to read additional files (source map files) and at some point VSCode just dropped it and reported me an error.  
When I changed the option in `tsconfig.json` debugger was reading only files being executed and found source maps in them, and VSCode didn't drop this activity because of slow I/O.  
But it's only my guess. 

## Conclusion
Now, I'm working with repositories only in WSL.  
I open terminal and have precious Linux tools for my command and applications run fine in docker.  
Yes, IDE works slower, it takes time for all extensions to 'scan' a project, linters may report errors because they didn't load all files yet.  

For now it works, of course it would be better to have more confidence that it is all about WSL2 slow I/O for Windows apps.

Hope this text helped somebody :)

UPD: [Just run VsCode in WSL and enjoy life again](./2022-11-12-develop_in_wsl_2.md)