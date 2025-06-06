/atom/attack_hand(mob/living/user)
	. = ..()
	if(can_buckle && buckled_mob)
		user_unbuckle_mob(user)

/atom/MouseDrop_T(mob/living/M, mob/living/user)
	. = ..()
	if(can_buckle && istype(M))
		user_buckle_mob(M, user)

/atom/proc/buckle_mob(mob/living/M)
	if(buckled_mob) //unless buckled_mob becomes a list this can cause problems
		return 0
	if(!istype(M) || (M.loc != loc) || M.buckled || M.pinned.len || (buckle_require_restraints && !M.restrained()))
		return 0


	M.buckled = src
	M.facing_dir = null
	M.set_dir(buckle_dir ? buckle_dir : dir)
	M.update_lying_buckled_and_verb_status()
	M.update_floating()
	buckled_mob = M

	post_buckle_mob(M)
	return 1

/atom/proc/unbuckle_mob()
	if(buckled_mob && buckled_mob.buckled == src)
		. = buckled_mob
		buckled_mob.buckled = null
		buckled_mob.anchored = initial(buckled_mob.anchored)
		buckled_mob.update_lying_buckled_and_verb_status()
		buckled_mob.update_floating()
		buckled_mob = null

		post_buckle_mob(.)

/atom/proc/post_buckle_mob(mob/living/M)
	if(buckle_pixel_shift)
		if(M == buckled_mob)
			var/list/pixel_shift = cached_key_number_decode(buckle_pixel_shift)
			animate(M, pixel_x = M.default_pixel_x + pixel_shift["x"], pixel_y = M.default_pixel_y + pixel_shift["y"], 4, 1, LINEAR_EASING)
		else
			animate(M, pixel_x = M.default_pixel_x, pixel_y = M.default_pixel_y, 4, 1, LINEAR_EASING)

/atom/proc/user_buckle_mob(mob/living/M, mob/user)
	if(!user.Adjacent(M) || user.restrained() || user.stat || istype(user, /mob/living/silicon/pai))
		return 0
	if(M == buckled_mob)
		return 0
	if(isslime(M))
		to_chat(user, span_warning("\The [M] is too squishy to buckle in."))
		return 0
	if(user.mob_size < M.mob_size)
		to_chat(user, span_warning("\The [M] is too heavy to buckle in."))
		return 0

	add_fingerprint(user)
	unbuckle_mob()

	//can't buckle unless you share locs so try to move M to the atom.
	if(M.loc != src.loc)
		step_towards(M, src)

	. = buckle_mob(M)
	if(.)
		if(M == user)
			M.visible_message(\
				span_notice("\The [M.name] buckles themselves to \the [src]."),\
				span_notice("You buckle yourself to \the [src]."),\
				span_notice("You hear metal clanking."))
		else
			M.visible_message(\
				span_danger("\The [M.name] is buckled to \the [src] by \the [user.name]!"),\
				span_danger("You are buckled to \the [src] by \the [user.name]!"),\
				span_notice("You hear metal clanking."))

/atom/proc/user_unbuckle_mob(mob/user)
	var/mob/living/M = unbuckle_mob()
	if(M)
		if(M != user)
			M.visible_message(\
				span_notice("\The [M.name] was unbuckled by \the [user.name]!"),\
				span_notice("You were unbuckled from \the [src] by \the [user.name]."),\
				span_notice("You hear metal clanking."))
		else
			M.visible_message(\
				span_notice("\The [M.name] unbuckled themselves!"),\
				span_notice("You unbuckle yourself from \the [src]."),\
				span_notice("You hear metal clanking."))
		add_fingerprint(user)
	return M

