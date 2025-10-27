//handles setting lastKnownIP and computer_id for use by the ban systems as well as checking for multikeying
/mob/proc/update_Login_details()
	//Multikey checks and logging
	lastKnownIP	= client.address
	computer_id	= client.computer_id
	log_access("Login: [key_name(src)] from [lastKnownIP ? lastKnownIP : "localhost"]-[computer_id] || BYOND v[client.byond_version]")
	if(CONFIG_GET(flag/log_access))
		var/is_multikeying = 0
		for(var/mob/M in GLOB.player_list)
			if(M == src)	continue
			if( M.key && (M.key != key) )
				var/matches
				if( (M.lastKnownIP == client.address) )
					matches += "IP ([client.address])"
				if( (client.connection != "web") && (M.computer_id == client.computer_id) )
					if(matches)	matches += " and "
					matches += "ID ([client.computer_id])"
					is_multikeying = 1
				if(matches)
					if(M.client)
						message_admins("<font color='red'><B>Notice: </B></font><font color='blue'><A href='byond://?src=\ref[usr];priv_msg=\ref[src]'>[key_name_admin(src)]</A> has the same [matches] as <A href='byond://?src=\ref[usr];priv_msg=\ref[M]'>[key_name_admin(M)]</A>.</font>", 1)
						log_access("Notice: [key_name(src)] has the same [matches] as [key_name(M)].")
					else
						message_admins("<font color='red'><B>Notice: </B></font><font color='blue'><A href='byond://?src=\ref[usr];priv_msg=\ref[src]'>[key_name_admin(src)]</A> has the same [matches] as [key_name_admin(M)] (no longer logged in). </font>", 1)
						log_access("Notice: [key_name(src)] has the same [matches] as [key_name(M)] (no longer logged in).")
		if(is_multikeying && !client.warned_about_multikeying)
			client.warned_about_multikeying = 1
			spawn(1 SECONDS)
				to_chat(src, "<b>WARNING:</b> It would seem that you are sharing connection or computer with another player. If you haven't done so already, please contact the staff via the Adminhelp verb to resolve this situation. Failure to do so may result in administrative action. You have been warned.")

/mob/Login()
	if(!client)
		return FALSE
	GLOB.player_list |= src
	update_Login_details()
	canon_client = client
	client.persistent_client.set_mob(src)

	world.update_status()

	client.images = list()				//remove the images such as AIs being unable to see runes
	client.screen = list()				//remove hud items just in case
	if(hud_used)
		qdel(hud_used)		//remove the hud objects
	if (!isnewplayer(src))
		hud_used = new /datum/hud(src)

	next_move = 1
	sight |= SEE_SELF
	client.statobj = src

	MakeParallax()

	// We don't call the parent login proc. Previous comment below.
	// --
	// BYOND's internal implementation of login does two things
	// 1: Set statobj to the mob being logged into (We got this covered)
	// 2: And I quote "If the mob has no location, place it near (1,1,1) if possible"
	// See, near is doing an agressive amount of legwork there
	// What it actually does is takes the area that (1,1,1) is in, and loops through all those turfs
	// If you successfully move into one, it stops
	// Because we want Move() to mean standard movements rather then just what byond treats it as (ALL moves)
	// We don't allow moves from nullspace -> somewhere. This means the loop has to iterate all the turfs in (1,1,1)'s area
	// For us, (1,1,1) is a space tile. This means roughly 200,000! calls to Move()
	// You do not want this

	if(!client)
		return FALSE

	SEND_SIGNAL_OLD(src, COMSIG_MOB_LOGIN)
	// the datum fires first than actual login. Do actual login first before triggering login events
	GLOB.logged_in_event.raise_event(src)

	if (key != client.key)
		key = client.key

	if(loc && !isturf(loc))
		client.eye = loc
		client.perspective = EYE_PERSPECTIVE
	else
		client.eye = src
		client.perspective = MOB_PERSPECTIVE

	// This is located here instead of under /mob/living/silicon/robot/Login() to make sure that player looses "robot" macro in all cases when they stop being a robot
	winset(src, null, "mainwindow.macro=[isrobot(src) ? "robot" : "default"]")

	if(client)
		if(client.UI)
			client.UI.show()
		else
			client.create_UI(src.type)

		add_click_catcher()
		update_action_buttons()

		client.CAN_MOVE_DIAGONALLY = FALSE

		for(var/datum/action/A as anything in persistent_client.player_actions)
			A.Grant(src)

		for(var/datum/callback/CB as anything in persistent_client.post_login_callbacks)
			CB.Invoke()

		log_played_names(
			client.ckey,
			list(
				"[name]" = tag,
				"[real_name]" = tag,
			),
		)

	update_client_colour(0)

	if(GLOB.admin_notice)
		to_chat(src, span_notice("<b>Admin Notice:</b>\n \t [GLOB.admin_notice]"))

	return TRUE
