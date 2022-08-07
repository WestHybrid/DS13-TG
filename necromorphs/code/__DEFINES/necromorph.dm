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
#define INIT_ORDER_NECROMORPH		32
#define INIT_ORDER_DECAY			26

// Subsystems Fire
#define FIRE_PRIORITY_DECAY			37

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
#define SPECIES_NECROMORPH "necromorph"
#define SPECIES_NECROMORPH_DIVIDER "divider"
#define SPECIES_NECROMORPH_DIVIDER_COMPONENT "divider_component"
#define SPECIES_NECROMORPH_SLASHER "slasher"

#define SPECIES_NECROMORPH_SLASHER_ENHANCED "enhanced_slasher"
#define SPECIES_NECROMORPH_SPITTER "spitter"
#define SPECIES_NECROMORPH_PUKER "puker"
#define SPECIES_NECROMORPH_BRUTE "brute"
#define SPECIES_NECROMORPH_EXPLODER "exploder"
#define SPECIES_NECROMORPH_EXPLODER_ENHANCED "enhanced_exploder"
#define SPECIES_NECROMORPH_TRIPOD "tripod"
#define SPECIES_NECROMORPH_HUNTER "hunter"
#define SPECIES_NECROMORPH_INFECTOR "infector"
#define SPECIES_NECROMORPH_TWITCHER "twitcher"
#define SPECIES_NECROMORPH_LEAPER "leaper"
#define SPECIES_NECROMORPH_LEAPER_ENHANCED "enhanced_leaper"
#define SPECIES_NECROMORPH_LEAPER_HOPPER "hopper"
#define	SPECIES_NECROMORPH_LURKER "lurker"
#define SPECIES_NECROMORPH_UBERMORPH "ubermorph"


//Graphical variants
#define SPECIES_NECROMORPH_BRUTE_FLESH "brutef"
#define SPECIES_NECROMORPH_SLASHER_DESICCATED "slasher_ancient"
#define SPECIES_NECROMORPH_SLASHER_CARRION "slasher_carrion"
#define	SPECIES_NECROMORPH_LURKER_MALO "lurker_malo"

#define SPECIES_NECROMORPH_PUKER_FLAYED "puker_flayed"
#define SPECIES_NECROMORPH_PUKER_CLASSIC "puker"

#define SPECIES_NECROMORPH_EXPLODER_ENHANCED_RIGHT "enhanced_right_exploder"
#define SPECIES_NECROMORPH_EXPLODER_ENHANCED_LEFT "enhanced_left_exploder"
#define SPECIES_NECROMORPH_EXPLODER_RIGHT "right_exploder"
#define SPECIES_NECROMORPH_EXPLODER_LEFT "left_exploder"

#define NECRO_DEFAULT_VENT_ENTER_TIME 4.5 SECONDS //Standard time for a necromorph to enter a vent.
#define NECRO_DEFAULT_VENT_EXIT_TIME 2 SECONDS //Standard time for a necromorph to exit a vent.

#define NECROMORPH_CAN_VENT_CRAWL (1<<0)
#define NECROMORPH_CAN_HAVE_ID (1<<1)
