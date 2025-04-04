/obj/machinery/igniter
	name = "igniter"
	desc = "It's useful for igniting flammable items."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "igniter1"
	var/id = null
	var/on = FALSE
	plane = FLOOR_PLANE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 4
	var/_wifi_id
	var/datum/wifi/receiver/button/igniter/wifi_receiver

/obj/machinery/igniter/New()
	..()
	update_icon()

/obj/machinery/igniter/Initialize()
	. = ..()
	update_icon()
	if(_wifi_id)
		wifi_receiver = new(_wifi_id, src)

/obj/machinery/igniter/update_icon()
	..()
	icon_state = "igniter[on]"

/obj/machinery/igniter/Destroy()
	qdel(wifi_receiver)
	wifi_receiver = null
	return ..()

/obj/machinery/igniter/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/igniter/attack_hand(mob/user as mob)
	if(..())
		return 1
	ignite()

/obj/machinery/igniter/Process()	//ugh why is this even in process()?
	if (on && powered() )
		var/turf/location = src.loc
		if (isturf(location))
			location.hotspot_expose(1000,500,1)
	return 1

/obj/machinery/igniter/power_change()
	..()
	update_icon()

/obj/machinery/igniter/proc/ignite()
	use_power(50)
	on = !on
	update_icon()


// Wall mounted remote-control igniter.

/obj/machinery/sparker
	name = "Mounted igniter"
	desc = "A wall-mounted ignition device."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "migniter"
	var/id = null
	var/disable = 0
	var/last_spark = 0
	var/base_state = "migniter"
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 4
	var/_wifi_id
	var/datum/wifi/receiver/button/sparker/wifi_receiver

/obj/machinery/sparker/Initialize()
	. = ..()
	if(_wifi_id)
		wifi_receiver = new(_wifi_id, src)

/obj/machinery/sparker/Destroy()
	qdel(wifi_receiver)
	wifi_receiver = null
	return ..()

/obj/machinery/sparker/update_icon()
	..()
	if(disable)
		icon_state = "migniter-d"
	else if(powered())
		icon_state = "migniter"
//		src.sd_SetLuminosity(2)
	else
		icon_state = "migniter-p"
//		src.sd_SetLuminosity(0)

/obj/machinery/sparker/power_change()
	..()
	update_icon()

/obj/machinery/sparker/attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W, /obj/item/tool/screwdriver))
		add_fingerprint(user)
		disable = !disable
		if(disable)
			user.visible_message(span_warning("[user] has disabled the [src]!"), span_warning("You disable the connection to the [src]."))
		else if(!disable)
			user.visible_message(span_warning("[user] has reconnected the [src]!"), span_warning("You fix the connection to the [src]."))
		update_icon()

/obj/machinery/sparker/attack_ai()
	if (anchored)
		return ignite()
	else
		return

/obj/machinery/sparker/proc/ignite()
	if (!powered())
		return

	if (disable || (last_spark && world.time < last_spark + 50))
		return


	flick("migniter-spark", src)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(2, 1, src)
	s.start()
	src.last_spark = world.time
	use_power(1000)
	var/turf/location = src.loc
	if (isturf(location))
		location.hotspot_expose(1000,500,1)
	return 1

/obj/machinery/sparker/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	ignite()
	..(severity)

/obj/machinery/button/ignition
	name = "ignition switch"
	desc = "A remote control switch for a mounted igniter."

/obj/machinery/button/ignition/attack_hand(mob/user as mob)

	if(..())
		return

	use_power(5)

	active = 1
	icon_state = "launcher1"

	for(var/obj/machinery/sparker/M in GLOB.machines)
		if (M.id == id)
			spawn( 0 )
				M.ignite()

	for(var/obj/machinery/igniter/M in GLOB.machines)
		if(M.id == id)
			M.ignite()

	sleep(50)

	icon_state = "launcher0"
	active = 0

	return
