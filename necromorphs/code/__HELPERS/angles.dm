GLOBAL_LIST_INIT(dir_angles, list(
		"[NORTH]" = 0,
		"[NORTHEAST]" = 45,
		"[EAST]" = 90,
		"[SOUTHEAST]" = 135,
		"[SOUTH]" = 180,
		"[SOUTHWEST]" = 225,
		"[WEST]" = 270,
		"[NORTHWEST]" = 315))

#define DIR2ANGLE(dir) GLOB.dir_angles[#dir]

//Checks if target is within arc degrees either side of a specified direction vector from user. All parameters are mandatory
//Rounding explained above
/proc/target_in_arc(var/atom/origin, var/atom/target, var/vector2/direction, var/arc)
	origin = get_turf(origin)
	target = get_turf(target)
	if (origin == target)
		return TRUE

	var/vector2/dirvector = direction.Copy()
	var/vector2/dotvector = get_new_vector(target.x - origin.x, target.y - origin.y)
	dotvector.SelfNormalize()
	.= (round(dirvector.Dot(dotvector),0.000001) >= round(cos(arc),0.000001))
	release_vector(dotvector)
	release_vector(dirvector)

//This proc returns all turfs which fall inside a cone stretching Distance tiles from origin, in direction, and being angle degrees wide
/proc/get_cone(var/turf/origin, var/vector2/direction, var/distance, var/angle)

	if (!istype(direction))
		direction = Vector2.FromDir(direction)	//One of the byond direction constants may be passed in

	angle *= 0.5//We split the angle in two for the arc function

	if (!istype(origin))
		origin = get_turf(origin)


	var/list/turfs


	//If the angle is narrow enough, we can reduce the number of tiles we need to test

	if (angle <= 90)
		//First of all, lets find a centre point. Halfway between origin and the edge of the cone
		var/turf/halfpoint = locate(origin.x + (direction.x * distance * 0.5), origin.y + (direction.y * distance * 0.5), origin.z)

		//And from this halfpoint, lets get a square area of turfs which is every possible turf that could be in the cone
		//We use half the distance as radius, +1 to account for any rounding errors. Its not a big deal if we get some unnecessary turfs in here
		turfs = RANGE_TURFS(((distance*0.5) + 1), halfpoint)

	else
		//Optimisation
		turfs = RANGE_TURFS(distance, origin)

	//Alright next up, we loop through the turfs. for each one:
	if (angle < 360)
		for (var/turf/T as anything in turfs)
			//1. We check if its distance is less than the requirement. This is cheap. If it is...
			var/dist_delta = get_dist_euclidian(origin, T)
			if (dist_delta > distance)
				turfs -= T
				continue

			//2. We check if it falls within the desired angle
			if (!target_in_arc(origin, T, direction, angle))
				turfs -= T
				continue
	else
		//Optimisation for 360 degree circles, a common use case. We can skip the arc math
		for (var/turf/T as anything in turfs)
			//1. We check if its distance is less than the requirement. This is cheap. If it is...
			var/dist_delta = get_dist_euclidian(origin, T)
			if (dist_delta > distance)
				turfs -= T
				continue


	//Alright we've removed all the turfs which aren't in the cone!
	return turfs
