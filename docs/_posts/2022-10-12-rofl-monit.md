---
layout: post
title: "Rofl-monit and my thoughts on DDD"
date:   2022-10-12 12:16:02 +0300
tags: portfolio typescript
---

[**rofl-monit**](https://github.com/funduck/rofl-monit) -- monitoring for docker containers.
Watch the demo!
![](/assets/rofl-monit-demo.gif)

This project is mostly an exercise for me and my goal was to try as much DomainDrivenDesign as I can. So I had "Vernon Vaughn - Implementing Domain-Driven-Design" on my table during the work and here are my thoughts afterwards.

## Code structure
I like the **code structure** application-domain-infra-interface and **objects hierarchy** value-entity-aggregate-event. It took extra time to understand what is the rights place for everything but in the end I have quite clean code with very few connections between modules and dependencies flow down from most abstract to most concrete things.

## Domain services
It's been hard to decide when to make an Entity and a DomainService and when to make a more complicated Aggregate that emrbaces the Entity.  
I have Observables - docker containers, and several signaling strategies for them. Observable is an Entity, and signaling strategies I represented as DomainServices, so the application only chooses which ones to launch.  
Still I'm not sure about this approach because signaling strategies need to store some "marks" on Observable. I just added these marks to Observable and load/save it every time something happens, so many domain services use ContainerRepository and it doesn't look right. May be signaling strategy should be an Aggregate with these marks in it. That would eliminate the problem with one repository for many services.

## Events in domain
My domain services subscribe for events and can emit them. Subscription is done in applications. And it makes the system very flexible. It is enough to change the subscription parameters and filters to change the behavior of the system. 
But.  
First "but" is debugging. It is more complicated as the books warned me.  
Second "but" is that all my code is syncronous. Of course it is my choice of implementation, but if I want to make it asyncronous I need queues everywhere for subscribers or I'll lose the order of events and it will break the logic. Anyway for this project syncronous handling of events is fine.

## Repository
When code needs and Entity it loads it from repository and if some modifications are done saves it. It makes the code look like it has transactions and it is good. I have no connections between services or entities so they can't unpredictably change each other.  
I dont use any database in the project so I dont get too much drawback but there is cloning on every load and save. In a project with database one should optimize the number of accesses to entity.

## Coding principles
Writing this project I had a feeling that I'm doing something wrong. Implementing DDD patterns is cool but it felt like I made some unnecessary work.  
I definitely broke the YAGNI and KISS principles. In the core of a project I have now a prototype of a ddd framework. Well, everytime I write a program there is a temptation to write "your own framework".  

## Finally
I will definitely use some of the principles that helped me to decouple things:
* keeping things consise: avoiding references between modules, objects in the domain
* domain: separating abstract things without dependencies to more concrete
* interface to domain: docker adapter or UI or telegram bot or any other kind of interaction with the world
* application: a bridge between interfaces and domain