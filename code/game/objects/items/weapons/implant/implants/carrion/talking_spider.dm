/obj/item/implant/carrion_spider/talking
	name = "talking spider"
	icon_state = "spiderling_talking"
	ignore_activate_all = TRUE
	spider_price = 15
	var/on_cooldown = FALSE

/obj/item/implant/carrion_spider/talking/activate()
	..()
	if(wearer)
		if(!on_cooldown)
			var/carrion_message = input(owner_mob, "say (text)") as text
			wearer.say(carrion_message)
			log_say("[key_name(owner_mob)] talked using the talking spider as [key_name(wearer)] and said: [carrion_message]")
			on_cooldown = TRUE
			spawn(2 SECONDS)
				on_cooldown = FALSE
		else
			to_chat(owner_mob, span_warning("[src] is not ready to speak yet"))
	else
		to_chat(owner_mob, span_warning("[src] doesn't have a host"))
