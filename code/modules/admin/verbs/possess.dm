/proc/possess(obj/O as obj)
	set name = "Possess Obj"
	set category = "Object"

	if(istype(O,/obj/singularity))
		if(CONFIG_GET(flag/forbid_singulo_possession))
			to_chat(usr, "It is forbidden to possess singularities.")
			return

	log_and_message_admins("has possessed [O]")

	if(!usr.control_object) //If you're not already possessing something...
		usr.name_archive = usr.real_name

	usr.forceMove(O)
	usr.real_name = O.name
	usr.SetName(O.name)
	usr.client.eye = O
	usr.control_object = O
	usr.ReplaceMovementHandler(/datum/movement_handler/mob/admin_possess)

/proc/release(obj/O)
	set name = "Release Obj"
	set category = "Object"
	//usr.loc = get_turf(usr)

	if(usr.control_object && usr.name_archive) //if you have a name archived and if you are actually relassing an object
		usr.RemoveMovementHandler(/datum/movement_handler/mob/admin_possess)
		usr.real_name = usr.name_archive
		usr.SetName(usr.real_name)
		if(ishuman(usr))
			var/mob/living/carbon/human/H = usr
			H.SetName(H.get_visible_name())
//		usr.regenerate_icons() //So the name is updated properly

	usr.forceMove(O.loc) // Appear where the object you were controlling is -- TLE
	usr.client.eye = usr
	usr.control_object = null
