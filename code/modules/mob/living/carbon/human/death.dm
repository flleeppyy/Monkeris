/mob/living/carbon/human/gib(max_range=3, keep_only_robotics=FALSE)

	var/on_turf = istype(loc, /turf)

	for(var/obj/item/organ/I in internal_organs)
		if (!(keep_only_robotics && !(I.nature == MODIFICATION_SILICON)))
			I.removed()
			if(on_turf)
				I.throw_at(get_edge_target_turf(src,pick(alldirs)),rand(1,max_range),30)

	for(var/obj/item/organ/external/E in src.organs)
		if (!(keep_only_robotics && !(E.nature == MODIFICATION_SILICON)))
			E.droplimb(TRUE, DROPLIMB_EDGE, 1)
			if(on_turf)
				E.throw_at(get_edge_target_turf(src,pick(alldirs)),rand(1,max_range),30)

	for(var/obj/item/D in src)
		if (keep_only_robotics && istype(D, /obj/item/organ))
			continue
		else
			drop_from_inventory(D)
			D.throw_at(get_edge_target_turf(src,pick(alldirs)), rand(1,max_range), round(30/D.w_class))

	..(species.gibbed_anim)
	gibs(loc, src, null, species.flesh_color, species.blood_color)

/mob/living/carbon/human/dust()
	if(species)
		..(species.dusted_anim, species.remains_type)
	else
		..()

/mob/living/carbon/human/death(gibbed)
	if(stat == DEAD) return

	BITSET(hud_updateflag, HEALTH_HUD)
	BITSET(hud_updateflag, STATUS_HUD)
	BITSET(hud_updateflag, LIFE_HUD)

	//Handle species-specific deaths.
	species.handle_death(src)

	callHook("death", list(src, gibbed))

	if(wearing_rig)
		wearing_rig.notify_ai(
			span_danger("Warning: user death event. Mobility control passed to integrated intelligence system.")
		)
	var/message = species.death_message
	if(stats.getPerk(PERK_TERRIBLE_FATE))
		message = "their inert body emits a strange sensation and a cold invades your body. Their screams before dying recount in your mind."
	. = ..(gibbed,message)
	if(!gibbed)
		dizziness = 0
		jitteriness = 0
		handle_organs()
		dead_HUD()
		if(species.death_sound)
			mob_playsound(loc, species.death_sound, 80, 1, 1)
	handle_hud_list()

	var/obj/item/implant/core_implant/cruciform/C = get_core_implant(/obj/item/implant/core_implant/cruciform)
	if(C && C.active)
		lost_cruciforms |= C
		var/obj/item/cruciform_upgrade/upgrade = C.upgrade
		if(upgrade && upgrade.active && istype(upgrade, CUPGRADE_MARTYR_GIFT))
			var/obj/item/cruciform_upgrade/martyr_gift/martyr = upgrade
			visible_message(span_danger("The [C] emit a massive light!"))
			var/burn_damage_done
			for(var/mob/living/L in oviewers(6, src))
				if(ishuman(L))
					var/mob/living/carbon/human/H = L
					if(H in disciples)
						continue
					else if (H.random_organ_by_process(BP_SPCORE) || H.active_mutations.len)
						burn_damage_done = (martyr.burn_damage / get_dist(src, H)) * 2
						H.adjustFireLoss(burn_damage_done)
					else
						burn_damage_done = martyr.burn_damage / get_dist(src, H)
						H.adjustFireLoss(burn_damage_done)
					to_chat(H, span_danger("You are get hurt by holy light!"))
				else
					burn_damage_done = martyr.burn_damage / get_dist(src, L)
					L.damage_through_armor(burn_damage_done, BURN)

			qdel(martyr)
			C.upgrade = null


/mob/living/carbon/human/proc/ChangeToHusk()
//	if(HUSK in mutations)	return

	if(f_style)
		f_style = "Shaved"	//we only change the icon_state of the hair datum, so it doesn't mess up their UI/UE
	if(h_style)
		h_style = "Bald"
	update_hair(0)

//	mutations.Add(HUSK)
	status_flags |= DISFIGURED	//makes them unknown without fucking up other stuff like admintools
	update_body(1)
	return

/mob/living/carbon/human/proc/Drain()
	ChangeToHusk()
	return

