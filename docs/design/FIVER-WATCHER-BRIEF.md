# Fiver / Watcher — user brief

Received 2026-09-21. Working direction, not a claim that every feature is implemented. Original notes follow.

## Changes
Let’s make the following changes based on research on other games and discussion forums etc and also plan it out and iterate on it to ensure it’s high quality and looks great:
1. 
1. Add afterimage based on speed. This way users can visually kind of tell where other players are if they’re moving very fast. Also ensure that Movemen speed changes the FOV slightly so the user can feel the speed. (maybe evne have some POV speed lines to some degree, non distracting)
2. FIx arm animation when in ball form. Right now in 3rd person, the arms just look like lines as it’s charging. Try to make the animation less weird looking.
3. Remove punch damage for now. Also make it so when you punch someone, they will be knocked away. if you are close to them, you will also be knocked away. This can help your friend gain speed too.
4. Punch animation. Lets make it a bit more interesting as the player charges it. It should visibly have feedback. And max charge should make ti shake a bit maybe

5. Lets make it so when the user punches a wall, we have some temporary imprint on the wall or something to give the map some life. So it feels like we can leave marks on the world and intract with it.
6. Ceiling walk mode: Later described. But basically pressing 1 toggles between armwalk mode and regula rmode. armwork mode makes it so both arms aren’t attached at the same time for more than 0.3s. the idea is the user would use right arm for example on the ceilling, then left arm, and the right arm will auto detatch and then they woul use the right arm again to kind of walk the ceiling. The arm length will also be reduced to be a fixed 5m or something so it’s easy to walk. There should be some visual indicator that it’s on armwalk mode for the user using it.
7. If arms are out, LC + RC will pull them both back instead of immediately punching. This way the user can lc + rc to reset their arms together. 
8. Potentially important and big change: When the player is zooming quickly through the map, if they use one or two of the arms to stick to a surface, they should be able to use that to redirect their speed. Right now, we can use the sticky hands to gain elastic energy and fling the other way. but we also want ot ensure that the user is able to attach to a column for example and maintain the speed and translate it to spinning around the column to direct it elsewhere. Similarly if a player is falling quickly, if they stick their hands to an edge, and fall beneath it, they can translate that falling speed to sideways speed and so on, as long as are on fixed arm mode (recall that we have regula rarm mode, and armwalk mode, armwalk mode should actually be named something like fixed arm mode that allows for walking but also 1 handed fixed distance speed translation etc) THis way both the arms mode has value. One has a way to translate momentum into elastic energy to rediretc backwards. The oter one has the ability to translate momentum into angula rspeed or whatever. You can figur eit out. Look into both overwatch’s hamster hero and speed runner’s grappling ability for inspiration




## Tutorial map ﻿Let’s also make a tutorial map. This will be separate enclosed spaces to teach the user each of the abilities. Make the guidance minimal. We don’t need to baby sit them but just tell them the ability and their keybind


Tutorial map: WASD + jump. Just let them walk around. to move to anothert area (that requires a jump and moving). Then this next area makes it so they need to left click/right click a high ground area then press F to reel themselves in to reach high ground. Then the user needs to move forward and drop down. They need to left click or right click a ball to have it stick to their hand, then drag it into another area by reeling it in or sometihng. Then they need to slingshot over to the next section. I.e. theres 2 pillars and they need to use it to slingshot over a big gap that can’t be crossed with just reeling since the ceilings are too high to reach. Then theres dmumies there that they need to punch to knock down. Then they need to punch the ground to reach the next area. Then they need to anchor as they walk past a cooridor that has things that knock them over, but anchoring makes it so you can’t be moved or punched around. Then maybe we make it so they need to gain a certain speed by using ground slingshot or something. and then give them a tip that they can redirect the speed by slingshotting on the ground and quickly turning but we dont need to test them on that. Then we have them ceiling walk maybe. Anyways the tutorial can be redesigned in any order. The goal is to get the user familiar with all the actions even if they can’t do it well yet. Try to make it so the tutorial is clean, kind of like a testing range in the matrix kind of look maybe? Simple actions. We check to see if they’re more or less doing the actions in the code or something? We keep it simple and the goal is really just to teach them. We may not even need to check if they done each thing fully successfully. Also we can have different rooms if we’d like. Think of how other games introduce many mechanics in a tutorial lets follow in their footsteps




## Overall gameplay
The goal of the game will eventually be that Fivers, aka the current player robots, need to complete tasks while the watcher tries to stop them by killing them and delaynig them) The Fivers are quick, nimble, and hard to hit and can get around quickly while the watcher is confined to towers most of the time but with incredible firepower and zoning capabilities. They can sometimes join as an imposter robot but only effective when the other robots comms and sight is weakened. Fivers will have 100 hp and takes damage from various sources but lets make all the damage sources weak for now.
ivers don’t die but take 20s to respawn. In our testing mode, they can just respawn in 3s.


## Fiver controls


Fiver Ctrls:
WASD + space = movement
LC / RC = Sticky Hand
LC + RC = punch
LC + RC (hold + release) = charge punch
Shift = crouch / anchor (drop to the ground immediately, and immovable, takes 50% damage)
F = reel arms in
E = release slingshot
1 = toggle armwalk mode (auto release arm after 0.3s of launching the other arm, arms shorted to 5 m) 
2 = toggle punch vs instapull mode (the old one where it launches them in parallel and immediately and quickly pulls the player to the spot like spiderman. 


High Five = two players left or right click at each other, full Heals and required for a task. 




## Map deisgn formulated
The map Ideally I will design manually for parts of it. Ideally you can make it into a map maker or make it easier for me to design maps with you. I can offboard some aspetcs but i feel like i have specific visions. Whats the best way for me to collaborate with you for map design. But anyways thats for later, for now, I want to formalize the map features: (We dont need to include all of them, but we want ot make sure we have the right vocabulary and context of the things we may want to include.


Map features:
1. Obstacles 
   1. Speed bump gates (hologram gates that slow momentum (requires jumping over it)
   2. Laser Rivers (fall in the cracks on bottom floor, take high damage must escape quickly)
   3. Laser Sweeps on floors (Jump it or take damage)
   4. Arm disablement zones. (keeps momentum but can’t use arms. Very dangerou sif lose momentum in area.)
   5. Leg disablement zones. (Walking is completely disabled. Must use arms to move)
   6. Crushing zones (giant hydrualid presses, squished = take huge damage)
2. Regular map features
   1. Ramps, Floors, pillars, mazes, Platforms, Nooks, Walls, Ceilings, Automatic doors
3. Powerups:

   1. Speed boost, Punch chargerate/speed/power, invisibility, anti-disablement, toughness (take less dmg), max charge

4. Tasks:
   1. Team Ring points (passing through rings of different difficulties) 
   2. Collection tasks (need 1 arm to bring an object to one of the collection zones)
   3. High five stations (Need 2 players to high five at certain locations)
   4. Maintanence task (Typically high up in the map, in the nooks. Play minigame to finish)
   5. Target Dummies (Need to KO abunch of target dummies on the map)


Some goals of the map is: We want there to be like 4-7 towers across the map for the purposes of of the watcher to switch between and monitor and attack the fivers. We want these towers to look ominous, like the eye of sauron tower. But they are part of the maps geometry and weave nicely into the maps design. The map shoudl feel intentional overall. I’m thinking maybe we’d have a tower in the center of the map very high up, then 4 towers on each quadrant? 
The map should have plenty of blindspots for the fivers but going from area to area should generally have lots of opportunites for the fiver to attack either directly with mouse or indirectly with Q or W when they need to fire around a wall or something. For testing purposes, the player can switch to the watcher to test it out. bc right now we’re just making a testing map where the player tries out both sides. 
The map should have big thick walls that other structures are built around. Smaller walls and maybe platforms. Some ramps. Some jump pads, some launch pads. The ceiling shoudl also be interesting. SOme near ceiling platforms, some walls that are only from the ceiling so players can tuck behidn them to hide from view in certani locations on the ceiling from the watchers etc. The map should be open enough for the watcher to generally see alot  but noth everything. As a rule of thumb as an estimate, the watcher across all their towers should be able to see maybe 70% of the map. But individually they should only see like 30% of the map or soemthing. i’m just estimating. For now, lets get rid of the disablement zones we can add them later. And powerups lets make it so they exist in dangerous areas that are very visible to the towers. And make them appear every 30s after being taken. Also they are temporary boost .no more permanent stats ever. Let’s also have special regions across the map that is kind of like a shrine or some kind of intentional area that has a little bit of coverage to do the tasks. Have lots of floor to ceiling pillars for lots of opportunies for people to sling shot. Lets only have 1 maze section. Let’s add lots of cooridors. DOn’t be afraid to add lots of walls. We can always add more watcher towers to increase coverage. maybe like if we have 7 towers then maybe they still add upt o 70-80% but each one would only contribut elike 20% of the vision/ idk just think about it. Do some deep research on waht type of map design we’re doing and how to design it in a cool way. Think of itlike a tron style arena. 


## Watcher controls


Watcher Ctrl:
1/2/3/4/5/6/7 or A/D switch between towers. 
RC hold = scope —> LC = sniper 
LC = heavy MG (high spread)
Q = Lob bouncing grenade
W = Brand W (Very delayed but big)
E = Cut off power (no comms or lights besides hand lights)
R = Full Auto mode: For a few sec, all towers use full capabilities and do 100% damage.
S =  come out of current tower as imposter robot. High fiving will cause the other player to die. Enter a tower to return as tower mode. Imposter robot can also self destruct after 10s of being completely statoinary (kamekaze). 


let’s make the watcher feel very powerful and destructive. Use good visual assets either generated or created carefully and iterated.


## Overall feel of the game
Dynamics: 
- Watcher typically scouts the map raining fire on zones that Fivers have tasks with

- Watchers when com and light disable is active, they may want to become a robot, and try to either self destruct near someone or high five someone as an imposter
- Watcher’s current tower has a full range of weapons but when a watcher isn’t using a tower, it’s on autopilot mode. They do use basic Ais and do 50% damage.

- Watchers see the task progress of the players to hvae an idea of where to watch for. 

- Fivers could also punch the eye of the towers to make them reduce visibility for a while
- Fivers need to maintain speed and agility to be a difficult target. They need to find blindspots and coordinate movements to overload the watcher. 
- When coms and lights are cut, fivers need to have an idea of where their teammates are. And be suspicious of behaviors of the imposter
- Fivers need to efficiently do their tasks, while staying connected to each other to heal up and do group tasks.  




This game is intended to play as a manhunt-style fly swatting game. WHere the flys are trying to complete tasks while zooming around with lots of mobility options. The flies must coordinate on occasion. The Fly swatter (watcher) is loaded with increidble power but is restainted to unmoving towers. They have the option to take away the senses of the fivers and join them as an imposter, where seemingly innocent actions can kill. 


FOr now though, since we aren’t doing multiplayer, we really want the map to be beautiful and contrusted in a way that realyl compliements the skillset of the fivers. Their ability to slingshot, ceilingwalk with arms, bunny hop and cover big distances and punch ground to make huge leaps. etc. We want it to be enclosed enough suhc that the user isn’t just in an open field most of the time but open enough that the users can buid up speed without constantly runnning into walls. We want the platsforms asnd walls ot feel cohesive and part of a nice design. WE want the lighting to look cool. We want it to look polished and tron like. The fivers experience moving therough the map is the core gameplay righ tnow. we must get this buttery smooth and addictive.

  