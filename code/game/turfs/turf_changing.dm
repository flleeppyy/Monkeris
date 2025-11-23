/turf/proc/ReplaceWithLattice()
	src.ChangeTurf(get_base_turf_by_area(src))
	new /obj/structure/lattice(locate(src.x, src.y, src.z))

// Removes all signs of lattice on the pos of the turf -Donkieyo
/turf/proc/RemoveLattice()
	var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
	if(L)
		qdel(L)

//Creates a new turf
/turf/proc/ChangeTurf(new_turf_type, force_lighting_update)
	ASSERT(new_turf_type)

	var/old_density = density
	var/old_opacity = opacity

	// This makes sure that turfs are not changed to space when one side is part of a zone
	if(new_turf_type == /turf/space)
		force_lighting_update = TRUE
		var/turf/below = GetBelow(src)
		if(istype(below) && (TURF_HAS_VALID_ZONE(below) || TURF_HAS_VALID_ZONE(src)))
			new_turf_type = /turf/open

	var/old_dynamic_lighting = dynamic_lighting
	var/list/old_affecting_lights = affecting_lights
	var/old_lighting_overlay = lighting_overlay
	var/list/old_lighting_corners = corners

	if(connections)
		connections.erase_all()

		//Yeah, we're just going to rebuild the whole thing.
		//Despite this being called a bunch during explosions,
		//the zone will only really do heavy lifting once.
		var/turf/S = src
		if(S.zone) // Remove the 'S.' ? --KIROV
			S.zone.rebuild()

	var/turf/new_turf = new new_turf_type(src)
	if(istype(new_turf, /turf/floor))
		new_turf.RemoveLattice()
		new_turf.fire = fire
		fire = null
	else if(fire)
		fire.RemoveFire()

	if(new_turf.is_simulated)
		SSair.mark_for_update(src)

	new_turf.levelupdate()
	. =  new_turf

	for(var/turf/neighbour in RANGE_TURFS(1, src))
		if(istype(neighbour, /turf/space))
			var/turf/space/SP = neighbour
			SP.update_starlight()
		else if(neighbour.is_simulated)
			neighbour.update_icon()
	if(SSlighting && SSlighting.initialized)
		lighting_overlay = old_lighting_overlay
		affecting_lights = old_affecting_lights
		corners = old_lighting_corners
		if((old_opacity != opacity) || (dynamic_lighting != old_dynamic_lighting) || force_lighting_update)
			reconsider_lights()
		if(dynamic_lighting != old_dynamic_lighting)
			if(dynamic_lighting)
				lighting_build_overlay()
			else
				lighting_clear_overlay()
	new_turf.update_openspace()
	GLOB.turf_changed_event.raise_event(src, old_density, density, old_opacity, opacity)

/turf/proc/transport_properties_from(turf/other)
	if(!istype(other, src.type))
		return 0
	src.set_dir(other.dir)
	src.icon_state = other.icon_state
	src.icon = other.icon
	src.overlays = other.overlays.Copy()
	src.underlays = other.underlays.Copy()
	src.opacity = other.opacity
	if(hasvar(src, "blocks_air"))
		src.blocks_air = other.blocks_air
	if(other.decals)
		src.decals = other.decals.Copy()
		src.update_icon()
	return 1

//I would name this copy_from() but we remove the other turf from their air zone for some reason
/turf/transport_properties_from(turf/other)
	if(!..())
		return 0

	if(other.zone)
		if(!src.air)
			src.make_air()
		src.air.copy_from(other.zone.air)
		other.zone.remove(other)
	return 1

// Make a new turf and put it on top
// The args behave identical to PlaceOnBottom except they go on top
// Things placed on top of closed turfs will ignore the topmost closed turf
// Returns the new turf
/turf/proc/PlaceOnTop(list/new_baseturfs, turf/fake_turf_type, flags)
	var/area/turf_area = loc
	if(new_baseturfs && !length(new_baseturfs))
		new_baseturfs = list(new_baseturfs)
	flags = turf_area.PlaceOnTopReact(new_baseturfs, fake_turf_type, flags) // A hook so areas can modify the incoming args

	var/turf/newT
	if(flags & CHANGETURF_SKIP) // We haven't been initialized
		if(flags_1 & INITIALIZED_1)
			stack_trace("CHANGETURF_SKIP was used in a PlaceOnTop call for a turf that's initialized. This is a mistake. [src]([type])")
		assemble_baseturfs()
	if(fake_turf_type)
		if(!new_baseturfs) // If no baseturfs list then we want to create one from the turf type
			if(!length(baseturfs))
				baseturfs = list(baseturfs)
			var/list/old_baseturfs = baseturfs.Copy()
			if(!isclosedturf(src))
				old_baseturfs += type
			newT = ChangeTurf(fake_turf_type, null, flags)
			newT.assemble_baseturfs(initial(fake_turf_type.baseturfs)) // The baseturfs list is created like roundstart
			if(!length(newT.baseturfs))
				newT.baseturfs = list(baseturfs)
			// The old baseturfs are put underneath, and we sort out the unwanted ones
			newT.baseturfs = baseturfs_string_list(old_baseturfs + (newT.baseturfs - GLOB.blacklisted_automated_baseturfs), newT)
			return newT
		if(!length(baseturfs))
			baseturfs = list(baseturfs)
		if(!isclosedturf(src))
			new_baseturfs = list(type) + new_baseturfs
		baseturfs = baseturfs_string_list(baseturfs + new_baseturfs, src)
		return ChangeTurf(fake_turf_type, null, flags)
	if(!length(baseturfs))
		baseturfs = list(baseturfs)
	if(!isclosedturf(src))
		baseturfs = baseturfs_string_list(baseturfs + type, src)
	var/turf/change_type
	if(length(new_baseturfs))
		change_type = new_baseturfs[new_baseturfs.len]
		new_baseturfs.len--
		if(new_baseturfs.len)
			baseturfs = baseturfs_string_list(baseturfs + new_baseturfs, src)

	else
		change_type = new_baseturfs
	return ChangeTurf(change_type, null, flags)

// Copy an existing turf and put it on top
// Returns the new turf
/turf/proc/CopyOnTop(turf/copytarget, ignore_bottom=1, depth=INFINITY, copy_air = FALSE)
	var/list/new_baseturfs = list()
	new_baseturfs += baseturfs
	new_baseturfs += type

	if(depth)
		var/list/target_baseturfs
		if(length(copytarget.baseturfs))
			// with default inputs this would be Copy(clamp(2, -INFINITY, baseturfs.len))
			// Don't forget a lower index is lower in the baseturfs stack, the bottom is baseturfs[1]
			target_baseturfs = copytarget.baseturfs.Copy(clamp(1 + ignore_bottom, 1 + copytarget.baseturfs.len - depth, copytarget.baseturfs.len))
		else if(!ignore_bottom)
			target_baseturfs = list(copytarget.baseturfs)
		if(target_baseturfs)
			target_baseturfs -= new_baseturfs & GLOB.blacklisted_automated_baseturfs
			new_baseturfs += target_baseturfs

	var/turf/newT = copytarget.copyTurf(src, copy_air)
	newT.baseturfs = baseturfs_string_list(new_baseturfs, newT)
	return newT
