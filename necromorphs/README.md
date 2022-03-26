
https://github.com/Skyrat-SS13/Skyrat-tg/pull/<!--PR Number-->

## Title: DS13 Port

MODULE ID: <!-- uppercase, underscore_connected name of your module, that you use to mark files-->

### Description:
DS13 TG Project
Preliminary Design Document 
Introduction
DS13 is a codebase dedicated to the lore of the popular horror action game Dead Space. Introducing features such as new game modes based around an artifact known as the Marker.  

The goal of this project is to port many of the unique features from the Baystation Code / DS13 project to the TG Codebase. And create a base to allow the DS13 the ability to rebase if they decide to, while allowing other TG Based servers access to new content. 
SkyRat - Goals

The initial creation of the project was an attempt to port basic Necromorph carbons and Mobs from DS13 to TG for use in a Dead Space event under development. It was determined shortly after beginning that many systems not currently available to TG would be required in order to have necromorph mobs function properly and with support for limb dismemberment (A primary focus of necromorphs in Combat and in Lore) 

By the completion of this project, it will be assumed the following features are functional and useable in a production environment. 
Player controllable Necromorph Mobs complete with Limb Dismemberment and functional abilities.
Player controllable Marker Overmind, similar to that of a blob overmind for use in game modes or admin triggered/created events. 
A new multi-department engine that players can use to power the station with large energy output and high risk. Utilizing the Marker as a power source. 
Multi-Limb Mob’s have the ability to split upon death or break into individual entities during combat. See “Tripod” for an example.
TBD - Gamemodes: The implementation of a basic Marker-based game mode designed to trigger a necromorph event on the station. Allowing for the use of the Marker Player Entity and subsequent features. 
Private Necromorph Hive Communication Channel
New Vent layer with custom graphics to simulate crawling through vents. No longer do you see just pipes!

Necromorphs
Hivemind Language 
Necromorphs need a method of communication between each other and the marker / signals.
UI / HUD
Biomass
Limb Dismemberment
Individual limb health and stats for Arms, Legs and Head. When enough limbs are removed, the creature “Dies” 
Limbs can also be removed with Kinesis module, and utilized as a weapon against them. 
Do we need Limb Height. See human_organs.dm
Need a better system to control individual limb icons, either removing icons on limb destruction or using a mask. At the moment, our system is very modular for standard races, but the nature of necromorphs requires more fine control. As they are also a different sprite size. 
Damage Overlay Mask
We have Blood Overlays available
We also have damaged Limbs Available.
I would like an override, to let us control each individual limb slots sprite, and allow for an overlay mask to add “X” number of extra limbs to them. In many cases, this would be tentacles.
Child Limbs and Body Parts for creatures such as the Divider. They split into multiple smaller mobs upon death. Their limbs are the mobs.
Abilities
See Necromorphs
Basic Abilities
Dodge
Slash
Projectile
Passive Healing
Biomass Values
Sound Effects
Need individual autocue functions. Cues are utilized in everything from footprints, mob ambiance, attack variations, pain variations, communication, effects.
Random Sound Effects



Sound Triggers
Attack
Miss
Aggro
Emote
Scream
Shout
Say
Death
Pain
Life
Ambiance
Footstep
Breathing
Random Trigger



Variants
Slasher
Brute
Hunter
Leaper
Lesser
Lurker
Puker
Spitter
Tripod
Twitcher
Ubermorph
Divider
Exploder
Infector

TBD - Balance
Ventcrawl
Wallcrawling
TBD - Potential Updates
Can update necromorphs to utilize our greyscale limb feature, allowing for customization of necromorphs. 
Sprites
Need the ability to offset limbs for species given the variation in sizes for necromorphs
Need the ability to parent limbs to other limbs for mobs like the splitter. 
Limb Masking or removal for the dismemberment system. Ideally these sprites need alot of limb manipulation and bodyparts. The more control we allow, the more interactive they can be. 
Need Single Icon / Icon-state override for mobs that are not piecemeal. 
Need the ability to add custom limb icons beyond our standard species. Many of these mobs have tentacles, tails and other limbs.
Var easily enables AI processing on Mobs in events where players are lacking. Giving basic ability control and response. 
Marker / Signal

The marker and Signal on DS13 appear to be controlled utilizing the vine / hydroponics system in the code. We are going to attempt to recreate this utilizing TG Blob code as to provide a more standardized system and utilize existing code. We feel many of these features can be recreated with less work utilizing this system. 

There will be many things that need to be updated to support all of the features. 

Utilize blob code to create the initial functionality for marker interaction.
Blob could be possible, but need to determine if it’s a good long-term solution. As it is very janky. 
Spells
Biomass
Growth / Corruption (Structures)
Naturally produces a growth similar to blobs. On this growth structures can be created to help in the aid of defense and necromorph spawning. 


Bioluminescence
Cyst
Eye
Growth
Harvester
Maw
Nest
Snare

Marker Activation
Markers typically have an activation timer that randomly begins after “X” amount of time. Starting the Necromorph spawning. I would like to bring this feature, as well as creating a new method of player directed activation when trying to use the marker as an energy source. 
Necromorph Spawning


Unitologist
DS13 - Goals 


This project would also provide a strong framework for the Dead Space 13 development team to switch from the outdated variation of baycode that they have been utilizing. Providing them with an updated and maintained codebase with many new features and performance changes. 

← Too be added / adjusted by members of the DS13 Team →



Considerations
In moving assets and code from Bay-code to TG-Code, many of the existing scripts will need to be reimplemented to properly function. This will require a lot of re-writing of existing scripts and/or redesigning how prior features function in the new development state. 
Vector2
One potential constraint that may be seen is the adaptation and implementation of the Vector2 Library used in the animation and control of Necromorphs and related assets. This being a root-level code adjustment, may require more communication and discussion with not just the members of this team, but the Upstream Developers at /TG/. At this time, it is unlikely this feature would be able to be modularized following our current standards. 
Marker / Signal Observer Eye
After reviewing the functionality of the Marker and Signal’s system, it is believed this feature can be recreated through the utilization of existing code, following the design of the “Blob Overmind” event. 
Necromorphs
In order for Necromorphs to function the way they are designed mechanically in the Dead Space series, the only way to properly eliminate a necromorph is to remove all of its limbs. This would require a dedicated system for limb dismemberment that is connected to mob health. Limbs appear to be added to mobs utilizing the Vector2 library mentioned prior. 

It would need to be determined if this method is still feasible or a new system would need to be designed to allow for this function. 
Mechanical Balance
This will be a long-term area of development to properly balance necromorphs to the new fast passed combat system that TG is designed around. 
Overmap
To the benefit of the DS13 team, this feature has been in active development for some time now, with functionality confirmed. 

Kinesis
*NEEDS POPULATION*
Object Mass
Object Interactability



Medical
The medical system in baycode, is far more indepth and advanced then the current medical system in use for TG. Design consideration will need to be taken into account as the playstyle of each codebase is significantly different. Flavor wise, it would be easy to add extra information for medical in terms of appearance. Anything beyond that would likely want to be PR’d upstream at TG for maximum compatibility but because of the gameplay style, it is likely to encounter resistance. We will need to discuss a method of handling this system. 
Potential Solutions
Kinesis: 
With the introduction of the new MODsuit mechanic from /TG/ Station, there is a discussion that a similar system may already be in development. Saving a large amount of required time and resources to recreate what is considered to be a difficult mechanic implemented on DS13.

Constraints / Limitations

Impact
Describe the potential impacts of the design on overall performance, security, and other aspects of the system.

Alternatives
If there are other potential solutions which were considered and rejected, list them here, as well as the reason why they were not chosen.



Glossary - TG Content / Code

Links
https://tgstation13.org/wiki/Main_Page
https://github.com/Skyrat-SS13/Skyrat-tg
https://github.com/tgstation/tgstation

Glossary - DS13 Content / Code

Links
https://github.com/DS-13-Dev-Team/DS13
https://ds-ss13.com/index.php/Main_Page
Machinery
Asteroid Cannon
Objects


Structures


DS13 - Mechanics
Kinesis 
Limb Dismemberment
Necroque
Necroshop
Necrochat
Biomass
Intent Modes
Gamemodes
Containment
The most common game mode in rotation. The crew of the USG Ishimura has uncovered an ancient alien artifact while on an illegal dig on Aegis VII, and are getting ready to make their final trip back to deliver the cargo. Since its arrival on board, some crew have been plagued with nightmares, hallucinations and psychotic episodes. Crew have gone missing. And before anyone has time to react, the ship goes into alert. Departments must defend their personnel and hold off the abominations the Marker has brought on board.
Marker/Necromorph objectives are usually a small selection of the following:
Spread corruption using nodes and other tools at your disposal while attacking the crew.
Absorb biomass from dead crew.
Influence the unitologists on board using your fellow signals.
Coordinates necromorphs to attack certain locations on the ship, act as a strategic command and control center.
Game Ending Conditions:
When all crew are deceased or off the ship.
If the Marker has summoned an Ubermorph or higher or all crew are deceased or absorbed, the Necromorphs win.
If any crew manage to escape the Ishimura alive, the crew wins.
Enemy Within
A spin on the Containment gamemode, instead of bringing the Marker on board, it resides on the Aegis VII colony. When it was found, miners broke off several shards of the Marker obelisk for study or for personal keeping, and are now under the Marker's influence. The Unitologists must protect and hide their shards in order to summon the powers of the Marker, spread corruption and sacrifice their fellow crewmembers for the sake of convergence.
Game Ending Conditions:
When all crew are deceased or off the ship.
If the Marker has summoned an Ubermorph or higher or all crew are deceased or absorbed, the Necromorphs win.
If any crew manage to escape the Ishimura alive, the crew wins.
If all the Shards have been disposed of or destroyed, Unitologists lose.
 
Defend the Block
Courage. Compassion. Stability. EarthGov are liars.
 
Scenario Five
If you're watching this film, it means despite our every precaution, containment has become a necessity. It is now up to us to make the ultimate sacrifice for the safety of the Sovereign Colonies we have sworn to protect. We understand we cannot expect one hundred percent compliance.




Factions
Unitologist 
See: https://ds-ss13.com/index.php/Unitologist%27s_Guide
Unitologist Terrorism 101
Congratulations, you're an operative from the Church of Unitology! You've stealthily integrated yourself into the crew of the Ishimura along with two other Operatives as part of a directive from the Church on Titan Station. You are motivated to act as an antagonist and create turmoil on the Ishimura. Before you bust out the fire axe and go on a murderous rampage, you might want to get up to speed with the Rules, and make sure that whatever devious schemes you have planned for the crew don't cause you to have fun at the expense of someone else's fun. First things first, you'll want to come up with some sort of backstory for your character and familiarize yourself with the core reasons your character is on board, and create a plan so you're not just randomly welderbombing hallways. Below are some key things to remember.
You are not crazy. You aren't immediately a psychotic killer hell-bent on allowing the Marker to take over the ship. You will need to work your character's sanity up to that before you start acting like one of the criminally insane. You can also choose to remain sane the entire duration of the round. Sometimes treating all your actions, however horrible, as rational choices is even scarier than a crazed man with a chainsaw.
The Church of Unitology is a massive organization with many groups under its umbrella and many threads to pull on. Your character could be a member of the saboteurs trained within the Church, or they could be someone coerced into helping the Church by force. Either way, you're there to do the Church's bidding, and eventually, the Marker's.
The main goal you were tasked with by the Church was to spy on and acquire evidence of a new Marker. When the dig teams bring one back onto the Ishimura, you know this is an affront to the Church and that it should be brought back to them as soon as possible. Already, the crew are an obstacle.
Unitologists are highly discriminated against by EarthGov personnel. If you're spying on the Ishimura, chances are EarthGov is sending people to spy on you. If they find you, it won't be pretty.
You have a wide range of options, tools and backgrounds at your disposal. You don't have to play the same way every time. If you're worried what you're doing might be breaking the rules, ask an Admin or consult this guide.
Unitology as a religion does not automatically mean an individual is a Uni Operative. Some people aboard the Ishimura may be Unitologists, but not the violent kind. It's important to understand that difference.
Adminhelping and making sure that you have an effective plan and that you aren't just randomly murdering people is always a good idea. For example, if you wish to play as a Unitologist assassin, you should adminhelp and have an admin send a transmission, warning your victim that a potential threat on their life is imminent. Even then, capturing them and explaining why the Church wants them dead is always a better idea than just whipping out a grenade launcher and incinerating your victim in the middle of the cantina. If you're planning on doing something bad, always think if your action is logical and justifiable, and isn't just something you're doing for your own self-satisfaction. Being an Operative is to make the round more fun for everyone, not just yourself.
Objectives
The USG Ishimura is a very large ship with several holes you can punch in its defenses. While you may not be able to break apart every faculty the ship has, you have several options.
The Asteroid Defense Sentry (ADS) serves as a large railgun held at the top of the ship on the EVA deck, protecting from oncoming rubble produced by the planet cracking. Damaging this system will give cause for engineers to repair it, and also open up the Ishimura to hull damage and power loss.
The VIP Escape Shuttle located on the crew deck is the largest available evacuation craft aboard the Ishimura. While the shuttle has a difficult process of launching already, throwing a bomb into the mix wouldn't necessarily be a bad idea. Venting the shuttle bay could also keep crew without RIGs from reaching safety.
The Ishimura is equipped with Escape Pods on both the Crew Deck and the Operations Deck, typically in batches of two to three pods. Damaging these areas, locking and frying the doors, or finding ways to launch the pods early without the crew inside of them are all good prospects.
More systems are being added as development to DS13 goes on, and we'll have several more options such as the Gravity Centrifuge, Mining Tether and Life Support System for you to sabotage.

Necromorph Faction
See: https://ds-ss13.com/index.php/Necromorph
Marker
How it Works
Markers in all Game Modes are player-controlled. Players can Ghost and become Signals, ghost-like mobs that act as eyes, ears and whisperers for the Marker. In both of the main game modes, Containment and Enemy Within, the Marker will activate after a set time.
Whether the Marker spawns on the Aegis VII colony or in the Ishimura's secure holding warehouse, the result is the same. The Marker will activate after a set duration, allowing the crew to get comfortable. When it activates, Corruption will begin spreading from the base of the Marker. At this point, a Signal is selected as the Master Signal.
The Master Signal controls the Marker and all of its "spells," and effectively becomes the leader of the Necromorph Horde. It can spawn nodes for spreading corruption, defenses such as flesh walls and cysts, maws that can devour and absorb biomass, and nests that can spawn necromorphs in an automated fashion.
Playing Marker
The general path of action of the Marker:
Join as a Signal and wait to be selected.
If selected, begin spreading corruption. Familiarize yourself with the tools you have. Spawn necromorphs.
Tell your Signals to inform the Unitologist crew what you want their objectives to be.
Spawn necromorphs, corruption, defenses and whatever else necessary to achieve your goals.
Kill all crew for the convergence.
Fulfill your objectives.
Signal
 
Signal Abilities
Name
Psi Cost
Description
Absorb
6
Absorbs a piece of biological matter, claiming some biomass for the Marker. The item to be absorbed must be located within Corruption.
Flicker
10
Causes a targeted light to flicker.
Bloody Scrawl
15
Write a message in blood.
Bloody Rune
15
Creates a spooky rune. Has no functional effects, just for decoration.
Scry
20
Reveals a targeted area in a 6 tile radius for a duration of 1 minute. Creates a spooky ethereal glow.
Whisper
30
Allows you to broadcast a subliminal message into the mind of a receptive target. Can be used on anyone visible, or on Unitlogists remotely.
Please remember that subliminal messages are in-character communication. You are a spooky voice in their head that they might be imagining. No memes or encouraging direct grief.
Bioluminesence
40
This node is effectively an organic lightbulb. It illuminates an 8 tile radius with a soft orange glow, allowing people (namely necromorphs) to see where they're going in the dark.
Flicker, Mass
50
Causes all lights in an area to flicker.
Repossess
50
Separates the target necromorph from their controlling signal, causing them to become an inert vessel once more that can be possessed by any other signal.
Good for use in cases of a necromorph player going AFK.
Hardened Growth
60
This node acts as a defensive wall, blocking movement and vision on the tile it's placed. It can stall attackers but is not very durable, and easily can be overcome with hand tools. Useful for blocking paths or creating traps.
Blowout
70
Destroys a target wall light, with an explosion of sparks. Be careful overusing this ability, as Necromorphs need light to see, too.
Lock
80
Triggers localised biohazard sensors in a door, causing ti to bolt shut for two minutes. This is quite visible and audible, sure to cause a panic. The door will unbolt again after that period, though it can also be used manually through wire hacking or excessive damage.
After it wears off, the same door cannot be affected again for four minutes.
Breaching Growth
100
Breaching Growth allows you to slowly break open an airlock by having corruption force it with repeated hits. This takes quite a long time to work, generally 5-10 minutes. It will be cancelled if anyone opens the door or removes corruption around it, but any damage dealt will remain.
Psychic Tracer
120
Plants a psychic tracer on a target mob, causing them to act as a visual relay for necrovision. This allows signals to see in a radius around them. This can last up to ten minutes, but it will expire faster the more human crewmembers are near the target. Visual radius will gradually dwindle as the duration runs out.
Casing it again on a target who already has tracer will referesh the duration and range.
Frantic Growth
125
Creates an impassible object to block a tile. This is almost identical to hardened growth, except it is far mroe expensive, and it can be placed on tiles that are currently visible to crew.
Frantic Growth can allow signals to construct a quick screen behind which other things can be placed, buying a precious few seconds of time to mount a defense.
Gaze
150
This node is effectively an organic camera, a smaller version of the Eye node. It moderately increases the view range of the necrovision network by 8 tiles.
In addition, it will notify all necromorph players when it sees a living human.
Finally and most significantly, all eye nodes will keep track of every living human they see, storing that information centrally in the Prey Sightings menu. This can be used by all necromorphs to direct and coordinate hunting efforts.
Branch
150
This node acts as a smaller source for corruption spread, allowing it to extend out up to 6 tiles in all directions from the node. It must be placed on existing corruption from another propagator node, or from the Marker.
Root
150
This node acts as a specialized source for corruption spread, it has a massive radius of 40 tiles, and grows 3 times as fast as normal.H However, it has a limit of 50 on the number of corruption tiles it can support, which is far less than other nodes would normally get.
Root is optimized for snaking corruption through long, narrow spaces, like maintenance corridors. It will not perform well if placed in any open space like a large room. Generally, Root should be used in areas that are only 1-2 tiles wide.
Cyst
180
The Cyst is a stationary defense emplacement, which must be mounted on a wall or similar hard surface. It detects any non-necromorph movement along a straight line in front of itself, and launches its payload blindly in that direction. It will be triggered by thrown objects, but not by anything a necromorph is dragging along the ground.
The payload is an unstable organic bomb which will explode on impact, dealing heavy damage. A direct hit could deal up to 50 damage total, with a bit under half of that dealt to other targets near the epicenter. The damage dealt is a combination of brute force damage from direct impact, melee burn damage, and chemical burn damage from acid splashing on the victim. It is very difficult to fully defend against, but acid-resistant gear will reduce damage significantly.
Assault Resonance
500
*Movespeed: +15%.
Attack Speed: +15%.
Evasion: +5%.
Max Health: +15%.
The energy cost is realtively cheap, and the effect lasts for three minutes. However, there are two major caveats. It only affects currently existing necromorphs, and once used, it has a long cooldown of 15 minutes.
Biohazard Lockdown
1000
Triggers a biohazard alert in the targeted area, causing an automated isolation lockdown. All the doors in and out of the target room will be bolted shut, trapping anyone inside.
Best used to combine with a necromorph assault, preventing the escape of human victims, and forcing them to fight to the death. This effect lasts for three minutes, but only if there is a live necromorph in the room. If there is none, the lockdown duration is halved.




Necromorphs
The Marker is capable of summoning any and all Necromorphs currently available dependent upon how much biomass it has accumulated.
Necromorphs are the player-controlled main antagonists of DS13 and are the largest threat to the safety of the Ishimura. As the crew of the USG Ishimura unwittingly brings the Red Marker on board their ship, crew start to have vivid nightmares, auditory hallucinations, and symptoms of dementia. Some have even been reported missing. Unbeknownst to the crew, the Marker is capable of absorbing the crew's biomass and converting them into horrible abominations with only one goal: Kill them all.
 
How to Play
The most important take-away that we try to instill in Necromorph players is this: You are expendable. Your biomass will be reclaimed upon death, so you can send in as many necromorphs you want as cannon fodder and do your best to mindlessly attempt to kill the Crew. Death is no longer a shackle to you. Obviously if you're a necromorph with weaker health and defense, play to your strengths, but do not concern yourself with prioritizing your own life over devouring the lives of the crew.
 
If you want to play Necromorph, you will start as a Signal. Signals are player-controlled extensions of the Marker that can fly around the map, use light abilities, and keep the Marker appraised of what is going on during the round. During this time, all Signals who opt in for it are put into a Queue. The Necroqueue is a system in place where if the Marker spawns a necromorph, the next Signal in line is directly spawned into that Necromorph.
 
In addition, any unoccupied or abandoned necromorph can be possessed by a signal using verbs in the Necromorph tab.
 
Once you're in a Necromorph, review your abilities, ask about your hotkeys, and get to work. Break down defenses as a brute, melt armor as a Puker, or if you're lucky, become a immortal Ubermorph and strike some fear into the crew.
 
Above all else, listen to the Marker. It will guide your way.
 
 
Abilities
Name
Biomass Cost
Description
 Slasher
60
The frontline soldier of the necromorph horde. Slow when not charging, but it's blade arms make for powerful melee attacks.
Abilities: Charge, Dodge.
 Enhanced Slasher
150
The frontline soldier of the necromorph horde, but much more deadly. Slow when not charging, but it's blade make for powerful melee attacks.
Abilities: Charge, Dodge.
 Spitter
55
A midline skirmisher with the ability to spit acid at medium range. Works best when accompanied by slashers to protect it from attacks. Weak and fragile in direct combat.
Abilities: PASSIVE: No Friendly Fire, PASSIVE: Crippling Acid, Snapshot, Long Shot
 Lurker
50
Long range fire-support. The lurker is tough and hard to hit as long as its retractable armor is closed. When open it is slow and vulnerable, but fires sharp spines in waves of three.
Abilities: PASSIVE: Wallcrawling, Retractable Shell, Spine Launch
 Leaper
85
A long range ambush unit, the Leaper can leap on unsuspecting victims from afar, knock them down, and tear them apart with its bladed tail. Not good for prolonged combat.
Abilities: PASSIVE: Wallcrawling, Leap, Tailstrike, Gallop
 Exploder
40
An expendable suicide bomber, the exploder's sole purpose is to go out in a blaze of glory, and hopefully take a few people with it.
Abilities: Charge, Explode
 Puker
130
A tough and flexible elite who fights by dousing enemies in acid, and is effective at all ranges. Good for crowd control and direct firefights.
Abilities: PASSIVE: Corrosive Vengeance, PASSIVE: Eyeless Horror, PASSIVE: Crippling Acid, Vomit, Snapshot, Long Shot
 Twitcher
130
An elite soldier displaced in time, blinks around randomly and is difficult to hit. Charges extremely quickly.
Abilities: PASSIVE: Temporal Displacement, Charge, Step Strike
 Brute
350
A powerful linebreaker and assault specialist, the brute can smash through almost any obstacle, and its tough frontal armor makes it perfect for assaulting entrenched positions. Very vulnerable to flanking attacks.
Abilities: PASSIVE: Tunnel Vision, PASSIVE: Organic Plating, Charge, Slam, Bio-Bomb, Curl
Divider
150
A bizarre walking horrorshow, slow but extremely durable. On death, it splits into five smaller creatures in an attempt to find a new body to control. The divider is hard to kill and has several abilities which excel at pinning down a lone target.
The Head after separating has the ability to inhabit the nervous system and chest cavity of a decapitated human being, revitalizing the nerves and taking control of the host.
Abilities: PASSIVE: Gestalt Being, PASSIVE: Strange Anatomy, PASSIVE: Momentum, Swipe, Execution: Tounguetacle
Tripod
350
A heavy skirmisher, the tripod is adept at leaping around open spaces and fighting against multiple distant targets. Does not operate well in close spaces.
Abilities: PASSIVE: Personal Space, PASSIVE: Cadence, High Leap, Arm Swing, Toung Lash, Execution: Kiss of Death
Ubermorph
1600
A juvenile hivemind. Constantly regenerating, a nigh-immortal leader in the necromorph horde.
Abilities: PASSIVE: Immortal, Regenerate, Lunge, Battlecry, Sense




Structures
The Marker can place certain structures at its will as long as it has the required amount of biomass. Placing structures is just as important as spawning necromorphs, as it will bolster your base and allow you to gain even more biomass.


Structure
Biomass Cost
Description


Cyst
5
The Cyst is a stationary defense emplacement, which must be mounted on a wall or similar hard surface. It detects any non-necromorph movement along a straight line in front of itself, and launches its payload blindly in that direction. It will be triggered by thrown objects, but not by anything a necromorph is dragging along the ground.
The payload is an unstable organic bomb which will explode on impact, dealing heavy damage. A direct hit could deal up to 50 damage total, with a bit under half of that dealt to other targets near the epicenter. The damage dealt is a combination of brute force damage from direct impact, melee burn damage, and chemical burn damage from acid splashing on the victim. It is very difficult to fully defend against, but acid-resistant gear will reduce damage significantly.


Eye
10
This node is effectively an organic camera. It massively increases the view range of the necrovision network by 20 tiles.
In addition, it will notify all necromorph players when it sees a live human.
Finally, and most significantly, all eye nodes will keep track of every living human they see, storing that information centrally in the Prey Sightings menu. This can be used by all necromorphs to direct and coordinate their hunting efforts.


Propagator
10
This node acts as a heart for corruption spread, allowing ti to extend up to 12 tiles in all directions from the node. It must be placed on existing corruption from another propagator node, or from the Marker.


Maw
8
The maw is a simple and useful node with two functions.
Firstly it acts as a corpse disposal location for Necromorphs. Maws will slowly devour any human corpses brought within a 2 range, sending their biomass on to the Marker. This means that bodies don't need to be dragged as far.
Secondly, the maw acts as a floor trap. Any non-necromorph who walks over it will fall in and get stuck, forced to gradually work their way out while it takes bites out of them. This will usually not prove fatal to a healthy crewmember, but the time it holds them for can be enough for necromorphs to arrive and cut them down.


Nest
30
The nest node is vital for a forward base, as it provides an additional spawn point, allowing the Marker to create new necromorphs at its location, thus cutting down travel times. In addition, the nest can be upgraded with a Spawner, allowing it to automatically generate low-tier necromorphs for Signal possession.


Harvester
50
This is a large base-defense node that can be placed to serve two purposes, the first being that it can easily defend spawns from damage by flinging any crew who get close to it in the opposite direction with its appendages. The second purpose is to harvest biomass, by placing them in key areas where biomass is generated; the Morgue, Cryogenics, the Bio-Prosthetics Lab and Hydroponics.




<!-- Here, try to describe what your PR does, what features it provides and any other directly useful information -->


### TG Proc/File Changes:

- N/A
<!-- If you had to edit, or append to any core procs in the process of making this PR, list them here. APPEND: Also, please include any files that you've changed. .DM files that is. -->

### Defines:

- N/A
<!-- If you needed to add any defines, mention the files you added those defines in -->

### Master file additions

- N/A
<!-- Any master file changes you've made to existing master files or if you've added a new master file. Please mark either as #NEW or #CHANGE -->

### Included files that are not contained in this module:

- N/A
<!-- Likewise, be it a non-modular file or a modular one that's not contained within the folder belonging to this specific module, it should be mentioned here -->

### Credits:
All assets present in this module unless otherwise stated are taken from the talented development team over at : https://github.com/DS-13-Dev-Team/DS13 : Please take the time to check them out, there work is beautiful. 
<!-- Here go the credits to you, dear coder, and in case of collaborative work or ports, credits to the original source of the code -->


