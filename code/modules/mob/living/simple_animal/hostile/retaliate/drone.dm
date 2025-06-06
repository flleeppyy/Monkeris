
//malfunctioning combat drones
/mob/living/simple_animal/hostile/retaliate/malf_drone
	name = "combat drone"
	desc = "An automated combat drone armed with state of the art weaponry and shielding."
	icon_state = "drone3"
	icon_dead = "drone_dead"
	ranged = 1
	rapid = 1
	speak_chance = 5
	turns_per_move = 3
	response_help = "pokes"
	response_disarm = "gently pushes aside"
	response_harm = "hits"
	speak = list("ALERT.","Hostile-ile-ile entities dee-twhoooo-wected.","Threat parameterszzzz- szzet.","Bring sub-sub-sub-systems uuuup to combat alert alpha-a-a.")
	emote_see = list("beeps menacingly","whirrs threateningly","scans its immediate vicinity")
	a_intent = I_HURT
	stop_automated_movement_when_pulled = 0
	health = 150
	maxHealth = 150
	speed = 4
	projectiletype = /obj/item/projectile/beam/drone
	projectilesound = 'sound/weapons/laser3.ogg'
	destroy_surroundings = 0
	var/datum/effect/effect/system/trail/ion/trail

	//the drone randomly switches between these states because it's malfunctioning
	var/hostile_drone = 0
	//0 - retaliate, only attack enemies that attack it
	//1 - hostile, attack everything that comes near

	var/turf/patrol_target
	var/explode_chance = 1
	var/disabled = 0
	var/exploding = 0

	//Drones aren't affected by atmos.
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	var/has_loot = 1
	faction = "malf_drone"

	mob_classification = CLASSIFICATION_SYNTHETIC

/mob/living/simple_animal/hostile/retaliate/malf_drone/New()
	..()
	if(prob(5))
		projectiletype = /obj/item/projectile/beam/pulse/drone
		projectilesound = 'sound/weapons/pulse2.ogg'
	trail = new /datum/effect/effect/system/trail/ion(src)
	trail.set_up(src)
	trail.start()

/mob/living/simple_animal/hostile/retaliate/malf_drone/allow_spacemove()
	return 1

/mob/living/simple_animal/hostile/retaliate/malf_drone/ListTargets()
	if(hostile_drone)
		return view(src, 10)
	else
		return ..()

//self repair systems have a chance to bring the drone back to life
/mob/living/simple_animal/hostile/retaliate/malf_drone/Life()

	var/htmlicon = icon2html(src, viewers(get_turf(src)))
	//emps and lots of damage can temporarily shut us down
	if(disabled > 0)
		stat = UNCONSCIOUS
		icon_state = "drone_dead"
		disabled--
		wander = 0
		speak_chance = 0
		if(disabled <= 0)
			stat = CONSCIOUS
			icon_state = "drone0"
			wander = 1
			speak_chance = 5

	//repair a bit of damage
	if(prob(1))
		src.visible_message(span_red("[htmlicon] [src] shudders and shakes as some of it's damaged systems come back online."))
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, src)
		s.start()
		health += rand(25,100)

	//spark for no reason
	if(prob(5))
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, src)
		s.start()

	//sometimes our targetting sensors malfunction, and we attack anyone nearby
	if(prob(disabled ? 0 : 1))
		if(hostile_drone)
			src.visible_message(span_blue("[htmlicon] [src] retracts several targetting vanes, and dulls it's running lights."))
			hostile_drone = 0
		else
			src.visible_message(span_red("[htmlicon] [src] suddenly lights up, and additional targetting vanes slide into place."))
			hostile_drone = 1

	if(health / maxHealth > 0.9)
		icon_state = "drone3"
		explode_chance = 0
	else if(health / maxHealth > 0.7)
		icon_state = "drone2"
		explode_chance = 0
	else if(health / maxHealth > 0.5)
		icon_state = "drone1"
		explode_chance = 0.1
	else if(health / maxHealth > 0.3)
		icon_state = "drone0"
		explode_chance = 1
	else if(health > 0)
		//if health gets too low, shut down
		icon_state = "drone_dead"
		exploding = 0
		if(!disabled)
			if(prob(50))
				src.visible_message(span_blue("[htmlicon] [src] suddenly shuts down!"))
			else
				src.visible_message(span_blue("[htmlicon] [src] suddenly lies still and quiet."))
			disabled = rand(150, 600)
			walk(src,0)

	if(exploding && prob(20))
		if(prob(50))
			src.visible_message(span_red("[htmlicon] [src] begins to spark and shake violenty!"))
		else
			src.visible_message(span_red("[htmlicon] [src] sparks and shakes like it's about to explode!"))
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, src)
		s.start()

	if(!exploding && !disabled && prob(explode_chance))
		exploding = 1
		stat = UNCONSCIOUS
		wander = 1
		walk(src,0)
		spawn(rand(50,150))
			if(!disabled && exploding)
				explosion(get_turf(src), 200, 75)
	..()

//ion rifle!
/mob/living/simple_animal/hostile/retaliate/malf_drone/emp_act(severity)
	health -= rand(3,15) * (severity + 1)
	disabled = rand(150, 600)
	hostile_drone = 0
	walk(src,0)

/mob/living/simple_animal/hostile/retaliate/malf_drone/death()
	..(null,"suddenly breaks apart.")
	qdel(src)

/mob/living/simple_animal/hostile/retaliate/malf_drone/Destroy()
	//some random debris left behind
	if(has_loot)
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, src)
		s.start()
		var/obj/O

		//shards
		O = new /obj/item/material/shard(src.loc)
		step_to(O, get_turf(pick(view(7, src))))
		if(prob(75))
			O = new /obj/item/material/shard(src.loc)
			step_to(O, get_turf(pick(view(7, src))))
		if(prob(50))
			O = new /obj/item/material/shard(src.loc)
			step_to(O, get_turf(pick(view(7, src))))
		if(prob(25))
			O = new /obj/item/material/shard(src.loc)
			step_to(O, get_turf(pick(view(7, src))))

		//rods
		O = new /obj/item/stack/rods(loc)
		step_to(O, get_turf(pick(view(7, src))))
		if(prob(75))
			O = new /obj/item/stack/rods(loc)
			step_to(O, get_turf(pick(view(7, src))))
		if(prob(50))
			O = new /obj/item/stack/rods(loc)
			step_to(O, get_turf(pick(view(7, src))))
		if(prob(25))
			O = new /obj/item/stack/rods(loc)
			step_to(O, get_turf(pick(view(7, src))))

		//plasteel
		O = new /obj/item/stack/material/plasteel(src.loc)
		step_to(O, get_turf(pick(view(7, src))))
		if(prob(75))
			O = new /obj/item/stack/material/plasteel(src.loc)
			step_to(O, get_turf(pick(view(7, src))))
		if(prob(50))
			O = new /obj/item/stack/material/plasteel(src.loc)
			step_to(O, get_turf(pick(view(7, src))))
		if(prob(25))
			O = new /obj/item/stack/material/plasteel(src.loc)
			step_to(O, get_turf(pick(view(7, src))))

		//also drop dummy circuit boards deconstructable for research (loot)
		var/obj/item/electronics/circuitboard/C

		//spawn 1-4 boards of a random type
		var/spawnees = 0
		var/num_boards = rand(1,4)
		var/list/options = list(1,2,4,8,16,32,64,128,256,512)
		for(var/i=0, i<num_boards, i++)
			var/chosen = pick(options)
			options.Remove(options.Find(chosen))
			spawnees |= chosen

		if(spawnees & 1)
			C = new(src.loc)
			C.name = "Drone CPU motherboard"
			C.origin_tech = list(TECH_DATA = rand(3, 6))

		if(spawnees & 2)
			C = new(src.loc)
			C.name = "Drone neural interface"
			C.origin_tech = list(TECH_BIO = rand(3,6))

		if(spawnees & 4)
			C = new(src.loc)
			C.name = "Drone suspension processor"
			C.origin_tech = list(TECH_MAGNET = rand(3,6))

		if(spawnees & 8)
			C = new(src.loc)
			C.name = "Drone shielding controller"
			C.origin_tech = list(TECH_BLUESPACE = rand(3,6))

		if(spawnees & 16)
			C = new(src.loc)
			C.name = "Drone power capacitor"
			C.origin_tech = list(TECH_POWER = rand(3,6))

		if(spawnees & 32)
			C = new(src.loc)
			C.name = "Drone hull reinforcer"
			C.origin_tech = list(TECH_MATERIAL = rand(3,6))

		if(spawnees & 64)
			C = new(src.loc)
			C.name = "Drone auto-repair system"
			C.origin_tech = list(TECH_ENGINEERING = rand(3,6))

		if(spawnees & 128)
			C = new(src.loc)
			C.name = "Drone plasma overcharge counter"
			C.origin_tech = list(TECH_PLASMA = rand(3,6))

		if(spawnees & 256)
			C = new(src.loc)
			C.name = "Drone targetting circuitboard"
			C.origin_tech = list(TECH_COMBAT = rand(3,6))

		if(spawnees & 512)
			C = new(src.loc)
			C.name = "Corrupted drone morality core"
			C.origin_tech = list(TECH_COVERT = rand(3,6))

	. = ..()

/obj/item/projectile/beam/drone
	damage_types = list(BURN = 15)

/obj/item/projectile/beam/pulse/drone
	damage_types = list(BURN = 10)
