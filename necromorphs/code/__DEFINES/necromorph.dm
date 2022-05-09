// Darkvision Levels these are inverted from normal so pure white is the darkest
// possible and pure black is none
#define DARKTINT_NONE      "#ffffff"
#define DARKTINT_POOR  		"#cccccc"
#define DARKTINT_MODERATE      "#aaaaaa"
#define DARKTINT_GOOD			"#8C8C8C"
#define DARKTINT_EXCEPTIONAL	"#666666"


// Colors
#define COLOR_KINESIS_INDIGO	"#4d59db"
#define COLOR_KINESIS_INDIGO_PALE	"#9fa6f5"

#define COLOR_NECRO_YELLOW		"#FFFF00"
#define COLOR_NECRO_DARK_YELLOW		"#AAAA00"
#define COLOR_MARKER_RED		"#FF4444"
#define COLOR_HARVESTER_RED		rgb(255,68,68,128)
#define COLOR_BIOMASS_GREEN		"#82bf26"
#define COLOR_BIOLUMINESCENT_ORANGE "#ffb347"


// Subsytems
#define SS_INIT_NECROMORPH			4

// Subsystems Fire
#define FIRE_PRIORITY_WEED			11

//Faction strings
#define FACTION_NECROMORPH	"necromorph"
#define ROLE_NECROMORPH "necromorph"

//Spawning methods for things purchased at necroshop
#define SPAWN_POINT		1	//The thing is spawned in a random clear tile around a specified spawnpoint
#define SPAWN_PLACE		2	//The thing is manually placed by the user on a viable corruption tile

#define NECROMORPH_ACID_POWER	3.5	//Damage per unit of necromorph organic acid, used by many things
#define NECROMORPH_FRIENDLY_FIRE_FACTOR	0.5	//All damage dealt by necromorphs TO necromorphs, is multiplied by this
#define NECROMORPH_ACID_COLOR	"#946b36"

//Minimum power levels for bioblasts to trigger the appropriate ex_act tier
#define BIOBLAST_TIER_1	120
#define BIOBLAST_TIER_2	60
#define BIOBLAST_TIER_3	30



//Errorcodes returned from a biomass source
#define MASS_READY	"ready"	//Nothing is wrong, ready to absorb
#define MASS_ACTIVE	"active"//The source is ready to absorb, but it needs to be handled carefully and asked each time you absorb from it
#define MASS_PAUSE	"pause"	//Not ready to deliver, but keep this source in the list and check again next tick
#define MASS_EXHAUST	"exhaust"	//All mass is gone, delete this source
#define MASS_FAIL	"fail"	//The source can't deliver anymore, maybe its not in range of where it needs to be



#define CORRUPTION_SPREAD_RANGE	12	//How far from the source corruption spreads
#define MAW_EAT_RANGE	2	//Nom distance of a maw node


//Biomass harvest defines. These are quantites per second that a machine gives when under the grip of a harvester
//Remember that there are often 10+ of any such machine in its appropriate room, and each gives a quantity
#define BIOMASS_HARVEST_LARGE	0.04
#define BIOMASS_HARVEST_MEDIUM	0.03
#define BIOMASS_HARVEST_SMALL	0.015

//This is intended for use with active sources which have a limited total quantity to distribute.
//Don't allow infinite sources to give out biomass at this rate
#define BIOMASS_HARVEST_ACTIVE	0.1

//Not for gameplay use, debugging only
#define BIOMASS_HARVEST_DEBUG	10

//Items in vendors are worth this* their usual biomass, to make them last longer as sources
#define VENDOR_BIOMASS_MULT	5

//One unit (10ml) of purified liquid biomass can be multiplied by this value to create one kilogram of solid biomass
#define REAGENT_TO_BIOMASS	0.01

#define BIOMASS_TO_REAGENT	100



//#define PLACEMENT_FLOOR	"floor"
//#define PLACEMENT_WALL	"wall"

//Necromorph species
#define SPECIES_NECROMORPH 	"Necromorph"
#define SPECIES_NECROMORPH_DIVIDER 	"Divider"
#define SPECIES_NECROMORPH_DIVIDER_COMPONENT 	"Divider Component"
#define SPECIES_NECROMORPH_SLASHER 	"Slasher"

#define SPECIES_NECROMORPH_SLASHER_ENHANCED 	"Enhanced Slasher"
#define SPECIES_NECROMORPH_SPITTER	"Spitter"
#define SPECIES_NECROMORPH_PUKER	"Puker"
#define SPECIES_NECROMORPH_BRUTE	"Brute"
#define SPECIES_NECROMORPH_EXPLODER	"Exploder"
#define SPECIES_NECROMORPH_EXPLODER_ENHANCED	"Enhanced Exploder"
#define SPECIES_NECROMORPH_TRIPOD	"Tripod"
#define SPECIES_NECROMORPH_HUNTER	"Hunter"
#define SPECIES_NECROMORPH_INFECTOR	"Infector"
#define SPECIES_NECROMORPH_TWITCHER	"Twitcher"
#define SPECIES_NECROMORPH_LEAPER 	"Leaper"
#define SPECIES_NECROMORPH_LEAPER_ENHANCED 	"Enhanced Leaper"
#define SPECIES_NECROMORPH_LEAPER_HOPPER	"Hopper"
#define	SPECIES_NECROMORPH_LURKER	"Lurker"
#define SPECIES_NECROMORPH_UBERMORPH	"Ubermorph"


//Graphical variants
#define SPECIES_NECROMORPH_BRUTE_FLESH	"BruteF"
#define SPECIES_NECROMORPH_SLASHER_DESICCATED "Ancient Slasher"
#define SPECIES_NECROMORPH_SLASHER_CARRION	"Carrion Gestalt"
#define	SPECIES_NECROMORPH_LURKER_MALO	"Malo"

#define SPECIES_NECROMORPH_PUKER_FLAYED	"Flayed One"
#define SPECIES_NECROMORPH_PUKER_CLASSIC	"Classic Puker"

#define SPECIES_NECROMORPH_EXPLODER_RIGHT	"Right Wing Exploder"
#define SPECIES_NECROMORPH_EXPLODER_ENHANCED_RIGHT	"Enhanced Right Wing Exploder"
#define SPECIES_NECROMORPH_EXPLODER_CLASSIC	"Classic Exploder"


#define SPECIES_ALL_NECROMORPHS SPECIES_NECROMORPH,\
SPECIES_NECROMORPH_SLASHER,\
SPECIES_NECROMORPH_SLASHER_ENHANCED,\
SPECIES_NECROMORPH_SPITTER,\
SPECIES_NECROMORPH_PUKER,\
SPECIES_NECROMORPH_BRUTE,\
SPECIES_NECROMORPH_EXPLODER,\
SPECIES_NECROMORPH_BRUTE_FLESH,\
SPECIES_NECROMORPH_TWITCHER,\
SPECIES_NECROMORPH_LEAPER,\
SPECIES_NECROMORPH_LEAPER_ENHANCED,\
SPECIES_NECROMORPH_LURKER,\
SPECIES_NECROMORPH_UBERMORPH

//Put this into any necromorph definition which is just a graphical change from its parent species.
//These flags make sure that variant doesn't appear in places it shouldn't
#define NECROMORPH_VISUAL_VARIANT	marker_spawnable = FALSE;\
spawner_spawnable = FALSE;\
always_customizable = FALSE;\
variants = list();

#define STANDARD_CLOTHING_EXCLUDE_SPECIES	list("exclude", SPECIES_NABBER,SPECIES_ALL_NECROMORPHS)
#define SIGNAL	"signal"


//Mode
#define MODE_MARKER "marker"
#define MODE_UNITOLOGIST "unitologist"
#define MODE_UNITOLOGIST_SHARD "unitologist_shardbearer"

#define BP_L_FOOT "l_foot"
#define BP_R_FOOT "r_foot"
#define BP_L_LEG  "l_leg"
#define BP_R_LEG  "r_leg"
#define BP_L_HAND "l_hand"
#define BP_R_HAND "r_hand"
#define BP_L_ARM  "l_arm"
#define BP_R_ARM  "r_arm"
#define BP_HEAD   "head"
#define BP_CHEST  "chest"
#define BP_GROIN  "groin"
#define BP_TAIL   "tail"
#define BP_UPPER_BODY	list(BP_CHEST, BP_HEAD, BP_L_ARM, BP_R_ARM, BP_L_HAND, BP_R_HAND)	//Everything above the waist
#define BP_LOWER_BODY	list(BP_GROIN, BP_L_LEG, BP_R_LEG, BP_L_FOOT, BP_R_FOOT, BP_TAIL)	//Everything below	 the waist
#define BP_ALL_LIMBS list(BP_CHEST, BP_GROIN, BP_HEAD, BP_L_ARM, BP_R_ARM, BP_L_HAND, BP_R_HAND, BP_L_LEG, BP_R_LEG, BP_L_FOOT, BP_R_FOOT, BP_TAIL)
#define BP_BY_DEPTH list(BP_HEAD, BP_L_HAND, BP_R_HAND, BP_L_ARM, BP_R_ARM, BP_L_FOOT, BP_R_FOOT, BP_L_LEG, BP_R_LEG, BP_TAIL,  BP_GROIN, BP_CHEST)
#define BP_OVERALL	"overall"	//A special value that means "target everything evenly"

// Defines mob sizes, used by lockers and to determine what is considered a small sized mob, etc.
#define MOB_LARGE  		40
#define MOB_MEDIUM 		20
#define MOB_SMALL 		10
#define MOB_TINY 		5
#define MOB_MINISCULE	1

// Defines how strong the species is compared to humans. Think like strength in D&D
#define STR_VHIGH       2
#define STR_HIGH        1
#define STR_MEDIUM      0
#define STR_LOW        -1
#define STR_VLOW       -2

#define MOB_PULL_NONE 0
#define MOB_PULL_SMALLER 1
#define MOB_PULL_SAME 2
#define MOB_PULL_LARGER 3



#define WALLRUN_DESC	"<h2>PASSIVE: Wallcrawling:</h2><br>\
This necromorph is capable of crawling along walls, over the heads of other creature. Simply move into a wall to climb onto it.<br>\
 While crawling on a wall, the necromorph gains +15% movespeed and +10% evasion."



#define SHARED_COOLDOWN_SHOT	(1.5 SECONDS)


//Takes a speed in metres per second, and outputs delay in deciseconds between each step to achieve that
#define SPEED_TO_DELAY(speed) (10/speed)
