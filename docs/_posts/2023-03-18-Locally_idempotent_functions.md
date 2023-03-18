---
layout: post
title: "Locally_idempotent_functions"
date: 2023-03-18T09:12:40UTC
tags: 
---
# Locally idempotent functions
Suppose a function may be called several times almost simultaneously and it should always return the same result.  
Would you like to save computational time and execute that function only once whenever it is possible?  
Sure!  
Especially if it is a heavy operation like index rebuild or a file reload.
Basically this is what this article.

    How to save computational resources if repeated calls to function make no difference

## Local idempotence
Here I am talking about some special kind of functions.  
A formal definition can be:  

    If function F
    * has no arguments
    * any number of calls to F overlapping in time give same result
    then F can be called locally idempotent

So once again, everything below is for *locally idempotent* functions only.

We have one more definition to make.  
### Simultaneous
Next lets define what we mean by *simultaneous calls*.  
In Nodejs a good take is
```
Two events in same event loop tick can be considered simultaneous
```
For example simultaneous (in real world) calls to REST server will execute endpoint resolvers in same tick. This is actually the key idea to bear N+1 problem for GraphQL but that's another story :)

Great, we are ready to write some code!

## Regular function
For now we have a function **F** and we want it to execute its body maximum once in loop tick no matter how many times it is called.  
Lets make a wrapper that returns the desired function
```TypeScript
function makeIdempotent<Result>(f: () => Result) {
    const idempotentF = function(): ReturnType<typeof f> {
        const promiseKey = '__idempotent_promise__';
        if (idempotentF[promiseKey] == undefined) {
            idempotentF[promiseKey] = f();
            // In next tick we clear cached results
			queueMicrotask(() => {
				idempotentF[promiseKey] = undefined;
			})
        }
        return idempotentF[promiseKey];
    }
    return idempotentF;
}
```
Done!
But what if **F** returns `Promise`? Is one tick enough?

## Async function
Lets think.  

**Synchronous** function ends in same loop tick when it is called.  
So *simultaneous* for synchronous functions means that they start and end in same tick. Fair enough.  

However **asynchronous** functions may end in different tick they start.  
Suppose `f` runs for `N` ticks, then should we execute it again until `N+1`'s tick?  
No, if `f` confirms to my definition of *locally idempotent* result will be same so why run it again?  
Until `f` resolves or rejects we should receive same `Promise` if we call `f` repeatedly.
```TypeScript
function makeIdempotent<Result>(f: () => Result) {
    const idempotentF = function(): ReturnType<typeof f> {
        const promiseKey = '__idempotent_promise__';
        if (idempotentF[promiseKey] == undefined) {
            idempotentF[promiseKey] = f();
            if (idempotentF[promiseKey] instanceof Promise) {
                // After promise is resolved we clear cached promise
                idempotentF[promiseKey].then(() => {
                    idempotentF[promiseKey] = undefined;
                }, (error) => {
                    idempotentF[promiseKey] = undefined;
                })
            } else {
                // In next tick we clear cached results
                queueMicrotask(() => {
                    idempotentF[promiseKey] = undefined;
                })
            }
        }
        return idempotentF[promiseKey];
    }
    return idempotentF;
}
```
Cool.  
But...  
What if **F** is a class method?

## Class method
We should write a decorator that applies `makeIdempotent` to class method.
```TypeScript
function MakeIdempotent(target: any, propertyName: string, descriptor: PropertyDescriptor) {
    // we use Symbol to hide the key in class instance
    const MakeIdempotentClassKey = Symbol(propertyName);

    const originalMethod = descriptor.value!;

    descriptor.value = function () {
        // We assign cached function to class instance
        // because different class instances should have their own instances of wrapped function
        if (!this[MakeIdempotentClassKey]) {
            this[MakeIdempotentClassKey] = makeIdempotent(() => originalMethod.apply(this))
        }
        return this[MakeIdempotentClassKey]();
    }
}
```

## Finally a real life example that inspired all of this
In my case I had a class that managed search index.
```TypeScript
class SearchIndexService {
  getIndex(): Promise<SearchIndex>
  buildIndex(): Promise<SearchIndex>
}
```
If index doesn't exist `getIndex` calls `buildIndex` but nothing prevents several calls to run in parallel.  
So I added a protection with `@MakeIdempotent`
```TypeScript
class SearchIndexService {
  getIndex(): Promise<SearchIndex>

  @MakeIdempotent
  buildIndex(): Promise<SearchIndex>
}
```
Thanks for reading!