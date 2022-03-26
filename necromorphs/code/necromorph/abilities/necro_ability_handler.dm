/datum/component/necro_ability_handler
	var/list/datum/action/action_buttons = list()
	var/list/component_types = list()
	var/list/element_types = list()

/datum/component/necro_ability_handler/Initialize(list/list/abilities)
	var/mob/living/carbon/holder = parent
	for(var/path in abilities)
		if(ispath(path, /datum/action))
			var/list/params = list(null)
			params += abilities[path]
			var/datum/action/button = new path(arglist(params))
			action_buttons += button
			button.Grant(holder)
		else if(ispath(path, /datum/component))
			component_types += path
			holder.AddComponent(path, abilities[path])
		else if(ispath(path, /datum/element))
			element_types += path
			holder.AddElement(path, abilities[path])

/datum/component/necro_ability_handler/Destroy(force, silent)
	var/mob/living/carbon/holder = parent
	for(var/datum/action/button as anything in action_buttons)
		qdel(button)
	for(var/type in component_types)
		qdel(GetComponent(holder, type))
	for(var/type in element_types)
		holder.RemoveElement(type)
	.=..()
