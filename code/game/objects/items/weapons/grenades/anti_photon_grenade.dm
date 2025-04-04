/obj/item/grenade/anti_photon
	name = "photon disruption grenade"
	desc = "An experimental device for temporarily removing light in a limited area."
	icon_state = "emp"
	item_state = "emp"
	det_time = 20
	origin_tech = list(TECH_BLUESPACE = 4, TECH_MATERIAL = 4)
	matter = list(MATERIAL_STEEL = 3, MATERIAL_SILVER = 2)

/obj/item/grenade/anti_photon/prime()
	playsound(loc, 'sound/effects/phasein.ogg', 50, 1, 5)
	set_light(10, -10, "#FFFFFF")

	var/extra_delay = rand(0,90)

	spawn(extra_delay)
		spawn(200)
			if(prob(10+extra_delay))
				set_light(10, 10, "#[num2hex(rand(64,255),3)][num2hex(rand(64,255),3)][num2hex(rand(64,255),3)]")
		spawn(210)
			..()
			playsound(loc, 'sound/effects/bang.ogg', 50, 1, 5)
			qdel(src)
