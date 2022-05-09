// =================
// weed node - grows other weeds
/obj/structure/necromorph/weeds/node
	name = "weed sac"
	desc = "A weird, pulsating purple node."
	max_integrity = 60
	var/node_icon = "minigrowth"
	/// list of all potential turfs that we can expand to
	var/node_turfs = list()
	/// How far this node can spread weeds
	var/node_range = 4
	/// What type of weeds this node spreads
	var/obj/structure/necromorph/weeds/weed_type = /obj/structure/necromorph/weeds

/obj/structure/necromorph/weeds/node/Initialize(mapload, obj/structure/necromorph/weeds/node/node)
	var/swapped = FALSE
	for(var/obj/structure/necromorph/weeds/W in loc)
		if(W != src)
			W.swapped = TRUE
			swapped = TRUE
			qdel(W) //replaces the previous weed
			break
	. = ..(mapload, node, swapped)

	// Generate our full graph before adding to SSweeds
	node_turfs = filled_turfs(src, node_range, "square")
	SSweeds.add_node(src)
	swapped = FALSE

/obj/structure/necromorph/weeds/node/set_parent_node(atom/node)
	CRASH("set_parent_node was called on a /obj/structure/necromorph/weeds/node, node are not supposed to have node themselves")

/obj/structure/necromorph/weeds/node/update_overlays()
	. = ..()
	add_overlay(node_icon)
