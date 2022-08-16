/datum/corruption_node
	/// con for an overlay applied to parent
	var/overlay_icon = 'necromorphs/icons/effects/corruption.dmi'
	/// icon_state for an overlay applied to parent
	var/overlay_icon_state = "minigrowth"
	/// Amount of corruption we can keep
	var/remaining_weed_amount = 25
	/// How far can we spread corruption
	var/control_range = 5
	/// Icon we've added as an overlay
	var/icon/overlay
	/// Corruption we are bound to in real world
	var/obj/structure/corruption/parent

/datum/corruption_node/New(obj/structure/corruption/new_parent)
	if(!new_parent)
		CRASH("Tried to spawn a corruption node without parent in real world.")
	SScorruption.nodes += src
	new_parent.set_master(src)
	parent = new_parent
	overlay = iconstate2appearance(overlay_icon, overlay_icon_state)
	new_parent.add_overlay(overlay)
	RegisterSignal(new_parent, COMSIG_ATOM_BREAK, .proc/on_parent_break)
	.=..()

/datum/corruption_node/proc/on_parent_break(obj/structure/corruption/source)
	SIGNAL_HANDLER
	qdel(src)

/datum/corruption_node/Destroy()
	SScorruption.nodes -= src
	parent.cut_overlay(overlay)
	parent = null
	.=..()

//Shouldn't be used outside of testing
/obj/structure/corruption/node
/obj/structure/corruption/node/Initialize(mapload, datum/corruption_node/new_master)
	for(var/obj/structure/corruption/corruption in loc)
		if(corruption == src)
			continue
		new /datum/corruption_node(corruption)
		return INITIALIZE_HINT_QDEL
	new_master = new /datum/corruption_node(src)
	.=..()
