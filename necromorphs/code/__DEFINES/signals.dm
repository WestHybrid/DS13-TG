#define COMSIG_ATOM_MARKER_ACT "atom_marker_act"
	/// if returned, forces nothing to happen when the atom is attacked by a blob
	#define COMPONENT_CANCEL_MARKER_ACT (1<<0)

///Resting position for living mob updated
#define COMSIG_LIVING_UPDATED_RESTING "living_updated_resting" //from base of (/mob/living/proc/update_resting): (resting)

#define COMSIG_LIVING_WEEDS_AT_LOC_CREATED "living_weeds_at_loc_created"	///from obj/structure/necromorph/weeds/Initialize()
#define COMSIG_LIVING_WEEDS_ADJACENT_REMOVED "living_weeds_adjacent_removed"	///from obj/structure/necromorph/weeds/Destroy()

// turf signals
#define COMSIG_TURF_WEED_REMOVED "turf_weed_removed"
