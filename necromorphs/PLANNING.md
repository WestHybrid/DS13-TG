
## ICONS TO ADD ##
* CEC Logo
* CEC Paperwork
* NT Logo
* NT Paperwork
* Unitology Logo
* Paperwork
* Marker Symbols.
* Biohazard Lockdown
* Quarantine Lockdown
* Station Alert: Quarantine
* Specimen Tube : Small - Large
* Biotube


Antagonists
* Unitologist
* Marker
* Necromorph
* AI Marker
* ERT
	* SolGov
	* Purge Squad
* ADD Alarm sounds, sirens, and warning lights that flash.

#TODO
-  Finish Single Icon option for Necromorphs
-  Finish Necromorph Outfits
-  Fix the offset of Necromorphs
-  Add necromorph organs and tentacles
-  Add Dismemberment
	-  Kinesis support to remove limbs
	-  Necromorphs die if all limbs are removed
-  Biomass Needs its own system all organic objects have biomass

- Replace /datum/extension with /datum/component

- Flavor Items
	- Newscaster Reports
	- Paperwork / Documents
	- Logos
	- New Clothing

-  Necromorphs
	-  Abilites Update to Datum Components 
		-  Actions
		-  Passives
	-  Sounds
		-  Ambient Sounds
		-  Attack Sounds
	-  Wallrun
	-  Ventcrawling
		- Time to make bigger vents ideally with support for people climbing.
		- Global Var to Enable people ventcrawling
		- Faction Checker to enable vent crawling
	-  Biomass
	-  Dismemberment
		-  Death on limb removal 
		-  Splitting support 
			-  Splitter
			-  Divider
		-  Kinesis Removal
	-  Link to Master
	-  Organs
		-  Tentacles
	-  Sprite
		-  Icon Offset
		-  Animations
		-  Iconstates
			-  Dead
			-  Laying
			-  Mutilated
			-  Removed Limbs
	-  Simple Mobs

-  Abilities
	-  Need to adjust /datum/extensions to /datum/action

The marker has three current locations in this file. There is a variation in mob/dead/observer/freelook/marker
The other two are stored in code/modules/antagonists
Need to decide which version we want to utilize. 
The gamemode is just there to activate the marker and set tracking for necromorphs. The marker should only be able to activate on station z-level and by random chance or by player interaction. 

- Marker Gamemode (Player Controlled)

	- Link the Gamemode Marker to the Blob Marker Core, When active, the marker should act as the blob core and continue.  It shouldnt just appear like blob can. It requires the machine/obj form to trigger, the AI Core can have more options. The player controlled should be more of a gamemode then random event. 
		- On activation whether by the timer, or by admin, it should poll ghost to find someone to be the master. If no master can be found, then it should remain dormant resetting its activation timer. 
		- Requires spawn points on map creation, whether it can spawn as one of the following
			- Lavaland Loot
			- Station Storage
			- Station Engine
			- Cargo Crate
			- Shard Spawn
			- Construction
		- Needs to be able to move before activation.
			- Once activated it is anchored and can no longer move.

	-  Marker[Master] (Player)
		-  Need to finalize all marker extra structures
		-  Need Necroshop
			- Structures
			- Upgrades
			- Necromorph Spawning
		-  Needs abilities
		-  Needs Signals
		-  Blob Code
			-  Needs to be refactored specifically for Necromorph Master
			-  Remove all prior reference to blob.
			-  Biomass generation 
	
		- Engine Variation Status
			- Containment
			- Power Generation
			- Required
				- R&D
					- Can operate the activation and management tools.
				- Engineering
					- Can build the containment system.
			- Causes hallucinations.
		
		- Admin Controls
			- Activate
			- Deactivate
			- Toggle Activation Timer
			- Set Timer
				- Adjust Timer
			- Change Biomass
			- Max number of Necromorphs

		- Refactor / Remove
			- Remove all reference to multiple blob strains and blobs from the marker. The marker does not need the functionality of blobstrains nor does it need that hard coded it. The controller should act regardless of any future variations of the marker.

	-  Corruption / Growth
		-  Mechanics
			-  Movement Slowdown
			- Necromorph Spawn points
		-  Sprites
			-  Need to add animation to the sprite. 
			-  Need damaged states.
			-  Needs Edge state overlay.
			-  Needs wall state overlay
			-  Need vent, door overlay.
			-  Need to add slow opacity forming
			-  Need to add early stage vine- like growth
		-  Sounds
			-  Growth Sounds
		- Statistics
			- Growth Tracking
			- Structure Tracking


-  Marker (AI)
	-  Need to finalize all marker extra structures
	- Create Marker shard version, that can trigger a minor outbreak similar to the blob core setup now. 


- SPRITES
	- MOBS
		- NECROMORPHS
			- Brute
				- Needs individual limbs
				- 
	- STRUCTURES
		- MARKER
		- CORRUPTION
			- Growth (Animated)
				- Wall
				- Door
				- Vent
				- Variants
					- Heavy Growth
					- Normal Growth
					- Light Growth
					- Seeding

	- OBJECTS
	- ITEMS
	- EFFECTS
